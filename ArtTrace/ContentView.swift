import SwiftUI
import AVFoundation
import PhotosUI

// MARK: - Main Application View
struct ContentView: View {
    // Camera & Image State
    @State private var session = AVCaptureSession()
    @State private var referenceImage: UIImage? = nil
    @State private var showingPicker = false
    
    // Transformation State
    @State private var scale: CGFloat = 1.0
    @State private var offset = CGSize.zero
    @State private var lastOffset = CGSize.zero
    @State private var opacity: Double = 0.5
    
    // UI State
    @State private var isLocked = false
    
    var body: some View {
        ZStack {
            // 1. BACKGROUND: Live Camera Feed
            CameraView(session: $session)
                .ignoresSafeArea()
            
            // 2. MIDDLE: The Reference Image
            if let img = referenceImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .scaleEffect(scale)
                    .offset(offset)
                    .opacity(opacity)
                    .disabled(isLocked)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isLocked {
                                    self.offset = CGSize(
                                        width: value.translation.width + lastOffset.width,
                                        height: value.translation.height + lastOffset.height
                                    )
                                }
                            }
                            .onEnded { _ in
                                self.lastOffset = self.offset
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                if !isLocked { self.scale = value }
                            }
                    )
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "hand.draw")
                        .font(.system(size: 60))
                    Text("Tap the photo icon to load a sketch")
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(40)
                .background(Color.black.opacity(0.5))
                .cornerRadius(20)
            }
            
            // 3. TOP: Interface Overlays
            VStack {
                HStack {
                    Button(action: { showingPicker = true }) {
                        ControlIcon(systemName: "photo.on.rectangle", color: .blue)
                    }
                    .disabled(isLocked)
                    .opacity(isLocked ? 0.3 : 1.0)
                    
                    Spacer()
                    
                    Button(action: { isLocked.toggle() }) {
                        ControlIcon(
                            systemName: isLocked ? "lock.fill" : "lock.open.fill",
                            color: isLocked ? .red : .green
                        )
                    }
                }
                .padding(.top, 50)
                .padding(.horizontal)

                Spacer()
                
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "eye.fill")
                            .foregroundColor(.white)
                        Slider(value: $opacity, in: 0.1...1.0)
                            .accentColor(.white)
                    }
                    
                    Text(isLocked ? "CANVAS LOCKED" : "Pinch to Zoom • Drag to Move")
                        .font(.caption2)
                        .kerning(1.2)
                        .foregroundColor(isLocked ? .red : .gray)
                        .bold()
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(25)
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
        // We use the new unique name here
        .sheet(isPresented: $showingPicker) {
            ArtImagePicker(image: $referenceImage)
        }
        .onAppear {
            checkPermissionsAndStart()
        }
    }
    
    func checkPermissionsAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted { setupCamera() }
            }
        default: break
        }
    }

    func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        if session.canAddInput(input) {
            session.addInput(input)
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        }
    }
}

// MARK: - Camera Components
struct CameraView: UIViewRepresentable {
    @Binding var session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - Unique Image Picker Name
struct ArtImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ArtImagePicker
        init(_ parent: ArtImagePicker) { self.parent = parent }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }

            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
}

// MARK: - UI Helpers
struct ControlIcon: View {
    var systemName: String
    var color: Color
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 22, weight: .bold))
            .padding()
            .background(color)
            .foregroundColor(.white)
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

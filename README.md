# ArtGhost: Da Vinci Eye Clone for iOS

ArtGhost is a digital "Camera Lucida" or art projector app. It uses alpha-blending to overlay a reference image from your photo library onto your live camera feed, allowing you to trace complex proportions onto physical paper with ease.

## 🚀 Features
- **Live AR Overlay:** Transparent image overlay on top of the back camera.
- **Precision Controls:** Pinch-to-zoom and drag-to-reposition reference images.
- **Opacity Slider:** Adjust the "ghost" level to see both your hand and the art.
- **Safety Lock:** Toggle interaction off once your art is aligned to prevent accidental movement.
- **Photo Library Integration:** Import any image using the modern iOS Photo Picker.

---

## 🛠 Installation (Physical Device)

### Option A: Swift Playgrounds (Recommended for iOS 26+)
Since this device is running iOS 26.3.01, using Swift Playgrounds on the device itself avoids version conflicts with older Xcode installs.

1. Download **Swift Playgrounds** from the App Store on your iPhone 16 Plus.
2. Open the app and tap **+ App** to create a new project.
3. Replace the contents of `ContentView.swift` with the code in this repository.
4. Tap the **App Settings** (gear icon) -> **Capabilities**.
5. Add the **Camera** and **Photo Library** capabilities.
6. Hit **Play**.

### Option B: Xcode (Manual Deployment)
1. Clone this repository: `git clone https://github.com/your-username/ArtTrace.git`
2. Open `ArtTrace.xcodeproj` in Xcode.
3. Go to the **Signing & Capabilities** tab.
4. Select your **Team** (Apple ID) and ensure the **Bundle Identifier** is unique.
5. Add the following to your `Info.plist`:
   - `Privacy - Camera Usage Description`: "ArtGhost needs the camera to overlay art onto your paper."
   - `Privacy - Photo Library Usage Description`: "ArtGhost needs access to your photos to select art for tracing."
6. Connect your iPhone via USB and press **Cmd + R**.

---

## 🎨 How to Use
1. **Setup:** Mount your iPhone 16 Plus on a stand so it is parallel to your drawing surface.
2. **Import:** Tap the **Photo Icon** to select the image you want to trace.
3. **Align:** Use two fingers to scale and one finger to move the image over your paper.
4. **Lock:** Tap the **Lock Icon** (it will turn red). This disables touch so you can draw without shifting the image.
5. **Trace:** Look at your phone screen while moving your pencil on the actual paper.

---

## ⚠️ Disclaimer
Drawing through a screen can cause eye strain. Ensure you have adequate lighting on your physical paper and take breaks every 20 minutes!

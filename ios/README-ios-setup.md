# iOS — cấu hình & các bước còn lại

Toàn bộ code Dart dùng chung cho Android/iOS. Phần native iOS **đã chuẩn bị nhưng CHƯA được build/chạy** (máy chưa cài Xcode). Dưới đây là những gì đã làm sẵn và việc còn phải làm.

## ✅ Đã chuẩn bị sẵn
- `Runner/Info.plist`:
  - `CFBundleDisplayName = Calculator` (ngụy trang — tên app trên home screen là "Calculator")
  - `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, `NSPhotoLibraryAddUsageDescription`, `NSFaceIDUsageDescription` — **bắt buộc**, thiếu là app crash khi chạm camera/ảnh/Face ID.
- `Podfile`: `platform :ios, '13.0'` + ép mọi pod tối thiểu iOS 13 (camera, file_picker cần).
- `Runner/SceneDelegate.swift`: đã wire MethodChannel `vault/app_icon` → `setAlternateIconName` (đổi icon ngụy trang). Sẽ no-op an toàn cho tới khi có icon assets (mục dưới).
- Deployment target trong project = iOS 13.0.

## ⚠️ Cần làm khi đã có Xcode

### 1. Cài Xcode + chạy lần đầu
```bash
# Sau khi cài Xcode từ App Store:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
cd ios && pod install && cd ..
flutter run -d <ios-device-or-simulator>
```

### 2. Bundle ID + ký ứng dụng
Mở `ios/Runner.xcworkspace` trong Xcode → tab **Signing & Capabilities** → chọn **Team** (Personal Team miễn phí OK, app chạy 7 ngày). Đổi Bundle ID sang giá trị duy nhất (vd `com.vault.hdhsolution.vaultcal`).

### 3. Icon ngụy trang (đổi Weather/Compass) — cần asset
Cơ chế native đã wire sẵn, chỉ còn thêm ảnh:
1. Chuẩn bị 2 bộ icon PNG (mỗi bộ 60x60@2x=120px, @3x=180px, và các size khác nếu muốn phủ đủ).
2. Thêm vào `Info.plist`:
   ```xml
   <key>CFBundleIcons</key>
   <dict>
     <key>CFBundleAlternateIcons</key>
     <dict>
       <key>AppIconWeather</key>
       <dict>
         <key>CFBundleIconFiles</key><array><string>AppIconWeather</string></array>
         <key>UIPrerenderedIcon</key><false/>
       </dict>
       <key>AppIconCompass</key>
       <dict>
         <key>CFBundleIconFiles</key><array><string>AppIconCompass</string></array>
         <key>UIPrerenderedIcon</key><false/>
       </dict>
     </dict>
   </dict>
   ```
3. Đặt file `AppIconWeather@2x.png`, `AppIconWeather@3x.png`, `AppIconCompass@2x.png`, `AppIconCompass@3x.png` vào thư mục `Runner/` (KHÔNG bỏ trong Assets.xcassets — alternate icons phải là file rời).

Tên `AppIconWeather` / `AppIconCompass` khớp với `SceneDelegate.swift`. Nếu chưa thêm, chọn Weather/Compass trong app sẽ không đổi icon nhưng **không crash** (Dart nuốt lỗi).

### 4. Khác biệt hành vi so với Android
- Đổi icon: iOS hiện popup hệ thống "You have changed the icon…" (không tắt được, do Apple). Android đổi thầm lặng.
- `allowBackup=false` (Android) không có tương đương — iOS mặc định không backup Keychain qua iCloud nếu dùng `.afterFirstUnlockThisDeviceOnly` (flutter_secure_storage cấu hình được nếu cần).

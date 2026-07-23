# App Icon — "Paper Calc" (3c)

Icon ngụy trang máy tính cho app Vault. Nền `#F5F5F7`, phím `#DCDCE1`, accent `#3B6BFF` — khớp với UI trong app.

## iOS
Thư mục `ios/` chứa đủ các kích thước PNG (vuông, không bo góc — iOS tự bo).
- `icon_1024.png` → App Store / Assets.xcassets (App Store iOS 1024pt).
- Kéo cả thư mục vào **Assets.xcassets → AppIcon**, hoặc dùng công cụ tạo AppIcon set. Với Xcode 14+ bạn chỉ cần cấp **icon_1024.png** (single size), Xcode tự sinh phần còn lại.
- Các size lẻ (180/167/152/120/87/80/76/60/58/40/29/20) đã có sẵn nếu cần asset catalog thủ công.

## Android
Thư mục `android/` theo đúng cấu trúc `res/`:
- `mipmap-<dpi>/ic_launcher.png` + `ic_launcher_round.png` — icon legacy (Android ≤ 7.1).
- `mipmap-<dpi>/ic_launcher_foreground.png` + `ic_launcher_background.png` — lớp cho adaptive icon (Android 8+). Foreground đã đặt trong "safe zone" (nội dung thu 72%).
- `mipmap-anydpi-v26/ic_launcher.xml` — khai báo adaptive icon (background = màu, foreground, monochrome cho themed icon Android 13+).
- `values/ic_launcher_background.xml` — màu nền `#F5F5F7`.
- `playstore_512.png` — icon 512×512 cho Google Play Console.

Copy nội dung `android/` vào `app/src/main/res/` của dự án. `AndroidManifest.xml` dùng `android:icon="@mipmap/ic_launcher"` (và `android:roundIcon="@mipmap/ic_launcher_round"`).

## Flutter (khuyến nghị)
Dùng package **flutter_launcher_icons** cho nhanh — chỉ cần 1 file nguồn 1024:

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.1

flutter_launcher_icons:
  image_path: "app_icons/ios/icon_1024.png"
  android: true
  ios: true
  adaptive_icon_background: "#F5F5F7"
  adaptive_icon_foreground: "app_icons/android/mipmap-xxxhdpi/ic_launcher_foreground.png"
  remove_alpha_ios: true
```
Rồi chạy: `dart run flutter_launcher_icons`

## Nguồn chỉnh sửa
`icon_master.html` (ở gốc project) là bản dựng vector bằng HTML/CSS nếu bạn muốn tinh chỉnh rồi export lại.

# Handoff: Vault App (Calculator Disguise) — Flutter

## Overview
Ứng dụng **kho bảo mật ngụy trang dưới dạng máy tính**. Khi mở app, người dùng chỉ thấy một máy tính bình thường. Nhập một mật mã bí mật sẽ kích hoạt luồng mở khóa (quét vân tay → PIN lớp 2) và vào Dashboard kho lưu trữ. Có cơ chế **kho giả (decoy)** để đối phó khi bị ép mở khóa, và màn Cài đặt với các tính năng cao cấp (IAP).

Toàn bộ prototype nằm trong **1 file HTML**: `Calculator.dc.html` (kèm theo trong thư mục này).

## About the Design Files
File `Calculator.dc.html` là **bản thiết kế tham chiếu viết bằng HTML/CSS/JS** — một prototype thể hiện *giao diện và hành vi mong muốn*, KHÔNG phải code để copy trực tiếp. Nhiệm vụ là **dựng lại thiết kế này trong dự án Flutter** bằng widget/pattern chuẩn của Flutter (Material 3, `AnimatedContainer`, `PageView`/`AnimatedSwitcher`, `showModalBottomSheet`, v.v.). Các con số (px, màu hex, bo góc, thời lượng animation) trong tài liệu này là nguồn chính xác để tái tạo pixel-perfect.

> Lưu ý về đơn vị: HTML dùng `px`. Trong Flutter dùng **logical pixels (dp)** — tỉ lệ 1:1, cứ lấy số px làm dp. Khung máy được thiết kế ở **392 × 812** (tỉ lệ điện thoại); trong app thật hãy để layout co giãn theo `MediaQuery`/`LayoutBuilder`, không hard-code 392×812 (đó chỉ là khung mockup).

## Fidelity
**High-fidelity (hifi).** Đã chốt màu, typography, spacing, bo góc, animation. Hãy tái tạo pixel-perfect bằng thư viện/hệ thiết kế sẵn có của dự án Flutter.

---

## Design Tokens

### Màu — Máy tính (có 2 theme)
| Token | Light | Dark |
|---|---|---|
| Nền app | `#F4F4F6` | `#0D0D10` |
| Phím số (nền / chữ) | `#FFFFFF` / `#1C1C1E` | `#26262B` / `#F5F5F7` |
| Phím chức năng AC/%/⌫ (nền / chữ) | `#E5E5EA` / `#1C1C1E` | `#3A3A40` / `#F5F5F7` |
| Phím toán tử (nền / chữ) | `#EEF1FB` / `#3B6BFF` | `#26262B` / `#8AB0FF` |
| Phím `=` (nền / chữ) | `#3B6BFF` / `#FFFFFF` | `#4F7DFF` / `#FFFFFF` |
| Chữ hiển thị / phụ | `#1C1C1E` / `#8A8A92` | `#FFFFFF` / `#8A8A92` |

### Màu — Kho / Dashboard / Settings (luôn Dark)
| Token | Hex |
|---|---|
| Nền | `#0C0C0F` |
| Card | `#16161B` |
| Card viền | `#23232B` |
| Divider | `#202027` |
| Chữ chính / phụ / mờ | `#FFFFFF` / `#8A8A92` / `#6A6A72` |
| Xanh "đã mở khóa" / OK | `#48D18A` |
| Accent chính (FAB, progress) | `oklch(0.62 0.16 265)` ≈ `#5B6FE0` |
| Đỏ cảnh báo (intruder, sai PIN) | `#E5484D` |
| Vàng Premium (crown) | `#F5C518` |

Màu icon thư mục dùng công thức **oklch cùng lightness/chroma, khác hue** (nền `oklch(0.33 0.07 H)`, icon `oklch(0.76 0.15 H)`):
- Hình ảnh H=255 (xanh dương) · Video H=25 (đỏ cam) · Tài liệu H=150 (xanh lá) · Ghi chú mật H=305 (tím) · Ảnh màn hình H=200 (cyan) · Ghi chú H=70 (hổ phách)
> Flutter chưa hỗ trợ oklch trực tiếp → convert sang hex hoặc dùng package hỗ trợ. Giá trị hex xấp xỉ ở phần Screens.

### Typography
- Font: **system** (`-apple-system` iOS / `Roboto` Android). Dùng `SF Pro` / mặc định hệ.
- Số hiển thị máy tính: weight **300 (light)**, size **72 → 34** tự co theo độ dài (72 nếu ≤7 ký tự, 58 nếu ≤9, 44 nếu ≤12, 34 nếu dài hơn), `letter-spacing: -1`.
- Tiêu đề màn (Kho riêng tư / Cài đặt): **700**, 24–27, `letter-spacing: -0.5`.
- Section label (BẢO MẬT…): **700**, 12.5, `letter-spacing: 0.4`, màu `#8A8A92`, viết HOA.
- Body: 15–16 / weight 600 tiêu đề dòng, 12–13 phụ đề.

### Spacing / hình khối
- Bo góc: khung máy 48; card lớn 20–24; phím 24; icon tile 11–14; FAB 22; bottom sheet 30 (chỉ 2 góc trên); nút pill 14–20.
- Padding card: 16–20. Gap lưới: 14.
- FAB: **60×60**, đặt `bottom: 28, right: 24`, shadow `0 10px 26px -6px accent@70%`.
- Switch toggle: track **46×28** bo 15; knob **22** tròn trắng, dịch `translateX(18)` khi bật.

### Animation
| Hiệu ứng | Thời lượng | Easing |
|---|---|---|
| Chuyển màn (slide + fade) | 500ms transform / 400ms opacity | `cubic-bezier(.4,0,.2,1)` |
| Quét vân tay (đường quét) | 1800ms lặp | `cubic-bezier(.4,0,.2,1)` |
| Vòng scan quay | 1100ms lặp | linear |
| Nhấn phím (pop) | 150ms | ease |
| Rung sai PIN | 450ms | ease |
| FAB xoay `+`→`×` | 300ms | `cubic-bezier(.34,1.56,.64,1)` (nảy) |
| Bottom sheet trượt lên | 380–400ms | `cubic-bezier(.4,0,.2,1)` |
| Toggle knob | 280ms | `cubic-bezier(.4,0,.2,1)` |
| Progress dung lượng | 900ms (từ 0) | `cubic-bezier(.4,0,.2,1)` |

---

## Screens / Views

### 1. Máy tính (Calculator) — màn ngụy trang
- **Mục đích**: Trông như máy tính mặc định của OS; tính toán thật; ẩn hoàn toàn bản chất bảo mật.
- **Layout**: cột dọc — thanh trên (giờ `9:41` + nút đổi theme ☾/☀ 34×34 tròn), vùng hiển thị (căn phải, đáy: dòng biểu thức phụ 20px + kết quả lớn), bàn phím **grid 4 cột, gap 14**.
- **Bàn phím** (5 hàng): `AC % ⌫ ÷` / `7 8 9 ×` / `4 5 6 −` / `1 2 3 +` / `0(rộng 2 ô) . =`. Phím `aspect-ratio 1`, `=` là accent, toán tử màu accent.
- **Flutter**: `GridView`/`Column`+`Row` với `Expanded`; `AspectRatio`; đổi theme = `AnimatedContainer`/`ValueNotifier`.

### 2. Chuyển cảnh mở khóa (Unlock / quét vân tay) — Lớp 1
- Kích hoạt khi nhập mật mã bí mật rồi `=` (xem State). Màn máy tính trượt trái + mờ, màn này hiện.
- **Nội dung**: tiêu đề "Xác thực bảo mật" / "Lớp 1 · Sinh trắc học"; vòng tròn 168 có **vòng scan quay** (accent) + **pad vân tay** (các cung tròn đồng tâm nhấp nháy) + **đường quét** chạy dọc phát sáng; trạng thái "Đang quét vân tay…" → khi xong: vân tay đổi xanh `#48D18A`, hiện ✓, chữ "Đã xác thực". Tự chuyển sang PIN sau ~2.6s.
- **Flutter**: `AnimationController` lặp cho vòng quay + đường quét; các cung tròn = `Container` bo tròn chỉ có `border top` (hoặc `CustomPaint` vẽ arc).

### 3. PIN Lớp 2
- **Nội dung**: icon ổ khóa 52×52, tiêu đề "Mã PIN lớp 2", phụ đề "Nhập 4 chữ số để tiếp tục"; **4 chấm** trạng thái; bàn phím **3 cột**: `1-9`, hàng cuối `(trống) 0 ⌫`; phím tròn 64.
- Nhập đủ 4 số → kiểm tra; **sai** → chấm đỏ + rung, xóa nhập lại.
- **Flutter**: state chuỗi pin; `Wrap`/`GridView` 3 cột; hiệu ứng rung = `TweenSequence` translateX; ổ khóa vẽ bằng 2 `Container` (thân + quai).

### 4a. Dashboard — Kho thật (Dark)
- **Header**: nhãn "● Đã mở khóa" (xanh) + tiêu đề "Kho riêng tư"; bên phải: nút ⚙ (mở Settings) + nút "Khóa".
- **Card dung lượng**: "Dung lượng đã dùng" + "2,4 GB / 5 GB" + % accent; **thanh progress** (track `#26262B`, fill gradient accent, 48%); 3 chú thích chấm màu (Ảnh/Video/Khác).
- **Lưới thư mục** 2 cột: Hình ảnh (128), Video (36), Tài liệu (54), Ghi chú mật (12, có badge ổ khóa nhỏ). Card `#16161B`, bo 22, icon tile 46 màu theo hue.
- **FAB `+`** góc phải dưới → mở **bottom sheet "Thêm vào kho"** (Ảnh & Video / Tài liệu…), có scrim mờ.
- **Flutter**: `CustomScrollView`; progress = `LinearProgressIndicator` bo góc hoặc `FractionallySizedBox` + `AnimatedContainer`; FAB = `FloatingActionButton`; sheet = `showModalBottomSheet` (bo 30 góc trên).

### 4b. Dashboard — Kho giả (Decoy)
- Cùng cấu trúc 4a nhưng nội dung **vô hại**: header "Xin chào 👋 / Kho của tôi"; dung lượng "1,1 GB / 5 GB (22%)"; thư mục: Ảnh du lịch (84), Ảnh màn hình (42), Tài liệu công việc (19), Ghi chú (7) — **không có badge khóa**. Đây là màn hiện ra khi nhập PIN giả.

### 5. Cài đặt (Settings) — Dark
- **Header**: nút `‹` quay lại + "Cài đặt". Back về đúng nơi mở (kho thật hoặc kho giả).
- **CTA Premium**: card nền `#1B1810` viền `#423916`, icon vương miện vàng, "Vault Premium / Mở khóa toàn bộ tính năng cao cấp" → mở **paywall**.
- **BẢO MẬT** (card): Đổi mật khẩu thật (icon xanh lá) · Đổi mật khẩu giả (icon tím) · Mở khóa bằng vân tay (**switch toggle**, mặc định BẬT).
- **CHỐNG ĐỘT NHẬP** (card): dòng "Intruder Selfie" kèm **vương miện vàng 👑** (premium) + phụ đề "Chụp lén khi nhập sai mật khẩu 3 lần" + toggle; bên dưới **Nhật ký kẻ đột nhập** — hàng cuộn ngang các ảnh (placeholder có sọc) kèm chấm đỏ, giờ ("Hôm nay 09:24"), "Sai mã · 3 lần". Bật toggle khi chưa mua → mở paywall.
- **NGỤY TRANG** (card): "Đổi icon ngụy trang" + 3 lựa chọn icon app: **Máy tính** (đang chọn, có ✓ xanh), **Thời tiết** (👑), **La bàn** (👑). Chọn Weather/Compass → mở paywall.
- **Flutter**: các card = `Container` + `Column`; toggle = `Switch`/`CupertinoSwitch` custom màu; ảnh intruder = `ListView` ngang; vương miện = `Icon`/`CustomPaint` (clip-path polygon → dùng `ClipPath` hoặc asset SVG).

### 6. Paywall (IAP)
- Bottom sheet: crown 58×58 nền vàng; "Vault Premium"; 4 dòng tính năng có ✓ vàng; 2 gói giá — **1 Năm 99.000đ** (viền vàng, badge "TIẾT KIỆM 60%") và **Trọn đời 249.000đ**; nút vàng "Bắt đầu dùng thử 7 ngày"; link "Khôi phục mua hàng".
- **Flutter**: `showModalBottomSheet`; tích hợp `in_app_purchase` khi làm thật.

---

## Interactions & Behavior / State

State chính (một máy trạng thái màn hình):
`screen ∈ { calc, unlocking, pin, dashboard, fakedash, settings }`

Luồng đầy-đến-cuối:
1. **calc**: máy tính hoạt động. Có `theme` (light/dark).
2. Nhập mật mã bí mật rồi `=`:
   - `1984 =` → `unlocking` (mở kho thật)
   - Nhập PIN giả sẽ rẽ nhánh ở bước PIN (xem dưới).
3. **unlocking**: chạy animation quét vân tay, sau ~1.9s hiện ✓, sau ~2.65s → `pin`.
4. **pin**: nhập 4 số:
   - `2468` → `dashboard` (kho thật)
   - `1111` → `fakedash` (kho giả)
   - sai → rung + xóa.
5. **dashboard/fakedash**: xem thư mục; FAB mở sheet thêm tệp; ⚙ → `settings` (nhớ `settingsFrom` để back đúng chỗ).
6. **settings**: bật/tắt toggle; tính năng 👑 hoặc icon ngụy trang premium → mở **paywall**.
7. Nút **Khóa** ở bất kỳ đâu → reset toàn bộ về `calc`.

Các mật mã (đổi được trong app thật; giá trị demo):
- Mật mã bí mật mở app: `1984`
- PIN kho thật: `2468`
- PIN kho giả (decoy): `1111`

Cơ chế cốt lõi = **duress password**: PIN khác nhau ở bước 4 quyết định vào kho thật hay kho giả.

Biến state phụ: `dark`, `pin`, `pinError`, `fabOpen`, `paywallOpen`, `tglFinger`, `tglIntruder`, `disguise ∈ {calc,weather,compass}`, `settingsFrom`.

---

## Gợi ý kiến trúc Flutter
- Điều hướng màn: một `Stack` + `AnimatedSlide`/`AnimatedOpacity` theo `screen`, hoặc `Navigator`/`go_router` với custom `PageRouteBuilder` (slide+fade 500ms). Prototype dùng cách "tất cả màn cùng tồn tại, dịch chuyển transform" — trong Flutter nên tách route cho sạch.
- State: `Provider`/`Riverpod`/`Bloc` cho máy trạng thái + theme + toggles.
- Bảo mật thật (nếu triển khai): `local_auth` (vân tay/FaceID), `flutter_secure_storage` cho PIN, mã hóa file bằng AES; đổi icon app = `flutter_dynamic_icon` (iOS) / activity-alias (Android).
- Placeholder ảnh (sọc chéo) → thay bằng thumbnail thật; giữ bo góc 14 và overlay gradient để chữ dễ đọc.

## Assets
- Không có ảnh thật — dùng placeholder sọc (repeating gradient). Icon vẽ bằng CSS shapes (ổ khóa, vân tay, camera, vương miện, icon app Thời tiết/La bàn). Trong Flutter nên thay bằng bộ icon (Material Icons / SVG) hoặc `CustomPaint`.
- Emoji 👋 dùng ở header kho giả (tùy chọn giữ/bỏ).

## Files
- `Calculator.dc.html` — prototype đầy đủ (mở bằng trình duyệt để xem tương tác thật: gõ `1984 =` → `2468` để vào kho thật, hoặc `1984 =` → `1111` cho kho giả).

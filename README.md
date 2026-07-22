# Vault Cal — Flutter Base Project

Dự án base Flutter theo **Clean Architecture** (feature-first) với **Bloc/Cubit**.

## Tech stack

| Thành phần | Package |
|---|---|
| State management | `flutter_bloc` + `equatable` |
| Điều hướng | `go_router` |
| Dependency injection | `get_it` |
| Network | `dio` |
| Local storage | `shared_preferences` |
| Đa ngôn ngữ | `flutter_localizations` + gen-l10n (Việt / Anh) |
| Test | `bloc_test` + `mocktail` |

## Cấu trúc thư mục

```
lib/
├── main.dart                  # Entry point: init DI, BlocObserver, runApp
├── app/                       # Cấu hình cấp ứng dụng
│   ├── app.dart               # MaterialApp.router (theme + l10n + router)
│   ├── router/app_router.dart # Khai báo route (go_router)
│   └── theme/                 # Light/dark theme + ThemeCubit (persist)
├── core/                      # Dùng chung, KHÔNG phụ thuộc feature nào
│   ├── constants/             # Hằng số (baseUrl, timeout...)
│   ├── di/injection.dart      # Đăng ký dependency (get_it)
│   ├── error/                 # Exceptions (data layer) & Failures (domain)
│   ├── extensions/            # context.l10n, context.theme...
│   ├── network/dio_client.dart# Dio đã cấu hình sẵn + log interceptor
│   ├── storage/               # Wrapper SharedPreferences
│   ├── utils/                 # Result<T> (Ok/Err), BlocObserver
│   └── widgets/               # Widget dùng chung (loading, error view)
├── features/                  # Mỗi feature một thư mục, 3 tầng
│   ├── home/
│   │   └── presentation/pages/home_page.dart
│   └── posts/                 # Feature mẫu: gọi REST API đầy đủ 3 tầng
│       ├── domain/            # Entity + Repository interface (thuần Dart)
│       ├── data/              # Model + DataSource + Repository impl
│       └── presentation/      # Cubit (sealed states) + Page
└── l10n/                      # File dịch .arb (en/vi) + code sinh tự động
```

## Luồng dữ liệu (feature `posts`)

```
PostsPage → PostsCubit → PostRepository (interface)
                              ↓
                    PostRepositoryImpl → PostRemoteDataSource → Dio → API
                              ↓
              Result<T>: Ok(data) hoặc Err(Failure) → Cubit emit state
```

## Chạy dự án

```bash
flutter pub get        # cài dependency + sinh code l10n
flutter run            # chạy app
flutter test           # chạy unit test
flutter analyze        # kiểm tra lint
```

## Thêm feature mới

1. Tạo thư mục `lib/features/<ten_feature>/` với 3 tầng `domain/`, `data/`, `presentation/`.
2. Đăng ký dependency trong `lib/core/di/injection.dart`.
3. Thêm route trong `lib/app/router/app_router.dart`.
4. Thêm chuỗi dịch vào `lib/l10n/app_en.arb` và `app_vi.arb`, chạy lại `flutter pub get`.
5. Viết test cho Cubit trong `test/features/<ten_feature>/`.

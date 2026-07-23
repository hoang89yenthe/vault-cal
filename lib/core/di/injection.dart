import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/theme/theme_cubit.dart';
import '../../features/calculator/presentation/cubit/calculator_cubit.dart';
import '../../features/posts/data/datasources/post_remote_data_source.dart';
import '../../features/posts/data/repositories/post_repository_impl.dart';
import '../../features/posts/domain/repositories/post_repository.dart';
import '../../features/posts/presentation/cubit/posts_cubit.dart';
import '../../features/intruder/data/capturing_intruder_trigger.dart';
import '../../features/intruder/data/repositories/intruder_repository_impl.dart';
import '../../features/intruder/data/services/selfie_capture_service.dart';
import '../../features/intruder/domain/intruder_trigger.dart';
import '../../features/intruder/domain/repositories/intruder_repository.dart';
import '../../features/intruder/presentation/cubit/intruder_log_cubit.dart';
import '../../features/purchases/data/mock_purchase_service.dart';
import '../../features/purchases/domain/purchase_service.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../features/unlock/data/repositories/credentials_repository_impl.dart';
import '../../features/unlock/domain/repositories/credentials_repository.dart';
import '../../features/unlock/presentation/cubit/pin_cubit.dart';
import '../../features/vault/data/repositories/media_repository_impl.dart';
import '../../features/vault/data/repositories/notes_repository_impl.dart';
import '../../features/vault/data/repositories/vault_repository_impl.dart';
import '../../features/vault/domain/repositories/media_repository.dart';
import '../../features/vault/domain/repositories/notes_repository.dart';
import '../../features/vault/domain/repositories/vault_repository.dart';
import '../../features/vault/presentation/cubit/dashboard_cubit.dart';
import '../../features/vault/presentation/cubit/folder_cubit.dart';
import '../../features/vault/presentation/cubit/import_cubit.dart';
import '../../features/vault/presentation/cubit/notes_cubit.dart';
import '../network/dio_client.dart';
import '../security/biometric_service.dart';
import '../security/key_manager.dart';
import '../security/pin_hasher.dart';
import '../session/vault_session.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  getIt
    // Core
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<LocalStorage>(() => LocalStorage(getIt()))
    ..registerLazySingleton<Dio>(createDio)
    // Core: security
    ..registerLazySingleton<SecureStorage>(
      () => const SecureStorage(FlutterSecureStorage()),
    )
    ..registerLazySingleton<KeyManager>(() => KeyManager(getIt()))
    ..registerLazySingleton<PinHasher>(PinHasher.new)
    ..registerLazySingleton<BiometricService>(BiometricService.new)
    ..registerLazySingleton<VaultSession>(() => VaultSession(getIt()))
    // Feature: intruder
    ..registerLazySingleton<SelfieCaptureService>(SelfieCaptureService.new)
    ..registerLazySingleton<IntruderRepository>(
      () => IntruderRepositoryImpl(getIt(), getIt()),
    )
    ..registerLazySingleton<IntruderTrigger>(
      () => CapturingIntruderTrigger(getIt(), getIt(), getIt(), getIt()),
    )
    ..registerFactory<IntruderLogCubit>(() => IntruderLogCubit(getIt()))
    // App
    ..registerLazySingleton<ThemeCubit>(() => ThemeCubit(getIt()))
    // Feature: calculator + unlock
    ..registerLazySingleton<CredentialsRepository>(
      () => CredentialsRepositoryImpl(getIt(), getIt()),
    )
    ..registerFactory<CalculatorCubit>(() => CalculatorCubit(getIt()))
    ..registerFactory<PinCubit>(() => PinCubit(getIt(), getIt(), getIt()))
    // Feature: vault
    ..registerLazySingleton<MediaRepository>(
      () => MediaRepositoryImpl(getIt(), getIt()),
    )
    ..registerLazySingleton<VaultRepository>(
      () => VaultRepositoryImpl(getIt(), getIt()),
    )
    ..registerLazySingleton<NotesRepository>(() => NotesRepositoryImpl(getIt()))
    ..registerFactory<DashboardCubit>(() => DashboardCubit(getIt()))
    ..registerFactory<FolderCubit>(() => FolderCubit(getIt()))
    ..registerFactory<ImportCubit>(() => ImportCubit(getIt()))
    ..registerFactory<NotesCubit>(() => NotesCubit(getIt()))
    // Feature: purchases
    ..registerLazySingleton<PurchaseService>(() => MockPurchaseService(getIt()))
    // Feature: settings
    ..registerLazySingleton<SettingsCubit>(
      () => SettingsCubit(getIt(), getIt()),
    )
    // Feature: posts (base-project demo)
    ..registerLazySingleton<PostRemoteDataSource>(
      () => PostRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<PostRepository>(() => PostRepositoryImpl(getIt()))
    ..registerFactory<PostsCubit>(() => PostsCubit(getIt()));

  // Seed default credentials on first launch.
  await getIt<CredentialsRepository>().ensureSeeded();
}

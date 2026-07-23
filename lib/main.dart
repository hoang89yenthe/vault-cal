import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'core/di/injection.dart';
import 'core/session/credentials_gate.dart';
import 'core/utils/app_bloc_observer.dart';
import 'features/unlock/domain/repositories/credentials_repository.dart';
import 'features/vault/data/repositories/media_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();
  Bloc.observer = const AppBlocObserver();

  // Decide up front whether first-run onboarding is needed.
  credentialsInitialized.value = await getIt<CredentialsRepository>()
      .isInitialized();

  // Wipe any decrypted temp files left over from a previous session.
  await MediaRepositoryImpl.sweepDecryptCache();

  runApp(const App());
}

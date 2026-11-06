import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/injection_container.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/cubits/auth/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MonqizApp());
}

/// MONQIZ Application Root
class MonqizApp extends StatelessWidget {
  const MonqizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => sl<AuthCubit>()..checkAuthStatus(),
        ),
      ],
      child: MaterialApp.router(
        title: 'MONQIZ — منقذ',
        debugShowCheckedModeBanner: false,
        theme: MonqizTheme.lightTheme,
        locale: const Locale('ar'),
        supportedLocales: const [
          Locale('ar'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: AppRouter.router,
      ),
    );
  }
}

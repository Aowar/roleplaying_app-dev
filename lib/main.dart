import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/services/auth_service.dart';
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    log('$e', name: 'first error');
  }
  runApp(RpApp());
}

class RpApp extends StatelessWidget {
  RpApp({Key? key}) : super(key: key);

  final AuthService authService = AuthService();

  void _portraitModeOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    const lightPrimary = Color(0xffa2cbea);
    const darkPrimary = Color(0xff313030);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.bottom
    ]);
    _portraitModeOnly();
    return BlocProvider(create: (context) => AuthBloc(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Roleplaying app',
          home: AuthScreen(),
          darkTheme: ThemeData(
              scaffoldBackgroundColor: darkPrimary,
              backgroundColor: darkPrimary,
              primaryColor: Colors.black,
              canvasColor: Colors.white,
              cardTheme: const CardTheme(
                shadowColor: Colors.white,
              ),
              textTheme: const TextTheme(
                headline1: TextStyle(color: Colors.white, fontSize: 24),
                headline2: TextStyle(color: Colors.white, fontSize: 24),
                bodyText1: TextStyle(color: Colors.white, fontSize: 20),
                bodyText2: TextStyle(color: Color(0xD2FFFFFF), fontSize: 20),
                subtitle1: TextStyle(color: Color(0xff000000), fontSize: 18),
                subtitle2: TextStyle(color: Color(0xffffffff), fontSize: 14),
              ), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: const Color(0xff9e9e9e), brightness: Brightness.dark)
          ),
          theme: ThemeData(
              scaffoldBackgroundColor: lightPrimary,
              backgroundColor: lightPrimary,
              primaryColor: const Color(0xFF2F69FF),
              textTheme: const TextTheme(
                headline1: TextStyle(color: Colors.white, fontSize: 24),
                headline2: TextStyle(color: Colors.black, fontSize: 24),
                bodyText1: TextStyle(color: Colors.black, fontSize: 20),
                bodyText2: TextStyle(color: Colors.white, fontSize: 20),
                subtitle1: TextStyle(color: Color(0xff000000), fontSize: 18),
                subtitle2: TextStyle(color: Color(0xff000000), fontSize: 14),
              ), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: const Color(0xffc2c2c2), brightness: Brightness.light)
          ),
        )
    );
  }
}
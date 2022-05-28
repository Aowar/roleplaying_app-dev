import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/services/auth_service.dart';
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  runApp(const RpApp());
}

class RpApp extends StatefulWidget {
  const RpApp({Key? key}) : super(key: key);

  static _RpAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_RpAppState>();

  @override
  State<RpApp> createState() => _RpAppState();
}

class _RpAppState extends State<RpApp> {
  ThemeMode _themeMode = ThemeMode.light;
  final AuthService authService = AuthService();
  late SharedPreferences _prefs;
  bool isNightTheme = false;

  void changeTheme(ThemeMode themeMode) {
    log(themeMode.toString(), name: "themeMode");
    _themeMode = themeMode;
    setState(() {
    });
  }

  getPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  getDataFromPrefs() async {
    await getPrefs();
    if (_prefs.containsKey("isNightTheme")) {
      isNightTheme = _prefs.getBool("isNightTheme")!;
      isNightTheme ? _themeMode = ThemeMode.dark : _themeMode = ThemeMode.light;

    }
  }

  void _portraitModeOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    getDataFromPrefs();
    const lightPrimary = Color(0xffa2cbea);
    const darkPrimary = Color(0xff313030);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.bottom
    ]);
    _portraitModeOnly();
    return BlocProvider(create: (context) => AuthBloc(),
        child: MaterialApp(
          themeMode: _themeMode,
          debugShowCheckedModeBanner: false,
          title: 'Roleplaying app',
          home: GestureDetector(child: AuthScreen(), onTap: () => FocusScope.of(context).unfocus()),
          darkTheme: ThemeData(
              scaffoldBackgroundColor: darkPrimary,
              backgroundColor: darkPrimary,
              primaryColor: Colors.black,
              canvasColor: Colors.white,
              cardColor: const Color(0xffc1c1c1),
              cardTheme: const CardTheme(
                shadowColor: Colors.white,
              ),
              textTheme: const TextTheme(
                headline1: TextStyle(color: Colors.white, fontSize: 24, overflow: TextOverflow.fade),
                headline2: TextStyle(color: Colors.white, fontSize: 24, overflow: TextOverflow.fade),
                bodyText1: TextStyle(color: Colors.black, fontSize: 20, overflow: TextOverflow.fade),
                bodyText2: TextStyle(color: Color(0xD2FFFFFF), fontSize: 20, overflow: TextOverflow.fade),
                subtitle1: TextStyle(color: Color(0xff000000), fontSize: 14, overflow: TextOverflow.fade),
                subtitle2: TextStyle(color: Color(0xffffffff), fontSize: 14, overflow: TextOverflow.fade),
              ),
              colorScheme: ColorScheme.fromSwatch().copyWith(
                  secondary: const Color(0xff9e9e9e),
                  brightness: Brightness.dark,
                  primaryContainer: const Color(0xffdbdbdb),
                  errorContainer: const Color(0xff6d0000)
              )
          ),
          theme: ThemeData(
              scaffoldBackgroundColor: lightPrimary,
              backgroundColor: lightPrimary,
              primaryColor: const Color(0xFF2F69FF),
              cardColor: Colors.white,
              textTheme: const TextTheme(
                headline1: TextStyle(color: Colors.white, fontSize: 24, overflow: TextOverflow.fade),
                headline2: TextStyle(color: Colors.black, fontSize: 24, overflow: TextOverflow.fade),
                bodyText1: TextStyle(color: Colors.black, fontSize: 20, overflow: TextOverflow.fade),
                bodyText2: TextStyle(color: Colors.white, fontSize: 20, overflow: TextOverflow.fade),
                subtitle1: TextStyle(color: Color(0xff000000), fontSize: 14, overflow: TextOverflow.fade),
                subtitle2: TextStyle(color: Color(0xff000000), fontSize: 14, overflow: TextOverflow.fade),
              ),
              colorScheme: ColorScheme.fromSwatch().copyWith(
                  secondary: const Color(0xffc2c2c2),
                  brightness: Brightness.light,
                  primaryContainer: const Color(0xFF2F69FF),
                  errorContainer: const Color(0xffff0000)
              )
          ),
        )
    );
  }
}

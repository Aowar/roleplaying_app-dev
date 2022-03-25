import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter/services.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/user.dart';
import 'package:roleplaying_app/src/services/auth_service.dart';
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/chat_description_screen.dart';
import 'package:roleplaying_app/src/ui/chat_screen.dart';
import 'package:roleplaying_app/src/ui/form_screen.dart';
import 'package:roleplaying_app/src/ui/landing.dart';
import 'package:roleplaying_app/src/ui/menu_screen.dart';
import 'package:roleplaying_app/src/ui/profile_screen.dart';
import 'firebase_options.dart';

final appRoutes = <String, WidgetBuilder>{
  '/start_screen': (BuildContext context) => Landing(),
  '/auth_screen': (BuildContext context) => AuthScreen(),
  '/menu_screen': (BuildContext context) => MenuScreen(),
  '/profile_screen' : (BuildContext context) => ProfileScreen(),
  '/chat_screen' : (BuildContext context) => ChatScreen(),
  '/form_screen' : (BuildContext context) => FormScreen(),
  '/chat_edit_screen' : (BuildContext context) => ChatEditScreen(),
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {}
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const lightPrimary = Color(0xffa2cbea);
    const darkPrimary = Color(0xff313030);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.bottom
    ]);
    _portraitModeOnly();
    return NeumorphicApp(
      debugShowCheckedModeBanner: false,
      title: 'Roleplaying app',
      home: BlocProvider(create: (context) => AuthBloc(), child: const Landing()),
      routes: appRoutes,
      theme: const NeumorphicThemeData(
        baseColor: lightPrimary,
        variantColor: Color(0xFFFFFFFF),
        shadowLightColor: Colors.white,
        shadowDarkColor: Color(0xFF424242),
        lightSource: LightSource.top,
      ),
      darkTheme: const NeumorphicThemeData(
        baseColor: darkPrimary,
        accentColor: Color(0xffa0a0a0),
        variantColor: Color(0xffffffff),
        shadowDarkColor: Color(0xFF000000),
        shadowLightColor: Color(0xFF424242),
        defaultTextColor: Colors.white
      ),
      materialTheme: ThemeData(
        scaffoldBackgroundColor: lightPrimary,
        backgroundColor: lightPrimary,
        primaryColor: const Color(0xFF2F69FF),
        accentColor: const Color(0xffc2c2c2),
        textTheme: const TextTheme(
            headline1: TextStyle(color: Colors.white, fontSize: 24),
            headline2: TextStyle(color: Colors.black, fontSize: 24),
            bodyText1: TextStyle(color: Colors.black, fontSize: 20),
            bodyText2: TextStyle(color: Colors.white, fontSize: 20),
            subtitle1: TextStyle(color: Color(0xff000000), fontSize: 18),
            subtitle2: TextStyle(color: Color(0xff525252), fontSize: 14),
        )
      ),
      materialDarkTheme: ThemeData(
        scaffoldBackgroundColor: darkPrimary,
        backgroundColor: darkPrimary,
        primaryColor: Colors.black,
        accentColor: const Color(0xff9e9e9e),
        canvasColor: Colors.white,
        brightness: Brightness.dark,
        cardTheme: const CardTheme(
          shadowColor: Colors.white,
        ),
          textTheme: const TextTheme(
            headline1: TextStyle(color: Colors.white, fontSize: 24),
            headline2: TextStyle(color: Colors.white, fontSize: 24),
            bodyText1: TextStyle(color: Colors.white, fontSize: 20),
            bodyText2: TextStyle(color: Color(0x7E000000), fontSize: 20),
            subtitle1: TextStyle(color: Color(0xff000000), fontSize: 18),
            subtitle2: TextStyle(color: Color(0xffe3e3e3), fontSize: 14),
          )
      ),
    );
  }
}
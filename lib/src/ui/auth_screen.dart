import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/services/auth_service.dart';
import 'package:roleplaying_app/src/services/customUserService.dart';

import 'dart:developer' as developer;

import '../models/user.dart';
import 'landing.dart';

class AuthScreen extends StatelessWidget {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return AuthView();
  }
}

class AuthView extends StatefulWidget {
  AuthView({Key? key}) : super(key: key);

  @override
  State<AuthView> createState() => _AuthView();
}

class _AuthView extends State<AuthView> {
  final GlobalKey<FormState> _formLoginKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formRegisterKey = GlobalKey<FormState>();
  final TextEditingController _passwordLoginController = TextEditingController();
  final TextEditingController _emailLoginController = TextEditingController();
  final TextEditingController _emailRegisterController = TextEditingController();
  final TextEditingController _userNicknameController = TextEditingController();
  final TextEditingController _passwordRegisterController = TextEditingController();
  late bool isOpen = false;
  late OverlayEntry _overlayEntry;

  final AuthService _authService = AuthService();
  late String _email;
  late String _nickName;
  late String _password;

  void openRegisterForm() {
    isOpen = true;
    _overlayEntry = _createRegisterOverlay();
    Overlay.of(context)!.insert(_overlayEntry);
  }

  void closeRegisterForm() {
    isOpen = false;
    _overlayEntry.remove();
  }

  OverlayEntry _createRegisterOverlay() {
    return OverlayEntry(builder: (context) {
      return GestureDetector(
        onTap: closeRegisterForm,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Container(
              color: const Color(0x41000000),
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 1.8,
                  child: GestureDetector(
                      onTap: () { },
                      child: Container(
                        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).accentColor,
                        ),
                          ///Register form
                        child: Center(
                          child: Form(
                            key: _formRegisterKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ///Login field
                                Material(
                                    child: generateFormEmailField(const Icon(Icons.login), "Введите email", _emailRegisterController, false),
                                    color: Theme.of(context).accentColor
                                ),
                                ///User nickname field
                                Material(
                                  child: generateFormTextField(const Icon(Icons.password), "Введите желаемый никнейм", _userNicknameController, true, "Пожалуйста введите никнейм"),
                                  color: Theme.of(context).accentColor,
                                ),
                                ///Password field
                                Material(
                                  child: generateFormPasswordField(const Icon(Icons.password), "Введите пароль", _passwordRegisterController, true),
                                  color: Theme.of(context).accentColor,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.5,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20.0),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Theme.of(context).primaryColor.withOpacity(0.2),
                                              spreadRadius: 5,
                                              offset: const Offset(0, 3),
                                              blurRadius: 10
                                          )
                                        ]
                                    ),
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20.0)
                                              )
                                          )
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text("Зарегистрироваться", style: Theme.of(context).textTheme.bodyText1),
                                        ),
                                      ),
                                      onPressed: () {
                                        if (_formRegisterKey.currentState!.validate()) {
                                          register();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      )
                  ),
                ),
              )
          ),
        ),
      );
    });
  }

  Widget generateFormTextField(Icon icon, String hintText, TextEditingController controller, bool obscureText, String failedValidatorText) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).cardColor.withOpacity(0.2),
                        spreadRadius: 5,
                        offset: const Offset(5, 5),
                        blurRadius: 10
                    )
                  ]
              ),
        child: TextFormField(
          decoration: InputDecoration(
            border: InputBorder.none,
            icon: icon,
            hintText: hintText,
          ),
          obscureText: obscureText,
          controller: controller,
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return failedValidatorText;
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget generateFormEmailField(Icon icon, String hintText, TextEditingController controller, bool obscureText) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(10.0),
            ),
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).cardColor.withOpacity(0.2),
                  spreadRadius: 5,
                  offset: const Offset(5, 5),
                  blurRadius: 10
              )
            ]
        ),
        child: TextFormField(
          decoration: InputDecoration(
            border: InputBorder.none,
            icon: icon,
            hintText: hintText,
          ),
          obscureText: obscureText,
          controller: controller,
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return "Пожалуйста введите email";
            } else if (value.contains(RegExp(r'\w+@\w+\.\w+'))) {
              return null;
            }
            return "Неправильный адрес электронной почты";
          },
        ),
      ),
    );
  }

  Widget generateFormPasswordField(Icon icon, String hintText, TextEditingController controller, bool obscureText) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(10.0),
            ),
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).cardColor.withOpacity(0.2),
                  spreadRadius: 5,
                  offset: const Offset(5, 5),
                  blurRadius: 10
              )
            ]
        ),
        child: TextFormField(
          decoration: InputDecoration(
            border: InputBorder.none,
            icon: icon,
            hintText: hintText,
          ),
          obscureText: obscureText,
          controller: controller,
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return "Пожалуйста введите пароль";
            } else if (value.length < 6) {
              return "Пароль должен быть больше 6 символов";
            } else if (!value.contains(RegExp(r'[A-Z]'))) {
              return "Пароль должен содержать хотя бы одну латинскую заглавную букву";
            } else if (!value.contains(RegExp(r'[a-z]'))) {
              return "Пароль должен содержать хотя бы одну латинскую строчную букву";
            } else if (!value.contains(RegExp(r'[0-9]'))) {
              return "Пароль должен содержать хотя бы одну цифру";
            } else if (!value.contains(RegExp(r'[!-|]'))) {
              return "Пароль должен содержать хотя бы один спецсимвол";
            } else if (value.contains(RegExp(r'[ ]'))) {
              return "Пароль должен содержать хотя бы";
            }
            if (value.contains(RegExp(r'[A-Za-z]\w+'))) {
              return null;
            }
            return "Пароль содержит недопустимый символ (Проверьте раскладку)";
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      return Scaffold(
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
              child: Container(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5, top: 5),
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.height / 16,
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                                        spreadRadius: 2,
                                        offset: const Offset(5, 5),
                                        blurRadius: 10
                                    )
                                  ]
                              ),
                              child: Center(
                                child: Text("Ролевые игры", style: Theme.of(context).textTheme.headline1),
                              ))),
                    ),
                    ///Auth form
                    Center(
                        child: Form(
                          key: _formLoginKey,
                          child: Padding(
                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.4),
                            child: Column(
                              children: [
                                ///Login field
                                generateFormEmailField(const Icon(Icons.login), "Введите email", _emailLoginController, false),
                                Padding(
                                    padding: const EdgeInsets.only(top: 30),
                                    ///Password field
                                      child: generateFormPasswordField(const Icon(Icons.password), "Введите пароль", _passwordLoginController, true)
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  ///Login button
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.5,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20.0),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Theme.of(context).primaryColor.withOpacity(0.2),
                                                spreadRadius: 5,
                                                offset: const Offset(0, 3),
                                                blurRadius: 10
                                            )
                                          ]
                                      ),
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20.0)
                                                )
                                            )
                                        ),
                                        onPressed: () {
                                          if (_formLoginKey.currentState!.validate()) {
                                            auth(authBloc);
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Text("Войти", style: Theme.of(context).textTheme.bodyText1),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: TextButton(
                                      onPressed: () {
                                        openRegisterForm();
                                      },
                                      child: Text("Ещё не зарегистрированы? Создать аккаунт",
                                          style: Theme.of(context).textTheme.subtitle2
                                      )
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                    ),
                    BlocListener<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthStateAuthenticated) {
                          Navigator.pushNamed(context, '/menu_screen');
                        }
                      },
                      child: Container(),
                    )
                  ],
                )
              )
            ),
          )
      );
    });
  }

  auth(authBloc) async {
    _email = _emailLoginController.text;
    _password = _passwordLoginController.text;
    if ((await _authService.signIn(_email.trim(), _password.trim())) == null) {
      return Fluttertoast.showToast(
          msg: "Неверный логин или пароль",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          webBgColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } else {
      UserModel user = await _authService.signIn(_email.trim(), _password.trim());
      if (user.id.isNotEmpty && FirebaseAuth.instance.currentUser!.emailVerified) {
        authBloc.add(UserLoggedIn(user: user));
      } else {
        return Fluttertoast.showToast(
            msg: "Ошибка авторизации",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }
  }

  register() async {
    _email = _emailRegisterController.text;
    _nickName = _userNicknameController.text;
    _password = _passwordRegisterController.text;
    final auth = FirebaseAuth.instance;
    User user;
    auth.createUserWithEmailAndPassword(email: _email, password: _password).then((_) {
      user = auth.currentUser!;
      user.sendEmailVerification();
      user.updateDisplayName(_nickName);
    });
    return Fluttertoast.showToast(
        msg: "Письмо отправлено на указанный адрес",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        backgroundColor: Theme.of(context).accentColor,
        webBgColor: Theme.of(context).accentColor,
        textColor: Theme.of(context).textTheme.bodyText1!.color,
        fontSize: 16.0
    );
  }
}

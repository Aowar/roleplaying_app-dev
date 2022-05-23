import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/customUserModel.dart';
import 'package:roleplaying_app/src/services/auth_service.dart';
import 'package:roleplaying_app/src/services/customUserService.dart';
import 'package:roleplaying_app/src/ui/menu_screen.dart';

import 'dart:developer' as developer;

import '../models/user.dart';

enum AuthProblems { userExists, networkError, invalidEmail, invalidPassword,  userDisabled, userNotFound, unknownProblem }

class AuthScreen extends StatelessWidget {
  final AuthService authService = AuthService();

  AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AuthView();
  }
}

class AuthView extends StatefulWidget {
  const AuthView({Key? key}) : super(key: key);

  @override
  State<AuthView> createState() => _AuthView();
}

class _AuthView extends State<AuthView> {
  final GlobalKey<FormState> _formLoginKey = GlobalKey<FormState>();
  final TextEditingController _passwordLoginController = TextEditingController();
  final TextEditingController _emailLoginController = TextEditingController();
  final GlobalKey<FormState> _formRegisterKey = GlobalKey<FormState>();
  final TextEditingController _emailRegisterController = TextEditingController();
  final TextEditingController _userNicknameController = TextEditingController();
  final TextEditingController _passwordRegisterController = TextEditingController();
  bool isOpen = false;
  late OverlayEntry _overlayEntry;
  bool isLoading = false;
  final AuthService _authService = AuthService();
  late String _email;
  late String _nickName;
  late String _password;
  Map<AuthProblems, String> registerErrorsMessages = {
    AuthProblems.userExists: "Данный email уже используется",
    AuthProblems.networkError: "Произошла ошибка, повторите попытку позже",
    AuthProblems.invalidEmail: "Неверная почта или пароль",
    AuthProblems.invalidPassword: "Неверная почта или пароль",
    AuthProblems.userDisabled: "Аккаунт пользователя деактивирован",
    AuthProblems.userNotFound: "Пользователя с таким email не существует",
    AuthProblems.unknownProblem: "Произошла неизвестная ошибка"
  };

  void openRegisterForm() {
    isOpen = true;
    _overlayEntry = _createRegisterOverlay();
    Overlay.of(context)!.insert(_overlayEntry);
  }

  void closeRegisterForm() {
    isOpen = false;
    _overlayEntry.remove();
  }

  auth(authBloc) async {
    AuthProblems? errorType;
    _email = _emailLoginController.text;
    _password = _passwordLoginController.text;
    dynamic signInResult;
    signInResult = await _authService.signIn(_email.trim(), _password.trim());
    if (signInResult.runtimeType == UserModel) {
      if (!FirebaseAuth.instance.currentUser!.emailVerified) {
        return Fluttertoast.showToast(
            msg: "Подтвердите адрес электронной почты",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 4,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
      if (!await CustomUserService().collectionContainsUser(signInResult.id)) {
        CustomUserModel _customUserModel = CustomUserModel(signInResult.id, signInResult.nickName, "default_user_icon.png");
        CustomUserService().addCustomUser(_customUserModel);
      }
      authBloc.add(UserLoggedIn(user: signInResult));
    } else if (signInResult.runtimeType == FirebaseAuthException) {
      setState(() {
        isLoading = false;
      });
      switch (signInResult.code) {
        case "internal-error":
          errorType = AuthProblems.networkError;
          break;
        case "invalid-auth-event":
          errorType = AuthProblems.networkError;
          break;
        case "network-request-failed":
          errorType = AuthProblems.networkError;
          break;
        case "user-not-found":
          errorType = AuthProblems.userNotFound;
          break;
        case "wrong-password":
          errorType = AuthProblems.invalidPassword;
          break;
        case "invalid-email" :
          errorType = AuthProblems.invalidEmail;
          break;
        default:
          errorType = AuthProblems.unknownProblem;
          break;
      }
      return Fluttertoast.showToast(
          msg: registerErrorsMessages[errorType]!,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  registration() async {
    AuthProblems? errorType;
    _email = _emailRegisterController.text;
    _nickName = _userNicknameController.text;
    _password = _passwordRegisterController.text;
    dynamic registrationResult;

    registrationResult = await _authService.registration(_email, _password, _nickName);
    if (registrationResult.runtimeType == FirebaseAuthException) {
      switch (registrationResult.code) {
        case "email-already-in-use":
          errorType = AuthProblems.userExists;
          break;
        case "internal-error":
          errorType = AuthProblems.networkError;
          break;
        case "invalid-auth-event":
          errorType = AuthProblems.networkError;
          break;
        case "network-request-failed":
          errorType = AuthProblems.networkError;
          break;
        default:
          errorType = AuthProblems.unknownProblem;
          break;
      }
      return Fluttertoast.showToast(
          msg: registerErrorsMessages[errorType]!,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    return Fluttertoast.showToast(
        msg: "Письмо отправлено на указанный адрес",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
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
                  width: MediaQuery.of(context).size.width / 1.3,
                  child: GestureDetector(
                      onTap: () { },
                      child: Container(
                        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).colorScheme.secondary,
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
                                    child: EmailFormField(icon: const Icon(Icons.login), hintText: "Введите email", controller: _emailRegisterController),
                                    color: Theme.of(context).colorScheme.secondary
                                ),
                                ///User nickname field
                                Material(
                                  child: NicknameFormField(icon: const Icon(Icons.text_fields_outlined), hintText: "Введите никнейм", controller: _userNicknameController),
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                ///Password field
                                Material(
                                  child: PasswordFormField(icon: const Icon(Icons.password), hintText: "Введите пароль", controller: _passwordRegisterController, registerFlag: true),
                                  color: Theme.of(context).colorScheme.secondary,
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
                                          child: Text("Зарегистрироваться",
                                              style: TextStyle(
                                                  fontStyle: Theme.of(context).textTheme.bodyText1!.fontStyle,
                                                  color: Theme.of(context).textTheme.bodyText1!.color,
                                                  fontSize: 12
                                              )
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        if (_formRegisterKey.currentState!.validate()) {
                                          registration();
                                        }
                                      }
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

  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      return Scaffold(
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
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
                              EmailFormField(icon: const Icon(Icons.login), hintText: "Введите email", controller: _emailLoginController),
                              Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  ///Password field
                                    child: PasswordFormField(icon: const Icon(Icons.password), hintText: "Введите пароль", controller: _passwordLoginController, registerFlag: false)
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
                                      onPressed: isLoading ? null : () {
                                        setState(() {
                                          isLoading = true;
                                          auth(authBloc);
                                        });
                                      },
                                      child: isLoading ? const CircularProgressIndicator() : Padding(
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
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MenuScreen()));
                      }
                    },
                    child: Container(),
                  )
                ],
              )
            ),
          )
      );
    });
  }
}

class NicknameFormField extends StatelessWidget {
  final Icon icon;
  final String hintText;
  final TextEditingController controller;

  const NicknameFormField({Key? key, required this.icon, required this.hintText, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.5,
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
            errorStyle: const TextStyle(
                fontSize: 10
            ),
            border: InputBorder.none,
            icon: icon,
            hintText: hintText,
          ),
          obscureText: false,
          controller: controller,
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return "Пожалуйста введите никнейм";
            }
            return null;
          },
        ),
      ),
    );
  }
}


class PasswordFormField extends StatelessWidget {
  final Icon icon;
  final TextEditingController controller;
  final String hintText;
  final bool registerFlag;

  const PasswordFormField({Key? key, required this.icon, required this.controller, required this.hintText, required this.registerFlag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.5,
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
            errorStyle: const TextStyle(
                fontSize: 10
            ),
            border: InputBorder.none,
            icon: icon,
            hintText: hintText,
          ),
          obscureText: true,
          controller: controller,
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return "Пожалуйста введите пароль";
            } else if (registerFlag) {
            if (value.length < 6) {
              return "Пароль должен быть больше 6 символов";
            } else if (!value.contains(RegExp(r'[A-Z]'))) {
              return "Пароль должен содержать \nхотя бы одну латинскую заглавную букву";
            } else if (!value.contains(RegExp(r'[a-z]'))) {
              return "Пароль должен содержать \nхотя бы одну латинскую строчную букву";
            } else if (!value.contains(RegExp(r'[0-9]'))) {
              return "Пароль должен содержать \nхотя бы одну цифру";
            } else if (!value.contains(RegExp(r'[!-|]'))) {
              return "Пароль должен содержать \nхотя бы один спецсимвол";
            } else if (value.contains(RegExp(r'[ ]'))) {
              return "Пароль не должен содержать пробелов";
            }
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
}

class EmailFormField extends StatelessWidget {
  final Icon icon;
  final String hintText;
  final TextEditingController controller;
  const EmailFormField({Key? key, required this.icon, required this.hintText, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.5,
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
            errorStyle: const TextStyle(
              fontSize: 10
            ),
            border: InputBorder.none,
            icon: icon,
            hintText: hintText,
          ),
          obscureText: false,
          controller: controller,
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return "Пожалуйста введите email";
            } else if (value.contains(RegExp(r'\w+@\w+\.\w+'))) {
              return null;
            }
            return "Неправильный email";
          },
        ),
      ),
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/services/auth_service.dart';

import 'dart:developer' as developer;

import '../models/user.dart';
import 'landing.dart';

class RegisterScreen extends StatelessWidget {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return RegisterView();
  }
}

class RegisterView extends StatefulWidget {
  RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterView();
}

class _RegisterView extends State<RegisterView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _passwordController;
  late TextEditingController _emailController;

  AuthService _authService = AuthService();
  late String _email;
  late String _password;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _emailController = TextEditingController();
  }

  ///Creating login fields func
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

  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      return Scaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(
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
                    key: _formKey,
                    child: Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.4),
                      child: Column(
                        children: [
                          ///Login field
                          generateFormTextField(const Icon(Icons.login), "Введите email", _emailController, false, 'Пожалуйста введите email'),
                          Padding(
                              padding: const EdgeInsets.only(top: 30),
                              ///Password field
                              child: generateFormTextField(const Icon(Icons.password), "Введите пароль", _passwordController, true, "Пожалуйста введите пароль")
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            ///Login button
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: GestureDetector(
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(20.0),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                                            spreadRadius: 15,
                                            offset: const Offset(5, 5),
                                            blurRadius: 10
                                        )
                                      ]
                                  ),
                                  child: Center(
                                    child: Text("Войти", style: Theme.of(context).textTheme.bodyText1),
                                  ),
                                ),
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    auth(authBloc);
                                  }
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: TextButton(
                                onPressed: () {
                                  // return Overlay.of(context)!.insert(
                                  //   OverlayEntry(builder: (context) {
                                  //     return Stack(
                                  //       children: [
                                  //         Positioned(
                                  //             top: 100,
                                  //             left: 100,
                                  //             child: SizedBox(
                                  //               width: 200,
                                  //               height: 200,
                                  //               child: Container(
                                  //                 color: Colors.red,
                                  //               ),
                                  //             )
                                  //         )
                                  //       ],
                                  //     );
                                  //   })
                                  // );
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
          ));
    });
  }

  auth(authBloc) async {
    _email = _emailController.text;
    _password = _passwordController.text;

    UserModel user = await _authService.signIn(_email.trim(), _password.trim());
    if (user.id.isNotEmpty) {
      authBloc.add(UserLoggedIn(user: user));
    }
    if (user.isEmpty) {
      Fluttertoast.showToast(
          msg: "Ошибка авторизации",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {}
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/services/auth_service.dart';

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
      child: Neumorphic(
        style: NeumorphicStyle(
            shape: NeumorphicShape.convex,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
            depth: 5.0,
            color: Theme.of(context).cardColor),
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
                    child: Neumorphic(
                        style: NeumorphicStyle(
                            shape: NeumorphicShape.flat,
                            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                            depth: 2.0,
                            color: Theme.of(context).primaryColor),
                        child: Center(
                          child: Text("?????????????? ????????", style: Theme.of(context).textTheme.headline1),
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
                          generateFormTextField(const Icon(Icons.login), "?????????????? email", _emailController, false, '???????????????????? ?????????????? email'),
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            ///Password field
                            child: generateFormTextField(const Icon(Icons.password), "?????????????? ????????????", _passwordController, true, "???????????????????? ?????????????? ????????????")
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            ///Login button
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: NeumorphicButton(
                                style: NeumorphicStyle(
                                    shape: NeumorphicShape.flat,
                                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                                    depth: 15.0,
                                    color: Theme.of(context).primaryColor),
                                child: Center(
                                  child: Text("??????????", style: Theme.of(context).textTheme.bodyText1),
                                ),
                                onPressed: () {
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
                                  setState(() {
                                    Stack(
                                      children: [
                                        Positioned(
                                          top: 100,
                                          left: 100,
                                          child: SizedBox(
                                            width: 200,
                                            height: 200,
                                            child: Container(
                                              color: Colors.red,
                                            ),
                                          )
                                        )
                                      ],
                                    );
                                  });
                                },
                                child: Text("?????? ???? ????????????????????????????????? ?????????????? ??????????????",
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
                  if (state is AuthStateAuthetificated) {
                    developer.log(context.read<AuthBloc>().state.getUser().toString(), name: "Current user");
                    developer.log(context.read<AuthBloc>().state.toString(), name: "Current state");
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
          msg: "???????????? ??????????????????????",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {}
  }
}

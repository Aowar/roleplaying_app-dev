import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PushButton extends StatelessWidget {
  final IconData icon;
  final void Function() onPressed;
  final bool? isLoading;

  const PushButton({Key? key, required this.icon, required this.onPressed, this.isLoading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
          shape: MaterialStateProperty.all(const CircleBorder()),
          padding: MaterialStateProperty.all(const EdgeInsets.all(8)),
        ),
        onPressed: onPressed,
        child: Icon(icon,
          color: Colors.white,
          size: sqrt(MediaQuery.of(context).size.height + MediaQuery.of(context).size.width),
        )
    );
  }
}

class CustomCircleIconButton extends StatelessWidget {
  final void Function()? onPressed;
  final Future<String> future;
  final double borderWidth;
  final double scale;
  late Color? borderColor;

  CustomCircleIconButton({Key? key, required this.onPressed, required this.scale, required this.borderWidth, required this.future, this.borderColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    borderColor ??= Theme.of(context).colorScheme.primaryContainer;
    return IconButton(
          iconSize: sqrt(MediaQuery.of(context).size.height+MediaQuery.of(context).size.width) * scale,
          icon: FutureBuilder<String>(
              future: future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  ErrorCatcher(snapshot: snapshot);
                  return const Icon(Icons.error_outline_sharp);
                } else {
                  return Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(width: borderWidth, color: borderColor!),
                        image: DecorationImage(
                          fit: BoxFit.fitHeight,
                          alignment: FractionalOffset.topCenter,
                          image: NetworkImage(snapshot.data!),
                        )
                    ),
                  );
                }
              }
          ),
          color: Colors.white,
          onPressed: onPressed
    );
  }
}

class CustomCircleIcon extends StatelessWidget {
  final Future<String> future;
  final double borderWidth;
  final double scale;

  const CustomCircleIcon({Key? key, required this.scale, required this.borderWidth, required this.future}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
        dimension: sqrt(MediaQuery.of(context).size.height+MediaQuery.of(context).size.width) * scale,
        child: FutureBuilder<String>(
            future: future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                ErrorCatcher(snapshot: snapshot);
                return const Icon(Icons.error_outline_sharp);
              } else {
                return Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(width: borderWidth, color: Theme.of(context).colorScheme.primaryContainer),
                      image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        alignment: FractionalOffset.topCenter,
                        image: NetworkImage(snapshot.data!)
                      )
                  ),
                );
              }
            }
        ),
    );
  }
}

class CustomSquareIconButton extends StatelessWidget {
  final void Function() onPressed;
  final Future<String> future;
  final double scale;

  const CustomSquareIconButton({Key? key, required this.future, required this.onPressed, required this.scale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        iconSize: sqrt(MediaQuery.of(context).size.height+MediaQuery.of(context).size.width) * scale,
        icon: FutureBuilder<String>(
            future: future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Icon(Icons.account_circle_sharp);
              } else if (snapshot.data == "error") {
                return Icon(Icons.account_circle_sharp, color: Theme.of(context).colorScheme.secondaryContainer);
              } else {
                return Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        alignment: FractionalOffset.topCenter,
                        image: NetworkImage(snapshot.data!),
                      )
                  ),
                );
              }
            }
        ),
        color: Colors.white,
        onPressed: onPressed
    );
  }
}

class BackButton extends StatelessWidget {
  const BackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
        shape: MaterialStateProperty.all(const CircleBorder()),
        padding: MaterialStateProperty.all(const EdgeInsets.all(8)),
      ),
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.arrow_back_ios_rounded,
          color: Colors.white,
          size: sqrt(MediaQuery.of(context).size.height + MediaQuery.of(context).size.width),
        ),
    );
  }
}

class ImageContainer extends StatelessWidget {
  final int imageScale;

  const ImageContainer({Key? key, required this.imageScale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: const BorderRadius.all(
              Radius.circular(5.0),
            ),
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
                  spreadRadius: 5,
                  offset: const Offset(5, 5),
                  blurRadius: 10
              )
            ]
        ),
        child: Icon(Icons.image_outlined,
          size: sqrt((MediaQuery.of(context).size.height + MediaQuery.of(context).size.width)*imageScale),
        ),
      ),
    );
  }
}

class ErrorCatcher extends StatelessWidget {
  final AsyncSnapshot snapshot;
  bool? showErrorTextWidget = false;

  ErrorCatcher({Key? key, required this.snapshot, this.showErrorTextWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Fluttertoast.showToast(
        msg: "Ошибка получения данных " + snapshot.error.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    return showErrorTextWidget! ? Text("Ошибка загрузки данных " + snapshot.error.toString(), style: Theme.of(context).textTheme.subtitle2) :
        Container();
  }
}

class Toasts {
  static showErrorMessage({required String errorMessage, int duration = 5, Color color = Colors.red}) {
    Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: duration,
        backgroundColor: color.withOpacity(0.8),
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static showInfo({required BuildContext context, required String infoMessage, int duration = 3, bool isSuccess = false}) {
    Fluttertoast.showToast(
        msg: infoMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: duration,
        backgroundColor: isSuccess ? Colors.green.withOpacity(0.7) : Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.7),
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
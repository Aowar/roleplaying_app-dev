import 'dart:math';

import 'package:flutter/material.dart';

class PushButton extends StatelessWidget {
  final IconData icon;
  final void Function() onPressed;
  final bool? isLoading;

  const PushButton({Key? key, required this.icon, required this.onPressed, this.isLoading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                spreadRadius: 5,
                offset: const Offset(5, 5),
                blurRadius: 10
            )
          ]
      ),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.white,
        iconSize: sqrt(MediaQuery.of(context).size.height + MediaQuery.of(context).size.width),
        onPressed: onPressed
      ),
    );
  }
}

class CustomCircleIconButton extends StatelessWidget {
  final void Function() onPressed;
  final Future<String> future;
  final double borderWidth;
  final double scale;

  const CustomCircleIconButton({Key? key, required this.onPressed, required this.scale, required this.borderWidth, required this.future}) : super(key: key);

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
                } else {
                  return Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(width: borderWidth, color: Theme.of(context).colorScheme.primaryContainer),
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
              } else {
                return Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0),
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
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                spreadRadius: 5,
                offset: const Offset(5, 5),
                blurRadius: 10
            )
          ]
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        color: Colors.white,
        iconSize: sqrt(MediaQuery.of(context).size.height + MediaQuery.of(context).size.width),
        onPressed: () {
          Navigator.pop(context);
        },
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
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: const BorderRadius.all(
              Radius.circular(5.0),
            ),
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
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
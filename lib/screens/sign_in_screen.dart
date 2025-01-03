import 'package:flutter/material.dart';
import 'package:ya_disk_explorer/utils/data.dart';
import 'package:ya_disk_explorer/utils/settings_storage.dart';

import '../services/yandex_auth.dart';
import 'files_screen.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _SignInBackground(size: size),
          _SignInForm(size: size),
          IconButton(
            onPressed: () {Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const FilesScreen()),
            );},
            icon: const Icon(
              Icons.folder,
              size: 100,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignInBackground extends StatelessWidget {
  final Size size;

  const _SignInBackground({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height * 0.4,
      child: Stack(
        children: [
          Positioned(
            top: -size.height * 0.1,
            left: -size.width * 0.2,
            child: _CircleWidget(
              size: size.width * 0.9,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColorLight,
                  Theme.of(context).primaryColorDark,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: -size.height * 0.15,
            right: -size.width * 0.2,
            child: _CircleWidget(
              size: size.width * 0.8,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColorLight,
                  Theme.of(context).primaryColorDark,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleWidget extends StatelessWidget {
  final double size;
  final Gradient gradient;

  const _CircleWidget({
    required this.size,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
      ),
    );
  }
}

class _SignInForm extends StatelessWidget {
  final Size size;

  const _SignInForm({required this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size.width * 0.9,
        height: size.height * 0.2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).primaryColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _SignInButton(
                    imagePath: 'assets/images/yandex_icon.png',
                    onPressed: () async {
                      await YandexAuth.authenticate();
                      await SettingsStorage.loadToken()
                          .then((token) => Data().accessToken = token);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FilesScreen()),
                      );
                    },
                  ),
                ),
                _SignedIn(signedIn: Data().accessToken != null),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _SignInButton(
                    imagePath: 'assets/images/google_icon.png',
                    onPressed: () {}, // TODO: Добавить Google авторизацию
                  ),
                ),
                _SignedIn(signedIn: Data().accessToken != null),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;

  const _SignInButton({
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Image.asset(
        imagePath,
        scale: 0.1,
      ),
    );
  }
}

class _SignedIn extends StatelessWidget {
  final bool signedIn;

  const _SignedIn({super.key, required this.signedIn});

  @override
  Widget build(BuildContext context) {
    return signedIn
        ? const Icon(
            Icons.check,
            color: Colors.green,
          )
        : const Icon(
            Icons.close,
            color: Colors.red,
          );
  }
}

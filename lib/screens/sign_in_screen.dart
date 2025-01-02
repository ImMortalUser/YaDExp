import 'package:flutter/material.dart';
import 'package:ya_disk_explorer/utils/global_data.dart';
import 'package:ya_disk_explorer/utils/token_storage.dart';

import '../services/yandex_auth.dart';
import 'files_screen.dart';

class SignInScreen extends StatelessWidget {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white70,
      body: Column(
        children: [
          SizedBox(
            height: size.height * 0.4,
            child: Stack(
              children: [
                Positioned(
                  top: -size.height * 0.1,
                  left: -size.width * 0.2,
                  child: CircleWidget(
                    size: size.width * 0.9,
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.cyan],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  top: -size.height * 0.15,
                  right: -size.width * 0.2,
                  child: CircleWidget(
                    size: size.width * 0.8,
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.cyan],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: size.width * 0.9,
                height: size.height * 0.20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: TextField(
                        controller: _controllerEmail,
                        decoration: const InputDecoration(
                          hintText: "Email",
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: TextField(
                        controller: _controllerPassword,
                        decoration: const InputDecoration(
                          hintText: "Password",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: IconButton(
                icon: Icon(
                  Icons.check_box,
                  size: size.shortestSide * 0.3,
                  color: Colors.blueAccent,
                ),
                onPressed: () async {
                  await YandexAuth.authenticate();
                  await TokenStorage.loadToken()
                      .then((token) => GlobalData.accessToken = token);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => FilesScreen()),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CircleWidget extends StatelessWidget {
  final double size;
  final Gradient gradient;

  const CircleWidget({
    super.key,
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

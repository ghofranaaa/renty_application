import 'package:flutter/material.dart';
import 'package:renty/features/profile/login.dart';
import 'package:renty/features/profile/sign_up.dart';
import 'package:renty/shared/welcome_buttons.dart';
import '../../shared/custom_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 40.0,
              ),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Tune into New Possibilities With Renty!\n',
                        style: TextStyle(
                          color: Color(0xFFFF9100),
                          fontSize: 45.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text:
                        '\nWelcome to Renty – Tunisia’s first dedicated platform crafted for musicians and enthusiasts to connect, trade, and manage instruments in a streamlined and accessible way. Renty fills a vital gap by providing a trusted, user-friendly space where the local community can engage and share their passion for music, all while making instrument transactions simpler and more efficient.',
                        style: TextStyle(
                          color: Color(0xFF00712d),
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Login',
                      onTap: LoginScreen(),
                      color:  Colors.transparent,
                      textColor: Color(0xFF51abb2),
                    ),
                  ),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign Up',
                      onTap: SignUpScreen(),
                      color: Color(0xFF51abb2),
                      textColor: Color(0xFFf8f2ea),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

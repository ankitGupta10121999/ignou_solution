import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../constants/appRouter_constants.dart';

class ErrorPage extends StatelessWidget {
  final String? message;

  const ErrorPage({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: Colors.red,
      backgroundColor: Color(0xFFf0f0f0),
      body: Center(
        child: Container(
          // width: double.infinity,
          // padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            // gradient: LinearGradient(
            //   colors: [Color(0xFF0175C2), Color(0xFF03A9F4)],
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            // ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                'images/error_404.gif',
                width: size.width > 600 ? 450 : 250,
                height: size.width > 600 ? 450 : 250,
                fit: BoxFit.contain,
                // color: Colors.green,
                alignment: Alignment.bottomCenter,
              ),
              Text(
                'Oops! Page Not Found',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: size.width > 600 ? 32 : 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message ??
                    'The page you are looking for doesn’t exist or something went wrong.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: size.width > 600 ? 18 : 14,
                  color: Theme.of(context).primaryColor,
                ),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  GoRouter.of(context).go(RouterConstant.splash);
                },
                child: Text(
                  'Back to Home',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

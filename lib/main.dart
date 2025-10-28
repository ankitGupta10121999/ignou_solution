import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ignousolutionhub/auth/auth_service.dart';
import 'package:ignousolutionhub/core/locator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ignousolutionhub/core/firebase_options.dart';
import 'package:ignousolutionhub/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AuthService().setPersistence();
  setupLocator();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return InteractiveViewer(
          maxScale: 5.0,
          minScale: 1.0,
          panEnabled: true,
          scaleEnabled: true,
          child: MaterialApp.router(
            routerConfig: AppRouter.router,
            title: 'IGNOUE Solution Hub',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: const Color(0xFF002147),
              colorScheme: ColorScheme.fromSwatch().copyWith(
                // secondary: const Color(0xFF28a745),
                primary: const Color(0xFF002147),
              ),
              scaffoldBackgroundColor: Colors.transparent,
              appBarTheme: AppBarTheme(
                backgroundColor: const Color(0xFF002147),
                foregroundColor: Colors.white,
                titleTextStyle: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Color(0xFF002147),
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002147),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  textStyle: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              textTheme: GoogleFonts.robotoTextTheme(
                Theme.of(context).textTheme,
              ).apply(bodyColor: Colors.black87, displayColor: Colors.black87),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Color(0xFF002147),
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                labelStyle: GoogleFonts.roboto(color: Colors.grey.shade700),
                hintStyle: GoogleFonts.roboto(color: Colors.grey.shade500),
              ),
            ),
          ),
        );
      },
    );
  }
}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purohithulu/controller/apicalls.dart';
import 'package:purohithulu/functions/flutterfunctions.dart';
import 'package:purohithulu/providers/registerprovider.dart';
import 'package:purohithulu/providers/wallet.dart';
import 'package:purohithulu/screens/bookingscreen.dart';
import 'package:purohithulu/screens/otp_screen.dart';
import 'package:provider/provider.dart';
import 'package:purohithulu/screens/register_otp.dart';
import 'package:purohithulu/screens/registeruser.dart';
import 'package:purohithulu/screens/splashscreen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:purohithulu/screens/verify_otp.dart';
import 'package:purohithulu/screens/wallet.dart';
import 'package:purohithulu/screens/wellcomescreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controller/auth.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

void main() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrintStack(stackTrace: details.stack);
    return ErrorWidget(details.exception);
  };
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    final navigatorKey = GlobalKey<NavigatorState>();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    runApp(
      riverpod.ProviderScope(child: MyApp(navigatorKey: navigatorKey)),
    );
  }, (error, stackTrace) {
    print('Caught Flutter error');
    print(error.toString());
    print(stackTrace.toString());
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const MyApp({super.key, required this.navigatorKey});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const MaterialColor customColor = MaterialColor(
      0xFFF9BF42,
      <int, Color>{
        50: Color(0xFFFFFDE7),
        100: Color(0xFFFFF9C4),
        200: Color(0xFFFFF59D),
        300: Color(0xFFFFF176),
        400: Color(0xFFFFEE58),
        500: Color(0xFFF9BF42),
        600: Color(0xFFF57F17),
        700: Color(0xFFEF6C00),
        800: Color(0xFFE65100),
        900: Color(0xFFBF360C),
      },
    );
    final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RegisterAsPurohithProvider()),
        ChangeNotifierProvider(create: (context) => Auth()),
        ChangeNotifierProvider(create: (context) => FlutterFunctions()),
        ChangeNotifierProxyProvider<Auth, ApiCalls>(
          create: (context) => ApiCalls(),
          update: (context, value, previous) {
            return previous!
              ..update(value.accessToken == null ? '' : value.accessToken!,
                  value.fToken == null ? '' : value.fToken!);
          },
        ),
        ChangeNotifierProvider(
          create: (context) => WalletProvider(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, value, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: widget.navigatorKey,
            title: 'Agents',
            scaffoldMessengerKey: scaffoldMessengerKey,
            theme: ThemeData(
              primarySwatch: customColor,
            ),
            home: Builder(
              builder: (context) {
                return value.isAuth
                    ? const WellcomeScreen()
                    : FutureBuilder(
                        future: value.tryAutoLogin(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            print('waiting');
                            return const SplashScreen();
                          }
                          return OtpScreen(
                              scaffoldMessengerKey: scaffoldMessengerKey);
                        });
              },
            ),
            routes: {
              'verifyotp': (context) => VerifyOtp(
                    scaffoldMessengerKey: scaffoldMessengerKey,
                  ),
              'login': (context) => OtpScreen(
                    scaffoldMessengerKey: scaffoldMessengerKey,
                  ),
              'wellcome': (context) => const WellcomeScreen(),
              'registerotp': (context) => RegisterVerifyOtp(
                    scaffoldMessengerKey: scaffoldMessengerKey,
                  ),
              'registeruser': (context) => Register(
                    scaffoldMessengerKey: scaffoldMessengerKey,
                  ),
              'bookingHistory': (context) => const BookingsScreen(),
              'wallet': (context) => const Wallet(),
            },
          );
        },
      ),
    );
  }
}

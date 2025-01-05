import 'package:confirma_id/components/shared/styles.dart';
import 'package:confirma_id/features/auth_req_screen/auth_req_screen.dart';
import 'package:confirma_id/features/data_manage/data_manage_screen.dart';
import 'package:confirma_id/features/database/database.dart';
import 'package:confirma_id/features/initial_screen/initial_screen.dart';
import 'package:confirma_id/features/login/login_screen.dart';
import 'package:confirma_id/features/profile_search/profile_search_screen.dart';
import 'package:confirma_id/features/profile_verification_screen/profile_verification_screen.dart';
import 'package:confirma_id/features/results_screens/confere.dart';
import 'package:confirma_id/features/results_screens/no_info.dart';
import 'package:confirma_id/features/results_screens/notconfere.dart';
import 'package:confirma_id/features/tutorial/tutorial_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  await dotenv.load();

  // Inicializa database
  final Database database = Database();
  await database.initialize();

  // Verifica se o tutorial já foi completado
  final prefs = await SharedPreferences.getInstance();
  final bool isTutorialCompleted = prefs.getBool('tutorialCompleted') ?? false;

  runApp(MyApp(isTutorialCompleted: isTutorialCompleted));
}

class MyApp extends StatelessWidget {
  final bool isTutorialCompleted;

  const MyApp({super.key, required this.isTutorialCompleted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ConfirmaID',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: darkBackgroundColor,
      ),
      initialRoute: isTutorialCompleted ? '/' : '/tutorial',
      routes: {
        '/': (context) => const InitialScreen(),
        '/tutorial': (context) => TutorialScreen(),
        '/authReq': (context) => const AuthReqScreen(),
        '/dataManage': (context) => const DataManageScreen(),
        '/profileSearch': (context) => ProfileSearchScreen(),
        '/NoInfoScreen': (context) => NoInfoScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/login') {
          final args = settings.arguments! as LoginScreen;
          return MaterialPageRoute(
            builder: (context) {
              return LoginScreen(
                isLogin: args.isLogin,
              );
            },
          );
        } else if (settings.name == '/verify') {
          final args = settings.arguments! as ProfileVerificationArguments;
          return MaterialPageRoute(
            builder: (context) {
              return ProfileVerificationScreen(
                searchUserID: args.searchUserID,
              );
            },
          );
        } else if (settings.name == '/ConfereScreen') {
          final args = settings.arguments! as ConfereScreenArguments;
          return MaterialPageRoute(
            builder: (context) {
              return ConfereScreen(
                updatedAt: args.updatedAt,
              );
            },
          );
        } else if (settings.name == '/notConfere') {
          final args = settings.arguments! as NotConfereArguments;
          return MaterialPageRoute(
            builder: (context) {
              return NotConfereScreen(
                updatedAt: args.updatedAt,
              );
            },
          );
        }
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
    );
  }
}

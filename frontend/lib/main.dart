import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/verify_otp_screen.dart';
import 'screens/donor_dashboard.dart';
import 'screens/ngo_dashboard.dart';
import 'screens/volunteer_dashboard.dart';
import 'screens/admin_dashboard.dart';
import 'screens/donor/payment_screen.dart';
import 'screens/donor/today_campaigns_screen.dart';
import 'screens/donor/notifications_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NGO Donation App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      theme: ThemeData(
        primaryColor: Colors.purple,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      ),
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        // ✅ FIXED: Correctly extracts email from the Map arguments
        '/verify-otp': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          String email = '';
          if (args is String) {
            email = args;
          } else if (args is Map) {
            email = args['email']?.toString() ?? '';
          }
          return VerifyOtpScreen(email: email);
        },

        '/donor-dashboard': (context) => const DonorDashboard(),
        '/ngo-dashboard': (context) => const NGODashboard(),
        '/volunteer-dashboard': (context) => const VolunteerDashboard(),
        '/admin-dashboard': (context) => const AdminDashboard(),

        // ✅ ADDED FOR BETTER WEB NAVIGATION
        '/payment': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>;
          return PaymentScreen(campaign: args);
        },
        '/today-campaigns': (context) => const TodayCampaignsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },
    );
  }
}

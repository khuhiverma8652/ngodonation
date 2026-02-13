import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/verify_otp_screen.dart';
import 'screens/donor_dashboard.dart';
import 'screens/ngo_dashboard.dart';
import 'screens/volunteer_dashboard.dart';
import 'screens/admin_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NGO Donation App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        // ✅ VERIFY OTP (expects String email)
        '/verify-otp': (context) {
  final args = ModalRoute.of(context)?.settings.arguments;
  final email = args is String ? args : '';
  return VerifyOtpScreen(email: email);
},


        // ✅ DASHBOARDS (NO ARGUMENTS)
        '/donor-dashboard': (context) => const DonorDashboard(),
        '/ngo-dashboard': (context) => const NGODashboard(),
        '/volunteer-dashboard': (context) => const VolunteerDashboard(),
        '/admin-dashboard': (context) => const AdminDashboard(),
      },
    );
  }
}

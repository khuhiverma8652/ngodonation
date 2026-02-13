import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
final TextEditingController _ngoNameController = TextEditingController();
final TextEditingController _ngoAddressController = TextEditingController();

  
  String _selectedRole = 'donor';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreedToTerms = false;
  
  final List<Map<String, dynamic>> _roles = [
    {
      'name': 'donor',
      'displayName': 'Donor',
      'icon': Icons.volunteer_activism,
      'color': const Color(0xFF6200EE),
      'description': 'Support causes you care about',
    },
    {
      'name': 'ngo',
      'displayName': 'NGO',
      'icon': Icons.business,
      'color': const Color(0xFFFF5252),
      'description': 'Create and manage campaigns',
    },
    {
      'name': 'volunteer',
      'displayName': 'Volunteer',
      'icon': Icons.favorite,
      'color': const Color(0xFF00BCD4),
      'description': 'Contribute your time and skills',
    },
    {
      'name': 'admin',
      'displayName': 'Admin',
      'icon': Icons.admin_panel_settings,
      'color': const Color(0xFF9C27B0),
      'description': 'Manage the platform',
    },
  ];

  Map<String, dynamic> get _currentRole {
    return _roles.firstWhere((role) => role['name'] == _selectedRole);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Conditions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.register(
  name: _nameController.text,
  email: _emailController.text,
  password: _passwordController.text,
  phone: _phoneController.text,
  role: _selectedRole,
  ngoName: _ngoNameController.text,
  ngoAddress: _ngoAddressController.text,
);


      if (!mounted) return;

      if (response['success'] == true) {
        // Success - Navigate to OTP screen with proper type casting
        Navigator.pushNamed(
          context,
          '/verify-otp',
          arguments: <String, String>{
            'phone': _phoneController.text.trim(),
            'email': _emailController.text.trim(),
            'name': _nameController.text.trim(),
            'role': _selectedRole,
          },
        );
      } else {
        String message = response['message']?.toString() ?? 'Registration failed';
        
        if (message.toLowerCase().contains('already exists') || 
            message.toLowerCase().contains('duplicate')) {
          _showUserExistsDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showUserExistsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Account Already Exists'),
          content: const Text(
            'An account with this email/phone already exists. Would you like to login instead?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentRole['color'] as Color,
              ),
              child: const Text('Go to Login'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      _currentRole['color'] as Color,
      (_currentRole['color'] as Color).withOpacity(0.7),
    ],
  ),
),
    
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  padding: const EdgeInsets.all(16),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            _currentRole['icon'] as IconData,
                            size: 45,
                            color: _currentRole['color'] as Color,
                          ),
                        ).animate()
                          .fadeIn(duration: 600.ms)
                          .scale(delay: 100.ms),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.3, end: 0),
                      
                      const SizedBox(height: 8),
                      
                      const Text(
                        'OTP will be sent to your phone number',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: 0.3, end: 0),
                      
                      const SizedBox(height: 30),
                      
                      // Role Selection
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'I want to be a:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...(_roles.map((role) {
                              final isSelected = _selectedRole == role['name'];
                              return GestureDetector(
                                onTap: () {
                                  setState(() => _selectedRole = role['name'] as String);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        role['icon'] as IconData,
                                        size: 24,
                                        color: isSelected
                                            ? role['color'] as Color
                                            : Colors.white,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              role['displayName'] as String,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? role['color'] as Color
                                                    : Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              role['description'] as String,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.grey.shade700
                                                    : Colors.white70,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle,
                                          color: role['color'] as Color,
                                          size: 24,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList()),
                          ],
                        ),
                      ).animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: 0.3, end: 0),
                      
                      const SizedBox(height: 24),
                      
                      // Form continues here (same as before but with proper type casting)
                      // ... rest of the form code from previous version
                      
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(Icons.person_outline, color: _currentRole['color'] as Color),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty ? 'Please enter your name' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number (for OTP)',
                                  prefixIcon: Icon(Icons.phone_outlined, color: _currentRole['color'] as Color),
                                  counterText: '',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Phone number required';
                                  if (value.length != 10) return 'Must be 10 digits';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined, color: _currentRole['color'] as Color),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                validator: (value) =>
                                    value == null || !value.contains('@') ? 'Enter valid email' : null,
                              ),
                              const SizedBox(height: 16),
if (_selectedRole == "ngo") ...[
  const SizedBox(height: 16),
  TextFormField(
    controller: _ngoNameController,
    decoration: InputDecoration(
      labelText: "NGO Name",
      prefixIcon: Icon(Icons.business, color: _currentRole['color'] as Color),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  const SizedBox(height: 16),
  TextFormField(
    controller: _ngoAddressController,
    decoration: InputDecoration(
      labelText: "NGO Address",
      prefixIcon: Icon(Icons.location_on, color: _currentRole['color'] as Color),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
],

                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.lock_outline, color: _currentRole['color'] as Color),
                                  suffixIcon: IconButton(
                                    icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                validator: (value) =>
                                    value == null || value.length < 6 ? 'Min 6 characters' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: !_isConfirmPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  prefixIcon: Icon(Icons.lock_outline, color: _currentRole['color'] as Color),
                                  suffixIcon: IconButton(
                                    icon: Icon(_isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                                    onPressed: () =>
                                        setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty ? 'Confirm password' : null,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _agreedToTerms,
                                    onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                                    activeColor: _currentRole['color'] as Color,
                                  ),
                                  const Expanded(
                                    child: Text('I agree to Terms & Conditions', style: TextStyle(fontSize: 13)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _currentRole['color'] as Color,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                      : const Text('Send OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? ', style: TextStyle(color: Colors.white)),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Login',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      if (_isLogin) {
        await repo.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await repo.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
      // Router will handle redirect
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8BA894), // Sage context
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
             child: Padding(
               padding: const EdgeInsets.all(24),
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Text(
                     _isLogin ? 'Welcome Back' : 'Create Account',
                     style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 24),
                   TextField(
                     controller: _emailController,
                     decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                     keyboardType: TextInputType.emailAddress,
                   ),
                   const SizedBox(height: 16),
                   TextField(
                     controller: _passwordController,
                     decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                     obscureText: true,
                   ),
                   const SizedBox(height: 24),
                   if (_isLoading)
                     const CircularProgressIndicator()
                   else
                     ElevatedButton(
                       onPressed: _submit,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFFD4A5A5), // Dusty Rose
                         foregroundColor: Colors.white,
                         minimumSize: const Size(double.infinity, 50),
                       ),
                       child: Text(_isLogin ? 'Login' : 'Sign Up'),
                     ),
                   const SizedBox(height: 16),
                   OutlinedButton.icon(
                     onPressed: () async {
                       setState(() => _isLoading = true);
                       try {
                         await ref.read(authRepositoryProvider).signInWithGoogle();
                       } catch (e) {
                         if (mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                         }
                       } finally {
                         if (mounted) setState(() => _isLoading = false);
                       }
                     },
                     icon: const Icon(Icons.g_mobiledata, size: 32),
                     label: const Text('Sign in with Google'),
                     style: OutlinedButton.styleFrom(
                       minimumSize: const Size(double.infinity, 50),
                       foregroundColor: Colors.teal.shade900,
                     ),
                   ),
                   const SizedBox(height: 16),
                   TextButton(
                     onPressed: () => setState(() => _isLogin = !_isLogin),
                     child: Text(_isLogin ? 'Need an account? Sign Up' : 'Have an account? Login'),
                   ),
                 ],
               ),
             ),
          ),
        ),
      ),
    );
  }
}

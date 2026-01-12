import 'package:flutter/material.dart';
import 'package:facebook_lab/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() {
    return _SignUpScreenState();
  }
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isObscure = true;
  bool loading = false;

  void _goToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const LoginScreen()),
    );
  }

  Future<void> signup() async {
    try {
      setState(() => loading = true);
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pop(context);
    } catch (e) {
      if (e is FirebaseAuthException &&
          e.code == 'account-exists-with-different-credential') {
        // Fetch existing providers and prompt user to sign in with original method, then link
        // For simplicity, show a message:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account exists with different provider. Please sign in with original method first.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign up failed: $e')));
      }
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      setState(() => loading = true);

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      // Wait a bit for the auth state to update
      await Future.delayed(const Duration(seconds: 1));
      // Navigate back to AuthGate, which will detect the user and go to HomePage
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_outlined),
        ),
        title: Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                maxLength: 50,
                decoration: InputDecoration(label: Text('Email')),
              ),
              TextFormField(
                controller: _passwordController,
                maxLength: 50,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  label: Text('Password'),
                  suffixIcon: IconButton(
                    icon: _isObscure
                        ? Icon(Icons.visibility)
                        : Icon(Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
              ),
              TextFormField(
                controller: _confirmPasswordController,
                maxLength: 50,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  label: Text('Confirm Password'),
                  suffixIcon: IconButton(
                    icon: _isObscure
                        ? Icon(Icons.visibility)
                        : Icon(Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    signup();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.secondaryFixed,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Image.asset(
                    'assets/google_logo.png',
                    height: 24,
                  ), // Optional: add Google logo asset
                  label: const Text('Sign up with Google'),
                  onPressed: loading ? null : signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  _goToLogin(context);
                },
                child: Text('Already have an account? Sign in'),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

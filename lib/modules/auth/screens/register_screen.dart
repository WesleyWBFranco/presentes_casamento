import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presentes_casamento/helper/helper_function.dart';

class RegisterScreen extends StatefulWidget {
  final void Function()? onTap;

  const RegisterScreen({super.key, required this.onTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPwController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future registerUser() async {
    if (passwordConfirmed()) {
      try {
        UserCredential? userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );

        String userRole = 'user';

        addUserDetails(
          nameController.text.trim(),
          emailController.text.trim(),
          userRole,
          userCredential.user!.uid,
        );
      } on FirebaseAuthException catch (e) {
        displayMessageToUser(e.code, context);
      }
    } else {
      displayMessageToUser("Senhas não coincidem", context);
    }
  }

  Future addUserDetails(
    String name,
    String email,
    String userRole,
    String uid,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'role': userRole,
    });
  }

  bool passwordConfirmed() {
    return passwordController.text.trim() == confirmPwController.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Container(
          width: 500,
          height: 900,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Image.asset(
                  'assets/images/presente.png',
                  color: Colors.black,
                  width: 65,
                ),
                Text(
                  'REGISTRAR',
                  style: GoogleFonts.libreBaskerville(
                    color: Colors.black,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 48),

                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    labelStyle: GoogleFonts.libreBaskerville(
                      color: Colors.black,
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outlined,
                      color: Colors.black,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: GoogleFonts.libreBaskerville(
                      color: Colors.black,
                    ),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Colors.black,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    labelStyle: GoogleFonts.libreBaskerville(
                      color: Colors.black,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.black,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: confirmPwController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Senha',
                    labelStyle: GoogleFonts.libreBaskerville(
                      color: Colors.black,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.black,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: registerUser,
                    child: Text(
                      'Registrar-se',
                      style: GoogleFonts.libreBaskerville(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Já tem uma conta?',
                      style: GoogleFonts.libreBaskerville(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        'Entrar',
                        style: GoogleFonts.libreBaskerville(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

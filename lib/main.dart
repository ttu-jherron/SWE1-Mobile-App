import 'package:flutter/material.dart';
import 'widgets/custom_text_field.dart';

void main() {
  runApp(const MainApp());
}

const List<Map<String, dynamic>> userData = [
  {
      'email': 'family@guy.com',
      'password': 'PeterGriffin123!',
  },
  {
      'email': 'user2@gmail.com',
      'password': 'Password1!',
  }
  ];


const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
const String passwordPattern = r'(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%\^&\*\(\)_\+=]).{8,32}';
const String phoneNumberPattern = r'^\+?[1-9]\d{9,14}$';
final emailRegex = RegExp(emailPattern);
final passwordRegex = RegExp(passwordPattern);
final phoneNumberRegex = RegExp(phoneNumberPattern);
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Text(
          "Login",
        ),
      ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(
                controller: emailController,
                labelText: "Email Address",
                isRequired: true,
              ),
              CustomTextField(
                controller: passwordController,
                labelText: "Password",
                isPassword: true,
                isRequired: true,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final emailAddress = emailController.text;

                      final password = passwordController.text;
                      if (!emailRegex.hasMatch(emailAddress)) {
                        showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                            content: Text("Invalid email address!"),
                          ),
                        );
                        return;
                      }
                      if (!passwordRegex.hasMatch(password)) {
                        showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                            content: Text("Invalid password!"),
                          ),
                        );
                        return;
                      }

                      final userExists = userData.any((user) =>
                        user['email'] == emailAddress && user['password'] == password
                      );
                      
                      // Successful login
                      if (userExists) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: Text("Sign in successful!\nEmail: $emailAddress"),
                          ),
                        );
                      }
                      // Unsuccessful login
                      else {
                        showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                            content: Text("Email or password incorrect."),
                          ),
                        );
                      }
                    },
                    child: const Text("Sign In"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                    },
                    child: const Text("Register"),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    phoneNumberController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Text(
          "Register",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomTextField(
            controller: firstNameController,
            labelText: "First Name",
            isRequired: true,
          ),
        CustomTextField(
            controller: lastNameController,
            labelText: "Last Name",
            isRequired: true,
          ),
          CustomTextField(
            controller: phoneNumberController,
            labelText: "Phone Number",
            isRequired: true,
          ),
          CustomTextField(
            controller: emailController,
            labelText: "Email Address",
            isRequired: true,
          ),
        CustomTextField(
            controller: passwordController,
            labelText: "Password",
            isRequired: true,
            isPassword: true,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                final firstName = firstNameController.text;
                final lastName = lastNameController.text;
                final phoneNumber = phoneNumberController.text;
                final emailAddress = emailController.text;
                final password = passwordController.text;

                if (firstName == '') {
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          content: Text("You are required a first name!"),
                        ),
                      );
                      return;
                }
                if (lastName == '') {
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          content: Text("You are required a last name!"),
                        ),
                      );
                      return;
                }
                if (phoneNumber == '') {
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          content: Text("You are required a phone number"),
                        ),
                      );
                      return;
                }
                // Validate regex for email password and phone number
                if (!emailRegex.hasMatch(emailAddress)) {
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          content: Text("Invalid email address!"),
                        ),
                      );
                      return;
                }
                if (!passwordRegex.hasMatch(password)) {
                  showDialog(
                    context: context,
                    builder: (context) => const AlertDialog(
                      content: Text("Invalid password!"),
                    ),
                  );
                  return;
                }
                if (!phoneNumberRegex.hasMatch(phoneNumber)) {
                  showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          content: Text("Invalid phone number!"),
                        ),
                      );
                      return;
                }
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Registration Info"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("First Name: $firstName"),
                        Text("Last Name: $lastName"),
                        Text("Phone Number: $phoneNumber"),
                        Text("Email Address: $emailAddress"),
                        Text("Password: $password"),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () { 
                          Navigator.of(context).pop();
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              }, 
              child: Text("Register Account")
              ),
            ],
          ),

        ],
      ),
      
    );
  }

}
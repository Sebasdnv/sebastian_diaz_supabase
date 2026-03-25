import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sebastian_diaz_supabase/viewmodel/auth_view_model.dart';
import 'package:sebastian_diaz_supabase/views/auth/login_view.dart';
import 'package:sebastian_diaz_supabase/views/home_view.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text("Registrazione"),
        centerTitle: true,
      ),
      body: vm.isLoading? const Center(child: CircularProgressIndicator(),)
      : Padding(padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          //* campo per email
          TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: "Email"),
          ),
          //* campo per password
          TextField(
            controller: passwordController,
            decoration:  InputDecoration(labelText: "Password"),
          ),
          ElevatedButton(onPressed: ()async{
            await vm.register(emailController.text, passwordController.text);
            if (vm.session != null && context.mounted) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> HomeView()));
            }
          }, child: Text("registrati")),
          TextButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (_)=> LoginView()));
          }, child: const Text("Hai un account? Loggati!"))
        ],
      ),)
    );
  }
}
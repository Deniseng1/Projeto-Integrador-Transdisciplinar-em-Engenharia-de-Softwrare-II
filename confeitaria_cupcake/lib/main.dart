import 'firebase_options.dart';


import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'services/cart_provider.dart';
import 'services/data_initialization_service.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Inicializa os dados dos cupcakes no Firestore
  try {
    print('🚀 Iniciando aplicativo Patisserie Artisan...');
    final dataService = DataInitializationService();
    await dataService.initializeCupcakes();
    print('✅ Dados inicializados com sucesso!');
  } catch (e) {
    print('⚠️ Erro na inicialização dos dados: $e');
    // App continua funcionando mesmo se a inicialização falhar
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Patisserie Artisan',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Enquanto verifica o estado de autenticação
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Se há erro na verificação
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Erro ao verificar autenticação'),
            ),
          );
        }
        
        // Se usuário está logado, vai para HomeScreen
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }
        
        // Se não está logado, vai para AuthScreen
        return const AuthScreen();
      },
    );
  }
}
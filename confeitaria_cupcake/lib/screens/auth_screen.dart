import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_service.dart';
import '../theme.dart';
import '../utils/responsive_util.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool isLogin;

  const AuthScreen({Key? key, this.isLogin = true}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nomeController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nomeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _resetPassword() async {
    if (_emailController.text.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, informe um email válido para recuperação',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseService.recuperarSenha(_emailController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Email de recuperação enviado! Verifique sua caixa de entrada.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao enviar email de recuperação: ${e.toString()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        // Login
        await _firebaseService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        // Registro
        await _firebaseService.registrar(
          _emailController.text.trim(),
          _passwordController.text,
          _nomeController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro de autenticação: ${e.toString()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: ResponsiveUtil.wrapWithMaxWidth(
        GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Fundo decorativo
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.35,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.secondaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cake_rounded,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Patisserie Artisan',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cupcakes Gourmet',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.8),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Formulário
            Positioned(
              top: size.height * 0.3,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 4,
                          shadowColor: isDarkMode
                              ? Colors.black.withOpacity(0.4)
                              : Colors.grey.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    _isLogin ? 'Bem-vindo(a) de volta!' : 'Criar nova conta',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _isLogin
                                        ? 'Entre para saborear nossos cupcakes'
                                        : 'Registre-se para descobrir nossos sabores',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                              ?.withOpacity(0.7),
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Campo Nome (somente no registro)
                                  if (!_isLogin)
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      constraints: BoxConstraints(
                                        maxHeight: !_isLogin ? 80 : 0,
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              controller: _nomeController,
                                              decoration: const InputDecoration(
                                                labelText: 'Nome completo',
                                                prefixIcon: Icon(Icons.person_outline),
                                              ),
                                              textCapitalization: TextCapitalization.words,
                                              textInputAction: TextInputAction.next,
                                              validator: (value) {
                                                if (!_isLogin &&
                                                    (value == null || value.trim().isEmpty)) {
                                                  return 'Por favor, informe seu nome';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 16),
                                          ],
                                        ),
                                      ),
                                    ),
                                  
                                  // Campo Email
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autocorrect: false,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Por favor, informe seu email';
                                      }
                                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value)) {
                                        return 'Por favor, informe um email válido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Campo Senha
                                  TextFormField(
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                      labelText: 'Senha',
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: AppTheme.primaryColor,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                    obscureText: _obscurePassword,
                                    textInputAction: _isLogin ? TextInputAction.done : TextInputAction.next,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor, informe sua senha';
                                      }
                                      if (!_isLogin && value.length < 6) {
                                        return 'A senha deve ter pelo menos 6 caracteres';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Campo Confirmar Senha (somente no registro)
                                  if (!_isLogin)
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      constraints: BoxConstraints(
                                        maxHeight: !_isLogin ? 80 : 0,
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              controller: _confirmPasswordController,
                                              decoration: InputDecoration(
                                                labelText: 'Confirmar senha',
                                                prefixIcon: const Icon(Icons.lock_outline),
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    _obscureConfirmPassword
                                                        ? Icons.visibility_outlined
                                                        : Icons.visibility_off_outlined,
                                                    color: AppTheme.primaryColor,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                                    });
                                                  },
                                                ),
                                              ),
                                              obscureText: _obscureConfirmPassword,
                                              textInputAction: TextInputAction.done,
                                              validator: (value) {
                                                if (!_isLogin) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Por favor, confirme sua senha';
                                                  }
                                                  if (value != _passwordController.text) {
                                                    return 'As senhas não conferem';
                                                  }
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 16),
                                          ],
                                        ),
                                      ),
                                    ),
                                  
                                  // Botão "Esqueci minha senha" (somente no login)
                                  if (_isLogin)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: _isLoading ? null : _resetPassword,
                                        child: Text(
                                          'Esqueci minha senha',
                                          style: TextStyle(
                                            color: AppTheme.secondaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 24),
                                  
                                  // Botão principal (Entrar ou Criar conta)
                                  ElevatedButton(
                                    onPressed: _isLoading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.5),
                                      elevation: 2,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : Text(_isLogin ? 'Entrar' : 'Criar conta'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Botão para alternar entre login e registro
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin ? 'Ainda não tem uma conta?' : 'Já tem uma conta?',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: _switchAuthMode,
                              child: Text(
                                _isLogin ? 'Criar conta' : 'Entrar',
                                style: TextStyle(
                                  color: AppTheme.secondaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
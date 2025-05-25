import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_models.dart';
import '../services/firebase_service.dart';
import '../services/cart_provider.dart';
import '../theme.dart';
import '../utils/responsive_util.dart';
import '../utils/image_validator.dart';

import 'profile_screen.dart';
import 'cart_payment_screen.dart';
import 'my_orders_screen.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  int _currentIndex = 0;
  String _selectedCategory = 'Todos';
  UserModel? _userData;
  late TabController _tabController;
  
  // Controlador de animação para os elementos da página
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _tabController = TabController(length: 3, vsync: this);
    
    // Inicializar controlador de animação
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Iniciar animação imediatamente
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _firebaseService.getUserData();
      setState(() {
        _userData = user;
      });
    } catch (e) {
      // print('Erro ao carregar dados do usuário: $e');
    }
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar saída'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _firebaseService.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuthScreen(isLogin: true),
                  ),
                );
              }
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      final bool isMobile = ResponsiveUtil.isMobile(context);
      final bool isTablet = ResponsiveUtil.isTablet(context);
      final cartProvider = Provider.of<CartProvider>(context);

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Row(
          children: [
            // Sidebar para desktop/tablet
            if (!isMobile) _buildDesktopSidebar(),
            
            // Conteúdo principal
            Expanded(
              child: _buildCurrentScreen(),
            ),
          ],
        ),
        bottomNavigationBar: isMobile ? _buildBottomNavigationBar() : null,
      );
    } catch (e, stackTrace) {
      print('Erro crítico no build do HomeScreen: $e');
      print('StackTrace: $stackTrace');
      
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro crítico na aplicação',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Erro: ${e.toString()}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      _currentIndex = 0;
                    });
                  }
                },
                child: const Text('Reiniciar'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.home),
              ),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_bag_outlined),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_bag),
              ),
              label: 'Carrinho',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person),
              ),
              label: 'Perfil',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_outlined),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long),
              ),
              label: 'Pedidos',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    try {
      switch (_currentIndex) {
        case 0:
          return _buildShowcaseScreen();
        case 1:
          return const CartPaymentScreen();
        case 2:
          return ProfileScreen(
            onUpdateProfile: () => _loadUserData(),
          );
        case 3:
          return const MyOrdersScreen();
        default:
          return _buildShowcaseScreen();
      }
    } catch (e, stackTrace) {
      // Log do erro para debugging
      print('Erro na tela $_currentIndex: $e');
      print('StackTrace: $stackTrace');
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar a tela',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Índice: $_currentIndex\nErro: ${e.toString()}',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 0; // Volta para a tela inicial
                });
              },
              child: const Text('Voltar ao Início'),
            ),
          ],
        ),
      );
    }
  }
  
  Widget _buildDesktopSidebar() {
    final bool isTablet = ResponsiveUtil.isTablet(context);
    final bool isNotebook = ResponsiveUtil.isNotebook(context);
    
    // Defina larguras e paddings mais adequados para cada tamanho de tela
    final double sidebarWidth = isTablet 
        ? 200 
        : isNotebook 
            ? 220 
            : 260;
    
    final double horizontalPadding = isTablet 
        ? 10 
        : isNotebook 
            ? 12 
            : 16;
    
    final double verticalPadding = isTablet 
        ? 6 
        : isNotebook 
            ? 8 
            : 10;
    
    final double iconSize = isTablet 
        ? 22 
        : isNotebook 
            ? 24 
            : 28;
    
    final double titleFontSize = isTablet 
        ? 14 
        : isNotebook 
            ? 15 
            : 16;
    
    final double avatarRadius = isTablet 
        ? 18 
        : isNotebook 
            ? 20 
            : 24;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: verticalPadding + 8),
          // Logo e nome do app
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet || isNotebook ? 6 : 8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.cake,
                    color: AppTheme.primaryColor,
                    size: iconSize,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Cupcake Delivery',
                    style: GoogleFonts.poppins(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: verticalPadding + 16),
          // Usuário logado
          if (_userData != null)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, 
                vertical: verticalPadding
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: AppTheme.accentColor,
                    child: _userData?.fotoPerfil != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(avatarRadius),
                            child: ImageValidator.buildSafeImage(
                              imageData: _userData!.fotoPerfil!,
                              width: avatarRadius * 2,
                              height: avatarRadius * 2,
                              fit: BoxFit.cover,
                              placeholder: Text(
                                _userData!.nome.substring(0, 1).toUpperCase(),
                                style: GoogleFonts.poppins(
                                  color: AppTheme.primaryColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            _userData!.nome.substring(0, 1).toUpperCase(),
                            style: GoogleFonts.poppins(
                              color: AppTheme.primaryColor,
                              fontSize: isTablet || isNotebook ? 16 : 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userData!.nome,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet ? 12 : (isNotebook ? 13 : 14),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _userData!.email,
                          style: GoogleFonts.poppins(
                            fontSize: isTablet || isNotebook ? 10 : 12,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: verticalPadding + 12),
          // Menu de navegação
          _buildNavItem(
            0,
            Icons.home_outlined,
            'Início',
            'Confira nossos produtos',
          ),
          _buildNavItem(
            1,
            Icons.shopping_bag_outlined,
            'Carrinho',
            'Veja seus itens',
            badge: true,
          ),
          _buildNavItem(
            2,
            Icons.person_outline,
            'Perfil',
            'Seus dados e configurações',
          ),
          // Item de menu para Pedidos
          _buildNavItem(
            3,
            Icons.receipt_long_outlined,
            'Meus Pedidos',
            'Histórico e acompanhamento',
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => const MyOrdersScreen(),
                ),
              );
            },
          ),
          const Spacer(),
          // Botão para sair
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding, 
              vertical: verticalPadding + 6
            ),
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: Icon(Icons.logout, size: isTablet || isNotebook ? 16 : 18),
              label: Text(
                'Sair',
                style: TextStyle(fontSize: isTablet || isNotebook ? 12 : 14),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey,
                side: BorderSide(color: Colors.grey.shade300),
                padding: EdgeInsets.symmetric(
                  vertical: isTablet || isNotebook ? 8 : 12, 
                  horizontal: isTablet || isNotebook ? 12 : 16
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(height: verticalPadding + 8),
        ],
      ),
    );
  }
  
  Widget _buildNavItem(int index, IconData icon, String title, String subtitle, {bool badge = false, VoidCallback? onTap}) {
    final isSelected = index == _currentIndex;
    final cartProvider = Provider.of<CartProvider>(context, listen: true);
    final itemCount = cartProvider.itemCount;
    
    final bool isTablet = ResponsiveUtil.isTablet(context);
    final bool isNotebook = ResponsiveUtil.isNotebook(context);
    
    // Ajustar tamanhos e espaçamentos com base no tamanho da tela
    final double horizontalPadding = isTablet 
        ? 6 
        : isNotebook 
            ? 8 
            : 12;
    
    final double verticalPadding = isTablet 
        ? 4 
        : isNotebook 
            ? 5 
            : 8;
    
    final double contentPaddingVertical = isTablet 
        ? 8 
        : isNotebook 
            ? 9 
            : 12;
    
    final double contentPaddingHorizontal = isTablet 
        ? 10 
        : isNotebook 
            ? 12 
            : 16;
    
    final double iconPadding = isTablet 
        ? 5 
        : isNotebook 
            ? 6 
            : 8;
    
    final double iconSize = isTablet 
        ? 18 
        : isNotebook 
            ? 19 
            : 20;
    
    final double titleFontSize = isTablet 
        ? 13 
        : isNotebook 
            ? 14 
            : 15;
    
    final double subtitleFontSize = isTablet 
        ? 10 
        : isNotebook 
            ? 11 
            : 12;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding, 
        vertical: verticalPadding
      ),
      child: InkWell(
        onTap: onTap ?? () {
          setState(() {
            _currentIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: contentPaddingVertical,
            horizontal: contentPaddingHorizontal
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isSelected
                ? AppTheme.accentColor.withOpacity(0.2)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: !isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          width: 1,
                        )
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
                  size: iconSize,
                ),
              ),
              SizedBox(width: isTablet || isNotebook ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: titleFontSize,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: subtitleFontSize,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge && index == 1 && itemCount > 0)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet || isNotebook ? 6 : 8, 
                    vertical: isTablet || isNotebook ? 3 : 4
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    itemCount.toString(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: isTablet || isNotebook ? 10 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo e nome
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.cake,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Cupcake Delivery',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          // Área do usuário com menu dropdown
          if (_userData != null)
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Foto e nome do usuário
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppTheme.accentColor,
                              child: _userData?.fotoPerfil != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: ImageValidator.buildSafeImage(
                                        imageData: _userData!.fotoPerfil!,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        placeholder: Text(
                                          _userData!.nome.substring(0, 1).toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            color: AppTheme.primaryColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      _userData!.nome.substring(0, 1).toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        color: AppTheme.primaryColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _userData!.nome,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _userData!.email,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        // Opções de menu
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: const Text('Meu Perfil'),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _currentIndex = 2; // Índice da tela de perfil
                            });
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.receipt_long_outlined),
                          title: const Text('Meus Pedidos'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => const MyOrdersScreen(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('Sair'),
                          onTap: () {
                            Navigator.pop(context);
                            _logout();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.accentColor,
                child: _userData?.fotoPerfil != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ImageValidator.buildSafeImage(
                          imageData: _userData!.fotoPerfil!,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          placeholder: Text(
                            _userData!.nome.substring(0, 1).toUpperCase(),
                            style: GoogleFonts.poppins(
                              color: AppTheme.primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        _userData!.nome.substring(0, 1).toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: AppTheme.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildMainBanner() {
    final double bannerHeight = ResponsiveUtil.getBannerHeight(context);
    final bool isMobile = ResponsiveUtil.isMobile(context);
    
    return Container(
      width: double.infinity,
      height: bannerHeight,
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 24,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF9D5E5),
            Color(0xFFEF5DA8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Elementos decorativos
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -30,
            top: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Conteúdo do banner
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Texto e botão
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Cupcakes Especiais',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: isMobile ? 24 : 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Experimente nossas delícias artesanais com sabores exclusivos.',
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 12 : 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = 'Premium';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Ver Premium'),
                      ),
                    ],
                  ),
                ),
                // Imagem (apenas visível em telas maiores)
                if (!isMobile)
                  Expanded(
                    flex: 2,
                    child: _buildBannerImage(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoriesSection() {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 24,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categorias',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                CategoryChip(
                  label: 'Todos',
                  isSelected: _selectedCategory == 'Todos',
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'Todos';
                    });
                  },
                ),
                CategoryChip(
                  label: 'Clássicos',
                  isSelected: _selectedCategory == 'Clássicos',
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'Clássicos';
                    });
                  },
                ),
                CategoryChip(
                  label: 'Premium',
                  isSelected: _selectedCategory == 'Premium',
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'Premium';
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeaturesSection() {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 24,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Por que escolher nossos cupcakes?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ResponsiveUtil.isMobile(context)
              ? Column(
                  children: [
                    _buildFeatureItem(
                      icon: Icons.cake_outlined,
                      title: 'Sabor Artesanal',
                      description: 'Cupcakes feitos à mão com ingredientes selecionados e receitas exclusivas.',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.delivery_dining_outlined,
                      title: 'Entrega Rápida',
                      description: 'Entregamos em até 60 minutos, mantendo a qualidade e frescor dos produtos.',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.eco_outlined,
                      title: 'Opções Especiais',
                      description: 'Variedade de opções para intolerâncias alimentares e dietas específicas.',
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFeatureItem(
                      icon: Icons.cake_outlined,
                      title: 'Sabor Artesanal',
                      description: 'Cupcakes feitos à mão com ingredientes selecionados e receitas exclusivas.',
                    ),
                    _buildFeatureItem(
                      icon: Icons.delivery_dining_outlined,
                      title: 'Entrega Rápida',
                      description: 'Entregamos em até 60 minutos, mantendo a qualidade e frescor dos produtos.',
                    ),
                    _buildFeatureItem(
                      icon: Icons.eco_outlined,
                      title: 'Opções Especiais',
                      description: 'Variedade de opções para intolerâncias alimentares e dietas específicas.',
                    ),
                  ],
                ),
        ],
      ),
    );
  }
  
  Widget _buildCupcakesGrid() {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    final bool isTablet = ResponsiveUtil.isTablet(context);
    final bool isNotebook = ResponsiveUtil.isNotebook(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : isTablet ? 24 : isNotebook ? 28 : 32,
        vertical: isMobile ? 16 : isTablet ? 20 : 24,
      ),
      child: ResponsiveUtil.wrapWithMaxWidth(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nossos Cupcakes',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: ResponsiveUtil.isMobile(context) ? 24 : 
                             ResponsiveUtil.isTablet(context) ? 26 : 
                             ResponsiveUtil.isNotebook(context) ? 28 : 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedCategory != 'Todos')
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'Todos';
                      });
                    },
                    icon: const Icon(Icons.filter_list_off, size: 18),
                    label: const Text('Limpar filtro'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Mostrar cupcakes baseados na categoria selecionada
            StreamBuilder<List<Cupcake>>(
              stream: _selectedCategory != 'Todos'
                  ? _firebaseService.getCupcakesByCategory(_selectedCategory)
                  : _firebaseService.getCupcakes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Text(
                        'Erro ao carregar dados: ${snapshot.error}',
                        style: TextStyle(color: AppTheme.errorColor),
                      ),
                    ),
                  );
                }

                final rawCupcakes = snapshot.data ?? [];
                
                // Filtrar cupcakes com dados corrompidos
                final cupcakes = _filterValidCupcakes(rawCupcakes);
                
                if (cupcakes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum cupcake encontrado com esses filtros',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = 'Todos';
                              });
                            },
                            child: const Text('Limpar filtros'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return _buildCupcakeGrid(cupcakes, 100);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCupcakeGrid(List<Cupcake> cupcakes, int maxItems) {
    final crossAxisCount = ResponsiveUtil.getCupcakeGridCrossAxisCount(context);
    final childAspectRatio = ResponsiveUtil.getChildAspectRatio(context);
    final bool isNotebook = ResponsiveUtil.isNotebook(context);
    final bool isDesktop = ResponsiveUtil.isDesktop(context);
    
    // Ajusta o espaçamento entre os itens para telas maiores
    final double spacing = isNotebook || isDesktop ? 24 : 16;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount.toInt(),
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      padding: EdgeInsets.zero, // Removing padding to avoid extra space
      itemCount: cupcakes.length > maxItems ? maxItems : cupcakes.length,
      itemBuilder: (context, index) {
        return _buildCupcakeCard(cupcakes[index]);
      },
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String title, required String description}) {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    final double containerWidth = isMobile ? double.infinity : 300;
    
    return Container(
      width: containerWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCupcakeCard(Cupcake cupcake) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final bool isInCart = cartProvider.isInCart(cupcake.id);
    
    return InkWell(
      onTap: () => _showCupcakeDetails(cupcake),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do cupcake
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.2,
                    child: _buildCupcakeImage(cupcake),
                  ),
                  // Tag de categoria
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: cupcake.categoria == 'Premium'
                            ? const Color(0xFFF2D492)
                            : AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        cupcake.categoria,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: cupcake.categoria == 'Premium'
                              ? AppTheme.textPrimaryColor
                              : AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  // Tag de sabor
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        cupcake.sabor,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Informações do cupcake
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nome e preço
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cupcake.nome,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'R\$ ${cupcake.preco.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    // Botão de adicionar ao carrinho
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (isInCart) {
                            cartProvider.removeItem(cupcake.id);
                          } else {
                            cartProvider.addItem(cupcake);
                          }
                          setState(() {}); // Atualiza o estado para refletir mudança no botão
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isInCart ? Colors.grey.shade200 : AppTheme.primaryColor,
                          foregroundColor: isInCart ? Colors.black : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: const Size(double.infinity, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isInCart ? Icons.remove_shopping_cart : Icons.add_shopping_cart,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isInCart ? 'Remover' : 'Adicionar',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCupcakeDetails(Cupcake cupcake) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final bool isInCart = cartProvider.isInCart(cupcake.id);
    final bool isMobile = ResponsiveUtil.isMobile(context);
    final bool isTablet = ResponsiveUtil.isTablet(context);
    final bool isNotebook = ResponsiveUtil.isNotebook(context);
    
    if (isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: _buildCupcakeDetailsContent(cupcake, isInCart, cartProvider),
              ),
            );
          },
        ),
      );
    } else {
      // Para tablet, notebook e desktop
      double dialogWidth = 800;
      double maxHeight = MediaQuery.of(context).size.height * 0.85;
      
      if (isTablet) {
        dialogWidth = MediaQuery.of(context).size.width * 0.85;
      } else if (isNotebook) {
        dialogWidth = MediaQuery.of(context).size.width * 0.75;
      } else {
        // Desktop
        dialogWidth = MediaQuery.of(context).size.width * 0.6;
      }
      
      // Garantir largura mínima e máxima
      dialogWidth = dialogWidth.clamp(600.0, 1000.0);
      
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: maxHeight,
            ),
            child: SingleChildScrollView(
              child: _buildCupcakeDetailsContent(cupcake, isInCart, cartProvider),
            ),
          ),
        ),
      );
    }
  }
  
  // Helper method to build cupcake details content for both mobile and desktop
  Widget _buildCupcakeDetailsContent(Cupcake cupcake, bool isInCart, CartProvider cartProvider) {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    final bool isTablet = ResponsiveUtil.isTablet(context);
    final bool isNotebook = ResponsiveUtil.isNotebook(context);
    
    // Responsivo padding
    double padding = isMobile ? 16 : isTablet ? 20 : 24;
    double headerFontSize = isMobile ? 20 : isTablet ? 22 : 24;
    double imageHeight = isMobile ? 250 : isTablet ? 300 : isNotebook ? 350 : 400;
    
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabeçalho com título e botão de fechar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Detalhes do Cupcake',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: headerFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey.shade700 
                        : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close, 
                    size: 20,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 24),
          // Conteúdo principal
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagem
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    cupcake.imagem,
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: imageHeight,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / 
                                  loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: imageHeight,
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, size: 48, color: AppTheme.textSecondaryColor),
                              SizedBox(height: 8),
                              Text('Imagem não disponível', style: TextStyle(color: AppTheme.textSecondaryColor)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 24),
                // Informações do produto
                _buildCupcakeInfo(cupcake, isInCart, cartProvider),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagem
                Expanded(
                  flex: isTablet ? 6 : 5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      cupcake.imagem,
                      height: imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: imageHeight,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / 
                                    loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: imageHeight,
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported, size: 48, color: AppTheme.textSecondaryColor),
                                SizedBox(height: 8),
                                Text('Imagem não disponível', style: TextStyle(color: AppTheme.textSecondaryColor)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 24),
                // Informações do produto
                Expanded(
                  flex: isTablet ? 6 : 7,
                  child: _buildCupcakeInfo(cupcake, isInCart, cartProvider),
                ),
              ],
            ),
        ],
      ),
    );
  }
  
  // Helper method to build info part of cupcake details
  Widget _buildCupcakeInfo(Cupcake cupcake, bool isInCart, CartProvider cartProvider) {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    final bool isTablet = ResponsiveUtil.isTablet(context);
    
    // Tamanhos responsivos
    double titleFontSize = isMobile ? 20 : isTablet ? 24 : 28;
    double priceFontSize = isMobile ? 20 : isTablet ? 22 : 24;
    double sectionFontSize = isMobile ? 16 : isTablet ? 17 : 18;
    double descriptionFontSize = isMobile ? 13 : isTablet ? 14 : 14;
    double buttonHeight = isMobile ? 48 : 50;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nome e tags
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cupcake.nome,
              style: GoogleFonts.playfairDisplay(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cupcake.categoria == 'Premium'
                    ? const Color(0xFFF2D492)
                    : AppTheme.accentColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cupcake.categoria,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cupcake.categoria == 'Premium'
                      ? AppTheme.textPrimaryColor
                      : AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Preço
        Text(
          'R\$ ${cupcake.preco.toStringAsFixed(2)}',
          style: GoogleFonts.poppins(
            fontSize: priceFontSize,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 20),
        // Descrição
        Text(
          'Descrição',
          style: GoogleFonts.poppins(
            fontSize: sectionFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          cupcake.descricao,
          style: GoogleFonts.poppins(
            fontSize: descriptionFontSize,
            height: 1.6,
          ),
          maxLines: isMobile ? 4 : 6,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isMobile ? 20 : 24),
        // Detalhes adicionais
        Text(
          'Detalhes',
          style: GoogleFonts.poppins(
            fontSize: sectionFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        // Layout responsivo para informações
        if (isMobile)
          Column(
            children: [
              _buildInfoItem(
                icon: Icons.spa_outlined,
                title: 'Sabor',
                info: cupcake.sabor,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.category_outlined,
                      title: 'Categoria',
                      info: cupcake.categoria,
                      color: cupcake.categoria == 'Premium'
                          ? const Color(0xFFF2D492)
                          : AppTheme.accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.check_circle_outline,
                      title: 'Status',
                      info: cupcake.disponivel ? 'Disponível' : 'Indisponível',
                      color: cupcake.disponivel ? AppTheme.successColor : AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.spa_outlined,
                  title: 'Sabor',
                  info: cupcake.sabor,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.category_outlined,
                  title: 'Categoria',
                  info: cupcake.categoria,
                  color: cupcake.categoria == 'Premium'
                      ? const Color(0xFFF2D492)
                      : AppTheme.accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.check_circle_outline,
                  title: 'Status',
                  info: cupcake.disponivel ? 'Disponível' : 'Indisponível',
                  color: cupcake.disponivel ? AppTheme.successColor : AppTheme.errorColor,
                ),
              ),
            ],
          ),
        SizedBox(height: isMobile ? 24 : 32),
        // Botões de ação
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton.icon(
            onPressed: cupcake.disponivel ? () {
              if (isInCart) {
                cartProvider.removeItem(cupcake.id);
              } else {
                cartProvider.addItem(cupcake);
              }
              Navigator.pop(context);
            } : null,
            icon: Icon(
              isInCart ? Icons.remove_shopping_cart : Icons.add_shopping_cart,
              size: isMobile ? 18 : 20,
            ),
            label: Text(
              isInCart ? 'Remover do Carrinho' : 'Adicionar ao Carrinho',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isInCart ? Colors.grey.shade200 : AppTheme.primaryColor,
              foregroundColor: isInCart ? Colors.black : Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (!isInCart && cupcake.disponivel)
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: OutlinedButton.icon(
              onPressed: () {
                cartProvider.addItem(cupcake);
                setState(() {
                  _currentIndex = 1; // Vai para a página do carrinho
                });
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.shopping_bag_outlined,
                size: isMobile ? 18 : 20,
              ),
              label: Text(
                'Comprar Agora',
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: BorderSide(color: AppTheme.primaryColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildInfoItem({required IconData icon, required String title, required String info, Color? color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color?.withOpacity(0.3) ?? Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? AppTheme.primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color ?? AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  info,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color ?? Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCupcakeImage(Cupcake cupcake) {
    try {
      // Verificar se há URL de imagem
      if (cupcake.imagem.isEmpty) {
        print('⚠️ URL de imagem vazia para ${cupcake.nome}');
        return _buildPlaceholderImage();
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          cupcake.imagem,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('❌ Erro ao carregar imagem para ${cupcake.nome}: $error');
            print('🔗 URL: ${cupcake.imagem}');
            return _buildPlaceholderImage();
          },
        ),
      );
    } catch (e) {
      print('❌ Erro inesperado ao construir imagem: $e');
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [AppTheme.accentColor, AppTheme.primaryColor.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bakery_dining,
            size: 48,
            color: AppTheme.primaryColor.withOpacity(0.7),
          ),
          const SizedBox(height: 8),
          Text(
            '🧁',
            style: TextStyle(fontSize: 32),
          ),
        ],
      ),
    );
  }

  // Método para detectar URLs corrompidas - SUPER SIMPLES para MVP
  bool _isCorruptedImageUrl(String url) {
    // Apenas verifica se é uma URL válida básica
    if (url.isEmpty || url.length < 8) {
      return true;
    }
    
    // Aceita qualquer URL que comece com http
    return !url.startsWith('http');
  }

  // Verifica se a URL contém apenas caracteres ASCII válidos
  bool _isValidAsciiUrl(String url) {
    try {
      // Permite apenas caracteres ASCII padrão para URLs
      final validUrlPattern = RegExp(r'^[a-zA-Z0-9:/?#\[\]@!$&()*+,;=._~%-]+$');
      return validUrlPattern.hasMatch(url);
    } catch (e) {
      return false;
    }
  }

  // Filtra cupcakes com dados válidos
  List<Cupcake> _filterValidCupcakes(List<Cupcake> cupcakes) {
    try {
      return cupcakes.where((cupcake) {
        // Validação mais simples - apenas verifica se há nome e preço
        bool hasName = cupcake.nome.isNotEmpty;
        bool hasPrice = cupcake.preco > 0;
        bool hasCategory = cupcake.categoria.isNotEmpty;
        
        bool isValid = hasName && hasPrice && hasCategory;
        
        if (!isValid) {
          print('⚠️ Cupcake inválido filtrado: ${cupcake.nome} (nome: $hasName, preço: $hasPrice, categoria: $hasCategory)');
        }
        return isValid;
      }).toList();
    } catch (e) {
      print('❌ Erro ao filtrar cupcakes: $e');
      return cupcakes; // Retorna todos se houver erro
    }
  }

  // Verifica se os dados do cupcake são válidos
  bool _isValidCupcakeData(Cupcake cupcake) {
    try {
      // Validações básicas e simples
      return cupcake.nome.trim().isNotEmpty && 
             cupcake.categoria.trim().isNotEmpty &&
             cupcake.preco > 0;
    } catch (e) {
      print('❌ Erro ao validar dados do cupcake: $e');
      return false;
    }
  }

  // Verifica se uma string contém caracteres inválidos
  bool _containsInvalidCharacters(String text) {
    try {
      // Padrões de corrupção de dados conhecidos
      final corruptionPatterns = [
        'MoblloHloader',
        'tatfreeotion:',
        'مرeg:',
        'AAAGGIZINGABAG',
        'aqHYoUH',
        'OxIUSIUztLd',
      ];

      for (String pattern in corruptionPatterns) {
        if (text.contains(pattern)) {
          return true;
        }
      }

      // Verifica caracteres de controle ASCII
      for (int i = 0; i < text.length; i++) {
        final codeUnit = text.codeUnitAt(i);
        // Caracteres de controle (0-31) exceto tab, newline, carriage return
        if (codeUnit < 32 && codeUnit != 9 && codeUnit != 10 && codeUnit != 13) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return true; // Se há erro na verificação, considera inválido por segurança
    }
  }

  Widget _buildBannerImage() {
    try {
      final imageUrl = "https://pixabay.com/get/gaef1653b91673021505866379381025ce9d7430c10a4fce8dc16800f85d1d30d2f0ea7690276a588cfea5d026dd3e356f4bd21aba248f665f6304be3c6d3f385_1280.jpg";
      
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.transparent,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white.withOpacity(0.7),
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Erro ao carregar imagem do banner: $error');
          return Container(
            color: Colors.transparent,
            child: Icon(
              Icons.cake,
              size: 80,
              color: Colors.white.withOpacity(0.7),
            ),
          );
        },
      );
    } catch (e) {
      print('Erro na geração da URL do banner: $e');
      return Container(
        color: Colors.transparent,
        child: Icon(
          Icons.cake,
          size: 80,
          color: Colors.white.withOpacity(0.7),
        ),
      );
    }
  }
  
  // Método para construir a tela principal de showcase
  Widget _buildShowcaseScreen() {
    try {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header para dispositivos móveis
            if (ResponsiveUtil.isMobile(context)) 
              _buildSafeWidget(() => _buildMobileHeader(), 'MobileHeader'),
            
            // Banner principal
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildSafeWidget(() => _buildMainBanner(), 'MainBanner'),
              ),
            ),
            
            // Seção de categorias
            FadeTransition(
              opacity: _fadeAnimation,
              child: _buildSafeWidget(() => _buildCategoriesSection(), 'CategoriesSection'),
            ),
            
            // Grid de cupcakes
            FadeTransition(
              opacity: _fadeAnimation,
              child: _buildSafeWidget(() => _buildCupcakesGrid(), 'CupcakesGrid'),
            ),
            
            // Diferenciais - Movido para depois dos cupcakes
            FadeTransition(
              opacity: _fadeAnimation,
              child: _buildSafeWidget(() => _buildFeaturesSection(), 'FeaturesSection'),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      );
    } catch (e, stackTrace) {
      // Log do erro para debugging
      print('=== ERRO NO SHOWCASE ===');
      print('Erro: $e');
      print('Tipo: ${e.runtimeType}');
      print('StackTrace: $stackTrace');
      print('========================');
      
      return Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro no Showcase',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Erro técnico: ${e.toString()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.errorColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          // Força uma reconstrução completa
                        });
                      }
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                    child: const Text('Reiniciar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  // Método auxiliar para executar widgets de forma segura
  Widget _buildSafeWidget(Widget Function() builder, String componentName) {
    try {
      return builder();
    } catch (e, stackTrace) {
      // Log detalhado para diferentes tipos de erro
      print('=== ERRO EM $componentName ===');
      print('Erro: $e');
      print('Tipo: ${e.runtimeType}');
      
      // Detecção específica de FormatException
      if (e is FormatException) {
        print('FORMATO DE DADOS CORROMPIDO:');
        print('Mensagem: ${e.message}');
        print('Fonte: ${e.source}');
        print('Offset: ${e.offset}');
      }
      
      print('StackTrace: $stackTrace');
      print('==============================');
      
      // UI específica para diferentes tipos de erro
      String errorTitle = 'Erro em $componentName';
      String errorMessage = 'Erro técnico';
      IconData errorIcon = Icons.warning_amber;
      
      if (e is FormatException) {
        errorTitle = 'Dados Corrompidos';
        errorMessage = 'Dados inválidos detectados';
        errorIcon = Icons.data_usage_outlined;
      } else if (e.toString().contains('MoblloHloader') || 
                 e.toString().contains('tatfreeotion:') ||
                 e.toString().contains('مرeg:')) {
        errorTitle = 'Dados Corrompidos';
        errorMessage = 'Formato de imagem inválido';
        errorIcon = Icons.broken_image;
      }
      
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              errorIcon,
              color: AppTheme.errorColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              errorTitle,
              style: TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              errorMessage,
              style: TextStyle(
                color: AppTheme.errorColor,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                if (mounted) {
                  setState(() {
                    // Força reconstrução do componente específico
                  });
                }
              },
              child: Text(
                'Tentar Novamente',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

// Widget auxiliar para chips de categoria
class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryColor 
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected 
                  ? AppTheme.primaryColor 
                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ] : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected 
                  ? Colors.white 
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }
}
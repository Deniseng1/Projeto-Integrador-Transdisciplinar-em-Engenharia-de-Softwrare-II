import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/data_initialization_service.dart';
import '../services/firebase_service.dart';
import '../theme.dart';
import '../utils/responsive_util.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  final DataInitializationService _dataService = DataInitializationService();
  final FirebaseService _firebaseService = FirebaseService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = false;
  String _statusMessage = '';
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _createExampleCupcakes() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Criando cupcakes de exemplo...';
    });
    
    try {
      await _dataService.initializeCupcakes();
      _showSnackBar('Cupcakes de exemplo criados com sucesso!', Colors.green);
      setState(() {
        _statusMessage = 'Cupcakes de exemplo criados! 🧁✨';
      });
    } catch (e) {
      _showSnackBar('Erro ao criar cupcakes: $e', Colors.red);
      setState(() {
        _statusMessage = 'Erro ao criar cupcakes ❌';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _recreateCupcakes() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Recriando cupcakes...';
    });
    
    try {
      await _dataService.recreateCupcakes();
      _showSnackBar('Cupcakes recriados com sucesso!', Colors.green);
      setState(() {
        _statusMessage = 'Cupcakes recriados com sucesso! 🎉';
      });
    } catch (e) {
      _showSnackBar('Erro ao recriar cupcakes: $e', Colors.red);
      setState(() {
        _statusMessage = 'Erro ao recriar cupcakes ❌';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }  
  Future<void> _addMoreCupcakes(String categoria) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Adicionando mais cupcakes à categoria $categoria...';
    });
    
    try {
      await _dataService.addMoreCupcakesToCategory(categoria, 4);
      setState(() {
        _statusMessage = '4 cupcakes adicionados à categoria $categoria com sucesso!';
      });
      _showSnackBar('Cupcakes adicionados com sucesso!', Colors.green);
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro ao adicionar cupcakes: $e';
      });
      _showSnackBar('Erro ao adicionar cupcakes', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Administração',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ResponsiveUtil.wrapWithMaxWidth(
          SingleChildScrollView(
            padding: ResponsiveUtil.getPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 24),
                _buildActionCard('🧁 CRIAR CUPCAKES DE EXEMPLO', 
                  'Força a criação dos 8 cupcakes iniciais se não existirem (4 Clássicos + 4 Premium)',
                  Icons.bakery_dining,
                  () => _createExampleCupcakes(),
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                _buildActionCard('Recriar Todos os Cupcakes', 
                  'Remove todos os cupcakes existentes e cria 8 novos (4 de cada categoria)',
                  Icons.refresh,
                  () => _showConfirmDialog(_recreateCupcakes, 'Tem certeza que deseja recriar todos os cupcakes?'),
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildActionCard('Adicionar Cupcakes Clássicos', 
                  'Adiciona 4 novos cupcakes à categoria Clássicos',
                  Icons.add_circle,
                  () => _addMoreCupcakes('Clássicos'),
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 16),
                _buildActionCard('Adicionar Cupcakes Premium', 
                  'Adiciona 4 novos cupcakes à categoria Premium',
                  Icons.add_circle,
                  () => _addMoreCupcakes('Premium'),
                  color: AppTheme.secondaryColor,
                ),
                const SizedBox(height: 24),
                _buildStatusCard(),
                const SizedBox(height: 24),
                _buildInfoCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.admin_panel_settings,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Painel Administrativo',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gerencie os cupcakes do aplicativo',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionCard(String title, String description, IconData icon, VoidCallback onTap, {Color? color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (color ?? AppTheme.primaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color ?? AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading) 
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.textSecondaryColor,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusCard() {
    if (_statusMessage.isEmpty) return const SizedBox.shrink();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Status',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _statusMessage,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: AppTheme.secondaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Informações',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem('🧁 CUPCAKES DE EXEMPLO INCLUEM:'),
            _buildInfoItem('📍 Clássicos: Chocolate Supremo, Baunilha, Morango, Coco'),
            _buildInfoItem('📍 Premium: Trufa Belga, Macarons Francês, Red Velvet, Lavanda'),
            _buildInfoItem('💰 Preços: Clássicos (R\$ 7,50-9,00) | Premium (R\$ 14,00-17,50)'),
            _buildInfoItem('🖼️ Imagens: Geradas automaticamente com segurança'),
            _buildInfoItem('💾 Dados: Armazenados no Firebase Firestore'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: AppTheme.textSecondaryColor,
        ),
      ),
    );
  }
  
  void _showConfirmDialog(VoidCallback onConfirm, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirmação',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/data_cleanup_service.dart';
import '../theme.dart';
import '../utils/responsive_util.dart';

class DataRecoveryScreen extends StatefulWidget {
  const DataRecoveryScreen({Key? key}) : super(key: key);

  @override
  State<DataRecoveryScreen> createState() => _DataRecoveryScreenState();
}

class _DataRecoveryScreenState extends State<DataRecoveryScreen> with SingleTickerProviderStateMixin {
  final DataCleanupService _cleanupService = DataCleanupService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isScanning = false;
  bool _isFixing = false;
  Map<String, int> _corruptionStats = {};
  String _lastScanTime = '';
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _scanForCorruption() async {
    setState(() {
      _isScanning = true;
      _corruptionStats.clear();
    });
    
    try {
      final stats = await _cleanupService.scanForCorruption();
      setState(() {
        _corruptionStats = stats;
        _lastScanTime = DateTime.now().toString().substring(0, 19);
      });
      
      _showSnackBar(
        'Verificação concluída. ${stats["corrupted_user_profiles"]! + stats["corrupted_cupcake_images"]!} problemas encontrados.',
        Colors.blue,
      );
    } catch (e) {
      _showSnackBar('Erro durante a verificação: $e', Colors.red);
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }
  
  Future<void> _fixCurrentUserProfile() async {
    setState(() {
      _isFixing = true;
    });
    
    try {
      final fixed = await _cleanupService.cleanupCurrentUserProfilePicture();
      if (fixed) {
        _showSnackBar('Foto de perfil corrigida com sucesso!', Colors.green);
      } else {
        _showSnackBar('Nenhum problema encontrado na foto de perfil.', Colors.blue);
      }
    } catch (e) {
      _showSnackBar('Erro ao corrigir foto de perfil: $e', Colors.red);
    } finally {
      setState(() {
        _isFixing = false;
      });
    }
  }
  
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Recuperação de Dados',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.primaryColor),
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
                _buildQuickFixCard(),
                const SizedBox(height: 24),
                _buildScanCard(),
                if (_corruptionStats.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildResultsCard(),
                ],
                const SizedBox(height: 24),
                _buildTipsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: AppTheme.primaryGradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.healing,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              'Ferramenta de Recuperação',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Esta ferramenta identifica e corrige problemas com dados corrompidos em sua conta.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickFixCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Correção Rápida',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Corrige automaticamente problemas na sua foto de perfil.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isFixing ? null : _fixCurrentUserProfile,
                icon: _isFixing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.auto_fix_high),
                label: Text(_isFixing ? 'Corrigindo...' : 'Corrigir Meu Perfil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildScanCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.search,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Verificação Completa',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Verifica todos os dados em busca de corrupção e fornece estatísticas detalhadas.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            if (_lastScanTime.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Última verificação: $_lastScanTime',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isScanning ? null : _scanForCorruption,
                icon: _isScanning
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                      )
                    : Icon(Icons.scanner),
                label: Text(_isScanning ? 'Verificando...' : 'Iniciar Verificação'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResultsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assessment,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resultados da Verificação',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ..._corruptionStats.entries.map((entry) => _buildStatItem(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String key, int value) {
    IconData icon;
    Color color;
    String label;
    
    switch (key) {
      case 'corrupted_user_profiles':
        icon = Icons.person_off;
        color = value > 0 ? Colors.red : Colors.green;
        label = 'Perfis com problemas';
        break;
      case 'corrupted_cupcake_images':
        icon = Icons.broken_image;
        color = value > 0 ? Colors.red : Colors.green;
        label = 'Imagens de produtos com problemas';
        break;
      case 'total_users_scanned':
        icon = Icons.people;
        color = Colors.blue;
        label = 'Usuários verificados';
        break;
      case 'total_cupcakes_scanned':
        icon = Icons.cake;
        color = Colors.blue;
        label = 'Produtos verificados';
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
        label = key;
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                Text(
                  value.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTipsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: AppTheme.warningColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Dicas de Prevenção',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._tips.map((tip) => _buildTipItem(tip)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  static const List<String> _tips = [
    'Sempre use imagens de boa qualidade para o seu perfil',
    'Evite editar dados diretamente no banco de dados',
    'Mantenha o aplicativo atualizado para as correções mais recentes',
    'Em caso de problemas persistentes, use a correção rápida',
    'Faça verificações regulares se notar comportamentos estranhos',
  ];
}
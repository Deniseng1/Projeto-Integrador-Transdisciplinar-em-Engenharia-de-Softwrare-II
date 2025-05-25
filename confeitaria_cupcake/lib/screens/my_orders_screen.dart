import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_models.dart';
import '../services/firebase_service.dart';
import '../theme.dart';
import '../utils/responsive_util.dart';
import 'home_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pendente':
        return AppTheme.warningColor;
      case 'confirmado':
        return AppTheme.infoColor;
      case 'entregue':
        return AppTheme.successColor;
      case 'cancelado':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pendente':
        return Icons.access_time;
      case 'confirmado':
        return Icons.directions_bike;
      case 'entregue':
        return Icons.check_circle;
      case 'cancelado':
        return Icons.cancel;
      default:
        return Icons.receipt_long;
    }
  }

  String _formatOrderStatus(String status) {
    switch (status) {
      case 'pendente':
        return 'Pendente';
      case 'confirmado':
        return 'A caminho';
      case 'entregue':
        return 'Entregue';
      case 'cancelado':
        return 'Cancelado';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showOrderDetails(BuildContext context, Pedido order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOrderDetailsSheet(context, order),
    );
  }

  Widget _buildOrderDetailsSheet(BuildContext context, Pedido order) {
    return ResponsiveUtil.wrapWithMaxWidth(
      Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho com status e botão para fechar
            Container(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botão para fechar e número do pedido
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pedido #${order.id.substring(0, 6).toUpperCase()}',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveUtil.getFontSize(context, 16),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // Status e data
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(order.status),
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              _formatOrderStatus(order.status),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        _formatDate(order.dataHora),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Conteúdo do pedido
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Itens do pedido
                    Text(
                      'Itens do Pedido',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtil.getFontSize(context, 18),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    // Lista de itens
                    ...order.itens.map((item) => _buildOrderItemCard(item)).toList(),
                    
                    Divider(height: 40, thickness: 1),
                    
                    // Resumo do pedido
                    Text(
                      'Resumo',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtil.getFontSize(context, 18),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Subtotal e entrega
                    _buildOrderSummaryItem(
                      'Subtotal',
                      'R\$ ${order.total.toStringAsFixed(2)}',
                    ),
                    _buildOrderSummaryItem(
                      'Taxa de entrega',
                      'Grátis',
                      valueColor: AppTheme.successColor,
                    ),
                    _buildOrderSummaryItem(
                      'Total',
                      'R\$ ${order.total.toStringAsFixed(2)}',
                      isTotal: true,
                      valueColor: AppTheme.primaryColor,
                    ),
                    
                    Divider(height: 40, thickness: 1),
                    
                    // Informações de pagamento e entrega
                    Text(
                      'Informações',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtil.getFontSize(context, 18),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Forma de pagamento
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            order.formaPagamento == 'pix'
                                ? Icons.qr_code
                                : order.formaPagamento == 'cartão'
                                    ? Icons.credit_card
                                    : Icons.payments,
                            size: 24,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Forma de Pagamento',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              order.formaPagamento.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Endereço de entrega
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.location_on,
                            size: 24,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Endereço de Entrega',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                order.endereco ?? 'Não informado',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 40),
                    
                    // Avaliação (apenas para pedidos entregues)
                    if (order.status == 'entregue')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Avaliação',
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveUtil.getFontSize(context, 18),
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          // Exibir avaliação existente ou formulário para avaliar
                          order.avaliacao != null
                              ? Row(
                                  children: [
                                    RatingBar.builder(
                                      initialRating: order.avaliacao!,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemSize: 28,
                                      ignoreGestures: true,
                                      itemBuilder: (context, _) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (_) {},
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      order.avaliacao!.toStringAsFixed(1),
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Como foi sua experiência com este pedido?',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    // Widget de avaliação interativo
                                    Center(
                                      child: Column(
                                        children: [
                                          RatingBar.builder(
                                            initialRating: _currentRating ?? 0,
                                            minRating: 0.5,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemSize: 40,
                                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: _ratingColor,
                                            ),
                                            onRatingUpdate: (rating) {
                                              setState(() {
                                                _currentRating = rating;
                                                // Mudar a cor baseado na avaliação
                                                if (rating <= 2) {
                                                  _ratingColor = AppTheme.errorColor;
                                                } else if (rating <= 3.5) {
                                                  _ratingColor = AppTheme.warningColor;
                                                } else {
                                                  _ratingColor = Colors.amber;
                                                }
                                              });
                                            },
                                          ),
                                          SizedBox(height: 20),
                                          // Botão para enviar avaliação
                                          ElevatedButton(
                                            onPressed: _currentRating != null && _currentRating! > 0
                                                ? () => _rateOrder(order.id, _currentRating!)
                                                : () {
                                                    // Garante que pelo menos 1 estrela seja selecionada
                                                    setState(() {
                                                      _currentRating = _currentRating ?? 1.0;
                                                    });
                                                    _rateOrder(order.id, _currentRating!);
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme.primaryColor,
                                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30),
                                              ),
                                            ),
                                            child: Text(
                                              'Enviar Avaliação',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ],
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

  // Variável para controlar a animação de avaliação
  double? _currentRating;
  Color _ratingColor = Colors.amber;

  Future<void> _rateOrder(String orderId, double rating) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      await _firebaseService.rateOrder(orderId, rating);
      
      // Feedback visual
      Navigator.pop(context); // Fechar modal
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.star, color: Colors.white),
              SizedBox(width: 10),
              Text('Obrigado pela sua avaliação!'),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      
      // Atualizar a interface
      HapticFeedback.mediumImpact(); // Feedback tátil
      
    } catch (e) {
      print('Erro ao avaliar pedido: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar avaliação. Tente novamente.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _currentRating = null;
      });
    }
  }

  Widget _buildOrderItemCard(Map<String, dynamic> item) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Imagem do produto
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['imagem'] as String? ?? '',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: AppTheme.accentColor.withOpacity(0.3),
                  child: Icon(Icons.cake, color: AppTheme.primaryColor),
                ),
              ),
            ),
            SizedBox(width: 12),
            // Detalhes do item
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['nome'] as String? ?? 'Item',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'R\$ ${(item['preco'] as num? ?? 0).toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            // Quantidade e subtotal
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${item['quantidade'] as int? ?? 1}x',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'R\$ ${(item['subtotal'] as num? ?? 0).toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen())),
        ),
        title: Text(
          'Meus Pedidos',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryColor,
                fontSize: ResponsiveUtil.isMobile(context) ? 20 : 
                         ResponsiveUtil.isTablet(context) ? 22 : 
                         ResponsiveUtil.isNotebook(context) ? 24 : 26,
              ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ResponsiveUtil.wrapWithMaxWidth(
        StreamBuilder<List<Pedido>>(
          stream: _firebaseService.getUserOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppTheme.errorColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Erro ao carregar pedidos',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }

            final orders = snapshot.data ?? [];

            if (orders.isEmpty) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: AppTheme.primaryColor.withOpacity(0.5),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Nenhum pedido ainda',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Seus pedidos aparecerão aqui',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildOrderCard(order),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(Pedido order) {
    // Calcular o total de itens no pedido
    final totalItems = order.itens.fold<int>(
        0, (sum, item) => sum + (item['quantidade'] as int? ?? 1));

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: AppTheme.primaryColor.withOpacity(0.1),
      child: InkWell(
        onTap: () => _showOrderDetails(context, order),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Cabeçalho com número e data do pedido
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Número do pedido
                  Text(
                    '#${order.id.substring(0, 6).toUpperCase()}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  // Data
                  Text(
                    _formatDate(order.dataHora),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              
              // Detalhes do pedido
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagem representativa do primeiro item
                  if (order.itens.isNotEmpty && order.itens.first['imagem'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        order.itens.first['imagem'] as String,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 70,
                          height: 70,
                          color: AppTheme.accentColor.withOpacity(0.3),
                          child: Icon(Icons.cake, color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                  SizedBox(width: 12),
                  
                  // Resumo do pedido
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quantidade de itens
                        Text(
                          totalItems == 1 ? '1 item' : '$totalItems itens',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        // Valor total
                        Text(
                          'R\$ ${order.total.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        // Forma de pagamento
                        Row(
                          children: [
                            Icon(
                              order.formaPagamento == 'pix'
                                  ? Icons.qr_code
                                  : order.formaPagamento == 'cartão'
                                      ? Icons.credit_card
                                      : Icons.payments,
                              size: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                            SizedBox(width: 4),
                            Text(
                              order.formaPagamento.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Status do pedido
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        _getStatusIcon(order.status),
                        color: _getStatusColor(order.status),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              Divider(height: 1),
              SizedBox(height: 16),
              
              // Barra de status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Texto de status
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        _formatOrderStatus(order.status),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(order.status),
                        ),
                      ),
                    ],
                  ),
                  
                  // Botão de avaliação para pedidos entregues
                  if (order.status == 'entregue')
                    Row(
                      children: [
                        if (order.avaliacao != null)
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                order.avaliacao!.toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          )
                        else
                          OutlinedButton(
                            onPressed: () => _showOrderDetails(context, order),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: BorderSide(color: AppTheme.primaryColor),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              textStyle: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            child: Text('Avaliar'),
                          ),
                      ],
                    ),
                    
                  // Botão para ver detalhes
                  if (order.status != 'entregue' || order.avaliacao != null)
                    OutlinedButton(
                      onPressed: () => _showOrderDetails(context, order),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: BorderSide(color: AppTheme.primaryColor),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        textStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      child: Text('Detalhes'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummaryItem(String label, String value,
      {Color? valueColor, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? (isTotal ? AppTheme.primaryColor : AppTheme.textPrimaryColor),
            ),
          ),
        ],
      ),
    );
  }

  // Variável para controlar estado de carregamento
  bool _isLoading = false;
}
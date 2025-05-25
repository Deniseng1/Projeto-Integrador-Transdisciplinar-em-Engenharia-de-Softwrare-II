import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../services/firebase_service.dart';
import '../services/cart_provider.dart';
import '../theme.dart';
import '../utils/responsive_util.dart';
import 'my_orders_screen.dart';
import 'home_screen.dart';

class CartPaymentScreen extends StatefulWidget {
  const CartPaymentScreen({Key? key}) : super(key: key);

  @override
  State<CartPaymentScreen> createState() => _CartPaymentScreenState();
}

class _CartPaymentScreenState extends State<CartPaymentScreen> with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isCheckout = false;
  UserModel? _userData;
  late TabController _tabController;
  
  String _selectedPaymentMethod = 'cartão';
  final _enderecoController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  bool _needsChange = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _enderecoController.dispose();
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserData() async {
    final userData = await _firebaseService.getUserData();
    if (mounted) {
      setState(() {
        _userData = userData;
        if (userData?.endereco != null && userData!.endereco!.isNotEmpty) {
          _enderecoController.text = userData.endereco!;
        }
      });
    }
  }
  
  void _startCheckout() {
    if (Provider.of<CartProvider>(context, listen: false).items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seu carrinho está vazio'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }
    
    setState(() {
      _isCheckout = true;
    });
  }
  
  void _cancelCheckout() {
    setState(() {
      _isCheckout = false;
    });
  }
  
  Future<void> _completeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      
      if (cartProvider.items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Seu carrinho está vazio'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      final orderId = await cartProvider.checkout(
        _selectedPaymentMethod,
        _enderecoController.text.trim(),
      );
      
      setState(() {
        _isLoading = false;
        _isCheckout = false;
      });
      
      if (mounted) {
        // Exibir mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pedido realizado com sucesso!'),
            backgroundColor: AppTheme.successColor,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Navegar para a tela de pedidos
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyOrdersScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao finalizar pedido: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  Future<void> _clearCart() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Limpar carrinho'),
        content: Text('Tem certeza que deseja remover todos os itens do carrinho?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Provider.of<CartProvider>(context, listen: false).clearCart();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Carrinho esvaziado com sucesso'),
                  backgroundColor: AppTheme.infoColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Limpar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items;
    final cartItemCount = cartProvider.itemCount;
    final cartTotal = cartProvider.total;
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: ResponsiveUtil.wrapWithMaxWidth(
          _isCheckout ? _buildCheckoutScreen(cartTotal) : _buildCartScreen(cartItems, cartItemCount, cartTotal),
        ),
      ),
    );
  }
  
  Widget _buildCartScreen(List<CartItem> cartItems, int cartItemCount, double cartTotal) {
    final bool isNotebook = ResponsiveUtil.isNotebook(context);
    final bool isDesktop = ResponsiveUtil.isDesktop(context);
    
    return Column(
      children: [
        // Cabeçalho
        Padding(
          padding: EdgeInsets.all(isNotebook || isDesktop ? 24.0 : 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meu Carrinho',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                      fontSize: ResponsiveUtil.isMobile(context) ? 20 : 
                               ResponsiveUtil.isTablet(context) ? 22 : 
                               ResponsiveUtil.isNotebook(context) ? 24 : 26,
                    ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Navegar para a tela Home (índice 0)
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                    icon: Icon(Icons.cake_outlined, color: AppTheme.primaryColor),
                    label: Text('Ver Cupcakes'),
                  ),
                  if (cartItems.isNotEmpty)
                    TextButton.icon(
                      onPressed: _clearCart,
                      icon: Icon(Icons.delete_outline, color: AppTheme.errorColor),
                      label: Text(
                        'Limpar',
                        style: TextStyle(color: AppTheme.errorColor),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        
        // Lista de itens ou mensagem de carrinho vazio
        Expanded(
          child: cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: AppTheme.textSecondaryColor.withOpacity(0.5),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Seu carrinho está vazio',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Adicione cupcakes deliciosos à sua cesta',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondaryColor.withOpacity(0.7),
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        transform: Matrix4.translationValues(0, 0, 0)..scale(1.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navegar para a tela Home (índice 0)
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => HomeScreen()),
                              (route) => false,
                            );
                          },
                          icon: Icon(Icons.cake, color: Colors.white),
                          label: Text('Ver cupcakes', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            elevation: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: 100),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return _buildCartItem(item);
                  },
                ),
        ),
        
        // Barra inferior com total e botão de finalizar
        if (cartItems.isNotEmpty)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Resumo do pedido
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        'R\$ ${cartTotal.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Taxa de entrega',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'GRÁTIS',
                        style: TextStyle(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'R\$ ${cartTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  // Botão finalizar pedido
                  ElevatedButton(
                    onPressed: _startCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Finalizar Pedido',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildCartItem(CartItem item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    return Dismissible(
      key: ValueKey(item.cupcake.id),
      background: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        color: AppTheme.errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Remover item'),
            content: Text('Deseja remover ${item.cupcake.nome} do carrinho?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  foregroundColor: Colors.white,
                ),
                child: Text('Remover'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        cartProvider.removeItem(item.cupcake.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.cupcake.nome} removido do carrinho'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.infoColor,
            action: SnackBarAction(
              label: 'DESFAZER',
              textColor: Colors.white,
              onPressed: () {
                cartProvider.addItem(item.cupcake);
              },
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Imagem
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.cupcake.imagem,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16),
              
              // Informações
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.cupcake.nome,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'R\$ ${item.cupcake.preco.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sabor: ${item.cupcake.sabor}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              
              // Controles de quantidade
              Row(
                children: [
                  // Botão de diminuir
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: item.quantidade > 1 ? AppTheme.accentColor : Colors.grey.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 16,
                      icon: Icon(
                        Icons.remove,
                        color: item.quantidade > 1 ? AppTheme.primaryColor : Colors.grey,
                      ),
                      onPressed: item.quantidade > 1
                          ? () => cartProvider.decreaseQuantity(item.cupcake.id)
                          : null,
                    ),
                  ),
                  
                  // Quantidade
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '${item.quantidade}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  
                  // Botão de aumentar
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 16,
                      icon: Icon(
                        Icons.add,
                        color: AppTheme.primaryColor,
                      ),
                      onPressed: () => cartProvider.increaseQuantity(item.cupcake.id),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCheckoutScreen(double cartTotal) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 100),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: _cancelCheckout,
                      color: AppTheme.primaryColor,
                    ),
                    Text(
                      'Finalizar Pedido',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                  ],
                ),
                
                // Endereço de entrega
                Card(
                  margin: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, color: AppTheme.primaryColor),
                            SizedBox(width: 8),
                            Text(
                              'Endereço de Entrega',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _enderecoController,
                          decoration: InputDecoration(
                            labelText: 'Endereço completo',
                            hintText: 'Rua, número, bairro, cidade, CEP',
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, informe o endereço de entrega';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Contato com a loja
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.support_agent, color: AppTheme.primaryColor),
                            SizedBox(width: 8),
                            Text(
                              'Contato com a Loja',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        _buildContactItem(Icons.phone, 'Telefone', '(11) 98765-4321'),
                        SizedBox(height: 8),
                        _buildContactItem(
                          Icons.chat,
                          'WhatsApp',
                          '(11) 98765-4321',
                          showButton: true,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Forma de pagamento
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.payment, color: AppTheme.primaryColor),
                            SizedBox(width: 8),
                            Text(
                              'Forma de Pagamento',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        
                        // Abas para métodos de pagamento
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.black.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: AppTheme.primaryColor,
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: AppTheme.textSecondaryColor,
                            tabs: [
                              Tab(text: 'Cartão'),
                              Tab(text: 'Pix'),
                              Tab(text: 'Dinheiro'),
                            ],
                            onTap: (index) {
                              setState(() {
                                _selectedPaymentMethod = index == 0
                                    ? 'cartão'
                                    : index == 1
                                        ? 'pix'
                                        : 'dinheiro';
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 24),
                        
                        // Conteúdo das abas de pagamento
                        SizedBox(
                          height: _selectedPaymentMethod == 'cartão' ? 280 : 200,
                          child: TabBarView(
                            controller: _tabController,
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              // 1. Cartão
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _cardNumberController,
                                    decoration: InputDecoration(
                                      labelText: 'Número do cartão',
                                      prefixIcon: Icon(Icons.credit_card),
                                      hintText: '0000 0000 0000 0000',
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: _selectedPaymentMethod == 'cartão'
                                        ? (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return 'Informe o número do cartão';
                                            }
                                            return null;
                                          }
                                        : null,
                                  ),
                                  SizedBox(height: 16),
                                  TextFormField(
                                    controller: _cardNameController,
                                    decoration: InputDecoration(
                                      labelText: 'Nome impresso no cartão',
                                      prefixIcon: Icon(Icons.person_outline),
                                    ),
                                    textCapitalization: TextCapitalization.characters,
                                    validator: _selectedPaymentMethod == 'cartão'
                                        ? (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return 'Informe o nome no cartão';
                                            }
                                            return null;
                                          }
                                        : null,
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _cardExpiryController,
                                          decoration: InputDecoration(
                                            labelText: 'Validade',
                                            hintText: 'MM/AA',
                                          ),
                                          validator: _selectedPaymentMethod == 'cartão'
                                              ? (value) {
                                                  if (value == null || value.trim().isEmpty) {
                                                    return 'Informe a validade';
                                                  }
                                                  return null;
                                                }
                                              : null,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _cardCvvController,
                                          decoration: InputDecoration(
                                            labelText: 'CVV',
                                            hintText: '123',
                                          ),
                                          obscureText: true,
                                          validator: _selectedPaymentMethod == 'cartão'
                                              ? (value) {
                                                  if (value == null || value.trim().isEmpty) {
                                                    return 'Informe o CVV';
                                                  }
                                                  return null;
                                                }
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              
                              // 2. Pix
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.qr_code_2,
                                          size: 100,
                                          color: AppTheme.primaryColor,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'QR Code Pix',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Pague com Pix',
                                          style: TextStyle(
                                            color: AppTheme.textSecondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              // 3. Dinheiro
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Preciso de troco',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      Spacer(),
                                      Switch(
                                        value: _needsChange,
                                        onChanged: (value) {
                                          setState(() {
                                            _needsChange = value;
                                          });
                                        },
                                        activeColor: AppTheme.primaryColor,
                                      ),
                                    ],
                                  ),
                                  if (_needsChange) ...[  
                                    SizedBox(height: 16),
                                    Text(
                                      'Por favor tenha troco para R\$ 100,00',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: 16),
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.warningColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.warningColor.withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: AppTheme.warningColor,
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            'O pagamento será realizado na entrega',
                                            style: TextStyle(
                                              color: AppTheme.warningColor.withOpacity(0.8),
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
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Resumo do pedido
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.receipt, color: AppTheme.primaryColor),
                            SizedBox(width: 8),
                            Text(
                              'Resumo do Pedido',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        _buildOrderSummaryItem('Subtotal', 'R\$ ${cartTotal.toStringAsFixed(2)}'),
                        SizedBox(height: 8),
                        _buildOrderSummaryItem(
                          'Taxa de entrega',
                          'GRÁTIS',
                          valueColor: AppTheme.successColor,
                        ),
                        Divider(height: 24),
                        _buildOrderSummaryItem(
                          'Total',
                          'R\$ ${cartTotal.toStringAsFixed(2)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 100), // Espaço para o botão fixo no fundo
              ],
            ),
          ),
        ),
        
        // Botão fixo na parte inferior
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _completeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
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
                    : Text(
                        'Confirmar Pedido',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildContactItem(IconData icon, String label, String value,
      {bool showButton = false}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
            SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        Spacer(),
        if (showButton)
          OutlinedButton.icon(
            onPressed: () {
              // Aqui seria implementada a ação para abrir o WhatsApp
            },
            icon: Icon(Icons.chat, color: AppTheme.secondaryColor),
            label: Text(
              'Conversar',
              style: TextStyle(color: AppTheme.secondaryColor),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.secondaryColor),
            ),
          ),
      ],
    );
  }
  
  Widget _buildOrderSummaryItem(String label, String value,
      {Color? valueColor, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
              : Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? (isTotal ? AppTheme.primaryColor : null),
            fontWeight: isTotal ? FontWeight.bold : null,
            fontSize: isTotal ? 18 : null,
          ),
        ),
      ],
    );
  }
}
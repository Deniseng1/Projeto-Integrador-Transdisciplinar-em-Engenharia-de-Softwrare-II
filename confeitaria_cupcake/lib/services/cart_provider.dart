import 'package:flutter/foundation.dart';
import '../models/app_models.dart';
import 'firebase_service.dart';

class CartProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<CartItem> _items = [];

  List<CartItem> get items => _items;
  
  // Total de itens no carrinho
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantidade);
  
  // Valor total do carrinho
  double get total => _items.fold(0, (sum, item) => sum + item.subtotal);
  
  // Verificar se cupcake já está no carrinho
  bool isInCart(String cupcakeId) {
    return _items.any((item) => item.cupcake.id == cupcakeId);
  }
  
  // Adicionar cupcake ao carrinho
  void addItem(Cupcake cupcake) {
    // Verificar se o cupcake já está no carrinho
    int index = _items.indexWhere((item) => item.cupcake.id == cupcake.id);
    
    if (index >= 0) {
      // Se já existir, incrementa a quantidade
      _items[index].quantidade += 1;
    } else {
      // Se não existir, adiciona um novo item
      _items.add(CartItem(cupcake: cupcake, quantidade: 1));
    }
    
    // Salvar carrinho localmente
    _firebaseService.saveCart(_items);
    notifyListeners();
  }
  
  // Remover item do carrinho
  void removeItem(String cupcakeId) {
    _items.removeWhere((item) => item.cupcake.id == cupcakeId);
    
    // Salvar carrinho localmente
    _firebaseService.saveCart(_items);
    notifyListeners();
  }
  
  // Reduzir quantidade de um item
  void decreaseQuantity(String cupcakeId) {
    int index = _items.indexWhere((item) => item.cupcake.id == cupcakeId);
    
    if (index >= 0) {
      if (_items[index].quantidade > 1) {
        // Reduz a quantidade se for maior que 1
        _items[index].quantidade -= 1;
      } else {
        // Remove o item se a quantidade for 1
        _items.removeAt(index);
      }
      
      // Salvar carrinho localmente
      _firebaseService.saveCart(_items);
      notifyListeners();
    }
  }
  
  // Aumentar quantidade de um item
  void increaseQuantity(String cupcakeId) {
    int index = _items.indexWhere((item) => item.cupcake.id == cupcakeId);
    
    if (index >= 0) {
      _items[index].quantidade += 1;
      
      // Salvar carrinho localmente
      _firebaseService.saveCart(_items);
      notifyListeners();
    }
  }
  
  // Limpar carrinho
  void clearCart() {
    _items = [];
    
    // Salvar carrinho localmente
    _firebaseService.saveCart(_items);
    notifyListeners();
  }
  
  // Finalizar pedido
  Future<String> checkout(String formaPagamento, String? endereco) async {
    if (_items.isEmpty) {
      throw Exception('Carrinho vazio');
    }
    
    String orderId = await _firebaseService.createOrder(
      cartItems: _items,
      total: total,
      formaPagamento: formaPagamento,
      endereco: endereco,
    );
    
    // Limpar o carrinho após finalizar o pedido
    clearCart();
    
    return orderId;
  }
}
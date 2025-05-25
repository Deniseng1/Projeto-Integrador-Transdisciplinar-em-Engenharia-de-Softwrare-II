import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';
import '../utils/image_validator.dart';
import 'data_cleanup_service.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Autenticação
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Registrar novo usuário
  Future<UserCredential> registrar(String email, String senha, String nome) async {
    try {
      // Criar usuário no Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      
      // Adicionar informações no Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'nome': nome,
        'email': email,
        'telefone': null,
        'endereco': null,
        'fotoPerfil': null,
        'dataCriacao': FieldValue.serverTimestamp(),
      });
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Login
  Future<UserCredential> login(String email, String senha) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Limpar informações salvas no dispositivo
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cart');
      
      // Deslogar do Firebase
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Recuperar senha
  Future<void> recuperarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Obter dados do usuário atual
  Future<UserModel?> getUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists && doc.data() != null) {
        final userData = UserModel.fromMap(doc.data()!);
        
        // Validate profile picture and fix if corrupted
        if (userData.fotoPerfil != null) {
          if (ImageValidator.isCorruptedImageData(userData.fotoPerfil!)) {
            // Auto-cleanup corrupted profile picture
            final cleanupService = DataCleanupService();
            await cleanupService.cleanupCurrentUserProfilePicture();
            
            // Return user data without the corrupted picture
            return userData.copyWith(fotoPerfil: null);
          }
        }
        
        return userData;
      }
      
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      // Try to recover with cleanup
      try {
        final cleanupService = DataCleanupService();
        await cleanupService.cleanupCurrentUserProfilePicture();
      } catch (cleanupError) {
        print('Error during cleanup: $cleanupError');
      }
      rethrow;
    }
  }

  // Atualizar dados do usuário
  Future<void> updateUserData(UserModel user) async {
    try {
      // Validate profile picture before saving
      if (user.fotoPerfil != null) {
        final validImage = ImageValidator.validateAndFixBase64Image(user.fotoPerfil!);
        if (validImage == null) {
          // Remove corrupted image instead of saving it
          final cleanUser = user.copyWith(fotoPerfil: null);
          await _firestore.collection('users').doc(user.uid).update(cleanUser.toMap());
          return;
        } else if (validImage != user.fotoPerfil!) {
          // Use the fixed image
          final fixedUser = user.copyWith(fotoPerfil: validImage);
          await _firestore.collection('users').doc(user.uid).update(fixedUser.toMap());
          return;
        }
      }
      
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }

  // Obter lista de cupcakes
  Stream<List<Cupcake>> getCupcakes() {
    return _firestore
        .collection('products')
        .where('disponivel', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              try {
                return Cupcake.fromMap(doc.data(), doc.id);
              } catch (e) {
                print('Error parsing cupcake ${doc.id}: $e');
                return null;
              }
            })
            .where((cupcake) => cupcake != null && !ImageValidator.isCorruptedImageData(cupcake.imagem))
            .cast<Cupcake>()
            .toList());
  }

  // Obter cupcakes filtrados por categoria
  Stream<List<Cupcake>> getCupcakesByCategory(String categoria) {
    return _firestore
        .collection('products')
        .where('disponivel', isEqualTo: true)
        .where('categoria', isEqualTo: categoria)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Cupcake.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Obter cupcakes filtrados por sabor
  Stream<List<Cupcake>> getCupcakesByFlavor(String sabor) {
    return _firestore
        .collection('products')
        .where('disponivel', isEqualTo: true)
        .where('sabor', isEqualTo: sabor)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Cupcake.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Obter cupcakes filtrados por sabor E categoria
  Stream<List<Cupcake>> getCupcakesByFlavorAndCategory(String sabor, String categoria) {
    return _firestore
        .collection('products')
        .where('disponivel', isEqualTo: true)
        .where('sabor', isEqualTo: sabor)
        .where('categoria', isEqualTo: categoria)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Cupcake.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Criar novo pedido
  Future<String> createOrder({
    required List<CartItem> cartItems,
    required double total,
    required String formaPagamento,
    String? endereco,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');
      
      // Preparar itens do pedido
      List<Map<String, dynamic>> itens = cartItems.map((item) => item.toMap()).toList();
      
      // Criar documento do pedido
      final docRef = await _firestore.collection('orders').add({
        'userId': user.uid,
        'itens': itens,
        'total': total,
        'status': 'pendente',
        'dataHora': FieldValue.serverTimestamp(),
        'formaPagamento': formaPagamento,
        'endereco': endereco,
        'avaliacao': null,
      });
      
      // Programar atualização para "entregue" após 5 segundos (para testes)
      Timer(Duration(seconds: 5), () async {
        await _firestore.collection('orders').doc(docRef.id).update({
          'status': 'entregue'
        });
      });
      
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Obter pedidos do usuário atual
  Stream<List<Pedido>> getUserOrders() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('dataHora', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Pedido.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Avaliar pedido
  Future<void> rateOrder(String orderId, double rating) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'avaliacao': rating,
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Salvar carrinho no SharedPreferences para persistência local
  Future<void> saveCart(List<CartItem> cartItems) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> serializedItems = [];
      
      for (var item in cartItems) {
        final Map<String, dynamic> itemData = {
          'cupcake': item.cupcake.toMap(),
          'quantidade': item.quantidade,
        };
        serializedItems.add(itemData);
      }
      
      await prefs.setString('cart', serializedItems.toString());
    } catch (e) {
      // Apenas log, não propagar erro para não interromper fluxo
      print('Erro ao salvar carrinho: $e');
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

// Modelo do Usuário
class UserModel {
  final String uid;
  final String nome;
  final String email;
  String? telefone;
  String? endereco;
  String? fotoPerfil;

  UserModel({
    required this.uid,
    required this.nome, 
    required this.email, 
    this.telefone,
    this.endereco,
    this.fotoPerfil,
  });

  // Converter dados do Firestore para UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      telefone: map['telefone'],
      endereco: map['endereco'],
      fotoPerfil: map['fotoPerfil'],
    );
  }

  // Converter UserModel para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'endereco': endereco,
      'fotoPerfil': fotoPerfil,
    };
  }

  // Copiar com alterações
  UserModel copyWith({
    String? nome,
    String? telefone,
    String? endereco,
    String? fotoPerfil,
  }) {
    return UserModel(
      uid: this.uid,
      nome: nome ?? this.nome,
      email: this.email,
      telefone: telefone ?? this.telefone,
      endereco: endereco ?? this.endereco,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
    );
  }
}

// Modelo do Cupcake
class Cupcake {
  final String id;
  final String nome;
  final String descricao;
  final double preco;
  final String categoria; // 'Clássico' ou 'Premium'
  final String sabor;
  final String imagem;
  final bool disponivel;

  Cupcake({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.categoria,
    required this.sabor,
    required this.imagem,
    this.disponivel = true,
  });

  // Converter dados do Firestore para Cupcake
  factory Cupcake.fromMap(Map<String, dynamic> map, String id) {
    return Cupcake(
      id: id,
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      preco: (map['preco'] ?? 0.0).toDouble(),
      categoria: map['categoria'] ?? 'Clássico',
      sabor: map['sabor'] ?? '',
      imagem: map['imagem'] ?? '',
      disponivel: map['disponivel'] ?? true,
    );
  }

  // Converter Cupcake para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'categoria': categoria,
      'sabor': sabor,
      'imagem': imagem,
      'disponivel': disponivel,
    };
  }
}

// Modelo de Item do Carrinho
class CartItem {
  final Cupcake cupcake;
  int quantidade;

  CartItem({
    required this.cupcake,
    this.quantidade = 1,
  });

  // Obter subtotal do item
  double get subtotal => cupcake.preco * quantidade;

  // Converter para Map (para salvar no pedido)
  Map<String, dynamic> toMap() {
    return {
      'produtoId': cupcake.id,
      'nome': cupcake.nome,
      'preco': cupcake.preco,
      'quantidade': quantidade,
      'subtotal': subtotal,
      'imagem': cupcake.imagem,
    };
  }
}

// Modelo de Pedido
class Pedido {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> itens;
  final double total;
  final String status; // 'pendente', 'confirmado', 'entregue', 'cancelado'
  final DateTime dataHora;
  final String formaPagamento;
  final String? endereco;
  double? avaliacao;

  Pedido({
    required this.id,
    required this.userId,
    required this.itens,
    required this.total,
    required this.status,
    required this.dataHora,
    required this.formaPagamento,
    this.endereco,
    this.avaliacao,
  });

  // Converter dados do Firestore para Pedido
  factory Pedido.fromMap(Map<String, dynamic> map, String id) {
    return Pedido(
      id: id,
      userId: map['userId'] ?? '',
      itens: List<Map<String, dynamic>>.from(map['itens'] ?? []),
      total: (map['total'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pendente',
      dataHora: (map['dataHora'] as Timestamp).toDate(),
      formaPagamento: map['formaPagamento'] ?? '',
      endereco: map['endereco'],
      avaliacao: map['avaliacao']?.toDouble(),
    );
  }

  // Converter Pedido para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'itens': itens,
      'total': total,
      'status': status,
      'dataHora': Timestamp.fromDate(dataHora),
      'formaPagamento': formaPagamento,
      'endereco': endereco,
      'avaliacao': avaliacao,
    };
  }

  // Verificar se o pedido pode ser avaliado
  bool get podeAvaliar => status == 'entregue' && (avaliacao == null);
}
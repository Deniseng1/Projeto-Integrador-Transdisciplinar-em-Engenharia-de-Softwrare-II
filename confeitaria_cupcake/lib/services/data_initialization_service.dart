import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/cupcake_data.dart';


/// Serviço para inicializar dados no Firestore
class DataInitializationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Inicializa os cupcakes no Firestore se ainda não existirem
  Future<void> initializeCupcakes() async {
    try {
      // Verifica se já existem cupcakes
      final snapshot = await _firestore.collection('products').limit(1).get();
      
      if (snapshot.docs.isEmpty) {
        print('Inicializando cupcakes no Firestore...');
        
        // Adiciona cupcakes clássicos
        final classicos = CupcakeData.classicos;
        for (int i = 0; i < classicos.length; i++) {
          await _firestore.collection('products').add({
            ...classicos[i],
            'dataCriacao': FieldValue.serverTimestamp(),
          });
        }
        
        // Adiciona cupcakes premium
        final premium = CupcakeData.premium;
        for (int i = 0; i < premium.length; i++) {
          await _firestore.collection('products').add({
            ...premium[i],
            'dataCriacao': FieldValue.serverTimestamp(),
          });
        }
        
        print('Cupcakes inicializados com sucesso!');
        print('- ${classicos.length} cupcakes Clássicos');
        print('- ${premium.length} cupcakes Premium');
      } else {
        print('Cupcakes já existem no Firestore. Pulando inicialização.');
      }
    } catch (e) {
      print('Erro ao inicializar cupcakes: $e');
    }
  }

  /// Força a recriação de todos os cupcakes (para desenvolvimento)
  Future<void> recreateCupcakes() async {
    try {
      print('🗑️ Removendo cupcakes existentes...');
      
      // Remove todos os produtos existentes
      final snapshot = await _firestore.collection('products').get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      
      print('🧁 Criando novos cupcakes...');
      
      // Adiciona cupcakes clássicos
      final classicos = CupcakeData.classicos;
      for (int i = 0; i < classicos.length; i++) {
        await _firestore.collection('products').add({
          ...classicos[i],
          'dataCriacao': FieldValue.serverTimestamp(),
        });
        print('✅ Adicionado: ${classicos[i]['nome']} (${classicos[i]['categoria']})');
      }
      
      // Adiciona cupcakes premium
      final premium = CupcakeData.premium;
      for (int i = 0; i < premium.length; i++) {
        await _firestore.collection('products').add({
          ...premium[i],
          'dataCriacao': FieldValue.serverTimestamp(),
        });
        print('✅ Adicionado: ${premium[i]['nome']} (${premium[i]['categoria']})');
      }
      
      print('\n🎉 Cupcakes recriados com sucesso!');
      print('📊 Total: ${classicos.length + premium.length} cupcakes');
      print('📍 ${classicos.length} cupcakes Clássicos');
      print('📍 ${premium.length} cupcakes Premium');
    } catch (e) {
      print('Erro ao recriar cupcakes: $e');
    }
  }

  /// Adiciona mais cupcakes à categoria especificada
  Future<void> addMoreCupcakesToCategory(String categoria, int quantidade) async {
    try {
      print('Adicionando $quantidade cupcakes à categoria $categoria...');
      
      // Dados base para cada categoria
      final Map<String, List<Map<String, dynamic>>> categoriasBase = {
        'Clássicos': [
          {
            'nome': 'Limão Siciliano',
            'descricao': 'Refrescante cupcake de limão com cobertura cítrica e raspas de limão siciliano.',
            'preco': 8.50,
            'sabor': 'Limão',
            'imagem': 'lemon cupcake sicilian',
          },
          {
            'nome': 'Cenoura Caseira',
            'descricao': 'Tradicional cupcake de cenoura com cobertura de chocolate e toque de canela.',
            'preco': 7.50,
            'sabor': 'Cenoura',
            'imagem': 'carrot cupcake homemade',
          },
          {
            'nome': 'Banana Caramelizada',
            'descricao': 'Cupcake de banana com pedaços caramelizados e cobertura cremosa.',
            'preco': 8.00,
            'sabor': 'Banana',
            'imagem': 'banana caramel cupcake',
          },
          {
            'nome': 'Chocolate Branco',
            'descricao': 'Delicado cupcake de chocolate branco com cobertura aveludada.',
            'preco': 8.50,
            'sabor': 'Chocolate Branco',
            'imagem': 'white chocolate cupcake',
          },
        ],
        'Premium': [
          {
            'nome': 'Tiramisu Italiano',
            'descricao': 'Sofisticado cupcake inspirado no tiramisu com café expresso e mascarpone.',
            'preco': 16.50,
            'sabor': 'Café',
            'imagem': 'tiramisu cupcake italian',
          },
          {
            'nome': 'Frutas Vermelhas Silvestres',
            'descricao': 'Luxuoso cupcake com mix de frutas vermelhas orgânicas e cobertura artesanal.',
            'preco': 17.00,
            'sabor': 'Frutas Vermelhas',
            'imagem': 'wild berries cupcake premium',
          },
          {
            'nome': 'Caramelo Salgado Premium',
            'descricao': 'Exclusivo cupcake com caramelo salgado artesanal e flor de sal francesa.',
            'preco': 15.50,
            'sabor': 'Caramelo',
            'imagem': 'salted caramel cupcake premium',
          },
          {
            'nome': 'Champagne e Morango',
            'descricao': 'Elegante cupcake com champagne rosé e morangos frescos selecionados.',
            'preco': 19.00,
            'sabor': 'Champagne',
            'imagem': 'champagne strawberry cupcake',
          },
        ],
      };

      final cupcakesBase = categoriasBase[categoria] ?? [];
      
      for (int i = 0; i < quantidade && i < cupcakesBase.length; i++) {
        final cupcakeData = cupcakesBase[i];
        
        await _firestore.collection('products').add({
          'nome': cupcakeData['nome'],
          'descricao': cupcakeData['descricao'],
          'preco': cupcakeData['preco'],
          'categoria': categoria,
          'sabor': cupcakeData['sabor'],
          'imagem': _getImageForKeyword(cupcakeData['imagem']),
          'disponivel': true,
          'dataCriacao': FieldValue.serverTimestamp(),
        });
      }
      
      print('$quantidade cupcakes adicionados à categoria $categoria com sucesso!');
    } catch (e) {
      print('Erro ao adicionar cupcakes: $e');
    }
  }

  /// Helper para gerar imagem baseada na palavra-chave
  String _getImageForKeyword(String keyword) {
    try {
      return "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NDgxMjgwODl8&ixlib=rb-4.1.0&q=80&w=1080";
    } catch (e) {
      print('⚠️ Erro ao gerar imagem para keyword "$keyword": $e');
      return "https://pixabay.com/get/g9cff79bd14fe007d9759726db804356e42fb9a313c710bb2bdf509d071e3afdd6f4998ea7ff07a29e29e5ea15ebf5b5286fc8283fba1b0cfc082916134703431_1280.jpg";
    }
  }
}
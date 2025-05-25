
import '../models/app_models.dart';


/// Dados de cupcakes organizados por categoria
class CupcakeData {
  
  /// Cupcakes da categoria Clássicos (4 únicos)
  static List<Map<String, dynamic>> get classicos => [
    {
      'nome': 'Chocolate Supremo',
      'descricao': 'Delicioso cupcake de chocolate com massa fofinha e cobertura cremosa de chocolate ao leite. Um clássico irresistível.',
      'preco': 8.50,
      'categoria': 'Clássicos',
      'sabor': 'Chocolate',
      'imagem': "https://pixabay.com/get/g8475284a30d78f93bc06289ac27008cd80e80b31adafba4315961dc8f96f1d13f2d69b39a4a3a7369b701d8339d0a7796849d808825e24ef25ad9195fc53a2ab_1280.jpg",
      'disponivel': true,
    },
    {
      'nome': 'Baunilha Tradicional',
      'descricao': 'Cupcake clássico de baunilha com cobertura leve de chantilly e decoração delicada. Perfeito para todas as ocasiões.',
      'preco': 7.50,
      'categoria': 'Clássicos',
      'sabor': 'Baunilha',
      'imagem': "https://pixabay.com/get/g440f8b51cf29033076c417bb9603278fac7bc1d621c6b5fc80e7dcc8dcca834586d761ea19eb5794777bce1e455c9d295a26eb9fdd4dec570a2f3cd9d408a087_1280.jpg",
      'disponivel': true,
    },
    {
      'nome': 'Morango Natural',
      'descricao': 'Cupcake de morango com pedaços de fruta fresca na massa e cobertura de cream cheese com morangos.',
      'preco': 9.00,
      'categoria': 'Clássicos',
      'sabor': 'Morango',
      'imagem': "https://pixabay.com/get/g3d82e2c1ba0ea679fd4328261f75f918f3068fe91a7b705465005b1d65a082ab882d5ea69eb7fe792ea6891f7cd777a80d60482a3998f601180a1cd42db40827_1280.jpg",
      'disponivel': true,
    },
    {
      'nome': 'Coco Gelado',
      'descricao': 'Refrescante cupcake de coco com massa úmida e cobertura de chantilly com coco ralado fresco.',
      'preco': 8.00,
      'categoria': 'Clássicos',
      'sabor': 'Coco',
      'imagem': "https://pixabay.com/get/g347cf39ddb56df75e7c074a4adc2fb8ab84d836514b6a2a3a1b279a2317127ebd58faa37afbce209032c3c4df69908e9a440fb0830da929ebf24953f28ab6f52_1280.jpg",
      'disponivel': true,
    },
  ];

  /// Cupcakes da categoria Premium (4 únicos)
  static List<Map<String, dynamic>> get premium => [
    {
      'nome': 'Trufa Belga Artesanal',
      'descricao': 'Sofisticado cupcake de chocolate belga com recheio de trufa negra e cobertura de ganache premium com ouro comestível.',
      'preco': 15.50,
      'categoria': 'Premium',
      'sabor': 'Chocolate',
      'imagem': "https://pixabay.com/get/g045f81542743b8674299248132267cacb6c0e35cdfd5a6e391db84c46aec9084822b464a5795966832dd3e7d6048c0f2b08b23a2921098c72986ffd85acfdac7_1280.jpg",
      'disponivel': true,
    },
    {
      'nome': 'Macarons Francês',
      'descricao': 'Exclusivo cupcake inspirado nos macarons franceses com massa de amêndoas e cobertura de buttercream de pistache.',
      'preco': 16.00,
      'categoria': 'Premium',
      'sabor': 'Pistache',
      'imagem': "https://pixabay.com/get/ge717a0774a0e4a60180450e91be9bf04337b40b2ae57f269c613ea0ab077b2ef78cc4ff5fd1d863ec386ad932a6a2e797275708e7a536fe90a243b8858724dbe_1280.jpg",
      'disponivel': true,
    },
    {
      'nome': 'Red Velvet Gourmet',
      'descricao': 'Autêntico Red Velvet americano com massa aveludada vermelha e cobertura de cream cheese artesanal.',
      'preco': 14.00,
      'categoria': 'Premium',
      'sabor': 'Red Velvet',
      'imagem': "https://pixabay.com/get/g43c691d368e475399036cbe6ba6ff936e7c98bb0dad8cde6013d462d13bfc56a8712bcf850fbc8a9d4c08a3e03e8247b278c6eb64f5d2a0290c97e99845c82c3_1280.jpg",
      'disponivel': true,
    },
    {
      'nome': 'Lavanda Provençal',
      'descricao': 'Delicado cupcake de lavanda francesa com mel orgânico e cobertura floral com pétalas cristalizadas.',
      'preco': 17.50,
      'categoria': 'Premium',
      'sabor': 'Lavanda',
      'imagem': "https://pixabay.com/get/g48dd083d0043cee01a90edb9748f06f873637bd5fc02d35ab84c0d534bed4c52c9e49c9f5da44d36cee7d9cd7152a9857bab8847f04786d6e2870f1bc21d025d_1280.jpg",
      'disponivel': true,
    },
  ];

  /// Retorna todos os cupcakes organizados
  static List<Map<String, dynamic>> get todosCupcakes {
    return [...classicos, ...premium];
  }

  /// Retorna cupcakes por categoria
  static List<Map<String, dynamic>> getCupcakesByCategory(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'clássicos':
      case 'classicos':
        return classicos;
      case 'premium':
        return premium;
      default:
        return todosCupcakes;
    }
  }

  /// Converte os dados para objetos Cupcake
  static List<Cupcake> toCupcakeObjects() {
    return todosCupcakes.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      
      return Cupcake(
        id: 'cupcake_$index',
        nome: data['nome'],
        descricao: data['descricao'],
        preco: data['preco'].toDouble(),
        categoria: data['categoria'],
        sabor: data['sabor'],
        imagem: data['imagem'],
        disponivel: data['disponivel'],
      );
    }).toList();
  }
}
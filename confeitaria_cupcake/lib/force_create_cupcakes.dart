import 'package:firebase_core/firebase_core.dart';
import 'services/data_initialization_service.dart';
import 'firebase_options.dart';

/// 🧁 SCRIPT PARA FORÇAR A CRIAÇÃO DOS CUPCAKES
/// Este script força a criação dos 8 cupcakes únicos no Firestore
/// Execute: dart run lib/force_create_cupcakes.dart

void main() async {
  print('🧁 CRIANDO CUPCAKES NO BANCO DE DADOS...\n');
  
  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado com sucesso!');
    
    // Criar instância do serviço
    final dataService = DataInitializationService();
    
    // Forçar recriação dos cupcakes
    print('\n🔄 Recriando todos os cupcakes...');
    await dataService.recreateCupcakes();
    
    print('\n🎉 CUPCAKES CRIADOS COM SUCESSO!');
    _mostrarCupcakesCriados();
    _mostrarInstrucoes();
    
  } catch (e) {
    print('\n❌ ERRO ao criar cupcakes: $e');
    print('\n💡 SOLUÇÕES:');
    print('1. Verifique sua conexão com a internet');
    print('2. Confirme se o Firebase está configurado corretamente');
    print('3. Tente usar o painel administrativo no app');
  }
}

void _mostrarCupcakesCriados() {
  print('\n📦 CUPCAKES CRIADOS:\n');
  
  print('📍 CATEGORIA CLÁSSICOS (4 cupcakes):');
  print('  🍫 Chocolate Supremo - R\$ 8,50');
  print('  🍦 Baunilha Tradicional - R\$ 7,50');
  print('  🍓 Morango Natural - R\$ 9,00');
  print('  🥥 Coco Gelado - R\$ 8,00');
  
  print('\n📍 CATEGORIA PREMIUM (4 cupcakes):');
  print('  🍫 Trufa Belga Artesanal - R\$ 15,50');
  print('  🌰 Macarons Francês - R\$ 16,00');
  print('  ❤️ Red Velvet Gourmet - R\$ 14,00');
  print('  💜 Lavanda Provençal - R\$ 17,50');
}

void _mostrarInstrucoes() {
  print('\n🎯 PRÓXIMOS PASSOS:');
  print('1. Abra o aplicativo');
  print('2. Os 8 cupcakes devem aparecer na tela inicial');
  print('3. Use os filtros "Clássicos", "Premium", "Todos"');
  print('4. Toque em qualquer cupcake para ver detalhes');
  print('5. Adicione itens ao carrinho para testar');
  
  print('\n✨ FUNCIONALIDADES ATIVAS:');
  print('✅ Grid responsivo de cupcakes');
  print('✅ Filtros dinâmicos por categoria');
  print('✅ Modal detalhado para cada produto');
  print('✅ Sistema de carrinho integrado');
  print('✅ Dados persistentes no Firebase');
  
  print('\n🎨 DESIGN:');
  print('✅ Interface elegante inspirada em confeitarias francesas');
  print('✅ Cores pastéis rosa e lavanda');
  print('✅ Tipografia Google Fonts');
  print('✅ Animações suaves');
  
  print('\n🧁 APROVEITE SUA CONFEITARIA DIGITAL! ✨');
}
import 'package:firebase_core/firebase_core.dart';
import 'lib/services/data_initialization_service.dart';
import 'lib/firebase_options.dart';

/// 🧁 SCRIPT EXECUTÁVEL PARA CRIAR CUPCAKES IMEDIATAMENTE
/// Execute este arquivo na raiz do projeto: dart run criar_cupcakes_agora.dart

void main() async {
  print('🧁 PATISSERIE ARTISAN - CRIANDO CUPCAKES...\n');
  
  try {
    // Inicializar Firebase
    print('🔥 Conectando ao Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase conectado!\n');
    
    // Criar cupcakes
    print('🧁 Criando os 8 cupcakes únicos...');
    final dataService = DataInitializationService();
    await dataService.recreateCupcakes();
    
    print('\n🎉 CUPCAKES CRIADOS COM SUCESSO!');
    _mostrarResumo();
    _mostrarProximosPassos();
    
  } catch (e) {
    print('\n❌ ERRO: $e');
    print('\n💡 SOLUÇÕES:');
    print('1. Verifique sua conexão com internet');
    print('2. Use o painel admin no aplicativo');
    print('3. Perfil → "Painel Administrativo" → "🧁 CRIAR CUPCAKES"');
  }
}

void _mostrarResumo() {
  print('\n📦 CUPCAKES CRIADOS:\n');
  
  print('📍 CLÁSSICOS (4 cupcakes):');
  print('  🍫 Chocolate Supremo - R\$ 8,50');
  print('  🍦 Baunilha Tradicional - R\$ 7,50');
  print('  🍓 Morango Natural - R\$ 9,00');
  print('  🥥 Coco Gelado - R\$ 8,00');
  
  print('\n📍 PREMIUM (4 cupcakes):');
  print('  🍫 Trufa Belga Artesanal - R\$ 15,50');
  print('  🌰 Macarons Francês - R\$ 16,00');
  print('  ❤️ Red Velvet Gourmet - R\$ 14,00');
  print('  💜 Lavanda Provençal - R\$ 17,50');
}

void _mostrarProximosPassos() {
  print('\n🎯 PRÓXIMOS PASSOS:');
  print('1. 📱 Abra o aplicativo Flutter');
  print('2. 🏠 Os cupcakes aparecerão na tela inicial');
  print('3. 🔍 Use os filtros "Todos", "Clássicos", "Premium"');
  print('4. 👆 Toque em qualquer cupcake para detalhes');
  print('5. 🛒 Adicione ao carrinho para testar');
  
  print('\n✨ FUNCIONALIDADES ATIVAS:');
  print('✅ Grid responsivo com 8 cupcakes únicos');
  print('✅ Filtros dinâmicos por categoria');
  print('✅ Modal detalhado para cada produto');
  print('✅ Sistema de carrinho integrado');
  print('✅ Imagens automáticas de alta qualidade');
  print('✅ Design elegante francês');
  
  print('\n🧁 APROVEITE SUA CONFEITARIA DIGITAL! ✨');
}
import 'package:firebase_core/firebase_core.dart';
import 'lib/services/data_initialization_service.dart';
import 'lib/firebase_options.dart';

/// 🧁 SCRIPT PARA CRIAR OS CUPCAKES DE EXEMPLO
/// Execute este arquivo para criar os 8 cupcakes no Firestore
/// 
/// COMO USAR:
/// 1. Certifique-se de estar conectado à internet
/// 2. Execute: dart run criar_cupcakes.dart
/// 3. Aguarde a confirmação de sucesso
/// 4. Abra o aplicativo para ver os cupcakes

void main() async {
  print('🧁 CRIADOR DE CUPCAKES - PATISSERIE ARTISAN 🧁\n');
  
  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    print('🔥 Firebase conectado com sucesso!');
    print('📦 Preparando para criar os cupcakes...\n');
    
    // Criar instância do serviço
    final dataService = DataInitializationService();
    
    print('🧁 Criando 4 cupcakes CLÁSSICOS...');
    print('🧁 Criando 4 cupcakes PREMIUM...\n');
    
    // Forçar recriação de todos os cupcakes
    await dataService.recreateCupcakes();
    
    print('\n🎉 SUCESSO TOTAL! 🎉');
    print('✅ 8 cupcakes únicos foram criados no Firestore!');
    print('📱 Agora abra o aplicativo para ver os produtos.\n');
    
    // Mostrar lista detalhada dos cupcakes criados
    _mostrarCupcakesCriados();
    
  } catch (e) {
    print('❌ ERRO ao criar cupcakes: $e\n');
    _mostrarSolucoes();
  }
}

void _mostrarCupcakesCriados() {
  print('🧁 CUPCAKES CRIADOS COM SUCESSO:');
  print('═══════════════════════════════════════════');
  print('');
  print('📍 CATEGORIA CLÁSSICOS (R\$ 7,50 - R\$ 9,00):');
  print('   1. 🍫 Chocolate Supremo - R\$ 8,50');
  print('      └─ Massa fofinha com cobertura cremosa');
  print('   2. 🍦 Baunilha Tradicional - R\$ 7,50');
  print('      └─ Clássico com chantilly delicado');
  print('   3. 🍓 Morango Natural - R\$ 9,00');
  print('      └─ Com pedaços de fruta fresca');
  print('   4. 🥥 Coco Gelado - R\$ 8,00');
  print('      └─ Refrescante com coco ralado');
  print('');
  print('📍 CATEGORIA PREMIUM (R\$ 14,00 - R\$ 17,50):');
  print('   1. 🍫 Trufa Belga Artesanal - R\$ 15,50');
  print('      └─ Chocolate belga com ouro comestível');
  print('   2. 🌰 Macarons Francês - R\$ 16,00');
  print('      └─ Inspirado em macarons franceses');
  print('   3. ❤️ Red Velvet Gourmet - R\$ 14,00');
  print('      └─ Autêntico americano aveludado');
  print('   4. 💜 Lavanda Provençal - R\$ 17,50');
  print('      └─ Com mel orgânico e pétalas');
  print('');
  print('═══════════════════════════════════════════');
  print('🎯 PRÓXIMOS PASSOS:');
  print('   1. Abra o aplicativo mobile');
  print('   2. Faça login ou cadastre-se');
  print('   3. Navegue pela tela inicial');
  print('   4. Use os filtros: "Todos", "Clássicos", "Premium"');
  print('   5. Toque em qualquer cupcake para ver detalhes');
  print('   6. Adicione produtos ao carrinho');
  print('');
  print('🎨 FUNCIONALIDADES DISPONÍVEIS:');
  print('   • Grid responsivo de produtos');
  print('   • Filtros por categoria em tempo real');
  print('   • Modal detalhado para cada cupcake');
  print('   • Sistema de carrinho integrado');
  print('   • Painel administrativo completo');
  print('');
  print('🎉 APROVEITE SUA CONFEITARIA DIGITAL! 🧁✨');
}

void _mostrarSolucoes() {
  print('💡 POSSÍVEIS SOLUÇÕES:');
  print('═══════════════════════════════════════════');
  print('1. 🌐 Verifique sua conexão com a internet');
  print('2. 🔧 Certifique-se de que o Firebase está configurado');
  print('3. 🔑 Verifique as permissões do Firestore');
  print('4. 📱 Tente usar o painel admin do aplicativo:');
  print('   • Abra o app → Perfil → "Painel Administrativo"');
  print('   • Toque em "🧁 CRIAR CUPCAKES DE EXEMPLO"');
  print('5. 🔄 Execute novamente este script');
  print('');
  print('📞 Se o problema persistir:');
  print('   • Verifique o console do Firebase');
  print('   • Confirme que as regras do Firestore permitem escrita');
  print('   • Teste a conexão com o banco de dados');
}
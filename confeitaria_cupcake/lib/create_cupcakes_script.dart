import 'package:firebase_core/firebase_core.dart';
import 'services/data_initialization_service.dart';
import 'firebase_options.dart';

/// 🧁 CRIADOR AUTOMÁTICO DE CUPCAKES - PATISSERIE ARTISAN
/// 
/// Este script cria automaticamente 8 cupcakes únicos no Firestore:
/// • 4 cupcakes CLÁSSICOS (R$ 7,50 - R$ 9,00)
/// • 4 cupcakes PREMIUM (R$ 14,00 - R$ 17,50)
/// 
/// COMO EXECUTAR:
/// 1. Terminal: dart run lib/create_cupcakes_script.dart
/// 2. Ou pelo app: Perfil → Painel Administrativo → "Criar Cupcakes"
void main() async {
  print('🧁═══════════════════════════════════════════🧁');
  print('    CRIADOR DE CUPCAKES - PATISSERIE ARTISAN    ');
  print('🧁═══════════════════════════════════════════🧁\n');
  
  try {
    // Inicializa o Firebase
    print('🔥 Conectando ao Firebase...');
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print('✅ Firebase inicializado com sucesso!\n');
    
    // Cria o serviço de inicialização
    final dataService = DataInitializationService();
    
    print('🧁 Preparando para criar os cupcakes de exemplo...');
    print('📦 Serão criados 8 cupcakes únicos (4 Clássicos + 4 Premium)\n');
    
    // Força a recriação de todos os cupcakes
    print('🔄 Iniciando processo de criação...\n');
    await dataService.recreateCupcakes();
    
    print('\n🎉 SUCESSO! Os cupcakes foram criados/recriados no Firestore!');
    print('\n📋 CUPCAKES CRIADOS:');
    print('📍 CATEGORIA CLÁSSICOS (4 cupcakes):');
    print('   • Chocolate Supremo - R\$ 8,50');
    print('   • Baunilha Tradicional - R\$ 7,50');  
    print('   • Morango Natural - R\$ 9,00');
    print('   • Coco Gelado - R\$ 8,00');
    
    print('\n📍 CATEGORIA PREMIUM (4 cupcakes):');
    print('   • Trufa Belga Artesanal - R\$ 15,50');
    print('   • Macarons Francês - R\$ 16,00');
    print('   • Red Velvet Gourmet - R\$ 14,00');
    print('   • Lavanda Provençal - R\$ 17,50');
    
    print('\n🎯 PRÓXIMOS PASSOS:');
    print('   1. 📱 Abra o aplicativo mobile');
    print('   2. 🔐 Faça login ou cadastre-se');
    print('   3. 🏠 Navegue pela tela inicial');
    print('   4. 🔍 Use os filtros: "Todos", "Clássicos", "Premium"');
    print('   5. 👆 Toque em qualquer cupcake para ver detalhes');
    print('   6. 🛒 Adicione produtos ao carrinho');
    
    print('\n🎨 FUNCIONALIDADES DISPONÍVEIS:');
    print('   • Grid responsivo de produtos');
    print('   • Filtros por categoria em tempo real');
    print('   • Modal detalhado para cada cupcake');
    print('   • Sistema de carrinho e pedidos');
    print('   • Painel administrativo completo');
    
    print('\n🧁═══════════════════════════════════════════🧁');
    print('       ✨ CUPCAKES CRIADOS COM SUCESSO! ✨       ');
    print('🧁═══════════════════════════════════════════🧁');
    
  } catch (e) {
    print('\n❌═══════════════════════════════════════════❌');
    print('                    ERRO DETECTADO                ');
    print('❌═══════════════════════════════════════════❌');
    print('🔍 Detalhes do erro: $e\n');
    
    print('💡 POSSÍVEIS SOLUÇÕES:');
    print('   1. 🌐 Verifique sua conexão com a internet');
    print('   2. 🔧 Confirme se o Firebase está configurado');
    print('   3. 🔑 Verifique as permissões do Firestore');
    print('   4. 📱 Use o painel admin do app como alternativa:');
    print('      • Perfil → "Painel Administrativo"');
    print('      • Toque em "🧁 CRIAR CUPCAKES DE EXEMPLO"');
    print('   5. 🔄 Execute este script novamente');
    
    print('\n📞 Se o problema persistir, verifique:');
    print('   • Console do Firebase para erros');
    print('   • Regras de segurança do Firestore');
    print('   • Configuração dos certificados');
  }
}
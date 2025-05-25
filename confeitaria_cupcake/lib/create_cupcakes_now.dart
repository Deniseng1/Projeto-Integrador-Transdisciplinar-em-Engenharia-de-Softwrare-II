import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/data_initialization_service.dart';
import 'firebase_options.dart';

/// Script executável para criar os cupcakes imediatamente
/// Execute este arquivo para garantir que os 8 cupcakes sejam criados no Firestore
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Inicializar o Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    print('🔥 Firebase inicializado com sucesso!');
    print('🧁 Iniciando criação dos cupcakes...\n');
    
    // Criar instância do serviço
    final dataService = DataInitializationService();
    
    // Recriar todos os cupcakes (força a criação mesmo se já existirem)
    await dataService.recreateCupcakes();
    
    print('\n✨ SUCESSO! Os cupcakes foram criados com sucesso!');
    print('📱 Agora você pode abrir o aplicativo e ver os 8 cupcakes na tela inicial.');
    print('🎯 Use os filtros "Clássicos", "Premium" e "Todos" para navegar.\n');
    
    // Mostrar resumo dos cupcakes criados
    print('🧁 RESUMO DOS CUPCAKES CRIADOS:');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📍 CATEGORIA CLÁSSICOS (4 cupcakes):');
    print('   • Chocolate Supremo - R\$ 8,50');
    print('   • Baunilha Tradicional - R\$ 7,50');
    print('   • Morango Natural - R\$ 9,00');
    print('   • Coco Gelado - R\$ 8,00');
    print('');
    print('📍 CATEGORIA PREMIUM (4 cupcakes):');
    print('   • Trufa Belga Artesanal - R\$ 15,50');
    print('   • Macarons Francês - R\$ 16,00');
    print('   • Red Velvet Gourmet - R\$ 14,00');
    print('   • Lavanda Provençal - R\$ 17,50');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🎉 PRONTO! Abra o app e aproveite! 🎉');
    
  } catch (e) {
    print('❌ ERRO ao criar cupcakes: $e');
    print('💡 Verifique se:');
    print('   • Você está conectado à internet');
    print('   • O Firebase está configurado corretamente');
    print('   • Você tem permissões para escrever no Firestore');
  }
}
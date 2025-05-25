import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/data_initialization_service.dart';
import 'firebase_options.dart';

/// 🧁 SCRIPT COMPLETO PARA TESTAR E CRIAR CUPCAKES
/// Este script:
/// 1. Testa a conexão com Firebase
/// 2. Verifica se existem cupcakes no banco
/// 3. Cria os cupcakes se necessário
/// 4. Mostra o status final

void main() async {
  print('🧁 PATISSERIE ARTISAN - TESTE E CRIAÇÃO DE CUPCAKES\n');
  
  try {
    // 1. Inicializar Firebase
    print('🔥 Inicializando Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado com sucesso!\n');
    
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DataInitializationService dataService = DataInitializationService();
    
    // 2. Testar conexão com Firestore
    print('🔗 Testando conexão com Firestore...');
    try {
      await firestore.collection('test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'connected'
      });
      print('✅ Conexão com Firestore funcionando!\n');
    } catch (e) {
      print('❌ Erro de conexão com Firestore: $e\n');
      return;
    }
    
    // 3. Verificar se já existem cupcakes
    print('🔍 Verificando cupcakes existentes...');
    final snapshot = await firestore.collection('products').get();
    print('📊 Encontrados ${snapshot.docs.length} cupcakes no banco\n');
    
    if (snapshot.docs.isNotEmpty) {
      print('📋 CUPCAKES EXISTENTES:');
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          print('  • ${data['nome']} - ${data['categoria']} - R\$ ${data['preco']}');
        }
      }
      print('');
      
      print('🤔 Deseja recriar todos os cupcakes? (Isso removerá os existentes)');
      print('   1. Digite "s" para SIM');
      print('   2. Digite "n" para NÃO');
      print('   3. Digite qualquer outra coisa para apenas criar novos se necessário');
      print('');
      
      // Para script automático, vamos recriar se houver menos de 8 cupcakes
      if (snapshot.docs.length < 8) {
        print('🔄 Menos de 8 cupcakes encontrados. Recriando todos...');
        await dataService.recreateCupcakes();
      } else {
        print('✅ Cupcakes suficientes encontrados. Usando existentes.');
      }
    } else {
      print('📦 Nenhum cupcake encontrado. Criando cupcakes iniciais...');
      await dataService.initializeCupcakes();
    }
    
    // 4. Verificar status final
    print('\n🔍 Verificando status final...');
    final finalSnapshot = await firestore.collection('products').get();
    print('✅ Total de cupcakes no banco: ${finalSnapshot.docs.length}\n');
    
    if (finalSnapshot.docs.isNotEmpty) {
      _mostrarCupcakesPorCategoria(finalSnapshot.docs);
      _mostrarInstrucoesSucesso();
    } else {
      print('❌ Erro: Nenhum cupcake foi criado!');
      _mostrarSolucoes();
    }
    
  } catch (e) {
    print('\n❌ ERRO GERAL: $e');
    _mostrarSolucoes();
  }
}

void _mostrarCupcakesPorCategoria(List<QueryDocumentSnapshot> docs) {
  print('📊 CUPCAKES POR CATEGORIA:\n');
  
  final classicos = docs.where((doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return data?['categoria'] == 'Clássicos';
  }).toList();
  final premium = docs.where((doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return data?['categoria'] == 'Premium';
  }).toList();
  
  print('📍 CLÁSSICOS (${classicos.length} cupcakes):');
  for (var doc in classicos) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data != null) {
      print('  🧁 ${data['nome']} - R\$ ${data['preco']}');
    }
  }
  
  print('\n📍 PREMIUM (${premium.length} cupcakes):');
  for (var doc in premium) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data != null) {
      print('  🧁 ${data['nome']} - R\$ ${data['preco']}');
    }
  }
  print('');
}

void _mostrarInstrucoesSucesso() {
  print('🎉 SUCESSO! CUPCAKES CRIADOS E INTEGRADOS!\n');
  
  print('🎯 PRÓXIMOS PASSOS:');
  print('1. 📱 Abra o aplicativo Flutter');
  print('2. 🏠 Vá para a tela inicial');
  print('3. 👀 Os cupcakes devem aparecer automaticamente');
  print('4. 🔍 Use os filtros: "Todos", "Clássicos", "Premium"');
  print('5. 👆 Toque em qualquer cupcake para ver detalhes');
  print('6. 🛒 Adicione itens ao carrinho para testar');
  
  print('\n✨ FUNCIONALIDADES ATIVAS:');
  print('✅ Grid responsivo de cupcakes');
  print('✅ Filtros dinâmicos por categoria');
  print('✅ Modal detalhado para cada produto');
  print('✅ Sistema de carrinho integrado');
  print('✅ Dados persistentes no Firebase Firestore');
  print('✅ Imagens automáticas via getRandomImageByKeyword');
  print('✅ Interface elegante inspirada em confeitarias francesas');
  
  print('\n🎨 DESIGN FEATURES:');
  print('• Cores pastéis rosa e lavanda');
  print('• Tipografia Google Fonts (Playfair Display + Poppins)');
  print('• Animações suaves com FadeTransition');
  print('• Layout responsivo (mobile, tablet, desktop)');
  print('• Cards elegantes com sombras e bordas arredondadas');
  
  print('\n🧁 APROVEITE SUA CONFEITARIA DIGITAL! ✨');
}

void _mostrarSolucoes() {
  print('\n💡 SOLUÇÕES PARA PROBLEMAS:');
  print('');
  print('📡 Se erro de conexão:');
  print('  • Verifique sua conexão com a internet');
  print('  • Confirme as configurações do Firebase');
  print('  • Tente novamente em alguns minutos');
  print('');
  print('🔑 Se erro de permissões:');
  print('  • Verifique as regras do Firestore');
  print('  • Confirme se a autenticação está configurada');
  print('  • Tente fazer login no aplicativo primeiro');
  print('');
  print('🛠️ Se problemas persistirem:');
  print('  • Use o Painel Administrativo no app');
  print('  • Perfil → "Painel Administrativo"');
  print('  • Toque em "🧁 CRIAR CUPCAKES DE EXEMPLO"');
  print('');
  print('📞 Para suporte adicional:');
  print('  • Verifique os logs do console');
  print('  • Confirme se o Firebase está online');
  print('  • Tente reiniciar o aplicativo');
}
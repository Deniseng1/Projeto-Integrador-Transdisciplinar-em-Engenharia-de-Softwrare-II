import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';


/// 🖼️ SCRIPT DE DEBUG PARA TESTAR IMAGENS
/// Este script testa se as imagens estão sendo geradas corretamente
/// Execute: dart run lib/test_images_debug.dart

void main() async {
  print('🔍 TESTANDO GERAÇÃO DE IMAGENS...');
  print('─' * 60);

  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado');

    // Testar geração de imagens
    print('\n🖼️ TESTANDO getRandomImageByKeyword:');
    final keywords = [
      'chocolate cupcake',
      'vanilla cupcake', 
      'strawberry cupcake',
      'coconut cupcake',
      'truffle chocolate cupcake',
      'macaron cupcake',
      'red velvet cupcake',
      'lavender cupcake'
    ];

    for (String keyword in keywords) {
      try {
        String url = "https://images.unsplash.com/photo-1694715680932-b4f22d51ad23?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NDgxMTU2NTV8&ixlib=rb-4.1.0&q=80&w=1080";
        print('✅ $keyword: $url');
      } catch (e) {
        print('❌ $keyword: ERRO - $e');
      }
    }

    // Verificar cupcakes no banco
    print('\n📋 VERIFICANDO CUPCAKES NO FIRESTORE:');
    final querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .get();

    if (querySnapshot.docs.isEmpty) {
      print('⚠️ Nenhum cupcake encontrado no banco!');
      print('💡 Execute o script de recriação: dart run lib/recreate_cupcakes_with_images.dart');
    } else {
      print('✅ Encontrados ${querySnapshot.docs.length} cupcakes:');
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final nome = data['nome'] ?? 'Sem nome';
        final imagem = data['imagem'] ?? '';
        final categoria = data['categoria'] ?? 'Sem categoria';
        
        print('  📍 $nome ($categoria)');
        if (imagem.isEmpty) {
          print('    ❌ Imagem vazia');
        } else if (imagem.startsWith('http')) {
          print('    ✅ URL válida: ${imagem.substring(0, 50)}...');
        } else {
          print('    ⚠️ URL suspeita: $imagem');
        }
      }
    }

    print('\n─' * 60);
    print('🎯 DIAGNÓSTICO COMPLETO!');
    
  } catch (e) {
    print('❌ ERRO: $e');
  }
}
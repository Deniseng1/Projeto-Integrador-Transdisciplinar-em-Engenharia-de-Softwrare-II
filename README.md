# Projeto-Integrador-Transdisciplinar-em-Engenharia-de-Software-II
Loja Virtual de Cupcakes
Título do Projeto:
ConfeitariaCupcake– Cupcake Delivery
Objetivo:
Criar um aplicativo responsivo, alegre e visualmente elegante de uma confeitaria especializada em cupcakes, com sistema de vitrine virtual, carrinho, pedidos online, pagamentos e acompanhamento da entrega. O app será acessível para todas as idades, com foco em responsividade
________________________________________
________________________________________
Personagens
•	Cliente: Navega, compra, paga, avalia.
•	Vendedor: Gerencia a vitrine e os pedidos.
________________________________________
Front-End Funcionalidades
1. Vitrine Virtual:
•	Exibir cupcakes com nome, descrição, preço e imagem.
•	Filtragem por:
o	Categoria (Clássicos e Premium)
•	Sistema de busca por nome.
2. Carrinho:
•	Adicionar e remover itens.
•	Selecionar quantidades.
•	Total atualizado automaticamente.
3. Finalização do Pedido:
•	Formulário com:
o	Nome
o	Telefone (00)00000-0000
o	Endereço completo
•	Escolha de pagamento:
o	Cartão de crédito/débito (entrada de dados)
o	Pix (QR code )
o	Dinheiro (com campo “precisa de troco?”)
•	Confirmação e toast “Pedido confirmado”.
4. Status do Pedido:
•	Etapas: Em preparo → Em entrega → Entregue.
•	Atualização automática 
•	Cliente recebe notificações visuais (toasts e alertas).
5. Área do Cliente:
•	Histórico de pedidos.
•	Avaliação de pedido com até 5 estrelas (muda a cor conforme nota).
•	Atualizar nome, telefone e senha.
•	Botão “Fale conosco” com:
o	WhatsApp 
o	Telefone 
.
6. Autenticação:
•	Login (email + senha)
•	Cadastro (nome, email, senha e confirmar senha)
•	Validações:
o	Email inválido → "Email inválido"
o	Email não encontrado → "Email não encontrado"
o	Senha incorreta → "Senha incorreta"
o	Senha < 6 caracteres → "A senha deve ter ao menos 6 caracteres"
o	Email já em uso → "Este email já está em uso"
•	Esqueci minha senha
7. Responsividade:
•	Layout adaptável para celular, tablet, notebook e desktop.
8. Notificações:
•	Toasts e mensagens de erro/sucesso.
________________________________________
Back-End & Firebase
1. Autenticação:
•	Firebase Auth para login, cadastro e recuperação de senha.
2. Firestore – Banco de dados:
•	Coleção cupcakes:
o	categoria (Tradicionais, Premium)
•	Coleção pedidos:
o	Informações de cliente, produtos, status, pagamento, avaliação
•	Coleção usuarios:
o	Perfil do cliente (nome, telefone, email)
3. Pedidos:
•	Criar, listar, atualizar status.
•	Avaliação disponível após status = "Entregue".
4. Pagamento:
o	Cartão
o	Pix (QR code fictício)
o	Dinheiro (opção de troco)
5. Relatórios de Vendas (Vendedor):
•	Número de cupcakes vendidos
•	Valor total das vendas
•	Filtros por data, cliente, produto
________________________________________
Contato Fictício:
•	WhatsApp: 
•	Telefone: 
________________________________________
Tecnologias Usadas:
•	Firebase (Auth, Firestore, Storage, Functions)
•	Dreamflow (Low-code builder)
•	React (caso precise customizar componentes externos)

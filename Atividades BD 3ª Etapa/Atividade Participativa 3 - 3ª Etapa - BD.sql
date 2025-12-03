-- 1) Criar database
Create Database LojaBancoDados2;
Use LojaBancoDados2;

-- 2) Criar tabelas (sem abreviações)
Create Table Produto (
  CodigoProduto            Int Primary Key,
  Nome                     Varchar(100),
  Descricao                Varchar(255),
  QuantidadeEmEstoque      Int
);

Create Table Cliente (
  CodigoCliente            Int Primary Key,
  Nome                     Varchar(100),
  Email                    Varchar(150),
  Cpf                      Varchar(20)
);

Create Table Pedido (
  CodigoPedido             Int Auto_Increment Primary Key,
  DataDoPedido             Datetime,
  StatusDoPedido           Varchar(30)
);

Create Table ItemPedido (
  CodigoPedido             Int,
  CodigoProduto            Int,
  PrecoDeVenda             Decimal(10,2),
  Quantidade               Int
);

Create Table Funcionario (
  CodigoFuncionario        Int Primary Key,
  Nome                     Varchar(100),
  Funcao                   Varchar(60),
  Cidade                   Varchar(80)
);

Create Table Vendedor (
  CodigoVendedor           Int Primary Key,
  Nome                     Varchar(100),
  Cidade                   Varchar(80)
);

-- 3) Tabela Auditoria (sem abreviações)
Create Table Auditoria (
  DataModificacao          Datetime,
  NomeTabela               Varchar(50),
  Historico                Text
);

-- 4) Triggers para Produto, Cliente, Pedido, ItemPedido, Vendedor (sem abreviações)
Delimiter $$

Create Trigger Trigger_Produto_Insert After Insert On Produto
For Each Row Begin
  Insert Into Auditoria (DataModificacao, NomeTabela, Historico)
  Values (Now(), 'Produto', Concat('Insert CodigoProduto=', New.CodigoProduto));
End$$

Create Trigger Trigger_Produto_Update After Update On Produto
For Each Row Begin
  Insert Into Auditoria (DataModificacao, NomeTabela, Historico)
  Values (Now(), 'Produto', Concat('Update CodigoProduto=', New.CodigoProduto));
End$$

Create Trigger Trigger_Produto_Delete After Delete On Produto
For Each Row Begin
  Insert Into Auditoria (DataModificacao, NomeTabela, Historico)
  Values (Now(), 'Produto', Concat('Delete CodigoProduto=', Old.CodigoProduto));
End$$


Create Trigger Trigger_Cliente_Insert After Insert On Cliente
For Each Row Begin
  Insert Into Auditoria (DataModificacao, NomeTabela, Historico)
  Values (Now(), 'Cliente', Concat('Insert CodigoCliente=', New.CodigoCliente));
End$$

Create Trigger Trigger_Cliente_Update After Update On Cliente
For Each Row Begin
  Insert Into Auditoria (DataModificacao, NomeTabela, Historico)
  Values (Now(), 'Cliente', Concat('Update CodigoCliente=', New.CodigoCliente));
End$$

Create Trigger Trigger_Cliente_Delete After Delete On Cliente
For Each Row Begin
  Insert Into Auditoria (DataModificacao, NomeTabela, Historico)
  Values (Now(), 'Cliente', Concat('Delete CodigoCliente=', Old.CodigoCliente));
End$$


Create Trigger Trigger_Pedido_Insert After Insert On Pedido
For Each Row Begin
  Insert Into Auditoria (DataModificacao, NomeTabela, Historico)
  Values (Now(), 'Pedido', Concat('Insert CodigoPedido=', New.CodigoPedido));
End$$

Create Trigger Trigger_Pedido_Update After Update On Pedido
For Each Row Begin
  Insert Into Auditoria (DataModificacao, NomeTabela, Historico)
  Values (Now(), 'Pedido', Concat('Update CodigoPedido=', New.CodigoPedido));
End$$

Create Trigger Trigger_Pedido_Delete After Delete On Pedido
For Each Row Begin
  Insert Into Auditoria (DataModificacao, NomeTabela, Historico)
  Values (Now(), 'Pedido', Concat('Delete CodigoPedido=', Old.CodigoPedido));
End$$


Create Trigger Trigger_ItemPedido_Insert After Insert On ItemPedido
For Each Row Begin
  Insert Into Auditoria (DataModificacao, NomeTabela, Historico)
  Values (Now(), 'ItemPedido', Concat('Insert CodigoPedido=', New.CodigoPedido, ', CodigoProduto=', New.CodigoProduto));
End$$

Create Trigger Trigger_ItemPedido_Update After Update On ItemPedido
For Each Row Begin
  Insert Into Auditoria (DataModificacao, NomeTabela, Historico)
  Values (Now(), 'ItemPedido', Concat('Update CodigoPedido=', New.CodigoPedido, ', CodigoProduto=', New.CodigoProduto));
End$$

Create Trigger Trigger_ItemPedido_Delete After Delete On ItemPedido
For Each Row Begin
  Insert Into Auditoria (DataModificacao, NomeTabela, Historico)
  Values (Now(), 'ItemPedido', Concat('Delete CodigoPedido=', Old.CodigoPedido, ', CodigoProduto=', Old.CodigoProduto));
End$$


Create Trigger Trigger_Vendedor_Insert After Insert On Vendedor
For Each Row Begin
  Insert Into Auditoria (DataModificacao, NomeTabela, Historico)
  Values (Now(), 'Vendedor', Concat('Insert CodigoVendedor=', New.CodigoVendedor));
End$$

Create Trigger Trigger_Vendedor_Update After Update On Vendedor
For Each Row Begin
  Insert Into Auditoria (DataModificacao, NomeTabela, Historico)
  Values (Now(), 'Vendedor', Concat('Update CodigoVendedor=', New.CodigoVendedor));
End$$

Create Trigger Trigger_Vendedor_Delete After Delete On Vendedor
For Each Row Begin
  Insert Into Auditoria (DataModificacao, NomeTabela, Historico)
  Values (Now(), 'Vendedor', Concat('Delete CodigoVendedor=', Old.CodigoVendedor));
End$$

Delimiter ;

-- 5) Procedures de inserção (sem abreviações) — exceto Pedido e ItemPedido
Delimiter $$

Create Procedure Procedure_Inserir_Produto(
  In Parametro_Codigo_Produto Int,
  In Parametro_Nome Varchar(100),
  In Parametro_Descricao Varchar(255),
  In Parametro_Quantidade_Em_Estoque Int
)
Begin
  Insert Into Produto (CodigoProduto, Nome, Descricao, QuantidadeEmEstoque)
  Values (Parametro_Codigo_Produto, Parametro_Nome, Parametro_Descricao, Parametro_Quantidade_Em_Estoque);
End$$

Create Procedure Procedure_Inserir_Cliente(
  In Parametro_Codigo_Cliente Int,
  In Parametro_Nome Varchar(100),
  In Parametro_Email Varchar(150),
  In Parametro_Cpf Varchar(20)
)
Begin
  Insert Into Cliente (CodigoCliente, Nome, Email, Cpf)
  Values (Parametro_Codigo_Cliente, Parametro_Nome, Parametro_Email, Parametro_Cpf);
End$$

Create Procedure Procedure_Inserir_Funcionario(
  In Parametro_Codigo_Funcionario Int,
  In Parametro_Nome Varchar(100),
  In Parametro_Funcao Varchar(60),
  In Parametro_Cidade Varchar(80)
)
Begin
  Insert Into Funcionario (CodigoFuncionario, Nome, Funcao, Cidade)
  Values (Parametro_Codigo_Funcionario, Parametro_Nome, Parametro_Funcao, Parametro_Cidade);
End$$

Create Procedure Procedure_Inserir_Vendedor(
  In Parametro_Codigo_Vendedor Int,
  In Parametro_Nome Varchar(100),
  In Parametro_Cidade Varchar(80)
)
Begin
  Insert Into Vendedor (CodigoVendedor, Nome, Cidade)
  Values (Parametro_Codigo_Vendedor, Parametro_Nome, Parametro_Cidade);
End$$

Delimiter ;

-- 6) Tabela do Json do Carrinho e extração (sem abreviações)
Create Table CarrinhoJson (
  Id    Int Auto_Increment Primary Key,
  Dados Json
);

Insert Into CarrinhoJson (Dados) Values
(
  Json_Array(
    Json_Object('CodigoProduto', 1, 'CodigoCliente', 101, 'CodigoVendedor', 1001, 'Quantidade', 2, 'PrecoDeVenda', 10.00),
    Json_Object('CodigoProduto', 2, 'CodigoCliente', 101, 'CodigoVendedor', 1001, 'Quantidade', 1, 'PrecoDeVenda', 20.00)
  )
);

Select
  Json_Extract(Dados, '$[0].CodigoProduto')    As Primeiro_Codigo_Produto,
  Json_Extract(Dados, '$[0].CodigoCliente')    As Primeiro_Codigo_Cliente,
  Json_Extract(Dados, '$[0].CodigoVendedor')   As Primeiro_Codigo_Vendedor,
  Json_Extract(Dados, '$[0].Quantidade')       As Primeira_Quantidade,
  Json_Extract(Dados, '$[0].PrecoDeVenda')     As Primeiro_Preco_De_Venda
From CarrinhoJson
Order By Id Desc
Limit 1;

-- 7) Procedure para inserir Pedido e ItemPedido com Transacao, Cursor e validacoes (sem abreviações)
Delimiter $$

Create Procedure Procedure_Criar_Pedido_Com_Carrinho(In Parametro_Carrinho Json)
Begin
  Declare Variavel_Tamanho Int Default 0;
  Declare Variavel_Indice Int Default 0;

  Declare Variavel_Codigo_Cliente  Int;
  Declare Variavel_Codigo_Vendedor Int;
  Declare Variavel_Codigo_Produto  Int;
  Declare Variavel_Quantidade      Int;
  Declare Variavel_Preco_De_Venda  Decimal(10,2);

  Declare Variavel_Codigo_Pedido   Int;
  Declare Variavel_Existe          Int;
  Declare Variavel_Quantidade_Estoque Int;

  Declare Variavel_Fim Tinyint Default 0;

  Declare Cursor_Itens Cursor For
    Select CodigoProduto, PrecoDeVenda, Quantidade From Tabela_Temporaria_Itens;

  Declare Continue Handler For Not Found Set Variavel_Fim = 1;
  Declare Exit Handler For Sqlexception
  Begin
    Rollback;
    Select 'Erro: Transacao desfeita' As Mensagem;
  End;

  Drop Temporary Table If Exists Tabela_Temporaria_Itens;
  Create Temporary Table Tabela_Temporaria_Itens (
    CodigoProduto  Int,
    PrecoDeVenda   Decimal(10,2),
    Quantidade     Int
  ) Engine = Memory;

  Set Variavel_Tamanho = Json_Length(Parametro_Carrinho);
  If Variavel_Tamanho Is Null Or Variavel_Tamanho = 0 Then
    Select 'Carrinho vazio' As Mensagem;
    Leave Rotulo_Fim;
  End If;

  Set Variavel_Codigo_Cliente  = Json_Extract(Parametro_Carrinho, '$[0].CodigoCliente');
  Set Variavel_Codigo_Vendedor = Json_Extract(Parametro_Carrinho, '$[0].CodigoVendedor');

  Select Count(*) Into Variavel_Existe From Cliente  Where CodigoCliente  = Variavel_Codigo_Cliente;
  If Variavel_Existe = 0 Then Select 'Cliente inexistente' As Mensagem; Leave Rotulo_Fim; End If;

  Select Count(*) Into Variavel_Existe From Vendedor Where CodigoVendedor = Variavel_Codigo_Vendedor;
  If Variavel_Existe = 0 Then Select 'Vendedor inexistente' As Mensagem; Leave Rotulo_Fim; End If;

  Set Variavel_Indice = 0;
  While Variavel_Indice < Variavel_Tamanho Do
    Set Variavel_Codigo_Produto = Json_Extract(Parametro_Carrinho, Concat('$[', Variavel_Indice, '].CodigoProduto'));
    Set Variavel_Quantidade     = Json_Extract(Parametro_Carrinho, Concat('$[', Variavel_Indice, '].Quantidade'));
    Set Variavel_Preco_De_Venda = Json_Extract(Parametro_Carrinho, Concat('$[', Variavel_Indice, '].PrecoDeVenda'));
    Insert Into Tabela_Temporaria_Itens (CodigoProduto, PrecoDeVenda, Quantidade)
    Values (Variavel_Codigo_Produto, Variavel_Preco_De_Venda, Variavel_Quantidade);
    Set Variavel_Indice = Variavel_Indice + 1;
  End While;

  Start Transaction;

  Select Count(*) Into Variavel_Existe
  From Tabela_Temporaria_Itens T Left Join Produto P On P.CodigoProduto = T.CodigoProduto
  Where P.CodigoProduto Is Null;
  If Variavel_Existe > 0 Then
    Rollback;
    Select 'Produto inexistente no carrinho' As Mensagem;
    Leave Rotulo_Fim;
  End If;

  Select Count(*) Into Variavel_Existe
  From Tabela_Temporaria_Itens T Join Produto P On P.CodigoProduto = T.CodigoProduto
  Where P.QuantidadeEmEstoque < T.Quantidade;
  If Variavel_Existe > 0 Then
    Rollback;
    Select 'Quantidade em estoque insuficiente' As Mensagem;
    Leave Rotulo_Fim;
  End If;

  Insert Into Pedido (DataDoPedido, StatusDoPedido) Values (Now(), 'Novo');
  Set Variavel_Codigo_Pedido = Last_Insert_Id();

  Open Cursor_Itens;
  Rotulo_Itens: Loop
    Fetch Cursor_Itens Into Variavel_Codigo_Produto, Variavel_Preco_De_Venda, Variavel_Quantidade;
    If Variavel_Fim = 1 Then Leave Rotulo_Itens; End If;

    Insert Into ItemPedido (CodigoPedido, CodigoProduto, PrecoDeVenda, Quantidade)
    Values (Variavel_Codigo_Pedido, Variavel_Codigo_Produto, Variavel_Preco_De_Venda, Variavel_Quantidade);

    Select QuantidadeEmEstoque Into Variavel_Quantidade_Estoque
    From Produto
    Where CodigoProduto = Variavel_Codigo_Produto
    For Update;

    Update Produto
    Set QuantidadeEmEstoque = Variavel_Quantidade_Estoque - Variavel_Quantidade
    Where CodigoProduto = Variavel_Codigo_Produto;
  End Loop;
  Close Cursor_Itens;

  Commit;
  Select Concat('Pedido ', Variavel_Codigo_Pedido, ' criado com sucesso') As Mensagem;

  Rotulo_Fim: Begin End;
End$$

Delimiter ;

-- 8) View para visualizar os produtos mais vendidos (sem abreviações)
Create View View_Produtos_Mais_Vendidos As
Select
  CodigoProduto,
  Sum(Quantidade) As Total_Vendido
From ItemPedido
Group By CodigoProduto
Order By Total_Vendido Desc;
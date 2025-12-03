Use classicmodels;

Delimiter $$

Create Procedure Procedure_Fazer_Pedido_Top5_Simples (
  In Parametro_Codigo_Do_Cliente Int,
  In Parametro_Codigo_Do_Vendedor Int
)
Begin
  -- variaveis gerais do pedido
  Declare Variavel_Numero_Do_Pedido Int;
  Declare Variavel_Data_Do_Pedido Date Default Current_Date();
  Declare Variavel_Data_De_Entrega Date Default Date_Add(Current_Date(), Interval 7 Day);
  Declare Variavel_Data_Do_Pagamento Date Default Date_Add(Current_Date(), Interval 10 Day);
  Declare Variavel_Total_Do_Pedido Decimal(15,2) Default 0.00;

  -- variaveis do cursor
  Declare Variavel_Codigo_Do_Produto Varchar(15);
  Declare Variavel_Preco_Do_Produto Decimal(10,2);
  Declare Variavel_Quantidade_Em_Estoque Int;
  Declare Variavel_Numero_Da_Linha Int Default 0;
  Declare Variavel_Fim Tinyint Default 0;

  -- quando acabar o cursor
  Declare Continue Handler For Not Found Set Variavel_Fim = 1;

  -- se der erro, desfaz tudo
  Declare Exit Handler For Sqlexception
  Begin
    Rollback;
    Select 'Erro: Transacao desfeita (iniciante)' As Mensagem;
  End;

  Start Transaction;

  -- cliente deve ter limite de credito = 0 antes
  Update Customers
     Set CreditLimit = 0
   Where CustomerNumber = Parametro_Codigo_Do_Cliente;

  -- pega o proximo numero de pedido
  Select Coalesce(Max(OrderNumber) + 1, 1)
    Into Variavel_Numero_Do_Pedido
    From Orders;

  -- cria o cabecalho do pedido
  Insert Into Orders (OrderNumber, OrderDate, RequiredDate, Status, Comments, CustomerNumber)
  Values (
    Variavel_Numero_Do_Pedido,
    Variavel_Data_Do_Pedido,
    Variavel_Data_De_Entrega,
    'In Process',
    'Pedido simples com top 5 produtos mais vendidos',
    Parametro_Codigo_Do_Cliente
  );

  -- top 5 produtos mais vendidos sem abreviacao
  Declare Cursor_Top5 Cursor For
    Select
      Products.ProductCode As Codigo_Do_Produto,
      Products.MSRP As Preco_De_Venda,
      Products.QuantityInStock As Quantidade_Em_Estoque
    From Products
    Join OrderDetails
      On OrderDetails.ProductCode = Products.ProductCode
    Group By Products.ProductCode, Products.MSRP, Products.QuantityInStock
    Order By Sum(OrderDetails.QuantityOrdered) Desc
    Limit 5;

  -- abre cursor e insere produtos
  Open Cursor_Top5;

  Loop_Produtos: Loop
    Fetch Cursor_Top5 Into Variavel_Codigo_Do_Produto, Variavel_Preco_Do_Produto, Variavel_Quantidade_Em_Estoque;

    If Variavel_Fim = 1 Then
      Leave Loop_Produtos;
    End If;

    -- so insere se tiver estoque
    If Variavel_Quantidade_Em_Estoque > 0 Then
      Set Variavel_Numero_Da_Linha = Variavel_Numero_Da_Linha + 1;

      Insert Into OrderDetails (OrderNumber, ProductCode, QuantityOrdered, PriceEach, OrderLineNumber)
      Values (
        Variavel_Numero_Do_Pedido,
        Variavel_Codigo_Do_Produto,
        1,                            -- quantidade pedida simples: 1
        Variavel_Preco_Do_Produto,
        Variavel_Numero_Da_Linha
      );

      Update Products
         Set QuantityInStock = QuantityInStock - 1
       Where ProductCode = Variavel_Codigo_Do_Produto;
    End If;
  End Loop;

  Close Cursor_Top5;

  -- soma o total do pedido
  Select Coalesce(Sum(QuantityOrdered * PriceEach), 0)
    Into Variavel_Total_Do_Pedido
    From OrderDetails
   Where OrderNumber = Variavel_Numero_Do_Pedido;

  -- cria pagamento para 10 dias depois
  Insert Into Payments (CustomerNumber, CheckNumber, PaymentDate, Amount)
  Values (
    Parametro_Codigo_Do_Cliente,
    Concat('CHK', Variavel_Numero_Do_Pedido),
    Variavel_Data_Do_Pagamento,
    Variavel_Total_Do_Pedido
  );

  -- vincula vendedor e atualiza limite para 100000
  Update Customers
     Set SalesRepEmployeeNumber = Parametro_Codigo_Do_Vendedor,
         CreditLimit = 100000
   Where CustomerNumber = Parametro_Codigo_Do_Cliente;

  Commit;

  -- mensagem final
  Select Concat(
    'Pedido ', Variavel_Numero_Do_Pedido,
    ' criado para o cliente ', Parametro_Codigo_Do_Cliente,
    ' com pagamento em ', Date_Format(Variavel_Data_Do_Pagamento, '%Y-%m-%d'),
    ' e limite de credito atualizado para 100000.'
  ) As Mensagem_Final;
End$$

Delimiter ;
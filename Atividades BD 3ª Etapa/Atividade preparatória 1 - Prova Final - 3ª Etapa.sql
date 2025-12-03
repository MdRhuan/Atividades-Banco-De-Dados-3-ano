-- a) criar tabela com total por cliente e mês (mar–set/2005)
Use sakila;

Drop Table If Exists Tabela_Pagamento_Por_Cliente_Mes;
Create Table Tabela_Pagamento_Por_Cliente_Mes (
  Cliente            Varchar(100)  Not Null,
  Mes                Tinyint       Not Null,
  Total_Valor_Pago   Decimal(10,2) Not Null,
  Rental_Id          Int           Null,
  Lucro_Esperado     Decimal(10,2) Not Null Default 0.00,
  Primary Key (Cliente, Mes)
);

Insert Into Tabela_Pagamento_Por_Cliente_Mes (Cliente, Mes, Total_Valor_Pago, Rental_Id)
Select
  Concat(Customer.first_name, ' ', Customer.last_name) As Cliente,
  Month(Payment.payment_date)                          As Mes,
  Sum(Payment.amount)                                  As Total_Valor_Pago,
  Min(Rental.rental_id)                                As Rental_Id
From Payment
Join Rental   On Rental.rental_id   = Payment.rental_id
Join Customer On Customer.customer_id = Payment.customer_id
Where Payment.payment_date Between '2005-03-01' And '2005-09-30 23:59:59'
Group By Payment.customer_id, Concat(Customer.first_name, ' ', Customer.last_name), Month(Payment.payment_date);

-- b) criar tabela de log
Drop Table If Exists Tabela_Pagamento_Por_Cliente_Mes_Log;
Create Table Tabela_Pagamento_Por_Cliente_Mes_Log (
  Id        Bigint Auto_Increment Primary Key,
  Descricao Text      Not Null,
  Data      Timestamp Not Null Default Current_Timestamp()
);

-- c) criar view com quantidade de filmes
Drop View If Exists View_Pagamento_Por_Cliente_Mes_Com_Quantidade_De_Filmes;
Create View View_Pagamento_Por_Cliente_Mes_Com_Quantidade_De_Filmes As
Select
  Tabela_Pagamento_Por_Cliente_Mes.Cliente,
  Tabela_Pagamento_Por_Cliente_Mes.Mes,
  Tabela_Pagamento_Por_Cliente_Mes.Total_Valor_Pago,
  Tabela_Pagamento_Por_Cliente_Mes.Rental_Id,
  Coalesce(Subconsulta.Quantidade_De_Filmes, 0) As Quantidade_De_Filmes
From Tabela_Pagamento_Por_Cliente_Mes
Left Join (
  Select
    Concat(Customer.first_name, ' ', Customer.last_name) As Cliente,
    Month(Payment.payment_date)                          As Mes,
    Count(Film.film_id)                                  As Quantidade_De_Filmes
  From Payment
  Join Rental    On Rental.rental_id   = Payment.rental_id
  Join Inventory On Inventory.inventory_id = Rental.inventory_id
  Join Film      On Film.film_id       = Inventory.film_id
  Join Customer  On Customer.customer_id = Payment.customer_id
  Where Payment.payment_date Between '2005-03-01' And '2005-09-30 23:59:59'
  Group By Payment.customer_id, Concat(Customer.first_name, ' ', Customer.last_name), Month(Payment.payment_date)
) As Subconsulta
  On Subconsulta.Cliente = Tabela_Pagamento_Por_Cliente_Mes.Cliente
 And Subconsulta.Mes     = Tabela_Pagamento_Por_Cliente_Mes.Mes;

-- d) criar função para calcular lucro esperado
Drop Function If Exists Funcao_Calcular_Lucro_Esperado;
Delimiter $$
Create Function Funcao_Calcular_Lucro_Esperado(Parametro_Total Decimal(10,2), Parametro_Quantidade Int)
Returns Decimal(10,2)
Deterministic
Begin
  Declare Variavel_Retorno Decimal(10,2);
  If Parametro_Quantidade > 30 Then
    Set Variavel_Retorno = Round(Parametro_Total * 0.10, 2);
  Elseif Parametro_Quantidade > 20 Then
    Set Variavel_Retorno = Round(Parametro_Total * 0.05, 2);
  Else
    Set Variavel_Retorno = Round(Parametro_Total * 0.02, 2);
  End If;
  Return Variavel_Retorno;
End$$
Delimiter ;

-- e) criar trigger para logar atualização do lucro_esperado
Drop Trigger If Exists Trigger_Tabela_Pagamento_Por_Cliente_Mes_Update;
Delimiter $$
Create Trigger Trigger_Tabela_Pagamento_Por_Cliente_Mes_Update
After Update On Tabela_Pagamento_Por_Cliente_Mes
For Each Row
Begin
  If (Old.Lucro_Esperado <> New.Lucro_Esperado) Then
    Insert Into Tabela_Pagamento_Por_Cliente_Mes_Log (Descricao)
    Values (
      Concat(
        'Cliente=', New.Cliente,
        ' | Mes=', New.Mes,
        ' | Novo_Lucro_Esperado=', New.Lucro_Esperado,
        ' | Data=', Date_Format(Current_Timestamp(), '%Y-%m-%d %H:%i:%s')
      )
    );
  End If;
End$$
Delimiter ;

-- f) criar procedure sem parâmetros (usa cursor, loop, função e update)
Drop Procedure If Exists Procedure_Aplicar_Lucro_Esperado;
Delimiter $$
Create Procedure Procedure_Aplicar_Lucro_Esperado()
Begin
  -- variáveis
  Declare Variavel_Cliente Varchar(100);
  Declare Variavel_Mes Tinyint;
  Declare Variavel_Total Decimal(10,2);
  Declare Variavel_Quantidade Int;
  Declare Variavel_Lucro Decimal(10,2);
  Declare Variavel_Fim Tinyint Default 0;

  -- cursor da view
  Declare Cursor_Tabela Cursor For
    Select Cliente, Mes, Total_Valor_Pago, Quantidade_De_Filmes
    From View_Pagamento_Por_Cliente_Mes_Com_Quantidade_De_Filmes;

  Declare Continue Handler For Not Found Set Variavel_Fim = 1;

  -- abrir cursor
  Open Cursor_Tabela;

  -- loop
  Loop_Leitura: Loop
    Fetch Cursor_Tabela Into Variavel_Cliente, Variavel_Mes, Variavel_Total, Variavel_Quantidade;
    If Variavel_Fim = 1 Then
      Leave Loop_Leitura;
    End If;

    Set Variavel_Lucro = Funcao_Calcular_Lucro_Esperado(Variavel_Total, Variavel_Quantidade);

    Update Tabela_Pagamento_Por_Cliente_Mes
    Set Lucro_Esperado = Variavel_Lucro
    Where Cliente = Variavel_Cliente
      And Mes = Variavel_Mes;
  End Loop;

  -- fechar cursor
  Close Cursor_Tabela;
End$$
Delimiter ;
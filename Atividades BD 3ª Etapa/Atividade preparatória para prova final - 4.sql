-- usar o banco
Use classicmodels;

-- a) view: cliente, limitecredito, totalpago, saldo (limite - total)
Drop View If Exists View_Cliente_Limite_TotalPago_Saldo;
Create View View_Cliente_Limite_TotalPago_Saldo As
Select
  Customers.customerNumber                              As Cliente,
  Customers.creditLimit                                 As LimiteCredito,
  Coalesce(Sum(Payments.amount), 0.00)                  As TotalPago,
  Coalesce(Customers.creditLimit, 0.00)
    - Coalesce(Sum(Payments.amount), 0.00)              As Saldo
From Customers
Left Join Payments On Payments.customerNumber = Customers.customerNumber
Group By Customers.customerNumber, Customers.creditLimit;

-- b) tabela baseada na view
Drop Table If Exists Tabela_Cliente_Limite_TotalPago_Saldo;
Create Table Tabela_Cliente_Limite_TotalPago_Saldo As
Select * From View_Cliente_Limite_TotalPago_Saldo;

-- c) tabela de auditoria
Drop Table If Exists Tabela_Auditoria_De_Clientes;
Create Table Tabela_Auditoria_De_Clientes (
  Id               Bigint Auto_Increment Primary Key,
  Descricao        Text,
  DataModificacao  Timestamp Default Current_Timestamp()
);

-- d) incluir campos de juro e montante
Alter Table Tabela_Cliente_Limite_TotalPago_Saldo
  Add Column Juro     Decimal(18,2) Default 0.00,
  Add Column Montante Decimal(18,2) Default 0.00;

-- e) trigger para monitorar alterações na tabela da letra b
Drop Trigger If Exists Trigger_Tabela_Cliente_Limite_TotalPago_Saldo_After_Update;
Delimiter $$
Create Trigger Trigger_Tabela_Cliente_Limite_TotalPago_Saldo_After_Update
After Update On Tabela_Cliente_Limite_TotalPago_Saldo
For Each Row
Begin
  Insert Into Tabela_Auditoria_De_Clientes (Descricao, DataModificacao)
  Values (
    Concat(
      'Atualização do cliente ', New.Cliente,
      ' | Juro: ', Old.Juro, ' -> ', New.Juro,
      ' | Montante: ', Old.Montante, ' -> ', New.Montante
    ),
    Current_Timestamp()
  );
End$$
Delimiter ;

-- f) função de juros simples (J = C * T * I)
Drop Function If Exists Funcao_Calcular_Juros_Simples;
Delimiter $$
Create Function Funcao_Calcular_Juros_Simples(CAPITAL Decimal(18,2), TAXA Decimal(10,4), PERIODO Int)
Returns Decimal(18,2)
Deterministic
Begin
  Return Round(CAPITAL * TAXA * PERIODO, 2);
End$$
Delimiter ;

-- g) procedure: parâmetros (taxa, periodo), cursor, transação, regra do saldo negativo
Drop Procedure If Exists Procedure_Aplicar_Juros_E_Montante;
Delimiter $$
Create Procedure Procedure_Aplicar_Juros_E_Montante(IN PARAMETRO_TAXA Decimal(10,4), IN PARAMETRO_PERIODO Int)
Begin
  -- variáveis
  Declare V_CLIENTE Int;
  Declare V_SALDO   Decimal(18,2);
  Declare V_JURO    Decimal(18,2);
  Declare V_MONTANTE Decimal(18,2);
  Declare V_FIM Tinyint Default 0;

  -- cursor na tabela da letra b (já com colunas novas)
  Declare CURSOR_CLIENTES Cursor For
    Select Cliente, Saldo
    From Tabela_Cliente_Limite_TotalPago_Saldo;

  Declare Continue Handler For Not Found Set V_FIM = 1;

  Start Transaction;

  Open CURSOR_CLIENTES;

  Loop_Leitura: Loop
    Fetch CURSOR_CLIENTES Into V_CLIENTE, V_SALDO;
    If V_FIM = 1 Then
      Leave Loop_Leitura;
    End If;

    -- só calcula quando o saldo é negativo
    If V_SALDO < 0 Then
      Set V_JURO = Funcao_Calcular_Juros_Simples(V_SALDO, PARAMETRO_TAXA, PARAMETRO_PERIODO);
      Set V_MONTANTE = V_SALDO + V_JURO;

      Update Tabela_Cliente_Limite_TotalPago_Saldo
      Set Juro = V_JURO,
          Montante = V_MONTANTE
      Where Cliente = V_CLIENTE;
    End If;
  End Loop;

  Close CURSOR_CLIENTES;

  Commit;
End$$
Delimiter ;

-- h) chamada da procedure e checagem
-- exemplo: taxa 2% ao mês por 3 meses
Call Procedure_Aplicar_Juros_E_Montante(0.02, 3);

Select Cliente, LimiteCredito, TotalPago, Saldo, Juro, Montante
From Tabela_Cliente_Limite_TotalPago_Saldo
Order By Cliente;
-- a) criar tabela com os campos pedidos e carregar 100 registros
Use sakila;

Drop Table If Exists Tabela_Resumo_De_Filmes;
Create Table Tabela_Resumo_De_Filmes (
  codigo           Smallint      Not Null Primary Key,
  relacao_atores   Text          Not Null,
  categoria        Varchar(25)   Not Null,
  taxa_aluguel     Decimal(4,2)  Not Null,
  atraso           Int           Not Null Default 0,
  taxa_calculada   Decimal(10,2) Not Null Default Cast(0 As Decimal(10,2))
);

Insert Into Tabela_Resumo_De_Filmes (codigo, relacao_atores, categoria, taxa_aluguel)
Select
  Film.film_id As codigo,
  Group_Concat(Concat(Actor.first_name, ' ', Actor.last_name) Order By Actor.first_name Separator '; ') As relacao_atores,
  Category.name As categoria,
  Film.rental_rate As taxa_aluguel
From Film
Join Film_Actor   On Film_Actor.film_id   = Film.film_id
Join Actor        On Actor.actor_id       = Film_Actor.actor_id
Join Film_Category On Film_Category.film_id = Film.film_id
Join Category     On Category.category_id = Film_Category.category_id
Group By Film.film_id, Category.name, Film.rental_rate
Limit 100;

-- b) criar tabela de log
Drop Table If Exists Tabela_Log_De_Resumo_De_Filmes;
Create Table Tabela_Log_De_Resumo_De_Filmes (
  id        Bigint Auto_Increment Primary Key,
  descricao Text      Not Null,
  data      Timestamp Not Null Default Current_Timestamp()
);

-- c) criar view relacionando com quantidade no estoque (Left Join em Inventory)
Drop View If Exists View_Resumo_De_Filmes_Com_Quantidade_No_Estoque;
Create View View_Resumo_De_Filmes_Com_Quantidade_No_Estoque As
Select
  Tabela_Resumo_De_Filmes.codigo,
  Tabela_Resumo_De_Filmes.relacao_atores,
  Tabela_Resumo_De_Filmes.categoria,
  Tabela_Resumo_De_Filmes.taxa_aluguel,
  Tabela_Resumo_De_Filmes.atraso,
  Tabela_Resumo_De_Filmes.taxa_calculada,
  Coalesce(Count(Inventory.inventory_id), 0) As quantidade_filmes
From Tabela_Resumo_De_Filmes
Left Join Inventory On Inventory.film_id = Tabela_Resumo_De_Filmes.codigo
Group By
  Tabela_Resumo_De_Filmes.codigo,
  Tabela_Resumo_De_Filmes.relacao_atores,
  Tabela_Resumo_De_Filmes.categoria,
  Tabela_Resumo_De_Filmes.taxa_aluguel,
  Tabela_Resumo_De_Filmes.atraso,
  Tabela_Resumo_De_Filmes.taxa_calculada;

-- d) criar função para calcular a taxa_calculada
Drop Function If Exists Funcao_Calcular_Taxa_Calculada;
Delimiter $$
Create Function Funcao_Calcular_Taxa_Calculada(QUANTIDADE_FILMES Int, TAXA_ALUGUEL Decimal(10,4))
Returns Decimal(10,2)
Deterministic
Begin
  Declare RESULTADO Decimal(10,2);
  If QUANTIDADE_FILMES >= 6 Then
    Set RESULTADO = QUANTIDADE_FILMES * Pow(TAXA_ALUGUEL, 2);
  Else
    Set RESULTADO = QUANTIDADE_FILMES * TAXA_ALUGUEL;
  End If;
  Return RESULTADO;
End$$
Delimiter ;

-- e) criar trigger de update para logar mudanças em atraso e taxa_calculada
Drop Trigger If Exists Trigger_Tabela_Resumo_De_Filmes_Update;
Delimiter $$
Create Trigger Trigger_Tabela_Resumo_De_Filmes_Update
After Update On Tabela_Resumo_De_Filmes
For Each Row
Begin
  If (Old.atraso <> New.atraso) Or (Old.taxa_calculada <> New.taxa_calculada) Then
    Insert Into Tabela_Log_De_Resumo_De_Filmes (descricao)
    Values (
      Concat(
        'Filme=', New.codigo,
        ' | Atraso: ', Old.atraso, ' -> ', New.atraso,
        ' | Taxa_Calculada: ', Old.taxa_calculada, ' -> ', New.taxa_calculada,
        ' | Data=', Date_Format(Current_Timestamp(), '%Y-%m-%d %H:%i:%s')
      )
    );
  End If;
End$$
Delimiter ;

-- f) criar procedure sem parâmetros (usa Cursor, Loop, View e Função)
Drop Procedure If Exists Procedure_Atualizar_Tabela_Resumo_De_Filmes;
Delimiter $$
Create Procedure Procedure_Atualizar_Tabela_Resumo_De_Filmes()
Begin
  -- variáveis (em MAIÚSCULAS)
  Declare CODIGO Int;
  Declare QUANTIDADE_FILMES Int;
  Declare TAXA_ALUGUEL Decimal(10,4);
  Declare TAXA_CALCULADA Decimal(10,2);
  Declare FIM Tinyint Default 0;

  -- cursor que lê da view
  Declare CURSOR_FILMES Cursor For
    Select codigo, quantidade_filmes, taxa_aluguel
    From View_Resumo_De_Filmes_Com_Quantidade_No_Estoque;

  Declare Continue Handler For Not Found Set FIM = 1;

  -- abrir cursor
  Open CURSOR_FILMES;

  -- loop
  Loop_Leitura: Loop
    Fetch CURSOR_FILMES Into CODIGO, QUANTIDADE_FILMES, TAXA_ALUGUEL;
    If FIM = 1 Then
      Leave Loop_Leitura;
    End If;

    Set TAXA_CALCULADA = Funcao_Calcular_Taxa_Calculada(QUANTIDADE_FILMES, TAXA_ALUGUEL);

    Update Tabela_Resumo_De_Filmes
    Set atraso = QUANTIDADE_FILMES,
        taxa_calculada = TAXA_CALCULADA
    Where codigo = CODIGO;
  End Loop;

  -- fechar cursor
  Close CURSOR_FILMES;
End$$
Delimiter ;
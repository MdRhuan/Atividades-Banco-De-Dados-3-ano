-- usar o banco
Use cotemig;

-- a) view com NomeAluno, NomeDisciplina, ano, nomeSituacao, nomeDepartamento
Drop View If Exists View_Aluno_Disciplina_Ano_Situacao_Departamento;
Create View View_Aluno_Disciplina_Ano_Situacao_Departamento As
Select
  Aluno.nomeAluno           As NomeAluno,
  Disciplina.nomeDisciplina As NomeDisciplina,
  Matricula_Aluno.ano       As Ano,
  Situacao.nomeSituacao     As NomeSituacao,
  Departamento.nomeDepartamento As NomeDepartamento
From Matricula_Aluno
Join Aluno        On Aluno.codigoAluno = Matricula_Aluno.codigoAlunoMatricula
Join Disciplina   On Disciplina.codigoDisciplina = Matricula_Aluno.codigoDisciplinaMatricula
Join Situacao     On Situacao.codigoSituacao = Matricula_Aluno.situacaoMatricula
Join Departamento On Departamento.codigoDepartamento = Disciplina.codigoDepartamentoDisciplina;

-- b) view com quantidade de alunos por ano e por situação
Drop View If Exists View_Quantidade_Alunos_Por_Ano_Por_Situacao;
Create View View_Quantidade_Alunos_Por_Ano_Por_Situacao As
Select
  Matricula_Aluno.ano   As Ano,
  Situacao.nomeSituacao As NomeSituacao,
  Count(Distinct Matricula_Aluno.codigoAlunoMatricula) As QuantidadeDeAlunos
From Matricula_Aluno
Join Situacao On Situacao.codigoSituacao = Matricula_Aluno.situacaoMatricula
Group By Matricula_Aluno.ano, Situacao.nomeSituacao;

-- c) tabela baseada em consulta: quantidade de disciplinas por departamento
Drop Table If Exists Tabela_Quantidade_De_Disciplinas_Por_Departamento;
Create Table Tabela_Quantidade_De_Disciplinas_Por_Departamento As
Select
  Departamento.codigoDepartamento   As CodigoDepartamento,
  Departamento.nomeDepartamento     As NomeDepartamento,
  Count(Disciplina.codigoDisciplina) As QuantidadeDeDisciplinas
From Departamento
Left Join Disciplina On Disciplina.codigoDepartamentoDisciplina = Departamento.codigoDepartamento
Group By Departamento.codigoDepartamento, Departamento.nomeDepartamento;

-- d) tabela recuperacao
Drop Table If Exists Tabela_Recuperacao;
Create Table Tabela_Recuperacao (
  codigoAlunoRecuperacao      Int Not Null,
  codigoDisciplinaRecuperacao Int Not Null,
  nota                        Decimal(5,2) Null
);

-- e) tabela de log_recuperacao
Drop Table If Exists Tabela_Log_Recuperacao;
Create Table Tabela_Log_Recuperacao (
  idLog     Int Auto_Increment Primary Key,
  descricao Text,
  data      Timestamp Default Current_Timestamp()
);

-- f) trigger BEFORE INSERT na recuperacao (gravar mensagem com aluno e disciplina)
Drop Trigger If Exists Trigger_Tabela_Recuperacao_Before_Insert;
Delimiter $$
Create Trigger Trigger_Tabela_Recuperacao_Before_Insert
Before Insert On Tabela_Recuperacao
For Each Row
Begin
  -- variáveis
  Declare NOME_ALUNO Varchar(200);
  Declare NOME_DISCIPLINA Varchar(200);

  -- buscar nomes
  Select Aluno.nomeAluno Into NOME_ALUNO
  From Aluno
  Where Aluno.codigoAluno = New.codigoAlunoRecuperacao;

  Select Disciplina.nomeDisciplina Into NOME_DISCIPLINA
  From Disciplina
  Where Disciplina.codigoDisciplina = New.codigoDisciplinaRecuperacao;

  -- gravar log
  Insert Into Tabela_Log_Recuperacao (descricao, data)
  Values (
    Concat('Foi incluído na recuperação: ', NOME_ALUNO, ' - para a disciplina: ', NOME_DISCIPLINA, ' | data=', Date_Format(Current_Timestamp(), '%Y-%m-%d %H:%i:%s')),
    Current_Timestamp()
  );
End$$
Delimiter ;

-- g) trigger AFTER UPDATE na recuperacao (gravar mudança de nota)
Drop Trigger If Exists Trigger_Tabela_Recuperacao_After_Update;
Delimiter $$
Create Trigger Trigger_Tabela_Recuperacao_After_Update
After Update On Tabela_Recuperacao
For Each Row
Begin
  -- variáveis
  Declare NOME_ALUNO Varchar(200);

  -- buscar nome do aluno
  Select Aluno.nomeAluno Into NOME_ALUNO
  From Aluno
  Where Aluno.codigoAluno = Old.codigoAlunoRecuperacao;

  -- gravar log
  Insert Into Tabela_Log_Recuperacao (descricao, data)
  Values (
    Concat('Foi alterada a nota do aluno: ', NOME_ALUNO, ' - nota antiga: ', Coalesce(Old.nota,'NULL'), ' - nota nova: ', Coalesce(New.nota,'NULL'), ' | data=', Date_Format(Current_Timestamp(), '%Y-%m-%d %H:%i:%s')),
    Current_Timestamp()
  );
End$$
Delimiter ;

-- h) trigger DELETE na Matricula_Aluno (logar disciplina excluída)
Drop Trigger If Exists Trigger_Matricula_Aluno_After_Delete;
Delimiter $$
Create Trigger Trigger_Matricula_Aluno_After_Delete
After Delete On Matricula_Aluno
For Each Row
Begin
  -- variáveis
  Declare NOME_DISCIPLINA Varchar(200);

  -- buscar nome da disciplina
  Select Disciplina.nomeDisciplina Into NOME_DISCIPLINA
  From Disciplina
  Where Disciplina.codigoDisciplina = Old.codigoDisciplinaMatricula;

  -- gravar log
  Insert Into Tabela_Log_Recuperacao (descricao, data)
  Values (
    Concat('A disciplina: ', NOME_DISCIPLINA, ' - foi excluída | data=', Date_Format(Current_Timestamp(), '%Y-%m-%d %H:%i:%s')),
    Current_Timestamp()
  );
End$$
Delimiter ;

-- i) procedure para incluir alunos em recuperação (nota = null)
Drop Procedure If Exists Procedure_Incluir_Alunos_Em_Recuperacao;
Delimiter $$
Create Procedure Procedure_Incluir_Alunos_Em_Recuperacao()
Begin
  -- variáveis do cursor
  Declare V_CODIGO_ALUNO Int;
  Declare V_CODIGO_DISCIPLINA Int;
  Declare V_FIM Tinyint Default 0;

  -- cursor com quem está em recuperação (nome da situação começa com 'Recuper')
  Declare CURSOR_RECUPERACAO Cursor For
    Select
      Matricula_Aluno.codigoAlunoMatricula,
      Matricula_Aluno.codigoDisciplinaMatricula
    From Matricula_Aluno
    Join Situacao On Situacao.codigoSituacao = Matricula_Aluno.situacaoMatricula
    Where Situacao.nomeSituacao Like 'Recuper%';

  Declare Continue Handler For Not Found Set V_FIM = 1;

  -- abrir cursor
  Open CURSOR_RECUPERACAO;

  -- loop
  Loop_Leitura: Loop
    Fetch CURSOR_RECUPERACAO Into V_CODIGO_ALUNO, V_CODIGO_DISCIPLINA;
    If V_FIM = 1 Then
      Leave Loop_Leitura;
    End If;

    -- inserir na tabela de recuperação
    Insert Into Tabela_Recuperacao (codigoAlunoRecuperacao, codigoDisciplinaRecuperacao, nota)
    Values (V_CODIGO_ALUNO, V_CODIGO_DISCIPLINA, Null);
  End Loop;

  -- fechar cursor
  Close CURSOR_RECUPERACAO;
End$$
Delimiter ;

-- j) função para avaliar aprovação pela nota
Drop Function If Exists Funcao_Avaliar_Aprovacao;
Delimiter $$
Create Function Funcao_Avaliar_Aprovacao(NOTA_ALUNO Decimal(5,2))
Returns Varchar(80)
Deterministic
Begin
  If NOTA_ALUNO >= 60 Then
    Return 'Aprovado - Boas Férias';
  Else
    Return 'Ainda há mais uma change! Bora estudar';
  End If;
End$$
Delimiter ;

-- k) procedure para excluir matrículas por ano (ano é parâmetro)
Drop Procedure If Exists Procedure_Excluir_Matriculas_Por_Ano;
Delimiter $$
Create Procedure Procedure_Excluir_Matriculas_Por_Ano(Parametro_Ano Int)
Begin
  Delete From Matricula_Aluno
  Where ano = Parametro_Ano;
End$$
Delimiter ;
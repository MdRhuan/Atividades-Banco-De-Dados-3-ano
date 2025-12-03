Use classicmodels;

-- criando tabela de filmes
Create table if not exists tabela_de_filmes (
  identificador_do_filme int auto_increment primary key,     
  titulo_do_filme varchar(150)                              

-- criando tabela de lojas
Create table if not exists tabela_de_lojas (
  codigo_da_loja int primary key,                 
  nome_da_loja varchar(100)                                 
);

-- criando tabela de estoque de filmes
Create table if not exists tabela_de_estoque_de_filmes (
  codigo_da_loja int,                                      
  identificador_do_filme int,                               
  quantidade_de_copias int                                
);

Delimiter $$

-- procedure para incluir filmes que estao faltando no estoque
Create procedure procedure_incluir_filmes_faltantes (
  in parametro_codigo_da_loja int,                          
  in parametro_ultimo_numero_da_matricula tinyint            
)
Begin
  -- variavel que vai guardar a quantidade de copias
  Declare variavel_quantidade_de_copias int;

  -- define a quantidade de copias 
  Set variavel_quantidade_de_copias = greatest(parametro_ultimo_numero_da_matricula,1);

  -- declaracao do cursor 
  Declare cursor_de_filmes_faltantes cursor for
    select tabela_de_filmes.identificador_do_filme
    from tabela_de_filmes
    left join tabela_de_estoque_de_filmes
      on tabela_de_estoque_de_filmes.identificador_do_filme = tabela_de_filmes.identificador_do_filme
     and tabela_de_estoque_de_filmes.codigo_da_loja = parametro_codigo_da_loja
    where tabela_de_estoque_de_filmes.identificador_do_filme is null;

  -- abre e fecha o cursor
  Open cursor_de_filmes_faltantes;
  Close cursor_de_filmes_faltantes;

  -- insere todos os filmes que estao faltando de uma vez
  Insert into tabela_de_estoque_de_filmes (codigo_da_loja, identificador_do_filme, quantidade_de_copias)
  select parametro_codigo_da_loja, tabela_de_filmes.identificador_do_filme, variavel_quantidade_de_copias
  from tabela_de_filmes
  left join tabela_de_estoque_de_filmes
    on tabela_de_estoque_de_filmes.identificador_do_filme = tabela_de_filmes.identificador_do_filme
   and tabela_de_estoque_de_filmes.codigo_da_loja = parametro_codigo_da_loja
  where tabela_de_estoque_de_filmes.identificador_do_filme is null;

  -- mensagem de sucesso 
  Select concat('Filmes incluidos com sucesso na loja ',
    parametro_codigo_da_loja,
    ' com ',
    variavel_quantidade_de_copias,
    ' copias cada.') as mensagem;
End$$

Delimiter ;

-- Chamada
Call procedure_incluir_filmes_faltantes(1,4);
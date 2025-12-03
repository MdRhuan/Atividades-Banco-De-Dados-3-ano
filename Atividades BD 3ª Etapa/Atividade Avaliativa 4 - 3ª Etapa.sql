Use sakila;

Create table if not exists tabela_log_customer (
  id int auto_increment primary key,
  operacao varchar(20),
  id_cliente int,
  ativo_antigo tinyint,
  ativo_novo tinyint,
  data_log timestamp default current_timestamp
);

Create table if not exists tabela_log_payment (
  id int auto_increment primary key,
  operacao varchar(20),
  id_pagamento int,
  id_cliente int,
  id_rental int,
  valor decimal(5,2),
  data_pagamento datetime,
  data_log timestamp default current_timestamp
);

Create table if not exists tabela_log_rental (
  id int auto_increment primary key,
  operacao varchar(20),
  id_rental int,
  id_cliente int,
  id_inventory int,
  data_rental datetime,
  data_retorno datetime,
  data_log timestamp default current_timestamp
);

Delimiter $$

Create trigger trigger_customer_update
After update on customer
For each row
Begin
  Insert into tabela_log_customer (operacao, id_cliente, ativo_antigo, ativo_novo)
  Values ('UPDATE', old.customer_id, old.active, new.active);
End$$

Create trigger trigger_payment_insert
After insert on payment
For each row
Begin
  Insert into tabela_log_payment (operacao, id_pagamento, id_cliente, id_rental, valor, data_pagamento)
  Values ('INSERT', new.payment_id, new.customer_id, new.rental_id, new.amount, new.payment_date);
End$$

Create trigger trigger_rental_insert
After insert on rental
For each row
Begin
  Insert into tabela_log_rental (operacao, id_rental, id_cliente, id_inventory, data_rental, data_retorno)
  Values ('INSERT', new.rental_id, new.customer_id, new.inventory_id, new.rental_date, new.return_date);
End$$

Delimiter ;

Delimiter $$

Create procedure procedure_alugar_filmes_inativos()
Begin
  -- variaveis simples
  Declare variavel_id_cliente int;
  Declare variavel_id_filme int;
  Declare variavel_valor decimal(5,2);
  Declare variavel_inventory int;
  Declare variavel_duracao_minima int;
  Declare acabou_clientes tinyint default 0;
  Declare acabou_filmes tinyint default 0;

  -- cursor para clientes inativos com gasto acima de 50
  Declare cursor_clientes Cursor For
    Select c.customer_id
    From customer c
    Join payment p On p.customer_id = c.customer_id
    Where c.active = 0
    Group by c.customer_id
    Having sum(p.amount) > 50
    Limit 5;

  -- cursor para os 5 filmes mais alugados
  Declare cursor_filmes Cursor For
    Select f.film_id
    From film f
    Join inventory i On i.film_id = f.film_id
    Join rental r On r.inventory_id = i.inventory_id
    Group by f.film_id
    Order by count(*) desc
    Limit 5;

  -- handlers
  Declare continue handler for not found set acabou_clientes = 1;

  Start transaction;

  -- pegar menor rental_duration dos 5 filmes
  Select min(rental_duration) into variavel_duracao_minima
  From (
    Select f.rental_duration
    From film f
    Join inventory i On i.film_id = f.film_id
    Join rental r On r.inventory_id = i.inventory_id
    Group by f.film_id, f.rental_duration
    Order by count(*) desc
    Limit 5
  ) as tabela_duracao;

  -- abrir cursor de clientes
  Open cursor_clientes;

  loop_clientes: Loop
    Fetch cursor_clientes into variavel_id_cliente;
    If acabou_clientes = 1 Then
      Leave loop_clientes;
    End if;

    -- para cada cliente
    Set acabou_filmes = 0;
    Declare continue handler for not found set acabou_filmes = 1;
    Open cursor_filmes;

    loop_filmes: Loop
      Fetch cursor_filmes into variavel_id_filme;
      If acabou_filmes = 1 Then
        Leave loop_filmes;
      End if;

      -- pega um inventory do filme
      Select min(inventory_id) into variavel_inventory
      From inventory
      Where film_id = variavel_id_filme;

      -- pega o valor do aluguel
      Select rental_rate into variavel_valor
      From film
      Where film_id = variavel_id_filme;

      -- insere rental
      Insert into rental (rental_date, inventory_id, customer_id, staff_id)
      Values (now(), variavel_inventory, variavel_id_cliente, 1);

      -- insere payment
      Insert into payment (customer_id, staff_id, rental_id, amount, payment_date)
      Values (variavel_id_cliente, 1, last_insert_id(), variavel_valor, date_add(now(), interval variavel_duracao_minima day));
    End loop;

    Close cursor_filmes;
  End loop;

  Close cursor_clientes;

  Commit;

  Select 'Processo concluido' as mensagem;
End$$

Delimiter ;
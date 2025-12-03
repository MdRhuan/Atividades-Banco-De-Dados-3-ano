-- 1ª parte - views (sakila)

-- Questão 1.1
Use sakila;
Create Or Replace View vw_filmes_vistos_clientes_inativos_pais_A As
Select Distinct film.film_id, film.title, country.country, customer.customer_id, 
       Concat(customer.first_name,' ',customer.last_name) As cliente
From film
Join inventory On film.film_id = inventory.film_id
Join rental On inventory.inventory_id = rental.inventory_id
Join customer On rental.customer_id = customer.customer_id
Join address On customer.address_id = address.address_id
Join city On address.city_id = city.city_id
Join country On city.country_id = country.country_id
Where customer.active = 0
  And country.country Like 'A%';

-- Questão 1.2
Use sakila;
Create Or Replace View vw_filme_ator_categoria_sem_estoque As
Select film.film_id, film.title,
       Concat(actor.first_name,' ', actor.last_name) As ator,
       category.category_id, category.name As categoria
From film
Join film_actor On film.film_id = film_actor.film_id
Join actor On film_actor.actor_id = actor.actor_id
Join film_category On film.film_id = film_category.film_id
Join category On film_category.category_id = category.category_id
Left Join inventory On film.film_id = inventory.film_id
Where inventory.inventory_id Is Null;

-- Questão 1.3
Use sakila;
Create Or Replace View vw_filmes_unificado As
Select Distinct film.film_id, film.title, category.name As categoria, 'Alugados_Maio_2005' As origem
From film
Join film_category On film.film_id = film_category.film_id
Join category On film_category.category_id = category.category_id
Join inventory On film.film_id = inventory.film_id
Join rental On inventory.inventory_id = rental.inventory_id
Where category.name In ('Action','Drama','Documentary')
  And Year(rental.rental_date) = 2005
  And Month(rental.rental_date) = 5

Union

Select Distinct film.film_id, film.title, category.name As categoria, 'Duracao_Tamanho' As origem
From film
Join film_category On film.film_id = film_category.film_id
Join category On film_category.category_id = category.category_id
Where category.name In ('Animation','Comedy','Horror')
  And film.rental_duration < 5
  And film.length > 100;

-- Questão 1.4
Use sakila;
Create Table If Not Exists total_pagamentos_por_loja As
Select store.store_id, store.manager_staff_id, 
       Sum(payment.amount) As total_pagamentos, 
       Count(payment.payment_id) As qtde_pagamentos
From payment
Join staff On payment.staff_id = staff.staff_id
Join store On staff.store_id = store.store_id
Group By store.store_id, store.manager_staff_id;

-- Questão 1.5
Use sakila;
Create Table If Not Exists stats_pagamentos_por_loja As
Select
    store.store_id As store_id,
    Avg(payment.amount) As avg_payment,
    Sum(payment.amount) As sum_payment,
    Count(payment.payment_id) As count_payment,
    Max(payment.amount) As max_payment,
    Min(payment.amount) As min_payment
From
    payment
    Inner Join staff On payment.staff_id = staff.staff_id
    Inner Join store On staff.store_id = store.store_id
Group By
    store.store_id;

-- Questão 1.6
Use sakila;
Create Table If Not Exists total_pagamentos_mar_set_2005_clientes_inativos As
Select payment.customer_id, Concat(customer.first_name,' ',customer.last_name) As cliente,
       Sum(payment.amount) As total_pagamentos
From payment
Join customer On payment.customer_id = customer.customer_id
Where customer.active = 0
  And payment.payment_date Between '2005-03-01' And '2005-09-30 23:59:59'
Group By payment.customer_id, cliente;

-- Questão 1.7
Use sakila;
Create Table If Not Exists filme_ator_categoria As
Select film.film_id, film.title,
       Concat(actor.first_name,' ',actor.last_name) As actor_name, actor.actor_id,
       category.name As category_name, category.category_id
From film
Join film_actor On film.film_id = film_actor.film_id
Join actor On film_actor.actor_id = actor.actor_id
Join film_category On film.film_id = film_category.film_id
Join category On film_category.category_id = category.category_id;

-- Questão 1.8
Use sakila;
Create Or Replace View vw_estoque_aluguel As
Select inventory.inventory_id, rental.rental_id, rental.customer_id, 
       filme_ator_categoria.film_id, filme_ator_categoria.title, filme_ator_categoria.category_id, filme_ator_categoria.category_name
From filme_ator_categoria
Join inventory On filme_ator_categoria.film_id = inventory.film_id
Left Join rental On inventory.inventory_id = rental.inventory_id;

-- Questão 1.9
Use sakila;
Create Or Replace View vw_pagamento_categoria As
Select vw_estoque_aluguel.category_id, vw_estoque_aluguel.category_name, 
       Sum(payment.amount) As total_pagamentos
From vw_estoque_aluguel
Join rental On vw_estoque_aluguel.rental_id = rental.rental_id
Join payment On rental.rental_id = payment.rental_id
Group By vw_estoque_aluguel.category_id, vw_estoque_aluguel.category_name;

-- Questão 1.10
Use sakila;
Create Table If Not Exists clientes_ativos As
Select Concat(customer.first_name,' ',customer.last_name) As cliente, city.city As cidade, 
       country.country As pais, customer.customer_id
From customer
Join address On customer.address_id = address.address_id
Join city On address.city_id = city.city_id
Join country On city.country_id = country.country_id
Where customer.active = 1;

Create Or Replace View vw_clientes_categoria As
Select vw_estoque_aluguel.category_id, vw_estoque_aluguel.category_name, 
       Count(Distinct vw_estoque_aluguel.customer_id) As qtde_clientes
From vw_estoque_aluguel
Join clientes_ativos On clientes_ativos.customer_id = vw_estoque_aluguel.customer_id
Group By vw_estoque_aluguel.category_id, vw_estoque_aluguel.category_name;

-- 2ª parte - procedures

-- Questão 2.1
Use classicmodels;
Drop Procedure If Exists proc_classic_customers;
Delimiter $$
Create Procedure proc_classic_customers()
Begin
  Select * From customers;
End$$
Delimiter ;

-- Questão 2.2
Use classicmodels;
Drop Procedure If Exists proc_vendas_por_escritorio_ano;
Delimiter $$
Create Procedure proc_vendas_por_escritorio_ano(In p_city Varchar(100), In p_ano Int)
Begin
  Select orderdetails.productCode, products.productName,
         Sum(orderdetails.quantityOrdered) As quantidade_vendida,
         Sum(orderdetails.quantityOrdered * orderdetails.priceEach) As total_vendido
  From orderdetails
  Join orders On orderdetails.orderNumber = orders.orderNumber
  Join customers On orders.customerNumber = customers.customerNumber
  Join employees On customers.salesRepEmployeeNumber = employees.employeeNumber
  Join offices On employees.officeCode = offices.officeCode
  Join products On orderdetails.productCode = products.productCode
  Where offices.city = p_city
    And Year(orders.orderDate) = p_ano
  Group By orderdetails.productCode, products.productName
  Order By quantidade_vendida Desc;
End$$
Delimiter ;

-- Questão 2.3
Use classicmodels;
Drop Procedure If Exists proc_clientes_por_escritorio;
Delimiter $$
Create Procedure proc_clientes_por_escritorio()
Begin
  Select offices.officeCode, offices.city,
         Count(customers.customerNumber) As qtde_clientes
  From offices
  Left Join employees On offices.officeCode = employees.officeCode
  Left Join customers On customers.salesRepEmployeeNumber = employees.employeeNumber
  Group By offices.officeCode, offices.city;
End$$
Delimiter ;

-- Questão 2.4
Use classicmodels;
Drop Procedure If Exists proc_total_vendido_ano;
Delimiter $$
Create Procedure proc_total_vendido_ano(In p_ano Int)
Begin
  Select Year(orders.orderDate) As ano,
         Sum(orderdetails.quantityOrdered * orderdetails.priceEach) As total_vendido
  From orders
  Join orderdetails On orders.orderNumber = orderdetails.orderNumber
  Where Year(orders.orderDate) = p_ano
  Group By Year(orders.orderDate);
End$$
Delimiter ;

-- Questão 2.5
Use classicmodels;
Drop Procedure If Exists proc_top10_produtos_ano;
Delimiter $$
Create Procedure proc_top10_produtos_ano(In p_ano Int)
Begin
  Declare done Int Default 0;
  Declare v_productCode Varchar(50);
  Declare v_qty Int;
  Declare v_total Decimal(18,2);
  Declare v_prod_max_total Varchar(50) Default '';
  Declare v_prod_max_qty Varchar(50) Default '';
  Declare v_max_total Decimal(18,2) Default 0;
  Declare v_max_qty Int Default 0;
  
  Declare cur Cursor For
    Select orderdetails.productCode, 
           Sum(orderdetails.quantityOrdered) As qty, 
           Sum(orderdetails.quantityOrdered * orderdetails.priceEach) As total
    From orderdetails
    Join orders On orderdetails.orderNumber = orders.orderNumber
    Where Year(orders.orderDate) = p_ano
    Group By orderdetails.productCode
    Order By qty Desc, total Desc
    Limit 10;
    
  Declare Continue Handler For Not Found Set done = 1;

  Open cur;
  read_loop: Loop
    Fetch cur Into v_productCode, v_qty, v_total;
    If done = 1 Then
      Leave read_loop;
    End If;
    
    If v_qty > v_max_qty Then
      Set v_max_qty = v_qty;
      Set v_prod_max_qty = v_productCode;
    End If;
    
    If v_total > v_max_total Then
      Set v_max_total = v_total;
      Set v_prod_max_total = v_productCode;
    End If;
  End Loop;
  Close cur;

  If v_prod_max_total = v_prod_max_qty Then
    Select Concat('Produto ', v_prod_max_total, ' está acima das expectativas') As resultado;
  Else
    Select Concat('Produtos diferentes: Maior quantidade=', v_prod_max_qty, 
                 ', Maior valor=', v_prod_max_total) As resultado;
  End If;
End$$
Delimiter ;

-- Questão 2.6
Use classicmodels;
Create Table If Not Exists Vendedor_Avaliacao (
  Vendedor Varchar(100),
  Avaliacao Varchar(100)
);

Drop Procedure If Exists proc_avaliar_vendedores;
Delimiter $$
Create Procedure proc_avaliar_vendedores()
Begin
  Declare v_done Int Default 0;
  Declare v_vendedor Varchar(100);
  Declare v_qtde Int;
  
  Declare cur Cursor For
    Select Ifnull(Count(customers.customerNumber), 0) As QTDECLIENTE,
           Concat(employees.lastName, ' ', employees.firstName) As VENDEDOR
    From employees
    Left Join customers On customers.salesRepEmployeeNumber = employees.employeeNumber
    Where employees.jobTitle Like '%Sales Rep%'
    Group By employees.employeeNumber, VENDEDOR
    Order By QTDECLIENTE;
    
  Declare Continue Handler For Not Found Set v_done = 1;

  Truncate Table Vendedor_Avaliacao;

  Open cur;
  fetch_loop: Loop
    Fetch cur Into v_qtde, v_vendedor;
    If v_done = 1 Then
      Leave fetch_loop;
    End If;

    If v_qtde > 8 Then
      Insert Into Vendedor_Avaliacao (Vendedor, Avaliacao)
      Values (v_vendedor, 'Você executou um excelente trabalho');
    Elseif v_qtde Between 6 And 8 Then
      Insert Into Vendedor_Avaliacao (Vendedor, Avaliacao)
      Values (v_vendedor, 'Bom trabalho, mas pode melhorar');
    Elseif v_qtde > 0 And v_qtde < 6 Then
      Insert Into Vendedor_Avaliacao (Vendedor, Avaliacao)
      Values (v_vendedor, 'Acreditamos no seu potencial, precisa de apoio?');
    Else
      Insert Into Vendedor_Avaliacao (Vendedor, Avaliacao)
      Values (v_vendedor, 'Passar no RH');
    End If;
  End Loop;
  Close cur;
End$$
Delimiter ;

-- Questão 2.7
Use escola;
Create Table If Not Exists DadosAluno (
  MatriculaAluno Int Primary Key,
  Nota_PI Decimal(5,2),
  Nota_PR Decimal(5,2),
  Nota_PF Decimal(5,2),
  Total_Faltas Int,
  Faltas_Possiveis Int
);

Drop Procedure If Exists proc_situacao_aluno;
Delimiter $$
Create Procedure proc_situacao_aluno(In p_matricula Int)
Begin
  Declare v_nota_total Decimal(7,2);
  Declare v_total_faltas Int;
  Declare v_faltas_possiveis Int;
  Declare v_percent_faltas Decimal(5,2);
  Declare v_situacao Varchar(50);
  
  Select Coalesce(Nota_PI,0) + Coalesce(Nota_PR,0) + Coalesce(Nota_PF,0),
         Total_Faltas, Faltas_Possiveis
  Into v_nota_total, v_total_faltas, v_faltas_possiveis
  From DadosAluno
  Where MatriculaAluno = p_matricula;

  If v_faltas_possiveis > 0 Then
    Set v_percent_faltas = (v_total_faltas / v_faltas_possiveis) * 100;
  Else
    Set v_percent_faltas = 0;
  End If;

  If v_percent_faltas <= 25 Then
    Set v_situacao = 'Aprovado';
  Elseif v_percent_faltas > 25 And v_percent_faltas <= 40 And v_nota_total >= 90 Then
    Set v_situacao = 'Aprovado';
  Else
    If v_nota_total >= 60 Then
      Set v_situacao = 'Aprovado';
    Elseif v_nota_total Between 45 And 59.99 Then
      Set v_situacao = 'Recuperacao';
    Else
      Set v_situacao = 'Reprovado';
    End If;
  End If;

  Select v_situacao As situacao, v_nota_total As nota_total, 
         Round(v_percent_faltas, 2) As perc_faltas;
End$$
Delimiter ;

-- Questão 2.8
Use util;
Create Table If Not Exists Sacola (
  id Int Auto_increment Primary Key,
  qtd_bolas Int Not Null
);

Drop Procedure If Exists proc_gerenciar_sacola;
Delimiter $$
Create Procedure proc_gerenciar_sacola(In p_operacao Varchar(10), In p_qtd Int)
Begin
  Declare v_qtd_atual Int Default 0;
  Declare v_capacidade Int Default 100;
  Declare v_nova_qtde Int;

  Select Coalesce(qtd_bolas, 0) Into v_qtd_atual 
  From Sacola 
  Order By id Desc 
  Limit 1;

  If p_operacao = 'inserir' Then
    If p_qtd <= 0 Then
      Select '** O VALOR INSERIDO É INVALIDO. POR FAVOR, TENTE NOVAMENTE! **' As mensagem;
    Elseif v_qtd_atual + p_qtd > v_capacidade Then
      Select '** VOCÊ ULTRAPASSOU A CAPACIDADE DA SACOLA. POR FAVOR, INSIRA OUTRO VALOR. **' As mensagem;
    Else
      If v_qtd_atual = 0 And Not Exists (Select 1 From Sacola) Then
        Insert Into Sacola (qtd_bolas) Values (p_qtd);
      Else
        Update Sacola Set qtd_bolas = qtd_bolas + p_qtd;
      End If;
      Select 'Inserido com sucesso' As mensagem, v_qtd_atual + p_qtd As nova_qtde;
    End If;

  Elseif p_operacao = 'remover' Then
    If p_qtd < 0 Then
      Set p_qtd = Abs(p_qtd);
    End If;
    
    If p_qtd >= v_qtd_atual Then
      Update Sacola Set qtd_bolas = 0;
      Select 'Bolas excluídas da sacola' As mensagem, 0 As nova_qtde;
    Else
      Update Sacola Set qtd_bolas = qtd_bolas - p_qtd;
      Select 'Removido com sucesso' As mensagem, v_qtd_atual - p_qtd As nova_qtde;
    End If;

  Elseif p_operacao = 'alterar' Then
    If p_qtd < 0 Then
      Select '** O VALOR INSERIDO É INVALIDO. POR FAVOR, TENTE NOVAMENTE! **' As mensagem;
    Elseif p_qtd > v_capacidade Then
      Select '** VOCÊ ULTRAPASSOU A CAPACIDADE DA SACOLA. POR FAVOR,
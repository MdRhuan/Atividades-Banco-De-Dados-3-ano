Use classicmodels;

Create Or Replace View v_receita_clientes_mgr1143 As
Select
  employees_vendedor.employeeNumber,
  employees_vendedor.firstName,
  employees_vendedor.lastName,
  Ifnull(Sum(payments_pagamento.amount), 0)           As total_recebido,
  Count(Distinct customers_cliente.customerNumber)     As quantidade_clientes
From employees As employees_vendedor
Join customers As customers_cliente
  On customers_cliente.salesRepEmployeeNumber = employees_vendedor.employeeNumber
Left Join payments As payments_pagamento
  On payments_pagamento.customerNumber = customers_cliente.customerNumber
Where
  employees_vendedor.reportsTo = 1143
  And customers_cliente.creditLimit > 100000
Group By
  employees_vendedor.employeeNumber,
  employees_vendedor.firstName,
  employees_vendedor.lastName;

Create Or Replace View v_recebido_por_vendedor_cliente As
Select
  employees_vendedor.employeeNumber,
  employees_vendedor.firstName,
  employees_vendedor.lastName,
  customers_cliente.customerNumber,
  Ifnull(Sum(payments_pagamento.amount), 0) As total_recebido
From employees As employees_vendedor
Join customers As customers_cliente
  On customers_cliente.salesRepEmployeeNumber = employees_vendedor.employeeNumber
Left Join payments As payments_pagamento
  On payments_pagamento.customerNumber = customers_cliente.customerNumber
Where
  employees_vendedor.reportsTo = 1143
  And customers_cliente.creditLimit > 100000
Group By
  employees_vendedor.employeeNumber,
  employees_vendedor.firstName,
  employees_vendedor.lastName,
  customers_cliente.customerNumber;

With visao_recebido_vendedor_cliente As (
  Select * From v_recebido_por_vendedor_cliente
),
ordens_primeiro_trimestre_2003 As (
  Select
    employees_vendedor.employeeNumber,
    Count(Distinct orders_pedido.orderNumber) As total_pedidos,
    Sum(orderdetails_item_pedido.quantityOrdered) As total_produtos
  From orders As orders_pedido
  Join orderdetails As orderdetails_item_pedido
    On orderdetails_item_pedido.orderNumber = orders_pedido.orderNumber
  Join customers As customers_cliente
    On customers_cliente.customerNumber = orders_pedido.customerNumber
  Join employees As employees_vendedor
    On employees_vendedor.employeeNumber = customers_cliente.salesRepEmployeeNumber
  Where
    orders_pedido.orderDate >= '2003-01-01'
    And orders_pedido.orderDate  < '2003-04-01'
  Group By
    employees_vendedor.employeeNumber
),
recebimentos_primeiro_trimestre_2003 As (
  Select
    visao_recebido_vendedor_cliente.employeeNumber,
    Sum(payments_pagamento.amount) As total_recebido
  From visao_recebido_vendedor_cliente
  Join payments As payments_pagamento
    On payments_pagamento.customerNumber = visao_recebido_vendedor_cliente.customerNumber
  Where
    payments_pagamento.paymentDate >= '2003-01-01'
    And payments_pagamento.paymentDate  < '2003-04-01'
  Group By
    visao_recebido_vendedor_cliente.employeeNumber
)
Select
  employees_vendedor.employeeNumber,
  employees_vendedor.firstName,
  employees_vendedor.lastName,
  Ifnull(recebimentos_primeiro_trimestre_2003.total_recebido, 0) As total_recebido,
  Ifnull(ordens_primeiro_trimestre_2003.total_pedidos, 0)        As total_pedidos,
  Ifnull(ordens_primeiro_trimestre_2003.total_produtos, 0)       As total_produtos
From employees As employees_vendedor
Join (

  Select Distinct employeeNumber From visao_recebido_vendedor_cliente
) As vendedores_filtrados
  On vendedores_filtrados.employeeNumber = employees_vendedor.employeeNumber
Left Join recebimentos_primeiro_trimestre_2003
  On recebimentos_primeiro_trimestre_2003.employeeNumber = employees_vendedor.employeeNumber
Left Join ordens_primeiro_trimestre_2003
  On ordens_primeiro_trimestre_2003.employeeNumber = employees_vendedor.employeeNumber
Order By
  employees_vendedor.employeeNumber;

Create Or Replace View v_giro_margem As
Select
  products_produto.productCode As codigo_produto,
  ((products_produto.MSRP / products_produto.buyPrice) - 1) * 100 As margem_percentual,
  (
    Sum(orderdetails_item_pedido.quantityOrdered)
    / Nullif(Sum(orderdetails_item_pedido.quantityOrdered) + products_produto.quantityInStock, 0) * 100
  ) As percentual_vendido
From products As products_produto
Left Join orderdetails As orderdetails_item_pedido
  On orderdetails_item_pedido.productCode = products_produto.productCode
Group By
  products_produto.productCode,
  products_produto.MSRP,
  products_produto.buyPrice,
  products_produto.quantityInStock;


Create Table If Not Exists ANALISE_GIRO_MARGEM (
  PRODUTO    Varchar(10)  Not Null,
  OBSERVACAO Varchar(200) Not Null
);

Delimiter $$
Create Procedure sp_analisar_giro_margem()
Begin

  Truncate Table ANALISE_GIRO_MARGEM;

  Insert Into ANALISE_GIRO_MARGEM (PRODUTO, OBSERVACAO)
  Select
    products_produto.productCode As PRODUTO,
    Case
      When (((products_produto.MSRP / products_produto.buyPrice) - 1) * 100) >= 100
           And (
                 (Sum(orderdetails_item_pedido.quantityOrdered)
                  / Nullif(Sum(orderdetails_item_pedido.quantityOrdered) + products_produto.quantityInStock, 0) * 100)
               ) > 20
        Then 'Produto alto giro e excelente margem. Manter preço.'
      When (((products_produto.MSRP / products_produto.buyPrice) - 1) * 100) >= 100
           And (
                 (Sum(orderdetails_item_pedido.quantityOrdered)
                  / Nullif(Sum(orderdetails_item_pedido.quantityOrdered) + products_produto.quantityInStock, 0) * 100)
               ) < 10
        Then 'Produto baixo giro e excelente margem. Reduzir preço de venda.'
      When (((products_produto.MSRP / products_produto.buyPrice) - 1) * 100) < 100
           And (
                 (Sum(orderdetails_item_pedido.quantityOrdered)
                  / Nullif(Sum(orderdetails_item_pedido.quantityOrdered) + products_produto.quantityInStock, 0) * 100)
               ) > 20
        Then 'Produto alto giro e baixa margem. Aumentar preço de venda.'
      Else 'Manter os valores praticados.'
    End
  From products As products_produto
  Left Join orderdetails As orderdetails_item_pedido
    On orderdetails_item_pedido.productCode = products_produto.productCode
  Group By
    products_produto.productCode,
    products_produto.MSRP,
    products_produto.buyPrice,
    products_produto.quantityInStock;
End$$
Delimiter ;

Use sakila;
Delimiter $$

Create Procedure sp_faturamento_por_categoria(In parametro_categoria Varchar(25))
Begin
  Select
    category_categoria.name                    As categoria,
    Count(Distinct film_filme.film_id)         As quantidade_filmes_distintos,
    Round(Sum(payment_pagamento.amount), 2)    As valor_total_faturado
  From category As category_categoria
  Join film_category As relacao_filme_categoria
    On relacao_filme_categoria.category_id = category_categoria.category_id
  Join film As film_filme
    On film_filme.film_id = relacao_filme_categoria.film_id
  Join inventory As inventory_inventario
    On inventory_inventario.film_id = film_filme.film_id
  Join rental As rental_locacao
    On rental_locacao.inventory_id = inventory_inventario.inventory_id
  Join payment As payment_pagamento
    On payment_pagamento.rental_id = rental_locacao.rental_id
  Where
    category_categoria.name = parametro_categoria
  Group By
    category_categoria.name;
End$$
Delimiter ;

Use world;

Create Table If Not Exists chn_language_speakers As 
Select countrylanguage_idioma_pais.Language As language,
    Round(Sum((countrylanguage_idioma_pais.Percentage / 100.0) * country_pais.Population),
            0) As total_speakers 
From
    CountryLanguage As countrylanguage_idioma_pais
        Join
    Country As country_pais On country_pais.Code = countrylanguage_idioma_pais.CountryCode
Where
    countrylanguage_idioma_pais.CountryCode = 'CHN'
Group By countrylanguage_idioma_pais.Language;
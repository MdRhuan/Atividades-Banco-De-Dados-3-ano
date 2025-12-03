-- A
Create View view_produtos_mais_vendidos_2003 As
Select 
  products.productCode,
  products.productName,
  Sum(orderdetails.quantityOrdered) As quantidade_total
From products
Join orderdetails On products.productCode = orderdetails.productCode
Join orders On orders.orderNumber = orderdetails.orderNumber
Where Year(orders.orderDate) = 2003
Group By products.productCode, products.productName
Order By quantidade_total Desc
Limit 20;

Update view_produtos_mais_vendidos_2003
Set productName = 'Produto alterado'
Where productCode = 'S10_1678';

-- Erro: error 1288 (hy000): the target table view_mais_vendidos_2003 of the update is not updatable
-- Como essa view faz soma, agrupamento e ordenação, ela não pode ser atualizada. 


-- B
Create View view_precos_paris_2004 As
Select 
  Month(orders.orderDate) As mes,
  Avg(orderdetails.priceEach) As preco_medio,
  Max(orderdetails.priceEach) As preco_maximo,
  Min(orderdetails.priceEach) As preco_minimo
From orders
Join orderdetails On orders.orderNumber = orderdetails.orderNumber
Join customers On orders.customerNumber = customers.customerNumber
Join employees On customers.salesRepEmployeeNumber = employees.employeeNumber
Join offices On employees.officeCode = offices.officeCode
Where Year(orders.orderDate) = 2004 And offices.city = 'Paris'
Group By Month(orders.orderDate);

Update view_precos_paris_2004
Set preco_medio = 99.99
Where mes = 3;

-- Erro:error 1288 (hy000): the target table view_precos_paris_2004 of the update is not updatable
-- A view não pode ser alterada porque ela usa funções de agregação (avg, max, min) e group by. 

-- C
Create View view_qtd_produtos_setembro_dezembro As
Select 
  orders.requiredDate As data_entrega,
  Sum(orderdetails.quantityOrdered) As total_produtos
From orders
Join orderdetails On orders.orderNumber = orderdetails.orderNumber
Where Month(orders.requiredDate) Between 9 And 12
Group By orders.requiredDate;

Update view_qtd_produtos_setembro_dezembro
Set total_produtos = 999
Where data_entrega = '2004-11-05';

-- Erro: error 1288 (hy000): the target table view_qtd_produtos_setembro_dezembro of the update is not updatable
-- View tá fazendo soma e agrupando por data. 
-- Isso vira um resumo das linhas reais, e o banco não tem como adivinhar o que você tá tentando mudar lá nas tabelas originais.

-- D

Create View view_total_clientes_por_cidade As
Select 
  offices.city As cidade,
  Count(customers.customerNumber) As total_clientes
From customers
Join employees On customers.salesRepEmployeeNumber = employees.employeeNumber
Join offices On employees.officeCode = offices.officeCode
Group By offices.city
Order By total_clientes Desc;


Update view_total_clientes_por_cidade
Set total_clientes = 100
Where cidade = 'Paris';

-- Erro: error 1288 (hy000): the target table view_total_clientes_por_cidade of the update is not updatable
-- View tá contando (count), agrupando (group by) e ainda ordenando (order by). 
-- Isso transforma várias linhas em uma só por cidade, e o banco não tem como saber qual cliente ou funcionário você tá querendo mudar.

-- E
Create View view_produtos_menos_vendidos_2004 As
Select 
  products.productCode,
  products.productName,
  Sum(orderdetails.quantityOrdered) As total_vendido
From products
Join orderdetails On products.productCode = orderdetails.productCode
Join orders On orders.orderNumber = orderdetails.orderNumber
Where Year(orders.orderDate) = 2004 And Month(orders.orderDate) Between 1 And 6
Group By products.productCode, products.productName
Order By total_vendido Asc
Limit 15;

Update view_produtos_menos_vendidos_2004
Set productName = 'Produto fraco'
Where productCode = 'S12_1666';

-- Erro: error 1288 (hy000): the target table view_produtos_menos_vendidos_2004 of the update is not updatable
-- Essa view tem group by, soma (sum) e limit. 
-- Tudo isso impede o banco de deixar você alterar os dados por ali, porque ele não sabe qual linha real da tabela original você quer mexer.

-- F
Create View view_precos_ny_2003 As
Select 
  Month(orders.orderDate) As mes,
  Avg(orderdetails.priceEach) As preco_medio,
  Max(orderdetails.priceEach) As preco_maximo,
  Min(orderdetails.priceEach) As preco_minimo
From orders
Join orderdetails On orders.orderNumber = orderdetails.orderNumber
Join customers On orders.customerNumber = customers.customerNumber
Join employees On customers.salesRepEmployeeNumber = employees.employeeNumber
Join offices On employees.officeCode = offices.officeCode
Where Year(orders.orderDate) = 2003 And offices.city = 'NY'
Group By Month(orders.orderDate);

Update view_precos_ny_2003
Set preco_medio = 75
Where mes = 4;

-- Erro: error 1288 (hy000): the target table view_precos_ny_2003 of the update is not updatable
-- Porque tem média (avg), maior, menor, group by, tudo isso junta várias linhas numa só por mês.
-- O banco não tem como saber qual linha original você quer mudar.

-- G
Create View view_menor_qtd_produto_setembro_dezembro As
Select 
  orderdetails.productCode,
  Min(orderdetails.quantityOrdered) As menor_quantidade
From orders
Join orderdetails On orders.orderNumber = orderdetails.orderNumber
Where Month(orders.requiredDate) Between 9 And 12
Group By orderdetails.productCode;

Update view_menor_qtd_produto_setembro_dezembro
Set menor_quantidade = 1
Where productCode = 'S18_2248';

-- Erro: error 1288 (hy000): the target table view_menor_qtd_produto_setembro_dezembro of the update is not updatable
-- View faz uso de min e group by, ou seja, ela junta várias linhas de pedidos em uma linha por produto. 
-- Não dá pra alterar direto porque o banco não sabe de qual pedido original você quer mudar a quantidade.

-- H
Create View view_total_clientes_por_cidade As
Select 
  offices.city As cidade,
  Count(customers.customerNumber) As total_clientes
From customers
Join employees On customers.salesRepEmployeeNumber = employees.employeeNumber
Join offices On employees.officeCode = offices.officeCode
Group By offices.city
Order By total_clientes Desc;

Update view_total_clientes_por_cidade
Set total_clientes = 300
Where cidade = 'Paris';

-- Erro: error 1288 (hy000): the target table view_total_clientes_por_cidade of the update is not updatable
-- A view tem count, group by e order by. 
-- É uma linha resumida por cidade, e o banco não tem como saber qual cliente real ou funcionário você tá querendo mexer.
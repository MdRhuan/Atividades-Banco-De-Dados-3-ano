USE classicmodels;

#A
DROP VIEW IF EXISTS view_produtos_mais_vendidos_2003;
CREATE VIEW view_produtos_mais_vendidos_2003 AS
SELECT 
  products.productCode,
  products.productName,
  SUM(orderdetails.quantityOrdered) AS quantidade_total
FROM products
JOIN orderdetails ON products.productCode = orderdetails.productCode
JOIN orders ON orders.orderNumber = orderdetails.orderNumber
WHERE YEAR(orders.orderDate) = 2003
GROUP BY products.productCode, products.productName
ORDER BY quantidade_total DESC
LIMIT 20;

UPDATE view_produtos_mais_vendidos_2003
SET productName = 'Produto Alterado'
WHERE productCode = 'S10_1678';

#ERRO: ERROR 1288 (HY000): The target table view_mais_vendidos_2003 of the UPDATE is not updatable
#Como essa view faz soma, agrupamento e ordenação, ela não pode ser atualizada. 


#B
DROP VIEW IF EXISTS view_precos_paris_2004;
CREATE VIEW view_precos_paris_2004 AS
SELECT 
  MONTH(orders.orderDate) AS mes,
  AVG(orderdetails.priceEach) AS preco_medio,
  MAX(orderdetails.priceEach) AS preco_maximo,
  MIN(orderdetails.priceEach) AS preco_minimo
FROM orders
JOIN orderdetails ON orders.orderNumber = orderdetails.orderNumber
JOIN customers ON orders.customerNumber = customers.customerNumber
JOIN employees ON customers.salesRepEmployeeNumber = employees.employeeNumber
JOIN offices ON employees.officeCode = offices.officeCode
WHERE YEAR(orders.orderDate) = 2004 AND offices.city = 'Paris'
GROUP BY MONTH(orders.orderDate);

UPDATE view_precos_paris_2004
SET preco_medio = 99.99
WHERE mes = 3;

#ERRO:ERROR 1288 (HY000): The target table view_precos_paris_2004 of the UPDATE is not updatable
#a view não pode ser alterada porque ela usa funções de agregação (AVG, MAX, MIN) e GROUP BY. 

#C
DROP VIEW IF EXISTS view_qtd_produtos_setembro_dezembro;
CREATE VIEW view_qtd_produtos_setembro_dezembro AS
SELECT 
  orders.requiredDate AS data_entrega,
  SUM(orderdetails.quantityOrdered) AS total_produtos
FROM orders
JOIN orderdetails ON orders.orderNumber = orderdetails.orderNumber
WHERE MONTH(orders.requiredDate) BETWEEN 9 AND 12
GROUP BY orders.requiredDate;

UPDATE view_qtd_produtos_setembro_dezembro
SET total_produtos = 999
WHERE data_entrega = '2004-11-05';

#ERRO: ERROR 1288 (HY000): The target table view_qtd_produtos_setembro_dezembro of the UPDATE is not updatable
#view tá fazendo soma e agrupando por data. 
#Isso vira um resumo das linhas reais, e o banco não tem como adivinhar o que você tá tentando mudar lá nas tabelas originais.

#D
DROP VIEW IF EXISTS view_total_clientes_por_cidade;
CREATE VIEW view_total_clientes_por_cidade AS
SELECT 
  offices.city AS cidade,
  COUNT(customers.customerNumber) AS total_clientes
FROM customers
JOIN employees ON customers.salesRepEmployeeNumber = employees.employeeNumber
JOIN offices ON employees.officeCode = offices.officeCode
GROUP BY offices.city
ORDER BY total_clientes DESC;


UPDATE view_total_clientes_por_cidade
SET total_clientes = 100
WHERE cidade = 'Paris';

#ERRO: ERROR 1288 (HY000): The target table view_total_clientes_por_cidade of the UPDATE is not updatable
#view tá contando (COUNT), agrupando (GROUP BY) e ainda ordenando (ORDER BY). 
#Isso transforma várias linhas em uma só por cidade, e o banco não tem como saber qual cliente ou funcionário você tá querendo mudar.

#E
DROP VIEW IF EXISTS view_produtos_menos_vendidos_2004;
CREATE VIEW view_produtos_menos_vendidos_2004 AS
SELECT 
  products.productCode,
  products.productName,
  SUM(orderdetails.quantityOrdered) AS total_vendido
FROM products
JOIN orderdetails ON products.productCode = orderdetails.productCode
JOIN orders ON orders.orderNumber = orderdetails.orderNumber
WHERE YEAR(orders.orderDate) = 2004 AND MONTH(orders.orderDate) BETWEEN 1 AND 6
GROUP BY products.productCode, products.productName
ORDER BY total_vendido ASC
LIMIT 15;

UPDATE view_produtos_menos_vendidos_2004
SET productName = 'Produto Fraco'
WHERE productCode = 'S12_1666';

#ERRO: ERROR 1288 (HY000): The target table view_produtos_menos_vendidos_2004 of the UPDATE is not updatable
#essa view tem GROUP BY, soma (SUM) e LIMIT. 
#Tudo isso impede o banco de deixar você alterar os dados por ali, porque ele não sabe qual linha real da tabela original você quer mexer.

#F
DROP VIEW IF EXISTS view_precos_ny_2003;
CREATE VIEW view_precos_ny_2003 AS
SELECT 
  MONTH(orders.orderDate) AS mes,
  AVG(orderdetails.priceEach) AS preco_medio,
  MAX(orderdetails.priceEach) AS preco_maximo,
  MIN(orderdetails.priceEach) AS preco_minimo
FROM orders
JOIN orderdetails ON orders.orderNumber = orderdetails.orderNumber
JOIN customers ON orders.customerNumber = customers.customerNumber
JOIN employees ON customers.salesRepEmployeeNumber = employees.employeeNumber
JOIN offices ON employees.officeCode = offices.officeCode
WHERE YEAR(orders.orderDate) = 2003 AND offices.city = 'NY'
GROUP BY MONTH(orders.orderDate);

UPDATE view_precos_ny_2003
SET preco_medio = 75
WHERE mes = 4;

#ERRO: ERROR 1288 (HY000): The target table view_precos_ny_2003 of the UPDATE is not updatable
#porque tem média (AVG), maior, menor, GROUP BY, tudo isso junta várias linhas numa só por mês.
#O banco não tem como saber qual linha original você quer mudar.

#G
DROP VIEW IF EXISTS view_menor_qtd_produto_setembro_dezembro;
CREATE VIEW view_menor_qtd_produto_setembro_dezembro AS
SELECT 
  orderdetails.productCode,
  MIN(orderdetails.quantityOrdered) AS menor_quantidade
FROM orders
JOIN orderdetails ON orders.orderNumber = orderdetails.orderNumber
WHERE MONTH(orders.requiredDate) BETWEEN 9 AND 12
GROUP BY orderdetails.productCode;

UPDATE view_menor_qtd_produto_setembro_dezembro
SET menor_quantidade = 1
WHERE productCode = 'S18_2248';

#ERRO: ERROR 1288 (HY000): The target table view_menor_qtd_produto_setembro_dezembro of the UPDATE is not updatable
#view faz uso de MIN e GROUP BY, ou seja, ela junta várias linhas de pedidos em uma linha por produto. 
#Não dá pra alterar direto porque o banco não sabe de qual pedido original você quer mudar a quantidade.

#H
DROP VIEW IF EXISTS view_total_clientes_por_cidade;
CREATE VIEW view_total_clientes_por_cidade AS
SELECT 
  offices.city AS cidade,
  COUNT(customers.customerNumber) AS total_clientes
FROM customers
JOIN employees ON customers.salesRepEmployeeNumber = employees.employeeNumber
JOIN offices ON employees.officeCode = offices.officeCode
GROUP BY offices.city
ORDER BY total_clientes DESC;

UPDATE view_total_clientes_por_cidade
SET total_clientes = 300
WHERE cidade = 'Paris';

#ERRO: ERROR 1288 (HY000): The target table view_total_clientes_por_cidade of the UPDATE is not updatable
#A view tem COUNT, GROUP BY e ORDER BY. 
#É uma linha resumida por cidade, e o banco não tem como saber qual cliente real ou funcionário você tá querendo mexer.

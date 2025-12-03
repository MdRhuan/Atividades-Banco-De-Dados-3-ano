Create View vw_empregado_2003 As
Select employees.employeeNumber, employees.firstName, employees.lastName,
       Count(orders.orderNumber) As qtd_pedidos,
       Sum(orderdetails.priceEach * orderdetails.quantityOrdered) As faturamento,
       Sum(orderdetails.quantityOrdered) As total_produtos
From employees
Join customers On customers.salesRepEmployeeNumber = employees.employeeNumber
Join orders On orders.customerNumber = customers.customerNumber
Join orderdetails On orderdetails.orderNumber = orders.orderNumber
Where employees.reportsTo = 1102 And Year(orders.orderDate) = 2003
Group By employees.employeeNumber, employees.firstName, employees.lastName;

With produtos_nao_comprados As (
    Select products.productCode, products.productName
    From products
    Left Join orderdetails On products.productCode = orderdetails.productCode
    Where orderdetails.productCode Is Null
)
Select * From produtos_nao_comprados;

Create View vw_vendas_2004 As
Select products.productCode, products.productName,
       orderdetails.priceEach As precoVenda,
       products.MSRP As precoFabrica
From products
Join orderdetails On products.productCode = orderdetails.productCode
Join orders On orderdetails.orderNumber = orders.orderNumber
Where Year(orders.orderDate) = 2004;

Create Table analise_de_venda (
    CodigoProduto Varchar(10),
    Observacao Varchar(300)
);

Delimiter $$

Create Procedure sp_analise_venda()
Begin
    Insert Into analise_de_venda (CodigoProduto, Observacao)
    Select vw_vendas_2004.productCode, 'Produto analisado'
    From vw_vendas_2004;
End$$

Delimiter ;

Delimiter 

Create Procedure sp_filmes_por_loja(In loja_id Int)
Begin
    Select category.name, Count(inventory.inventory_id) As qtd_filmes
    From inventory
    Join film On film.film_id = inventory.film_id
    Join film_category On film_category.film_id = film.film_id
    Join category On category.category_id = film_category.category_id
    Where inventory.store_id = loja_id
    Group By category.name;
End 

Delimiter ;

Create Table tabela_portugues As
Select country.Name, country.Region,
       Sum((countrylanguage.Percentage * country.Population) / 100) As total_falantes
From country
Join countrylanguage On country.Code = countrylanguage.CountryCode
Where countrylanguage.Language = 'Portuguese'
  And country.Continent = 'North America'
Group By country.Name, country.Region;
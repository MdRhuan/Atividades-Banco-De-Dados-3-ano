-- 1) CLIENTES, TOTAL PAGO E DESCONTO

Use classicmodels;

Drop View If Exists View_Cliente_Total_Pago_Desconto;

Create View View_Cliente_Total_Pago_Desconto As
Select
    Customers.customerName As NomeDoCliente,
    Sum(Payments.amount) As TotalPago,
    Case
        When Sum(Payments.amount) > 50000 Then Sum(Payments.amount) * 0.05
        When Sum(Payments.amount) > 20000 Then Sum(Payments.amount) * 0.03
        When Sum(Payments.amount) > 10000 Then Sum(Payments.amount) * 0.02
        Else 0
    End As Desconto
From Payments
Inner Join Customers On Customers.customerNumber = Payments.customerNumber
Where Year(Payments.paymentDate) In (2003, 2004)
  And Month(Payments.paymentDate) Between 1 And 6
Group By NomeDoCliente
Order By Desconto Desc
Limit 50;

-- 2) UNIFICAÇÃO DAS 3 CONSULTAS

-- CONSULTA 1 – PRODUTOS > 550 EM 2004
Drop View If Exists View_Produtos_Mais_Vendidos;

Create View View_Produtos_Mais_Vendidos As
Select
    'PRODUTOS' As TipoDeRegistro,
    Products.productName As NomeDoProduto
From Products
Inner Join OrderDetails On OrderDetails.productCode = Products.productCode
Inner Join Orders On Orders.orderNumber = OrderDetails.orderNumber
Where Year(Orders.orderDate) = 2004
Group By NomeDoProduto
Having Sum(OrderDetails.quantityOrdered) > 550;


-- CONSULTA 2 – CLIENTES > 100K (PARIS / TOKYO – 2003)
Drop View If Exists View_Clientes_Acima_De_100_Mil;

Create View View_Clientes_Acima_De_100_Mil As
Select
    'CLIENTES' As TipoDeRegistro,
    Customers.customerName As NomeDoCliente
From Customers
Inner Join Payments On Payments.customerNumber = Customers.customerNumber
Inner Join Employees On Employees.employeeNumber = Customers.salesRepEmployeeNumber
Inner Join Offices On Offices.officeCode = Employees.officeCode
Where Year(Payments.paymentDate) = 2003
  And Offices.city In ('Paris', 'Tokyo')
Group By NomeDoCliente
Having Sum(Payments.amount) > 100000;


-- CONSULTA 3 – VENDEDORES > 200K EM 2005
Drop View If Exists View_Vendedores_Acima_De_200_Mil;

Create View View_Vendedores_Acima_De_200_Mil As
Select
    'VENDEDORES' As TipoDeRegistro,
    Concat(Employees.firstName, ' ', Employees.lastName) As NomeDoVendedor
From Customers
Inner Join Payments On Payments.customerNumber = Customers.customerNumber
Inner Join Employees On Employees.employeeNumber = Customers.salesRepEmployeeNumber
Where Year(Payments.paymentDate) = 2005
Group By NomeDoVendedor
Having Sum(Payments.amount) > 200000;


-- VIEW FINAL UNIFICADA
Drop View If Exists View_Unificacao_Total;

Create View View_Unificacao_Total As
Select * From View_Clientes_Acima_De_100_Mil
Union
Select * From View_Produtos_Mais_Vendidos
Union
Select * From View_Vendedores_Acima_De_200_Mil;

-- 3) TOTAL DE CLIENTES POR PAÍS - SAKILA

Use sakila;

Drop View If Exists View_Quantidade_De_Clientes_Por_Pais;

Create View View_Quantidade_De_Clientes_Por_Pais As
Select
    Country.country As NomeDoPais,
    Count(Distinct Customer.customer_id) As QuantidadeDeClientes
From Country
Inner Join City On City.country_id = Country.country_id
Inner Join Address On Address.city_id = City.city_id
Inner Join Customer On Customer.address_id = Address.address_id
Inner Join Payment On Payment.customer_id = Customer.customer_id
Where Year(Payment.payment_date) = 2005
  And Month(Payment.payment_date) In (5, 6, 7)
Group By NomeDoPais
Order By QuantidadeDeClientes Desc
Limit 10;
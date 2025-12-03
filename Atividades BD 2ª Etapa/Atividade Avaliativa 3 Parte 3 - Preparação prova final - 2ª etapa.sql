Drop Table Credito_cliente;
Create Table Credito_cliente (
    Cliente Varchar(100),
    Total Decimal(10,2),
    Limite_credito Decimal(10,2),
    Analise Varchar(100)
);
Insert Into Credito_cliente (Cliente, Total, Limite_credito, Analise)
Select 
    c.customerName,
    Sum(p.amount) As Total,
    c.creditLimit,
    Case 
        When (c.creditLimit - Sum(p.amount)) < 0 Then 'Entrar em contato com o cliente'
        Else 'Sugerir aumento de crédito'
    End As Analise
From customers c
Join payments p On c.customerNumber = p.customerNumber
Join employees e On c.salesRepEmployeeNumber = e.employeeNumber
Join offices o On e.officeCode = o.officeCode
Where Year(p.paymentDate) In (2003, 2005)
  And c.creditLimit > 100000
  And e.jobTitle = 'Sales Rep'
  And o.city = 'San Francisco'
Group By c.customerName, c.creditLimit;

Drop Table If Exists Analise_lucro;
Create Table Analise_lucro (
    Produto Varchar(100),
    Media Decimal(10,2),
    Analise Varchar(100)
);
Insert Into Analise_lucro (Produto, Media, Analise)
Select 
    p.productName,
    Round(Avg(((od.priceEach / p.buyPrice) - 1) * 100), 2) As Media,
    Case
        When Round(Avg(((od.priceEach / p.buyPrice) - 1) * 100), 2) < 30 Then 'Chamar o representante imediatamente'
        When Round(Avg(((od.priceEach / p.buyPrice) - 1) * 100), 2) < 50 Then 'Aumentar margem de lucro'
        When Round(Avg(((od.priceEach / p.buyPrice) - 1) * 100), 2) < 100 Then 'Manter o valor'
        Else 'Conceder mais 10% de desconto'
    End As Analise
From products p
Join orderdetails od On p.productCode = od.productCode
Join orders o On od.orderNumber = o.orderNumber
Join customers c On o.customerNumber = c.customerNumber
Join employees e On c.salesRepEmployeeNumber = e.employeeNumber
Join offices ofc On e.officeCode = ofc.officeCode
Where ofc.city = 'San Francisco'
  And c.country = 'USA'
Group By p.productName;

Select * From Credito_cliente;
Select * From Analise_lucro;
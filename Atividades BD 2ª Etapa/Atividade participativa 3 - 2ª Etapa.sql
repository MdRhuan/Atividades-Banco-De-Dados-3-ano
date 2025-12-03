Use classicmodels;

Select 
    products.productName,
    orderdetails.priceEach,
    products.buyPrice,
    products.MSRP,
    ((orderdetails.priceEach / products.buyPrice) - 1) * 100 As lucroSobreCompra_percent,
    ((orderdetails.priceEach / products.MSRP) - 1) * 100 As lucroSobreSugerido_percent
From 
    orderdetails
Join 
    orders On orderdetails.orderNumber = orders.orderNumber
Join 
    customers On orders.customerNumber = customers.customerNumber
Join 
    employees On customers.salesRepEmployeeNumber = employees.employeeNumber
Join 
    offices On employees.officeCode = offices.officeCode
Join 
    products On orderdetails.productCode = products.productCode
Where 
    offices.city In ('Paris', 'Tokyo', 'London')
    And (
        (Year(orders.orderDate) = 2004 And Month(orders.orderDate) In (10, 11, 12)) Or
        (Year(orders.orderDate) = 2005 And Month(orders.orderDate) In (10, 11, 12))
    );


-- View 1
Create View viewlucrodetalhado As
Select 
    products.productName,
    orderdetails.priceEach,
    products.buyPrice,
    products.MSRP,
    ((orderdetails.priceEach / products.buyPrice) - 1) * 100 As lucroComprapercent,
    ((orderdetails.priceEach / products.MSRP) - 1) * 100 As lucroSugeridopercent
From 
    orderdetails
Join 
    orders On orderdetails.orderNumber = orders.orderNumber
Join 
    customers On orders.customerNumber = customers.customerNumber
Join 
    employees On customers.salesRepEmployeeNumber = employees.employeeNumber
Join 
    offices On employees.officeCode = offices.officeCode
Join 
    products On orderdetails.productCode = products.productCode
Where 
    offices.city In ('Paris', 'Tokyo', 'London')
    And (
        (Year(orders.orderDate) = 2004 And Month(orders.orderDate) In (10, 11, 12)) Or
        (Year(orders.orderDate) = 2005 And Month(orders.orderDate) In (10, 11, 12))
    );

-- View 2
Create View viewlucromedia As
Select 
    productName,
    Avg(lucroComprapercent) As mediaLucroComprapercent,
    Avg(lucroSugeridopercent) As mediaLucroSugeridopercent
From 
    viewlucrodetalhado
Group By 
    productName;
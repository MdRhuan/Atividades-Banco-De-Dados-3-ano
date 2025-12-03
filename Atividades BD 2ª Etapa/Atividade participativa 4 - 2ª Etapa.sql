Use classicmodels;

With cte_orderdetails As (
    Select 
        orderNumber, 
        productCode, 
        priceEach
    From orderdetails
),
cte_orders As (
    Select 
        orderNumber, 
        customerNumber, 
        orderDate
    From orders
),
cte_customers As (
    Select 
        customerNumber, 
        salesRepEmployeeNumber
    From customers
),
cte_employees As (
    Select 
        employeeNumber, 
        officeCode
    From employees
),
cte_offices As (
    Select 
        officeCode, 
        city
    From offices
),
cte_products As (
    Select 
        productCode, 
        productName, 
        buyPrice, 
        MSRP
    From products
)

Select 
    products.productName,
    orderdetails.priceEach,
    products.buyPrice,
    products.MSRP,
    ((orderdetails.priceEach / products.buyPrice) - 1) * 100 As lucroSobreCompra_percent,
    ((orderdetails.priceEach / products.MSRP) - 1) * 100 As lucroSobrePrecoSugerido_percent
From 
    cte_orderdetails As orderdetails
Join 
    cte_orders As orders On orderdetails.orderNumber = orders.orderNumber
Join 
    cte_customers As customers On orders.customerNumber = customers.customerNumber
Join 
    cte_employees As employees On customers.salesRepEmployeeNumber = employees.employeeNumber
Join 
    cte_offices As offices On employees.officeCode = offices.officeCode
Join 
    cte_products As products On orderdetails.productCode = products.productCode
Where 
    offices.city In ('Paris', 'Tokyo', 'London')
    And (
        (Year(orders.orderDate) = 2004 And Month(orders.orderDate) In (10, 11, 12))
        Or
        (Year(orders.orderDate) = 2005 And Month(orders.orderDate) In (10, 11, 12))
    );
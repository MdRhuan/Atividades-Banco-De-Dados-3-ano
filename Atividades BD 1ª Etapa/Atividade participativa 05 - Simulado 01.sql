--  Simulado B  

Select 
    language.name as Idioma,
    category.name as Categoria,
    count(rental.rental_id) as Quantidade_alugada,
    sum(payment.amount) as Valor_acumulado
From
    rental
        inner Join
    inventory on rental.inventory_id = inventory.inventory_id
        inner Join
    film on inventory.film_id = film.film_id
        inner join 
    language on film.language_id = language.language_id
        Inner Join
    film_category on film.film_id = film_category.film_id
        inner join
    category on film_category.category_id = category.category_id
        inner join 
    payment on rental.rental_id = payment.rental_id
Where 
    Year (rental.rental_date) = 2005
group by language.name , category.name
Order BY Quantidade_alugada desc , Valor_acumulado Desc;

Select 
    products.productName AS Produto,
    sum(orderdetails.quantityOrdered) as Quantidade_vendida
From
    orderdetails
        Inner join
    orders on orderdetails.orderNumber = orders.orderNumber
        Inner join 
    products on orderdetails.productCode = products.productCode
Where
    Year(orders.orderDate) = 2003
group by products.productName
Order By Quantidade_vendida Desc
Limit 20;

Select  
    Month(orders.orderDate) as Mes,
    Avg(orderdetails.priceEach) as Valor_medio,
    max(orderdetails.priceEach) as Valor_maximo,
    min(orderdetails.priceEach) as Valor_minimo
From
    orderdetails
        Inner join 
    orders on orderdetails.orderNumber = orders.orderNumber
        Inner join
    customers on orders.customerNumber = customers.customerNumber
        Inner join
    employees on customers.salesRepEmployeeNumber = employees.employeeNumber
        Inner join
    offices on employees.officeCode = offices.officeCode
Where
    Year(orders.orderDate) = 2004
        and offices.city = 'Paris'
group by Mes
Order By Mes;

Select 
    products.productName as Produto,
    SUM(orderdetails.quantityOrdered) as Quantidade
From
    orderdetails
        Inner join 
    orders on orderdetails.orderNumber = orders.orderNumber
         Inner join 
    products on orderdetails.productCode = products.productCode
Where
    Month(orders.requiredDate) between 9 And 12
group by products.productName
Order By Quantidade Desc;

Select 
    offices.city as Cidade_escritorio,
    COUNT(customers.customerNumber) as Total_clientes
From
    customers
        Inner join 
    employees on customers.salesRepEmployeeNumber = employees.employeeNumber
        Inner join 
    offices on employees.officeCode = offices.officeCode
group by offices.city
Order By Total_clientes Desc;
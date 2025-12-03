-- PAG 40
use sakila;

-- A 
select * 
From city
inner Join Adress on city.city+id = Adress.city_id;

-- B
select * 
From Adress
inner Join customer on Adress.adress_id = Customer.Adress_id;

-- C 
select * 
From Customer
inner Join Paymants on Customer.customer_id = Paymants.customer_id;

-- D
Select *
From Paymants
inner Join Customer on Paymants.customer_id = Customer.customer_id;

--E 
Select *
From Film 
inner Join Lenguage on film.language_id = Lenguage.lenguage_id;

-- PAG 41
-- 3
Select Count(Adress_id) As QuantidadeDeEnderecos, City.City As Cidade
From City
inner Join Adress on (City.City_id = Address.Address_id) 
Group By City.City;

-- A
Select lenguage.name As Idioma, Count(Film.film_id) As QuantidadeDeFilmes
From Film film  
inner Join Language lenguage on film.lenguage_id = lenguage.lenguage_id
Group By lenguage.name;

-- B
Select s.store_id, Sum(payments.amount) As LucroBruto
From Payment 
inner Join Customer on Payment.customer_id = Customer.customer_id
inner Join Store on Customer.store_id = Store.store_id
Group By Store.store_id;

-- C 
Select Store.store_id, Count(Customer.customer_id) As QuantidadeClientes
From Customer 
inner Join Store on Customer.store_id = Store.store-id
Group By Store.store_id;

-- D
Select s.store_id,
       Avg(p.amount) As Media_Pagamento,
       Sum(p.amount) As Total_Pagamentos,
       Count(p.payment_id) As Quantidade_Pagamentos,
       Max(p.amount) As Pagamento_Maximo,
       Min(p.amount) As Pagamento_Minimo
From Payment p
inner Join Customer c on p.customer_id = c.customer_id
inner Join Store s on c.store_id = s.store_id
Group By s.store_id;

-- E
Select c.customer_id, c.first_name, c.lAst_name, SUM(p.amount) As TotalPagamentos
From Payment p
inner Join Customer c on p.customer_id = c.customer_id
Group By c.customer_id, c.first_name, c.lAst_name;

-- F
Select l.name As Idioma, Count(f.film_id) As QuantidadeFilmes
From Film f
inner Join Language l on f.language_id = l.language_id
WHERE f.length Between 100 And 150
Group By l.name;

-- G
Select s.store_id, Sum(p.amount) As TotalPagamentos
From Payment p
inner Join Customer c on p.customer_id = c.customer_id
inner Join Store s on c.store_id = s.store_id
WHERE Month(p.payment_date) in (8, 9)
Group By s.store_id;

-- H
Select s.store_id, Count(c.customer_id) As QuantidadeClientes
From Customer c
inner Join Store s on c.store_id = s.store_id
WHERE c.lAst_name Like 'R%'
Group By s.store_id;

-- PAG42
-- 4
Select * From Country
inner Join City on (Country.Country_id = City.Country_id)
inner Join Address On (City.City_id = Address.City_id);

-- A
Select *
From City c
inner Join Address a On c.city_id = a.city_id
inner Join Customer cu On a.address_id = cu.address_id;

-- B
Select *
From Customer c
inner Join Payment p On c.customer_id = p.customer_id
inner Join Rental r On c.customer_id = r.customer_id;

-- C
Select *
From Film f
inner Join Film_Category fc On f.film_id = fc.film_id
inner Join Category cat On fc.category_id = cat.category_id;

-- D
Select *
From Actor a
inner Join Film_Actor fa On a.actor_id = fa.actor_id
inner Join Film f On fa.film_id = f.film_id;

-- E
Select ci.city, Count(cu.customer_id) As QuantidadeClientes
From City ci
inner Join Address a On ci.city_id = a.city_id
inner Join Customer cu On a.address_id = cu.address_id
Group By ci.city;

-- F
Select a.first_name, a.lAst_name, Count(f.film_id) As QuantidadeFilmes
From Actor a
inner Join Film_Actor fa On a.actor_id = fa.actor_id
Inner JoIn Film f On fa.film_id = f.film_id
WHERE f.rental_duratiOn In (3,7)
  And f.length Between 60 And 150
  And f.replacement_cost > 12.00
Group By a.actor_id;

-- G
Select c.name As Categoria, SUM(f.replacement_cost) As TotalMulta
From Film f
Inner JoIn Film_Actor fa On f.film_id = fa.film_id
Inner JoIn Film_Category fc On f.film_id = fc.film_id
Inner JoIn Category c On fc.category_id = c.category_id
WHERE f.rental_duratiOn In (3,7)
  And f.length Between 60 And 150
  And f.replacement_cost > 12.00
Group By c.name;

-- PAG43

Select * From Country
Inner JoIn City On (Country.Country_id = City.Country_id)
Inner JoIn Address On (City.City_id = Address.City_id)
Inner JoIn Customer On (Address.Address_id = Customer.Address_id)
Inner JoIn Paymants On (Customer.customer_id = Payment.customer_id);

-- a
Select *
From City ci
Inner JoIn Address a On ci.city_id = a.city_id
Inner JoIn Customer cu On a.address_id = cu.address_id
Inner JoIn Payment p On cu.customer_id = p.customer_id;

-- B
Select *
From Store s
Inner JoIn Staff st On s.store_id = st.store_id
Inner JoIn Payment p On st.staff_id = p.staff_id
Inner JoIn Rental r On p.rental_id = r.rental_id
Inner JoIn Inventory i on r.Inventory_id = i.Inventory_id
Inner JoIn Film f on i.film_id = f.film_id;

-- c
Select * From Actor a
Inner JoIn Film_Actor on Actor.actor_id = Film_Actor.actor_id
Inner JoIn Film on Film_Actor.film_id = film.film_id
Inner JoIn Inventory on film.film_id = film.film_id
Inner JoIn Rental on Inventory.Inventory_id = r.Inventory_id
Inner JoIn Payment on Rental.rental_id = Payment.rental_id
Inner JoIn Customer on Payment.customer_id = Customer.customer_id
Inner JoIn Address ad on cu.address_id = ad.address_id
Inner JoIn City ci on ad.city_id = ci.city_id
inner Join Country co on ci.Country_id = co.Country_id;

-- RHUAN MATAVELLI AMARAL - 51
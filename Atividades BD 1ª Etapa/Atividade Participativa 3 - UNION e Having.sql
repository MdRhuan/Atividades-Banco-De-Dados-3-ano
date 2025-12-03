use classicmodels;

select * from products;
select * from customers;
select * from payments;

(select customerNumber, sum(amount) from payments group by CustomerNunber limit 5)
union
(select productCode, productName from products limit 5);

-- Entrar base sakila, criarr uma uniao das consulatas (Clientes ativos que realizaram pagamentos
-- de 2005 entre agosto a outrubro e como o pais que comce com a letra a e 
-- Retonar o nome dos clientes inativos, que sao residentes dis paises que comcem com a letra c

use sakila;

select 
concat(firt_name,' ', last_name) as nomeCliente  from customers 
inner join adress using (adress_id)
inner join city using (city_id)
inner join country using (country_id)

where 
coutry like 'C%'
and active = 0

union -- O all Vai repetir
select
 concat(firt_name,' ', last_name) as nomeCliente 
from payments 
inner join customer using (customer_id)
inner join city using (city_id)
inner join country using (country_id)
inner join adress using (adress_id)

where 
year (payments_date) = 2005
and month (payments_date) between 8 and 10
and coutry like'A%'
and active = 1;

use clasicmodels;

select CustumerName as nomeCcompleto, sum(amont) as total
from payments 

inner join cutumer using( custumerNumber)
group by nomeCompleto having total > 100000;

-- Crie uma consulta, unificando as duas consultas abaixo
-- Retorne os clientes e limite de credito, para aqueles que fizeram pagamento entre o ano de 2003 a 2005, no primeiro trimestre 
-- retorne os clientes e o total pago, para aqueles que realizaram pagament no segundo trimestr de 2006 

select 
customerName as nomeCliente,
creditLimit as limiteCredito
from customers
inner join payments using (customerNumber)
where
year(paymentsDate) between 2003 and 2005
and month(paymentsDate) in (1,2,3)

union 

select 
customerName as nomeCliente,
sum(amount) as totalPago
from
cutomer
inner join payments using (cutomerNumber)
where
year(paymentsDate) = 2006
and month(paymenteDate) in (4,5,6)
group by nomeCliente;
use sakila;

Select datadiff('2025-05-06', ' 2025-04-04') * 2 + 10 as resultado;
#parametros: datediff(datafinal,datainicial)
#primeiro parametro : a maior data
#Segundo parametro : a menor data 
Describe rental;

select datediff(return_date, rental_date) as dias from rental;

#Modifique a consulta acima para retornar os cambos abaixo
#codigo do cliente - Customer_id
#Codigo do Aluguel - Rental_id
#Titulo do filme - Title
#Taxa do aluguel - Rental_rate
#taxa de reposição - replacemnt_cost 
#taxa maxima de algueç - rental_duration
#Dias do filme alugado - calculo acima

select Customer_id, Rental_id, Title, rental_rate, replacement_cost, rental_duration, datediff(return_date, rental_date) as dias
from rental 
inner join inventory using (inventory_id)
inner join fiml using (film_id);

#modifique a consulta acima, para realizar o calculo de atraso na entrega do filme
#neste caso, vc utilizara o calculo de dias a fazer uma opercao matemaica com o tempo maximo de aluguel 

select Customer_id, Rental_id, Title, rental_rate, replacement_cost, rental_duration, datediff(return_date, rental_date) as dias,
rental_duration - cast(datediff(return_date, rental_date) as decimal) as dias_atraso
from rental 
inner join inventory using (inventory_id)
inner join fiml using (film_id);

select customer_id, case when active = 1 then 'Ativo'
else 'Inativo' end as situacao_cliente from customer;

#modifique a consulta acina para incluir a a situacao cliente, voce deve realizar a verificacao da situacao do atrso, conforme abaixo
#se o valor for negativo, colocar o campo 'cloteiro' SE nao 'gente boa'

select Customer_id, Rental_id, Title, rental_rate, replacement_cost, rental_duration, ifnull(datediff(return_date, rental_date),999) as dias,
iffnull(rental_duration - cast(datediff(return_date, rental_date) as decimal),999) as dias_atraso,
case 
when ifnull(rental_duration - cast(datediff(return_date, rental_date) as decimal),999) < 0
or ifnull(rental_duration - cast(datediff(return_date, rental_date) as decimal),999) = 999
then 'Caloteiro' 
else
'gente booa' 
end as situacao_atraso
from rental 
inner join inventory using (inventory_id)
inner join film using (fil_id);

#Modifiquei a consulta acima, incluindo o campo multa que deveria obdecer a seguinte verificação:
#Se o valor dos dias em atrasofor menos que zero, faça: dias de atraso * taxa de aluguel * -1
#se o valor dos dias em atraso for 999 incluir  no campo multa a taxa de reposição
#do contrario incluir o valor zero a multa

select Customer_id, Rental_id, Title, rental_rate, replacement_cost, rental_duration, ifnull(datediff(return_date, rental_date),999) as dias,
iffnull(rental_duration - cast(datediff(return_date, rental_date) as decimal),999) as dias_atraso,
case 
when ifnull(rental_duration - cast(datediff(return_date, rental_date) as decimal),999) < 0
or ifnull(rental_duration - cast(datediff(return_date, rental_date) as decimal),999) = 999
then 'Caloteiro' 
else
'gente booa' 
end as situacao_atraso,
case 
when   ifnull(rental_duration - cast(datediff(return_date, rental_date) as decimal),999) < 0
then (rental_duration - cast(datediff(return_date, rental_dae) as decimal)) * rental_rate * -1
when ifnull(rental_duration - cast(datediff(return_date, rental_date) as decimal),999) = 999
then replacement_cost
else 0
end as multa
from rental
inner join inventory using (inventory_id)
inner join film using (film_id);
-- Funções de Agregações: Minimo, Maximo, Media, Soma e Contagem
select 
	MIN   (salario),
	MAX   (salario),
	ROUND(AVG(salario), 2),
	SUM   (salario),
	COUNT (salario)

from engineer03.funcionarios;
	/*
-- Média salarial geral
select 
	ROUND(AVG(salario), 2) as media_salario

from engineer03.funcionarios;
	*/

-- Média salarial por departamento
select 
	departamento, ROUND(AVG(salario), 2) as media_salario_departamento

from engineer03.funcionarios

group by departamento;
	

-- Média salarial por departamento ordenado por departamento

select 
	departamento, ROUND(AVG(salario), 2) as media_salario_departamento

from engineer03.funcionarios
group by departamento
order by departamento;


-- Média salarial por departamento ordenado por departamento somente medias maiores que 20.000

select 
	departamento, ROUND(AVG(salario), 2) as med_sala_depar

from engineer03.funcionarios

group by departamento
having ROUND(AVG(salario), 2) > 20000
order by departamento;


/*
Média salarial por departamento somente se a média for maior do que e somente se o
nome do departamento tiver a palavra 'Engenharia'
Ordenado por departamento
*/


select 
	departamento, ROUND(AVG(salario), 2) as med_sala_depar

from engineer03.funcionarios

where departamento like '%Engenharia%'
group by departamento
having ROUND(AVG(salario), 2) > 20000
order by departamento;


select * from funcionarios









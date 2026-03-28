/* 
CTE - Muito utilizado em ETL. O processo fica mais agil pois cria uma tabela temporaria para realizar qualquer processamento de dados, ao inves
de realizar em disco. 
*/

-- Funcionários com salário maior do que 21900
with funcionarios_salarios_mais_altos as (
	select 
		nome, 
		salario,
		dt_contratacao
		
	from engineer03.funcionarios
	where salario > 21900
)

select *
from funcionarios_salarios_mais_altos
where extract(day from dt_contratacao) = 10;



/*
Subconsulta

Considerando os funcionarios contratados no mês de fevereiro, retorne nome
e departamento de quem tem o maior salário.
*/

-- Observe que o agrupamento por nome e departamento vai retornar o resultado muito granular (muito detalhado)
select 
	nome, 
	departamento, 
	MAX (salario)
	
from engineer03.funcionarios
WHERE EXTRACT(MONTH FROM dt_contratacao)
GROUP BY nome, departamento;


-- Solução com subconsulta
SELECT 
	nome, 
	departamento
	
FROM engineer03.funcionarios
WHERE salario = (SELECT MAX(sa1ario) from engineer03.funcionarios where eXTRACT (month from dt_contratacao) = 2);





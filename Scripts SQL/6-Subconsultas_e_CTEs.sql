-- CTE
-- Funcionários com salário maior do que 21900

with funcionarios_salarios_mais_altos as (
	select 
		nome, 
		salario
		
	from engineer03.funcionarios
	where salario > 21900
)

select *
from funcionarios_salarios_mais_altos;


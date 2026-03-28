-- Criando tabela projetos
create table engineer03.projetos(
	id_projeto 	 INT primary key,
	nome_projeto VARCHAR(100),
	func_id 	 INT references engineer03.funcionarios (id_funcionario)
);

-- Inserindo falores na tabela projetos
INSERT INTO engineer03.projetos (id_projeto, nome_projeto, func_id)
VALUES (6001, 'Análise de Dados em Tempo Real', 101);

INSERT INTO engineer03.projetos (id_projeto, nome_projeto, func_id)
VALUES (6002, 'Pipelines de CI/CD', 103);

INSERT INTO engineer03.projetos (id_projeto, nome_projeto, func_id)
VALUES (6003, 'Extração de Dados de Bancos Transacionais', 104);

INSERT INTO engineer03.projetos (id_projeto, nome_projeto, func_id)
VALUES (6004, 'Backup de Dados', 102);

INSERT INTO engineer03.projetos (id_projeto, nome_projeto, func_id)
VALUES (6005, 'Levantamento de Requisitos', null);


select * 
from engineer03.projetos



-- INNER JOIN - Nome e salário dos funcionários alocados em projetos.
select
	e.nome,
	e.salario,
	p.nome_projeto
	
from engineer03.funcionarios e
inner join engineer03.projetos p on e.id_funcionario = p.func_id;



-- LEFT JOIN - Nome e salario de todos os funcionarios independentes de estarem alocados em projetos.
select
	e.nome,
	e.salario,
	p.nome_projeto
	
from engineer03.funcionarios e 
left join engineer03.projetos p on e.id_funcionario = p.func_id;



select
	e.nome,
	e.salario,
	p.nome_projeto
	
from engineer03.projetos p
left join engineer03.funcionarios e on e.id_funcionario = p.func_id;



-- COALESCE - Alternativa mais elegante para o resultado anterior 
select
	e.nome,
	e.salario,
	COALESCE(p.nome_projeto, 'Não Alocado em Projeto')

from engineer03.funcionarios e
left join engineer03.projetos p on e.id_funcionario = p.func_id;



-- RIGHT JOIN - Nome de todos os funcionários alocados em projetos e os projetos sem funcionários alocados

select
	e.nome,
	e.salario,
	COALESCE(p.nome_projeto, 'Não Alocado em Projeto')

from engineer03.funcionarios e
right join engineer03.projetos p on e.id_funcionario = p.func_id;


-- FULL JOIN - Nome de todos os funcionários alocados ou não em projetos e todos os projetos com ou sem funcionários alocados


select
	coalesce(e.nome, 'Sem Funcionário Alocado') as nome_funcionario,
	coalesce(p.nome_projeto, 'Não Alocado em Projeto')

from engineer03.funcionarios e
full join engineer03.projetos p on e.id_funcionario = p.func_id;


-- Média de salário dos departamentos com funcionários alocados em projetos

select
	f.departamento,
	ROUND(AVG(f.salario), 2) as media_salarial_dpt
	
from engineer03.funcionarios f
inner join engineer03.projetos p on f.id_funcionario = p.func_id
group by f.departamento;



/* Média de salário dos departamentos com funcionários alocados em projetos, cuja data de contratação do funcionário tenha sido 
   no dia 10 de qualquer mês ou ano */ 

select
	f.departamento,
	ROUND(AVG(f.salario), 2) as media_salarial_dpt

from engineer03.funcionarios f
inner join engineer03.projetos p on f.id_funcionario = p.func_id

where extract(day from dt_contratacao) = 10
group by f.departamento;


















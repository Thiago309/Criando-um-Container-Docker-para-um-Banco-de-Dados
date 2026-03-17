-- Instruções DDL (Data Definition Language)
-- CREATE, ALTER, DROP

/*
-- Criação da tabela

create table engineer03.funcionarios (
	-- o comando SERIAL gera uma sequencia de valores inteiros conforme id's são gerados.
	id_funcionario SERIAL primary key,
	nome VARCHAR(50),
	departamento VARCHAR(50),
	salario DECIMAL (10, 2)
)
*/

-- Alteração da tabela
-- alter table engineer03.funcionarios add column dt_contratacao DATE;

-- Exclusão da tabela
-- drop table engineer03.funcionarios;


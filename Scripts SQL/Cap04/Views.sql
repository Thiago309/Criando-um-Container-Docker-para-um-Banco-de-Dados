create schema engineer04 authorization engineer_user;

create table engineer04.funcionarios(
	id_funcionario int primary key,
	nome varchar(50),
	departamento varchar(50),
	data_contratacao date,
	salario decimal(10, 2)
	
)

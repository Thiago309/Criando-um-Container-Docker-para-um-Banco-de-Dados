create table engineer03.funcionarios (
	id_funcionario INT primary key,
	nome 		   VARCHAR(50),
	departamento   VARCHAR(50),
	dt_contratacao DATE,
	salario        DECIMAL(10, 2)
);


insert into engineer03.funcionarios (id_funcionario, nome, departamento, dt_contratacao, salario)
values (100, 'José Alencar', 'Engenharia de Dados - DSA', '2024-01-10', 25000.00);

insert into engineer03.funcionarios (id_funcionario, nome, departamento, dt_contratacao, salario)
values (101, 'Machado de Assis', 'Data Science - DSA', '2024-02-10', 19000.00);

insert into engineer03.funcionarios (id_funcionario, nome, departamento, dt_contratacao, salario)
values (102, 'Cecília Meireles', 'Engenharia de Dados - DSA', '2024-02-11', 22000.00);

insert into engineer03.funcionarios (id_funcionario, nome, departamento, dt_contratacao, salario)
values (103, 'Carlos Drummond de Andrade', 'DataOps - DSA', '2024-02-12', 23400.00);

insert into engineer03.funcionarios (id_funcionario, nome, departamento, dt_contratacao, salario)
values (104, 'Clarice Lispector', 'DataOps - DSA', '2024-02-13', 21800.00);
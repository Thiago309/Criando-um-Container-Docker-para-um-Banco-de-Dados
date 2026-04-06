-- Cria um schema de organização lógica de objetos no banco de dados
create schema engineer04 authorization engineer_user;


-- Criação de tabela funcionarios
create table engineer04.funcionarios(
	id_funcionario int primary key,
	nome varchar(50),
	departamento varchar(50),
	data_contratacao date,
	salario decimal(10, 2)
);


-- Inserção de dados
insert into engineer04.funcionarios (id_funcionario, nome, departamento, data_contratacao, salario)
values (100, 'José de Alencar', 'Engenharia de Dados - DSA', '2024-01-10', 25000.00);

insert into engineer04.funcionarios (id_funcionario, nome, departamento, data_contratacao, salario)
values (101, 'Machado de Assis', 'Data Science - DSA', '2024-02-10', 19000.00);

insert into engineer04.funcionarios (id_funcionario, nome, departamento, data_contratacao, salario)
values (102, 'Cecília Meireles', 'Engenharia de Dados - DSA', '2024-02-11', 22000.00);

insert into engineer04.funcionarios (id_funcionario, nome, departamento, data_contratacao, salario)
values (103, 'Carlos Drummond de Andrade', 'DataOps - DSA', '2024-02-12', 23400.00);

insert into engineer04.funcionarios (id_funcionario, nome, departamento, data_contratacao, salario)
values (104, 'Clarice Lispector', 'DataOps - DSA', '2024-02-13', 21800.00);


-- Consultar os dados
select * from engineer04.funcionarios;


-- Criar tabela projetos
create table engineer04.projetos(
	id_projeto int primary key,
	nome_projeto varchar(100),
	func_id int references engineer04.funcionarios(id_funcionario)
);


-- Inserir os dados
insert into engineer04.projetos(id_projeto, nome_projeto, func_id)
values (6001, 'Análise de Dados em Tempo Real', 101);

insert into engineer04.projetos(id_projeto, nome_projeto, func_id)
values (6002, 'Pipelines de CI/CD', 103);

insert into engineer04.projetos(id_projeto, nome_projeto, func_id)
values (6003, 'Extração de Dados de Bancos Transacionais', 104);

insert into engineer04.projetos(id_projeto, nome_projeto, func_id)
values (6004, 'Backup de Dados', 102);

insert into engineer04.projetos(id_projeto, nome_projeto, func_id)
VALUES (6005, 'Levantamento de Requisitos', null);


-- Consultar os dados
select * from engineer04.projetos;


-- 								[VIEWS]

-- View para retornar funcionários com salário maior que a média por departamento
create or replace view engineer04.vw_detalhes_funcionarios as
with Salario_Departamento as (
    select 
    	departamento, 
    	round(avg(salario), 2) as salario_medio
    	
    from engineer04.funcionarios
    group by departamento
)
select 
    f.id_funcionario, 
    f.nome, 
    f.departamento, 
    f.data_contratacao, 
    f.salario
    
from engineer04.funcionarios f
inner join Salario_Departamento sd on f.departamento = sd.departamento
where f.salario > sd.salario_medio;


-- Visualiza os dados
SELECT * from engineer04.vw_detalhes_funcionarios


-- View para retornar funcionários alocados em projetos
create view engineer04.vw_funcionarios_projetos as
with FuncionariosProjetos as (
    select 
        f.id_funcionario,
        f.nome as nome_funcionario,
        f.departamento,
        f.salario,
        coalesce(p.id_projeto, 0) as id_projeto,
        coalesce(p.nome_projeto, 'NA') as nome_projeto
        
    from engineer04.funcionarios f
    left join engineer04.projetos p on f.id_funcionario = p.func_id
    
)
select * from FuncionariosProjetos;


-- Visualiza os dados
SELECT * from engineer04.vw_funcionarios_projetos



-- 							[VIEWS MATERALIZADAS]

-- Materialized View para retornar funcionários alocados em projetos
create materialized view engineer04.mv_funcionarios_projetos as
with FuncionariosProjetos as (
    select 
        f.id_funcionario,
        f.nome as nome_funcionario,
        f.departamento,
        f.salario,
        coalesce(p.id_projeto, 0) as id_projeto,
        coalesce(p.nome_projeto, 'NA') as nome_projeto
    from 
        engineer04.funcionarios f
    left join 
        engineer04.projetos p on f.id_funcionario = p.func_id
)
select * from FuncionariosProjetos;


-- Visualiza os dados (VIEW MATERALIZADA)
select * from engineer04.mv_funcionarios_projetos

-- Visualiza os dados (VIEW)
select * from engineer04.vw_funcionarios_projetos


-- Visualiza os dados (VIEW MATERALIZADA) -> Executa uma consulta. (Temporaria)
explain select * from engineer04.mv_funcionarios_projetos

-- Visualiza os dados (VIEW) com EXPLAIN -> Executa uma tabela.    (Gera na máquina)
explain select * from engineer04.vw_funcionarios_projetos

-- Inserindo mais um funcionário
insert into engineer04.funcionarios (id_funcionario, nome, departamento, data_contratacao, salario)
values (105, 'cora coralina', 'analytics engineer - dsa', '2024-03-13', 29700.00);


-- Visualiza os dados (VIEW MATERALIZADA)
select * from engineer04.mv_funcionarios_projetos

-- Visualiza os dados (VIEW)
select * from engineer04.vw_funcionarios_projetos


-- Refresh - Atualiza os novos dados na VIEW MATERALIZADA antiga.
refresh materialized view engineer04.mv_funcionarios_projetos;


-- 			  		[STORED PROCEDURE] - PROGRAMAÇÃO DE BANCO DE DADOS


-- SP que retorna o salário de cada funcionário com aumento de 5%
create or replace procedure engineer04.aumenta_salario()
language plpgsql	-- Indica o tipo de linguagem de programação de banco de dados a ser utilizada. Neste caso o plpgsql para o postegree.
as $$
declare 
    cur cursor for select id_funcionario, nome, salario, salario * 1.05 as salario_novo from engineer04.funcionarios;
begin
    for record in cur loop
        raise notice 'funcionario: %, salario atual: %, novo salario: %', 
                     record.nome, record.salario, record.salario_novo;
    end loop;
end;
$$;


-- Executa a SP criada anteriormente.
CALL engineer04.aumenta_salario();



-- 							[FUNCTION] - FUNÇÕES

-- Função que vai verificar se um projeto está sendo cadastrado sem funcionário associado
create or replace function engineer04.verifica_funcionario_projeto()
returns trigger as $$
begin
    -- verifica se o id do funcionário associado ao projeto é nulo
    if new.func_id is null then
        raise exception 'não é permitido inserir um projeto sem um funcionário associado.';
    end if;
    return new;
end;
$$ language plpgsql;



-- 			  				[TRIGGERS] - GATILHOS


/*
Um Trigger (ou Gatilho) é um tipo especial de rotina ou procedimento no banco de dados que
é acionado (executado) automaticamente sempre que um evento específico ocorre em uma 
tabela ou view. Diferente de uma Stored Procedure que você precisa chamar manualmente com
um comando CALL, o Trigger fica "escutando" a tabela. Se alguém fizer um INSERT (inserir), 
UPDATE (atualizar) ou DELETE (deletar) naquela tabela, o Trigger "dispara" e executa a sua
lógica.
*/

create trigger trg_verifica_funcionario_projeto
before insert on engineer04.projetos
for each row execute function engineer04.verifica_funcionario_projeto();

-- Tentativa de inserir projeto sem funcionário associado
insert into engineer04.projetos (id_projeto, nome_projeto, func_id)
values (6008, 'Pipeline de Integração de Dados', null);

-- Cria tabela para auditoria
create table engineer04.historico_salarios (
    id_funcionario int,
    salario_antigo decimal(10, 2),
    data_mudanca   timestamp default current_timestamp
);

-- Function
create or replace function engineer04.salva_salario_antigo()
returns trigger as $$
begin
    -- Insere o salário antigo na tabela historico_salarios
    if old.salario is distinct from new.salario then
        insert into engineer04.historico_salarios (id_funcionario, salario_antigo)
        values (old.id_funcionario, old.salario);
    end if;
    return new;
end;
$$ language plpgsql;

-- Trigger para função anterior
create trigger trg_salva_salario_antigo
before update on engineer04.funcionarios
for each row execute function engineer04.salva_salario_antigo();

-- Testando Trigger salva_salario_antigo
-- Verificando o valor antes da atualização do salario
select * from engineer04.funcionarios

-- Atualização de dados
update engineer04.funcionarios 
set salario = 36500.00 
where nome = 'Machado de Assis';

-- Verifica os dados
select * from engineer04.historico_salarios;















-- Qual a Diferença Entre Stored Procedure e Function?

-- 1. Propósito e Uso:

-- Stored Procedure: Geralmente usada para realizar um conjunto de operações no banco de dados, 
-- como inserções, atualizações, deleções e consultas complexas. Pode ou não retornar um valor.

-- Function: Projetada para calcular e retornar um valor. 
-- É frequentemente usada em consultas SQL para realizar cálculos, formatar dados, etc.

-- 2. Retorno de Valores:

-- Stored Procedure: Pode retornar zero, um ou vários valores (através de parâmetros OUT ou conjuntos 
-- de resultados).

-- Function: Sempre retorna um único valor. Não pode retornar múltiplos conjuntos de resultados.

-- 3. Uso em SQL:

-- Stored Procedure: Não pode ser utilizada diretamente em instruções SQL como SELECT, WHERE, etc.

-- Function: Pode ser incorporada em instruções SQL.

-- 4. Natureza:

-- Stored Procedure: Mais procedimental, ideal para executar sequências de comandos e lógicas complexas.

-- Function: Mais funcional, concentrada em cálculos ou operações de dados.

















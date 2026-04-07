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


/*
 Qual a Diferença Entre Stored Procedure e Function?

 1. Propósito e Uso:

 Stored Procedure: Geralmente usada para realizar um conjunto de operações no banco de dados, 
 como inserções, atualizações, deleções e consultas complexas. Pode ou não retornar um valor.

 Function: Projetada para calcular e retornar um valor. 
 É frequentemente usada em consultas SQL para realizar cálculos, formatar dados, etc.

 2. Retorno de Valores:

 Stored Procedure: Pode retornar zero, um ou vários valores (através de parâmetros OUT ou conjuntos 
 de resultados).

 Function: Sempre retorna um único valor. Não pode retornar múltiplos conjuntos de resultados.

 3. Uso em SQL:

 Stored Procedure: Não pode ser utilizada diretamente em instruções SQL como SELECT, WHERE, etc.

 Function: Pode ser incorporada em instruções SQL.

 4. Natureza:

 Stored Procedure: Mais procedimental, ideal para executar sequências de comandos e lógicas complexas.

 Function: Mais funcional, concentrada em cálculos ou operações de dados.
*/


-- 			  				[TRIGGERS] - GATILHOS


/*
Um Trigger (ou Gatilho) é um tipo especial de rotina ou procedimento no banco de dados que
é acionado (executado) automaticamente sempre que um evento específico ocorre em uma 
tabela ou view. Diferente de uma Stored Procedure que você precisa chamar manualmente com
um comando CALL, o Trigger fica "escutando" a tabela. Se alguém fizer um INSERT (inserir), 
UPDATE (atualizar) ou DELETE (deletar) naquela tabela, o Trigger "dispara" e executa a sua
lógica.



Vantagens


Automação e Consistência: A regra de negócio é aplicada sempre, não importa quem esteja acessando o banco (seja o seu script Python, o DBeaver ou uma aplicação web). 
Se a regra está no Trigger, ela é inquebrável.

Integridade de Dados Complexa: Permite criar regras de validação que são muito complexas para as restrições normais (como PRIMARY KEY ou CHECK). Por exemplo, verificar 
o estoque em uma tabela antes de permitir a inserção de uma venda em outra.

Auditoria Invisível: É a ferramenta perfeita para rastrear o histórico de alterações. Você pode criar um Trigger que, toda vez que um registro for alterado, salva 
silenciosamente quem alterou, quando alterou e qual era o valor antigo em uma tabela de log separada.



Desvantagens


Lógica Oculta ("Efeito Fantasma"): Esta é a maior dor de cabeça. Como os Triggers rodam de forma invisível no background, um desenvolvedor ou engenheiro de dados pode fazer um UPDATE simples e, 
sem saber, acionar um Trigger que altera dados em outras 5 tabelas. Isso torna o debug (encontrar erros) muito difícil.

Impacto na Performance: Triggers adicionam tempo de processamento a cada operação de escrita. Se você fizer um UPDATE em 1 milhão de linhas (algo comum em Data Warehouses) e houver um Trigger 
rodando para cada linha (FOR EACH ROW), a operação ficará extremamente lenta.

Efeito Cascata: Um Trigger na Tabela A pode atualizar a Tabela B, que por sua vez tem um Trigger que atualiza a Tabela C. Se não for bem planejado, isso pode gerar loops infinitos ou bloqueios 
severos no banco de dados.



Onde é utilizado ?


Tabelas de Auditoria e Histórico (Sistemas Transacionais/OLTP): O cenário mais clássico. Rastrear alterações de preços, mudanças de status de pedidos ou dados sensíveis de 
usuários (ex: manter um histórico de senhas antigas).

Validação de Regras de Negócio Estritas: Impedir que um salário seja atualizado com um valor menor que o atual, ou bloquear a exclusão de um cliente se ele tiver faturas em aberto.

Atenção em Data Warehouses: Na Engenharia de Dados analítica, Triggers são pouco utilizados nas tabelas finais do Data Warehouse, pois impactam muito a performance das 
cargas massivas (ETL). Eles são mais comuns nos bancos transacionais de origem.
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


-- 			  			 [COMMIT & ROLLBACK] - Controle de Transações

/*
Uma transação é um bloco de comandos SQL que deve ser tratado como uma unidade 
única de trabalho. A regra de ouro aqui é o conceito de Atomicidade (o "Tudo ou 
Nada"): ou todos os comandos do bloco funcionam e são salvos, ou, se apenas um 
falhar, absolutamente nada é salvo.

COMMIT: É o comando que diz ao banco de dados: "Tudo ocorreu bem. Salve todas as
alterações feitas nesta transação permanentemente no disco."

ROLLBACK: É o comando de emergência que diz: "Algo deu errado ou eu desisti. 
Desfaça todas as alterações feitas desde o início desta transação e volte ao 
estado original."



Vantagens

Garantia de Integridade (Segurança): Impede que o banco de dados fique em um estado inconsistente. Por exemplo, em uma transferência 
bancária, se o sistema tirar R$ 100 da Conta A, mas der erro na hora de adicionar na Conta B, o ROLLBACK devolve o dinheiro para a Conta 
A instantaneamente.

Rede de Segurança para Desenvolvedores: Ao trabalhar diretamente em ferramentas gráficas ou no terminal, você pode iniciar uma transação, 
testar um comando de exclusão (DELETE) massivo e, ao perceber que apagou linhas a mais, usar o ROLLBACK para restaurar os dados como num passe de mágica.

Consistência em Múltiplas Etapas: Permite que scripts complexos em linguagens como Java ou Python garantam que múltiplos INSERTS e UPDATES 
só sejam validados se o script rodar até a última linha sem falhas.



Desvantagens

Bloqueios (Locks) de Banco de Dados: Esta é a principal desvantagem em ambientes de produção. Enquanto uma transação está aberta (você iniciou, mas ainda não deu COMMIT ou ROLLBACK),
 o banco de dados "tranca" as linhas ou tabelas envolvidas. Outros usuários e sistemas ficarão travados esperando você terminar, o que pode causar lentidão severa.

O Risco do Esquecimento: É muito comum desenvolvedores abrirem uma transação manual, irem tomar um café e esquecerem de dar o COMMIT. Os dados ficam invisíveis para o resto da empresa 
e as tabelas ficam bloqueadas.

Consumo de Recursos: Transações gigantescas (ex: atualizar 50 milhões de linhas de uma vez antes do commit) exigem muito espaço de memória temporária e log do servidor para guardar as 
informações caso um ROLLBACK seja necessário.


Onde é utilizado ?

Pipelines de Engenharia de Dados (ETL/ELT): Essencial na carga de dados em um Data Warehouse. Se você está movendo dados da camada Staging para a camada Analytics e a conexão 
cai nos 90% do processo, o script em Python faz um ROLLBACK automático para não deixar o Data Warehouse com dados pela metade.

Sistemas Transacionais (OLTP): Qualquer sistema de e-commerce, ERP ou financeiro utiliza esse controle o tempo todo para processar pagamentos, baixas de estoque e faturamento.

Rotinas de Stored Procedures: Como vimos anteriormente, procedures robustas englobam toda a sua lógica de negócio entre essas instruções para garantir que a transformação de 
dados ocorra de forma atômica.
*/

-- Início da transação
begin;

-- inserindo um novo funcionário
insert into engineer04.funcionarios (id_funcionario, nome, departamento, data_contratacao, salario)
values (106, 'Jorge Amado', 'Desenvolvimento', '2024-01-01', 15000.00);

-- Tentativa de inserir um projeto associado ao funcionário
insert into engineer04.projetos (id_projeto, nome_projeto, func_id)
values (7777, 'Projeto Alpha', 106);

-- Commit ou Rollback
commit;
-- rollback; --em caso de erro ou necessidade de desfazer as operações

select * from engineer04.funcionarios



-- 			  			 [EXPLAIN] - Analise de Performance de Transações

/*
O comando EXPLAIN é como um "raio-X" ou uma espiada no cérebro do banco de dados. Quando você envia uma consulta SQL, 
o motor do banco (especificamente o Query Planner ou Otimizador) avalia dezenas de formas diferentes de buscar os seus dados 
e escolhe a que ele julga ser a mais rápida.
O comando EXPLAIN revela exatamente qual foi esse Plano de Execução escolhido, mostrando passo a passo como o banco vai 
acessar as tabelas, quais índices vai usar e qual o custo estimado da operação.

Vantagens


Identificação de Gargalos (Tuning): É a principal ferramenta para descobrir por que uma consulta está lenta. Ele mostra claramente se o 
banco está lendo a tabela inteira linha por linha (Sequential Scan) ou se está usando um atalho eficiente (Index Scan).

Previsibilidade de Custo: Antes de rodar um SELECT monstruoso em uma tabela de faturamento com bilhões de linhas no seu Data Warehouse, 
você pode usar o EXPLAIN para ver a estimativa de tempo e recurso (CPU/Memória) que a consulta vai gastar.

Validação de Índices: Ajuda a comprovar se aquele índice que você acabou de criar realmente está sendo utilizado pelo banco de dados ou se foi ignorado.



Desvantagens


Curva de Aprendizado: O resultado em texto bruto gerado pelo EXPLAIN pode ser muito intimidador para iniciantes. Ele usa jargões 
técnicos de arquitetura de banco de dados, como Hash Join, Nested Loop, Bitmap Heap Scan e Cost.

Estimativas vs. Realidade: Se as estatísticas internas do banco de dados estiverem desatualizadas, o EXPLAIN simples fará uma estimativa 
incorreta do tempo e do número de linhas, enganando você sobre a real performance da consulta.

(ATENÇÃO !!!) Perigo com Comandos Destrutivos: Existe uma variação chamada EXPLAIN ANALYZE. Diferente do EXPLAIN normal (que apenas planeja), o ANALYZE 
executa de fato a consulta para medir o tempo exato. Se você usar EXPLAIN ANALYZE em um DELETE ou UPDATE sem o devido cuidado com 
transações (lembra do BEGIN e ROLLBACK?), você vai alterar os dados reais.



Onde é utilizado ?

Otimização de Dashboards e BI: Quando um painel no Power BI está demorando 5 minutos para carregar, a equipe de engenharia extrai o código SQL gerado, 
roda um EXPLAIN e otimiza a consulta ou cria os índices corretos no Data Warehouse.

Desenvolvimento de Pipelines (ELT): Engenheiros de Dados o utilizam para garantir que as rotinas noturnas de cruzamento de dados (JOINs entre várias tabelas staging) 
ocorram no menor tempo possível.

Auditoria de Performance por DBAs: Monitoramento contínuo para reescrever consultas que estão consumindo muitos recursos do servidor PostgreSQL.
*/


explain -- Ou explain analyze
with FuncionariosProjetos as (
    select 
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
select * 
from FuncionariosProjetos
where salario > 20000;


-- Criação de índice
create index idx_funcionarios_id on engineer04.funcionarios (id_funcionario);
create index idx_salario on engineer04.funcionarios (salario);


-- DROP
drop index engineer04.idx_funcionarios_id;
drop index engineer04.idx_salario;





















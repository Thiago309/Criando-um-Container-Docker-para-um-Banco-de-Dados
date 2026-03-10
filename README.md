# Criando um Container Docker para um Banco de Dados 

Comando para executar a criação de um Banco de Dados PostgreSQL em um container Docker. Esse banco de dados será gerenciado com o SGBD DBeaver e servirá de base para a formação em Modelagem, Implementação e Governança de Data Warehouses.

---

## Preparando o Ambiente de Trabalho

### 1. Instale o Docker Desktop
Siga as instruções das aulas para instalar o Docker Desktop. Certifique-se de que o programa esteja aberto e rodando na sua máquina antes de prosseguir.

### 2. Crie o Container Docker
Abra o terminal ou prompt de comando e execute a instrução abaixo para criar o container Docker:

\`\`\`bash
docker run --name engineer_dw -p 5437:5432 -e POSTGRES_USER=engineer_user -e POSTGRES_PASSWORD=12345 -e POSTGRES_DB=db_engineer --restart unless-stopped -d postgres:18-alpine
\`\`\`

**Entendendo a estrutura do comando:**

| Parâmetro | Descrição |
| :--- | :--- |
| `docker run` | Comando principal para criar e iniciar um novo contêiner. |
| `--name engineer_dw` | Atribui o nome `engineer_dw` ao contêiner, facilitando a identificação no Docker Desktop. |
| `-p 5437:5432` | Mapeia a porta `5437` da sua máquina para a porta `5432` do contêiner. O DBeaver usará a porta 5437. |
| `-e POSTGRES_USER=...` | Define o usuário administrador inicial (`engineer_user`). |
| `-e POSTGRES_PASSWORD=...`| Define a senha (`12345`) do usuário. |
| `-e POSTGRES_DB=...` | Cria automaticamente o banco de dados inicial (`db_engineer`). |
| `--restart unless-stopped` | Garante que o contêiner reinicie automaticamente caso sua máquina seja reiniciada. |
| `-d` | Roda o contêiner em segundo plano, liberando o terminal. |
| `postgres:18-alpine` | Utiliza a versão 18 do PostgreSQL em uma distribuição Linux super leve (Alpine). |

> **⚠️ Atenção:** Este comando provisiona o banco sem um volume persistente mapeado. Isso significa que, se o contêiner for apagado, os dados gravados no banco `db_engineer` serão perdidos. Perfeito para laboratórios e testes da formação. Caso você deseje ativar o mapeamento de volume de dados, adicione o seguinte comando logo após do (-e POSTGRES_DB=db_engineer) -v dsadata_volume:/var/lib/postgresql/data 

---

### 3. Instale e Configure o DBeaver
Instale o DBeaver conforme instruções das aulas.

**Obs:** Quando acessar o DBeaver para configurar a sua conexão, escolha o driver do **PostgreSQL** e preencha os campos exatamente com os parâmetros que você definiu no Docker:

* **Host:** `localhost`
* **Porta:** `5437`
* **Database:** `db_engineer`
* **Username:** `engineer_user`
* **Password:** `12345`
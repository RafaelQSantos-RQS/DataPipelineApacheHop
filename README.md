# DataPipelineApacheHop

Pipeline de dados para extração, transformação e carregamento (ETL) de currículos acadêmicos Lattes de pesquisadores brasileiros.

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Apache Hop](https://img.shields.io/badge/Apache%20Hop-0033A0?style=for-the-badge&logo=apache&logoColor=white)
![Metabase](https://img.shields.io/badge/Metabase-509EE3?style=for-the-badge&logo=metabase&logoColor=white)

---

## Descrição

Este projeto implementa um pipeline de dados completo para processar currículos acadêmicos no formato XML do Lattes (Plataforma Lattes - CNPq). Os dados são extraídos, transformados e carregados em um banco de dados PostgreSQL com extensão pgvector, possibilitando análises e visualizações através do Metabase.

### Caso de Uso

- Catalogação automática de pesquisadores brasileiros
- Armazenamento estruturado de produções acadêmicas
- Visualização e análise de dados de pesquisa via dashboards

---

## Arquitetura

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                  │     │                 │     │                 │
│  Currículos     │────▶│  Apache Hop      │────▶│  PostgreSQL     │────▶│  Metabase       │
│  Lattes (XML)   │     │  (Pipelines ETL) │     │  (pgvector)     │     │  (Visualização) │
│                 │     │                  │     │                 │     │                 │
└─────────────────┘     └──────────────────┘     └─────────────────┘     └─────────────────┘
        │                                                 │
        │                                                 │
        ▼                                                 ▼
  dataset/*.xml                                    tabelas:
                                                   - pesquisadores
                                                   - producoes
```

### Fluxo de Dados

1. **Extração**: Currículos XML do Lattes são lidos do diretório `dataset/`
2. **Transformação**: Apache Hop processa os dados extraindo informações relevantes
3. **Carregamento**: Dados são inseridos/atualizados no PostgreSQL
4. **Visualização**: Metabase acessa o banco para criar dashboards

---

## Pré-requisitos

| Software | Versão | Obrigatório |
|----------|--------|-------------|
| Docker | 20.10+ | Sim |
| Docker Compose | 2.0+ | Sim |
| Apache Hop | 2.x | Para executar pipelines |

---

## Início Rápido

### 1. Clone o repositório

```bash
git clone https://github.com/RafaelQSantos-RQS/DataPipelineApacheHop.git
cd DataPipelineApacheHop
```

### 2. Configure as variáveis de ambiente

```bash
cp .env.example .env
```

Edite o arquivo `.env` com suas configurações:

```env
POSTGRES_PASSWORD=sua_senha_segura_aqui
```

### 3. Inicie os serviços

```bash
docker-compose up -d
```

### 4. Verifique se os serviços estão rodando

```bash
docker-compose ps
```

Você deve ver dois containers:
- `pgvector` - PostgreSQL com extensão pgvector (porta 5432)
- `metabase` - Metabase para visualização (porta 3000)

### 5. Acesse o Metabase

Abra seu navegador em: [http://localhost:3000](http://localhost:3000)

Configure a conexão com o banco usando:
- **Host**: database
- **Porta**: 5432
- **Banco**: BD_PESQUISADOR
- **Usuário**: postgres
- **Senha**: (a senha definida no `.env`)

---

## Estrutura do Projeto

```
DataPipelineApacheHop/
├── dataset/                          # Currículos Lattes em formato XML
│   ├── 1966167015825708.xml
│   └── 6716225567627323.xml
├── pipelines/                        # Definições de pipelines Apache Hop
│   ├── Dados_Pesquisador.hpl         # Processa um pesquisador
│   ├── Dados_Pesquisadores_varios.hpl # Processa múltiplos pesquisadores
│   ├── Dados_Producoes_Pesquisadores_Varios.hpl # Processa produções
│   └── Workflow.hwf                  # Workflow de orquestração
├── scripts/                          # Scripts de inicialização
│   └── init.sh                       # Criação do schema do banco
├── docker-compose.yaml               # Orquestração dos containers
├── project-config.json               # Configuração do projeto Apache Hop
├── .env.example                      # Template de variáveis de ambiente
└── README.md                         # Este arquivo
```

---

## Configuração

### Variáveis de Ambiente

| Variável | Descrição | Valor Padrão |
|----------|-----------|--------------|
| `PGVECTOR_TAG` | Tag da imagem Docker do PostgreSQL + pgvector | `pg18-trixie` |
| `POSTGRES_DB` | Nome do banco de dados | `BD_PESQUISADOR` |
| `POSTGRES_USER` | Usuário do PostgreSQL | `postgres` |
| `POSTGRES_PASSWORD` | Senha do PostgreSQL | `sua_senha_segura_aqui` |
| `POSTGRES_HOST_AUTH_METHOD` | Método de autenticação | `trust` |
| `METABASE_TAG` | Tag da imagem Docker do Metabase | `v0.59.x` |

> **Aviso de Segurança**: O valor padrão `trust` em `POSTGRES_HOST_AUTH_METHOD` permite conexões locais sem senha. Adequado apenas para desenvolvimento. Em produção, utilize `scram-sha-256`.

### Serviços Docker

| Serviço | Container | Porta | Descrição |
|---------|-----------|-------|-----------|
| database | pgvector | 5432 | PostgreSQL com extensão pgvector |
| dataview | metabase | 3000 | Ferramenta de visualização de dados |

---

## Banco de Dados

### Schema

O banco é inicializado automaticamente pelo script `scripts/init.sh` quando o container PostgreSQL é iniciado.

#### Tabela `pesquisadores`

Armazena informações dos pesquisadores.

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| pesquisador_id | UUID | Chave primária (gerada automaticamente) |
| lattes_id | VARCHAR(16) | ID único do currículo Lattes |
| nome | VARCHAR(200) | Nome completo do pesquisador |
| data_cadastro | TIMESTAMP | Data de cadastro no sistema |

#### Tabela `producoes`

Armazena as produções acadêmicas dos pesquisadores.

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| producao_id | UUID | Chave primária (gerada automaticamente) |
| pesquisador_id | UUID | Chave estrangeira para pesquisadores |
| issn | VARCHAR(16) | ISSN do periódico |
| nome_artigo | TEXT | Título do artigo |
| ano_artigo | INTEGER | Ano de publicação |

#### Índices

```sql
CREATE INDEX idx_producoes_pesquisador ON producoes(pesquisador_id);
CREATE INDEX idx_producoes_ano ON producoes(ano_artigo);
```

---

## Pipelines

### Descrição dos Pipelines

| Pipeline | Arquivo | Descrição |
|----------|---------|-----------|
| Dados_Pesquisador | `Dados_Pesquisador.hpl` | Extrai dados de um único currículo XML |
| Dados_Pesquisadores_Varios | `Dados_Pesquisadores_varios.hpl` | Processa múltiplos currículos em lote |
| Dados_Producoes_Pesquisadores_Varios | `Dados_Producoes_Pesquisadores_Varios.hpl` | Extrai produções acadêmicas |
| Workflow | `Workflow.hwf` | Orquestra a execução dos pipelines |

### Transformações Utilizadas

Cada pipeline utiliza as seguintes transformações do Apache Hop:

1. **Get data from XML** - Lê arquivos XML do Lattes
2. **Select values** - Seleciona e mapeia campos relevantes
3. **Insert / Update** - Insere ou atualiza registros no PostgreSQL

### Conexão com o Banco

Os pipelines se conectam ao PostgreSQL através da conexão `pg_vector_local` configurada no Apache Hop.

---

## Tecnologias

| Tecnologia | Uso | Link |
|------------|-----|------|
| Apache Hop | ETL (Extract, Transform, Load) | [hop.apache.org](https://hop.apache.org) |
| PostgreSQL | Banco de dados relacional | [postgresql.org](https://www.postgresql.org) |
| pgvector | Extensão para vetores no PostgreSQL | [github.com/pgvector/pgvector](https://github.com/pgvector/pgvector) |
| Metabase | Visualização e dashboards | [metabase.com](https://www.metabase.com) |
| Docker | Containerização | [docker.com](https://www.docker.com) |

---

## Autores

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/RafaelQSantos-RQS">
        <img src="https://avatars.githubusercontent.com/RafaelQSantos-RQS" width="100px;" alt="Foto do autor"/>
        <br />
        <sub>
          <b>Rafael Queiroz Santos</b>
        </sub>
      </a>
    </td>
  </tr>
</table>

---

## Licença

Este projeto está licenciado sob a licença MIT. Consulte o arquivo [LICENSE](LICENSE) para mais detalhes.

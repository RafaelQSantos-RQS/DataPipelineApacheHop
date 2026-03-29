-- =============================================================================
-- 01_schema.sql
-- Cria as tabelas, índices e comentários do projeto
-- Executado em SEGUNDO lugar (ordem alfabética no docker-entrypoint-initdb.d/)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Tabela: pesquisadores
-- Armazena os dados básicos dos pesquisadores extraídos do Lattes
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pesquisadores (
    pesquisador_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lattes_id VARCHAR(16) NOT NULL UNIQUE,
    nome VARCHAR(200) NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON COLUMN pesquisadores.lattes_id IS 'ID único do currículo Lattes';

-- -----------------------------------------------------------------------------
-- Tabela: producoes
-- Armazena as produções acadêmicas (artigos) de cada pesquisador
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS producoes (
    producao_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pesquisador_id UUID NOT NULL,
    issn VARCHAR(16),
    nome_artigo TEXT NOT NULL,
    ano_artigo INTEGER NOT NULL,
    CONSTRAINT fk_pesquisador FOREIGN KEY (pesquisador_id)
        REFERENCES pesquisadores (pesquisador_id) ON DELETE CASCADE
);

-- -----------------------------------------------------------------------------
-- Índices de performance
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_producoes_pesquisador ON producoes(pesquisador_id);
CREATE INDEX IF NOT EXISTS idx_producoes_ano ON producoes(ano_artigo);

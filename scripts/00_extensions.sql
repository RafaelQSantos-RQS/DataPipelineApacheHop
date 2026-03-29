-- =============================================================================
-- 00_extensions.sql
-- Habilita as extensões necessárias para o projeto
-- Executado PRIMEIRO (ordem alfabética no docker-entrypoint-initdb.d/)
-- =============================================================================

-- Extensão para geração de UUIDs (usada nas PKs das tabelas)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Extensão para remoção de acentos em buscas textuais (FTS)
CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Extensão para busca fuzzy (trigrams) — erros de ortografia e similaridade
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

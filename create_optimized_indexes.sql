-- Script otimizado para criar índices de performance
-- Execute este script quando o banco estiver com baixa carga

-- Índice para busca rápida por situação cadastral ATIVA
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_cnpj_situacao_ativa 
ON cnpj ((json ->> 'descricao_situacao_cadastral')) 
WHERE (json ->> 'descricao_situacao_cadastral') = 'ATIVA';

-- Índice para busca em campos específicos do QSA
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_cnpj_qsa_search
ON cnpj USING GIN ((json -> 'qsa') jsonb_path_ops)
WHERE json -> 'qsa' IS NOT NULL;

-- Estatísticas para melhorar o planejador de queries
ANALYZE cnpj;

-- Verificar índices criados
SELECT 
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
FROM pg_indexes 
WHERE tablename = 'cnpj' 
ORDER BY indexname;
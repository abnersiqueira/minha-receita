-- Criar view materializada para buscas rápidas de sócios em empresas ativas
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_socios_ativos AS
SELECT 
    c.id,
    c.cnpj,
    c.json ->> 'razao_social' as razao_social,
    c.json ->> 'uf' as uf,
    socio ->> 'cnpj_cpf_do_socio' as cpf_socio,
    socio ->> 'nome_socio' as nome_socio,
    c.json
FROM 
    cnpj c,
    LATERAL jsonb_array_elements(c.json -> 'qsa') AS socio
WHERE 
    c.json ->> 'descricao_situacao_cadastral' = 'ATIVA'
    AND c.json -> 'qsa' IS NOT NULL
    AND jsonb_typeof(c.json -> 'qsa') = 'array';

-- Criar índices na view materializada
CREATE INDEX idx_mv_cpf_socio ON mv_socios_ativos (cpf_socio);
CREATE INDEX idx_mv_nome_socio ON mv_socios_ativos (lower(nome_socio) varchar_pattern_ops);
CREATE INDEX idx_mv_cpf_nome ON mv_socios_ativos (cpf_socio, lower(nome_socio));

-- Analisar para otimizar queries
ANALYZE mv_socios_ativos;
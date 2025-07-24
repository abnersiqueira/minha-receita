-- Índices GIN para melhorar performance de busca em arrays JSON
-- Estes índices são muito mais eficientes para buscar em estruturas JSON aninhadas

-- Índice para busca por situação cadastral
CREATE INDEX IF NOT EXISTS idx_cnpj_situacao_gin ON cnpj USING GIN ((json -> 'descricao_situacao_cadastral'));

-- Índice para todo o array QSA (quadro societário)
CREATE INDEX IF NOT EXISTS idx_cnpj_qsa_gin ON cnpj USING GIN ((json -> 'qsa'));

-- Índice específico para CPF/CNPJ dos sócios
CREATE INDEX IF NOT EXISTS idx_cnpj_qsa_cnpf_gin ON cnpj USING GIN ((json -> 'qsa') jsonb_path_ops);

-- Índice para busca textual em nomes de sócios
CREATE INDEX IF NOT EXISTS idx_cnpj_qsa_nome_gin ON cnpj USING GIN (
    (json -> 'qsa') jsonb_path_ops
);

-- Índice composto para situação + existência de QSA
CREATE INDEX IF NOT EXISTS idx_cnpj_situacao_qsa ON cnpj (
    (json ->> 'descricao_situacao_cadastral')
) WHERE json -> 'qsa' IS NOT NULL;
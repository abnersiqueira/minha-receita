-- Tabela auxiliar para indexar sócios e melhorar performance de busca
CREATE TABLE IF NOT EXISTS partners (
    id SERIAL PRIMARY KEY,
    cnpj VARCHAR(14) NOT NULL,
    cnpj_cpf_do_socio VARCHAR(14) NOT NULL,
    nome_socio TEXT NOT NULL,
    company_id INTEGER NOT NULL
);

-- Índices para busca rápida
CREATE INDEX idx_partners_cnpj_cpf ON partners(cnpj_cpf_do_socio);
CREATE INDEX idx_partners_nome_socio ON partners(nome_socio varchar_pattern_ops);
CREATE INDEX idx_partners_nome_socio_lower ON partners(LOWER(nome_socio) varchar_pattern_ops);
CREATE INDEX idx_partners_company_id ON partners(company_id);

-- Índice composto para busca por CPF + nome
CREATE INDEX idx_partners_cpf_nome ON partners(cnpj_cpf_do_socio, LOWER(nome_socio));
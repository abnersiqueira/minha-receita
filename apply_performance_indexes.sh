#!/bin/bash
# Script para aplicar índices de performance no PostgreSQL

echo "=== Aplicando índices GIN para melhorar performance de busca ==="
echo "ATENÇÃO: Este processo pode demorar vários minutos dependendo do tamanho do banco"

# Verifica se DATABASE_URL está definida
if [ -z "$DATABASE_URL" ]; then
    echo "Erro: DATABASE_URL não está definida"
    echo "Use: export DATABASE_URL='postgres://minhareceita:minhareceita@postgres:5432/minhareceita'"
    exit 1
fi

echo ""
echo "Conectando ao banco de dados..."
echo "URL: $DATABASE_URL"
echo ""

# Aplica os índices GIN
psql "$DATABASE_URL" < db/postgres/create_gin_indexes.sql

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Índices aplicados com sucesso!"
    echo ""
    echo "Os seguintes índices foram criados:"
    echo "- idx_companies_situacao_gin: Para busca por situação cadastral"
    echo "- idx_companies_qsa_gin: Para busca no quadro societário"
    echo "- idx_companies_qsa_cnpf_gin: Para busca por CPF/CNPJ de sócios"
    echo "- idx_companies_qsa_nome_gin: Para busca por nome de sócios"
    echo "- idx_companies_situacao_qsa: Índice composto para situação + QSA"
    echo ""
    echo "A performance das buscas deve melhorar significativamente!"
else
    echo ""
    echo "✗ Erro ao aplicar índices"
    exit 1
fi
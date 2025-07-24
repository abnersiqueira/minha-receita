-- Query otimizada que força o uso dos índices GIN
SELECT {{ .CursorFieldName }}, {{ .JSONFieldName }}
FROM {{ .CompanyTableFullName }}
WHERE
  {{ if .Query.Cursor -}}
  cursor > {{ .Query.CursorAsInt }} AND
  {{- end }}
  
  -- Usar índice GIN para situação cadastral primeiro (mais seletivo)
  {{ if .Query.SituacaoCadastral -}}
  ({{ range $i, $sit := .Query.SituacaoCadastral }}{{ if $i }} OR {{ end }}json -> 'descricao_situacao_cadastral' = '"{{ $sit }}"'::jsonb{{ end }}) AND
  {{- end }}
  
  -- Depois filtrar por UF
  {{ if .Query.UF -}}
  ({{ range $i, $uf := .Query.UF }}{{ if $i }} OR {{ end }}json -> 'uf' = '"{{ $uf }}"'::jsonb{{ end }}) AND
  {{- end }}
  
  -- CNAE fiscal
  {{ if .Query.CNAEFiscal -}}
  ({{ range $i, $cnae := .Query.CNAEFiscal }}{{ if $i }} OR {{ end }}json -> 'cnae_fiscal' = '{{ $cnae }}'::jsonb{{ end }}) AND
  {{- end }}
  
  -- CNAE (fiscal + secundários)
  {{ if .Query.CNAE -}}
  (
    jsonb_path_query_array(json, '$.cnaes_secundarios[*].codigo') @> '[{{ range $i, $cnae := .Query.CNAE }}{{ if $i }},{{ end }}{{ $cnae }}{{ end }}]'
    {{ range $i, $cnae := .Query.CNAE -}}
    OR json -> 'cnae_fiscal' = '{{ $cnae }}'::jsonb
    {{ end -}}
  ) AND
  {{- end }}
  
  -- Busca por sócio usando índice GIN do QSA
  {{ if or .Query.CNPF .Query.NomeSocio -}}
  json -> 'qsa' IS NOT NULL AND 
  jsonb_typeof(json -> 'qsa') = 'array' AND
  EXISTS (
    SELECT 1 FROM jsonb_array_elements(json -> 'qsa') AS socio
    WHERE 1=1
    {{ if .Query.CNPF -}}
      AND socio ->> 'cnpj_cpf_do_socio' IN ({{ range $i, $cnpf := .Query.CNPF }}{{ if $i }},{{ end }}'{{ $cnpf }}'{{ end }})
    {{- end }}
    {{ if .Query.NomeSocio -}}
      AND socio ->> 'nome_socio' ILIKE '%{{ .Query.NomeSocio }}%'
    {{- end }}
  )
  {{- else }}
  true
  {{- end }}
ORDER BY {{ .CursorFieldName }}
LIMIT {{ .Query.Limit }}
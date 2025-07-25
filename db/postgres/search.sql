SELECT {{ .CursorFieldName }}, {{ .JSONFieldName }}
FROM {{ .CompanyTableFullName }}
WHERE
  {{ if .Query.Cursor -}}
  cursor > {{ .Query.CursorAsInt }} AND
  {{- end }}
  {{ if .Query.UF -}}
  ({{ range $i, $uf := .Query.UF }}{{ if $i }} OR {{ end }}json -> 'uf' = '"{{ $uf }}"'::jsonb{{ end }})
  {{- end }}
  {{ if and .Query.UF .Query.CNAEFiscal }} AND {{ end }}
  {{ if .Query.CNAEFiscal -}}
  ({{ range $i, $cnae := .Query.CNAEFiscal }}{{ if $i }} OR {{ end }}json -> 'cnae_fiscal' = '{{ $cnae }}'::jsonb{{ end }})
  {{- end }}
  {{ if and (or .Query.UF .Query.CNAEFiscal) .Query.CNAE }} AND {{ end }}
  {{ if .Query.CNAE -}}
  (
    jsonb_path_query_array(json, '$.cnaes_secundarios[*].codigo') @> '[{{ range $i, $cnae := .Query.CNAE }}{{ if $i }},{{ end }}{{ $cnae }}{{ end }}]'
    {{ range $i, $cnae := .Query.CNAE -}}
    OR json -> 'cnae_fiscal' = '{{ $cnae }}'::jsonb
    {{ end -}}
  )
  {{- end }}
  {{ if and (or .Query.UF .Query.CNAEFiscal .Query.CNAE) (or .Query.CNPF .Query.NomeSocio) }} AND {{ end }}
  {{ if or .Query.CNPF .Query.NomeSocio -}}
  (
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
  )
  {{- end }}
  {{ if and (or .Query.UF .Query.CNAEFiscal .Query.CNAE .Query.CNPF .Query.NomeSocio) .Query.SituacaoCadastral }} AND {{ end }}
  {{ if .Query.SituacaoCadastral -}}
  ({{ range $i, $sit := .Query.SituacaoCadastral }}{{ if $i }} OR {{ end }}json -> 'descricao_situacao_cadastral' = '"{{ $sit }}"'::jsonb{{ end }})
  {{- end }}
ORDER BY {{ .CursorFieldName }}
LIMIT {{ .Query.Limit }}

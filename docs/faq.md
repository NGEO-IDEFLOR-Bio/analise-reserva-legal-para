# FAQ Técnico: Redução de Reserva Legal (Art. 12, § 4º) - Estado do Pará

Este documento centraliza as principais dúvidas técnicas e jurídicas sobre a metodologia de quantificação do impacto da redução da Reserva Legal (RL) para imóveis rurais acima de 4 módulos fiscais.

---

## 1. FUNDAMENTAÇÃO LEGAL E ESTRATÉGIA

### Por que utilizar o Art. 12, § 4º em vez do ZEE estadual?
[cite_start]A escolha pelo **Artigo 12, § 4º da Lei nº 12.651/2012** visa a **máxima segurança jurídica**[cite: 179, 572, 580]. [cite_start]Enquanto o Zoneamento Ecológico-Econômico (ZEE) pode sofrer variações interpretativas regionais, o critério federal de sobreposição municipal com áreas protegidas (> 50%) é um parâmetro objetivo e pacificado pelo Supremo Tribunal Federal (STF)[cite: 77, 180, 580].

### Isso se aplica a todo o Estado do Pará?
Não. [cite_start]A redução de 80% para 50% para fins de recomposição é restrita aos **18 municípios** que atendem ao critério de ter mais de 50% do território ocupado por Unidades de Conservação de domínio público e Terras Indígenas homologadas[cite: 269, 574].

### Quais são os 18 municípios elegíveis?
| Município | % Área Protegida |
|-----------|------------------|
| São Félix do Xingu | 59,34% |
| Altamira | 86,11% |
| Ourilândia do Norte | 84,61% |
| Jacareacanga | 73,47% |
| Monte Alegre | 56,37% |
| Óbidos | 73,85% |
| Alenquer | 68,24% |
| Oriximiná | 90,19% |
| Porto de Moz | 73,93% |
| Senador José Porfírio | 65,76% |
| Parauapebas | 77,50% |
| Trairão | 67,61% |
| Nova Esperança do Piriá | 52,91% |
| Belterra | 56,12% |
| Almeirim | 78,81% |
| Faro | 92,80% |
| Aveiro | 55,55% |
| Quatipuru | 62,18% |

---

## 2. METODOLOGIA E DADOS

### Como garantir que não há anistia para desmatamentos recentes?
[cite_start]A metodologia utiliza a **Coleção 9 do MapBiomas** para isolar o marco temporal de **22 de julho de 2008**[cite: 38, 289, 581]. [cite_start]O benefício da redução ($\Delta_{reg}$) incide exclusivamente sobre o **passivo consolidado** (pré-2008)[cite: 61, 404, 576]. [cite_start]Os **2,2 milhões de hectares** de supressão detectados após 2008 permanecem como passivo não consolidado, exigindo recomposição integral[cite: 403, 563, 577].

### Qual a precisão do cálculo de 5,8 milhões de hectares?
[cite_start]O valor de **5,803 milhões de hectares** é o resultado de um processamento geoestatístico de alta precisão realizado via **Google Earth Engine (GEE)**[cite: 60, 384, 575]. [cite_start]Foram analisados **8.153 imóveis** rurais superiores a 4 módulos fiscais localizados nos municípios elegíveis[cite: 507, 576].

### Por que focar apenas em imóveis acima de 4 Módulos Fiscais (MF)?
[cite_start]Porque imóveis de até 4 MF já possuem o benefício de "congelamento" da Reserva Legal pelo Artigo 67 do Código Florestal[cite: 71, 158]. [cite_start]O gargalo da regularização ambiental e a paralisia do PRA no Pará concentram-se nas médias e grandes propriedades, que agora encontram viabilidade técnica nesta metodologia[cite: 72, 73, 163].

### O que significam os campos `def_80_ha`, `def_50_ha` e `delta_reg`?

- **def_80_ha**: Déficit de Reserva Legal considerando a exigência de 80% (regra geral na Amazônia)
- **def_50_ha**: Déficit considerando a exigência reduzida para 50% (Art. 12)
- **delta_reg**: Ganho de área regularizável = `def_80_ha - def_50_ha`

Fórmula:
```
delta_reg = max(0, area_ha × 0.8 - veg22_ha) - max(0, area_ha × 0.5 - veg22_ha)
```

### Por que usar o MapBiomas Collection 9 (2008) e Collection 10 (2022)?

A Collection 9 do MapBiomas é a versão mais consolidada para o mapeamento histórico de uso e cobertura do solo, com qualidade validada para o ano de referência de 2008 (marco temporal do Código Florestal). A Collection 10 (Sentinel-2) oferece dados mais recentes para 2022, permitindo a detecção de supressões pós-2008.

---

## 3. CLASSIFICAÇÃO DOS IMÓVEIS

### O que acontece com imóveis em municípios NÃO elegíveis?
Imóveis located fora dos 18 municípios elegíveis aparecem nos CSVs com `elegivel_final = FALSE` e `delta_validado = 0`. Estes imóveis **não se beneficiam** da redução do Art. 12 e devem recompor 80% da área original da Reserva Legal.

### Qual a diferença entre "passivo consolidado" e "passivo não consolidado"?

| Tipo | Período | Implicação |
|------|---------|------------|
| **Passivo Consolidado** | Pré-2008 | Pode ser objeto de redução via Art. 12 |
| **Passivo Não Consolidado** | Pós-2008 | Exige recomposição integral, sem benefício da redução |

### Distribuição dos imóveis elegíveis:

| Status | Quantidade | Área Total (ha) |
|--------|------------|-----------------|
| Elegível - Sem Passivo | 1.690 | 12.734.542 |
| Elegível - Apenas Passivo Consolidado | 1.874 | 4.481.134 |
| Elegível - Apenas Passivo Não Consolidado | 2.775 | 6.252.647 |
| Elegível - Ambos Passivos | 1.814 | 2.579.188 |
| Não Elegível | 22.814 | 40.122.111 |

---

## 4. IMPACTO E GESTÃO PÚBLICA

### Qual o benefício prático para o Estado?
[cite_start]A metodologia permite a **conformidade ambiental imediata de 3.564 propriedades**[cite: 62, 576]. [cite_start]Isso descloga a fila de análise do SICAR-PA e permite que os órgãos de fiscalização foquem seus recursos cirurgicamente nos polígonos de ilegalidade pós-2008[cite: 94, 569, 585].

### O que é o conceito de "Justiça Territorial" citado no parecer?
[cite_start]É o reconhecimento de que o produtor rural nestes municípios deve ter o benefício legal como contrapartida ao fato de que o município onde ele produz já cumpre uma altíssima função ambiental pública, mantendo mais de metade do seu território sob preservação estrita (UCs e TIs)[cite: 560, 582].

### Quais métricas o Estado deve monitorar?

1. **Delta total de regularização**: 1.332.922 ha (benefício potencial)
2. **Redução do déficit**: 5.803.014 ha (80% → 50%)
3. **Passivo não consolidado**: 2.260.083 ha (prioridade de fiscalização)
4. **Imóveis com benefício**: 4.130

---

## 5. LIMITAÇÕES E ADVERTÊNCIAS

### Quais as limitações da metodologia?

- **Sobreposição com Terras Indígenas**: Imóveis com sobreposição em TIs em processo de demarcação podem apresentar inconsistências
- **Qualidade do SICAR**: A base do SICAR-PA pode conter códigos CAR duplicados ou desatualizados
- **Precisão do MapBiomas**: O produto apresenta precisão de ~85% na classificação de uso do solo

### O que não está coberto pela metodologia?

- Imóveis com vegetação já consolidada (delta = 0)
- Áreas de Preservação Permanente (APP) e Reservas Legais já regularizadas
- Passivos em municípios fora da elegibilidade

---

## 6. REPRODUTIBILIDADE E AUDITORIA

### Como auditar esses números?
A transparência é total. [cite_start]Todo o código-fonte (Python/R) e a lógica de filtragem espacial estão disponíveis neste repositório GitHub[cite: 234, 588]. [cite_start]Qualquer órgão de controle pode replicar o processamento utilizando as bases oficiais do SICAR-PA e MapBiomas para validar os resultados apresentados[cite: 263, 587, 627].

### Quais bases de dados oficiais são utilizadas?

| Base | Fonte | Versão |
|------|-------|--------|
| Imóveis CAR | SICAR-PA | 2024 |
| Vegetação 2008 | MapBiomas | Collection 9 |
| Vegetação 2022 | MapBiomas | Collection 10 (S2) |
| Áreas Protegidas | IDEFLOR-Bio | 2024 |

### Como executar a análise?

```bash
# 1. Análise principal
Rscript code/analise_reserva_legal.R

# 2. Análise de passivo
Rscript code/analise_passivo.R

# 3. Processamento Python
python code/total_delta_reg_ha.py
python code/total_delta_reg_mun_alvo.py
```

---

## 7. PRODUTOS GERADOS

### CSVs

| Arquivo | Descrição |
|---------|-----------|
| `resultados_elegibilidade.csv` | Base completa com flags de elegibilidade |
| `resultados_classificacao_passivo.csv` | Base com classificação de passivo |
| `ranking_municipal.csv` | Ranking de municípios elegíveis |
| `ranking_municipal_completo.csv` | Todos os municípios |
| `consolidado_art12_valido.csv` | Imóveis em municípios elegíveis |

### Gráficos

| Arquivo | Descrição |
|---------|-----------|
| `grafico_deficit_cenarios.jpg` | Comparativo 80% vs 50% |
| `grafico_ranking_municipal.jpg` | Ranking completo |
| `grafico_ranking_top10.jpg` | Top 10 municípios |
| `grafico_passivo_nao_consolidado.jpg` | Distribuição passivo pós-2008 |
| `grafico_passivo_consolidado.jpg` | Distribuição passivo pré-2008 |
| `grafico_pizza_passivo_nao_con.jpg` | Proporção com/sem passivo |
| `grafico_categoria_passivo.jpg` | Categorias de passivo |

---

## Referências

- Lei nº 12.651/2012 (Código Florestal) - Art. 12
- PAE nº 2025/2587584 - IDEFLOR-Bio
- MapBiomas Collection 9 e Collection 10
- SICAR-PA - Sistema de Cadastro Ambiental Rural

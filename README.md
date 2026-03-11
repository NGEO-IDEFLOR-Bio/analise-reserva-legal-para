# Analise do Passivo de Reserva Legal (CAR) - Estado do Para

## Contexto

Projeto de analise geoestatistica para quantificar o impacto da reducao da Reserva Legal (RL) de 80% para 50% no Estado do Para, conforme Artigo 12 da Lei nº 12.651/2012 (Codigo Florestal).

Objetivo: Medir o potencial de transicao do passivo consolidado para a conformidade ambiental em imoveis acima de 4 Modulos Fiscais (MF).

## Estrutura do Projeto

```
├── code/
│   ├── analise_reserva_legal.R    # Script principal (tidyverse)
│   └── analise-car-gee.js         # Codigo GEE para extracao de dados
├── docs/
│   └── contrato-analise.md        # Documento de diretrizes
├── materiais/
│   ├── Impacto_Reducao_RL_Para_Acima_4MF.csv
│   ├── ti_homologadas_uc_uso-e-dominio-publico.csv
│   └── DICIONARIO.md
├── output/
│   └── (produtos gerados pelo script R)
├── README.md
└── gitignore
```

## Requisitos

- R >= 4.0
- Pacotes: tidyverse, janitor, stringr, scales, stringi

Instalacao:
```r
install.packages(c("tidyverse", "janitor", "stringr", "scales", "stringi"))
```

## Execucao

Na raiz do projeto:
```bash
Rscript code/analise_reserva_legal.R
```

Ou no console R:
```r
source("code/analise_reserva_legal.R")
```

## Produtos

- `grafico_deficit_cenarios.jpg` - Comparativo de deficit 80% vs 50%
- `grafico_ranking_municipal.jpg` - Top 10 municipios por ganho de area
- `grafico_passivo_nao_consolidado.jpg` - Distribuicao do passivo pos-2008
- `resultados_elegibilidade.csv` - Base completa com flag de elegibilidade
- `ranking_municipal.csv` - Ranking municipal

## Base Legal

- Lei nº 12.651/2012 (Codigo Florestal) - Art. 12
- PAE nº 2025/2587584 - IDEFLOR-Bio
- Zoneamento Economico-Ecologico do Estado do Para (ZEE-PA)

## Dados de Entrada

| Arquivo | Descricao |
|---------|-----------|
| Impacto_Reducao_RL_Para_Acima_4MF.csv | Resultados GEE (Landsat/Sentinel-2) |
| ti_homologadas_uc_uso-e-dominio-publico.csv | Criterios de elegibilidade municipal |

## Licenca

MIT License

# Analise de Passivo Consolidado vs Nao Consolidado

## Contexto

Esta analise complementa o estudo principal sobre a reducao da Reserva Legal (RL) de 80% para 50% conforme Art. 12 da Lei 12.651/2012.

O objetivo e entender a composicao do passivo ambiental nos imoveis elegiveis, distinguishing entre:
- **Passivo Consolidado**: Deficit pre-existente (antes de 2008)
- **Passivo Nao Consolidado**: Supressao de vegetacao apos 2008

## Justificativa

A diferenciacao entre passivo consolidado e nao consolidado e fundamental para:

1. **Rigor Probatrio**: Imoveis com apenas passivo consolidado (pre-2008) possuem maior potencial de regularizacao, pois o desmatamento anterior ao marco temporal nao esta sujeito as mesmas penalidades.

2. **Barreiras a Regularizacao**: Imoveis com passivo nao consolidado (pos-2008) enfrentam barreiras adicionais,pois a supressao recente de vegetacao pode inviabilizar a reducao da RL.

3. **Planejamento**: Permite identificar qual parcela dos imoveis elegiveis poderia se beneficar efetivamente da reducao de 80% para 50%.

## Metodologia

### Classificacao de Elegibilidade

Um imovel e considerado elegivel se:
- Municipio com mais de 50% de area em Unidades de Conservacao (UC) ou Terras Indigenas (TI)

### Categorias de Passivo Nao Consolidado

| Categoria | Intervalo (ha) |
|-----------|---------------|
| Sem passivo | 0 |
| Passivo Pequeno | > 0 - 50 |
| Passivo Medio | 51 - 200 |
| Passivo Grande | 201 - 500 |
| Passivo Muito Grande | > 500 |

### Status do Imovel

- Elegivel - Apenas Passivo Consolidado
- Elegivel - Sem Passivo
- Elegivel - Ambos Passivos
- Elegivel - Apenas Passivo Nao Consolidado
- Nao Elegivel

## Dados de Entrada

- `Impacto_Reducao_RL_Para_Acima_4MF.csv` - Base de imoveis CAR
- `ti_homologadas_uc_uso-e-dominio-publico.csv` - Percentual de UC por municipio

## Executar a Analise

```bash
Rscript code/analise_passivo.R
```

## Produtos Gerados

### Graficos

- `grafico_pizza_passivo_nao_con.jpg` - Proporcao de imoveis com/sem passivo nao consolidado
- `grafico_categoria_passivo.jpg` - Distribuicao por categoria de passivo
- `grafico_delta_passivo.jpg` - Delta medio de regularizacao por status

### Dados

- `resultados_classificacao_passivo.csv` - Base completa com flags de classificacao
- `resumo_status_imoveis.csv` - Resumo agregado por status
- `dist_categoria_passivo.csv` - Distribuicao por categoria

## Interpretação dos Resultados

### Imoveis com Apenas Passivo Consolidado

Estes imoveis sao os melhores candidatos a regularizacao, pois:
- O deficit existente e anterior ao marco temporal (2008)
- A reducao de 80% para 50% pode ser suficiente para alcancar conformidade
- Nao ha desmatamento recente a ser penalizado

### Imoveis com Passivo Nao Consolidado

Estes imoveis enfrentan barreiras:
- O desmatamento pos-2008 pode comprometer a area de RL remanescente
- Podem estar sujeitos a embargos e sancoes administrativas
- A reducao de 50% pode nao ser suficiente para quitar o deficit

## Referencia

- Lei nº 12.651/2012 (Codigo Florestal) - Art. 12
- PAE nº 2025/2587584 - IDEFLOR-Bio
- Protocolo do CNJ (2023) sobre valor probatorio de imagens de satelite

# DICIONÁRIO DE DADOS E METADADOS TÉCNICOS

**Projeto:** Análise Geoestatística do Passivo de Reserva Legal (> 4MF) no Pará 
**Responsável:** Samuel Santos (NGEO/IDEFLOR-Bio)
**Data de Geração:** 10/03/2026

## 1. DESCRIÇÃO GERAL

Este conjunto de dados quantifica o impacto da redução da Reserva Legal (RL) de 80% para 50% em imóveis de médio e grande porte no Estado do Pará. O processamento identifica espacialmente o passivo consolidado (pré-2008) e o passivo não consolidado, simulando cenários de conformidade ambiental baseados no Artigo 12 da Lei nº 12.651/2012.

## 2. FONTES DE DADOS E PROCESSAMENTO

* 
**Base Vetorial:** Dados extraídos do banco de dados `ngeo.tb_sicar`, filtrados para imóveis com `tamanho_imovel = 'Acima de 4MF'`.


* 
**Malha Territorial:** Limites municipais (IBGE) e índices de Módulos Fiscais (INCRA) integrados via Python/Geopandas.


* 
**Sensoriamento Remoto (Marco de 2008):** MapBiomas Coleção 9 (Landsat - 30m) para validação da área rural consolidada em 22 de julho de 2008.


* 
**Sensoriamento Remoto (Cenário Atual):** MapBiomas Coleção 10 (Sentinel-2 Beta - 10m) para diagnóstico da cobertura vegetal em 2022.


* 
**Ambiente de Processamento:** Google Earth Engine (GEE) via algoritmos de redução zonal (`reduceRegions`).



## 3. DICIONÁRIO DE VARIÁVEIS (COLUNAS)

| Coluna | Descrição Técnica | Base Legal / Referência |
| --- | --- | --- |
| `codigo_car` | Chave primária do imóvel no SICAR-PA. | Lei 12.651/2012 

 |
| `area_ha` | Área total do imóvel rural convertida para hectares. 

 |  |
| `veg08_ha` | Vegetação nativa remanescente em 22/07/2008 (ha). | Art. 3º, IV 

 |
| `veg22_ha` | Vegetação nativa remanescente no ano de 2022 (ha). 

 |  |
| `pass_n_con` | **Passivo Não Consolidado:** Supressão detectada pós-2008 (ha). 

 |  |
| `def_80_ha` | Déficit de RL calculado sobre a exigência padrão de 80%. | Art. 12 

 |
| `def_50_ha` | Déficit de RL simulado com a redução para 50%. | Art. 12, §4º e 5º 

 |
| `delta_reg` | **Impacto da Redução:** Área que deixa de ser passivo oneroso. 

 |  |
| `beneficia` | Indica se o imóvel atende aos critérios para redução da RL. | Decreto Fed. 2013 

 |

## 4. PARÂMETROS DE QUALIDADE E RIGOR PROBATÓRIO

* 
**Padrão Geográfico:** Os cálculos de área utilizam a função `ee.Image.pixelArea()`, garantindo precisão métrica independente da projeção cartográfica.


* 
**Confiabilidade Jurídica:** A metodologia segue o **Protocolo do CNJ (2023)** e o entendimento do **STJ**, conferindo às imagens de satélite presunção de veracidade e valor de prova documental.


* 
**Integridade:** O processo automatizado elimina erros de interpretação humana e viabiliza a análise de Big Data em escala estadual.


## 📑 Contrato de Análise Geoestatística (R / tidyverse)

### 1. Preparação e Harmonização (ETL)

O primeiro passo é garantir que a "conversa" entre as duas tabelas seja perfeita, já que os nomes de municípios podem vir com variações de acentuação ou caixa.

* **Ação:** Carregar o `Impacto_Reducao_RL_Para_Acima_4MF.csv` (vírgula) e o `ti_uc_filtradas.csv` (ponto e vírgula).
* **Standardization:** Criar uma função para remover acentos e converter para *UPPERCASE* as colunas de município em ambos os *dataframes*.
* 
**Legal Join:** Realizar um `left_join` para injetar a coluna de elegibilidade (`+50`) na base de imóveis do CAR.



### 2. Validação da Elegibilidade Jurídica

Nem todo imóvel que o GEE marcou como `beneficia == 'Sim'` terá o benefício validado se o município não cumprir o requisito legal.

* **Filtro Art. 12:** Criar uma coluna lógica `elegivel_final`.
* 
**Critério:** O imóvel deve estar em um município com `Percentual > 50` (áreas protegidas) OU estar nas zonas delimitadas pelo ZEE-PA (Oeste, Leste e Calha Norte).



### 3. Extração de Métricas de Impacto (Os "Números de Ouro")

Utilizar o `summarise()` para gerar os indicadores que vão para o seu **Capítulo 4**:

* 
**Delta Total (ha):** $\sum \text{delta\_reg}$ apenas para imóveis elegíveis.


* 
**Redução da Demanda de Recomposição:** Comparar a soma de $\text{Deficit}_{80}$ vs $\text{Deficit}_{50}$.


* 
**Hectares de Passivo Não Consolidado:** $\sum \text{pass\_n\_con}$ para atestar o rigor contra desmatamentos pós-2008.



### 4. Categorização de Conformidade Ambiental

Determinar o potencial de transição do passivo para a regularidade:

* 
**Imóveis "Salvos":** Contar quantos imóveis possuíam déficit no cenário de 80%, mas atingem déficit zero (conformidade total) com os 50%.


* 
**Inadimplência Forçada:** Identificar imóveis onde o custo de recomposição dos 80% excederia a capacidade produtiva (área de déficit vs área total).



### 5. Plano de Visualização (ggplot2)

Gerar as evidências visuais para o relatório:

* **Gráfico de Barras (Cenários):** Comparativo visual do estoque de passivo ambiental (80% vs 50%) em hectares.
* 
**Ranking Municipal:** Top 10 municípios que mais "liberam" área para produção sustentável através da regularização.


* **Plot de Dispersão:** Relação entre o tamanho do imóvel (`area_ha`) e o benefício recebido (`delta_reg`).

---

### Exemplo de Estrutura do Script (Sugestão):

```R
# Carregamento
library(tidyverse)
library(janitor)

imoveis <- read_csv("Impacto_Reducao_RL_Para_Acima_4MF.csv") %>% clean_names()
municipios_elegiveis <- read_delim("ti_uc_filtradas.csv", delim = ";") %>% clean_names()

# Harmonização (Exemplo de lógica)
imoveis <- imoveis %>%
  mutate(municipio_clean = str_to_upper(iconv(municipio, to="ASCII//TRANSLIT")))

# Cruzamento e Cálculo do Delta Real
# (Considere apenas o delta onde o município é elegível)
resultado_final <- imoveis %>%
  left_join(municipios_elegiveis, by = c("municipio_clean" = "municipio")) %>%
  mutate(impacto_validado = if_else(!is.na(x50), delta_reg, 0))

# Resumo para o Capítulo 4
resumo_estado <- resultado_final %>%
  summarise(
    total_area_regularizada = sum(impacto_validado),
    imoveis_beneficiados = sum(impacto_validado > 0),
    passivo_pos_2008 = sum(pass_n_con)
  )

```
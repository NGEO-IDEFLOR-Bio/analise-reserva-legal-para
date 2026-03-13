# ==============================================================================
# Analise de Passivo Consolidado vs Nao Consolidado nos Imoveis Elegiveis
# PAE no 2025/2587584 - IDEFLOR-Bio
# ==============================================================================

# Configuracao de Diretorios ----
dir_root <- ifelse(basename(getwd()) == "code", "..", ".")
dir_output <- file.path(dir_root, "output")
dir_materiais <- file.path(dir_root, "materiais")

if (!dir.exists(dir_output)) dir.create(dir_output)

# 1. CARREGAMENTO DE PACOTES ----
library(tidyverse)
library(janitor)
library(stringr)
library(scales)
library(stringi)

# 2. LEITURA DOS DADOS ----
imoveis <- read_csv(file.path(dir_materiais, "Impacto_Reducao_RL_Para_Acima_4MF.csv")) %>%
  clean_names()

ucs <- read_delim(
  file.path(dir_materiais, "ti_homologadas_uc_uso-e-dominio-publico.csv"),
  delim = ";",
  locale = locale(decimal_mark = ",")
) %>%
  clean_names()

# 3. HARMONIZACAO DE DADOS ----
normalizar_municipio <- function(x) {
  x %>%
    stri_trans_general("Latin-ASCII") %>%
    str_to_upper() %>%
    str_replace_all("[^A-Z ]", "") %>%
    str_squish()
}

imoveis <- imoveis %>%
  mutate(municipio_clean = normalizar_municipio(municipio))

ucs <- ucs %>%
  mutate(municipio_clean = normalizar_municipio(municipio))

ucs <- ucs %>%
  mutate(percentual = as.numeric(percentual))

# 4. CLASSIFICACAO DE ELEGIBILIDADE E PASSIVO ----
imoveis_classif <- imoveis %>%
  left_join(
    ucs %>% select(municipio_clean, percentual),
    by = "municipio_clean"
  ) %>%
  mutate(
    percentual = coalesce(percentual, 0),
    criterio_uc = percentual > 50,
    elegivel = criterio_uc,
    
    # Classificacao do passivo
    tem_passivo_nao_con = pass_n_con > 0,
    passivo_nao_con_cat = case_when(
      pass_n_con == 0 ~ "Sem passivo pos-2008",
      pass_n_con > 0 & pass_n_con <= 50 ~ "Passivo Pequeno (<=50 ha)",
      pass_n_con > 50 & pass_n_con <= 200 ~ "Passivo Medio (51-200 ha)",
      pass_n_con > 200 & pass_n_con <= 500 ~ "Passivo Grande (201-500 ha)",
      pass_n_con > 500 ~ "Passivo Muito Grande (>500 ha)"
    ),
    
    # Passivo Consolidado
    passivo_consolidado = pmax(0, area_ha * 0.8 - veg08_ha),
    tem_passivo_con = passivo_consolidado > 0,
    
    # Status final
    status_imovel = case_when(
      elegivel & !tem_passivo_nao_con & tem_passivo_con ~ "Elegivel - Apenas Passivo Consolidado",
      elegivel & !tem_passivo_nao_con & !tem_passivo_con ~ "Elegivel - Sem Passivo",
      elegivel & tem_passivo_nao_con & tem_passivo_con ~ "Elegivel - Ambos Passivos",
      elegivel & tem_passivo_nao_con & !tem_passivo_con ~ "Elegivel - Apenas Passivo Nao Consolidado",
      !elegivel ~ "Nao Elegivel"
    )
  )

# 5. ANALISES ----

# 5.1 Resumo geral por status
cat("\n================================================================================\n")
cat("   ANALISE DE PASSIVO CONSOLIDADO VS NAO CONSOLIDADO\n")
cat("   PAE no 2025/2587584 - IDEFLOR-Bio\n")
cat("================================================================================\n\n")

resumo_status <- imoveis_classif %>%
  group_by(status_imovel) %>%
  summarise(
    quantidade = n(),
    area_total_ha = sum(area_ha, na.rm = TRUE),
    delta_reg_total = sum(delta_reg, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(quantidade))

cat("RESUMO POR STATUS DO IMOVEL:\n")
cat("--------------------------------------------------------------------------------\n")
print(resumo_status)
cat("\n")

# 5.2 Imoveis elegiveis: com vs sem passivo nao consolidado
cat("IMOVEIS ELEGIVEIS - COM VS SEM PASSIVO NAO CONSOLIDADO:\n")
cat("--------------------------------------------------------------------------------\n")

elegiveis_passivo <- imoveis_classif %>%
  filter(elegivel) %>%
  group_by(tem_passivo_nao_con) %>%
  summarise(
    quantidade = n(),
    area_total_ha = sum(area_ha, na.rm = TRUE),
    delta_reg_medio = mean(delta_reg, na.rm = TRUE),
    delta_reg_total = sum(delta_reg, na.rm = TRUE),
    .groups = "drop"
  )

print(elegiveis_passivo)
cat("\n")

# 5.3 Distribuicao por categoria de passivo nao consolidado (elegiveis)
cat("DISTRIBUICAO POR CATEGORIA DE PASSIVO NAO CONSOLIDADO (ELEGIVEIS):\n")
cat("--------------------------------------------------------------------------------\n")

dist_passivo <- imoveis_classif %>%
  filter(elegivel) %>%
  group_by(passivo_nao_con_cat) %>%
  summarise(
    quantidade = n(),
    area_total_ha = sum(area_ha, na.rm = TRUE),
    delta_reg_total = sum(delta_reg, na.rm = TRUE),
    .groups = "drop"
  )

print(dist_passivo)
cat("\n")

# 5.4 Percentual de imoveis elegiveis com passivo nao consolidado
total_elegiveis <- sum(imoveis_classif$elegivel)
com_passivo_nao_con <- sum(imoveis_classif$elegivel & imoveis_classif$tem_passivo_nao_con)
sem_passivo_nao_con <- total_elegiveis - com_passivo_nao_con

cat("SINTESE - IMOVEIS ELEGIVEIS:\n")
cat("--------------------------------------------------------------------------------\n")
cat(sprintf("  Total de imoveis elegiveis:             %s\n", scales::number(total_elegiveis, big.mark = ".")))
cat(sprintf("  Com passivo nao consolidado (pos-2008): %s (%.1f%%)\n", 
            scales::number(com_passivo_nao_con, big.mark = "."),
            com_passivo_nao_con / total_elegiveis * 100))
cat(sprintf("  Sem passivo nao consolidado:            %s (%.1f%%)\n", 
            scales::number(sem_passivo_nao_con, big.mark = "."),
            sem_passivo_nao_con / total_elegiveis * 100))
cat("================================================================================\n")

# 6. GRAFICOS ----
theme_set(theme_minimal(base_size = 12))
theme_update(
  text = element_text(family = "serif"),
  plot.background = element_rect(fill = "white", color = NA),
  plot.title = element_text(hjust = 0.5, margin = margin(b = 10)),
  plot.subtitle = element_text(margin = margin(t = 0, b = 15))
)

tema_abnt <- theme(
  legend.position = "none",
  panel.border = element_rect(color = "black", fill = NA, linewidth = 1),
  panel.grid.minor = element_blank(),
  panel.grid.major = element_line(color = "gray90"),
  axis.title = element_text(size = 11, face = "bold"),
  axis.text = element_text(size = 10)
)

# Grafico 1: Pizza - Imoveis elegiveis com vs sem passivo nao consolidado
dados_pizza <- tibble(
  categoria = c("Com Passivo\nNao Consolidado", "Sem Passivo\nNao Consolidado"),
  valor = c(com_passivo_nao_con, sem_passivo_nao_con)
)

grafico_pizza <- dados_pizza %>%
  ggplot(aes(x = "", y = valor, fill = categoria)) +
  geom_bar(width = 1, stat = "identity", color = "white") +
  coord_polar("y", start = 0) +
  geom_text(aes(label = scales::percent(valor / sum(valor))),
            position = position_stack(vjust = 0.5), size = 5, family = "serif") +
  scale_fill_manual(values = c("#d35400", "#27AE60")) +
  labs(
    title = "Imoveis Elegiveis: Passivo Nao Consolidado",
    subtitle = "Proporcao de imoveis com e sem desmatamento pos-2008",
    x = NULL,
    y = NULL
  ) +
  tema_abnt +
  theme(axis.text = element_blank())

ggsave(paste0(dir_output, "/grafico_pizza_passivo_nao_con.jpg"), grafico_pizza, 
      width = 8, height = 6, dpi = 300, bg = "white")

# Grafico 2: Barras - Distribuicao por categoria de passivo
grafico_categoria <- dist_passivo %>%
  ggplot(aes(x = reorder(passivo_nao_con_cat, quantidade), y = quantidade, fill = quantidade)) +
  geom_col(width = 0.7) +
  scale_fill_gradient(low = "#FAD7A0", high = "#E74C3C") +
  geom_text(aes(label = scales::number(quantidade, big.mark = ".")),
            vjust = -0.5, size = 4, family = "serif") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(
    title = "Distribuicao de Imoveis Elegiveis por Categoria",
    subtitle = "Categorias de Passivo Nao Consolidado",
    x = NULL,
    y = "Quantidade de Imoveis"
  ) +
  tema_abnt +
  theme(axis.text.x = element_text(angle = 15, hjust = 1))

ggsave(paste0(dir_output, "/grafico_categoria_passivo.jpg"), grafico_categoria, 
      width = 10, height = 6, dpi = 300, bg = "white")

# Grafico 3: Comparativo de delta_reg medio por status
delta_por_status <- imoveis_classif %>%
  filter(elegivel) %>%
  group_by(tem_passivo_nao_con) %>%
  summarise(
    delta_medio = mean(delta_reg, na.rm = TRUE),
    delta_total = sum(delta_reg, na.rm = TRUE),
    .groups = "drop"
  )

grafico_delta <- delta_por_status %>%
  ggplot(aes(x = tem_passivo_nao_con, y = delta_medio, fill = tem_passivo_nao_con)) +
  geom_col(width = 0.5) +
  scale_fill_manual(values = c("#27AE60", "#E74C3C")) +
  geom_text(aes(label = scales::number(delta_medio, big.mark = ".", decimal.mark = ",")),
            vjust = -0.5, size = 5, family = "serif") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(
    title = "Delta de Regularizacao Medio por Status",
    subtitle = "Imoveis elegiveis: com vs sem passivo nao consolidado",
    x = "Possui Passivo Nao Consolidado",
    y = "Delta Medio (ha)"
  ) +
  tema_abnt

ggsave(paste0(dir_output, "/grafico_delta_passivo.jpg"), grafico_delta, 
      width = 8, height = 6, dpi = 300, bg = "white")

# 7. EXPORTAR DADOS ----
write_csv(imoveis_classif, paste0(dir_output, "/resultados_classificacao_passivo.csv"))
write_csv(resumo_status, paste0(dir_output, "/resumo_status_imoveis.csv"))
write_csv(dist_passivo, paste0(dir_output, "/dist_categoria_passivo.csv"))

cat("\nArquivos gerados em output/:\n")
cat("  - grafico_pizza_passivo_nao_con.jpg\n")
cat("  - grafico_categoria_passivo.jpg\n")
cat("  - grafico_delta_passivo.jpg\n")
cat("  - resultados_classificacao_passivo.csv\n")
cat("  - resumo_status_imoveis.csv\n")
cat("  - dist_categoria_passivo.csv\n")

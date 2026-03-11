# ==============================================================================
# Script de Analise Geoestatistica - Reserva Legal Para (Art. 12, Lei 12.651/2012)
# Base do CAR - PAE no 2025/2587584 - IDEFLOR-Bio
# Autoria: Coordenacao de Geotecnologias
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
# Base principal: Imoveis CAR acima de 4 MF com analise de deficit de RL
imoveis <- read_csv(file.path(dir_materiais, "Impacto_Reducao_RL_Para_Acima_4MF.csv")) %>%
  clean_names()

# Base de areas protegidas: Criterios de elegibilidade municipal
# Delimitador ponto-e-virgula, virgula como decimal
ucs <- read_delim(
  file.path(dir_materiais, "ti_homologadas_uc_uso-e-dominio-publico.csv"),
  delim = ";",
  locale = locale(decimal_mark = ",")
) %>%
  clean_names()

# 3. HARMONIZACAO DE DADOS ----
# Funcao robusta para normalizar nomes de municipios (usa stringi)
normalizar_municipio <- function(x) {
  x %>%
    stri_trans_general("Latin-ASCII") %>%
    str_to_upper() %>%
    str_replace_all("[^A-Z ]", "") %>%
    str_squish()
}

# Aplicar harmonizacao na base de imoveis
imoveis <- imoveis %>%
  mutate(municipio_clean = normalizar_municipio(municipio))

# Aplicar harmonizacao na base de UCs
ucs <- ucs %>%
  mutate(municipio_clean = normalizar_municipio(municipio))

# Converter coluna percentual para numeric (trata NAs explicitamente)
ucs <- ucs %>%
  mutate(percentual = as.numeric(percentual))

# 4. VERIFICACAO DE DADOS ----
# Verificar municipios sem correspondencia no join
imoveis_sem_uc <- anti_join(imoveis, ucs, by = "municipio_clean")
if (nrow(imoveis_sem_uc) > 0) {
  cat("\n[AVISO] Municipios sem correspondencia na base de UCs:\n")
  print(imoveis_sem_uc %>% count(municipio_clean) %>% head(20))
}

# 5. DEFINICAO DAS ZONAS DO ZEE-PA ----
# Zonas elegiveis conforme Art. 12 e ZEE-PA: Oeste, Leste e Calha Norte
# JA normalizados (sem acentos)
zonas_zee_elegiveis <- c(
  "ALTAMIRA", "ITAITUBA", "TRAIRAO", "NOVO PROGRESSO",
  "ITAUPIRANGA", "MARABA", "PARAGOMINAS", "REDENCAO",
  "OURILANDIA DO NORTE", "TUCUMA", "SAO FELIX DO XINGU",
  "XINGUARA", "CONCEICAO DO ARAGUAIA", "BREJO GRANDE DO ARAGUAIA",
  "CANAA DOS CARAJA", "PARAUAPEBAS", "JACAREACANGA",
  "SENADOR JOSE PORFIRIO", "PORTO DE MOZ", "ORIXIMINA",
  "OBIDOS", "MONTE ALEGRE", "AVEIRO", "FARO",
  "BELTERRA", "SANTAREM", "RUROPOLIS", "MEDICILANDIA",
  "NOVO REPARTIMENTO", "PACAJA", "CURIONOPOLIS",
  "ELDORADO DOS CARAJAS", "RONDON DO PARA", "OURILANDIA",
  "FLORESTA DO ARAGUAIA"
)

# 6. VALIDACAO JURIDICA - CRITERIO DE ELEGIBILIDADE ----
imoveis_elegiveis <- imoveis %>%
  left_join(
    ucs %>% select(municipio_clean, percentual, x50),
    by = "municipio_clean"
  ) %>%
  mutate(
    # Tratar NAs explicitly
    percentual = coalesce(percentual, 0),
    
    # Criterio 1: Municipio com >50% de areas protegidas
    criterio_uc = percentual > 50,
    
    # Criterio 2: Municipio em zona elegivel do ZEE-PA
    criterio_zee = municipio_clean %in% zonas_zee_elegiveis,
    
    # Elegibilidade final: satisfaz pelo menos um criterio
    elegivel_final = criterio_uc | criterio_zee,
    
    # Delta regularizacao validado (so conta se elegivel)
    delta_validado = if_else(elegivel_final, delta_reg, 0)
  )

# 7. EXTRACAO DE METRICAS DE IMPACTO ----
resumo_estado <- imoveis_elegiveis %>%
  summarise(
    delta_total_ha = sum(delta_validado, na.rm = TRUE),
    deficit_80_total_ha = sum(def_80_ha, na.rm = TRUE),
    deficit_50_total_ha = sum(def_50_ha, na.rm = TRUE),
    reducao_deficit_ha = deficit_80_total_ha - deficit_50_total_ha,
    passivo_nao_consolidado_ha = sum(pass_n_con, na.rm = TRUE),
    total_imoveis = n(),
    imoveis_beneficiados = sum(beneficia == "Sim", na.rm = TRUE),
    imoveis_elegiveis_beneficio = sum(elegivel_final & delta_validado > 0, na.rm = TRUE),
    imoveis_conformidade_total = sum(def_50_ha == 0 & def_80_ha > 0, na.rm = TRUE)
  )

# 8. ANALISE MUNICIPAL ----
ranking_municipal <- imoveis_elegiveis %>%
  group_by(municipio) %>%
  summarise(
    delta_validado_total = sum(delta_validado, na.rm = TRUE),
    imoveis = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(delta_validado_total)) %>%
  head(10)

# Configuracao de temas para graficos com fundo branco e padrao ABNT
theme_set(theme_minimal(base_size = 12))
theme_update(
  text = element_text(family = "serif"),
  plot.background = element_rect(fill = "white", color = NA),
  plot.title = element_text(hjust = 0.5, margin = margin(b = 10)),
  plot.subtitle = element_text(margin = margin(t = 0, b = 15))
)

# Tema base com caixa ao redor do grafico
tema_abnt <- theme(
  legend.position = "none",
  panel.border = element_rect(color = "black", fill = NA, linewidth = 1),
  panel.grid.minor = element_blank(),
  panel.grid.major = element_line(color = "gray90"),
  axis.title = element_text(size = 11, face = "bold"),
  axis.text = element_text(size = 10)
)

# 9. VISUALIZACOES ACADEMICAS ----

# Grafico 1: Comparativo de deficit total por cenario (80% vs 50%)
grafico_deficit <- tibble(
  Cenario = c("80% RL\n(Atual)", "50% RL\n(Reduzido)"),
  Deficit_Ha = c(resumo_estado$deficit_80_total_ha, resumo_estado$deficit_50_total_ha)
) %>%
  ggplot(aes(x = Cenario, y = Deficit_Ha, fill = Cenario)) +
  geom_col(width = 0.6) +
  geom_text(aes(label = scales::label_number(scale = 1e-3, suffix = "k ha", decimal.mark = ",", big.mark = ".")(Deficit_Ha)),
            vjust = -0.5, size = 4.5, family = "serif") +
  scale_fill_manual(values = c("#455a64", "#1b5e20")) +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.2)),
    labels = scales::label_number(scale = 1e-3, suffix = "k ha", decimal.mark = ",", big.mark = ".")
  ) +
  labs(
    title = "Comparativo do Deficit de Reserva Legal por Cenario",
    subtitle = "Imoveis acima de 4 MF - Estado do Para",
    x = NULL,
    y = "Deficit (hectares)"
  ) +
  tema_abnt

ggsave(paste0(dir_output, "/grafico_deficit_cenarios.jpg"), grafico_deficit, 
      width = 10, height = 6, dpi = 300, bg = "white")

# Grafico 2: Ranking dos 10 municipios com maior ganho de area regularizada
# Paleta de cores: do mais claro (topo) ao mais escuro (base)
paleta_ranking <- c(
  "#E2EFB9", "#9ACD32", "#6B8E23", "#228B22", "#006400",
  "#FFD8A8", "#E9A20E", "#B8731E", "#5D3A1A", "#8B4513"
)

grafico_ranking <- ranking_municipal %>%
  ggplot(aes(x = reorder(municipio, delta_validado_total), y = delta_validado_total, fill = delta_validado_total)) +
  geom_col(width = 0.7) +
  scale_fill_gradientn(colors = c('#5D3A1A', '#FFEBCD', '#006400')) +
  coord_flip() +
  geom_text(aes(label = scales::label_number(scale = 1e-3, suffix = "k ha", decimal.mark = ",", big.mark = ".")(delta_validado_total)),
            hjust = -0.1, size = 3.5, family = "serif") +
  scale_x_discrete(expand = expansion(mult = c(0, 0.2))) +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.2)),
    labels = scales::label_number(scale = 1e-3, suffix = "k ha", decimal.mark = ",", big.mark = ".")
  ) +
  labs(
    title = "Top 10 Municipios - Ganho de Area Regularizada",
    subtitle = "Delta valido (elegivel por UC >50% ou ZEE-PA)",
    x = NULL,
    y = "Area (hectares)"
  ) +
  tema_abnt

ggsave(paste0(dir_output, "/grafico_ranking_municipal.jpg"), grafico_ranking, 
      width = 10, height = 6, dpi = 300, bg = "white")

# Grafico 3: Distribuicao do passivo nao consolidado
# Com densidade e limite no percentil 95
passivo_dados <- imoveis_elegiveis %>% filter(pass_n_con > 0)
passivo_stats <- passivo_dados %>%
  summarise(media = mean(pass_n_con), mediana = median(pass_n_con), p95 = quantile(pass_n_con, 0.95))

limite_x <- passivo_stats$p95

grafico_passivo <- passivo_dados %>%
  ggplot(aes(x = pass_n_con)) +
  geom_histogram(binwidth = 20, fill = "#d35400", color = "white", alpha = 0.7) +
  geom_density(aes(y = ..count.. * 20), fill = "gray", alpha = 0.2, color = NA) +
  geom_vline(xintercept = passivo_stats$mediana, linetype = "dashed", color = "#2C3E50", size = 1) +
  annotate("text", x = passivo_stats$mediana, y = Inf, 
           label = paste("Mediana:", round(passivo_stats$mediana), "ha"),
           vjust = 2, hjust = -0.1, color = "#2C3E50", size = 3.5, family = "serif") +
  coord_cartesian(xlim = c(0, limite_x)) +
  scale_x_continuous(
    expand = expansion(mult = c(0, 0.05)),
    labels = scales::label_number(scale = 1, suffix = " ha", decimal.mark = ",", big.mark = ".")
  ) +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.2))
  ) +
  labs(
    title = "Distribuicao do Passivo Nao Consolidado",
    subtitle = paste("Imoveis com desmatamento pos-2008 - Limite:", round(limite_x), "ha (percentil 95)"),
    x = "Passivo nao consolidado (ha)",
    y = "Frequencia de imoveis"
  ) +
  tema_abnt

ggsave(paste0(dir_output, "/grafico_passivo_nao_consolidado.jpg"), grafico_passivo, 
      width = 10, height = 6, dpi = 300, bg = "white")

# 10. RELATORIO FINAL ----
cat("\n")
cat("================================================================================\n")
cat("   RELATORIO DE ANALISE - RESERVA LEGAL PARA (Art. 12, Lei 12.651/2012)\n")
cat("   PAE no 2025/2587584 - IDEFLOR-Bio\n")
cat("================================================================================\n\n")

cat("METRICAS PRINCIPAIS:\n")
cat("--------------------------------------------------------------------------------\n")
cat(sprintf("  - Delta total de regularizacao (elegivel):  %s ha\n",
            scales::number(resumo_estado$delta_total_ha, big.mark = ".", decimal.mark = ",")))
cat(sprintf("  - Deficit total cenario 80%% (atual):        %s ha\n",
            scales::number(resumo_estado$deficit_80_total_ha, big.mark = ".", decimal.mark = ",")))
cat(sprintf("  - Deficit total cenario 50%% (reduzido):     %s ha\n",
            scales::number(resumo_estado$deficit_50_total_ha, big.mark = ".", decimal.mark = ",")))
cat(sprintf("  - Reducao do deficit:                       %s ha\n",
            scales::number(resumo_estado$reducao_deficit_ha, big.mark = ".", decimal.mark = ",")))
cat(sprintf("  - Passivo nao consolidado (pos-2008):      %s ha\n",
            scales::number(resumo_estado$passivo_nao_consolidado_ha, big.mark = ".", decimal.mark = ",")))
cat("--------------------------------------------------------------------------------\n")
cat(sprintf("  - Total de imoveis analisados:              %s\n",
            scales::number(resumo_estado$total_imoveis, big.mark = ".")))
cat(sprintf("  - Imoveis que se beneficiam:               %s\n",
            scales::number(resumo_estado$imoveis_beneficiados, big.mark = ".")))
cat(sprintf("  - Imoveis elegiveis com beneficio:         %s\n",
            scales::number(resumo_estado$imoveis_elegiveis_beneficio, big.mark = ".")))
cat(sprintf("  - Imoveis em conformidade total (50%%):    %s\n",
            scales::number(resumo_estado$imoveis_conformidade_total, big.mark = ".")))
cat("================================================================================\n")

# Exportar dados processados
write_csv(imoveis_elegiveis, paste0(dir_output, "/resultados_elegibilidade.csv"))
write_csv(ranking_municipal, paste0(dir_output, "/ranking_municipal.csv"))

cat("\nArquivos gerados em output/:\n")
cat("  - grafico_deficit_cenarios.jpg\n")
cat("  - grafico_ranking_municipal.jpg\n")
cat("  - grafico_passivo_nao_consolidado.jpg\n")
cat("  - resultados_elegibilidade.csv\n")
cat("  - ranking_municipal.csv\n")

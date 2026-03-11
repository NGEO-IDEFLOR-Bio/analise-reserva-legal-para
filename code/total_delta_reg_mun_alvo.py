import duckdb
import os

# Caminhos dos arquivos
file_resultados = os.path.join("output", "resultados_elegibilidade.csv")
file_municipios_elegiveis = os.path.join("materiais", "ti_homologadas_uc_uso-e-dominio-publico.csv")
output_file = os.path.join("output", "consolidado_art12_valido.csv")

print("Iniciando cruzamento e filtragem dos municípios elegíveis...")

# Executa a query SQL
# Nota: Usamos delim=';' e decimal=',' para a base de UCs/TIs conforme o seu arquivo
duckdb.query(f"""
    WITH municipios_alvo AS (
        SELECT 
            "Município [-]" AS nome_mun_ref
        FROM read_csv_auto('{file_municipios_elegiveis}', delim=';', decimal_separator=',')
        WHERE "+50" IS NOT NULL
    )
    SELECT 
        res.municipio,
        SUM(res.delta_reg) AS total_delta_reg_ha,
        SUM(res.def_80_ha - res.pass_n_con) AS passivo_consolidado_total,
        COUNT(res.codigo_car) AS total_imoveis
    FROM read_csv_auto('{file_resultados}') res
    INNER JOIN municipios_alvo m ON res.municipio = m.nome_mun_ref
    GROUP BY res.municipio
    ORDER BY total_delta_reg_ha DESC
""").write_csv(output_file)

print(f"✅ Sucesso! O arquivo filtrado e consolidado foi salvo em: {output_file}")
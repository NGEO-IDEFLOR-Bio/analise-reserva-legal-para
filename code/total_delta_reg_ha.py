import duckdb
import os

# Caminhos dos arquivos
input_file = os.path.join("output", "resultados_elegibilidade.csv")
output_file = os.path.join("output", "consolidado_delta_reg_municipio.csv")

# Certifica-se que a pasta output existe (opcional, já que o arquivo está lá)
if not os.path.exists("output"):
    os.makedirs("output")

print(f"Lendo {input_file} e consolidando dados...")

# Executa a query SQL diretamente no CSV usando DuckDB
duckdb.query(f"""
    SELECT 
        municipio, 
        SUM(delta_reg) AS total_delta_reg_ha,
        COUNT(codigo_car) AS qtd_imoveis_impactados
    FROM read_csv_auto('{input_file}')
    GROUP BY municipio
    ORDER BY total_delta_reg_ha DESC
""").write_csv(output_file)

print(f"Sucesso! Arquivo consolidado salvo em: {output_file}")
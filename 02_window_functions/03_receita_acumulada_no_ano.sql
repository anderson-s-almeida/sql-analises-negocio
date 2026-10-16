-- =====================================================================
-- Pergunta : Qual a receita acumulada no ano até cada mês (YTD)?
-- Técnica  : SUM OVER · PARTITION BY · ROWS UNBOUNDED PRECEDING
-- Observe  : como o acumulado de 2018 se compara ao de 2017 no mesmo mês
-- Dados    : Olist (Databricks · catálogo workspace)
-- =====================================================================

WITH mensal AS (
    SELECT d.ano, d.mes, SUM(f.valor_total) AS receita
    FROM workspace.olist_gold.fato_vendas f
    JOIN workspace.olist_gold.dim_data d ON d.sk_data = f.sk_data_compra
    WHERE f.status = 'delivered'
    GROUP BY d.ano, d.mes
)
SELECT
    ano,
    mes,
    ROUND(receita, 2) AS receita_mes,
    ROUND(SUM(receita) OVER (
        PARTITION BY ano
        ORDER BY mes
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2) AS receita_acumulada_ano
FROM mensal
ORDER BY ano, mes;

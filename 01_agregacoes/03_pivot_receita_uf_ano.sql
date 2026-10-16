-- =====================================================================
-- Pergunta : Qual a receita de cada estado em cada ano, lado a lado?
-- Técnica  : PIVOT
-- Observe  : o crescimento de 2017 para 2018 por estado
-- Dados    : Olist (Databricks · catálogo workspace)
-- =====================================================================

SELECT
    uf,
    ROUND(a2016, 0) AS receita_2016,
    ROUND(a2017, 0) AS receita_2017,
    ROUND(a2018, 0) AS receita_2018,
    ROUND(100 * (a2018 / a2017 - 1), 1) AS cresc_2018_vs_2017_pct
FROM (
    SELECT c.uf, d.ano, f.valor_total
    FROM workspace.olist_gold.fato_vendas f
    JOIN workspace.olist_gold.dim_cliente c USING (customer_id)
    JOIN workspace.olist_gold.dim_data    d ON d.sk_data = f.sk_data_compra
    WHERE f.status = 'delivered'
)
PIVOT (
    SUM(valor_total) FOR ano IN (2016 AS a2016, 2017 AS a2017, 2018 AS a2018)
)
ORDER BY receita_2018 DESC;

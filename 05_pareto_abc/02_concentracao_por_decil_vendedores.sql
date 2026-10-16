-- =====================================================================
-- Pergunta : Quanto da receita fica com os 10% maiores vendedores, os 10% seguintes e assim por diante?
-- Técnica  : NTILE · agregação por decil
-- Observe  : o 1º decil de vendedores concentra a maior parte da receita
-- Dados    : Olist (Databricks · catálogo workspace)
-- =====================================================================

WITH por_vendedor AS (
    SELECT seller_id, SUM(valor_total) AS receita
    FROM workspace.olist_gold.fato_vendas
    WHERE status = 'delivered'
    GROUP BY seller_id
),
decis AS (
    SELECT seller_id, receita, NTILE(10) OVER (ORDER BY receita DESC) AS decil
    FROM por_vendedor
)
SELECT
    decil,
    COUNT(*)                                                       AS vendedores,
    ROUND(SUM(receita), 2)                                         AS receita,
    ROUND(100 * SUM(receita) / SUM(SUM(receita)) OVER (), 1)       AS pct_receita,
    ROUND(100 * SUM(SUM(receita)) OVER (ORDER BY decil) / SUM(SUM(receita)) OVER (), 1) AS pct_acumulado
FROM decis
GROUP BY decil
ORDER BY decil;

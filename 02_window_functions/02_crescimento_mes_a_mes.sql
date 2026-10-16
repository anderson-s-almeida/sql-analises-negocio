-- =====================================================================
-- Pergunta : Quanto a receita cresceu ou caiu em relação ao mês anterior?
-- Técnica  : LAG
-- Observe  : os picos de novembro (Black Friday) e a queda em dezembro
-- Dados    : Olist (Databricks · catálogo workspace)
-- =====================================================================

WITH mensal AS (
    SELECT
        d.ano_mes,
        SUM(f.valor_total)          AS receita,
        COUNT(DISTINCT f.order_id)  AS pedidos
    FROM workspace.olist_gold.fato_vendas f
    JOIN workspace.olist_gold.dim_data d ON d.sk_data = f.sk_data_compra
    WHERE f.status = 'delivered'
    GROUP BY d.ano_mes
)
SELECT
    ano_mes,
    pedidos,
    ROUND(receita, 2)                                    AS receita,
    ROUND(LAG(receita) OVER (ORDER BY ano_mes), 2)       AS receita_mes_anterior,
    ROUND(100 * (receita / LAG(receita) OVER (ORDER BY ano_mes) - 1), 1) AS variacao_pct
FROM mensal
ORDER BY ano_mes;

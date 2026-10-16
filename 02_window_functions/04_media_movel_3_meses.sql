-- =====================================================================
-- Pergunta : Qual a média móvel de 3 meses dos pedidos?
-- Técnica  : AVG OVER · ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
-- Observe  : a média móvel suaviza picos pontuais e mostra a tendência
-- Dados    : Olist (Databricks · catálogo workspace)
-- =====================================================================

WITH mensal AS (
    SELECT d.ano_mes, COUNT(DISTINCT f.order_id) AS pedidos
    FROM workspace.olist_gold.fato_vendas f
    JOIN workspace.olist_gold.dim_data d ON d.sk_data = f.sk_data_compra
    GROUP BY d.ano_mes
)
SELECT
    ano_mes,
    pedidos,
    ROUND(AVG(pedidos) OVER (
        ORDER BY ano_mes
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 0) AS media_movel_3m
FROM mensal
ORDER BY ano_mes;

-- =====================================================================
-- Pergunta : Qual a receita, o número de pedidos e o ticket médio por estado?
-- Técnica  : GROUP BY · JOIN · COUNT DISTINCT
-- Observe  : a concentração da receita no Sudeste e a diferença de ticket entre estados
-- Dados    : Olist (Databricks · catálogo workspace)
-- =====================================================================

SELECT
    c.uf,
    COUNT(DISTINCT f.order_id)                                    AS pedidos,
    ROUND(SUM(f.valor_total), 2)                                  AS receita,
    ROUND(SUM(f.valor_total) / COUNT(DISTINCT f.order_id), 2)     AS ticket_medio,
    ROUND(100 * SUM(f.valor_total) / SUM(SUM(f.valor_total)) OVER (), 2) AS participacao_pct
FROM workspace.olist_gold.fato_vendas f
JOIN workspace.olist_gold.dim_cliente c USING (customer_id)
WHERE f.status = 'delivered'
GROUP BY c.uf
ORDER BY receita DESC;

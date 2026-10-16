-- =====================================================================
-- Pergunta : Os dados da camada gold estão íntegros?
-- Técnica  : LEFT ANTI JOIN · UNION ALL · regras de qualidade
-- Observe  : o ideal é 0 em todas; valores diferentes indicam dados a investigar
-- Dados    : Olist (Databricks · catálogo workspace)
-- =====================================================================

SELECT 'Fato sem cliente na dimensão' AS regra, COUNT(*) AS violacoes
FROM workspace.olist_gold.fato_vendas f
LEFT ANTI JOIN workspace.olist_gold.dim_cliente c USING (customer_id)

UNION ALL
SELECT 'Fato sem produto na dimensão', COUNT(*)
FROM workspace.olist_gold.fato_vendas f
LEFT ANTI JOIN workspace.olist_gold.dim_produto p USING (product_id)

UNION ALL
SELECT 'Fato sem data na dimensão', COUNT(*)
FROM workspace.olist_gold.fato_vendas f
LEFT ANTI JOIN workspace.olist_gold.dim_data d ON d.sk_data = f.sk_data_compra

UNION ALL
SELECT 'Preço ou frete negativo', COUNT(*)
FROM workspace.olist_gold.fato_vendas
WHERE preco < 0 OR frete < 0

UNION ALL
SELECT 'Entrega antes da compra', COUNT(*)
FROM workspace.olist_silver.pedidos
WHERE dt_entrega < dt_compra

UNION ALL
SELECT 'Item duplicado (order_id + item_seq)', COUNT(*)
FROM (
    SELECT order_id, item_seq
    FROM workspace.olist_gold.fato_vendas
    GROUP BY order_id, item_seq
    HAVING COUNT(*) > 1
);

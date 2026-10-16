-- =====================================================================
-- Pergunta : Quais pares de categorias aparecem juntos no mesmo pedido?
-- Técnica  : Self join · CTE · DISTINCT
-- Observe  : oportunidades de venda cruzada (cross-sell)
-- Dados    : Olist (Databricks · catálogo workspace)
-- =====================================================================

WITH itens AS (
    SELECT DISTINCT f.order_id, p.categoria
    FROM workspace.olist_gold.fato_vendas f
    JOIN workspace.olist_gold.dim_produto p USING (product_id)
    WHERE p.categoria <> 'sem_categoria'
)
SELECT
    a.categoria                    AS categoria_a,
    b.categoria                    AS categoria_b,
    COUNT(DISTINCT a.order_id)     AS pedidos_juntos
FROM itens a
JOIN itens b
  ON  a.order_id  = b.order_id
  AND a.categoria < b.categoria    -- evita par repetido (A,B)/(B,A) e a categoria consigo mesma
GROUP BY a.categoria, b.categoria
ORDER BY pedidos_juntos DESC
LIMIT 15;

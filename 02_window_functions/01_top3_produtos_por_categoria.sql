-- =====================================================================
-- Pergunta : Quais são os 3 produtos mais vendidos em cada categoria?
-- Técnica  : DENSE_RANK · PARTITION BY · QUALIFY
-- Observe  : categorias dominadas por um único produto
-- Dados    : Olist (Databricks · catálogo workspace)
-- =====================================================================

WITH vendas AS (
    SELECT
        p.categoria,
        f.product_id,
        COUNT(*)            AS itens_vendidos,
        SUM(f.valor_total)  AS receita
    FROM workspace.olist_gold.fato_vendas f
    JOIN workspace.olist_gold.dim_produto p USING (product_id)
    WHERE f.status = 'delivered'
    GROUP BY p.categoria, f.product_id
)
SELECT
    categoria,
    product_id,
    itens_vendidos,
    ROUND(receita, 2) AS receita,
    DENSE_RANK() OVER (PARTITION BY categoria ORDER BY itens_vendidos DESC) AS posicao
FROM vendas
QUALIFY posicao <= 3          -- QUALIFY filtra pelo resultado da window function
ORDER BY categoria, posicao;

-- Alternativa sem QUALIFY (SQL padrão):
-- SELECT * FROM (SELECT ..., DENSE_RANK() OVER (...) AS posicao FROM vendas) WHERE posicao <= 3

-- =====================================================================
-- Pergunta : Quais categorias formam 80% da receita (classe A)?
-- Técnica  : SUM OVER (ORDER BY) · acumulado · CASE WHEN
-- Observe  : poucas categorias concentram a maior parte da receita
-- Dados    : Olist (Databricks · catálogo workspace)
-- =====================================================================

WITH por_categoria AS (
    SELECT p.categoria, SUM(f.valor_total) AS receita
    FROM workspace.olist_gold.fato_vendas f
    JOIN workspace.olist_gold.dim_produto p USING (product_id)
    WHERE f.status = 'delivered'
    GROUP BY p.categoria
),
acumulado AS (
    SELECT
        categoria,
        receita,
        SUM(receita) OVER (ORDER BY receita DESC ROWS UNBOUNDED PRECEDING) / SUM(receita) OVER () AS pct_acumulado
    FROM por_categoria
)
SELECT
    ROW_NUMBER() OVER (ORDER BY receita DESC)   AS posicao,
    categoria,
    ROUND(receita, 2)                           AS receita,
    ROUND(100 * pct_acumulado, 1)               AS pct_acumulado,
    CASE
        WHEN pct_acumulado <= 0.80 THEN 'A'
        WHEN pct_acumulado <= 0.95 THEN 'B'
        ELSE 'C'
    END                                         AS classe
FROM acumulado
ORDER BY receita DESC;

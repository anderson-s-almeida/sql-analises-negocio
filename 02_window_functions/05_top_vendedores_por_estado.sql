-- =====================================================================
-- Pergunta : Quem são os 3 maiores vendedores de cada estado e quanto representam do estado?
-- Técnica  : ROW_NUMBER · SUM OVER (PARTITION BY)
-- Observe  : estados onde um único vendedor concentra a maior parte da receita
-- Dados    : Olist (Databricks · catálogo workspace)
-- =====================================================================

WITH vendas AS (
    SELECT v.uf, f.seller_id, SUM(f.valor_total) AS receita
    FROM workspace.olist_gold.fato_vendas f
    JOIN workspace.olist_gold.dim_vendedor v USING (seller_id)
    WHERE f.status = 'delivered'
    GROUP BY v.uf, f.seller_id
)
SELECT
    uf,
    seller_id,
    ROUND(receita, 2)                                                    AS receita,
    ROUND(100 * receita / SUM(receita) OVER (PARTITION BY uf), 1)        AS pct_do_estado,
    ROW_NUMBER() OVER (PARTITION BY uf ORDER BY receita DESC)            AS posicao
FROM vendas
QUALIFY posicao <= 3
ORDER BY uf, posicao;

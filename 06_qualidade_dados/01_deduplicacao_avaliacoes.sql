-- =====================================================================
-- Pergunta : Existem avaliações duplicadas por pedido? Como manter só a mais recente?
-- Técnica  : ROW_NUMBER para deduplicação · comparação antes/depois
-- Observe  : a mesma lógica usada na camada silver do pipeline
-- Dados    : Olist (Databricks · catálogo workspace)
-- =====================================================================

-- 1) Diagnóstico na bronze (dados brutos): pedidos com mais de uma avaliação
SELECT
    COUNT(*)                                             AS total_avaliacoes,
    COUNT(DISTINCT order_id)                             AS pedidos_distintos,
    COUNT(*) - COUNT(DISTINCT order_id)                  AS avaliacoes_excedentes
FROM workspace.olist_bronze.order_reviews;

-- 2) Deduplicação: mantém a avaliação respondida por último em cada pedido
WITH ordenadas AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY TO_TIMESTAMP(review_answer_timestamp) DESC
        ) AS rn
    FROM workspace.olist_bronze.order_reviews
)
SELECT order_id, review_id, review_score, review_answer_timestamp
FROM ordenadas
WHERE rn = 1;

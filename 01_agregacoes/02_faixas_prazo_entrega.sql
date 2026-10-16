-- =====================================================================
-- Pergunta : Como os pedidos entregues se distribuem por faixa de prazo de entrega?
-- Técnica  : CASE WHEN · agregação · % do total com janela
-- Observe  : quantos pedidos levam mais de 30 dias
-- Dados    : Olist (Databricks · catálogo workspace)
-- =====================================================================

WITH entregues AS (
    SELECT order_id, dias_entrega
    FROM workspace.olist_silver.pedidos
    WHERE status = 'delivered'
      AND dias_entrega IS NOT NULL
)
SELECT
    CASE
        WHEN dias_entrega <= 7  THEN '1. até 7 dias'
        WHEN dias_entrega <= 15 THEN '2. 8 a 15 dias'
        WHEN dias_entrega <= 30 THEN '3. 16 a 30 dias'
        ELSE                         '4. mais de 30 dias'
    END                                                   AS faixa,
    COUNT(*)                                              AS pedidos,
    ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)      AS pct
FROM entregues
GROUP BY 1
ORDER BY 1;

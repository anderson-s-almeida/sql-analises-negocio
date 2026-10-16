-- =====================================================================
-- Pergunta : Quantos clientes compram de novo e quanto tempo levam para voltar?
-- Técnica  : CTEs encadeadas · LEAD · PERCENTILE_APPROX
-- Observe  : a taxa de recompra baixíssima típica de marketplace
-- Dados    : Olist (Databricks · catálogo workspace)
-- =====================================================================

WITH compras AS (
    -- uma linha por pedido do cliente (customer_unique_id identifica a pessoa)
    SELECT
        c.customer_unique_id,
        p.order_id,
        p.dt_compra
    FROM workspace.olist_silver.pedidos  p
    JOIN workspace.olist_silver.clientes c USING (customer_id)
    WHERE p.status <> 'canceled'
),
sequencia AS (
    SELECT
        customer_unique_id,
        dt_compra,
        LEAD(dt_compra) OVER (PARTITION BY customer_unique_id ORDER BY dt_compra) AS proxima_compra
    FROM compras
),
retorno AS (
    SELECT customer_unique_id, DATEDIFF(proxima_compra, dt_compra) AS dias_ate_voltar
    FROM sequencia
    WHERE proxima_compra IS NOT NULL
),
por_cliente AS (
    SELECT customer_unique_id, COUNT(*) AS pedidos
    FROM compras
    GROUP BY customer_unique_id
)
SELECT
    (SELECT COUNT(*) FROM por_cliente)                                         AS clientes,
    (SELECT COUNT(*) FROM por_cliente WHERE pedidos > 1)                       AS clientes_recorrentes,
    ROUND(100 * (SELECT COUNT(*) FROM por_cliente WHERE pedidos > 1)
              / (SELECT COUNT(*) FROM por_cliente), 2)                         AS taxa_recompra_pct,
    (SELECT PERCENTILE_APPROX(dias_ate_voltar, 0.5) FROM retorno)              AS mediana_dias_ate_voltar,
    (SELECT ROUND(AVG(dias_ate_voltar), 1) FROM retorno)                       AS media_dias_ate_voltar;

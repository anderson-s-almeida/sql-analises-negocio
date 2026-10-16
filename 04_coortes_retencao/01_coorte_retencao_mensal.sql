-- =====================================================================
-- Pergunta : Dos clientes que fizeram a 1ª compra em cada mês, quantos voltaram nos meses seguintes?
-- Técnica  : Análise de coorte · CTEs · MONTHS_BETWEEN · agregação condicional
-- Observe  : a retenção cai para perto de zero já no 1º mês
-- Dados    : Olist (Databricks · catálogo workspace)
-- =====================================================================

WITH compras AS (
    SELECT
        c.customer_unique_id,
        DATE_TRUNC('MONTH', p.dt_compra) AS mes
    FROM workspace.olist_silver.pedidos  p
    JOIN workspace.olist_silver.clientes c USING (customer_id)
    WHERE p.status <> 'canceled'
),
primeira AS (
    SELECT customer_unique_id, MIN(mes) AS coorte
    FROM compras
    GROUP BY customer_unique_id
),
atividade AS (
    SELECT DISTINCT
        c.customer_unique_id,
        pr.coorte,
        CAST(MONTHS_BETWEEN(c.mes, pr.coorte) AS INT) AS mes_relativo
    FROM compras  c
    JOIN primeira pr USING (customer_unique_id)
),
tabela AS (
    SELECT
        coorte,
        COUNT(DISTINCT CASE WHEN mes_relativo = 0 THEN customer_unique_id END) AS tamanho,
        COUNT(DISTINCT CASE WHEN mes_relativo = 1 THEN customer_unique_id END) AS m1,
        COUNT(DISTINCT CASE WHEN mes_relativo = 2 THEN customer_unique_id END) AS m2,
        COUNT(DISTINCT CASE WHEN mes_relativo = 3 THEN customer_unique_id END) AS m3,
        COUNT(DISTINCT CASE WHEN mes_relativo = 6 THEN customer_unique_id END) AS m6
    FROM atividade
    GROUP BY coorte
)
SELECT
    DATE_FORMAT(coorte, 'yyyy-MM')     AS coorte,
    tamanho                            AS clientes_novos,
    ROUND(100 * m1 / tamanho, 2)       AS retencao_m1_pct,
    ROUND(100 * m2 / tamanho, 2)       AS retencao_m2_pct,
    ROUND(100 * m3 / tamanho, 2)       AS retencao_m3_pct,
    ROUND(100 * m6 / tamanho, 2)       AS retencao_m6_pct
FROM tabela
WHERE tamanho >= 100                   -- ignora meses com poucos clientes (início/fim do dataset)
ORDER BY coorte;

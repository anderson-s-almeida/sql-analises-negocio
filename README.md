# 🧮 SQL para Análise de Negócio

Coletânea de **perguntas de negócio respondidas em SQL**, organizadas por técnica, usando os dados reais de e-commerce da **Olist** já modelados no projeto [olist-medallion-pipeline](https://github.com/anderson-s-almeida/olist-medallion-pipeline) (camadas bronze, silver e gold no Databricks).

Cada arquivo traz no topo a **pergunta**, a **técnica** usada e **o que observar** no resultado.

---

## 📚 Índice

| # | Pergunta de negócio | Técnica | Arquivo |
|---|---|---|---|
| 1 | Receita, pedidos e ticket médio por estado | `GROUP BY` · `JOIN` · % do total | [01_receita_ticket_por_uf](01_agregacoes/01_receita_ticket_por_uf.sql) |
| 2 | Distribuição dos pedidos por faixa de prazo de entrega | `CASE WHEN` · janela sobre agregação | [02_faixas_prazo_entrega](01_agregacoes/02_faixas_prazo_entrega.sql) |
| 3 | Receita por estado × ano, lado a lado | `PIVOT` | [03_pivot_receita_uf_ano](01_agregacoes/03_pivot_receita_uf_ano.sql) |
| 4 | Top 3 produtos mais vendidos em cada categoria | `DENSE_RANK` · `PARTITION BY` · `QUALIFY` | [01_top3_produtos_por_categoria](02_window_functions/01_top3_produtos_por_categoria.sql) |
| 5 | Crescimento da receita mês a mês | `LAG` | [02_crescimento_mes_a_mes](02_window_functions/02_crescimento_mes_a_mes.sql) |
| 6 | Receita acumulada no ano (YTD) | `SUM OVER` · `ROWS UNBOUNDED PRECEDING` | [03_receita_acumulada_no_ano](02_window_functions/03_receita_acumulada_no_ano.sql) |
| 7 | Média móvel de 3 meses dos pedidos | `AVG OVER` · moldura de janela | [04_media_movel_3_meses](02_window_functions/04_media_movel_3_meses.sql) |
| 8 | Top 3 vendedores por estado e sua participação | `ROW_NUMBER` · `SUM OVER (PARTITION BY)` | [05_top_vendedores_por_estado](02_window_functions/05_top_vendedores_por_estado.sql) |
| 9 | Taxa de recompra e tempo até o cliente voltar | CTEs encadeadas · `LEAD` · `PERCENTILE_APPROX` | [01_recompra_e_tempo_de_retorno](03_ctes/01_recompra_e_tempo_de_retorno.sql) |
| 10 | Categorias compradas juntas no mesmo pedido | Self join | [02_categorias_compradas_juntas](03_ctes/02_categorias_compradas_juntas.sql) |
| 11 | Retenção mensal por coorte de clientes | Análise de coorte · `MONTHS_BETWEEN` · agregação condicional | [01_coorte_retencao_mensal](04_coortes_retencao/01_coorte_retencao_mensal.sql) |
| 12 | Curva ABC de categorias (classes A, B e C) | Acumulado com `SUM OVER (ORDER BY)` | [01_curva_abc_categorias](05_pareto_abc/01_curva_abc_categorias.sql) |
| 13 | Concentração de receita por decil de vendedores | `NTILE` | [02_concentracao_por_decil_vendedores](05_pareto_abc/02_concentracao_por_decil_vendedores.sql) |
| 14 | Deduplicação de avaliações por pedido | `ROW_NUMBER` para deduplicar | [01_deduplicacao_avaliacoes](06_qualidade_dados/01_deduplicacao_avaliacoes.sql) |
| 15 | Checagens de integridade da camada gold | `LEFT ANTI JOIN` · `UNION ALL` | [02_checagens_integridade](06_qualidade_dados/02_checagens_integridade.sql) |

---

## 🗂️ Estrutura

```
sql-analises-negocio/
├── 01_agregacoes/          # GROUP BY, CASE WHEN, PIVOT
├── 02_window_functions/    # RANK, LAG, SUM/AVG OVER, QUALIFY
├── 03_ctes/                # CTEs encadeadas, self join
├── 04_coortes_retencao/    # análise de coorte
├── 05_pareto_abc/          # curva ABC, decis
└── 06_qualidade_dados/     # deduplicação e integridade
```

---

## 🗃️ Tabelas utilizadas

| Camada | Tabelas |
|---|---|
| `workspace.olist_gold` | `fato_vendas`, `dim_cliente`, `dim_produto`, `dim_vendedor`, `dim_data` |
| `workspace.olist_silver` | `pedidos`, `clientes` |
| `workspace.olist_bronze` | `order_reviews` (dados brutos, para o exercício de deduplicação) |

---

## ▶️ Como executar

1. Rode o pipeline do projeto [olist-medallion-pipeline](https://github.com/anderson-s-almeida/olist-medallion-pipeline) para criar as camadas.
2. Abra o **SQL Editor** do Databricks e conecte num SQL Warehouse.
3. Copie qualquer arquivo `.sql` e execute.

> Dialeto: **Databricks SQL (Spark SQL)**. Recursos como `QUALIFY`, `PIVOT` e `LEFT ANTI JOIN` são suportados nativamente; os arquivos indicam alternativas em SQL padrão quando relevante.

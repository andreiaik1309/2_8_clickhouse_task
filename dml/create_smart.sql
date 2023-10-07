CREATE MATERIALIZED VIEW IF NOT EXISTS sales_analyze
ENGINE = MergeTree()
ORDER BY (category_id, order_date)
POPULATE
AS
WITH cumulative_data AS (
    SELECT 
        category_id,
        order_date,
        revenue,
        sum(revenue) OVER w AS cum_sum_revenue,
        count(*) OVER w AS cum_count_orders,
        round(sum(revenue) OVER w / count(*) OVER w, 2) AS avg_cheque
    FROM sales
    WINDOW w AS (PARTITION BY category_id ORDER BY order_date)
),
table_max_avg as (
    SELECT
        category_id,
        order_date,
        revenue,
        cum_sum_revenue,
        cum_count_orders,
        avg_cheque,
        max(avg_cheque) OVER (PARTITION BY category_id order by order_date) AS max_avg_cheque
    FROM cumulative_data),
utils_table as (
    select order_date, category_id, avg_cheque from (
        select order_date, category_id, avg_cheque, row_number() over (partition by category_id, avg_cheque order by order_date)
        as n_row from cumulative_data) Z 
    where n_row = 1)
select tma.category_id,
       tma.order_date,
       tma.revenue,
       tma.cum_sum_revenue,
       tma.cum_count_orders,
       tma.avg_cheque,
       tma.max_avg_cheque,
       ut.order_date as date_max_avg_cheque
from table_max_avg as tma
left join utils_table as ut on tma.category_id = ut.category_id AND
    tma.max_avg_cheque = ut.avg_cheque


;

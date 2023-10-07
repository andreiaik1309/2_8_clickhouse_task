CREATE TABLE IF NOT EXISTS sales (
    category_id   Int64,
    order_date    Date,
    revenue       Float32
) ENGINE = MergeTree()
ORDER BY (category_id, order_date)

;

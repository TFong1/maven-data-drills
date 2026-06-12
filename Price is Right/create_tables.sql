CREATE TABLE IF NOT EXISTS stg.pizza_products (
    pizza_id SMALLINT PRIMARY KEY,
    name VARCHAR(50),
    current_price NUMERIC(15,2)
)
;

CREATE TABLE IF NOT EXISTS stg.pizza_price_history (
    pizza_id SMALLINT NOT NULL,
    effective_date DATE NOT NULL,
    price NUMERIC(15,2),

    PRIMARY KEY (pizza_id, effective_date),
    FOREIGN KEY (pizza_id) REFERENCES stg.pizza_products (pizza_id)
)
;

CREATE TABLE IF NOT EXISTS stg.pizza_transactions (
    order_detail_id SMALLINT PRIMARY KEY,
    order_id SMALLINT NOT NULL,
    order_date DATE,
    pizza_id SMALLINT,
    quantity INTEGER,

    FOREIGN KEY (pizza_id) REFERENCES stg.pizza_products (pizza_id)
)
;

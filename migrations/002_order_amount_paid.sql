-- Только схема: без UPDATE и без SET NOT NULL, чтобы не вешать таблицу.
-- В PostgreSQL 11+ ADD COLUMN без DEFAULT — изменение каталога.
-- Старые строки остаются NULL; при чтении NULL = amount_kop (скидки ещё не было).
ALTER TABLE orders ADD COLUMN IF NOT EXISTS amount_paid_kop BIGINT;

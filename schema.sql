-- ============================================================
--  Foodbank Stock & Distribution Tracker  —  schema
--  SQLite. Run with:  sqlite3 foodbank.db < schema.sql
--
--  Models a small community foodbank: donations come in, are
--  held as stock, and are given out to families. Built to
--  practise relational modelling, keys, constraints and views.
-- ============================================================

PRAGMA foreign_keys = ON;   -- enforce foreign key relationships

-- Categories of item the foodbank handles (e.g. Tinned, Dry, Fresh)
CREATE TABLE IF NOT EXISTS category (
    id    INTEGER PRIMARY KEY AUTOINCREMENT,
    name  TEXT NOT NULL UNIQUE
);

-- Individual products, each belonging to one category
CREATE TABLE IF NOT EXISTS item (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    name         TEXT NOT NULL,
    category_id  INTEGER NOT NULL,
    unit         TEXT NOT NULL DEFAULT 'unit',   -- e.g. tin, kg, pack
    FOREIGN KEY (category_id) REFERENCES category(id)
);

-- People or organisations who donate
CREATE TABLE IF NOT EXISTS donor (
    id      INTEGER PRIMARY KEY AUTOINCREMENT,
    name    TEXT NOT NULL,
    type    TEXT NOT NULL CHECK (type IN ('individual','business','school','other'))
);

-- A donation event: which donor, which item, how many, when
CREATE TABLE IF NOT EXISTS donation (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    donor_id      INTEGER NOT NULL,
    item_id       INTEGER NOT NULL,
    quantity      INTEGER NOT NULL CHECK (quantity > 0),
    donated_on    TEXT NOT NULL DEFAULT (date('now')),
    FOREIGN KEY (donor_id) REFERENCES donor(id),
    FOREIGN KEY (item_id)  REFERENCES item(id)
);

-- A distribution event: item given out to a family (anonymous reference)
CREATE TABLE IF NOT EXISTS distribution (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    family_ref     TEXT NOT NULL,                 -- anonymised code, not a name
    item_id        INTEGER NOT NULL,
    quantity       INTEGER NOT NULL CHECK (quantity > 0),
    given_on       TEXT NOT NULL DEFAULT (date('now')),
    FOREIGN KEY (item_id) REFERENCES item(id)
);

-- Indexes to speed up the lookups the reports use most
CREATE INDEX IF NOT EXISTS idx_donation_item ON donation(item_id);
CREATE INDEX IF NOT EXISTS idx_distribution_item ON distribution(item_id);
CREATE INDEX IF NOT EXISTS idx_donation_date ON donation(donated_on);

-- A view giving current stock per item = total donated minus total given out.
-- Views let a complex query be reused by name, like a saved question.
CREATE VIEW IF NOT EXISTS current_stock AS
SELECT
    i.id                                   AS item_id,
    i.name                                 AS item_name,
    c.name                                 AS category,
    COALESCE(d.total_in,  0)               AS total_donated,
    COALESCE(x.total_out, 0)               AS total_given,
    COALESCE(d.total_in,  0) - COALESCE(x.total_out, 0) AS in_stock
FROM item i
JOIN category c ON c.id = i.category_id
LEFT JOIN (SELECT item_id, SUM(quantity) total_in  FROM donation     GROUP BY item_id) d ON d.item_id = i.id
LEFT JOIN (SELECT item_id, SUM(quantity) total_out FROM distribution GROUP BY item_id) x ON x.item_id = i.id;

-- ============================================================
--  Reporting queries — the questions this database answers.
--  Run against a populated db:  sqlite3 foodbank.db < queries.sql
--  Each query builds on core SQL: JOIN, GROUP BY, aggregates,
--  filtering, ordering, and a subquery.
-- ============================================================

-- 1. Current stock of every item (uses the current_stock view)
SELECT item_name, category, in_stock
FROM current_stock
ORDER BY in_stock DESC;

-- 2. Items that are low or out of stock (10 or fewer) — a data-quality / ops alert
SELECT item_name, in_stock
FROM current_stock
WHERE in_stock <= 10
ORDER BY in_stock ASC;

-- 3. Total quantity donated per category (JOIN + GROUP BY + SUM)
SELECT c.name AS category, SUM(d.quantity) AS total_donated
FROM donation d
JOIN item i     ON i.id = d.item_id
JOIN category c ON c.id = i.category_id
GROUP BY c.name
ORDER BY total_donated DESC;

-- 4. Most generous donors, ranked by total items given
SELECT don.name AS donor, don.type, SUM(d.quantity) AS items_donated
FROM donation d
JOIN donor don ON don.id = d.donor_id
GROUP BY don.id
ORDER BY items_donated DESC;

-- 5. How many distinct families each item has helped (COUNT DISTINCT)
SELECT i.name AS item, COUNT(DISTINCT x.family_ref) AS families_helped
FROM distribution x
JOIN item i ON i.id = x.item_id
GROUP BY i.id
ORDER BY families_helped DESC;

-- 6. Donations received per week (date grouping)
SELECT strftime('%Y-W%W', donated_on) AS week, SUM(quantity) AS items_in
FROM donation
GROUP BY week
ORDER BY week;

-- 7. Items donated but never given out yet (subquery / NOT IN)
SELECT name
FROM item
WHERE id NOT IN (SELECT DISTINCT item_id FROM distribution);

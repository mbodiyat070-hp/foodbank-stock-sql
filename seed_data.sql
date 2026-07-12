-- ============================================================
--  Sample data so the queries return something meaningful.
--  Run after schema.sql:  sqlite3 foodbank.db < seed_data.sql
-- ============================================================

INSERT INTO category (name) VALUES
    ('Tinned'), ('Dry Goods'), ('Fresh'), ('Toiletries');

INSERT INTO item (name, category_id, unit) VALUES
    ('Baked Beans',      1, 'tin'),
    ('Chopped Tomatoes', 1, 'tin'),
    ('Rice',             2, 'kg'),
    ('Pasta',            2, 'pack'),
    ('Cereal',           2, 'box'),
    ('Apples',           3, 'kg'),
    ('Soap',             4, 'bar'),
    ('Toothpaste',       4, 'tube');

INSERT INTO donor (name, type) VALUES
    ('Local Supermarket', 'business'),
    ('Community Member A', 'individual'),
    ('Community Member B', 'individual'),
    ('Primary School Collection', 'school');

-- Donations coming in
INSERT INTO donation (donor_id, item_id, quantity, donated_on) VALUES
    (1, 1, 120, '2026-06-01'),
    (1, 2,  80, '2026-06-01'),
    (1, 3,  40, '2026-06-03'),
    (2, 4,  25, '2026-06-05'),
    (4, 5,  30, '2026-06-07'),
    (3, 7,  50, '2026-06-08'),
    (1, 8,  20, '2026-06-10'),
    (2, 6,  15, '2026-06-11'),
    (1, 1,  60, '2026-06-20');

-- Distributions going out (families anonymised as F-001 etc.)
INSERT INTO distribution (family_ref, item_id, quantity, given_on) VALUES
    ('F-001', 1, 10, '2026-06-12'),
    ('F-001', 3,  5, '2026-06-12'),
    ('F-002', 1, 12, '2026-06-13'),
    ('F-002', 4,  4, '2026-06-13'),
    ('F-003', 7, 10, '2026-06-15'),
    ('F-004', 1, 20, '2026-06-21'),
    ('F-004', 5,  6, '2026-06-21'),
    ('F-005', 6,  8, '2026-06-22');

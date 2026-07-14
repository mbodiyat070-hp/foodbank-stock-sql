# Foodbank Stock & Distribution Tracker (SQL)

A small SQLite database that tracks a community foodbank: donations come in,
are held as stock, and are distributed to families. I built it to practise
relational data modelling and SQL — the kind of data-handling a data engineer
does day to day. The idea comes from my own experience volunteering with
foodbank and charity stock.

## What it does

- Records **donors**, **items** (grouped into **categories**), **donations** in
  and **distributions** out.
- Calculates **current stock** for every item as *total donated − total given out*.
- Answers reporting questions: low-stock alerts, donations per category, most
  generous donors, how many families each item helped, and weekly intake.

## Files

| File | What's in it |
|------|--------------|
| `schema.sql` | Table definitions — primary keys, foreign keys, `CHECK` constraints, indexes, and a `current_stock` view |
| `seed_data.sql` | Sample data so the queries return something meaningful |
| `queries.sql` | Seven reporting queries (JOINs, `GROUP BY`, aggregates, a subquery, date grouping) |
| `report.py` | Python script that builds the database and prints reports using **parameterised queries** |

## Run it

**With Python (no setup needed — uses the standard library `sqlite3`):**

```bash
python report.py
python report.py --low-stock 15
```

**Or with the SQLite command-line tool:**

```bash
sqlite3 foodbank.db < schema.sql
sqlite3 foodbank.db < seed_data.sql
sqlite3 foodbank.db < queries.sql
```

**Sample output:**

```
Current stock
-------------
  item_name: Baked Beans | category: Tinned | in_stock: 138
  item_name: Chopped Tomatoes | category: Tinned | in_stock: 80
  item_name: Soap | category: Toiletries | in_stock: 40
  ...

Low stock (<= 10)
-----------------
  item_name: Apples | in_stock: 7

Donated per category
--------------------
  category: Tinned | total: 260
  category: Dry Goods | total: 95
  ...
```

## Tests

```bash
python -m pytest
```

Four tests build a fresh in-memory database from the real schema and seed
data, then check the reports: stock ordering, no negative stock, the
low-stock threshold, and that the grouped donation totals reconcile with
the raw donation table.

## SQL concepts demonstrated

- Relational modelling with **foreign keys** and referential integrity (`PRAGMA foreign_keys = ON`)
- `CHECK` constraints and `UNIQUE` to protect **data quality** at the point of entry
- `JOIN` across multiple tables
- Aggregation with `GROUP BY`, `SUM`, `COUNT(DISTINCT ...)`
- A **view** to save and reuse a complex query
- **Indexes** on the columns the reports filter and join on
- A **subquery** (`NOT IN`) to find items never distributed
- **Parameterised queries** in Python (`?` placeholders) to prevent SQL injection
- **Input validation** — the `--low-stock` flag rejects negative or
  non-numeric thresholds with a clear error instead of running a
  meaningless query

## What I learned

- Validating data **in the database itself** (`CHECK`, `UNIQUE`, foreign
  keys) is the strongest layer — bad rows are rejected no matter which
  program tries to insert them
- A view earns its place when several reports need the same calculation:
  `current_stock` is written once and every query reuses it
- Parameterised queries aren't just an injection defence, they also handle
  quoting and types for you — string-gluing SQL is never worth it
- Tests that reconcile a grouped total against the raw table catch the
  errors that eyeballing sample output misses

## What I'd add next

- A distribution cap per family per week (a data-validation rule)
- Expiry-date tracking on perishable stock
- Export of the weekly report to CSV

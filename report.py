"""
report.py — build the foodbank database from the .sql files and print reports.

Ties Python to SQL: it runs the schema and seed scripts, then queries the
database using parameterised queries (values passed as parameters, never
glued into the SQL string) to keep data handling safe.

Usage:
    python report.py
    python report.py --low-stock 15
"""

import argparse
import sqlite3
from pathlib import Path

DB_PATH = Path("foodbank.db")
HERE = Path(__file__).parent


def build_database(conn: sqlite3.Connection) -> None:
    """Create the tables and load the sample data from the .sql files."""
    for script in ("schema.sql", "seed_data.sql"):
        sql = (HERE / script).read_text(encoding="utf-8")
        conn.executescript(sql)
    conn.commit()


def current_stock(conn: sqlite3.Connection) -> list[sqlite3.Row]:
    """Return every item and how many are in stock, highest first."""
    return conn.execute(
        "SELECT item_name, category, in_stock "
        "FROM current_stock ORDER BY in_stock DESC"
    ).fetchall()


def low_stock(conn: sqlite3.Connection, threshold: int) -> list[sqlite3.Row]:
    """Return items at or below a stock threshold.

    `threshold` is passed as a parameter (the ? placeholder) rather than
    formatted into the query string — this prevents SQL injection.
    """
    return conn.execute(
        "SELECT item_name, in_stock FROM current_stock "
        "WHERE in_stock <= ? ORDER BY in_stock ASC",
        (threshold,),
    ).fetchall()


def donated_per_category(conn: sqlite3.Connection) -> list[sqlite3.Row]:
    """Total quantity donated, grouped by category."""
    return conn.execute(
        "SELECT c.name AS category, SUM(d.quantity) AS total "
        "FROM donation d "
        "JOIN item i     ON i.id = d.item_id "
        "JOIN category c ON c.id = i.category_id "
        "GROUP BY c.name ORDER BY total DESC"
    ).fetchall()


def print_table(title: str, rows: list[sqlite3.Row]) -> None:
    print(f"\n{title}")
    print("-" * len(title))
    if not rows:
        print("(no rows)")
        return
    for row in rows:
        print("  " + " | ".join(f"{k}: {row[k]}" for k in row.keys()))


def main() -> None:
    parser = argparse.ArgumentParser(description="Foodbank stock reports")
    parser.add_argument("--low-stock", type=int, default=10,
                        help="stock threshold for the low-stock alert")
    args = parser.parse_args()

    # A fresh database each run keeps the demo reproducible.
    if DB_PATH.exists():
        DB_PATH.unlink()

    with sqlite3.connect(DB_PATH) as conn:
        conn.row_factory = sqlite3.Row
        build_database(conn)

        print_table("Current stock", current_stock(conn))
        print_table(f"Low stock (<= {args.low_stock})", low_stock(conn, args.low_stock))
        print_table("Donated per category", donated_per_category(conn))


if __name__ == "__main__":
    main()

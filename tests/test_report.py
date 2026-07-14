"""
Tests for the foodbank reports.

Each test builds a fresh in-memory database from schema.sql + seed_data.sql,
so the tests exercise the real schema, views and seed data end to end.

Run from the project root:  python -m pytest
"""

import sqlite3

import pytest

import report


@pytest.fixture
def conn():
    connection = sqlite3.connect(":memory:")
    connection.row_factory = sqlite3.Row
    report.build_database(connection)
    yield connection
    connection.close()


def test_current_stock_is_sorted_highest_first(conn):
    rows = report.current_stock(conn)
    assert len(rows) > 0
    stock_levels = [row["in_stock"] for row in rows]
    assert stock_levels == sorted(stock_levels, reverse=True)


def test_stock_is_never_negative(conn):
    # Distributions should never exceed what was donated for any item.
    for row in report.current_stock(conn):
        assert row["in_stock"] >= 0, f"{row['item_name']} has negative stock"


def test_low_stock_respects_threshold(conn):
    threshold = 10
    rows = report.low_stock(conn, threshold)
    assert all(row["in_stock"] <= threshold for row in rows)
    # Raising the threshold can only return the same items or more.
    assert len(report.low_stock(conn, 1000)) >= len(rows)


def test_donated_per_category_matches_raw_totals(conn):
    # The grouped report must add up to the same total as the donation table.
    grouped_total = sum(row["total"] for row in report.donated_per_category(conn))
    raw_total = conn.execute("SELECT SUM(quantity) AS t FROM donation").fetchone()["t"]
    assert grouped_total == raw_total

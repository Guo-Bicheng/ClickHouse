#!/usr/bin/env bash

CURDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../shell_config.sh
. "$CURDIR"/../shell_config.sh

export CLICKHOUSE_TEST_UNIQUE_NAME="${CLICKHOUSE_TEST_NAME}_${CLICKHOUSE_DATABASE}"

$CLICKHOUSE_CLIENT -q "DROP VIEW IF EXISTS test_02428_pv1"
$CLICKHOUSE_CLIENT -q "DROP VIEW IF EXISTS test_02428_pv2"
$CLICKHOUSE_CLIENT -q "DROP VIEW IF EXISTS test_02428_pv3"
$CLICKHOUSE_CLIENT -q "DROP VIEW IF EXISTS test_02428_pv4"
$CLICKHOUSE_CLIENT -q "DROP VIEW IF EXISTS test_02428_pv5"
$CLICKHOUSE_CLIENT -q "DROP VIEW IF EXISTS test_02428_pv6"
$CLICKHOUSE_CLIENT -q "DROP VIEW IF EXISTS test_02428_pv7"
$CLICKHOUSE_CLIENT -q "DROP VIEW IF EXISTS test_02428_v1"
$CLICKHOUSE_CLIENT -q "DROP TABLE IF EXISTS test_02428_Catalog"
$CLICKHOUSE_CLIENT -q "DROP TABLE IF EXISTS ${CLICKHOUSE_TEST_UNIQUE_NAME}.pv1"
$CLICKHOUSE_CLIENT -q "DROP TABLE IF EXISTS ${CLICKHOUSE_TEST_UNIQUE_NAME}.Catalog"
$CLICKHOUSE_CLIENT -q "DROP DATABASE IF EXISTS ${CLICKHOUSE_TEST_UNIQUE_NAME}"

$CLICKHOUSE_CLIENT -q "CREATE TABLE test_02428_Catalog (Name String, Price UInt64, Quantity UInt64) ENGINE = Memory"

$CLICKHOUSE_CLIENT -q "INSERT INTO test_02428_Catalog VALUES ('Pen', 10, 3)"
$CLICKHOUSE_CLIENT -q "INSERT INTO test_02428_Catalog VALUES ('Book', 50, 2)"
$CLICKHOUSE_CLIENT -q "INSERT INTO test_02428_Catalog VALUES ('Paper', 20, 1)"

$CLICKHOUSE_CLIENT -q "CREATE VIEW test_02428_pv1 AS SELECT * FROM test_02428_Catalog WHERE Price={price:UInt64}"
$CLICKHOUSE_CLIENT -q "SELECT Price FROM test_02428_pv1(price=20)"
$CLICKHOUSE_CLIENT -q "SELECT Price FROM \`test_02428_pv1\`(price=20)"

$CLICKHOUSE_CLIENT -q "SELECT Price FROM test_02428_pv1" 2>&1 |  grep -Fq "UNKNOWN_QUERY_PARAMETER" && echo 'ERROR' || echo 'OK'
$CLICKHOUSE_CLIENT --param_p 10 -q "SELECT Price FROM test_02428_pv1(price={p:UInt64})"

$CLICKHOUSE_CLIENT --param_l 1 -q "SELECT Price FROM test_02428_pv1(price=50) LIMIT ({l:UInt64})"
$CLICKHOUSE_CLIENT -q "DETACH TABLE test_02428_pv1"
$CLICKHOUSE_CLIENT -q "ATTACH TABLE test_02428_pv1"

$CLICKHOUSE_CLIENT -q "EXPLAIN SYNTAX SELECT * from test_02428_pv1(price=10)"

$CLICKHOUSE_CLIENT -q "INSERT INTO test_02428_pv1 VALUES ('Bag', 50, 2)" 2>&1 |  grep -Fq "NOT_IMPLEMENTED" && echo 'ERROR' || echo 'OK'

$CLICKHOUSE_CLIENT -q "SELECT Price FROM pv123(price=20)" 2>&1 |  grep -Fq "UNKNOWN_FUNCTION" && echo 'ERROR' || echo 'OK'

$CLICKHOUSE_CLIENT -q "CREATE VIEW test_02428_v1 AS SELECT * FROM test_02428_Catalog WHERE Price=10"

$CLICKHOUSE_CLIENT -q "SELECT Price FROM test_02428_v1(price=10)" 2>&1 |  grep -Fq "UNKNOWN_FUNCTION" && echo 'ERROR' || echo 'OK'

$CLICKHOUSE_CLIENT -q "CREATE VIEW test_02428_pv2 AS SELECT * FROM test_02428_Catalog WHERE Price={price:UInt64} AND Quantity={quantity:UInt64}"

$CLICKHOUSE_CLIENT -q "SELECT Price FROM test_02428_pv2(price=50,quantity=2)"
$CLICKHOUSE_CLIENT -q "SELECT Price FROM test_02428_pv2(price=50)"  2>&1 |  grep -Fq "UNKNOWN_QUERY_PARAMETER" && echo 'ERROR' || echo 'OK'

$CLICKHOUSE_CLIENT -q "CREATE VIEW test_02428_pv3 AS SELECT * FROM test_02428_Catalog WHERE Price={price:UInt64} AND Quantity=3"
$CLICKHOUSE_CLIENT -q "SELECT Price FROM test_02428_pv3(price=10)"

$CLICKHOUSE_CLIENT -q "CREATE VIEW test_02428_pv4 AS SELECT * FROM test_02428_Catalog WHERE Price={price:UInt64} AND Quantity={price:UInt64}" 2>&1 |  grep -Fq "DUPLICATE_COLUMN" && echo 'ERROR' || echo 'OK'

$CLICKHOUSE_CLIENT -q "CREATE DATABASE ${CLICKHOUSE_TEST_UNIQUE_NAME}"
$CLICKHOUSE_CLIENT -q "CREATE TABLE ${CLICKHOUSE_TEST_UNIQUE_NAME}.Catalog (Name String, Price UInt64, Quantity UInt64) ENGINE = Memory"
$CLICKHOUSE_CLIENT -q "INSERT INTO ${CLICKHOUSE_TEST_UNIQUE_NAME}.Catalog VALUES ('Pen', 10, 3)"
$CLICKHOUSE_CLIENT -q "INSERT INTO ${CLICKHOUSE_TEST_UNIQUE_NAME}.Catalog VALUES ('Book', 50, 2)"
$CLICKHOUSE_CLIENT -q "INSERT INTO ${CLICKHOUSE_TEST_UNIQUE_NAME}.Catalog VALUES ('Paper', 20, 1)"
$CLICKHOUSE_CLIENT -q "CREATE VIEW ${CLICKHOUSE_TEST_UNIQUE_NAME}.pv1 AS SELECT * FROM ${CLICKHOUSE_TEST_UNIQUE_NAME}.Catalog WHERE Price={price:UInt64}"
$CLICKHOUSE_CLIENT -q "SELECT Price FROM ${CLICKHOUSE_TEST_UNIQUE_NAME}.pv1(price=20)"
$CLICKHOUSE_CLIENT -q "SELECT Price FROM \`${CLICKHOUSE_TEST_UNIQUE_NAME}.pv1\`(price=20)"  2>&1 |  grep -Fq "UNKNOWN_FUNCTION" &&  echo 'ERROR' || echo 'OK'


$CLICKHOUSE_CLIENT -q "INSERT INTO test_02428_Catalog VALUES ('Book2', 30, 8)"
$CLICKHOUSE_CLIENT -q "INSERT INTO test_02428_Catalog VALUES ('Book3', 30, 8)"
$CLICKHOUSE_CLIENT -q "CREATE VIEW test_02428_pv5 AS SELECT Price FROM test_02428_Catalog WHERE {price:UInt64} HAVING Quantity in (SELECT {quantity:UInt64}) LIMIT {limit:UInt64}"
$CLICKHOUSE_CLIENT -q "SELECT Price FROM test_02428_pv5(price=30, quantity=8, limit=1)"
$CLICKHOUSE_CLIENT -q "CREATE VIEW test_02428_pv6 AS SELECT Price+{price:UInt64} FROM test_02428_Catalog GROUP BY Price+{price:UInt64} ORDER BY Price+{price:UInt64}"
$CLICKHOUSE_CLIENT -q "SELECT * FROM test_02428_pv6(price=10)"
$CLICKHOUSE_CLIENT -q "CREATE VIEW test_02428_pv7 AS SELECT Price/{price:UInt64} FROM test_02428_Catalog ORDER BY Price"
$CLICKHOUSE_CLIENT -q "SELECT * FROM test_02428_pv7(price=10)"

$CLICKHOUSE_CLIENT -q "DROP VIEW test_02428_pv1"
$CLICKHOUSE_CLIENT -q "DROP VIEW test_02428_pv2"
$CLICKHOUSE_CLIENT -q "DROP VIEW test_02428_pv3"
$CLICKHOUSE_CLIENT -q "DROP VIEW test_02428_pv5"
$CLICKHOUSE_CLIENT -q "DROP VIEW test_02428_pv6"
$CLICKHOUSE_CLIENT -q "DROP VIEW test_02428_pv7"
$CLICKHOUSE_CLIENT -q "DROP VIEW test_02428_v1"
$CLICKHOUSE_CLIENT -q "DROP TABLE test_02428_Catalog"
$CLICKHOUSE_CLIENT -q "DROP TABLE ${CLICKHOUSE_TEST_UNIQUE_NAME}.pv1"
$CLICKHOUSE_CLIENT -q "DROP TABLE ${CLICKHOUSE_TEST_UNIQUE_NAME}.Catalog"
$CLICKHOUSE_CLIENT -q "DROP DATABASE ${CLICKHOUSE_TEST_UNIQUE_NAME}"
-- Tags: no-parallel
-- Tag no-parallel: Messes with internal cache

SYSTEM DROP QUERY RESULT CACHE;

-- Cache the query result after the 1st query invocation
SELECT 1 SETTINGS enable_experimental_query_result_cache = true, query_result_cache_min_query_runs = 0;
SELECT COUNT(*) FROM system.query_result_cache;

SELECT '---';

SYSTEM DROP QUERY RESULT CACHE;

-- Cache the query result after the 2nd query invocation
SELECT 1 SETTINGS enable_experimental_query_result_cache = true, query_result_cache_min_query_runs = 1;
SELECT COUNT(*) FROM system.query_result_cache;
SELECT 1 SETTINGS enable_experimental_query_result_cache = true, query_result_cache_min_query_runs = 1;
SELECT COUNT(*) FROM system.query_result_cache;

SELECT '---';

SYSTEM DROP QUERY RESULT CACHE;

-- Cache the query result after the 3rd query invocation
SELECT 1 SETTINGS enable_experimental_query_result_cache = true, query_result_cache_min_query_runs = 2;
SELECT COUNT(*) FROM system.query_result_cache;
SELECT 1 SETTINGS enable_experimental_query_result_cache = true, query_result_cache_min_query_runs = 2;
SELECT COUNT(*) FROM system.query_result_cache;
SELECT 1 SETTINGS enable_experimental_query_result_cache = true, query_result_cache_min_query_runs = 2;
SELECT COUNT(*) FROM system.query_result_cache;

SYSTEM DROP QUERY RESULT CACHE;

DROP FUNCTION IF EXISTS analyze_table;
CREATE OR REPLACE FUNCTION analyze_table(tb_nm text)
RETURNS TABLE(
    col_nm TEXT,
    count_of_distinct_values BIGINT,
    count_of_non_null_values BIGINT,
    count_of_rows BIGINT,
    max_value TEXT,
    min_value TEXT,
    value_list TEXT
)
AS
 $$
    DECLARE SQL_str TEXT;
    DECLARE i INTEGER;
    DECLARE const_sql TEXT;
BEGIN
    SQL_str := $s$
WITH base AS (
        SELECT * FROM (VALUES('general_duration', 'duration_in_ms')) AS t(old_col_nm, new_col_nm)
    )
, x AS       (
            SELECT 
              CASE WHEN ordinal_position = 2 THEN '' ELSE 'UNION ALL ' END || 'SELECT ''' || COALESCE(new_col_nm, column_name) || ''' AS col_nm
            , COUNT(DISTINCT '|| column_name || ')          AS count_of_distinct_values 
            , COUNT(' || column_name || ')                  AS count_of_non_null_values
            , COUNT(*)                                      AS count_of_rows
            , MAX(' || column_name || ')                    AS max_value
            , MIN(' || column_name || ')                    AS min_value
            , STRING_AGG(DISTINCT '||column_name ||', '','')  AS value_list
            FROM %I' AS line
        FROM information_schema.columns LEFT JOIN base ON old_col_nm = column_name
        WHERE table_name = '%I'  AND column_name NOT in('file_id'))
--        , ' ')
SELECT STRING_AGG(line, ' ') FROM x
$s$;
    --RAISE NOTICE 's3 %', SQL_str;
    EXECUTE format(SQL_str, tb_nm, tb_nm) INTO const_sql;
    
    raise notice 'Value: %', const_sql;
    RETURN QUERY    
    EXECUTE const_sql; 
END;
$$
LANGUAGE 'plpgsql';

SELECT * FROM analyze_table('files_media_info') ORDER BY col_nm 

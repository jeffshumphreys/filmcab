-- simplified.scheduled_tasks_ext_v source
DROP VIEW IF EXISTS simplified.scheduled_tasks_ext_v;
CREATE OR REPLACE VIEW simplified.scheduled_tasks_ext_v
AS WITH base AS (
SELECT 
    st.scheduled_task_id                                                                                                                                                                                        AS scheduled_task_id,
    strs.scheduled_task_run_set_id                                                                                                                                                                              AS scheduled_task_run_set_id,
    strs.scheduled_task_run_set_name                                                                                                                                                                            AS scheduled_task_run_set_name,
    st.order_in_set                                                                                                                                                                                             AS order_in_set,
    strs.run_start_time                                                                                                                                                                                         AS run_start_time,
    st.scheduled_task_root_directory                                                                                                                                                                            AS scheduled_task_root_directory,
    ((('\'::text || st.scheduled_task_root_directory) || '\'::text) || strs.scheduled_task_run_set_name) || '\'::text                                                                                           AS scheduled_task_directory,
    (((('\'::text || st.scheduled_task_root_directory) || '\'::text) || strs.scheduled_task_run_set_name) || '\'::text) || st.scheduled_task_name                                                               AS uri,
    lag(st.scheduled_task_name) OVER (PARTITION BY strs.scheduled_task_run_set_id ORDER BY st.order_in_set)                                                                                                     AS previous_task_name,
    lag((((('\'::text || st.scheduled_task_root_directory) || '\'::text) || strs.scheduled_task_run_set_name) || '\'::text) || st.scheduled_task_name) OVER (ORDER BY st.scheduled_task_run_set_id, st.order_in_set) AS previous_uri,
    st.scheduled_task_name                                                                                                                                                                                      AS scheduled_task_name,
    st.scheduled_task_short_description                                                                                                                                                                         AS scheduled_task_short_description,
    CASE WHEN st.script_path_to_run IS NULL THEN 
        'D:\qt_projects\' || st.scheduled_task_root_directory|| '\simplified\tasks\scheduled_tasks\' || strs.scheduled_task_run_set_name || '\' || st.scheduled_task_name ||'.ps1' ELSE st.script_path_to_run END AS script_path_to_run,
        CASE WHEN st.script_path_to_run IS NOT NULL AND st.script_path_to_run !~~ (('%'::text || st.scheduled_task_name) || '.ps1'::text) THEN 'WARNING: Name mismatch'::TEXT ELSE ''::TEXT END                 AS warning,
    st.execution_time_limit                                                                                                                                                                                     AS execution_time_limit,
    MIN(st.order_in_set) OVER()                                                                                                                                                                                 AS min_order_in_set,
    MAX(st.order_in_set) OVER()                                                                                                                                                                                 AS max_order_in_set
    
   FROM scheduled_tasks st
     JOIN scheduled_task_run_sets strs USING (scheduled_task_run_set_id)
)
SELECT *, CASE WHEN min_order_in_set = max_order_in_set THEN 'Starting-Ending' WHEN order_in_set  = min_order_in_set THEN 'Starting' WHEN order_in_set = max_order_in_set  THEN 'Ending' ELSE 'In-Between' END  AS script_position_in_lineup
    FROM base;

COMMENT ON VIEW simplified.scheduled_tasks_ext_v IS 'scheduled tasks with their sets (sub groups, streams) labeled';
SELECT * FROM scheduled_tasks_ext_v stev;
--UPDATE scheduled_tasks  SET script_path_to_run  = NULL WHERE scheduled_task_id  = 22;
--UPDATE scheduled_tasks  SET script_path_to_run  = NULL WHERE scheduled_task_run_set_id = 2;
--UPDATE scheduled_tasks  SET script_path_to_run  = NULL;
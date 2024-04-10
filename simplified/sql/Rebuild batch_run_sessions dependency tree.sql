-- simplified.batch_run_sessions_v source
DROP VIEW IF EXISTS batch_run_sessions_v CASCADE;
CREATE OR REPLACE VIEW simplified.batch_run_sessions_v
AS SELECT 
    batch_run_session_id                           AS batch_run_session_id,
    started                                        AS started,
    initcap(to_char(started, 'DAY'))               AS started_on_dow,          
    stopped                                        AS ended,
    marking_stopped_after_overrun                  AS marking_ended_after_overrun,
    running                                        AS running,
    TRUNC(EXTRACT(EPOCH FROM (stopped - started))) AS run_duration_in_seconds,
    TRUNC(EXTRACT(EPOCH FROM (stopped - started))/60) AS run_duration_in_minutes,
    TRUNC(EXTRACT(EPOCH FROM (stopped - started))/60/60,2) AS run_duration_in_hours,
    last_script_ran                                AS last_script_ran,
    session_starting_script                        AS session_starting_script,
    session_killing_script                         AS session_ending_script,
    caller_starting                                AS caller_starting,
    caller_stopping                                AS caller_ending,
    trigger_type                                   AS trigger_type,
    triggered_by_login                             AS triggered_by_login,
    thread_id,
    process_id
    activity_uuid,
    trigger_id
   FROM batch_run_sessions;
   
-- simplified.batch_run_sessions_v_last_10_days_v source

CREATE OR REPLACE VIEW simplified.batch_run_sessions_v_last_10_days_v
AS SELECT *
   FROM batch_run_sessions_v
  WHERE started > (CURRENT_DATE - '10 days'::interval)
  ORDER BY started;
  
-- simplified.batch_run_sessions_scheduled_and_completed_v source

CREATE OR REPLACE VIEW simplified.batch_run_sessions_scheduled_and_completed_v
AS SELECT *
   FROM batch_run_sessions_v
  WHERE 
    started IS NOT NULL 
  AND
    ended IS NOT NULL 
  AND 
    ended > started
  AND 
    session_starting_script = '_start_new_batch_run_session.ps1'
  AND 
    session_ending_script = 'zzz_end_batch_run_session.ps1'
  AND
    caller_starting = 'Windows Task Scheduler' 
  AND 
    caller_ending = 'Windows Task Scheduler'
  ORDER BY started;
  
CREATE OR REPLACE VIEW simplified.batch_run_session_tasks_v
AS 
SELECT 
    brst.batch_run_session_task_id
,   brst.batch_run_session_id
,   brst.started
,   brst.ended
,   brst.error_code
,   TRUNC(EXTRACT(EPOCH FROM (brst.ended - brst.started))) AS run_duration_in_seconds                       
,   brst.running
,   brst.caller
,   brst.caller_ending
,   brst.caller_starting
,   brst.marking_ended_after_overrun
,   brst.script_name
,   brst.script_changed
,   brst.triggered_by_login
,   brst.trigger_type
,   brst.thread_id
,   brst.process_id
,   brst.activity_uuid
,   brst.trigger_id    
,   brst.is_testscheduledriventaskdetection
FROM
    batch_run_session_tasks brst
;
SELECT * FROM batch_run_sessions_scheduled_and_completed_v brssacv  
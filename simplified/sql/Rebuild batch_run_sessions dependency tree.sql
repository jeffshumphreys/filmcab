-- simplified.batch_run_sessions_v source
DROP VIEW batch_run_sessions_v CASCADE;
CREATE OR REPLACE VIEW simplified.batch_run_sessions_v
AS SELECT 
    brs.batch_run_session_id,
    brs.started,
    brs.stopped                       AS ended,
    brs.marking_stopped_after_overrun AS marking_ended_after_overrun,
    brs.running,
    brs.run_duration_in_seconds,
    brs.last_script_ran,
    brs.session_killing_script        AS session_ending_script,
    brs.session_starting_script,
    brs.caller,
    brs.caller_starting,
    brs.caller_stopping               AS caller_ending
   FROM batch_run_sessions brs;
   
-- simplified.batch_run_sessions_v_last_10_days_v source

CREATE OR REPLACE VIEW simplified.batch_run_sessions_v_last_10_days_v
AS SELECT 
    batch_run_session_id,
    started,
    ended,
    marking_ended_after_overrun,
    running,
    run_duration_in_seconds,
    last_script_ran,
    session_ending_script,
    session_starting_script,
    caller,
    caller_starting,
    caller_ending
   FROM batch_run_sessions_v
  WHERE started > (CURRENT_DATE - '10 days'::interval)
  ORDER BY started;
  
-- simplified.batch_run_sessions_scheduled_and_completed_v source

CREATE OR REPLACE VIEW simplified.batch_run_sessions_scheduled_and_completed_v
AS SELECT 
    batch_run_session_id,
    started,
    ended,
    marking_ended_after_overrun,
    running,
    run_duration_in_seconds,
    last_script_ran,
    session_ending_script,
    session_starting_script,
    caller,
    caller_starting,
    caller_ending
   FROM batch_run_sessions_v
  WHERE 
    started IS NOT NULL 
  AND
    ended IS NOT NULL 
  AND 
    ended > started

  ORDER BY started;
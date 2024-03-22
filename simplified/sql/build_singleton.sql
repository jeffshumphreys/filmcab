/*
    My invention

    Idea: What if I could avoid implementation details about how an active state is defined?  It may change over time.
    But, for those scripts who just want to know which state identifier is active, for their records, they don't want to go "SELECT id FROM master_table where  active and thread_id is max - 1 and not canceled and not on hold or incomplete or restarted or migrated to failover table/server/db"

    What if I could say select id from id_view, and it always gave me either a) -1, meaning no active state, or b) a single value(1 row) identifying the active session state.
    One script defined as starting a state (a being state, a session with a begin and end), this script sets the state value with an INSERT.  For now, if multiple inserts occur, you get multiple rows, but SELECT only ever returns the last one.
    One script is defined as the ending of that state (exiting state), and it's job is to clear out (DELETE) all rows from our singleton, and thereby make sure that no more tasks attach to that session.

    All the scripts between start and end (or stop, finish) query for the state identifier with a SELECT.  Then they insert a log entry somewhere, so that the journey down the path is traceable.
*/
DROP TABLE IF EXISTS simplified.batch_run_session_active_running_values CASCADE;
CREATE TABLE simplified.batch_run_session_active_running_values (
    active_batch_run_session_id int4 NOT NULL,
    set_on timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL
    );
    
DROP VIEW IF EXISTS simplified.batch_run_session_active_running_values_ext_v;

CREATE OR REPLACE VIEW simplified.batch_run_session_active_running_values_ext_v AS
SELECT * FROM (
SELECT -1 AS active_batch_run_session_id, now() AS set_on UNION ALL 
SELECT active_batch_run_session_id, set_on FROM simplified.batch_run_session_active_running_values
) x ORDER BY set_on ASC
LIMIT 1
;
SELECT * FROM simplified.batch_run_session_active_running_values_ext_v;

CREATE OR REPLACE RULE "block_multi_rows_insert" AS ON INSERT TO simplified.batch_run_session_active_running_values
WHERE (SELECT COUNT(*) FROM simplified.batch_run_session_active_running_values) >= 1
DO INSTEAD UPDATE simplified.batch_run_session_active_running_values SET active_batch_run_session_id = NEW.active_batch_run_session_id ;

SELECT * FROM simplified.batch_run_session_active_running_values_ext_v;


--UPDATE batch_run_session_active_running_values_ext_v SET active_batch_run_session_id  = 2;

INSERT INTO simplified.batch_run_session_active_running_values(active_batch_run_session_id) VALUES (1);
INSERT INTO simplified.batch_run_session_active_running_values(active_batch_run_session_id) VALUES (3);

SELECT * FROM simplified.batch_run_session_active_running_values_ext_v;

CREATE OR REPLACE FUNCTION view_delete()  RETURNS TRIGGER AS $$
BEGIN 
    DELETE FROM simplified.batch_run_session_active_running_values WHERE 1=1;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER on_delete_batch_run_session_active_running_values INSTEAD OF DELETE ON batch_run_session_active_running_values_ext_v
FOR EACH ROW EXECUTE PROCEDURE view_delete();

DELETE FROM simplified.batch_run_session_active_running_values_ext_v WHERE 1=1;

SELECT * FROM simplified.batch_run_session_active_running_values_ext_v;

CREATE OR REPLACE FUNCTION insert_update_if_no_record()  RETURNS TRIGGER AS $$
BEGIN 
    IF (SELECT COUNT(*) FROM simplified.batch_run_session_active_running_values) = 0 THEN
        INSERT INTO simplified.batch_run_session_active_running_values(active_batch_run_session_id) VALUES(NEW.active_batch_run_session_id);
    ELSE
        UPDATE simplified.batch_run_session_active_running_values SET active_batch_run_session_id = NEW.active_batch_run_session_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER on_update_batch_run_session_active_running_values INSTEAD OF UPDATE ON batch_run_session_active_running_values_ext_v
FOR EACH ROW EXECUTE PROCEDURE insert_update_if_no_record();

UPDATE simplified.batch_run_session_active_running_values_ext_v SET active_batch_run_session_id  = 5;

SELECT * FROM simplified.batch_run_session_active_running_values_ext_v;

UPDATE simplified.batch_run_session_active_running_values_ext_v SET active_batch_run_session_id  = 6;

SELECT * FROM simplified.batch_run_session_active_running_values_ext_v;

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

pg_dump --schema-only --file filmcab_dump_ddl.sql filmcab
pg_dump --column-inserts -t typs --file filmcab_dump_ref_data.sql filmcab
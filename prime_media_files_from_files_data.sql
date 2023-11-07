SET search_path = stage_for_master, "$user", public;
select distinct final_extension  FROM files;

select * FROM files where id not in(select id from media_files mf);

with typ_to_ext_map as (
	select * from (
		values('avi', 'Video'), ('f4v', 'Video'), ('flv', 'Video'), ('mkv', 'Video'), ('mov', 'Video'), ('mp4', 'Video'), ('mpg', 'Video'), ('ogv', 'Video'), ('webm', 'Video'), ('wmv', 'Video')
		, ('sub', 'DVD Subtitles'), ('idx', 'DVD Index'), ('vob', 'DVD Video'), ('srt', 'Subtitles')
		) as t(ext, typ)
)
INSERT INTO media_files (id, typ_id, txt, file_name_no_extension, parent_folder_name, grandparent_folder_name, greatgrandparent_folder_name, record_version_for_same_name)
SELECT f.id
, t.id                       as typ_id
, split_part(f.txt, '/', -1) as txt
, f.base_name                as file_name_no_extension
, split_part(f.txt, '/', -2) as parent_folder_name
, split_part(f.txt, '/', -3) as grandparent_folder_name
, split_part(f.txt, '/', -4) as greatgrandparent_folder_name
, 1                          as record_version_for_same_name
from files f join typ_to_ext_map tt on f.final_extension = tt.ext
cross join public.typs t
where t.txt = tt.typ
and f.id not in(select id from media_files); 


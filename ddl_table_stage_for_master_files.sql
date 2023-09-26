-- public.files definition

-- Drop table


create schema if not exists receiving_dock;
create schema if not exists stage_for_master;
create schema if not exists shipping_dock;

set search path = stage_for_master;

drop table if exists files; -- Probably don't want constraints on this table

create table files (
	id                                           int                         not null generated always as identity, -- local counter, since staging data
	text                                         varchar(400)                not null, -- full path. i.e., "D:/qBittorrent Downloads/Video/Movies/13.Hours.The.Secret.Soldiers.of.Benghazi.2016.1080p.BluRay.x264.DTS-JYK/13.Hours.The.Secret.Soldiers.of.Benghazi.2016.1080p.BluRay.x264.DTS-JYK.mkv"
	base_name                                    varchar(200)                not null, -- i.e., "13.Hours.The.Secret.Soldiers.of.Benghazi.2016.1080p.BluRay.x264.DTS-JYK"
	final_extension                              varchar(5)                  not null, -- i.e., "mkv"
	record_version_for_same_name_file            int                         not null, -- local versioning
	type_id                                      int8                            null, -- Unlike Titles table, type does not make it unique. Mainly path
	record_created_on_ts_wth_tz                  timestamptz                     null default clock_timestamp(),
	record_changed_on_ts_wth_tz                  timestamptz                     null,
	record_deleted                               bool                            null,
	record_deleted_on_ts_wth_tz                  timestamptz                     null,
	record_deleted_why							 varchar(400)                    null, -- could be a code, too, as in "file no longer present, torrent system moved, duplicate record"
	text_prev                                    varchar(400)                    null,
	text_corrected                               bool                            null,
	text_corrected_on_ts_wth_tz                  timestamptz                     null,
	type_corrected                               bool                            null,
	type_corrected_on_ts_wth_tz                  timestamptz                     null,
	file_size                                    bigint                          null,
	file_created_on_ts                           timestamp without time zone not null,
	file_modified_on_ts                          timestamp without time zone not null,
	parent_folder_created_on_ts                  timestamp without time zone not null,
	parent_folder_modified_on_ts                 timestamp without time zone not null,
	file_deleted                                 bool                        not null default false,
	file_deleted_on_ts_wth_tz                    timestamptz                     null,
	file_replaced                                bool                        not null default false,
	file_replaced_on_ts_wth_tz                   timestamptz                     null,
	file_moved                                   bool                        not null default false,
	file_moved_where                             varchar(400)                    null, -- cloud? thumbdrive? another network? computer?
	file_moved_on_ts_wth_tz                      timestamptz                     null,
	file_lost                                    bool                        not null default false,
	file_loss_detected_on_ts_wth_tz              timestamptz                     null,
	last_verified_full_path_present_on_ts_wth_tz timestamptz                     null,
	file_md5_hash                                bytea                       not null,
	constraint files_pkey primary key (id),
	constraint files_text_version unique (text, record_version_for_same_name_file)
);

comment on column files.id                          is 'staging so use an identity. Master has to keep id''s across system. Still, would be nice to keep a few staged sets, all the week, 1 from previous month, year';
comment on column files.text                        is 'aka full_path. "text" means the same update algorithm triggers work. is 400 enough? It can be changed - NEVER TRUNCATE! In postgresql it''s UTF8, which SQL Server only recently supports and recommends not using. The collation was the default, English_United States.1252. Maybe a dictionary collate?';
comment on column files.base_name                   is 'Doesn''t include the extension, hopefully ''base'' is clear.';
comment on column files.final_extension             is 'Ever any longer than 3? Torrents are often styled with lots of dots instead of spaces.  No idea why. In the torrent downloading folder we do not change the names, so multi-dots are probably every file';
comment on column files.record_deleted              is 'By keeping "deleted" records of files (hopefully deleted), we lose the ability to use the ON CONFLICT clause since a postgres doesn''t support filtered constraints, only filtered indexes. Not sure if MS SQL was the same. But, this complicates the insert.';
comment on column files.type_id                     is 'Type can be what contextually is, like movie, or what it physically is, like mkv or codec or torrented file.';
comment on column files.text_corrected_on_ts_wth_tz is 'Type was corrected, meaning the original type was "video" and we want to label it more specifically "movie", but hopefully in the same tree. This will require thought. Other possibilities exist that would confuse the typing, like going to a whole new hierarchy, or up the tree. And is it corrected or enhanced?';
comment on column files.file_md5_hash               is 'I include the encryption method in the name because most people don''t, and then you have a devil of a time in a new app guessing.  This tells me two files are identical or not. They could be the same movie, but any slight variation would';
comment on column files.record_deleted              is 'I suppose this is weird with file_deleted also present, but There are so many reasons to delete a record, I just can''t think of one. Let it sit and then we can update the comment.  Examples of why a column exists are important, or else the column shouldn''t exist.';
comment on column files.file_deleted                is 'Try and trap this so if it comes back around, as things do over time, then we have a record';
comment on column files.parent_folder_created_on_ts is 'Newly noted: When torrents come down in folders, the folder is the date I downloaded it, or it finished, but the inner files are the date the online source created the file.  Very useful.';

create trigger public.trgupd_files before
update
	on
	files for each row execute function public.trgupd_common_columns();

-- update trigger
-- what happened?

create index ix_files_hash on files(file_md5_hash); 
comment on index ix_files_hash is 'We have files that would be the same hash but in different locations or names';

create unique index ax_files_text on files(text) where file_deleted is null or file_deleted is false;
comment on index ax_files_text is 'The only way a file could have the same path is if the other one is no longer there, so we keep the old entry and mark it deleted. No idea about undelete redelete';


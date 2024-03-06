# These are the PowerShell scripts and Windows Task Scheduler Tasks I've begun consolidating:
## database maintenance
1. ✅vacuum_database
1. ✅backup_database
1. 🤔restart_database_server

## file maintenance
1. ✅_start_new_batch_run_session
1. ✅back_up_unbackedup_published_media
1. ✅scan_for_file_directories
1. ✅delete_missing_directory_entries
1. ✅scan_file_directories_for_files
1. ✅delete_file_entries_in_deleted_directories
1. ✅delete_references_to_missing_files
1. ✅populate_any_missing_file_hashes
1. 🚧clean_up_table_data
1. 💡delete_dup_backups_not_published
1. ✅extract_genres_from_file_paths
1. 💡physically_delete_published_crap
1. 🚧link_files_across_search_directories
1. convert_published_duplicates_to_hard_links
1. report_unpublished_files
1. 🚧zzz_end_batch_run_session

## video file maintenance
1. pull_new_file_entries_into_videos
1. link_subtitles_to_videos
1. normalize_video_file_names_to_titles
1. extract_metadata_from_files_into_video_files
1. count_seasons_and_episodes

## video maintenance
1. generate_alternate_calculable_titles

## schedule maintenance
1. ✅pull_new_scheduled_task_events
1. ✅pull_scheduled_task_definitions
1. export_project_scheduled_task_definition_xml

## import metadata
1. ✅load_user_spreadsheet_interface
1. validate_user_spreadsheet_interface_quality
1. update_spreadsheet_with_new_files
1. pull_keep_list
1. merge_keep_list_into_spreadsheet
1. pull_new_tmdb_metadata
1. scrape_tmdb_metadata_history
1. pull_imdb_dumps
1. scrape_imdb_metadata
1. pull_new_omdb_metadata
1. pull_wikidata_metadata
1. pull_wikiquote_metadata
1. merge_metadata_into_video_files

## download maintenance
1. pull_torrent_download_status
1. scan_sources_for_spreadsheet_entries
1. scrape_source_metadata
1. identify_best_seeders
1. identify_worst_trackers
1. cancel_overdue_downloads

## video player maintenance
1. remove_video_files_stale_locks

## server maintenance
1. 🤔restart_host

## polling
1. 🌙monitor_running_batch_run_session

## event driven
1. 🌙trap_new_scheduled_task_definitions

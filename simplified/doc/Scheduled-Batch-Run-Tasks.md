---
description: >-
  List of tasks scheduled for project, each section is an entry in the table
  scheduled_task_run_sets, and the numbered items underneath are entries in
  scheduled_tasks.
---

# Windows Task Scheduler Tasks

## database maintenance

1. ✅vacuum\_database
2. ✅backup\_database
3. 🤔restart\_database\_server

## file maintenance

1. ✅\_start\_new\_batch\_run\_session
2. ✅back\_up\_unbackedup\_published\_media
3. ✅scan\_for\_file\_directories
4. ✅delete\_missing\_directory\_entries
5. ✅scan\_file\_directories\_for\_files
6. ✅delete\_file\_entries\_in\_deleted\_directories
7. ✅delete\_references\_to\_missing\_files
8. ✅populate\_any\_missing\_file\_hashes
9. ✅clean\_up\_table\_data
10. 💡delete\_dup\_backups\_not\_published
11. ✅extract\_genres\_from\_file\_paths
12. ✅pull_ntfs_metadata_off_files
13. 💡physically\_delete\_published\_crap
14. link\_files\_across\_search\_directories
15. convert\_published\_duplicates\_to\_hard\_links
16. report\_unpublished\_files
17. ✅zzz\_end\_batch\_run\_session

## video file maintenance

1. pull\_new\_file\_entries\_into\_videos
2. link\_subtitles\_to\_videos
3. normalize\_video\_file\_names\_to\_titles
4. extract\_metadata\_from\_files\_into\_video\_files
5. count\_seasons\_and\_episodes

## video maintenance

1. generate\_alternate\_calculable\_titles

## schedule maintenance

1. ✅pull\_new\_scheduled\_task\_events
2. ✅pull\_scheduled\_task\_definitions
3. export\_project\_scheduled\_task\_definition\_xml

## import metadata

1. ✅load\_user\_spreadsheet\_interface
2. validate\_user\_spreadsheet\_interface\_quality
3. update\_spreadsheet\_with\_new\_files
4. pull\_keep\_list
5. merge\_keep\_list\_into\_spreadsheet
6. pull\_new\_tmdb\_metadata
7. scrape\_tmdb\_metadata\_history
8. pull\_imdb\_dumps
9. scrape\_imdb\_metadata
10. pull\_new\_omdb\_metadata
11. pull\_wikidata\_metadata
12. pull\_wikiquote\_metadata
13. merge\_metadata\_into\_video\_files

## download maintenance

1. pull\_torrent\_download\_status
2. scan\_sources\_for\_spreadsheet\_entries
3. scrape\_source\_metadata
4. identify\_best\_seeders
5. identify\_worst\_trackers
6. cancel\_overdue\_downloads

## video player maintenance

1. remove\_video\_files\_stale\_locks

## server maintenance

1. 🤔restart\_host

## polling

1. 🌙monitor\_running\_batch\_run\_session

## event driven

1. 🌙trap\_new\_scheduled\_task\_definitions

Icons 🚧 - Under construction 🤔 - Are we sure we want to do this 🌙 - Dead; so far off and low priority 💡 - Good idea, concept, how will we implement ✅ - Deployed, scheduled, appears to be running good

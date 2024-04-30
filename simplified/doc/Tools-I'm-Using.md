---
description: >-
  Makes any (non-existent) users of this code aware of the tools involved, which
  goes along way to explaining the coding style choices.
---

# Tools I'm Using

## Operating Systems

* Windows 10.0.19045 22H2 not 11 (_No need to upgrade? Nah._)

#### PowerShell Development

* Visual Code 1.88.1 (_for PowerShell Development, MD editing._)
* ~~PowerShell 7.4.1 Core for running simple SQL and file loops, especially if I need excel.~~
  * ~~ImportExcel 7.8.6 (Import-Excel) https://github.com/dfinke/ImportExcel (Excel.dll now has blocking unremovable popups if used from automation)~~
* ~~PowerShell 5.1~~ (_Core will not allow me to load UNO, which is a great tool for editing excel files without excel_)
* PowerShell Core 7.5.0 preview 1 (_Got it to work, though UNO is probably out. Switched to straight LibreOffice_)
* soffice 24.2.0.3 (_executable part of LibreOffice_)
* psqlodbc\_x64.msi (_https://ftp.postgresql.org/pub/odbc/versions/msi/psqlodbc\_15\_00\_0000-x64.zip_)

**PowerShell Extensions** _in order of usefulness_

* PowerShell 2024.3.1
* Inline Values support for PowerShell 0.0.7 (_Best tool for debugging_)
* WakaTime 24.4.0                            (_Very awesome. Makes me feel rewarded for time spent._)
* Better Align 1.4.2                         (_Use to align lines without selecting them at "=" sign with Alt-A, though it doesn't work that great._)
* align-columns 0.0.6                        (_needed to align various comment indicators. Better Align doesn't do it._)
* Bracket Lens                               (_Works except sometimes disappears, then comes back mysteriously. Note that sometimes it's linking back to the wrong line!!!. Trying to guess a workaround._)
* Sort lines 1.11.0                          (_saved me so much work on my massive list of constants, media info columns to ignore is 780! columns to include, too._)
* Insert Time Stamp 1.1.3 Preview            (_Works well enough_)
* Hide Gitignored 1.1.0                      (_Useful, reduces clutter in Explorer_)
* Material Icon Theme                        (_Helps my poor eyes identify different files, mostly ps1 and log files_)
* VS Code Counter 3.4.0                      (_Helps with compiling stats on my work. By these metrics, I remind myself that I did stuff and it's growing.  Motivator._)
* AutoTrim 1.0.6                             (_I think it's working_)
* change-case 1.0.0                          (_Can't tell if I'm usin' this one or Casing Convention_)
* Draw.io Integration 1.6.6                  (_Haven't used in a while since I'm not graphically designing. Is that a theme? Do I use less ER diagrams as the project solidifies?  Seems so._)
* ~~TODO Highlight 1.0.5~~                   (_Never used. I suppose if I converted them to GitHub Issues it would help, but I work on what I want and not just whereever I stuff a TODO tag._)
* ~~fake-virtual-space 0.1.3~~               (_too much fake change constant churn in github pushes. That and it's 50/50 whether I want the end of the next line down or to virtually spaced over._)
* ~~Batch Runner~~                           (_No need for it since no batch files like crap job at City of Boise_)
* ~~cmd exec~~                               (_No need for it since no batch files like crap job at City of Boise_)

**PowerShell Modules/NuGet Packages**

* Get-MediaInfo 3.7 (_Fantastic! Granted, lotta work cleaning up output, but massive movie metadata!_)
* Npgsql 8.0.1 (or 3.2.6??)
* PowerShellHumanizer 3.2
* ~~Humanizer (trying to install. May fail. Over 20 minutes.)~~

#### Database Development

* postgreSQL 15.4 not 16 (local) (_No need for 16_)
  * unaccent extension (_works!_)
* DBeaver 24.0.2 Community (_latest always, Oct 2023, for browsing data, DDL extract, adding columns, scripting._)
* pgAdmin 4.7.8 (_latest always) (2023) (for not table work, just types, enums, ddl creation, most can be done in DBeaver_)
* pg\_dump for DDL (_only tool that works_)
* psqlODBC 16.00.0000, psqlODBC 13.02.0000-1, psqlODBC_x64 15.00.0000 (_Huh? Which installed app is used??_)

#### File Gathering

* qBitTorrent 4.6.4                (_for I2P - GNU General Public License, version 3 or GPLv3+ \* Qt 6.4.2 \* libtorrent-rasterbar 1.2.19.0 \* Boost 1.83.0 \* OpenSSL 1.1.1w \* zlib 1.3_)
* YouTube (on FireFox)
    * Video DownloadHelper 8.2.2.8 (**$28** permanent) (_Works good, though quality so far of downloads is limited.  Source of last resort_)
    * DownloadHelper CoApp 2.0.19.0
* Jackett 0.21.1025                (_Probably misconfigured. Does it matter?_)
* Telegram - Channel iPapkornFbot  (_Haven't tried it yet_)
* archive.com                      (_Works for old films_)

#### File Management

* Windows Explorer
* Link Shell Extension 3.9.3.3 (_Explorer extension_)
* ~~Fsync~~
* fsutil
    * fsutil file queryfileid  (_Get ntfs id for (eventual) use in detecting when files change name but are not new files so don't need new file hash_)
    * fsutil behavior set SymlinkEvaluation L2L:1 R2R:1 L2R:1 R2L:1 (_I want to move stuff off of spindles for space saving, but leave a link that MX Player can follow_)
* Everything (1.4.1.1005)      (_Fast!_)
* Advanced Renamer 3.91        (_Used to get crazy on cleanin' up mass names of episodes from their downloaded torrent names_)

#### Video Play

* ~~VLC 3.0.20~~                 (_latest always. Can't use well on firetv. Uses it's own codecs so not always up to date._)
* ~~X-plore (FireTV) 4.32 ($6)~~ (_almost dead, buggy as hell, getting WORSE_)
* MX Player                      (_linux (firetv) only, can't play protected DSL Audio EAC. Need to try pro version_)
* MPC-HC (64-bit) 2.2.0          (_only way to get subtitles (some) and plays more than MX Player, but only on Desktop_)
* K-Lite Mega Codec Pack 18.2.6  (_Being used I assume?_)

#### Video Edit

* Free Video Editor 1.0.18 (_Used it a few times to concatenate split up VOB files_)

#### Video Metadata

* Get-MediaInfo 3.7     (_Fantastic! Granted, lotta work cleaning up output, but massive movie metadata!_)
* MediaInfo 24.04 (GUI) (_Helps to see what I'm missin'_)

#### Scheduling

* Windows Task Scheduler on Windows 10

#### User Interface

* ~~Excel~~
* LibreOffice Calc 24.2.0.3 (_Browse all the files, fix titles, add release year, add tags and genres, characters, actors_)
* Google Keep               (_Quickly make notes on my phone that go to my desktop while I'm watching something_)
* Google Sheets             (_Better than LibreOffice in that it's on my phone and protected in the cloud. Better and more clever than O365, too. Simpler Conditional Formatting, simpler complex cell formatting, better column value wrapping)
* offload_published_directories_selecting_using_gui.ps1 (_WinForms script_)

#### Source Control

* GitHub (_More for my project tracking; no collaboration taking place; issues;discussions_)
* git 2.42.0.windows.2
* Microsoft Git Credential Manager for Windows 1.20.0 (_Only way I can get VS Code + git to checkin code to GitHub now that text passwords are blocked_)

#### Design

* draw.io v22.1.2 (_for flowcharting the bigger picture, all the different tasks, logging files found, downloaded, starting downloads, renaming, publishing, pulling TMDB and IMDB metadata and loading and splitting json into columns, etc._)
* ~~Navicat Premium 16.1.2~~ (_Works. Iffy with round-trip gen, but works if I'm delicate. And it pushes to PostgreSQL 15._)

## Tools Will Not Be Using

* Visual Studio
* Microsoft SQL Server (_$$$_)
* Visio, LucidChart
* ChatGPT, AI
* Azure, AWT
* GitHub Copilot
* Hey Code voice command
* Amazon voice commands
* FileBot ($6) _Bought. Fakes you out that you can use it for free, but it won't fix a name til you buy. And the output is COMPLETELY UNCONFIGURABLE._
* gcc, mingw, Qt _Too hard for me. Too many errors were slipping by because I couldn't wrap my head around the complexity._

## Tools Tried Using but Failed

* ~~MindManager~~ (_Fun, but no longer bouncing ideas around_)
* ~~ERwin~~ (_No roundtrip support for Postgres_)
* boost 1.83.0 (stacktrace) (_No longer using C++_)
* cygwin (_breaks Qt minGW build if anywhere in path, though probably a partial install might work_)
* MSYS2
* PGXN (_extensions to postgres do not install on Windows._)
  * ddlx PostgreSQL extension 0.27.0 (Oct 2023) "DDL eXtractor functions for PostgreSQL" on PGXN (failed to install)
* pip (_installed packages, but then I didn't use, or couldn't._)

## Tools Planning to Use

* WebUI API  (_part of qBitTorrent. Disabled when suspected hacking._)
* FFmpeg 6.0 (_needed to extract video meta data like resolution - with FileInfo, probably don't need._)
* Pester     (_A lot of complaints about v5 online, so I'm not using._)
* fsutil hardlink create <newfilename> <existingfilename>
* Kubuntu (_Need to build on another machine, but too lazy_)
* Mac     (_have the other machine_)
* Google Keep API
* MediaConch "MediaConch is an extensible, open source software project consisting of an implementation checker, policy checker, reporter, and fixer that targets preservation-level audiovisual files (specifically Matroska, Linear Pulse Code Modulation (LPCM) and FF Video Codec 1 (FFV1)) for use in memory institutions, providing detailed and batch-level conformance checking via an adaptable and flexible application program interface"
* MediaTrace "MediaTrace is a technical report that expresses the binary architecture of a file as interpreted by MediaArea tools such as MediaInfo, starting in version 0.7.76, and MediaConch, starting in version 2015-07. Although MediaTrace reports may document any file format, the tools that generate it, MediaInfo and MediaConch, are optimized to report on audiovisual formats. "
* AVI MetaEdit

## Tools I may Need Someday

* (DOS cat) (_May use to concatenate VOB files_)

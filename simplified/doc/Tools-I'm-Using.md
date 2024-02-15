---
description: >-
  Makes any (non-existent) users of this code aware of the tools involved, which
  goes along way to explaining the code choices.
---

# Tools I'm Using

## Operating Systems

* Windows 10.0.19045 22H2 not 11 (_No need to upgrade_)

#### PowerShell Development

* Visual Code 1.86.1 (_for PowerShell Development_)
* ~~PowerShell 7.4.1 Core for running simple SQL and file loops, especially if I need excel.~~
  * ~~ImportExcel 7.8.6 (Import-Excel) https://github.com/dfinke/ImportExcel (Excel.dll now has blocking unremovable popups if used from automation)~~
* PowerShell 5.1 (_Core will not allow me to load UNO, which is a great tool for editing excel files without excel_)
* soffice (_executable part of LibreOffice_)
* psqlodbc\_x64.msi (_https://ftp.postgresql.org/pub/odbc/versions/msi/psqlodbc\_15\_00\_0000-x64.zip_)

**PowerShell Extensions**

* Better Align 1.4.2
* GitHub 0.0.1
* Inline Values support for PowerShell 0.0.7
* Insert Time Stamp 1.1.3 Preview
* PowerShell 2024.3.0
* TODO Highlight 1.0.5

**NuGet Packages**

* ~~Humanizer (trying to install. May fail. Over 20 minutes.)~~

**PowerShell Modules**
* PowerShellHumanizer 3.2


#### Database Development

* postgreSQL 15.4 not 16 (local) (_No need for 16_)
  * unaccent extension (_works!_)
* pgAdmin 4.7.8 (_latest always) (2023) (for not table work, just types, enums, ddl creation, most can be done in DBeaver_)
* pg\_dump for DDL (_only tool that works_)
* DBeaver 23.3.4 Community (_latest always, Oct 2023, for browsing data, DDL extract, adding columns, scripting._)

#### File Gathering

* qBitTorrent 4.6.3 (_for I2P - GNU General Public License, version 3 or GPLv3+ \* Qt 6.4.2 \* libtorrent-rasterbar 1.2.19.0 \* Boost 1.83.0 \* OpenSSL 1.1.1w \* zlib 1.3_)

#### Video Play

* VLC 3.0.20 (_latest always_)
* X-plore (FireTV) 4.32 ($6) (_almost dead, buggy as hell, getting WORSE_)
* MX Player (_linux (firetv) only_)
*

#### Scheduling

* Windows Task Scheduler on Windows 10

#### User Interface

* ~~Excel~~
* LibreOffice Calc (_Browse all the files, fix titles, add release year, add tags and genres, characters, actors_)
* Google Keep (_Quickly make notes on my phone that go to my desktop while I'm watching something_)

#### Source Control

* GitHub (_More for my project tracking; no collaboration taking place_)
* git 2.42.0.windows.2

#### Design

* draw.io v22.1.2 (_for flowcharting the bigger picture, all the different tasks, logging files found, downloaded, starting downloads, renaming, publishing, pulling TMDB and IMDB metadata and loading and splitting json into columns, etc._)
* Navicat Premium 16.1.2 (_Works. Iffy with round-trip gen, but works if I'm delicate. And it pushes to PostgreSQL 15._)

## Tools Will Not Be Using

* Visual Studio
* Microsoft SQL Server
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
* PGXN (_extensions to postgres not installing on Windows._)
  * ddlx PostgreSQL extension 0.27.0 (Oct 2023) "DDL eXtractor functions for PostgreSQL" on PGXN (failed to install)
* pip (_installed packages, but then I didn't use, or couldn't._)

## Tools Planning to Use

* WebUI API (_part of qBitTorrent_)
* FFmpeg 6.0 (_needed to extract video meta data like resolution_)
* Pester
* Kubuntu (on another machine)
* Mac (have the other machine)
* Google Keep API

## Tools I may Need Someday

* (DOS cat) (_May use to concatenate VOB files_)

---
description: >-
  Makes any (non-existent) users of this code aware of the tools involved, which
  goes along way to explaining the code choices.
---

# Tools I'm Using

## Operating Systems

* Windows 10.0.19045 22H2 not 11

#### PowerShell Development

* Visual Code 1.85.2 (for PowerShell Development)
* PowerShell 7.4.1 Core for running simple SQL and file loops, especially if I need excel.
  * ImportExcel 7.8.6 (Import-Excel) https://github.com/dfinke/ImportExcel (Excel.dll now has blocking unremovable popups if used from automation)
* psqlodbc\_x64.msi (for PowerShell only) https://ftp.postgresql.org/pub/odbc/versions/msi/psqlodbc\_15\_00\_0000-x64.zip

#### Database Development

* postgreSQL 15.4 not 16 (local)
  * unaccent extension (works!)
* pgAdmin 4.7.8 (latest always) (2023) (for not table work, just types, enums, ddl creation)
* pg\_dump for DDL (only tool that works)
* DBeaver 23.3.3 community (latest always) (Oct 2023) for browsing data, DDL extract, adding columns, scripting.

#### File Gathering

* qBitTorrent 4.6.3 (I2P) - GNU General Public License, version 3 or GPLv3+ \* Qt 6.4.2 \* libtorrent-rasterbar 1.2.19.0 \* Boost 1.83.0 \* OpenSSL 1.1.1w \* zlib 1.3

#### Video Play

* VLC 3.0.20 (latest always)
* X-plore (FireTV) 4.32 ($6) (almost dead, buggy as hell, getting WORSE)

#### Scheduling

* Windows Task Scheduler

#### User Interface

* Excel
* Google Keep

#### Source Control

* GitHub
* git 2.42.0.windows.2

#### Design

* draw.io v22.1.2 for flowcharting the bigger picture, all the different tasks, logging files found, downloaded, starting downloads, renaming, publishing, pulling TMDB and IMDB metadata and loading and splitting json into columns, etc.
* Google Keep (less, hope to replace with actual app)
* Navicat Premium 16.1.2 - Works Now? Iffy with round-trip gen, but works if I'm delicate.

## Tools I'm Considering

## Tools Will Not Be Using

* Visual Studio
* Microsoft SQL Server
* Visio, LucidChart
* ChatGPT, AI
* Azure, AWT

## Tools Tried Using but Failed

* MindManager, ERwin
* boost 1.83.0 (stacktrace)
* cygwin (breaks Qt minGW build if anywhere in path, though probably a partial install might work)
* MSYS2
* PGXN - extensions to postgres not installing on Windows.
  * ddlx PostgreSQL extension 0.27.0 (Oct 2023) "DDL eXtractor functions for PostgreSQL" on PGXN (failed to install)
* pip - installed packages, but then I didn't use, or couldn't.

## Tools Planning to Use

* WebUI API (part of qBitTorrent)
* FFmpeg 6.0 (if needed to extract video meta data like resolution)
* Pester
* Kubuntu (another machine)
* Mac (have the other machine)

## Tools I Stopped Using

* MindManager 21.0.261 (ERDs work better for me for structural design)
* FileBot ($6) Bought. Fakes you out that you can use it for free, but it won't fix a name til you buy. And the output is COMPLETELY UNCONFIGURABLE.
* gcc, mingw, Qt. Too hard for me. Too many errors were slipping by because I couldn't wrap my head around the complexity.
* Moving towards stopping ERwin use since it doesn't have PostgreSQL support, and it's very buggy in round-trip engineering.
* ERwin

## Tools I may Need Someday

* (DOS cat) (not much)
# filmcab
file cabinet for my movie and tv files

Simple tool to capture torrent downloaded files in a database.
Why? So I can determine via MD5 hash if:
  1) Have I already downloaded this, regardless of source or name?
  2) Do I have this same content, regardless of hash, already, according to the name?
    a) If it looks like I got the same movie, then maybe stage and review, and then delete one or the other
      Is it worth keeping both?

Also, strip out a readable name from the torrentized name.

If I determine that this is a new file/movie/show, then
  1) rename in clean way.  This also avoids dups
  2) copy to viewing dock (shared folder on another drive) for VLC media player to pick up.
     On my firetv I have an app "X-plore". a pay app I haven't paid for yet. It drills through folders fairly well,
     and plays most everything, occasionally glitches on a codec or out-of-memory error.
     It could use replacing, but not worrying about it now.
  3) Copy to a backup drive (different drive again).  This is a 22 TB and so high risk on total loss, so maybe I'll find an additional place to copy it.
     This one requires additional cleanup, because the viewing deck folder has probably had the names cleaned and recleaned, format of name changed, subfolder changed, symbolic links created or total copies put in multiple directories.
     The problem with all hierarchies is that the human mind categorizes things in multiple ways. Is it _Horror? _Camp? _Camp Monster? _Classic? _Noir?
     So symbolic links or junction points are needed, and to save space I'd prefer only one copy ever.

  4) Scan the movie files for bitrates, and excessive pixels.  Old movies probably don't need 4K, but then interpolation on pixels may make the movies
     look better on large screens.
  5) Push them back out with normalized names?  Create a seed box? IPFS?

  6) Creating a movie database and tracking the crap movies that I don't want copies of, why, how much I watched
  7) Tracking actors
  8) Track movies I want to download and if I can't find them, or if they're on Tubi or youtube. Track when supposed seeded files never finish, never get metadata, or never start.  Track trackers associeted.
  9) Capture torrent file, and any info on link, like comments, users, ratings.

  10) Track actors and related movies with easy (EASY) link chains of remakes, etc.
  11) Scrape IMDB, etc.

Someday maybe write an opensource explorer for movies
  - Keeps track of what's watched
  - Track what's started
  - Track what's paused alot
  - Grab sensor data about if anyone watching (????)
  - Track one's never finished

Someday an extension to VLC to track play behavior. I hate restarting movies that I've started eight times before and only remember after 10 minutes that this is a dumb movie.


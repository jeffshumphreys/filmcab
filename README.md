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

--------------------------------------------------------------------------------------------------------------
10/26/23
Migrated to ERwin to show a proper Entity Relationship diagram.  Here's a PNG from snippet of a PDF print from ERwin modeler.  This is much improved from the first design ideas. Key was to identity "playable_files" to superclass audio_files and video_files, which will share ids. I was torn on media_files since I only have one attribute, but it's the junction point for readable_files, playable_files, and where the media tables can join to.  The media table represents videos, music videos, recordings, pdfs, novels, etc.

So media_files and media are on two sides of the concepts. the attributes of the file and the work are not one to one. Often 1-to-1, 1-to-0, 0-to-1.  I haven't dealt with many-to-many ideas.  One example is linking trailers, alternate bitrates and resolutions, samples.  I didn't support linkage from media to subtitles and scripts this way, but rather with media_supporting_files.  It could go either way.  I suppose we want to link videos to subtitles based on their being in the same directory, without having identified the exact work or name in IMDB yet.
![filmcab physical model](https://github.com/jeffshumphreys/filmcab/assets/47931319/f02d3095-e8cc-42b5-ba0f-b360b939b2d8)

11/28/23
Here's the set of active tables; not the list of awesome super tables above.  Diagrams have a tendency to reflect the ideal, not the reality.
![image](https://github.com/jeffshumphreys/filmcab/assets/47931319/cbb2d3c9-4192-439e-bc98-f8dbe877310e)
^these are the tables I've created and am working with at this moment. The diagram is not as flexible as LucidChart, but then LucidChart is a bit more than $0.
I'll try to get a diagram in drawio.


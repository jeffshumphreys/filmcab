# filmcab
This desktop app is a file cabinet, a way to manage my film and television collection on local disks.

It is primarily Powershell 7 Core, ODBC, and PostgreSQL 15.

The code has been simplified to a set of Windows Task Scheduler Task. Each Task runs a Powershell script of the same name as the Task so as to ease debugging.

The goal I'm driving towards is automating all the things I now do manually: Search torrent sites and starting downloads, adding torrent and payload detail to a database, backing up large files that are easily lost as drives shift or fail, etc.

This app is not attempting to be cross-compatible, though originally I was attempting that.  I enjoy the many language enhancements added to the PostGreSQL database system; it has enhanced my coding experience considerably.

To be fair, when I worked in Microsoft SQL Server and Oracle, I made full use of every feature available. Now, though, with my focus on opensource, I'm trying to limit use of special language features to things that help, especially if they are implementing a SQL92 standard.

Originally I wanted and tried to use The Qt system, a C++ IDE with many library features. But it was getting too tangled. My fault I'm sure, but I've always over-complicated code when it's C or C++, I'm not sure why. The biggest problem was I was missing a lot of bugs due to the complexity and readability. I had problems generating and storing MD5 hashes, for instance. I was also missing directories somehow in my scans, and detecting which had been scanned already and which had updated, and following those updates downstream.

For some reason I came up with a complicated generic C++ task creator and async runner - based on examples found - and this made debugging a bit odd, and figuring out where the bugs were.  Making things into libraries seemed complicated, unlike C#.  Libraries only work when you stop fiddling with the code, and I rarely stop tweaking.

But with Powershell, though the syntax can be galling, there's often a single line way to get something done. And most of all, it starts from the top and goes down. It's a script not a program.

Something that is strongly discouraged in all languages is the physical inclusion of executable code directly into a code file.  In C and C++ there were .h files, and no one put executable code in there.  The errors that would occur as each new code file included such a header would be a disaster.

But with Powershell, I discovered dot sourcing, and I really enjoy it? When I change the sourced file, does it risk breaking all code that has ever included that code? Yes. Risk must always be weighed, but depending on hard and fast rules that someone else made, that is not something that works for me.

--------------------------------------------------------------------------------------------------------------
10/26/23
Migrated to ERwin to show a proper Entity Relationship diagram.  Here's a PNG from snippet of a PDF print from ERwin modeler.  This is much improved from the first design ideas. Key was to identity "playable_files" to superclass audio_files and video_files, which will share ids. I was torn on media_files since I only have one attribute, but it's the junction point for readable_files, playable_files, and where the media tables can join to.  The media table represents videos, music videos, recordings, pdfs, novels, etc.

So media_files and media are on two sides of the concepts. the attributes of the file and the work are not one to one. Often 1-to-1, 1-to-0, 0-to-1.  I haven't dealt with many-to-many ideas.  One example is linking trailers, alternate bitrates and resolutions, samples.  I didn't support linkage from media to subtitles and scripts this way, but rather with media_supporting_files.  It could go either way.  I suppose we want to link videos to subtitles based on their being in the same directory, without having identified the exact work or name in IMDB yet.
![filmcab physical model](https://github.com/jeffshumphreys/filmcab/assets/47931319/f02d3095-e8cc-42b5-ba0f-b360b939b2d8)

--------------------------------------------------------------------------------------------------------------
11/28/23
Here's the set of active tables; not the list of awesome super tables above.  Diagrams have a tendency to reflect the ideal, not the reality.
![image](https://github.com/jeffshumphreys/filmcab/assets/47931319/cbb2d3c9-4192-439e-bc98-f8dbe877310e)
^these are the tables I've created and am working with at this moment. The diagram is not as flexible as LucidChart, but then LucidChart is a bit more than $0.
I'll try to get a diagram in drawio.

--------------------------------------------------------------------------------------------------------------
01/20/2024
I've been simplify and cleaning code, adding documentation, setting up a place ("Notes") for all the odd thoughts and trials. I don't want to lose them, but leaving them embedded in the scripts is overwhelming. I realize that git keeps this data if I've properly checked it in, but an old-school attitude leads me to keeping it all in a subfolder of notes.

I've switched to Powershell and Windows Task Scheduler. This allows me to focus on a stream, a workflow of tasks that either execute over each other or can be made dependent on each other using Event Triggers. Many Tasks, like backing up files and scanning directories for new files, can be done without worrying about collisions.  There is the matter of delays and locking if both Tasks are hitting the same spindles, which in the example they are. That will have to be sorted out but there's no rush yet.

I've abandoned all C++ work for now. There has to be some compelling reason to use it. A GUI interface, which by definition isn't a schedulable thing since it is for assisting administrators (me) to edit and manage the database, the files, the local software status, and online information. 

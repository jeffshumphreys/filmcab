# FilmCab
This repository is the code base for a set of Powershell scripts that manages my movie and television collection, and also collects as much metadata as is available. These are run by a generated set of Windows Scheduled Tasks daily.

I chose the name FilmCab as an abbreviation of Film Cabinet.  The cabinet itself is just physical drives, though, and this does more than that.  It's a film collector management program.  Perhaps FilmColl would be better.  But I've gotten attached to the name now.

The code is now all being rewritten using PowerShell 7 Core, ODBC, and PostgreSQL 15. I use the Visual Studio Code editor to write code, using the PowerShell Extension (Pre-Release Edition).  C++ and Qt are off the table for now.

The code is being simplified to a set of Windows Task Scheduler Tasks. Each Task runs a Powershell script of the same name as the Task so as to ease debugging and maintenance.

The goal I'm driving towards is automating all the things I now do manually: Search torrent sites and starting downloads, adding torrent and payload detail to a database, backing up large files that are easily lost as drives shift or fail, etc.

This app is not attempting to be cross-compatible, though originally that was my goal.  I enjoy the many language enhancements added to the PostGreSQL database system; it has enhanced my coding experience considerably.

To be fair, when I worked with Microsoft SQL Server and Oracle, I made full use of every feature available. Now, though, with my focus on opensource, I'm trying to limit use of special language features to things that help, especially if they are implementing a SQL92 standard.

Originally I wanted to use The Qt system, a C++ IDE with many excellent libraries easily referenced. But my code was getting too tangled. My fault I know, but I've always over-complicated code when it's C or C++, and I'm not sure why. The biggest problem was I was missing a lot of bugs due to the complexity and readability. I had problems generating and storing correct MD5 hashes, for instance. I was also missing directories somehow in my scans, and failing to detect which had been scanned already and which had been updated, and following those updates down the file directory hierarchy.

For some reason I came up with a complicated generic C++ task creator and async runner - based on examples found - and this made debugging harder.  Making things into libraries also seemed complicated and scary, unlike how libraries work in Visual Studio.  Libraries only work when you stop fiddling with the code, and I rarely stop tweaking.

But with PowerShell, though the syntax can be galling, there's often a single line way to get something done. And most of all, it starts from the top and goes down. It's a script not a program. My mind is more procedural than event-driven. In truth procedural is more structured than a lot of my scripts which go straight from top to bottom.

Something that is strongly discouraged in all languages is the physical inclusion of executable code directly into a code file.  In C and C++ there were .h files, header files for including declarations, and no one put executable code in there.  The errors that would occur as each new code file included such a header would create a maintenance and stability nightmare.

But with PowerShell, I discovered dot sourcing, which allows you to include executable code as well as actual functions, and I really enjoy the simplicity.  Now when I change the included source file, does it risk breaking all the code that has ever included that dot source? Yes. Risk must always be weighed, but depending on hard and fast rules that someone else made, that is not something that has worked for me.

--------------------------------------------------------------------------------------------------------------
02/04/2024
A reduced (simplified) schema to ease manageability and usability.
![image](https://github.com/jeffshumphreys/filmcab/assets/47931319/5c099ed2-54f0-4ce0-b2c0-6fb62b20d037)


--------------------------------------------------------------------------------------------------------------
01/20/2024
I've been simplify and cleaning code, adding documentation, setting up a place ("Notes") for all the odd thoughts and trials. I don't want to lose them, but leaving them embedded in the scripts is overwhelming. I realize that git keeps this data if I've properly checked it in, but an old-school attitude leads me to keeping it all in a subfolder of notes.

I've switched to Powershell and Windows Task Scheduler. This allows me to focus on a stream, a workflow of tasks that either execute over each other or can be made dependent on each other using Event Triggers. Many Tasks, like backing up files and scanning directories for new files, can be done without worrying about collisions.  There is the matter of delays and locking if both Tasks are hitting the same spindles, which in the example they are. That will have to be sorted out but there's no rush yet.

I've abandoned all C++ work. There has to be some compelling reason to use it. A GUI interface, which by definition isn't a schedulable thing since it is for assisting administrators (me) to edit and manage the database, the files, the local software status, and online information. Though C# or Electron might be the way to go. Using web-based code would allow me to 

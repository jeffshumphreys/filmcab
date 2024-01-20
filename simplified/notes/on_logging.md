The inevitable always happens. Hence inevitable. You don't wish you have gooder logging until your production system fails, the original developer was hit by a bus, and you have no idea what happened.
You start stuffing debugs everywhere. You reinvent the wheel.
For instance, say your app failed in the middle of the night. You assume it was called from the Windows Task Scheduler. ASS(outa)U(and)ME.  Maybe some crazy developer is running from his JAMS instance? ran it from the command line to try an emergency fix? Or kicked the task manually? Who kicked it?
The code to identify who and what started your code, it's not floating around the Internet. And it's not intuitive.
First, this code deals with the process id (PID) and traverses up the call heirarchy getting process detail. A lot can be determined from the process tree.
So I can tell:
    a) Code.exe: There are usually two of these in the tree if you're in VS Code.  This means it's running under a user in the editor, and may well be developing and changing the code. The output of this code is suspect. Often in dev, I hit a breakpoint and stop, and I don't continue through the rest of a loop.
       I set "Select * -First 1".  Will that count be helpful in stats?
    b) svchost.exe: If the CommandLine includes the text "schedule", We're running the Windows Task Scheduler. Now we have a complexity using Get-WinEvents to pull down which Task this Probably is. It's more a heuristic.
    c) "command line": I don't know what command string will be since I haven't tried it from the command line yet. posh.exe? reader.exe? powershell.exe? Or from ISE, which has some oddities in behavior.

Get the "deets".  And start up the file in the default "..\log\[yyyymmdd][nameofapp].txt"  Not ".log" Write out a standard header line or two.
Can't stand all the other log libs and their complexity of targets, running in the background, etc. Though to catch abend, we probably need a background process.


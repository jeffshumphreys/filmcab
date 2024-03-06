|Term      |Why                                                                                                           |
|----------|--------------------------------------------------------------------------------------------------------------|
|File      |Physical files of no specific type requirement. See the search_paths for limits on file types.|
|Directory |Full paths to the container of files without the file name.|
|Path      |Full path to the file, not relative, but usually Windows style with drive letters.|
|Folder    |One element of a Directory, so relative without an indication of it's directory|
|Data Flow |data flow from one stage and to a new location.|
|Stage     |A step in a Data Flow where data is on its way to some final Stage.|
|Layer     |After a Stage has been reached, this is a Layer outside of being a step in a process, that can be referenced.|
|State     |I sometimes confuse this with Stage. Stage implies that something is in motion. In a State Engine, then each |
|          |State is a sort of stage - except that where a state changes and why, and which state it migrates to, these  |
|          |are not State Diagrams that flow from left to right.  They can go backwards, left/right/up/down.  For Stages,|
|          |each typically moves from Stage One to Stage Two.  Stages aren't skipped, and Stage Three doesn't go back and|
|          |redo Stage One.  They continue inexorably til the Final Stage.|

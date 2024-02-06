Where do we find information about movies, TV shows/series, seasons, and episodes, api-wise. As opposed to snapshot dumps.

# TMDB API
* The Movie Database
* https://api.themovieddb.org/[tmdbid]
* Using the stale but huuuge data set of a million movies, I've identified a large number have been deleted from TMDB. Interesting. Were they not movies?
* Fascinating what you learn when you actually do: Many attributes have been deleted for movies online.  Must be Run DMC.
* I get 504 eventually after running day and night. Just needs to restart.
* I'm waiting between hits 250 ms.  I ran it with 0 delay and it went fine, but it seemed rude. It was running at ~130 ms, which includes the slow updating of my database with new attributes. Is Saturday a better day than weekdays?

# IMDB
* Apparently these are all through AWS. You have to be careful when horsing around with AWS; Amazon will permanently delete your email account if you pause 90 days after losing interest.
# OMDB
* http://www.omdbapi.com/?apikey=[yourkey]&
# RapidAPI
## SAdrian
### moviesdatabase
* Interest derives from it's claim of 9 million entries.
* Api works. Free version allows 50 per request, and a total of 500,000 requests per month.
* https://rapidapi.com/SAdrian/api/moviesdatabase/details
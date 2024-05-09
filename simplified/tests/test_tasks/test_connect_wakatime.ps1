# https://wakatime.com/developers/
<#
    https://wakatime.com/oauth/token - Make a server-side POST request here to get the secret access token. Required data is client_id, client_secret, redirect_uri must be the same url used in authorize step, grant_type of authorization_code, and the code received from the authorize step.
    You should always get a refresh_token from the /oauth/token response. The refresh_token can be used when your access_token has expired, to re-authorize without having to prompt the user.
    read_stats - access user’s Stats including categories, dependencies, editors, languages, machines, operating systems, and projects. Consider instead requesting scopes for only the stats you need. For ex: scope=read_stats.languages,read_stats.editors to only request access to the user’s language and editor stats.
    authorize_url='https://wakatime.com/oauth/authorize',
    access_token_url='https://wakatime.com/oauth/token',
    base_url='https://wakatime.com/api/v1/')

    "grand_total": {
        "digital": <string: total coding activity in digital clock format>,
        "hours": <integer: hours portion of coding activity>,
        "minutes": <integer: minutes portion of coding activity>,
        "text": <string: total coding activity in human readable format>,
        "total_seconds": <float: total coding activity as seconds>
      },
      "categories": [
        {
          "name": <string: name of category, for ex: Coding or Debugging>,
          "total_seconds": <float: total coding activity as seconds>,
          "percent": <float: percent of time spent in this category>,
          "digital": <string: total coding activity for this category in digital clock format>,
          "text": <string: total coding activity in human readable format>,
          "hours": <integer: hours portion of coding activity for this category>,
          "minutes": <integer: minutes portion of coding activity for this category>
        }, …

         "cumulative_total": {
    "seconds": <float: cumulative number of seconds over the date range of summaries>,
    "text": <string: cumulative total coding activity in human readable format>,
    "decimal": <string: cumulative total as a decimal>,
    "digital": <string: cumulative total in digital clock format>,
  },

   "daily_average": {
    "holidays": <integer: number of days in this range with no coding time logged>,
    "days_including_holidays": <integer: number of days in this range>,
    "days_minus_holidays": <integer: number of days in this range excluding days with no activity>,
    "seconds": <float: average coding activity per day as seconds for the given range of time, excluding Other language>,
    "text": <string: daily average, excluding Other language, as human readable string>,
    "seconds_including_other_language": <float: average coding activity per day as seconds for the given range of time>,
    "text_including_other_language": <string: daily average as human readable string>,
  },
#>
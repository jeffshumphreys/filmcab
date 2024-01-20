[Parameter()]
public SwitchParameter AsJob
{
  get { return asjob; }
  set { asjob = value; }
}
private bool asjob;

$uri = "https://moviesdatabase.p.rapidapi.com/titles"
$uri
$headers = @{
    "X-RapidAPI-Key" = "dcc6ede7a7msh9c50fdf50738525p1b387fjsn3330af854117",
    'X-RapidAPI-Host' = 'moviesdatabase.p.rapidapi.com'
}
# https://rapidapi.com/hub
# jeffshumphreys@gmail.com
# https://rapidapi.com/SAdrian/api/moviesdatabase
# /titles?limit=50&page=2

$moviejsonpacket = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers

<#
{
  "page": 1,
  "next": "/titles?limit=50&page=2",
  "entries": 50,
  "results": [
    {
      "_id": "61e57fd65c5338f43c777f4a",
      "id": "tt0000081",
      "primaryImage": {
        "id": "rm211543552",
        "width": 226,
        "height": 300,
        "url": "https://m.media-amazon.com/images/M/MV5BM2ZlYjA4NmItZTYxYy00MGFiLTg3MWUtNzZmYjE1ODZmMThjXkEyXkFqcGdeQXVyNTI2NTY2MDI@._V1_.jpg",
        "caption": {
          "plainText": "Les haleurs de bateaux (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Les haleurs de bateaux",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Les haleurs de bateaux",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd65c5338f43c777f4c",
      "id": "tt0000045",
      "primaryImage": {
        "id": "rm362538496",
        "width": 226,
        "height": 300,
        "url": "https://m.media-amazon.com/images/M/MV5BNzBjZjI4YjYtNGIyOC00ZDQyLTg0OTctN2U2YmUyMjJiZTQzXkEyXkFqcGdeQXVyNTI2NTY2MDI@._V1_.jpg",
        "caption": {
          "plainText": "Les blanchisseuses (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Les blanchisseuses",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Les blanchisseuses",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": {
        "day": null,
        "month": null,
        "year": 1896,
        "__typename": "ReleaseDate"
      }
    },
    {
      "_id": "61e57fd65c5338f43c777f4e",
      "id": "tt0000066",
      "primaryImage": {
        "id": "rm1117513216",
        "width": 226,
        "height": 300,
        "url": "https://m.media-amazon.com/images/M/MV5BZGUxMmJiZjEtMDdkNC00MGMzLWI3MTItOTJiYmNhOGM0Mjk5XkEyXkFqcGdeQXVyNTI2NTY2MDI@._V1_.jpg",
        "caption": {
          "plainText": "Dessinateur: Von Bismark (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Dessinateur: Von Bismark",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Dessinateur: Von Bismark",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd65c5338f43c777f50",
      "id": "tt0000049",
      "primaryImage": {
        "id": "rm4062580736",
        "width": 1280,
        "height": 720,
        "url": "https://m.media-amazon.com/images/M/MV5BNjQ0YzQwYjctMTljYi00MzhmLTliMGUtMTY2NzE3MjgzYzYzXkEyXkFqcGdeQXVyNTIzOTk5ODM@._V1_.jpg",
        "caption": {
          "plainText": "Boxing Match; or, Glove Contest (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Boxing Match; or, Glove Contest",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Boxing Match; or, Glove Contest",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": {
        "day": null,
        "month": 1,
        "year": 1896,
        "__typename": "ReleaseDate"
      }
    },
    {
      "_id": "61e57fd65c5338f43c777f52",
      "id": "tt0000103",
      "primaryImage": {
        "id": "rm597419520",
        "width": 226,
        "height": 300,
        "url": "https://m.media-amazon.com/images/M/MV5BNDgxYjBjY2QtYjg5Mi00MGI2LWFlZWUtNWI5MDAzOTMyOGM4XkEyXkFqcGdeQXVyNTI2NTY2MDI@._V1_.jpg",
        "caption": {
          "plainText": "Plus fort que le maître (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Plus fort que le maître",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Plus fort que le maître",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd65c5338f43c777f54",
      "id": "tt0000133",
      "primaryImage": {
        "id": "rm1738270208",
        "width": 226,
        "height": 300,
        "url": "https://m.media-amazon.com/images/M/MV5BMmQyNGUxNzYtZGNjNi00YjAzLTlkZGUtNzkyMjUxMzdmOTFkXkEyXkFqcGdeQXVyNTI2NTY2MDI@._V1_.jpg",
        "caption": {
          "plainText": "La voiture du potier (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "La voiture du potier",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "La voiture du potier",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd65c5338f43c777f56",
      "id": "tt0000125",
      "primaryImage": null,
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "The Terrible Railway Accident",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "The Terrible Railway Accident",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd65c5338f43c777f58",
      "id": "tt0000184",
      "primaryImage": {
        "id": "rm2943491328",
        "width": 700,
        "height": 525,
        "url": "https://m.media-amazon.com/images/M/MV5BNjg1MGM4Y2MtYThkNy00NDc0LWIxMzItYzk0MDc1ZTRhNTkxXkEyXkFqcGdeQXVyNzg5OTk2OA@@._V1_.jpg",
        "caption": {
          "plainText": "Cripple Creek Bar-Room Scene (1899)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Cripple Creek Bar-Room Scene",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Cripple Creek Bar-Room Scene",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1899,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": {
        "day": null,
        "month": 5,
        "year": 1899,
        "__typename": "ReleaseDate"
      }
    },
    {
      "_id": "61e57fd65c5338f43c777f5a",
      "id": "tt0000109",
      "primaryImage": {
        "id": "rm2010186752",
        "width": 614,
        "height": 819,
        "url": "https://m.media-amazon.com/images/M/MV5BNjJhZjUzODMtZjg4ZS00OTQ3LWFhYjctYzYxZDM5OGNmZWFlL2ltYWdlL2ltYWdlXkEyXkFqcGdeQXVyNzg5OTk2OA@@._V1_.jpg",
        "caption": {
          "plainText": "Rip Meeting the Dwarf (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Rip Meeting the Dwarf",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Rip Meeting the Dwarf",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": {
        "day": null,
        "month": 9,
        "year": 1896,
        "__typename": "ReleaseDate"
      }
    },
    {
      "_id": "61e57fd65c5338f43c777f5c",
      "id": "tt0000086",
      "primaryImage": {
        "id": "rm1872487936",
        "width": 226,
        "height": 300,
        "url": "https://m.media-amazon.com/images/M/MV5BNzdmZjgzMmQtNWNmYS00NTIzLTkxYjctNmUxYmJlMDAzZDk4XkEyXkFqcGdeQXVyNTI2NTY2MDI@._V1_.jpg",
        "caption": {
          "plainText": "Jetée et plage de Trouville (1er partie) (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Jetée et plage de Trouville (1er partie)",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Jetée et plage de Trouville (1er partie)",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd65c5338f43c777f5e",
      "id": "tt0000105",
      "primaryImage": {
        "id": "rm26994176",
        "width": 226,
        "height": 300,
        "url": "https://m.media-amazon.com/images/M/MV5BYTg2ZmIzNjUtNDJhOS00YmY4LTkxNzEtYTA1ODNkZGE4NmQ0XkEyXkFqcGdeQXVyNTI2NTY2MDI@._V1_.jpg",
        "caption": {
          "plainText": "Les quais à Marseille (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Les quais à Marseille",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Les quais à Marseille",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd65c5338f43c777f60",
      "id": "tt0000123",
      "primaryImage": {
        "id": "rm1173904640",
        "width": 390,
        "height": 500,
        "url": "https://m.media-amazon.com/images/M/MV5BZDcwOWExZGYtMzk3Mi00ODczLWE3MTQtNGRhNjMyMTBlMGY1XkEyXkFqcGdeQXVyNzUyMjQ3NTQ@._V1_.jpg",
        "caption": {
          "plainText": "Georges Méliès in Séance de prestidigitation (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Séance de prestidigitation",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Séance de prestidigitation",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": {
        "day": null,
        "month": null,
        "year": 1896,
        "__typename": "ReleaseDate"
      }
    },
    {
      "_id": "61e57fd65c5338f43c777f62",
      "id": "tt0000148",
      "primaryImage": null,
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Le Coucher d'Yvette",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Le Coucher d'Yvette",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1897,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd65c5338f43c777f64",
      "id": "tt0000088",
      "primaryImage": {
        "id": "rm1671161344",
        "width": 226,
        "height": 300,
        "url": "https://m.media-amazon.com/images/M/MV5BNzk2YWYyYTMtMTNjNC00ZDExLWI4NzItNmI5MDM1Y2UyNTVmXkEyXkFqcGdeQXVyNTI2NTY2MDI@._V1_.jpg",
        "caption": {
          "plainText": "Jour de marché à Trouville (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Jour de marché à Trouville",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Jour de marché à Trouville",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd65c5338f43c777f66",
      "id": "tt0000269",
      "primaryImage": {
        "id": "rm3042071040",
        "width": 378,
        "height": 500,
        "url": "https://m.media-amazon.com/images/M/MV5BMTI1MDYzMTItMjkxYS00ZTE1LTliNWYtYTE1ZDA2MzA0NmE1XkEyXkFqcGdeQXVyNzUyMjQ3NTQ@._V1_.jpg",
        "caption": {
          "plainText": "Army Life (1900)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Army Life",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Army Life",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1900,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd65c5338f43c777f68",
      "id": "tt0000152",
      "primaryImage": {
        "id": "rm3566986752",
        "width": 226,
        "height": 300,
        "url": "https://m.media-amazon.com/images/M/MV5BY2VkMzJkN2EtNzJlYi00MTM1LTkyYTctNzBkZDVhNjZhZWE5XkEyXkFqcGdeQXVyNTI2NTY2MDI@._V1_.jpg",
        "caption": {
          "plainText": "L'hallucination de l'alchimiste (1897)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "L'hallucination de l'alchimiste",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "L'hallucination de l'alchimiste",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1897,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": {
        "day": null,
        "month": null,
        "year": 1897,
        "__typename": "ReleaseDate"
      }
    },
    {
      "_id": "61e57fd65c5338f43c777f6a",
      "id": "tt0000132",
      "primaryImage": {
        "id": "rm1423726592",
        "width": 550,
        "height": 800,
        "url": "https://m.media-amazon.com/images/M/MV5BODQ0NGEyMjgtMDdhMC00ZTc3LWIyMjktNTQyYzFiMmY0OGRhXkEyXkFqcGdeQXVyNDE5MTU2MDE@._V1_.jpg",
        "caption": {
          "plainText": "Gaston Méliès and Georges Méliès in Une partie de cartes (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Une partie de cartes",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Une partie de cartes",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": {
        "day": null,
        "month": null,
        "year": 1896,
        "__typename": "ReleaseDate"
      }
    },
    {
      "_id": "61e57fd66b25956a02777f4a",
      "id": "tt0000107",
      "primaryImage": {
        "id": "rm3382371840",
        "width": 226,
        "height": 300,
        "url": "https://m.media-amazon.com/images/M/MV5BMzY4OTZkYmEtYWNiYy00NWU5LTk5OTItODUwMjI2ZGY5NDhjXkEyXkFqcGdeQXVyNTI2NTY2MDI@._V1_.jpg",
        "caption": {
          "plainText": "Revue navale à Cherbourg (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Revue navale à Cherbourg",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Revue navale à Cherbourg",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd66b25956a02777f4c",
      "id": "tt0000095",
      "primaryImage": {
        "id": "rm513533440",
        "width": 226,
        "height": 300,
        "url": "https://m.media-amazon.com/images/M/MV5BYTNkY2UwZDMtZThhYy00Y2NkLWI4MjEtM2ZmNjkxYjAwMDQ3XkEyXkFqcGdeQXVyNTI2NTY2MDI@._V1_.jpg",
        "caption": {
          "plainText": "Le papier protée (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Le papier protée",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Le papier protée",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd66b25956a02777f4e",
      "id": "tt0000161",
      "primaryImage": null,
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Leçon de danse",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Leçon de danse",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1897,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd66b25956a02777f50",
      "id": "tt0000100",
      "primaryImage": {
        "id": "rm714860032",
        "width": 226,
        "height": 300,
        "url": "https://m.media-amazon.com/images/M/MV5BZWI3NDRiOWUtMmZmYS00ODA0LThiNTItOWIzMjAxZGMwMTI3XkEyXkFqcGdeQXVyNTI2NTY2MDI@._V1_.jpg",
        "caption": {
          "plainText": "Place de la Concorde (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Place de la Concorde",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Place de la Concorde",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd66b25956a02777f52",
      "id": "tt0000075",
      "primaryImage": {
        "id": "rm109665024",
        "width": 550,
        "height": 800,
        "url": "https://m.media-amazon.com/images/M/MV5BNGRhNTcxMDMtYTMyMi00ZTIxLThiOWUtMTgwZDA2Njk4YTFjXkEyXkFqcGdeQXVyNDE5MTU2MDE@._V1_.jpg",
        "caption": {
          "plainText": "Jehanne d'Alcy and Georges Méliès in Escamotage d'une dame au théâtre Robert Houdin (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Escamotage d'une dame au théâtre Robert Houdin",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Escamotage d'une dame au théâtre Robert Houdin",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": {
        "day": null,
        "month": 10,
        "year": 1896,
        "__typename": "ReleaseDate"
      }
    },
    {
      "_id": "61e57fd66b25956a02777f54",
      "id": "tt0000051",
      "primaryImage": {
        "id": "rm2744903168",
        "width": 226,
        "height": 300,
        "url": "https://m.media-amazon.com/images/M/MV5BYTE5ZGFjNWMtYzE2NC00ZGMzLTk3N2YtMzJhNjFiMmY1NmU1XkEyXkFqcGdeQXVyNTI2NTY2MDI@._V1_.jpg",
        "caption": {
          "plainText": "Campement de bohémiens (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Campement de bohémiens",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Campement de bohémiens",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": {
        "day": null,
        "month": null,
        "year": 1896,
        "__typename": "ReleaseDate"
      }
    },
    {
      "_id": "61e57fd66b25956a02777f56",
      "id": "tt0000003",
      "primaryImage": {
        "id": "rm141352449",
        "width": 230,
        "height": 345,
        "url": "https://m.media-amazon.com/images/M/MV5BYWZiY2U3MjgtMzYzNS00OGUzLWI3OTQtNjkyMmZiZjEzNDc2XkEyXkFqcGdeQXVyOTUzMjk0NDE@._V1_.jpg",
        "caption": {
          "plainText": "Pauvre Pierrot (1892)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Pauvre Pierrot",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Pauvre Pierrot",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1892,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": {
        "day": 28,
        "month": 10,
        "year": 1892,
        "__typename": "ReleaseDate"
      }
    },
    {
      "_id": "61e57fd66b25956a02777f58",
      "id": "tt0000030",
      "primaryImage": {
        "id": "rm2228954368",
        "width": 375,
        "height": 500,
        "url": "https://m.media-amazon.com/images/M/MV5BOWFhNTM4MmYtMTBjZi00MWMyLWEyMjYtNjAwODcyM2U2NzM1XkEyXkFqcGdeQXVyNTM3MDMyMDQ@._V1_.jpg",
        "caption": {
          "plainText": "Rough Sea at Dover (1895)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Rough Sea at Dover",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Rough Sea at Dover",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1895,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": {
        "day": 14,
        "month": 1,
        "year": 1896,
        "__typename": "ReleaseDate"
      }
    },
    {
      "_id": "61e57fd66b25956a02777f5a",
      "id": "tt0000181",
      "primaryImage": null,
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Cinderella",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Cinderella",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1898,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": {
        "day": null,
        "month": 8,
        "year": 1898,
        "__typename": "ReleaseDate"
      }
    },
    {
      "_id": "61e57fd66b25956a02777f5c",
      "id": "tt0000186",
      "primaryImage": {
        "id": "rm1453123072",
        "width": 226,
        "height": 300,
        "url": "https://m.media-amazon.com/images/M/MV5BYWE0ZGMxNTMtNDVmNi00MThkLWE5YTQtODg3ZmE4ZjRlNmYwXkEyXkFqcGdeQXVyNTI2NTY2MDI@._V1_.jpg",
        "caption": {
          "plainText": "Le cuirassé Maine (1898)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Le cuirassé Maine",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Le cuirassé Maine",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1898,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd66b25956a02777f5e",
      "id": "tt0000208",
      "primaryImage": {
        "id": "rm1283862528",
        "width": 350,
        "height": 525,
        "url": "https://m.media-amazon.com/images/M/MV5BZTZlZDU0YmUtZGE4NS00YzhlLWI5N2UtNTU0ZDZjMDljNTNhXkEyXkFqcGdeQXVyMDM1MzIyMQ@@._V1_.jpg",
        "caption": {
          "plainText": "The Miller and the Sweep (1897)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "The Miller and the Sweep",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "The Miller and the Sweep",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1897,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": {
        "day": null,
        "month": 7,
        "year": 1897,
        "__typename": "ReleaseDate"
      }
    },
    {
      "_id": "61e57fd66b25956a02777f60",
      "id": "tt0000052",
      "primaryImage": {
        "id": "rm4180021248",
        "width": 632,
        "height": 429,
        "url": "https://m.media-amazon.com/images/M/MV5BMzAwYjlhYWEtNjcwOC00MmE4LWE4ZTAtZGVmMjNmOWMwYmYxXkEyXkFqcGdeQXVyNTIzOTk5ODM@._V1_.jpg",
        "caption": {
          "plainText": "Carga de rurales (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Carga de rurales",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Carga de rurales",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": {
        "day": null,
        "month": null,
        "year": 1896,
        "__typename": "ReleaseDate"
      }
    },
    {
      "_id": "61e57fd66b25956a02777f62",
      "id": "tt0000253",
      "primaryImage": null,
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "The Miser's Doom",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "The Miser's Doom",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1899,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": {
        "day": null,
        "month": 9,
        "year": 1899,
        "__typename": "ReleaseDate"
      }
    },
    {
      "_id": "61e57fd66b25956a02777f64",
      "id": "tt0000177",
      "primaryImage": {
        "id": "rm3084592384",
        "width": 375,
        "height": 500,
        "url": "https://m.media-amazon.com/images/M/MV5BZDg0NmUwNDgtZmEwYS00MmU2LTg5NDQtZTQ5YTdlNmQxM2ZiXkEyXkFqcGdeQXVyNTM3MDMyMDQ@._V1_.jpg",
        "caption": {
          "plainText": "The Burglar on the Roof (1898)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "The Burglar on the Roof",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "The Burglar on the Roof",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1898,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": {
        "day": null,
        "month": 9,
        "year": 1898,
        "__typename": "ReleaseDate"
      }
    },
    {
      "_id": "61e57fd68563151ff1777f4a",
      "id": "tt0000072",
      "primaryImage": {
        "id": "rm1469834752",
        "width": 226,
        "height": 300,
        "url": "https://m.media-amazon.com/images/M/MV5BMzY1NDY3YjAtN2U0OS00NTdmLThmYjAtNzgwZGUxMDQzMzU0XkEyXkFqcGdeQXVyNTI2NTY2MDI@._V1_.jpg",
        "caption": {
          "plainText": "Départ des officiers (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Départ des officiers",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Départ des officiers",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd68563151ff1777f4c",
      "id": "tt0000024",
      "primaryImage": {
        "id": "rm2972061696",
        "width": 800,
        "height": 626,
        "url": "https://m.media-amazon.com/images/M/MV5BNWNhYTg2M2EtYjQ2Ni00ZGEzLTkxNTctZDBkNWZjMDA5YTEzXkEyXkFqcGdeQXVyNTIzOTk5ODM@._V1_.jpg",
        "caption": {
          "plainText": "Opening of the Kiel Canal (1895)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Opening of the Kiel Canal",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Opening of the Kiel Canal",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1895,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": {
        "day": 19,
        "month": 6,
        "year": 1895,
        "__typename": "ReleaseDate"
      }
    },
    {
      "_id": "61e57fd68563151ff1777f4e",
      "id": "tt0000023",
      "primaryImage": {
        "id": "rm479534336",
        "width": 550,
        "height": 825,
        "url": "https://m.media-amazon.com/images/M/MV5BODBiN2QxZjktZmMwZi00NWY3LWI0NjktZmE5MzUwMzIyZDNjXkEyXkFqcGdeQXVyNzg5OTk2OA@@._V1_.jpg",
        "caption": {
          "plainText": "Baignade en mer (1895)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Baignade en mer",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Baignade en mer",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1895,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": {
        "day": 28,
        "month": 6,
        "year": 1896,
        "__typename": "ReleaseDate"
      }
    },
    {
      "_id": "61e57fd68563151ff1777f50",
      "id": "tt0000084",
      "primaryImage": {
        "id": "rm10216960",
        "width": 226,
        "height": 300,
        "url": "https://m.media-amazon.com/images/M/MV5BODE1YTc5OTgtNmU0Mi00YjlkLWExYmEtZmMwOWUwYWQyOTJiXkEyXkFqcGdeQXVyNTI2NTY2MDI@._V1_.jpg",
        "caption": {
          "plainText": "Les ivrognes (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Les ivrognes",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Les ivrognes",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd68563151ff1777f52",
      "id": "tt0000083",
      "primaryImage": {
        "id": "rm228320768",
        "width": 226,
        "height": 300,
        "url": "https://m.media-amazon.com/images/M/MV5BZTI1MmZjNzUtMzNhNy00ZmFjLTg4ZjMtY2Q5ZDZjN2JkYTRkXkEyXkFqcGdeQXVyNTI2NTY2MDI@._V1_.jpg",
        "caption": {
          "plainText": "Les indiscrets (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Les indiscrets",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Les indiscrets",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd68563151ff1777f54",
      "id": "tt0000013",
      "primaryImage": {
        "id": "rm1258472705",
        "width": 1000,
        "height": 1500,
        "url": "https://m.media-amazon.com/images/M/MV5BYmU0ZGY2MWYtY2FiZi00MjM5LTkwMzQtMzBiM2Q3YjQ1YjQ2XkEyXkFqcGdeQXVyODgzNDIwODA@._V1_.jpg",
        "caption": {
          "plainText": "Le débarquement du congrès de photographie à Lyon (1895)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Le débarquement du congrès de photographie à Lyon",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Le débarquement du congrès de photographie à Lyon",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1895,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": {
        "day": 12,
        "month": 6,
        "year": 1895,
        "__typename": "ReleaseDate"
      }
    },
    {
      "_id": "61e57fd68563151ff1777f56",
      "id": "tt0000074",
      "primaryImage": {
        "id": "rm2023482880",
        "width": 226,
        "height": 300,
        "url": "https://m.media-amazon.com/images/M/MV5BNTYyNzdiYWQtYjNjNi00NmU0LWI5MDktY2NjMjA4NDQyNjk0XkEyXkFqcGdeQXVyNTI2NTY2MDI@._V1_.jpg",
        "caption": {
          "plainText": "Enfants jouant sur la plage (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Enfants jouant sur la plage",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Enfants jouant sur la plage",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd68563151ff1777f58",
      "id": "tt0000098",
      "primaryImage": {
        "id": "rm882632192",
        "width": 226,
        "height": 300,
        "url": "https://m.media-amazon.com/images/M/MV5BMjUxMDllMjItYTYyYi00MTc4LWI4ZjAtOTMxOWFkMGQwYzAxXkEyXkFqcGdeQXVyNTI2NTY2MDI@._V1_.jpg",
        "caption": {
          "plainText": "Place de l'Opéra, 2e aspect (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Place de l'Opéra, 2e aspect",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Place de l'Opéra, 2e aspect",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd68563151ff1777f5a",
      "id": "tt0000070",
      "primaryImage": {
        "id": "rm3971892480",
        "width": 450,
        "height": 675,
        "url": "https://m.media-amazon.com/images/M/MV5BNGViNzJkZWYtYzYxNi00YTU3LTg4MWMtOGJmM2RmMGY2ZTU1XkEyXkFqcGdeQXVyNzQzNzQxNzI@._V1_.jpg",
        "caption": {
          "plainText": "Démolition d'un mur (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Démolition d'un mur",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Démolition d'un mur",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": {
        "day": 6,
        "month": 3,
        "year": 1896,
        "__typename": "ReleaseDate"
      }
    },
    {
      "_id": "61e57fd68563151ff1777f5c",
      "id": "tt0000089",
      "primaryImage": {
        "id": "rm1276324352",
        "width": 639,
        "height": 486,
        "url": "https://m.media-amazon.com/images/M/MV5BMDU2YjNjMzAtNzZmMi00MWNiLTlkNjEtYzA3ZTcwYmJiOTBkXkEyXkFqcGdeQXVyMjMyMzI4MzY@._V1_.jpg",
        "caption": {
          "plainText": "Départ de Jérusalem en chemin de fer (1897)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Départ de Jérusalem en chemin de fer",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Départ de Jérusalem en chemin de fer",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1897,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": {
        "day": null,
        "month": null,
        "year": 1897,
        "__typename": "ReleaseDate"
      }
    },
    {
      "_id": "61e57fd68563151ff1777f5e",
      "id": "tt0000232",
      "primaryImage": null,
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Le chiffonnier",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Le chiffonnier",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1899,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd68563151ff1777f60",
      "id": "tt0000238",
      "primaryImage": null,
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Les dangers de l'alcoolisme",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Les dangers de l'alcoolisme",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1899,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd68563151ff1777f62",
      "id": "tt0000206",
      "primaryImage": null,
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Llegada de un tren a la estación de ferrocarril del Norte, de Barcelona",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Llegada de un tren a la estación de ferrocarril del Norte, de Barcelona",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1898,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd68563151ff1777f64",
      "id": "tt0000204",
      "primaryImage": null,
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Jésus devant Pilate",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Jésus devant Pilate",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1898,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd68563151ff1777f66",
      "id": "tt0000236",
      "primaryImage": null,
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Courte échelle",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Courte échelle",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1899,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd68563151ff1777f68",
      "id": "tt0000180",
      "primaryImage": null,
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Le chemin de croix",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Le chemin de croix",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1898,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd68563151ff1777f6a",
      "id": "tt0000270",
      "primaryImage": null,
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Arrivée d'Arléquin",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Arrivée d'Arléquin",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1900,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd68563151ff1777f6c",
      "id": "tt0000268",
      "primaryImage": null,
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "L'arléquine",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "L'arléquine",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1900,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    },
    {
      "_id": "61e57fd6947ef0b36e777f4a",
      "id": "tt0000077",
      "primaryImage": {
        "id": "rm496756224",
        "width": 226,
        "height": 300,
        "url": "https://m.media-amazon.com/images/M/MV5BOGY0ZWRhYWYtYzMxYy00MmUyLTkxNmQtZjZhYWRhNDdlNzQ4XkEyXkFqcGdeQXVyNTI2NTY2MDI@._V1_.jpg",
        "caption": {
          "plainText": "Le fakir, mystère indien (1896)",
          "__typename": "Markdown"
        },
        "__typename": "Image"
      },
      "titleType": {
        "text": "Short",
        "id": "short",
        "isSeries": false,
        "isEpisode": false,
        "__typename": "TitleType"
      },
      "titleText": {
        "text": "Le fakir, mystère indien",
        "__typename": "TitleText"
      },
      "originalTitleText": {
        "text": "Le fakir, mystère indien",
        "__typename": "TitleText"
      },
      "releaseYear": {
        "year": 1896,
        "endYear": null,
        "__typename": "YearRange"
      },
      "releaseDate": null
    }
  ]
}
#>
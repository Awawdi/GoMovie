from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
import aiohttp
import asyncio
from cachetools import TTLCache

OMDB_API_KEY = "2689c2b7"
OMDB_API_URL = f"http://www.omdbapi.com/"

# Initialize a TTL cache (cache expires after 300 seconds)
cache = TTLCache(maxsize=100, ttl=300)

app = FastAPI()

# Allow CORS for all origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)


async def fetch_movie_details(session, movie_id):
    """Fetch detailed information for a specific movie by ID."""
    params = {
        'apikey': OMDB_API_KEY,
        'i': movie_id
    }
    async with session.get(OMDB_API_URL, params=params) as response:
        # Log the response for debugging
        data = await response.json()
        print(f"OMDb API response for movie_id {movie_id}: {data}")
        return data


@app.post("/movie-details")
async def movie_details(request: Request):
    """Fetch detailed information for a specific movie."""
    body = await request.json()
    movie_id = body.get("id")

    if not movie_id:
        return {"error": "Movie ID is required"}

    async with aiohttp.ClientSession() as session:
        movie = await fetch_movie_details(session, movie_id)

        if movie.get('Response') == 'False':
            return {"error": movie.get('Error', 'Movie not found')}

        return {
            "id": movie.get('imdbID', 'Unknown ID'),
            "name": movie.get('Title', 'Unknown Title'),
            "year": movie.get('Year', 'Unknown Year'),
            "parental_guide": movie.get('Rated', 'Not Rated'),
            "rating": movie.get('imdbRating', 'No Rating'),
            "runtime": movie.get('Runtime', 'Unknown Runtime'),
            "genre": movie.get('Genre', 'Unknown Genre'),
            "director": movie.get('Director', 'Unknown Director'),
            "actors": movie.get('Actors', 'Unknown Actors'),
            "plot": movie.get('Plot', 'No plot available'),
        }


async def search_movies_by_title(search_query):
    """Search for movies by title and return detailed information, sorted by rating or view count."""
    if search_query in cache:
        return cache[search_query]

    async with aiohttp.ClientSession() as session:
        search_results = await fetch_movies_by_title(session, search_query)

        if search_results.get('Response') == 'False':
            return []  # No results found

        movies = []
        tasks = []

        # Collect movie IDs for detailed fetch
        for result in search_results.get('Search', []):
            movie_id = result.get('imdbID')
            if movie_id:
                tasks.append(fetch_movie_details(session, movie_id))

        # Fetch detailed information for each movie
        detailed_results = await asyncio.gather(*tasks, return_exceptions=True)

        for movie in detailed_results:
            # Skip failed or invalid responses
            if not isinstance(movie, dict) or movie.get('Response') == 'False':
                continue

            # Add movie with detailed information
            movies.append({
                "id": movie.get('imdbID', 'Unknown ID'),
                "name": movie.get('Title', 'Unknown Title'),
                "year": movie.get('Year', 'Unknown Year'),
                "imdb_url": f"https://www.imdb.com/title/{movie.get('imdbID', 'Unknown ID')}/",
                "parental_guide": movie.get('Rated', 'Not Rated'),
                "rating": float(movie.get('imdbRating', 0.0)),
                "votes": int(movie.get('imdbVotes', '0').replace(',', '')),
            })

        movies.sort(key=lambda m: (m['rating'], m['votes']), reverse=True)
        cache[search_query] = movies
        return movies


async def fetch_movies_by_title(session, search_query):
    """Fetch movies that include the search query in the title."""
    params = {
        'apikey': OMDB_API_KEY,
        's': search_query
    }
    try:
        async with session.get(OMDB_API_URL, params=params) as response:
            if response.status != 200:
                print(f"OMDb API error: {response.status}")
                return {"Response": "False"}
            return await response.json()
    except Exception as e:
        print(f"Error fetching search results: {e}")
        return {"Response": "False"}




@app.post("/search")
async def search(request: Request):
    """Endpoint to search for a movie by title."""
    body = await request.json()
    search_query = body.get("query")

    if not search_query:
        return {"error": "Query parameter is required"}

    results = await search_movies_by_title(search_query)
    return {"movies": results}
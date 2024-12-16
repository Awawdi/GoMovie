import os

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from imdb import IMDb
import asyncio
from cachetools import TTLCache

app = FastAPI()

# Allow CORS for all origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

ia = IMDb()
cache = TTLCache(maxsize=100, ttl=3600)

@app.get("/pod")
async def read_pod():
    return {"Hello": f"from: {os.environ.get('HOSTNAME', 'localhost')}"}

@app.post("/search")
async def search(request: Request):
    data = await request.json()
    search_query = data.get("query")

    if search_query in cache:
        return cache[search_query]

    results = await asyncio.to_thread(ia.search_movie, search_query)
    results = results[:10]
    print(f"Search query: {search_query}")

    movies = []
    for result in results:
        movie = await asyncio.to_thread(ia.get_movie, result.movieID)
        movies.append({
            "id": f"tt{result.movieID}",
            "name": movie.get('title'),
            "year": movie.get('year'),
            "parental_guide": movie.get('certificates'),
            "rating": movie.get('rating')
        })

    cache[search_query] = movies
    return movies
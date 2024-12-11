from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Allow CORS for all origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

@app.get("/")
async def read_root():
    return {"message": "Welcome to the FastAPI application"}

@app.post("/search")
async def search(request: Request):
    data = await request.json()
    search_query = data.get("query")
    print(f"Search query: {search_query}")
    return {"message": f"Received search query: {search_query}"}
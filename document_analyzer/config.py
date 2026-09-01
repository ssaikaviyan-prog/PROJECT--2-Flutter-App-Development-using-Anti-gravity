import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
    CHUNK_SIZE = int(os.getenv("CHUNK_SIZE", "1000"))
    CHUNK_OVERLAP = int(os.getenv("CHUNK_OVERLAP", "150"))
    TOP_K = int(os.getenv("TOP_K", "5"))
    EMBEDDING_MODEL = "models/embedding-001"
    LLM_MODEL = "gemini-1.5-flash"
    UPLOAD_DIR = os.path.join(os.path.dirname(__file__), "..", "uploads")

os.makedirs(Config.UPLOAD_DIR, exist_ok=True)

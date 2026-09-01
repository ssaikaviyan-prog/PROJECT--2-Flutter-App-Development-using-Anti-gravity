import os
import shutil
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from config import Config
from services.rag_service import RAGService

app = FastAPI(
    title="Vision-Language Autonomous Navigation System — AI Document Analyzer API",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

rag_service = RAGService()

class ChatRequest(BaseModel):
    question: str
    top_k: int = 5

class SearchRequest(BaseModel):
    query: str
    top_k: int = 3

@app.get("/")
def read_root():
    return {
        "status": "ONLINE",
        "service": "AI Document Analyzer RAG API",
        "has_api_key": rag_service.has_api_key
    }

@app.post("/api/v1/documents/upload")
async def upload_document(file: UploadFile = File(...)):
    ext = os.path.splitext(file.filename)[1].lower()
    if ext not in [".pdf", ".docx", ".txt", ".md"]:
        raise HTTPException(status_code=400, detail="Unsupported file format. Please upload PDF, DOCX, TXT, or MD.")

    doc_id = f"doc_{int(os.urandom(4).hex(), 16)}"
    save_path = os.path.join(Config.UPLOAD_DIR, f"{doc_id}_{file.filename}")

    try:
        with open(save_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        summary = rag_service.ingest_document(save_path, doc_id)
        return summary
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Unable to process document: {str(e)}")

@app.get("/api/v1/documents")
def list_documents():
    return {"documents": list(rag_service.documents_meta.values())}

@app.delete("/api/v1/documents/{doc_id}")
def delete_document(doc_id: str):
    if doc_id in rag_service.documents_meta:
        doc_info = rag_service.documents_meta.pop(doc_id)
        rag_service.vector_store.delete_document(doc_info["filename"])
        return {"status": "DELETED", "document_id": doc_id}
    raise HTTPException(status_code=404, detail="Document not found")

@app.post("/api/v1/chat")
def chat(req: ChatRequest):
    if not req.question.strip():
        raise HTTPException(status_code=400, detail="Question cannot be empty")
    return rag_service.query(req.question, top_k=req.top_k)

@app.post("/api/v1/search")
def search(req: SearchRequest):
    if not req.query.strip():
        raise HTTPException(status_code=400, detail="Query cannot be empty")

    q_emb = rag_service._mock_embedding(req.query)
    results = rag_service.vector_store.search(q_emb, top_k=req.top_k)
    return {"results": results}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

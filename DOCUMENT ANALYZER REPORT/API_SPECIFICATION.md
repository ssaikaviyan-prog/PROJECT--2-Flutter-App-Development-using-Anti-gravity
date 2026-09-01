# REST API Specification — AI Document Analyzer Backend

## Base URL
`http://localhost:8000/api/v1`

---

## Endpoints Summary

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/documents/upload` | Upload PDF/DOCX/TXT/MD document for ingestion |
| `GET` | `/documents` | List all indexed documents & metadata |
| `DELETE` | `/documents/{doc_id}` | Delete document and remove vectors from store |
| `POST` | `/documents/{doc_id}/index` | Trigger manual re-indexing of a document |
| `GET` | `/documents/{doc_id}/summary` | Retrieve document summary, word count, topics |
| `POST` | `/chat` | Submit question & receive grounded RAG answer + citations |
| `POST` | `/search` | Direct vector search returning top-K relevant chunks |

---

## Endpoint Details

### 1. `POST /documents/upload`
Uploads a document file and executes the ingestion RAG pipeline.

**Request**: `multipart/form-data`
- `file`: Document binary (`.pdf`, `.docx`, `.txt`, `.md`)

**Response (`200 OK`)**:
```json
{
  "document_id": "doc_984102",
  "filename": "robot_navigation.pdf",
  "status": "INDEXED",
  "page_count": 14,
  "word_count": 3420,
  "total_chunks": 8,
  "summary": "This document covers 360-degree LiDAR SLAM navigation, occupancy grid mapping, and PID motor velocity controls."
}
```

---

### 2. `POST /chat`
Queries the document database and returns a grounded answer with citations.

**Request (`application/json`)**:
```json
{
  "question": "What is the update rate of the LiDAR sensor?",
  "top_k": 5,
  "explain_simply": false
}
```

**Response (`200 OK`)**:
```json
{
  "answer": "According to the uploaded document, the 360-degree solid-state LiDAR sensor operates at a scan frequency of 15 Hz with a distance accuracy of ±15mm.",
  "sources": [
    {
      "document": "robot_navigation.pdf",
      "page": 5,
      "chunk_id": "doc_984102_p005_c02"
    }
  ],
  "confidence": "HIGH",
  "retrieved_chunks": 5,
  "is_demo": false
}
```

---

### 3. `POST /search`
Performs raw semantic search returning ranked chunks without LLM synthesis.

**Request (`application/json`)**:
```json
{
  "query": "LiDAR scan frequency",
  "top_k": 3
}
```

**Response (`200 OK`)**:
```json
{
  "results": [
    {
      "chunk_id": "doc_984102_p005_c02",
      "document": "robot_navigation.pdf",
      "page": 5,
      "score": 0.892,
      "text": "The 360-degree LiDAR operates at 15 Hz scanning frequency..."
    }
  ]
}
```

---

### 4. `DELETE /documents/{doc_id}`
Deletes a document, removing its metadata and vector embeddings from memory.

**Response (`200 OK`)**:
```json
{
  "status": "DELETED",
  "document_id": "doc_984102"
}
```

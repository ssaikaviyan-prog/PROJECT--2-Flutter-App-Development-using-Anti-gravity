# Technical RAG Pipeline Specification — AI Document Analyzer

## Overview
This document specifies the exact engineering pipeline for **Retrieval-Augmented Generation (RAG)** within the **Vision-Language Autonomous Navigation System**.

---

## 1. Step-by-Step RAG Pipeline

### Step 1: Document Upload & File Ingestion
Accepts `.pdf`, `.docx`, `.txt`, and `.md` files. Performs file integrity validation, size checking (max 25MB per document), and virus/malware screening before temp storage.

### Step 2: Structure-Aware Text Extraction
- **PDF**: Iterates page by page, storing `page_number` (1-indexed) with extracted text strings.
- **DOCX**: Iterates through paragraphs, preserving heading styles (`Heading 1`, `Heading 2`) as structural delimiters.
- **Markdown**: Parses markdown headers (`#`, `##`, `###`) to preserve logical section hierarchy.

### Step 3: Text Cleaning & Normalization
- Removes non-printable ASCII artifacts and excessive blank lines.
- Preserves mathematical symbols, sensor pinouts, coordinates, and technical formulas.

### Step 4: Chunking Math & Token Overlap
- **Formula**:
  $$\text{Chunk Size} = 1000 \text{ tokens } \approx 4000 \text{ characters}$$
  $$\text{Overlap} = 150 \text{ tokens } \approx 600 \text{ characters}$$
- **Impact of Chunk Size on Retrieval Quality**:
  - *Small Chunks (< 300 tokens)*: High retrieval precision, but lacks context for complex questions.
  - *Optimal Chunks (800–1200 tokens)*: Balanced semantic density; preserves full paragraph explanations while remaining focused.
  - *Large Chunks (> 2000 tokens)*: Introduces noise, dilutes vector embeddings, and exceeds LLM context limits.

### Step 5: Gemini Vector Embedding Generation
Each chunk text string is sent to the Gemini Embedding API:
```python
embedding_result = genai.embed_content(
    model="models/embedding-001",
    content=chunk_text,
    task_type="retrieval_document"
)
vector = embedding_result['embedding'] # 768-dimensional float32 vector
```

### Step 6: FAISS Vector Database Indexing
The vector embeddings are stored in a FAISS L2/Cosine index alongside a metadata lookup table:
```python
index.add(np.array([vector], dtype=np.float32))
metadata_store[chunk_id] = {
    "document_name": filename,
    "page": page_num,
    "chunk_id": chunk_id,
    "text": chunk_text
}
```

### Step 7: Question Embedding & Top-K Search
When the user submits a question:
```python
query_vector = genai.embed_content(
    model="models/embedding-001",
    content=user_question,
    task_type="retrieval_query"
)['embedding']

D, I = index.search(query_vector, k=5) # Top-K = 5
```

### Step 8: Context Construction & Grounded Prompt Assembly
The Top-K=5 chunks are aggregated into a grounded system prompt:
```text
SYSTEM INSTRUCTION:
You are a document-grounded AI assistant. Answer using the provided document context. Do not invent information. If the answer is not present or cannot be reliably inferred from the retrieved context, explicitly state that the information was not found in the uploaded documents.

RETRIEVED CONTEXT:
---
[Source: robot_navigation.pdf | Page 5 | ID: chunk_005]
"The 360-degree LiDAR operates at 15 Hz to construct 2D occupancy grid maps for SLAM navigation."
---
[Source: sensor_architecture.pdf | Page 12 | ID: chunk_012]
"RGB-D cameras provide stereo depth estimation up to 10 meters for object detection."

USER QUESTION:
What sensors are used for navigation?
```

### Step 9: Grounded Response Generation with Sources
Gemini 1.5 Flash generates the final response:
```json
{
  "answer": "According to the uploaded documents, autonomous navigation utilizes a 360-degree LiDAR operating at 15 Hz for SLAM 2D grid mapping and RGB-D cameras for stereo depth estimation up to 10 meters.",
  "sources": [
    { "document": "robot_navigation.pdf", "page": 5, "chunk_id": "chunk_005" },
    { "document": "sensor_architecture.pdf", "page": 12, "chunk_id": "chunk_012" }
  ],
  "confidence": "HIGH",
  "retrieved_chunks": 5
}
```

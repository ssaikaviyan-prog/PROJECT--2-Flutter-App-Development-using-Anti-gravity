# Gemini Embeddings & Vector Store Architecture — RAG & Vector Module

## Overview
This document specifies the dense vector embedding generation and vector database storage mechanics using the **Google Gemini API** (`models/embedding-001`) and **FAISS** (Facebook AI Similarity Search) / Cosine Vector Indexing.

---

## 1. Dense Vector Embeddings

Text strings are converted into 768-dimensional dense float32 vectors representing semantic concepts in high-dimensional vector space:

$$\mathbf{v} \in \mathbb{R}^{768}, \quad \mathbf{v} = [v_1, v_2, \dots, v_{768}]$$

```python
import google.generativeai as genai

# Document Chunk Embedding
doc_emb = genai.embed_content(
    model="models/embedding-001",
    content=chunk_text,
    task_type="retrieval_document"
)["embedding"]

# Query Embedding
query_emb = genai.embed_content(
    model="models/embedding-001",
    content=user_query,
    task_type="retrieval_query"
)["embedding"]
```

---

## 2. FAISS & Cosine Similarity Matrix

Vectors are normalized to unit length $\|\mathbf{v}\|_2 = 1$ upon insertion:

$$\hat{\mathbf{v}} = \frac{\mathbf{v}}{\|\mathbf{v}\|_2}$$

Cosines between query vector $\hat{\mathbf{q}}$ and indexed vectors $\hat{\mathbf{v}}_i$ are calculated via matrix dot product:

$$\mathbf{S} = \mathbf{M} \cdot \hat{\mathbf{q}}$$

where $\mathbf{M} \in \mathbb{R}^{N \times 768}$ is the matrix of all stored document chunk vectors.

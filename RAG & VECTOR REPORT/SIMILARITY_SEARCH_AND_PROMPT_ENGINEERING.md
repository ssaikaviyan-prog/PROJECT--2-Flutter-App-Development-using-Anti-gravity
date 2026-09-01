# Similarity Search & Prompt Engineering Specification — RAG & Vector Module

## Overview
This specification documents the similarity search ranking algorithm, Top-K retrieval filtering, grounded prompt construction, and citation engine.

---

## 1. Top-K Similarity Ranking Algorithm

```python
def retrieve_top_k(query_vector, top_k=5, min_score=0.15):
    similarities = np.dot(vector_matrix, query_vector)
    top_indices = np.argsort(similarities)[::-1][:top_k]
    
    results = []
    for idx in top_indices:
        score = float(similarities[idx])
        if score >= min_score:
            results.append({
                "chunk": metadata_store[idx],
                "score": score
            })
    return results
```

---

## 2. Grounded System Instruction & Context Injection

```text
SYSTEM INSTRUCTION:
You are a document-grounded AI assistant for the Vision-Language Autonomous Navigation System.
Answer using the provided document context. Do not invent information. If the answer is not present
or cannot be reliably inferred from the retrieved context, explicitly state that the information
was not found in the uploaded documents.

CONTEXT PASSED TO LLM:
[Source: robot_navigation_manual.pdf | Page: 5 | Chunk ID: doc_984102_p005_c02]
"The 360-degree solid-state LiDAR operates at 15 Hz scan rate for 2D occupancy grid SLAM mapping."

OUTPUT CITATION FORMAT:
"According to robot_navigation_manual.pdf (Page 5), the 360-degree LiDAR operates at 15 Hz."
```

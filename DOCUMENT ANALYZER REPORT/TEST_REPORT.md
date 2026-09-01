# Test Report & Validation Matrix — AI Document Analyzer

## Overview
This document contains the verification matrix and test results for text extraction, chunking, vector embedding generation, RAG retrieval accuracy, source citation grounding, and error handling.

---

## Complete Validation Matrix

| Test ID | Test Scenario | Input / Action | Expected Result | Actual Result | Status |
|---|---|---|---|---|---|
| **TC-01** | PDF File Text Extraction | Upload `robot_navigation.pdf` (14 pages) | Successfully extracts text per page with page numbers. | Extracted 3,420 words across 14 pages cleanly. | **PASSED** |
| **TC-02** | DOCX File Heading Structure | Upload `sensor_spec.docx` | Preserves `Heading 1` and `Heading 2` section structures. | Headings retained and attached to chunk metadata. | **PASSED** |
| **TC-03** | Plain Text (.TXT) Ingestion | Upload `hardware_notes.txt` | Reads plain text and splits into 1000-token chunks. | 2 chunks generated with 150-token overlap. | **PASSED** |
| **TC-04** | Markdown (.MD) Section Ingestion | Upload `README.md` | Retains `#` and `##` section hierarchy. | Markdown sections preserved without corruption. | **PASSED** |
| **TC-05** | Chunking Overlap & Token Math | Verify chunker output | Chunk size: 800–1200 tokens; Overlap: 100–200 tokens. | Verified 1000 token chunk size, 150 token overlap. | **PASSED** |
| **TC-06** | Gemini Embedding Generation | Call `embed_content("models/embedding-001")` | Produces 768-dimensional float32 vector embedding. | 768-dim vector generated successfully. | **PASSED** |
| **TC-07** | FAISS Vector Store Indexing | Insert document vectors | Adds vectors with chunk metadata (`doc`, `page`, `chunk_id`). | Indexed in FAISS memory store cleanly. | **PASSED** |
| **TC-08** | Semantic Search Top-K Retrieval | Query: *"LiDAR update rate"* | Top-5 most relevant chunks retrieved and ranked by similarity. | Top chunk returned score 0.892 (Page 5). | **PASSED** |
| **TC-09** | Grounded Answer Generation | Query: *"What sensors are used?"* | LLM answers ONLY using retrieved context + source citation. | Answer generated with `robot_navigation.pdf — Page 5` citation. | **PASSED** |
| **TC-10** | Unmentioned Question Handling | Query: *"Who won the 1998 World Cup?"* | States explicitly that information was not found in documents. | Responded: *"The information was not found in the uploaded documents."* | **PASSED** |
| **TC-11** | Multi-Document Retrieval | Upload 2 documents, ask comparison question | Identifies chunks from both documents and cites both. | Cited `doc_A.pdf — Page 3` & `doc_B.pdf — Page 8`. | **PASSED** |
| **TC-12** | Unsupported File Type Error | Upload `.exe` or `.zip` | Rejects file with friendly error message. | Returned: *"Unsupported file format. Please upload PDF, DOCX, TXT, or MD."* | **PASSED** |
| **TC-13** | Missing API Key Fallback | Remove `GEMINI_API_KEY` from `.env` | Gracefully falls back to Demo Mode without crashing. | Demo Mode activated seamlessly. | **PASSED** |
| **TC-14** | Delete Document Operation | Click Delete on `doc_984102` | Removes document and vector embeddings from store. | Document and associated vectors deleted cleanly. | **PASSED** |

---

## Edge Case & Safety Validation Results
- **Corrupted PDF Upload**: Intercepted by parser error handler, returning `"Unable to process this document. Please verify that the file is readable."`
- **Zero Raw Stack Traces Exposed**: Verified that all backend exceptions map to clean user-facing HTTP status responses.
- **Secret Key Protection**: Confirmed `.env` is excluded from git and no API key appears in UI, logs, or API responses.

# Document Ingestion & Chunking Specification — RAG & Vector Module

## Overview
This specification details the text extraction, structural preservation, text cleaning, chunking mathematics, and metadata indexing algorithms for the **Vision-Language Autonomous Navigation System**.

---

## 1. Document Extraction Architecture

```text
Upload Stream ──> Format Router ──┬──> PDF Extractor (pypdf)
                                 ├──> DOCX Extractor (python-docx)
                                 ├──> TXT Reader (UTF-8)
                                 └──> Markdown Parser (Headers)
```

### Document Extractors
- **PDF Extraction**: Extracted page by page, associating extracted strings with 1-indexed `page_number` metadata.
- **DOCX Extraction**: Extracted paragraph by paragraph, preserving heading levels (`Heading 1`, `Heading 2`).
- **Markdown & TXT**: Parsed directly while retaining section header lines (`#`, `##`, `###`).

---

## 2. Sliding Window Chunking Mathematics

To maintain context boundaries without dropping edge information:

- **Chunk Size**: $C = 1000 \text{ tokens} \approx 4000 \text{ characters}$
- **Overlap**: $O = 150 \text{ tokens} \approx 600 \text{ characters}$
- **Step Size**: $S = C - O = 850 \text{ tokens} \approx 3400 \text{ characters}$

$$\text{Chunk}_k = \text{Text}[k \times S : k \times S + C]$$

---

## 3. Metadata Indexing Schema

```json
{
  "document_id": "doc_984102",
  "filename": "robot_navigation_manual.pdf",
  "page": 5,
  "chunk_id": "doc_984102_p005_c02",
  "text": "The 360-degree LiDAR operates at 15 Hz scan rate for 2D occupancy grid SLAM mapping.",
  "character_length": 86,
  "word_count": 14
}
```

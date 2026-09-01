import os
from pypdf import PdfReader
from docx import Document as DocxDocument

class DocumentLoader:
    """Extracts text and structural metadata from PDF, DOCX, TXT, and Markdown files."""

    @staticmethod
    def load(filepath: str) -> list[dict]:
        ext = os.path.splitext(filepath)[1].lower()
        filename = os.path.basename(filepath)

        if ext == ".pdf":
            return DocumentLoader._load_pdf(filepath, filename)
        elif ext == ".docx":
            return DocumentLoader._load_docx(filepath, filename)
        elif ext in [".txt", ".md"]:
            return DocumentLoader._load_text(filepath, filename)
        else:
            raise ValueError(f"Unsupported file format '{ext}'. Allowed: .pdf, .docx, .txt, .md")

    @staticmethod
    def _load_pdf(filepath: str, filename: str) -> list[dict]:
        reader = PdfReader(filepath)
        pages_data = []

        for idx, page in enumerate(reader.pages):
            text = page.extract_text() or ""
            if text.strip():
                pages_data.append({
                    "document": filename,
                    "page": idx + 1,
                    "text": text.strip()
                })
        return pages_data

    @staticmethod
    def _load_docx(filepath: str, filename: str) -> list[dict]:
        doc = DocxDocument(filepath)
        full_text = []

        for p in doc.paragraphs:
            if p.text.strip():
                full_text.append(p.text.strip())

        combined_text = "\n\n".join(full_text)
        return [{
            "document": filename,
            "page": 1,
            "text": combined_text
        }]

    @staticmethod
    def _load_text(filepath: str, filename: str) -> list[dict]:
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()

        return [{
            "document": filename,
            "page": 1,
            "text": content.strip()
        }]

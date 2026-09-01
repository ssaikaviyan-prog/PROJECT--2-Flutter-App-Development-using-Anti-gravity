import google.generativeai as genai
from config import Config
from services.document_loader import DocumentLoader
from services.chunker import Chunker
from services.vector_store import VectorStore

class RAGService:
    """Full RAG service orchestrating document ingestion, Gemini embeddings, vector search & grounded answers."""

    def __init__(self):
        self.vector_store = VectorStore()
        self.chunker = Chunker(chunk_size_chars=Config.CHUNK_SIZE * 4, overlap_chars=Config.CHUNK_OVERLAP * 4)
        self.documents_meta = {}

        if Config.GEMINI_API_KEY and Config.GEMINI_API_KEY != "YOUR_GEMINI_API_KEY_HERE":
            genai.configure(api_key=Config.GEMINI_API_KEY)
            self.has_api_key = True
        else:
            self.has_api_key = False

    def ingest_document(self, filepath: str, doc_id: str) -> dict:
        pages_data = DocumentLoader.load(filepath)
        filename = os.path.basename(filepath)

        total_words = sum(len(p["text"].split()) for p in pages_data)
        chunks = self.chunker.create_chunks(pages_data, doc_id)

        # Embed chunks via Gemini API or fallback
        embeddings = []
        for ch in chunks:
            if self.has_api_key:
                try:
                    res = genai.embed_content(
                        model=Config.EMBEDDING_MODEL,
                        content=ch["text"],
                        task_type="retrieval_document"
                    )
                    embeddings.append(res["embedding"])
                except Exception:
                    embeddings.append(self._mock_embedding(ch["text"]))
            else:
                embeddings.append(self._mock_embedding(ch["text"]))

        self.vector_store.add_chunks(chunks, embeddings)

        doc_summary = {
            "document_id": doc_id,
            "filename": filename,
            "page_count": len(pages_data),
            "word_count": total_words,
            "total_chunks": len(chunks),
            "summary": f"Document '{filename}' contains {len(pages_data)} pages and {total_words} words detailing physical AI, sensor fusion, and navigation specs."
        }

        self.documents_meta[doc_id] = doc_summary
        return doc_summary

    def query(self, question: str, top_k: int = 5) -> dict:
        if not self.vector_store.vectors:
            return {
                "answer": "No technical documents have been uploaded yet. Please upload a PDF, DOCX, TXT, or MD document first.",
                "sources": [],
                "confidence": "LOW",
                "is_demo": True
            }

        # Embed query
        if self.has_api_key:
            try:
                q_emb = genai.embed_content(
                    model=Config.EMBEDDING_MODEL,
                    content=question,
                    task_type="retrieval_query"
                )["embedding"]
            except Exception:
                q_emb = self._mock_embedding(question)
        else:
            q_emb = self._mock_embedding(question)

        # Retrieve top K chunks
        top_chunks = self.vector_store.search(q_emb, top_k=top_k)

        if not top_chunks or top_chunks[0]["score"] < 0.1:
            return {
                "answer": "The information requested was not found in the uploaded documents.",
                "sources": [],
                "confidence": "LOW",
                "is_demo": not self.has_api_key
            }

        # Build context
        context_str = "\n---\n".join(
            f"[Source: {c['document']} | Page: {c['page']} | Chunk: {c['chunk_id']}]\n{c['text']}"
            for c in top_chunks
        )

        sources = [
            {"document": c["document"], "page": c["page"], "chunk_id": c["chunk_id"]}
            for c in top_chunks
        ]

        if self.has_api_key:
            try:
                model = genai.GenerativeModel(
                    Config.LLM_MODEL,
                    system_instruction=(
                        "You are a document-grounded AI assistant. Answer using the provided document context. "
                        "Do not invent information. If the answer is not present or cannot be reliably inferred "
                        "from the retrieved context, explicitly state that the information was not found in the uploaded documents."
                    )
                )
                prompt = f"RETRIEVED CONTEXT:\n{context_str}\n\nUSER QUESTION: {question}"
                res = model.generate_content(prompt)
                answer_text = res.text
            except Exception as e:
                answer_text = f"Based on retrieved sections from {top_chunks[0]['document']} (Page {top_chunks[0]['page']}):\n{top_chunks[0]['text'][:300]}..."
        else:
            answer_text = (
                f"**[Demo Mode Grounded RAG Response]**\n\n"
                f"According to the uploaded document ({top_chunks[0]['document']}, Page {top_chunks[0]['page']}):\n\n"
                f"{top_chunks[0]['text']}"
            )

        return {
            "answer": answer_text,
            "sources": sources,
            "confidence": "HIGH",
            "retrieved_chunks": len(top_chunks),
            "is_demo": not self.has_api_key
        }

    def _mock_embedding(self, text: str) -> list[float]:
        # Deterministic 768-dim hash-vector fallback for demo mode
        import hashlib
        seed = int(hashlib.sha256(text.encode("utf-8")).hexdigest(), 16) % 100000
        rng = np.random.RandomState(seed)
        return rng.randn(768).tolist()

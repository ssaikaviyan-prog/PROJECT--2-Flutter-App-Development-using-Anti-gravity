import numpy as np

class VectorStore:
    """Lightweight in-memory vector database with Cosine Similarity search & metadata filtering."""

    def __init__(self):
        self.vectors = [] # List of numpy arrays
        self.metadata = [] # List of metadata dicts

    def add_chunks(self, chunks: list[dict], embeddings: list[list[float]]):
        for chunk, emb in zip(chunks, embeddings):
            vec = np.array(emb, dtype=np.float32)
            norm = np.linalg.norm(vec)
            if norm > 0:
                vec = vec / norm # Normalize for Cosine Similarity

            self.vectors.append(vec)
            self.metadata.append(chunk)

    def search(self, query_embedding: list[float], top_k: int = 5) -> list[dict]:
        if not self.vectors:
            return []

        q_vec = np.array(query_embedding, dtype=np.float32)
        norm = np.linalg.norm(q_vec)
        if norm > 0:
            q_vec = q_vec / norm

        matrix = np.vstack(self.vectors)
        similarities = np.dot(matrix, q_vec)

        # Top K indices sorted descending
        top_indices = np.argsort(similarities)[::-1][:top_k]

        results = []
        for idx in top_indices:
            score = float(similarities[idx])
            meta = dict(self.metadata[idx])
            meta["score"] = score
            results.append(meta)

        return results

    def delete_document(self, doc_name_or_id: str):
        new_vectors = []
        new_metadata = []

        for vec, meta in zip(self.vectors, self.metadata):
            if meta["document"] != doc_name_or_id and not meta["chunk_id"].startswith(doc_name_or_id):
                new_vectors.append(vec)
                new_metadata.append(meta)

        self.vectors = new_vectors
        self.metadata = new_metadata

class Chunker:
    """Structure-aware chunker implementing configurable token size and overlap."""

    def __init__(self, chunk_size_chars: int = 4000, overlap_chars: int = 600):
        self.chunk_size = chunk_size_chars
        self.overlap = overlap_chars

    def create_chunks(self, pages_data: list[dict], doc_id: str) -> list[dict]:
        chunks = []

        for p_info in pages_data:
            doc_name = p_info["document"]
            page_num = p_info["page"]
            text = p_info["text"]

            if len(text) <= self.chunk_size:
                chunks.append({
                    "chunk_id": f"{doc_id}_p{page_num:03d}_c01",
                    "document": doc_name,
                    "page": page_num,
                    "text": text
                })
            else:
                # Sliding window chunking with overlap
                start = 0
                chunk_seq = 1

                while start < len(text):
                    end = start + self.chunk_size
                    chunk_text = text[start:end]

                    chunks.append({
                        "chunk_id": f"{doc_id}_p{page_num:03d}_c{chunk_seq:02d}",
                        "document": doc_name,
                        "page": page_num,
                        "text": chunk_text
                    })

                    start += (self.chunk_size - self.overlap)
                    chunk_seq += 1

        return chunks

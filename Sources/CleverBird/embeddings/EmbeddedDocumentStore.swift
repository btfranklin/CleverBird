//  Created by B.T. Franklin on 7/23/23

public class EmbeddedDocumentStore {

    public struct DocumentSimilarityResult {
        public let document: Document
        public let similarity: Similarity
    }

    private let maxBatchSize = 8192

    let connection: OpenAIAPIConnection
    let model: EmbeddingModel
    let user: String?

    public internal(set) var documents: [Document] = []
    public internal(set) var embeddings: [Vector] = []
    public var dictionaryRepresentation: [Document: Vector] {
        return zip(documents, embeddings).reduce(into: [Document: Vector]()) { result, pair in
            result[pair.0] = pair.1
        }
    }

    private var similarityMetric: SimilarityMetric

    public init(connection: OpenAIAPIConnection,
                model: EmbeddingModel = .textEmbeddingAda002,
                user: String? = nil,
                similarityMetric: SimilarityMetric = .cosine) {
        self.connection = connection
        self.model = model
        self.user = user
        self.similarityMetric = similarityMetric
    }

    public func embedAndStore(_ documents: [Document]) async throws {

        do {
            let embeddingReponse = try await embed(documents)

            for embeddingData in embeddingReponse.data {
                let index = embeddingData.index
                addDocument(documents[index], withEmbedding: embeddingData.embedding)
            }

        } catch {
            throw CleverBirdError.requestFailed(message: error.localizedDescription)
        }
    }

    public func embedAndStore(_ document: Document) async throws {
        try await embedAndStore([document])
    }

    private func embed(_ documents: [Document]) async throws -> EmbeddingResponse {

        guard documents.count >= 1 && documents.count <= 8192 else {
            throw CleverBirdError.invalidEmbeddingRequest(message: "Number of documents to embed must be between 1 and 8192.")
        }

        let requestBody = EmbeddingRequestParameters(
            model: self.model,
            input: documents,
            user: self.user
        )

        do {
            let request = try await self.connection.createEmbeddingRequest(for: requestBody)
            let response = try await self.connection.client.send(request)
            return response.value

        } catch {
            throw CleverBirdError.requestFailed(message: error.localizedDescription)
        }

    }

    public func addDocument(_ document: Document, withEmbedding embedding: Vector) {
        documents.append(document)
        embeddings.append(embedding)
    }

    public func removeDocument(at index: Int) {
        embeddings.remove(at: index)
        documents.remove(at: index)
    }

    public func queryDocumentSimilarity(_ queryDocument: Document, topK: Int = 5) async throws -> [DocumentSimilarityResult] {

        do {
            let queryEmbeddingResponse = try await embed([queryDocument])
            guard let queryDocumentEmbeddingData = queryEmbeddingResponse.data.first else {
                throw CleverBirdError.requestFailed(message: "Embedding request returned empty results")
            }
            let queryDocumentEmbedding: Vector = queryDocumentEmbeddingData.embedding
            let (rankedResults, similarities) = sortVectors(self.embeddings,
                                                            bySimilarityTo: queryDocumentEmbedding,
                                                            topK: topK,
                                                            metric: self.similarityMetric)
            return zip(rankedResults.map { documents[$0] }, similarities).map { DocumentSimilarityResult(document: $0, similarity: $1) }
        } catch {
            throw CleverBirdError.requestFailed(message: error.localizedDescription)
        }
    }

    // Ranking algorithm for sorting vectors by their similarity to a query vector
    private func sortVectors(_ vectors: [Vector],
                             bySimilarityTo queryVector: Vector,
                             topK: Int = 5,
                             metric: SimilarityMetric = .cosine) -> ([Int], [Double]) {
        let similarities = metric.function(vectors, queryVector)

        // Sorting the vectors in descending order of similarity
        let sortedIndices = (0..<similarities.count).sorted { similarities[$0] > similarities[$1] }
        let topIndices = Array(sortedIndices.prefix(topK))
        let topSimilarities = topIndices.map { similarities[$0] }
        return (topIndices, topSimilarities)
    }

}

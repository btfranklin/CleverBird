//  Created by B.T. Franklin on 9/2/23

import Accelerate

extension EmbeddedDocumentStore {

    public enum SimilarityMetric {
        case dot
        case cosine
        case euclidean

        var function: SimilarityFunction {
            switch self {
            case .dot:
                return calculateDotProduct
            case .cosine:
                return calculateCosineSimilarity
            case .euclidean:
                return calculateEuclideanSimilarity
            }
        }

        // Compute the dot product of each vector in the array with a query vector
        private func calculateDotProduct(of vectors: [Vector], and queryVector: Vector) -> [Float] {
            return vectors.map { vector in
                var result: Float = 0.0

                // The dot product is a measure of the extent to which two vectors point in the same direction
                vDSP_dotpr(vector, 1, queryVector, 1, &result, vDSP_Length(vector.count))
                return result
            }
        }

        // Calculate the cosine similarity between an array of vectors and a query vector
        private func calculateCosineSimilarity(of vectors: [Vector], and queryVector: Vector) -> [Float] {
            let normVectors = normalize(vectors: vectors)
            let normQueryVector = normalize(vector: queryVector)

            // Cosine similarity is often used in NLP tasks to measure how similar two documents are, irrespective of their size
            return calculateDotProduct(of: normVectors, and: normQueryVector)
        }

        // Calculate the Euclidean similarity between an array of vectors and a query vector
        private func calculateEuclideanSimilarity(of vectors: [Vector], and queryVector: Vector) -> [Float] {
            let diffVectors = vectors.map { zip($0, queryVector).map { $0.0 - $0.1 } }
            let distances = diffVectors.map { sqrt($0.map { $0 * $0 }.reduce(0, +)) }

            // Euclidean similarity: inverse of Euclidean distance, with a tweak for handling identical vectors
            return distances.map { distance in distance == 0 ? 1 : 1 / distance }
        }

        // Helper function to get the Euclidean norm (or length) of a vector
        private func calculateNorm(of vector: Vector) -> Float {
            var result: Float = 0.0

            // Taking the dot product of the vector with itself, then square rooting the result gives us the Euclidean norm
            vDSP_dotpr(vector, 1, vector, 1, &result, vDSP_Length(vector.count))
            return sqrt(result)
        }

        // Convert a vector to a normalized vector
        private func normalize(vector: Vector) -> Vector {
            let normValue = calculateNorm(of: vector)

            // Each component of the vector is divided by its norm
            return vector.map { $0 / normValue }
        }

        // Normalize each vector in a 2D array
        private func normalize(vectors: [Vector]) -> [Vector] {

            // Normalization is applied to each vector in the array
            return vectors.map { normalize(vector: $0) }
        }
    }
}

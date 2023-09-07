//  Created by B.T. Franklin on 9/4/23

import Foundation

extension EmbeddedDocumentStore {

    public func save(to fileURL: URL) {
        do {
            let jsonData = try JSONEncoder().encode(self.dictionaryRepresentation)
            try jsonData.write(to: fileURL)
        } catch {
            print(error.localizedDescription)
        }
    }

    public func load(from fileURL: URL) {
        do {
            let jsonData = try Data(contentsOf: fileURL)
            let data = try JSONDecoder().decode([Document: Vector].self, from: jsonData)
            self.documents = data.map { $0.key }
            self.embeddings = data.map { $0.value }
        } catch {
            print(error.localizedDescription)
        }
    }
}

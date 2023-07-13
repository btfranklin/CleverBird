import Foundation

fileprivate struct SymbolPair: Hashable {
    let left: String
    let right: String

    @inlinable
    init(_ left: String, _ right: String) {
        self.left = left
        self.right = right
    }
}

fileprivate func bytesToUnicode() -> [UInt8: Character] {
    var dict = [UInt8: Character]()
    var n: UInt16 = 0

    for b: UInt8 in 0...255 {
        switch b {
        case 33...126, 161...172, 174...255:
            dict[b] = Character(UnicodeScalar(b))
        default:
            dict[b] = Character(UnicodeScalar(256 + n)!)
            n += 1
        }
    }

    return dict
}

fileprivate func getPairs(in word: [String]) -> Set<SymbolPair> {
    var pairs = Set<SymbolPair>()
    var prevChar = word[0]

    for char in word[1..<word.count] {
        pairs.insert(SymbolPair(prevChar, char))
        prevChar = char
    }

    return pairs
}

public struct TokenEncoder {
    static let pattern: Pattern = Pattern(#"'s|'t|'re|'ve|'m|'ll|'d| ?\p{L}+| ?\p{N}+| ?[^\s\p{L}\p{N}]+|\s+(?!\S)|\s+"#, options: [.caseInsensitive])

    static let byteEncoder: [UInt8: Character] = bytesToUnicode()
    static let byteDecoder: [Character: UInt8] = Dictionary(uniqueKeysWithValues: byteEncoder.map { ($1, $0) })

    let encoder: [String: Token]
    let decoder: [Token: String]
    fileprivate let bpeRanks: [SymbolPair: Int]

    public init(model: Model = .gpt3) throws {
        encoder = try model.encoder()
        decoder = Dictionary(uniqueKeysWithValues: encoder.map { ($1, $0) })
        bpeRanks = try model.bpeRanks()
    }

    fileprivate func bpe(token: String) -> String {
        var word: [String] = token.map { String($0) }
        var pairs: Set<SymbolPair> = getPairs(in: word)
        if pairs.isEmpty {
            return token
        }
        while true {
            guard let bigram = pairs.min(by: { bpeRanks[$0] ?? Int.max < bpeRanks[$1] ?? Int.max }),
                  let _ = bpeRanks[bigram] else { break }

            let first = bigram.left
            let second = bigram.right
            var newWord = [String]()
            var i = 0

            while i < word.count {
                if let j = word[i...].firstIndex(of: first) {
                    newWord.append(contentsOf: word[i..<j])
                    i = j
                } else {
                    newWord.append(contentsOf: word[i...])
                    break
                }
                if word[i] == first && i < word.count - 1 && word[i + 1] == second {
                    newWord.append(first + second)
                    i += 2
                } else {
                    newWord.append(word[i])
                    i += 1
                }
            }
            word = newWord
            if word.count == 1 {
                break
            } else {
                pairs = getPairs(in: word)
            }
        }

        return word.joined(separator: " ")
    }

    public func encode(text: String) throws -> [Token] {
        var bpeTokens: [Token] = []
        var cache = [String: String]()

        for result in TokenEncoder.pattern.findAll(in: text) {
            let token = String(result.value.utf8.map { TokenEncoder.byteEncoder[$0]! })

            if token.isEmpty { continue }

            let word = cache[token] ?? bpe(token: token)
            cache[token] = word

            let splitBpe = word.split(separator: " ")
            let encodedResult = try splitBpe.map {
                guard let value = encoder[String($0)] else {
                    throw TokenEncoder.Error.invalidEncoding(value: String($0))
                }
                return value
            }
            bpeTokens.append(contentsOf: encodedResult)
        }
        return bpeTokens
    }

    public func decode(tokens: [Token]) throws -> String {
        let text = try tokens.map {
            guard let value = decoder[$0] else {
                throw TokenEncoder.Error.invalidToken(value: $0)
            }
            return value
        }.joined()
        let decoded = try text.map {
            let char = $0
            guard let byte = TokenEncoder.byteDecoder[char] else {
                throw TokenEncoder.Error.invalidCharacter(value: $0)
            }
            return byte
        }
        let decodedData = Data(decoded)
        return String(decoding: decodedData, as: UTF8.self)
    }
}

extension TokenEncoder {
    public enum Error: Swift.Error, Equatable {
        case missingResource(name: String)
        case invalidBytePair(value: String)
        case invalidEncoding(value: String)
        case invalidToken(value: Token)
        case invalidCharacter(value: Character)
    }
}

extension TokenEncoder {
    public enum Model: String {
        case gpt3

        func encoder() throws -> [String: Token] {
            guard let encoderPath = Bundle.module.url(forResource: "\(rawValue)-encoder", withExtension: "json") else {
                throw TokenEncoder.Error.missingResource(name: "\(rawValue)-encoder.json")
            }
            let encoderData = try Data(contentsOf: encoderPath)
            return try JSONDecoder().decode([String: Token].self, from: encoderData)
        }

        fileprivate func bpeRanks() throws -> [SymbolPair: Int] {
            guard let bpePath = Bundle.module.url(forResource: "\(rawValue)-vocab", withExtension: "bpe") else {
                throw TokenEncoder.Error.missingResource(name: "\(rawValue)-vocab.bpe")
            }
            let bpeData = try String(contentsOf: bpePath, encoding: .utf8)

            let bpeMerges = try bpeData
                .split(separator: "\n")
                .dropFirst().dropLast()
                .map {
                    let split = $0.split(separator: " ")
                    guard split.count == 2,
                          let left = split.first, let right = split.last else {
                        throw TokenEncoder.Error.invalidBytePair(value: String($0))
                    }
                    return SymbolPair(String(left), String(right))
                }

            return bpeMerges.enumerated().reduce(into: [SymbolPair: Int]()) { result, item in
                result[item.element] = item.offset
            }
        }
    }
}

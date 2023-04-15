import Foundation

/**
 A wrapper for simplified RegEx matching. It does not throw an exception when given a bad pattern, rather it triggers a `preconditionFailure` with the error message. This makes it useful for providing reusable constants which generally should not fail in the real world.
 */
struct Pattern: CustomStringConvertible {
    typealias Options = NSRegularExpression.Options
    typealias MatchingOptions = NSRegularExpression.MatchingOptions

    private static var cache: [String: NSRegularExpression] = [:]

    /// The underlying `NSRegularExpression` instance.
    let regex: NSRegularExpression

    /// Description of the pattern.
    var description: String {
        regex.pattern
    }

    /// Creates a pattern from a string.
    ///
    /// - Parameters:
    ///   - pattern: The pattern to match.
    ///   - options: The options to use when matching.
    init(_ pattern: String, options: Options = []) {
        if let cachedRegex = Self.cache[pattern] {
            regex = cachedRegex
        } else {
            do {
                let newRegex = try NSRegularExpression(pattern: pattern, options: options)
                Self.cache[pattern] = newRegex
                regex = newRegex
            } catch {
                preconditionFailure("Invalid regular expression '\(pattern)': \(error)")
            }
        }
    }

    /// Returns whether the pattern matches the given string.
    func hasMatch(in text: String, options: MatchingOptions = []) -> Bool {
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.numberOfMatches(in: text, options: options, range: range) > 0
    }

    /// Returns whether the pattern matches the given ``CustomStringConvertible`` value.
    ///
    /// - Parameters:
    ///   - value: The value to match.
    ///   - options: The options to use when matching.
    ///
    /// - Returns: Whether the pattern matches the given value.
    func hasMatch(in text: CustomStringConvertible, options: MatchingOptions = []) -> Bool {
        return hasMatch(in: String(describing: text), options: options)
    }

    /// Returns the first match of the pattern in the given string.
    ///
    /// - Parameters:
    ///   - value: The value to match.
    ///   - options: The options to use when matching.
    ///
    /// - Returns: The first match of the pattern in the given string.
    func matchGroups(in text: String, options: MatchingOptions = []) -> Result? {
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        if let result = regex.firstMatch(in: text, options: options, range: range)
        {
            return Result(textCheckingResult: result, original: text)
        }
        return nil
    }

    func matchGroups(in text: CustomStringConvertible, options: MatchingOptions = []) -> Result? {
        return matchGroups(in: String(describing: text), options: options)
    }

    func findAll(in text: String, options: MatchingOptions = []) -> [Result] {
        let results = regex.matches(in: text, options: options, range: NSRange(text.startIndex..., in: text))
        return results.compactMap {
            Result(textCheckingResult: $0, original: text)
            //      Range($0.range, in: value).map { value[$0] }
        }
    }

    func replace(in text: String, with replacement: String, options: MatchingOptions = []) -> String {
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.stringByReplacingMatches(in: text, options: options, range: range, withTemplate: replacement)
    }

    struct Result: CustomStringConvertible {
        let textCheckingResult: NSTextCheckingResult
        let original: String

        var value: Substring {
            Range(textCheckingResult.range, in: original).map { original[$0] } ?? ""[...]
        }

        var description: String {
            String(value)
        }

        subscript(i: Int) -> Substring? {
            guard i < textCheckingResult.numberOfRanges else {
                return nil
            }

            if let group = Range(textCheckingResult.range(at: i), in: original) {
                return original[group]
            }
            return nil
        }

        subscript(i: Int, j: Int) -> (Substring, Substring)? {
            if let iValue = self[i],
               let jValue = self[j]
            {
                return (iValue, jValue)
            } else {
                return nil
            }
        }

        subscript(i: Int, j: Int, k: Int) -> (Substring, Substring, Substring)? {
            if let iValue = self[i],
               let jValue = self[j],
               let kValue = self[k]
            {
                return (iValue, jValue, kValue)
            } else {
                return nil
            }
        }

        subscript(name: String) -> Substring? {
            let nsrange = textCheckingResult.range(withName: name)
            guard nsrange.location != NSNotFound else {
                return nil
            }

            if let range = Range(nsrange, in: original) {
                return original[range]
            } else {
                return nil
            }
        }

        subscript(name1: String, name2: String) -> (Substring, Substring)? {
            if let value1 = self[name1],
               let value2 = self[name2]
            {
                return (value1, value2)
            }
            return nil
        }

        subscript(name1: String, name2: String, name3: String) -> (Substring, Substring, Substring)? {
            if let value1 = self[name1],
               let value2 = self[name2],
               let value3 = self[name3]
            {
                return (value1, value2, value3)
            }
            return nil
        }

    }
}

extension Pattern: ExpressibleByStringLiteral {
    typealias StringLiteralType = String

    init(stringLiteral value: String) {
        self.init(value)
    }
}

//  Created by Ronald Mannak on 4/12/24.

import Foundation

public enum MessageContent: Hashable {
    case text(String)
    case imageUrl(URLDetail)
}

extension MessageContent {
    public enum ContentType: String, Codable, Hashable {
        case text
        case imageUrl = "image_url"
    }
    
    public struct URLDetail: Codable, Equatable, Hashable {
        
        public enum Detail: String, Codable {
            case low, high, auto
        }
        
        let url: String
        let detail: Detail?
        
        public init(url: String, detail: Detail? = nil) {
            self.url = url
            self.detail = detail
        }
        
        public init(url: URL, detail: Detail? = nil) {
            self.init(url: url.absoluteString, detail: detail)
        }
        
        public init(imageData: Data, detail: Detail? = nil) {
            let base64 = imageData.base64EncodedString()
            self.init(url: "data:image/jpeg;base64,\(base64)", detail: detail)
        }
    }
}
    
extension MessageContent: Codable {

    private enum CodingKeys: String, CodingKey {
        case type, text, imageUrl
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ContentType.self, forKey: .type)
        
        switch type {
        case .text:
            let text = try container.decode(String.self, forKey: .text)
            self = .text(text)
        case .imageUrl:
            let imageUrl = try container.decode(URLDetail.self, forKey: .imageUrl)
            self = .imageUrl(imageUrl)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode(ContentType.text.rawValue, forKey: .type)
            try container.encode(text, forKey: .text)
        case .imageUrl(let urlDetail):
            try container.encode(ContentType.imageUrl.rawValue, forKey: .type)
            try container.encode(urlDetail, forKey: .imageUrl)
        }
    }
}

extension MessageContent: Equatable {
    public static func == (lhs: MessageContent, rhs: MessageContent) -> Bool {
        switch (lhs, rhs) {
        case (.text(let lhsText), .text(let rhsText)):
            return lhsText == rhsText
        case (.imageUrl(let lhsUrlDetail), .imageUrl(let rhsUrlDetail)):
            return lhsUrlDetail == rhsUrlDetail
        default:
            return false
        }
    }
}

//
//  ChatContent.swift
//  
//
//  Created by Ronald Mannak on 4/12/24.
//

import Foundation

enum ChatContent {
    
    private enum ContentType: String, Codable {
        case text
        case imageUrl = "image_url"
    }
    
    struct URLDetail: Codable {
        
        public enum Detail: String, Codable {
            case low, high, auto
        }
        
        let url: String
        let detail: Detail?
        
        public init(url: String, detail: Detail? = nil) {
            self.url = url
            self.detail = detail
        }
    }
    
    case text(String)
    case imageUrl(URLDetail)
}
    
extension ChatContent: Codable {

    private enum CodingKeys: String, CodingKey {
        case type, text, imageUrl
    }
    
    init(from decoder: Decoder) throws {
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
    
    func encode(to encoder: Encoder) throws {
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

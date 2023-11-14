//
//  JSONObject.swift
//  
//
//  Created by Ronald Mannak on 11/7/23.
//

import Foundation

public enum JSONObject {
    case text, JSON
}

extension JSONObject: Codable {
    enum CodingKeys {
        case text
        case JSON = "json_object"
    }
}

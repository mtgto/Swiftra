// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import Foundation
import NIOHTTP1

// ステータスコードとか指定したいときに使う
public enum Response {
    case text(String, ResponseDetail), data(Data, ResponseDetail)
    
    public struct ResponseDetail {
        public var status: HTTPResponseStatus = .ok
        public var contentType: String = "text/plain"
    }
    
    func createHeaders() -> [String: String] {
        let contentType: String
        switch self {
        case .text(_, let detail), .data(_, let detail):
            contentType = detail.contentType
        }
        return ["Content-Type": contentType]
    }
}

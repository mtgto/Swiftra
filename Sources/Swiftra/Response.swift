// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import Foundation
import NIO
import NIOHTTP1

// ステータスコードとか指定したいときに使う
public enum Response {
    case text(String, detail: ResponseDetail = ResponseDetail())
    case data(Data, detail: ResponseDetail = ResponseDetail(contentType: "application/octet-stream"))

    public init(text: String, status: HTTPResponseStatus = .ok, contentType: String = "text/plain") {
        self = .text(text, detail: ResponseDetail(status: status, contentType: contentType))
    }

    public init(data: Data, status: HTTPResponseStatus = .ok, contentType: String = "application/octet-stream") {
        self = .data(data, detail: ResponseDetail(status: status, contentType: contentType))
    }

    public init?<T: Encodable>(json: T, status: HTTPResponseStatus = .ok, contentType: String = "application/json") {
        let jsonEncoder = JSONEncoder()
        if let data = try? jsonEncoder.encode(json) {
            self.init(data: data, status: status, contentType: contentType)
        } else {
            return nil
        }
    }

    public struct ResponseDetail {
        public var status: HTTPResponseStatus = .ok
        public var contentType: String = "text/plain"

        public init(status: HTTPResponseStatus = .ok, contentType: String = "text/plain") {
            self.status = status
            self.contentType = contentType
        }
    }

    func createHeaders() -> [(String, String)] {
        let contentType: String
        switch self {
        case .text(_, let detail), .data(_, let detail):
            contentType = detail.contentType
        }
        return [("Content-Type", contentType)]
    }

    func data() -> Data {
        switch self {
        case .text(let text, _):
            return text.data(using: .utf8) ?? Data()
        case .data(let data, _):
            return data
        }
    }
}

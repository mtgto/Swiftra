// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import Foundation
import NIO
import NIOHTTP1

// ステータスコードとか指定したいときに使う
public enum Response {
    case text(String, status: HTTPResponseStatus = .ok, contentType: String = ContentType.textPlain.withCharset(), headers: [(String, String)] = [])
    case data(
        Data, status: HTTPResponseStatus = .ok, contentType: String = ContentType.applicationOctetStream.rawValue, headers: [(String, String)] = [])

    public init(
        text: String, status: HTTPResponseStatus = .ok, contentType: String = ContentType.textPlain.withCharset(), headers: [(String, String)] = []
    ) {
        self = .text(text, status: status, contentType: contentType, headers: headers)
    }

    public init(
        data: Data, status: HTTPResponseStatus = .ok, contentType: String = ContentType.applicationOctetStream.rawValue,
        headers: [(String, String)] = []
    ) {
        self = .data(data, status: status, contentType: contentType, headers: headers)
    }

    public init?<T: Encodable>(json: T, status: HTTPResponseStatus = .ok, contentType: String = ContentType.applicationJson.withCharset()) {
        let jsonEncoder = JSONEncoder()
        if let data = try? jsonEncoder.encode(json) {
            self.init(data: data, status: status, contentType: contentType)
        } else {
            return nil
        }
    }

    func createHeaders() -> [(String, String)] {
        let contentType: String
        switch self {
        case .text(_, status: _, contentType: let ct, let headers), .data(_, status: _, contentType: let ct, let headers):
            contentType = ct
            return headers + [("Content-Type", contentType)]
        }
    }

    func data() -> Data {
        switch self {
        case .text(let text, status: _, contentType: _, headers: _):
            return text.data(using: .utf8) ?? Data()
        case .data(let data, status: _, contentType: _, headers: _):
            return data
        }
    }

    func status() -> HTTPResponseStatus {
        switch self {
        case .text(_, let status, contentType: _, headers: _):
            return status
        case .data(_, let status, contentType: _, headers: _):
            return status
        }
    }
}

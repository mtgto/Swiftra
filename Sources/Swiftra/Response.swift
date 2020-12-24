// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import Foundation
import NIO
import NIOHTTP1

// ステータスコードとか指定したいときに使う
public enum Response {
    case text(String, status: HTTPResponseStatus = .ok, contentType: String = ContentType.textPlain.rawValue)
    case data(Data, status: HTTPResponseStatus = .ok, contentType: String = ContentType.applicationOctetStream.rawValue)

    public init(text: String, status: HTTPResponseStatus = .ok, contentType: String = ContentType.textPlain.rawValue) {
        self = .text(text, status: status, contentType: contentType)
    }

    public init(data: Data, status: HTTPResponseStatus = .ok, contentType: String = ContentType.applicationOctetStream.rawValue) {
        self = .data(data, status: status, contentType: contentType)
    }

    public init?<T: Encodable>(json: T, status: HTTPResponseStatus = .ok, contentType: String = ContentType.applicationJson.rawValue) {
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
        case .text(_, status: _, contentType: let ct), .data(_, status: _, contentType: let ct):
            contentType = ct
        }
        return [("Content-Type", contentType)]
    }

    func data() -> Data {
        switch self {
        case .text(let text, status: _, contentType: _):
            return text.data(using: .utf8) ?? Data()
        case .data(let data, status: _, contentType: _):
            return data
        }
    }
}

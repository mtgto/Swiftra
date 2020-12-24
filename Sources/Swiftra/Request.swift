// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import Foundation
import NIO
import NIOHTTP1

public struct Request {
    public let path: String
    public let queryItems: [URLQueryItem]
    public let header: HTTPRequestHead
    public let remoteAddress: SocketAddress?
    public let eventLoop: EventLoop
    public var match: Match? = nil
    internal(set) public var body: ByteBuffer? = nil

    init(header: HTTPRequestHead, remoteAddress: SocketAddress?, eventLoop: EventLoop) {
        if let components = URLComponents(string: header.uri) {
            self.path = components.path
            self.queryItems = components.queryItems ?? []
        } else {
            // TODO: error handling
            self.path = ""
            self.queryItems = []
        }
        self.header = header
        self.remoteAddress = remoteAddress
        self.eventLoop = eventLoop
    }

    public func params(_ name: String) -> String? {
        if case .success(let params) = self.match {
            return params[name]
        }
        if let query = self.queryItems.first(where: { $0.name == name }), let value = query.value {
            return value
        }
        return nil
    }

    public func params(_ name: String, default defaultValue: String) -> String {
        return self.params(name) ?? defaultValue
    }
}

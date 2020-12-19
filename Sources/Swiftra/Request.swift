// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import NIO
import NIOHTTP1

public struct Request {
    public let header: HTTPRequestHead
    public let eventLoop: EventLoop
    public var match: Match? = nil

    init(header: HTTPRequestHead, eventLoop: EventLoop) {
        self.header = header
        self.eventLoop = eventLoop
    }

    public func params(_ name: String) -> String? {
        if case .success(let params) = self.match {
            return params[name]
        }
        return nil
    }
}

// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import NIO
import NIOHTTP1
import XCTest

@testable import Swiftra

class RequestTests: XCTestCase {
    class MockedEventLoop: EventLoop {
        var inEventLoop: Bool = true

        func execute(_ task: @escaping () -> Void) {
            fatalError("Not implemented")
        }

        func scheduleTask<T>(deadline: NIODeadline, _ task: @escaping () throws -> T) -> Scheduled<T> {
            fatalError("Not implemented")
        }

        func scheduleTask<T>(in: TimeAmount, _ task: @escaping () throws -> T) -> Scheduled<T> {
            fatalError("Not implemented")
        }

        func shutdownGracefully(queue: DispatchQueue, _ callback: @escaping (Error?) -> Void) {
            fatalError("Not implemented")
        }
    }

    func testRequestQueryItems() {
        let head = HTTPRequestHead(
            version: .init(major: 1, minor: 1), method: .GET, uri: "/foo/bar?baz=xxx&baz=yyy&ja=%E3%81%93%E3%82%93%E3%81%AB%E3%81%A1%E3%81%AF")
        let request = Request(header: head, remoteAddress: try? SocketAddress(ipAddress: "10.0.0.1", port: 8080), eventLoop: MockedEventLoop())
        XCTAssertEqual(request.params(""), nil)
        XCTAssertEqual(request.params("baz"), "xxx")  // first item is found
        XCTAssertEqual(request.params("ja"), "こんにちは")
    }

    static var allTests = [
        ("testRequestQueryItems", testRequestQueryItems)
    ]
}

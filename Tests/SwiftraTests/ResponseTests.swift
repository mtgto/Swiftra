// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import NIO
import XCTest

@testable import Swiftra

class ResponseTests: XCTestCase {

    func testResponse() {
        let textResponse: Response = .text("Hello, world")
        XCTAssertTrue(textResponse.createHeaders().contains(where: { ("Content-Type", "text/plain") == $0 }))
        XCTAssertEqual(String(data: textResponse.data(), encoding: .utf8), "Hello, world")
        guard let jsonResponse = Response(json: ["hoge": ["fuga", "piyo"]]) else {
            XCTFail()
            return
        }
        XCTAssertTrue(jsonResponse.createHeaders().contains(where: { ("Content-Type", "application/json") == $0 }))
    }

    static var allTests = [
        ("testResponse", testResponse)
    ]
}

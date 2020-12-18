// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import NIO
import XCTest
@testable import Swiftra

class ResponseTests: XCTestCase {

    func testResponse() {
        let textResponse: Response = .text("Hello, world")
        XCTAssertEqual(textResponse.createHeaders(), ["Content-Type": "text/plain"])
        let jsonResponse = Response(json: ["hoge": ["fuga", "piyo"]])
        XCTAssertEqual(jsonResponse?.createHeaders(), ["Content-Type": "application/json"])
    }

    static var allTests = [
        ("testResponse", testResponse),
    ]
}

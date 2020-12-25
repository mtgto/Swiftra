// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import Foundation
import XCTest

@testable import Swiftra

class MatcherTests: XCTestCase {

    func testMatcher() {
        let matcher = PathMatcher(method: .GET, path: "/foo/bar/baz")
        XCTAssertEqual(matcher.match(path: "/foo/bar/baz"), .success([:]))
        XCTAssertEqual(matcher.match(path: "/foo/bar/baz/"), .success([:]))
        XCTAssertEqual(matcher.match(path: "//foo///bar////baz"), .success([:]))
        XCTAssertEqual(matcher.match(path: "/Foo/BAR/BaZz"), .failure)
        XCTAssertEqual(matcher.match(path: "/foo/bar/bazz"), .failure)
        XCTAssertEqual(matcher.match(path: "/foo/bar"), .failure)
        XCTAssertEqual(matcher.match(path: "/foo/bar/baz/aaa"), .failure)
    }

    func testMatcherWithParams() {
        let matcher = PathMatcher(method: .GET, path: "/foo/:bar/baz")
        XCTAssertEqual(matcher.match(path: "/foo/bar/baz"), .success(["bar": "bar"]))
        XCTAssertEqual(matcher.match(path: "/foo/barbarbar/baz"), .success(["bar": "barbarbar"]))
        XCTAssertEqual(
            PathMatcher(method: .GET, path: "/:foo/:bar/:baz").match(path: "/foo/bar/baz"), .success(["foo": "foo", "bar": "bar", "baz": "baz"]))
        guard let components = URLComponents(string: "/foo/%E3%81%93%E3%82%93%E3%81%AB%E3%81%A1%E3%81%AF/baz") else {
            XCTFail("Fail to parse encoded url")
            return
        }
        XCTAssertEqual(matcher.match(path: components.path), .success(["bar": "こんにちは"]))
    }

    static var allTests = [
        ("testMatcher", testMatcher),
        ("testMatcherWithParams", testMatcherWithParams),
    ]
}

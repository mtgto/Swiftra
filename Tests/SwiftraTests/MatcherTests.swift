// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import XCTest

@testable import Swiftra

class MatcherTests: XCTestCase {

    func testMatcher() {
        let matcher = Matcher(path: "/foo/bar/baz")
        XCTAssertEqual(matcher.match(path: "/foo/bar/baz"), .success([:]))
        XCTAssertEqual(matcher.match(path: "/foo/bar/baz/"), .success([:]))
        XCTAssertEqual(matcher.match(path: "/foo/bar/bazz"), .failure)
        XCTAssertEqual(matcher.match(path: "/foo/bar"), .failure)
        XCTAssertEqual(matcher.match(path: "/foo/bar/baz/aaa"), .failure)
    }

    func testMatcherWithParams() {
        let matcher = Matcher(path: "/foo/:bar/baz")
        XCTAssertEqual(matcher.match(path: "/foo/bar/baz"), .success(["bar": "bar"]))
        XCTAssertEqual(matcher.match(path: "/foo/barbarbar/baz"), .success(["bar": "barbarbar"]))
        XCTAssertEqual(Matcher(path: "/:foo/:bar/:baz").match(path: "/foo/bar/baz"), .success(["foo": "foo", "bar": "bar", "baz": "baz"]))
    }

    static var allTests = [
        ("testMatcher", testMatcher),
        ("testMatcherWithParams", testMatcherWithParams),
    ]
}

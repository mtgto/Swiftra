// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import Foundation
import NIOHTTP1

public enum Match: Equatable {
    case success([String: String])
    case failure
}

public protocol Matcher {
    func match(method: HTTPMethod?, path: String) -> Match
    func match(request: Request) -> Match
}

// TODO: Implements Hashable to use key of routing table
public struct PathMatcher: Matcher {
    private let method: HTTPMethod
    private let components: [String]

    public init(method: HTTPMethod, path: String) {
        self.method = method
        self.components = URL(fileURLWithPath: path).pathComponents
    }

    public func match(method: HTTPMethod? = nil, path: String) -> Match {
        if let method = method, method != self.method {
            return .failure
        }
        let components = URL(fileURLWithPath: path).pathComponents
        return self.match(lhs: self.components, rhs: components, params: [:])
    }

    public func match(request: Request) -> Match {
        return self.match(method: request.header.method, path: request.path)
    }

    private func match(lhs: [String], rhs: [String], params: [String: String]) -> Match {
        if lhs.isEmpty && rhs.isEmpty {
            return .success(params)
        } else if lhs.count != rhs.count {
            return .failure
        }
        let component = lhs.first!
        if component.first == ":" {
            let newParams = params.merging([String(component.dropFirst()): rhs.first!]) { $1 }
            return match(lhs: Array(lhs.dropFirst()), rhs: Array(rhs.dropFirst()), params: newParams)
        } else if component == rhs.first {
            return match(lhs: Array(lhs.dropFirst()), rhs: Array(rhs.dropFirst()), params: params)
        }
        return .failure
    }
}

public struct AllMatcher: Matcher {
    public func match(method: HTTPMethod? = nil, path: String) -> Match {
        .success([:])
    }

    public func match(request: Request) -> Match {
        .success([:])
    }
}

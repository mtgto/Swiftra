// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import Foundation

public enum Match: Equatable {
    case success([String: String])
    case failure
}

public struct Matcher {
    private let components: [String]

    public init(path: String) {
        self.components = URL(fileURLWithPath: path).pathComponents
    }

    public func match(path: String) -> Match {
        let components = URL(fileURLWithPath: path).pathComponents
        return self.match(lhs: self.components, rhs: components, params: [:])
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

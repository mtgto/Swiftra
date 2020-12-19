// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import Foundation
import NIOHTTP1

@_functionBuilder public struct DSLMaker {
    public static func buildBlock<T>(_ components: T...) -> [T] {
        //return components
        log.info("components:", components)
        return components
    }
}

public func get(_ path: String, handler: @escaping Handler) -> Route {
    return createRoute(method: .GET, path: path, handler: .normal(handler))
}

public func futureGet(_ path: String, handler: @escaping FutureHandler) -> Route {
    return createRoute(method: .GET, path: path, handler: .future(handler))
}

private func createRoute(method: HTTPMethod, path: String, handler: HandlerType) -> Route {
    let matcher = Matcher(path: path)
    return Route(method: method, pathMatcher: matcher, handler: handler)
}

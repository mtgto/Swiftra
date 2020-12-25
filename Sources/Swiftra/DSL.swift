// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import Foundation
import NIO
import NIOHTTP1

@_functionBuilder public struct DSLMaker {
    public static func buildBlock(_ routes: Route...) -> [Route] {
        return routes
    }
}

public func get(_ path: String, handler: @escaping Handler) -> Route {
    return createRoute(method: .GET, path: path, handler: .normal(handler))
}

public func futureGet(_ path: String, handler: @escaping FutureHandler) -> Route {
    return createRoute(method: .GET, path: path, handler: .future(handler))
}

public func post(_ path: String, handler: @escaping Handler) -> Route {
    return createRoute(method: .POST, path: path, handler: .normal(handler))
}

public func futurePost(_ path: String, handler: @escaping FutureHandler) -> Route {
    return createRoute(method: .POST, path: path, handler: .future(handler))
}

public func handle(_ method: HTTPMethod, _ path: String, handler: @escaping Handler) -> Route {
    return createRoute(method: method, path: path, handler: .normal(handler))
}

public func futureHandle(_ method: HTTPMethod, _ path: String, handler: @escaping FutureHandler) -> Route {
    return createRoute(method: method, path: path, handler: .future(handler))
}

public func notFound(handler: @escaping Handler) -> Route {
    let matcher = AllMatcher()
    return Route(matcher: matcher, handler: .normal(handler))
}

private func createRoute(method: HTTPMethod, path: String, handler: HandlerType) -> Route {
    let matcher = PathMatcher(method: method, path: path)
    return Route(matcher: matcher, handler: handler)
}

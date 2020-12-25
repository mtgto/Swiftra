// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import NIO

public typealias Handler = (Request) throws -> Response
public typealias FutureHandler = (Request) -> EventLoopFuture<Response>
public typealias ErrorHandler = (Request, Error) -> Response

public enum HandlerType {
    case normal(Handler)
    case future(FutureHandler)
    case error(ErrorHandler)
}

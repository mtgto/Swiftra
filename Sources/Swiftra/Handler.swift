// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import NIO

public typealias Handler = (Request) -> Response
public typealias FutureHandler = (Request) -> EventLoopFuture<Response>

public enum HandlerType {
    case normal((Request) -> Response)
    case future((Request) -> EventLoopFuture<Response>)
}

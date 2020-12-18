// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import NIOHTTP1

public struct Route {
    public let method: HTTPMethod
    public let pathMatcher: Matcher
    public let handler: HandlerType
}

// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

public typealias Next = ( Any... ) -> Void

public typealias Middleware = (Request, Response, @escaping Next) -> Any

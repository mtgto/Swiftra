// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import NIO
import Foundation
import Swiftra

let app = App {
    get("/") { req in
        "Hello, world!"
    }
    
    get("/hello/:name") { req in
        "Hello \(req.params("name") ?? "guest")"
    }
    
    get("/future") { req in
        let promise: EventLoopPromise<String> = req.eventLoop.makePromise()
        promise.succeed("Hello from future")
        return promise.futureResult
    }
}

try! app.run(1337)

RunLoop.main.run()

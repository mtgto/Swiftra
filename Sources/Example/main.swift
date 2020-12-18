// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

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
        let promise = req.eventLoop.makePromise(of: String.self)
        promise.succeed("Hello from future")
        return promise.futureResult
    }
    /*
    get("/customize") { req in
        status(200)
        contentType("application/json")
        json(["Hello"])
    }
    */
    /*
    get("/customize") { req in
        .json(["Hello"], status: 200, contentType: "application/json")
    }
    */
}

try! app.run(1337)

RunLoop.main.run()

// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import Foundation
import Swiftra

let app = App {
    get("/") { req in
        .text("Hello, world!")
    }

    // path parameters
    get("/hello/:name") { req in
        .text("Hello \(req.params("name") ?? "guest")")
    }

    // convert Encodable value into JSON
    get("/json") { req in
        Response(json: ["Hello": "World!"])!
    }

    // asynchronous
    futureGet("/future") { req in
        let promise = req.eventLoop.makePromise(of: String.self)
        _ = req.eventLoop.scheduleTask(in: .seconds(1)) {
            promise.succeed("Hello from future")
        }
        return promise.futureResult.map { .text($0) }
    }
}

// You can add routes
app.addRoutes {
    get("/addRoute") { req in
        .text("New route is added")
    }
}

try! app.start(1337)
while let line = readLine() {
    if line == "exit" {
        app.stop { (error) in
            if let error = error {
                print(error)
                exit(EXIT_FAILURE)
            } else {
                print("shutdown")
                exit(EXIT_SUCCESS)
            }
        }
    }
}

// try! app.start(1337)
// RunLoop.main.run()

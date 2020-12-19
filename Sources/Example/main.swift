// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import Foundation
import Swiftra

let app = App {
    get("/") { req in
        .text("Hello, world!")
    }

    get("/hello/:name") { req in
        .text("Hello \(req.params("name") ?? "guest")")
    }

    futureGet("/future") { req in
        let promise = req.eventLoop.makePromise(of: String.self)
        promise.succeed("Hello from future")
        return promise.futureResult.map { .text($0) }
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
//RunLoop.main.run()

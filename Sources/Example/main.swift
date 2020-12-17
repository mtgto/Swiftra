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
}

try! app.run(1337)

RunLoop.main.run()

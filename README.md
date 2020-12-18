# Swiftra

A tiny Sinatra-like web framework for Swift.

## Example

```swift
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
}

try! app.run(1337)
```

## Features

- Routing
- Access path parameter(s)

## Roadmap to v1.0.0

- [ ] Helper to access components of request header
  - [ ] query string
  - [ ] fragment
  - [ ] Cookie
- [ ] HTTP methods except for GET
- [ ] JSON request/response
- [ ] Error handling callback
- [ ] More performance

## License

Apache License 2.0.

See `LICENSE.txt`.

## Author

@mtgto

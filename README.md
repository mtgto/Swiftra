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

## Contributing

Please format swift code with [swift-format](https://github.com/apple/swift-format) before send your contribution.

```console
$ swift-format --configuration .swift-format --in-place YourAwesomeCode.swift
```

[pre-commit](https://pre-commit.com/) is recommended.

```console
$ brew install pre-commit
$ pre-commit install
```

## License

Apache License 2.0.

See `LICENSE.txt`.

## Author

@mtgto

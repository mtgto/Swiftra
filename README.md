# Swiftra

A tiny Sinatra-like web framework for Swift.

Swiftra is a small wrapper on [SwiftNIO](https://github.com/apple/swift-nio).

## Example

```swift
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
```

## Installation

Add `https://github.com/mtgto/Swiftra` to your dependencies of Swift Package.

## Features

- Routing
- Access path parameter(s)

## Roadmap to v1.0.0

- [ ] Helper to access components of request header
  - [ ] query string
  - [ ] fragment
  - [ ] Cookie
- [ ] HTTP methods except for `GET`
- [ ] JSON request/response
- [ ] Error handling
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

## Acknowledgements

Thanks a lot [A µTutorial on SwiftNIO 2](https://www.alwaysrightinstitute.com/microexpress-nio2/).

## License

Apache License 2.0.

See `LICENSE.txt`.

## Author

@mtgto

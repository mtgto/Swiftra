# Swiftra

[![Cocoapods](https://img.shields.io/cocoapods/v/Swiftra)](https://cocoapods.org/pods/Swiftra)
![Platforms](https://img.shields.io/cocoapods/p/Swiftra)
[![build status](https://github.com/mtgto/Swiftra/workflows/Swift/badge.svg)](https://github.com/mtgto/Swiftra/actions?query=workflow%3ASwift)

A tiny Sinatra-like web framework for Swift.

Swiftra is a small wrapper on [SwiftNIO](https://github.com/apple/swift-nio).

## Example

```swift
import Swiftra

struct ExampleError: Error {}

let app = App {
    get("/") { req in
        .text("Hello, world!")
    }

    get("/html") { req in
        .text("<html><body>Hello from Swiftra</body></html>", contentType: ContentType.textHtml.withCharset())
    }

    // path parameters
    get("/hello/:name") { req in
        .text("Hello \(req.params("name", default: "guest"))")
    }

    // convert Encodable value into JSON
    get("/json") { req in
        Response(json: ["Hello": "World!"])!
    }

    // asynchronous
    futureGet("/future") { req in
        let promise = req.makePromise(of: String.self)
        _ = req.eventLoop.scheduleTask(in: .seconds(1)) {
            promise.succeed("Hello from future")
        }
        return promise.futureResult.map { .text($0) }
    }

    // No route matches
    notFound { req in
        .text("Not Found", status: .notFound)
    }

    // Example of error handling. See also below `error`
    get("/error") { req in
        throw ExampleError()
    }

    // unhandled error handler
    error { req, error in
        .text("Error", status: .internalServerError)
    }
}

// You can add routes
app.addRoutes {
    get("/addRoute") { req in
        .text("New route is added")
    }
}

// Set default response headers
app.defaultHeaders = [("Server", "SwiftraExample/1.0.0")]

try! app.start(1337)
// You can customize bind address
// try! app.start(1337, host: "localhost")
```

## Installation

### Swift Package Manager (SPM)

Add `https://github.com/mtgto/Swiftra` to your dependencies of Swift Package.

### Cocoapods

Add `pod 'Swiftra', '~> 0.3'` to your Podfile.

## Features

- Routing
- Access path parameter(s)
- Access query paramter(s)

## Roadmap to v1.0.0

- [ ] Helper to access components of request header
  - [x] query string
  - [ ] fragment
  - [ ] Cookie
- [ ] Helper to access request body
  - [ ] x-www-form-urlencoded data
  - [ ] JSON request
- [ ] HTTP methods except for `GET`
- [x] Error handling
- [ ] File upload
  - [ ] Large file upload
- [ ] More performance

## Contributing

Format swift code with [swift-format](https://github.com/apple/swift-format) before send your contribution.

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

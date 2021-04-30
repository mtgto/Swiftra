CHANGELOG
====
## v0.5.0 (2021-04-30)

### Changed

- Support Swift 5.4 (`@resultHandler`)
- Refactor App source code
- Update SwiftNIO to 2.28.0

## v0.4.0 (2021-02-20)

### Added

- Add new method `Request.data()` to get request body

### Changed

- Update SwiftNIO to 2.26.0
- Add Ubuntu to test environment

## v0.3.1 (2021-01-01)

### Changed

- Call error handler for future handler
- Add missing argument of headers to create json response

## v0.3.0 (2020-12-28)

### Added

- Add accessor to set response headers
- Support default response headers

### Changed

- Set `charset=utf-8` to `Content-Type` header by default

## v0.2.1 (2020-12-26)

### Changed

- Fix status code of response code is always 200 OK

## v0.2.0 (2020-12-26)

### Added

- Support query params
- Add error handler
- Add default handler to handle no route is matched
- Add tests of Request

## v0.1.1 (2020-12-20)

### Changed

- Fix to create EventLoopGroup each app start

## v0.1.0 (2020-12-20)

- First release

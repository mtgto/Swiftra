// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import NIO
import NIOHTTP1

open class App {
    public var defaultHeaders: [(String, String)] = []
    private var loopGroup: EventLoopGroup! = nil
    private var routes: [Route]
    private var defaultHandler: Handler? = nil
    private var errorHandler: ErrorHandler? = nil

    public init(@DSLMaker routing: () -> [Route] = { () in [] }) {
        self.routes = []
        self.addRoutes(routes: routing())
    }

    public func addRoutes(@DSLMaker routing: () -> [Route]) {
        self.addRoutes(routes: routing())
    }

    private func addRoutes(routes: [Route]) {
        for route in routes {
            switch route.handler {
            case .error(let handler):
                self.errorHandler = handler
            case .normal(let handler):
                if route.matcher is AllMatcher {
                    self.defaultHandler = handler
                } else {
                    self.routes.append(route)
                }
            case .future(_):
                self.routes.append(route)
            }
        }
    }

    public func start(_ port: Int, host: String = "0.0.0.0") throws {
        self.loopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        let reuseAddrOpt = ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR)
        let bootstrap = ServerBootstrap(group: self.loopGroup)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(reuseAddrOpt, value: 1)
            .childChannelInitializer { (channel) -> EventLoopFuture<Void> in
                channel.pipeline.configureHTTPServerPipeline().flatMap {
                    channel.pipeline.addHandler(HTTPHandler(self))
                }
            }
            .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .childChannelOption(reuseAddrOpt, value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)

        let serverChannel = try bootstrap.bind(host: host, port: port).wait()
        #if DEBUG
            log.info("Server running on:", serverChannel.localAddress!)
        #endif
        //try serverChannel.closeFuture.wait()
    }

    public func stop(_ callback: @escaping (Error?) -> Void) {
        self.loopGroup.shutdownGracefully { (error) in
            self.loopGroup = nil
            callback(error)
        }
    }

    final class HTTPHandler: ChannelInboundHandler {
        typealias InboundIn = HTTPServerRequestPart

        private let app: App
        private var request: Request! = nil
        private var buffer: ByteBuffer! = nil

        init(_ app: App) {
            self.app = app
        }

        func handlerAdded(context: ChannelHandlerContext) {
            self.buffer = context.channel.allocator.buffer(capacity: 0)
        }

        private func handleResponse(channel: Channel, response: Response) {
            let responseData = response.data()
            let headers = self.app.defaultHeaders + response.createHeaders() + [("Content-Length", "\(responseData.count)")]
            let head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: response.status(), headers: HTTPHeaders(headers))
            _ = channel.write(HTTPServerResponsePart.head(head))
            let buffer = channel.allocator.buffer(bytes: responseData)
            _ = channel.write(HTTPServerResponsePart.body(.byteBuffer(buffer)))
            _ = channel.writeAndFlush(HTTPServerResponsePart.end(nil)).map {
                channel.close()
            }
        }

        func channelRead(context: ChannelHandlerContext, data: NIOAny) {
            let reqPart = unwrapInboundIn(data)

            switch reqPart {
            case .head(let header):
                self.buffer.clear()
                self.request = Request(header: header, remoteAddress: context.remoteAddress, eventLoop: context.eventLoop)
            case .body(buffer: var body):
                self.buffer.writeBuffer(&body)
            case .end:
                let channel = context.channel
                self.request.body = self.buffer
                do {
                    var found: Bool = false
                    for route in self.app.routes {
                        if case .success(let match) = route.matcher.match(method: self.request.header.method, path: self.request.path) {
                            self.request.match = .success(match)
                            if case .normal(let handler) = route.handler {
                                let response = try handler(self.request)
                                self.handleResponse(channel: channel, response: response)
                            } else if case .future(let handler) = route.handler {
                                handler(self.request).whenComplete { (result) in
                                    if case .success(let response) = result {
                                        self.handleResponse(channel: channel, response: response)
                                    } else if case .failure(let error) = result {
                                        #if DEBUG
                                            log.info("Error:", error)
                                        #endif
                                        if let handler = self.app.errorHandler {
                                            let response = handler(self.request, error)
                                            self.handleResponse(channel: channel, response: response)
                                        } else {
                                            self.handleResponse(
                                                channel: channel,
                                                response: .text(
                                                    "Internal Server Error", status: .internalServerError,
                                                    contentType: ContentType.textPlain.withCharset()))
                                        }
                                    }
                                }
                            }
                            found = true
                            break
                        }
                    }
                    if !found {
                        if let handler = self.app.defaultHandler {
                            let response = try handler(self.request)
                            self.handleResponse(channel: channel, response: response)
                        }
                    }
                } catch {
                    if let handler = self.app.errorHandler {
                        let response = handler(self.request, error)
                        self.handleResponse(channel: channel, response: response)
                    }
                }
            }
        }
    }
}

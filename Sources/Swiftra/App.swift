// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import NIO
import NIOHTTP1

open class App {
    private var loopGroup: EventLoopGroup! = nil
    private var routes: [Route]

    public init(@DSLMaker routing: () -> [Route] = { () in [] }) {
        self.routes = routing()
    }

    public func addRoutes(@DSLMaker routing: () -> [Route]) {
        self.routes = self.routes + routing()
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

        func handleResponse(channel: Channel, response: Response) {
            let responseData = response.data()
            let headers = response.createHeaders() + [("Content-Length", "\(responseData.count)")]
            let head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: .ok, headers: HTTPHeaders(headers))
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
                break
            case .body(buffer: var body):
                self.buffer.writeBuffer(&body)
                break
            case .end:
                let channel = context.channel
                _ = self.app.routes.contains { (route) -> Bool in
                    // TODO: parse uri to path and querystring and hash
                    if case .success(let match) = route.matcher.match(method: self.request.header.method, path: self.request.path) {
                        self.request.body = self.buffer
                        self.request.match = .success(match)
                        if case .normal(let handler) = route.handler {
                            let response = handler(self.request)
                            self.handleResponse(channel: channel, response: response)
                        } else if case .future(let handler) = route.handler {
                            handler(self.request).whenComplete { (result) in
                                if case .success(let response) = result {
                                    self.handleResponse(channel: channel, response: response)
                                } else if case .failure(let error) = result {
                                    // TODO: Call error handler
                                    #if DEBUG
                                        log.info("Error:", error)
                                    #endif
                                }
                            }
                        }
                        return true
                    }
                    return false
                }
            }
        }
    }
}

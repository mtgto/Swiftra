// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import NIO
import NIOHTTP1

open class App {
    private let loopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    private let routes: [Route]
    
    public init(@DSLMaker routing: () -> [Route]) {
        self.routes = routing()
        log.info("App.init")
    }
    
    public func run(_ port: Int) throws {
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

        // TODO: host should be customizable
        let serverChannel = try bootstrap.bind(host: "localhost", port: port).wait()
        #if DEBUG
        log.info("Server running on:", serverChannel.localAddress!)
        #endif
        //try serverChannel.closeFuture.wait()
    }
    
    final class HTTPHandler: ChannelInboundHandler {
        typealias InboundIn = HTTPServerRequestPart
        
        let app: App
        private var buffer: ByteBuffer! = nil
        
        init(_ app: App) {
            self.app = app
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
                let channel = context.channel
                var request = Request(header: header, eventLoop: context.eventLoop)
                let found = self.app.routes.contains { (route) -> Bool in
                    if route.method != request.header.method {
                        return false
                    }
                    // TODO: parse uri to path and querystring and hash
                    if case .success(let match) = route.pathMatcher.match(path: request.header.uri) {
                        request.match = .success(match)
                        if case .normal(let handler) = route.handler {
                            let response = handler(request)
                            self.handleResponse(channel: channel, response: response)
                        } else if case .future(let handler) = route.handler {
                            handler(request).whenComplete { (result) in
                                if case .success(let response) = result {
                                    self.handleResponse(channel: channel, response: response)
                                } else if case .failure(let error) = result {
                                    log.info("Error:", error)
                                }
                            }
                        }
                        return true
                    }
                    return false
                }
                if !found {
                    // TODO: Add notFound to DSL to customize.
                    let head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: .notFound, headers: HTTPHeaders())
                    _ = context.channel.writeAndFlush(HTTPServerResponsePart.head(head))
                    let buffer = context.channel.allocator.buffer(string: "Not Found")
                    _ = context.channel.writeAndFlush(HTTPServerResponsePart.body(.byteBuffer(buffer)))
                    _ = context.channel.writeAndFlush(HTTPServerResponsePart.end(nil)).map {
                        context.channel.close()
                    }
                }
                break
            case .body(buffer: let body):
                #if DEBUG
                log.info("Body:", body)
                #endif
                break
            case .end:
                #if DEBUG
                log.info("END")
                #endif
                break
            }
        }
    }
}

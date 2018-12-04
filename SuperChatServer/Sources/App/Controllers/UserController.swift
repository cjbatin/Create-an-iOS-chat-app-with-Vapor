import Vapor
import Foundation
import PerfectCrypto
import FluentSQLite

/// Controls basic CRUD operations on `Todo`s.
final class UserController {

    func find(_ req: Request) throws -> Future<User> {
        return try req.content.decode(User.self).flatMap({ user in
            return User.query(on: req).filter(\.name == user.name).first().map(to: User.self, { user in
                guard let user = user else {
                    throw Abort(.notFound)
                }
                return user
            })
        })
    }

    func create(_ req: Request) throws -> Future<User> {
        return try req.content.decode(User.self).flatMap { user in
            let chatkitEndPoint = "https://us1.pusherplatform.io/services/chatkit/v2/1848b958-7926-4708-8959-aad6ca8cfdd9/users"
            guard let url = URL(string: chatkitEndPoint) else {
                throw Abort.init(HTTPResponseStatus.internalServerError)
            }
            user.id = UUID.init()
            let newUser = user.create(on: req)
            newUser.save(on: req).whenSuccess({ _ in
                let bearer = BearerAuthorization.init(token: AuthController.createJWToken())
                _ = try! req.client().post(url) { post in
                    post.http.headers.bearerAuthorization = bearer
                    post.http.headers.add(name: HTTPHeaderName.contentType.description, value: "application/json")
                    try post.content.encode(User.init(id: user.id, name: user.name))
                }
            })
            return newUser
        }
    }
}

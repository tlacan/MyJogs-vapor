import Vapor
import Crypto
import Random
import FluentSQLite

final class UserController {

    /**
    * Create user and return id, a login must be done afterward to get the token
    * check that no user with same email already exists
    */
    func register(_ req: Request) throws -> Future<User.UserPublic> {
        return try req.content.decode(User.self).flatMap { user in
            return User.query(on: req).filter(\.email == user.email).first().flatMap { fetchedUser in
                if fetchedUser != nil {
                    throw Abort(HTTPStatus.conflict)
                }
            
                let hasher = try req.make(BCryptDigest.self)
                let passwordHashed = try hasher.hash(user.password)
                let newUser = User(email: user.email, password: passwordHashed)

                return newUser.save(on: req).map { storedUser in
                    return User.UserPublic(
                        id: try storedUser.requireID(),
                        email: storedUser.email
                    )
                }
            }
        }
    }

    /**
     * Return access token if login success
     */
    func login(_ req: Request) throws -> Future<Token> {
        return try req.content.decode(User.self).flatMap { user in
            return User.query(on: req).filter(\.email == user.email).first().flatMap { fetchedUser in
                guard let existingUser = fetchedUser else {
                    throw Abort(HTTPStatus.notFound)
                }

                let hasher = try req.make(BCryptDigest.self)
                if try hasher.verify(user.password, created: existingUser.password) {
                    return try Token
                        .query(on: req)
                        .filter(\Token.userId, .equal, existingUser.requireID())
                        .delete()
                        .flatMap { _ in
                        let tokenString = try URandom().generateData(count: 32).base64EncodedString()
                        let token = try Token(token: tokenString, userId: existingUser.requireID())
                        return token.save(on: req)
                    }
                } else {
                    throw Abort(HTTPStatus.unauthorized)
                }
            }
        }
    }

    /**
     * Return logged user data
     */
    func profile(_ req: Request) throws -> Future<String> {
        let user = try req.requireAuthenticated(User.self)
        return req.future("Welcome \(user.email)")
    }

    /**
     * Delete logged user token
     */
    func logout(_ req: Request) throws -> Future<HTTPResponse> {
        let user = try req.requireAuthenticated(User.self)
        return try Token
            .query(on: req)
            .filter(\Token.userId, .equal, user.requireID())
            .delete()
            .transform(to: HTTPResponse(status: .ok))
    }
    
    /**
     * Send email with password to the related user
     */
    func forgotPassword(_ req: Request) throws -> Future<HTTPResponse> {
        guard let email = req.query[String.self, at: "email"] else {
            throw Abort(.badRequest)
        }
        return User.query(on: req).filter(\.email == email).first().flatMap { fetchedUser in
            if fetchedUser != nil {
                throw Abort(HTTPStatus.badRequest)
            }
            // send email with passord
            
            return req.future(HTTPResponse(status: .ok))
        }
    }
    
    // TO DO: edit user
}

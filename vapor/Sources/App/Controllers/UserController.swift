//
//  JogsController.swift
//  App
//
//  Created by thomas lacan on 18/04/2019.
//

import Vapor
import Crypto
import Random
import FluentSQLite
import Mailgun

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
     * Delete logged user
     */
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        _ = try Token.query(on: req).filter(\Token.userId, .equal, user.requireID()).delete()
        return user.delete(on: req).transform(to: HTTPStatus.ok)
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
            // TODO: send email with passord
            return try req.view().render("lostPasswordEmail").flatMap { view in
                guard let contentTxt = String(data: view.data, encoding: .utf8) else {
                     throw Abort(HTTPStatus.badRequest)
                }
                let message = Mailgun.Message(
                    from: "postmaster@sandboxa7e601d25d8a40578e4a669f14ca36f5.mailgun.org",
                    to: "lacan.thomas@gmail.com",
                    subject: "lost password",
                    text: "",
                    html: contentTxt
                )
                
                let mailgun = try req.make(Mailgun.self)
                return try mailgun.send(message, on: req)
                                  .transform(to: (HTTPResponse(status: .ok)))
            }
        }
    }
    
    /**
     * Edit current user with data, check if no user with same email before update
     */
    func editUser(_ req: Request) throws -> Future<User.UserPublic> {
        let currentUser = try req.requireAuthenticated(User.self)
        return try req.content.decode(User.self).flatMap { user in
            return User.query(on: req).filter(\.email == user.email).first().flatMap { fetchedUser in
                if fetchedUser != nil && currentUser.id != fetchedUser?.id {
                    throw Abort(HTTPStatus.conflict)
                }
                
                let hasher = try req.make(BCryptDigest.self)
                let passwordHashed = try hasher.hash(user.password)
                
                currentUser.email = user.email
                currentUser.password = passwordHashed
                return currentUser.update(on: req).map { storedUser in
                    return User.UserPublic(
                        id: try storedUser.requireID(),
                        email: storedUser.email
                    )
                }
            }
        }
    }
}

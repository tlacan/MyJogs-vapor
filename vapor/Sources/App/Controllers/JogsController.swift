//
//  JogsController.swift
//  App
//
//  Created by thomas lacan on 18/04/2019.
//

import Foundation

import Vapor
import Crypto
import Random
import FluentSQLite

final class JogsController {

    /**
     * Create new jog and link it to logged user
     */
    func create(_ req: Request) throws -> Future<Jog> {
        let user = try req.requireAuthenticated(User.self)
        return try req.content.decode(Jog.self).flatMap { jog in
            var jogToSave = jog
            jogToSave.userId = try user.requireID()
            return jogToSave.save(on: req)
        }
    }
    
    /**
     * Update the jog data
     */
    func update(_ req: Request) throws -> Future<Jog> {
        let user = try req.requireAuthenticated(User.self)
        return try req.content.decode(Jog.self).flatMap { jog in
            let userId = try user.requireID()
            if userId != jog.userId {
                throw Abort(HTTPStatus.unauthorized)
            }
            return jog.update(on: req)
        }
    }
    
    /**
     * Delete the jog if this one is related to the current user
     */
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        let userId = try user.requireID()
        return try req.parameters.next(Jog.self).flatMap { jog in
            if userId != jog.userId {
                throw Abort(HTTPStatus.unauthorized)
            }
            return jog.delete(on: req).transform(to: .ok)
        }
    }
    
    /**
     * Return the list of logs for the current user
     */
    func list(_ req: Request) throws -> Future<[Jog]> {
        let user = try req.requireAuthenticated(User.self)
        let userId = try user.requireID()
        return Jog.query(on: req).filter(\.userId == userId).all()
    }
}

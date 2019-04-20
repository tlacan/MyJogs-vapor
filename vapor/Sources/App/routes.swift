//
//  JogsController.swift
//  App
//
//  Created by thomas lacan on 18/04/2019.
//

import Vapor

public func routes(_ router: Router) throws {

    let userController = UserController()
    let jogsController = JogsController()
    
    // public routes
    router.post("register", use: userController.register)
    router.post("login", use: userController.login)
    router.get("forgot-password", use: userController.forgotPassword)

    
    // private routes
    let tokenAuthenticationMiddleware = User.tokenAuthMiddleware()
    let authedRoutes = router.grouped(tokenAuthenticationMiddleware)
    
    // user routes
    authedRoutes.get("user", use: userController.profile)
    authedRoutes.put("user", use: userController.editUser)
    authedRoutes.get("logout", use: userController.logout)
    authedRoutes.delete("user", use: userController.delete)
    
    // jog routes
    authedRoutes.get("jogs", use: jogsController.list)
    authedRoutes.delete("jogs", Jog.parameter, use: jogsController.delete)
    authedRoutes.post("jogs", use: jogsController.create)
    authedRoutes.put("jogs", use: jogsController.update)
}

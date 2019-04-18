import Vapor

public func routes(_ router: Router) throws {

    let userController = UserController()
    router.post("register", use: userController.register)
    router.post("login", use: userController.login)

    let tokenAuthenticationMiddleware = User.tokenAuthMiddleware()
    let authedRoutes = router.grouped(tokenAuthenticationMiddleware)
    authedRoutes.get("profile", use: userController.profile)
    authedRoutes.get("logout", use: userController.logout)
}

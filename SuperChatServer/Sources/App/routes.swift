import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let userController = UserController()
    router.post("api", "users", "new", use: userController.create)
    router.post("api", "users", "login", use: userController.find)
}


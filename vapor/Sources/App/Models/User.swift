import FluentSQLite
import Vapor
import Authentication

final class User: SQLiteModel {
    var id: Int?
    var email: String
    var password: String

    init(id: Int? = nil, email: String, password: String) {
        self.id = id
        self.email = email
        self.password = password
    }
}

extension User: Content {}
extension User: Migration {}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension User {
    struct UserPublic: Content {
        let id: Int
        let email: String
    }
}

import FluentSQLite
import Authentication

final class Token: SQLiteModel {
    var id: Int?
    var token: String
    var userId: User.ID
 
    init(token: String, userId: User.ID) {
        self.token = token
        self.userId = userId
    }
}

extension Token {
    var user: Parent<Token, User> {
        return parent(\.userId)
    }
}

extension Token: BearerAuthenticatable {
    static var tokenKey: WritableKeyPath<Token, String> { return \Token.token }
}

extension Token: Authentication.Token {
    typealias UserType = User
    typealias UserIDType = User.ID

    static var userIDKey: WritableKeyPath<Token, User.ID> {
        return \Token.userId
    }
}

extension Token: Migration {}
extension Token: Content {}

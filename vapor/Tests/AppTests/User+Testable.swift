@testable import App
import FluentSQLite
import Crypto

extension User {
    static func create(email: String, on conn: SQLiteConnection) throws -> User {
        let password = try BCrypt.hash("password")
        let user = User(email: email, password: password)
        return try user.save(on: conn).wait()
    }
}

//
//  JogsController.swift
//  App
//
//  Created by thomas lacan on 18/04/2019.
//

import Vapor
import Leaf
import FluentSQLite
import Authentication
import Mailgun

/// Called before your application initializes.
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Templating + Auth + SQLite configuration
    let leafProvider = LeafProvider()
    try services.register(leafProvider)
    try services.register(FluentSQLiteProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    try services.register(AuthenticationProvider())

    // Data base configuration
    var databases = DatabasesConfig()
    try databases.add(database: SQLiteDatabase(storage: .memory), as: .sqlite)
    services.register(databases)

    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .sqlite)
    migrations.add(model: Token.self, database: .sqlite)
    migrations.add(model: Jog.self, database: .sqlite)
    services.register(migrations)

    // Mail provider configuration
    let mailgun = Mailgun(apiKey: "7c207fea1ae216a5371c21bfc81747ff-3fb021d1-94bd9c0e", domain: "https://localhost:8080")
    services.register(mailgun, as: Mailgun.self)
}

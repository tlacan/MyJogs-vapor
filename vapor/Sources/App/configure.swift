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

    let leafProvider = LeafProvider()
    try services.register(leafProvider)
    try services.register(FluentSQLiteProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    try services.register(AuthenticationProvider())

    var databases = DatabasesConfig()
    try databases.add(database: SQLiteDatabase(storage: .memory), as: .sqlite)
    services.register(databases)

    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .sqlite)
    migrations.add(model: Token.self, database: .sqlite)
    migrations.add(model: Jog.self, database: .sqlite)
    services.register(migrations)
}

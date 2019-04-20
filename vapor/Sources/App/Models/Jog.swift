//
//  Jog.swift
//  App
//
//  Created by thomas lacan on 18/04/2019.
//

import FluentSQLite
import Vapor

struct Jog: Content, SQLiteModel, Migration, Parameter {
    var id: Int?
    var userId: Int
    var position: [Position]
    var beginDate: Date
    var endDate: Date?
}

struct Position: Codable {
    let lat: Double
    let lon: Double
}

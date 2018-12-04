 import Vapor
 import FluentSQLite

 final class User: Codable {
    var id: UUID?
    var name: String

    init(name: String) {
        self.name = name
    }

    init(id: UUID?, name: String) {
        self.id = id
        self.name = name
    }
 }

extension User: Content {}
extension User: SQLiteUUIDModel {
    static func prepare(on connection: SQLiteConnection)
        -> Future<Void> {
            // 1
            return Database.create(self, on: connection) { builder in
                // 2
                try addProperties(to: builder)
                // 3
                builder.unique(on: \.name)
            }
    }
 }
extension User: Migration {}
extension User: Parameter {}

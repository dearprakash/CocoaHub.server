//
//  Event.swift
//  App
//
//  Created by Pedro Carrasco on 12/04/2019.
//

import Vapor
import FluentPostgreSQL
import Pagination

// MARK: - Event
final class Event {
    
    // MARK: Properties
    var id: Int?
    var name: String
    var logo: String
    var tags: [String]
    var url: String
    var country: String
    var city: String
    var coordinates: Coordinates?
    var startDate: Date
    var endDate: Date
    var isActive: Bool
    
    // MARK: Init
    init(name: String,
         logo: String,
         tags: [String],
         url: String,
         country: String,
         city: String,
         coordinates: Coordinates?,
         startDate: Date,
         endDate: Date,
         isActive: Bool
    ) {

        self.name = name
        self.logo = logo
        self.tags = tags
        self.url = url
        self.country = country
        self.city = city
        self.coordinates = coordinates
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
    }
}

// MARK: - PostgreSQLModel
extension Event: PostgreSQLModel {
    
    func willCreate(on conn: PostgreSQLConnection) throws -> EventLoopFuture<Event> {
        tags = tags.sorted()
        return Future.map(on: conn) { self }
    }
    
    func willUpdate(on conn: PostgreSQLConnection) throws -> EventLoopFuture<Event> {
        tags = tags.sorted()
        return Future.map(on: conn) { self }
    }
}

// MARK: - Content
extension Event: Content {}

// MARK: - Migration
extension Event: Migration {}

// MARK: - Parameter
extension Event: Parameter {}

// MARK: - Paginatable
extension Event: Paginatable {

    static var defaultPageSorts: [PostgreSQLOrderBy] {
        return [
            (\Event.startDate).querySort(.ascending)
        ]
    }
}

// MARK: - Validatable
extension Event: Validatable {
    
    static func validations() throws -> Validations<Event> {
        var validations = Validations(Event.self)
        try validations.add(\.url, .url)
        validations.add("Tags must be valid") {
            guard !Tags.containsInvalidTags($0.tags, for: .event) else {
                throw Abort(.internalServerError, reason: "Contains invalid tags")
            }
        }
        return validations
    }
}

// MARK: - Update
extension Event {
    
    @discardableResult
    func update(with event: Event) -> Event {
        name = event.name
        logo = event.logo
        tags = event.tags
        url = event.url
        country = event.country
        city = event.city
        coordinates = event.coordinates
        startDate = event.startDate
        endDate = event.endDate
        isActive = event.isActive
        
        return self
    }
}

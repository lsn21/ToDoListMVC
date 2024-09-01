//
//  ToDoRecord.swift
//  ToDoListMVC
//
//  Created by SIARHEI LUKYANAU on 26.08.2024.
//

import Foundation

struct ToDoRecord: Codable {
    
    var id: Int?
    var todo: String?
    var description: String?
    var date: Date?
    var completed: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case todo
        case description
        case date
        case completed
    }
}

struct ToDoAnswer: Codable {
    
    let total: Int?
    let limit: Int?
    let skip: Int?
    var todos: [ToDoRecord]?
    
    private enum CodingKeys: String, CodingKey {
        case total
        case limit
        case skip
        case todos
    }
}

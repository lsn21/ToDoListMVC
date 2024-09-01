//
//  StorageService.swift
//  ToDoListMVC
//
//  Created by SIARHEI LUKYANAU on 27.08.2024.
//

import UIKit
import CoreData

protocol StorageServiceProtocol: AnyObject {
    func loadTodos() -> [ToDoRecord]?
    func saveTodos(_ toDoRecords: [ToDoRecord]?)
    func addTodo(_ todo: ToDoRecord)
    func updateTodo(_ todo: ToDoRecord)
    func deleteTodo(_ id: Int)
    func getNextId() -> Int
}

class StorageService: NSObject, StorageServiceProtocol {
    
    private override init() {}
    
    public static var shared = StorageService()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // Контекст для работы с Core Data
    var context: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - Core Data methods
    
    // загружаем данные из БД
    func loadTodos() -> [ToDoRecord]? {
        let request: NSFetchRequest<ToDoEntity> = ToDoEntity.fetchRequest()
        var toDoRecords = [ToDoRecord]()

        do {
            var toDoEntities = [ToDoEntity]()
            toDoEntities = try context.fetch(request)
            toDoEntities.forEach { toDoEntity in
                var toDoRecord = ToDoRecord()
                toDoRecord.id = Int(toDoEntity.id)
                toDoRecord.todo = toDoEntity.todo
                toDoRecord.description = toDoEntity.descript
                toDoRecord.date = toDoEntity.date
                toDoRecord.completed = toDoEntity.completed
                toDoRecords.append(toDoRecord)
            }
        } catch {
            print("Error fetching data from context \(error)")
        }
        return toDoRecords
    }
    
    // сохраняем данные полученные с сервера в БД
    func saveTodos(_ toDoRecords: [ToDoRecord]?) {
        for todo in (toDoRecords ?? [ToDoRecord]()) {
            let todoEntity = ToDoEntity(context: context)
            if let id = todo.id {
                todoEntity.id = Int16(id)
                todoEntity.todo = todo.todo ?? ""
                todoEntity.descript = todo.description ?? ""
                todoEntity.completed = todo.completed ?? false
                todoEntity.date = todo.date ?? Date()
            }
        }
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    // добавляем новую запись в БД
    func addTodo(_ todo: ToDoRecord) {
        let todoEntity = ToDoEntity(context: context)
        if let id = todo.id {
            todoEntity.id = Int16(id)
            todoEntity.todo = todo.todo ?? ""
            todoEntity.descript = todo.description ?? ""
            todoEntity.completed = todo.completed ?? false
            todoEntity.date = todo.date ?? Date()
            do {
                try context.save()
            } catch {
                print("Error saving context \(error)")
            }
        }
    }
    
    // обновляем существующую запись в БД
    func updateTodo(_ todo: ToDoRecord) {
        if let id = todo.id {
            let fetchRequest: NSFetchRequest<ToDoEntity> = ToDoEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", id)
            
            do {
                // Получаем массив существующих записей
                let existingTodos = try context.fetch(fetchRequest)

                // Проверяем, найдена ли запись
                if let todoEntity = existingTodos.first {
                    // Обновляем атрибуты
                    todoEntity.todo = todo.todo ?? ""
                    todoEntity.descript = todo.description ?? ""
                    todoEntity.completed = todo.completed ?? false
                    todoEntity.date = todo.date ?? Date()

                    // Сохраняем изменения
                    try context.save()
                    print("Задача обновлена.")
                } else {
                    print("Задача с id \(id) не найдена.")
                }
            } catch {
                print("Ошибка при обновлении задачи: \(error)")
            }
        }
    }
    
    // удаляем запись в БД по id
    func deleteTodo(_ id: Int) {
        // Создаем запрос для поиска записи с заданным id
        let fetchRequest: NSFetchRequest<ToDoEntity> = ToDoEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)

        do {
            // Получаем массив существующих записей
            let existingTodos = try context.fetch(fetchRequest)
            
            // Проверяем, найдена ли запись
            if let todoToDelete = existingTodos.first {
                // Удаляем объект из контекста
                context.delete(todoToDelete)
                
                // Сохраняем изменения
                try context.save()
                print("Задача с id \(id) удалена.")
            } else {
                print("Задача с id \(id) не найдена.")
            }
        } catch {
            print("Ошибка при удалении задачи: \(error)")
        }
    }
    
    // находим id для новой записи
    func getNextId() -> Int {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ToDoEntity.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = ["id"]
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.fetchLimit = 1  // Ограничиваем выборку до одной записи

        do {
            let results = try context.fetch(fetchRequest)
            if let lastId = results.first as? [String: Any], let id = lastId["id"] as? Int16 {
                return Int(id) + 1 // Увеличиваем максимальный id на 1
            }
        } catch {
            print("Ошибка при получении максимального id: \(error)")
        }
        return 1 // Если записи нет, начинаем с 1
    }
}

import Foundation
import Combine

class TodoStore: ObservableObject {
    static let shared = TodoStore()
    
    @Published var todos: [TodoItem] = []
    @Published var notes: [NoteItem] = []
    
    private let filePath: URL
    private let notesFilePath: URL
    
    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let zenithDir = appSupport.appendingPathComponent("Zenith")
        try? FileManager.default.createDirectory(at: zenithDir, withIntermediateDirectories: true)
        
        filePath = zenithDir.appendingPathComponent("todos.json")
        notesFilePath = zenithDir.appendingPathComponent("notes.json")
        
        load()
    }
    
    func addTodo(_ text: String) {
        let todo = TodoItem(id: UUID(), text: text, isCompleted: false, createdAt: Date(), completedAt: nil)
        todos.append(todo)
        saveTodos()
    }
    
    func toggleTodo(_ id: UUID) {
        if let index = todos.firstIndex(where: { $0.id == id }) {
            todos[index].isCompleted.toggle()
            todos[index].completedAt = todos[index].isCompleted ? Date() : nil
            saveTodos()
        }
    }
    
    func deleteTodo(_ id: UUID) {
        todos.removeAll { $0.id == id }
        saveTodos()
    }
    
    func addNote(_ text: String) {
        let note = NoteItem(id: UUID(), text: text, createdAt: Date())
        notes.insert(note, at: 0)
        saveNotes()
    }
    
    func deleteNote(_ id: UUID) {
        notes.removeAll { $0.id == id }
        saveNotes()
    }
    
    private func load() {
        loadTodos()
        loadNotes()
    }
    
    private func loadTodos() {
        guard let data = try? Data(contentsOf: filePath),
              let items = try? JSONDecoder().decode([TodoItem].self, from: data) else { return }
        todos = items
    }
    
    private func loadNotes() {
        guard let data = try? Data(contentsOf: notesFilePath),
              let items = try? JSONDecoder().decode([NoteItem].self, from: data) else { return }
        notes = items
    }
    
    private func saveTodos() {
        guard let data = try? JSONEncoder().encode(todos) else { return }
        try? data.write(to: filePath)
    }
    
    private func saveNotes() {
        guard let data = try? JSONEncoder().encode(notes) else { return }
        try? data.write(to: notesFilePath)
    }
}

struct TodoItem: Codable, Identifiable {
    let id: UUID
    var text: String
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?
}

struct NoteItem: Codable, Identifiable {
    let id: UUID
    var text: String
    var createdAt: Date
}

import Foundation
import Combine

enum AIPersonality: String, Codable, CaseIterable {
    case friendly
    case efficient
    
    var displayName: String {
        switch self {
        case .friendly: return "Friendly"
        case .efficient: return "Efficient"
        }
    }
    
    var systemPrompt: String {
        switch self {
        case .friendly:
            return "You are a helpful, warm assistant. Use conversational language, occasionally add light humor, and be encouraging. Keep responses concise but friendly."
        case .efficient:
            return "You are a precise, no-nonsense assistant. Provide direct answers with minimal filler. Prioritize clarity and brevity."
        }
    }
}

struct AIResponse {
    let content: String
    let isComplete: Bool
    let error: Error?
}

class AIHelper: ObservableObject {
    static let shared = AIHelper()
    
    @Published var isLoading = false
    @Published var currentResponse = ""
    @Published var lastError: String?
    
    var apiKey: String? {
        get { UserDefaults.standard.string(forKey: "zenithAIApiKey") }
        set { UserDefaults.standard.set(newValue, forKey: "zenithAIApiKey") }
    }
    
    var personality: AIPersonality {
        get {
            let raw = UserDefaults.standard.string(forKey: "zenithAIPersonality") ?? "efficient"
            return AIPersonality(rawValue: raw) ?? .efficient
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "zenithAIPersonality") }
    }
    
    var isConfigured: Bool {
        return apiKey != nil && !apiKey!.isEmpty
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func setApiKey(_ key: String) {
        apiKey = key
    }
    
    func query(_ question: String, completion: @escaping (AIResponse) -> Void) {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            completion(AIResponse(content: "API key not configured. Please add your API key in Settings.", isComplete: true, error: nil))
            return
        }
        
        isLoading = true
        currentResponse = ""
        lastError = nil
        
        let systemMessage = personality.systemPrompt
        
        let messages: [[String: Any]] = [
            ["role": "system", "content": systemMessage],
            ["role": "user", "content": question]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "max_tokens": 500,
            "stream": true
        ]
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            isLoading = false
            let error = NSError(domain: "AIHelper", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completion(AIResponse(content: "", isComplete: true, error: error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            isLoading = false
            completion(AIResponse(content: "", isComplete: true, error: error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.lastError = error.localizedDescription
                    completion(AIResponse(content: "", isComplete: true, error: error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    let error = NSError(domain: "AIHelper", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    self?.lastError = error.localizedDescription
                    completion(AIResponse(content: "", isComplete: true, error: error))
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    DispatchQueue.main.async {
                        self?.currentResponse = content
                        completion(AIResponse(content: content, isComplete: true, error: nil))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self?.lastError = "Failed to parse response"
                    completion(AIResponse(content: "", isComplete: true, error: error))
                }
            }
        }
        
        task.resume()
    }
    
    func clearResponse() {
        currentResponse = ""
        lastError = nil
        isLoading = false
    }
}

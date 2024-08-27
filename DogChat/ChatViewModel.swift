//
//  ChatViewModel.swift
//  DogChat
//
//  Created by jason wan on 2024-08-26.
//

import Foundation

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputText: String = ""

    func sendMessage() {
        // Debug: Log the function call
        print("sendMessage() called")
        
        let userMessage = Message(text: inputText, isUser: true)
        
        // Debug: Log the user message
        print("User message: \(userMessage.text)")
        
        messages.append(userMessage)
        inputText = ""
        
        // Debug: Log message list after adding user message
        print("Messages after adding user message: \(messages.map { $0.text })")
        
        fetchResponse(for: userMessage.text)
    }

    private func fetchResponse(for input: String) {
        // Update the URL to use a compatible endpoint
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("Error: Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer mytoken", forHTTPHeaderField: "Authorization")
        
        // Update the JSON payload to use the correct format for chat models
        let json: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": input]
            ],
            "max_tokens": 50
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("Error: Failed to serialize JSON")
            return
        }
        
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Error: No data received")
                return
            }
            
            // Debug: Log the raw response data
            print("Raw response data: \(String(data: data, encoding: .utf8) ?? "N/A")")
            
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let choices = jsonResponse["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let text = message["content"] as? String {
                
                // Debug: Log the text received from the API
                print("Response text from API: \(text)")
                
                DispatchQueue.main.async {
                    let botMessage = Message(text: text.trimmingCharacters(in: .whitespacesAndNewlines), isUser: false)
                    
                    // Debug: Log the bot message
                    print("Bot message: \(botMessage.text)")
                    
                    self.messages.append(botMessage)
                    
                    // Debug: Log message list after adding bot message
                    print("Messages after adding bot message: \(self.messages.map { $0.text })")
                }
            } else {
                print("Error: Failed to parse JSON response")
            }
        }.resume()
    }

}



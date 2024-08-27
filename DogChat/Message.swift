//
//  Message.swift
//  DogChat
//
//  Created by jason wan on 2024-08-26.
//

import Foundation


struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

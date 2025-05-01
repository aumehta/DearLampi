//
//  Message.swift
//  Dear Lampi
//
//  Created by Arohi Mehta on 4/27/25.
//

import Foundation

struct Message: Identifiable {
    let id: Int64
    let sender: String
    let recipient: String
    let text: String
    let timestamp: Date
}


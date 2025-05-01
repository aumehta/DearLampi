//
//  MessageHistoryView.swift
//  Dear Lampi
//
//  Created by Arohi Mehta on 4/27/25.
//
import SwiftUI
struct MessageHistoryView: View {
    @State private var messages: [Message] = []
    var currentUsername: String  // <-- PASS THIS IN

    var body: some View {
        List(messages) { message in
            VStack(alignment: .leading) {
                Text("To: \(message.recipient)")
                Text("Message: \(message.text)")
                Text("Sent at: \(message.timestamp.formatted())")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            messages = DatabaseManager.shared.fetchMessages(currentUsername: currentUsername)
            print(messages)
            print(currentUsername)
        }
    }
}


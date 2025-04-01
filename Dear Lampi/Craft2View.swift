import SwiftUI

struct Craft2View: View {
    var selectedBackground: String
    @State private var message: String = ""

    var body: some View {
        VStack {
            Image(selectedBackground)
                .resizable()
                .scaledToFit()
                .frame(height: 200)

            TextField("Enter message", text: $message)
                .padding()
                .background(Color.white.opacity(0.3))
                .cornerRadius(10)
            
            HStack {
                Button("Text") {
                    // Add text feature
                }
                .padding()
                .background(Color.white.opacity(0.3))
                .cornerRadius(10)

                Button("Stickers") {
                    // Add sticker feature
                }
                .padding()
                .background(Color.white.opacity(0.3))
                .cornerRadius(10)
            }

            Button(action: {
                print("Message Sent: \(message)")
            }) {
                Text("Send")
                    .font(.headline)
                    .padding()
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
    }
}


import SwiftUI

struct Craft2View: View {
    var selectedBackground: String
    var selectedAlert:String
    var recipientIP: String  // From database
    var recipientDeviceID: String  // From database
    
    @State private var message: String = ""
    @StateObject private var mqttManager = MQTTManager()
    
    var body: some View {
        VStack {
            // Status indicator
            HStack {
                Circle()
                    .fill(mqttManager.connectionStatus.contains("Connected") ? Color.green : Color.red)
                    .frame(width: 10, height: 10)
                Text(mqttManager.connectionStatus)
                    .font(.caption)
                Spacer()
            }
            .padding(.horizontal)
            
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
                // Create topic with recipient's device ID
                let topic = "swift/lampi/\(recipientDeviceID)"
                
                mqttManager.publishLampiMessage(background:selectedBackground, alertLight:selectedAlert, message: message, to: topic)
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
        .onAppear {
            // Connect to MQTT broker
            mqttManager.connect(host:recipientIP)
        }
        .onDisappear {
            // Disconnect when the view disappears
            mqttManager.disconnect()
        }
    }
}

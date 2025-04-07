import SwiftUI

struct Craft2View: View {
    var selectedBackground: String
    var selectedAlert: String
    var recipientIP: String  // From database
    var recipientDeviceID: String  // From database
    
    @State private var message: String = ""
    @StateObject private var mqttManager = MQTTManager()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background Color
            Color(hex: "FFF5F5")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Status indicator
                HStack {
                    Circle()
                        .fill(mqttManager.connectionStatus.contains("Connected") ? Color.green : Color.red)
                        .frame(width: 10, height: 10)
                    Text(mqttManager.connectionStatus)
                        .font(.caption)
                        .foregroundColor(Color(hex: "530000"))
                    Spacer()
                }
                .padding(.horizontal)
                
                Image(selectedBackground)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(15)
                    .padding(.bottom, 20)

                TextField("Enter message", text: $message)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .foregroundColor(Color(hex: "530000"))
                    .padding(.horizontal)
                
                Button(action: {
                    // Create topic with recipient's device ID
                    let topic = "swift/lampi/\(recipientDeviceID)"
                    dismiss()
                    
                    mqttManager.publishLampiMessage(background: selectedBackground, alertLight: selectedAlert, message: message, to: topic)
                }) {
                    Text("Send")
                        .font(.custom("Cantora One", size: 18))
                        .padding()
                        .frame(width: 200)
                        .background(Color(hex: "530000"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            // Connect to MQTT broker
            mqttManager.connect(host: recipientIP)
        }
        .onDisappear {
            // Disconnect when the view disappears
            mqttManager.disconnect()
        }
    }
}


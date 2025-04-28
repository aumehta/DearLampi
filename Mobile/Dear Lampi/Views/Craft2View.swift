import SwiftUI

struct Craft2View: View {
    var selectedBackground: String
    var selectedAlert: String
    var recipientName: String
    var recipientDeviceID: String
    var isGif: Bool

    @State private var message: String = ""
    @StateObject private var mqttManager = MQTTManager(port: 50001)
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(hex: "FFF5F5").ignoresSafeArea()

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

                // Show GIF or Background
                if isGif {
                    GIFView(gifName: selectedBackground)
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 300)
                        .cornerRadius(15)
                        .padding(.bottom, 20)
                } else {
                    Image(selectedBackground)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(15)
                        .padding(.bottom, 20)
                }

                // Only show text field if it's NOT a GIF
                if !isGif {
                    TextField("Enter message", text: $message)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(Color(hex: "530000"))
                        .padding(.horizontal)
                }

                // Send Button
                Button(action: {
                    let topic = "devices/\(recipientDeviceID)/swift/lampi"
                    let messageToSend = isGif ? "this is a gif" : message

                    mqttManager.publishLampiMessage(background: selectedBackground, alertLight: selectedAlert, message: messageToSend, to: topic, isGif: isGif)

                    if !isGif {
                        DatabaseManager.shared.saveMessage(
                            sender: "current_user",   // replace this later with actual user
                            recipient: recipientName,
                            text: message
                        )
                    }

                    dismiss()
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
            mqttManager.connect(host: "ec2-98-82-250-240.compute-1.amazonaws.com")
        }
        .onDisappear {
            mqttManager.disconnect()
        }
    }
}


import SwiftUI

struct ContentView: View {
    // Use @StateObject to bind MQTTManager to the view lifecycle
    @ObservedObject private var mqttManager = MQTTManager()
    
    var body: some View {
        NavigationView {
            VStack {
                // Status and connection controls
                HStack {
                    Text("Status: \(mqttManager.connectionStatus)")
                        .foregroundColor(mqttManager.connectionStatus == "Connected to MQTT Broker" ? .green : .red)
                    Spacer()
                    Button(action: {
                        if mqttManager.connectionStatus == "Connected to MQTT Broker" {
                            mqttManager.disconnect()
                        } else {
                            mqttManager.connect()
                        }
                    }) {
                        Text(mqttManager.connectionStatus == "Connected to MQTT Broker" ? "Disconnect" : "Connect")
                            .padding()
                            .background(mqttManager.connectionStatus == "Connected to MQTT Broker" ? Color.red : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                // Quick message buttons
                HStack {
                    Button("Send Hello World") {
                        mqttManager.sendHelloWorld()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Clear Messages") {
                        mqttManager.receivedMessages = []
                    }
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                // Custom message sender
                VStack {
                    TextField("Custom topic", text: $mqttManager.customTopic)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    HStack {
                        TextField("Message to send", text: $mqttManager.messageToSend)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Send") {
                            if !mqttManager.messageToSend.isEmpty && !mqttManager.customTopic.isEmpty {
                                mqttManager.publish(message: mqttManager.messageToSend, to: mqttManager.customTopic)
                                mqttManager.messageToSend = ""
                            }
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(mqttManager.messageToSend.isEmpty || mqttManager.customTopic.isEmpty)
                    }
                    .padding(.horizontal)
                }
                
                // Received messages list
                List {
                    Section(header: Text("Received Messages")) {
                        ForEach(mqttManager.receivedMessages.reversed()) { message in
                            VStack(alignment: .leading) {
                                Text("Topic: \(message.topic)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Text(message.message)
                                    .fontWeight(.medium)
                                Text(message.formattedTime)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("LAMPI MQTT Client")
            .onAppear {
                // Auto-connect when the view appears
                mqttManager.connect()
            }
            .onDisappear {
                // Disconnect when the view disappears
                mqttManager.disconnect()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


import SwiftUI
import Combine
import CocoaMQTT

// MARK: - MQTT Message
struct MQTTMessage: Identifiable {
    let id = UUID()
    let topic: String
    let message: String
    let timestamp: Date
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: timestamp)
    }
}

// MARK: - MQTT Manager
class MQTTManager: ObservableObject {
    @Published var connectionStatus: String = "Disconnected"
    @Published var receivedMessages: [MQTTMessage] = []
    @Published var customTopic: String = "swift/lampi/custom"  // Default topic
    @Published var messageToSend: String = ""
    
    private var mqttClient: CocoaMQTT?
    private let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    
    // MQTT settings
    private var host: String
    private var port: UInt16
    
    init(host: String = "172.20.117.149", port: UInt16 = 1883) {
        self.host = host
        self.port = port
    }
    
    func connect() {
        let clientID = "SwiftUI_\(deviceID)_\(Int(Date().timeIntervalSince1970))"
        
        mqttClient = CocoaMQTT(clientID: clientID, host: host, port: UInt16(port))
        mqttClient?.keepAlive = 60
        mqttClient?.delegate = self
        
        // Optional authentication if your broker requires it
        // mqttClient?.username = "username"
        // mqttClient?.password = "password"
        
        _ = mqttClient?.connect()
    }
    
    func disconnect() {
        mqttClient?.disconnect()
    }
    
    func subscribe(to topic: String) {
        mqttClient?.subscribe(topic, qos: .qos1)
    }
    
    func publish(message: String, to topic: String) {
        mqttClient?.publish(topic, withString: message, qos: .qos1)
    }
    
    // Send a simple hello world message to the LAMPI
    func sendHelloWorld() {
        publish(message: "Hello from Swift App!", to: "swift/lampi/LAMPI-b827eb23402e")
    }
    
    // Subscribe to LAMPI discovery topic
    func subscribeToLampiDiscovery() {
        subscribe(to: "lampi/discovery/+")
    }
    // Subscribe only to lampi topics
    func subscribeToLampiTopics() {
        subscribe(to: "lampi/discovery/+")  // Discovery messages
        subscribe(to: "lampi/hello")        // Hello messages from LAMPI
        subscribe(to: "lampi/status")       // Any status updates from LAMPI
        subscribe(to: "lampi/config")       // Configuration messages if needed
    }

    
    // Subscribe to hello messages from LAMPI
    func subscribeToHelloMessages() {
        subscribe(to: "lampi/hello")
    }
}

// MARK: - CocoaMQTT Delegate Extension
extension MQTTManager: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        DispatchQueue.main.async {
            if ack == .accept {
                self.connectionStatus = "Connected to MQTT Broker"
                self.subscribeToLampiTopics()  // Only subscribe to lampi topics
            } else {
                self.connectionStatus = "Connection failed: \(ack)"
            }
        }
    }

    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("Published message to \(message.topic)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        // Nothing to do here
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        if let messageString = message.string {
            let receivedMessage = MQTTMessage(
                topic: message.topic,
                message: messageString,
                timestamp: Date()
            )
            
            DispatchQueue.main.async {
                self.receivedMessages.append(receivedMessage)
            }
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        for topic in success.allKeys {
            print("Subscribed to \(topic)")
        }
        
        if !failed.isEmpty {
            print("Failed to subscribe to: \(failed.joined(separator: ", "))")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("Unsubscribed from \(topics.joined(separator: ", "))")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        // Ping sent
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        // Pong received
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        DispatchQueue.main.async {
            self.connectionStatus = "Disconnected"
            if let error = err {
                print("Disconnected with error: \(error.localizedDescription)")
            }
        }
    }
}

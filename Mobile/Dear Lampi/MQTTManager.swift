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
    @Published var messageToSend: String = ""
    @Published var customTopic: String = "swift/lampi/custom"  // Default topic
    var host: String = ""
    var port: UInt16
    
    private var mqttClient: CocoaMQTT?
    private let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    
    
    init(port: UInt16 = 50001) {
        self.port = port
    }
    
    
    func connect(host:String) {
        let clientID = "SwiftUI_\(deviceID)_\(Int(Date().timeIntervalSince1970))"
        mqttClient?.enableSSL = false
        self.host = host
        
        mqttClient = CocoaMQTT(clientID: clientID, host: host, port: UInt16(port))
        mqttClient?.keepAlive = 60
        mqttClient?.delegate = self
        
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
    
    func publishLampiMessage(background: String, alertLight: String, message: String, to topic: String, isGif: Bool) {
        print("Publishing message...")
        
        var base64ImageString: String = ""
        
        if isGif {
            // If it's a GIF, read it manually from the bundle
            if let gifURL = Bundle.main.url(forResource: background, withExtension: "gif"),
               let gifData = try? Data(contentsOf: gifURL) {
                base64ImageString = gifData.base64EncodedString()
                print("was able to encode gif")
            } else {
                print("Failed to load GIF \(background)")
                return
            }
        } else {
            // Otherwise, it's a normal image
            guard let image = UIImage(named: background),
                  let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("Failed to load normal image \(background)")
                return
            }
            base64ImageString = imageData.base64EncodedString()
        }
        
        let payload: [String: Any] = [
            "background": base64ImageString,
            "alert_light": alertLight,
            "message": message
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Failed to serialize JSON payload.")
            return
        }
        
        mqttClient?.publish(topic, withString: jsonString, qos: .qos1)
    }
}

// MARK: - CocoaMQTT Delegate Extension
extension MQTTManager: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        DispatchQueue.main.async {
            if ack == .accept {
                self.connectionStatus = "Connected to MQTT Broker"
            } else {
                self.connectionStatus = "Connection failed: \(ack)"
            }
        }
    }

    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("Published message to \(message.topic)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
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

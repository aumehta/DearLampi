import Foundation
import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()
    var db: Connection?

    // Table and columns
    let users = Table("users")
    let id = SQLite.Expression<Int64>("id")
    let username = SQLite.Expression<String>("username")
    let deviceID = SQLite.Expression<String>("device_id")
    let uniqueCode = SQLite.Expression<String>("unique_code")
    let friends = SQLite.Expression<String>("friends") // Stores friends as comma-separated values
    let password = SQLite.Expression<String>("password") // 👈 NEW
    
    let messages = Table("messages")
    let messageID = SQLite.Expression<Int64>("id")
    let senderUsername = SQLite.Expression<String>("sender_username")
    let recipientDeviceID = SQLite.Expression<String>("recipient_device_id")
    let messageText = SQLite.Expression<String>("message_text")
    let timestamp = SQLite.Expression<Date>("timestamp")



    private init() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            db = try Connection("\(path)/mydatabase.sqlite3")
            createTable()
        } catch {
            print("Database connection failed: \(error)")
        }
    }

    func createTable() {
        do {
            try db?.run(users.create(ifNotExists: true) { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(username, unique: true)
                table.column(password)
                table.column(deviceID)
                table.column(uniqueCode, unique: true)
                table.column(friends, defaultValue: "")
            })

            try db?.run(messages.create(ifNotExists: true) { table in
                table.column(messageID, primaryKey: .autoincrement)
                table.column(senderUsername)
                table.column(recipientDeviceID)
                table.column(messageText)
                table.column(timestamp)
            })

            print("Tables created successfully")
        } catch {
            print("Table creation failed: \(error)")
        }
    }

    
    func validateUser(username: String, password: String) -> Bool {
        do {
            let query = users.filter(self.username == username && self.password == password)
            if let _ = try db?.pluck(query) {
                return true
            }
        } catch {
            print("Error validating user: \(error)")
        }
        return false 
    }


    func addUser(username: String, password: String, deviceID: String, uniqueCode: String) {
        do {
            let insert = users.insert(
                self.username <- username,
                self.password <- password,
                self.deviceID <- deviceID,
                self.uniqueCode <- uniqueCode,
                self.friends <- "" // Initialize empty friends list
            )
            try db?.run(insert)
            print("User added successfully")
            fetchUsers()
        } catch {
            print("Insert failed: \(error)")
        }
    }
    
    func getFriendDetails(friendUsername: String) -> String? {
        do {
            let query = users.filter(self.username == friendUsername)
            
            if let friendRow = try db?.pluck(query) {
                let deviceID = friendRow[self.deviceID]
                return deviceID
            } else {
                print("Friend not found in the database.")
                return nil
            }
        } catch {
            print("Error fetching friend details: \(error)")
            return nil
        }
    }


    // Fetch users (for testing purposes)
    func fetchUsers() {
        do {
            for user in try db!.prepare(users) {
                print("User: \(user[username]), UniqueCode: \(user[uniqueCode])")
            }
        } catch {
            print("Fetch failed: \(error)")
        }
    }

    
    // Find a user by username
    func findUser(byUniqueCode code: String) -> Row? {
        do {
            let query = users.filter(self.uniqueCode == code)
            return try db?.pluck(query)
        } catch {
            print("User not found: \(error)")
            return nil
        }
    }

    func addFriend(currentUsername: String, friendUniqueCode: String) {
        guard let friendRow = findUser(byUniqueCode: friendUniqueCode) else {
            print("Friend not found")
            return
        }

        let friendUsername = friendRow[username]

        do {
            let query = users.filter(self.username == currentUsername)
            if let userRow = try db?.pluck(query) {
                var friendList = userRow[friends].split(separator: ",").map { String($0) }

                if !friendList.contains(friendUsername) {
                    friendList.append(friendUsername)
                    let updatedFriends = friendList.joined(separator: ",")
                    try db?.run(query.update(self.friends <- updatedFriends))
                    print("Friend added successfully")
                } else {
                    print("Friend already added")
                }
            }
        } catch {
            print("Error adding friend: \(error)")
        }
    }

    func getFriends(forUsername username: String) -> [String] {
        do {
            let query = users.filter(self.username == username)
            if let userRow = try db?.pluck(query) {
                let friendsString = userRow[friends]
                print("test")
                print(friendsString)
                print(friendsString.split(separator: ",").map { String($0) })  // Fixed parentheses here
                return friendsString.isEmpty ? [] : friendsString.split(separator: ",").map { String($0) }
            }
        } catch {
            print("Error fetching friends: \(error)")
        }
        return []
    }
    func getUniqueCode(forUsername username: String) -> String? {
        do {
            let query = users.filter(self.username == username)
            if let userRow = try db?.pluck(query) {
                let code = userRow[uniqueCode]
                print("Unique code for \(username): \(code)")
                return code
            }
        } catch {
            print("Error fetching unique code for username \(username): \(error)")
        }
        return nil
    }

    
    func saveMessage(sender: String, recipient: String, text: String, time: Date = Date()) {
        do {
            let insert = messages.insert(
                senderUsername <- sender,
                recipientDeviceID <- recipient,
                messageText <- text,
                timestamp <- time
            )
            try db?.run(insert)
            print("Message saved successfully")
        } catch {
            print("Failed to save message: \(error)")
        }
    }
    
    func fetchMessages() -> [Message] {
        var fetchedMessages: [Message] = []
        do {
            if let db = db {
                for row in try db.prepare(messages) {
                    let message = Message(
                        id: row[messageID],
                        sender: row[senderUsername],
                        recipient: row[recipientDeviceID],
                        text: row[messageText],
                        timestamp: row[timestamp]
                    )
                    fetchedMessages.append(message)
                }
            }
        } catch {
            print("Failed to fetch messages: \(error)")
        }
        return fetchedMessages
    }



    
}


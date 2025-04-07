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
    let ipAddress = SQLite.Expression<String>("ip_address")
    let uniqueCode = SQLite.Expression<String>("unique_code")
    let friends = SQLite.Expression<String>("friends") // Stores friends as comma-separated values

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
                table.column(deviceID)
                table.column(ipAddress)
                table.column(uniqueCode, unique: true)
                table.column(friends, defaultValue: "") // Stores as comma-separated values
            })
            print("Table created successfully")
        } catch {
            print("Table creation failed: \(error)")
        }
    }

    func addUser(username: String, deviceID: String, ipAddress: String, uniqueCode: String) {
        do {
            let insert = users.insert(
                self.username <- username,
                self.deviceID <- deviceID,
                self.ipAddress <- ipAddress,
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
    
    func getFriendDetails(friendUsername: String) -> (ipAddress: String?, deviceID: String?)? {
        do {
            let query = users.filter(self.username == friendUsername)
            
            if let friendRow = try db?.pluck(query) {
                let ipAddress = friendRow[self.ipAddress]
                let deviceID = friendRow[self.deviceID]
                return (ipAddress, deviceID)
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
                print("User: \(user[username]), IP: \(user[ipAddress]), UniqueCode: \(user[uniqueCode]), Friends: \(user[friends])")
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

    
}


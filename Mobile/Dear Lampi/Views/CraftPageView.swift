import SwiftUI

struct CraftPageView: View {
    @State private var selectedFriend: String? = nil
    @State private var selectedBackground: String = "bg1"
    @State private var selectedAlert: String = "Rainbow"
    @State private var navigateToCraft2 = false
    @State private var showAddFriendModal = false
    @State private var uniqueCode = ""
    @State private var friends: [String] = []
    var currentUsername: String

    private let backgrounds = ["bg1", "bg2"]
    private let alerts = ["Rainbow", "Heartbeat", "Twinkle"]

    init(currentUsername: String) {
        self.currentUsername = currentUsername
    }

    var body: some View {
        NavigationView {
            ZStack {
                RadialGradient(
                    gradient: Gradient(colors: [Color(hex: "FF996D"), Color(hex: "F99D9D")]),
                    center: .center,
                    startRadius: 0,
                    endRadius: UIScreen.main.bounds.width
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Send a Message")
                        .font(.custom("Cantora One", size: 28))
                        .bold()
                        .padding(.bottom, 10)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("My Friends")
                            .font(.custom("Cantora One", size: 18))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 15) {
                            Button(action: { showAddFriendModal.toggle() }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(width: 70, height: 70)
                                    .background(Color.white.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            ForEach(friends, id: \.self) { friend in
                                Button(action: {
                                    selectedFriend = friend
                                    print("Selected Friend: \(friend)")  // Print selected friend to console
                                    
                                }) {
                                    VStack {
                                        Text(friend)
                                            .font(.custom("Cantora One", size: 16))
                                            .foregroundColor(.black)
                                    }
                                    .frame(width: 70, height: 70)
                                    .background(selectedFriend == friend ? Color.white.opacity(0.5) : Color.white.opacity(0.2))
                                    .clipShape(Circle())
                                }
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Background")
                            .font(.custom("Cantora One", size: 18))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(backgrounds, id: \.self) { bg in
                                    Image(bg)
                                        .resizable()
                                        .frame(width: 80, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(selectedBackground == bg ? Color.white : Color.clear, lineWidth: 2)
                                        )
                                        .onTapGesture { selectedBackground = bg }
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Alert Light")
                            .font(.custom("Cantora One", size: 18))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 15) {
                            ForEach(alerts, id: \.self) { alert in
                                Button(action: { selectedAlert = alert }) {
                                    Text(alert)
                                        .font(.custom("Cantora One", size: 16))
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(selectedAlert == alert ? Color.black.opacity(0.8) : Color.black.opacity(0.6))
                                        .cornerRadius(10)
                                }
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                    
                    NavigationLink(destination: Craft2View(selectedBackground: selectedBackground), isActive: $navigateToCraft2) {
                        Button(action: { navigateToCraft2 = true }) {
                            Text("Next")
                                .font(.custom("Cantora One", size: 18))
                                .padding()
                                .frame(width: 150)
                                .background(Color.pink)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $showAddFriendModal) {
            AddFriendModal(uniqueCode: $uniqueCode, friends: $friends, currentUsername: currentUsername, onFriendAdded: fetchFriends)
        }
        .onAppear {
            fetchFriends()
        }

    }
    // In CraftPageView
    func fetchFriends() {
        // Fetch friends from the database when the view appears
        friends = DatabaseManager.shared.getFriends(forUsername: currentUsername)
        print("Friends fetched: \(friends)")  // Debug print to verify the result
    }
}


// Modal View for Entering Unique Code
struct AddFriendModal: View {
    @Binding var uniqueCode: String
    @Binding var friends: [String]
    var currentUsername: String  // Add this line
    @Environment(\.presentationMode) var presentationMode
    @State private var errorMessage: String? = nil
    @State private var isFriendAdded: Bool = false
    var onFriendAdded: () -> Void  // Add this callback

    var body: some View {
        VStack {
            Text("Insert Unique Code")
                .font(.title2)
                .bold()
                .padding()

            TextField("Enter unique code", text: $uniqueCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button(action: {
                addFriend()
            }) {
                Text("Submit")
                    .font(.headline)
                    .padding()
                    .frame(width: 150)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            if isFriendAdded {
                Text("Friend added successfully!")
                    .foregroundColor(.green)
                    .padding()
            }

            Spacer()
        }
        .padding()
    }

    private func addFriend() {
         // Get the current user's username (assuming it's stored in UserDefaults or passed into the modal)
         let currentUsername = currentUsername

         // Try to add the friend
         if let friend = DatabaseManager.shared.findUser(byUniqueCode: uniqueCode) {
             let friendUniqueCode = friend[DatabaseManager.shared.uniqueCode]
             DatabaseManager.shared.addFriend(currentUsername: currentUsername, friendUniqueCode: friendUniqueCode)

             // If friend is added successfully, show a success message
             isFriendAdded = true
             errorMessage = nil
             
             // Call the callback to refresh the friends list
             onFriendAdded()
             
             DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                 presentationMode.wrappedValue.dismiss()
             }
         } else {
             errorMessage = "User with this unique code not found."
             isFriendAdded = false
         }
     }
}


// Extension to create Color from hex string
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


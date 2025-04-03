import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var deviceID = ""
    @State private var ipAddress = "" // User will input IP address
    @State private var friends = "" // User will input IP address
    @State private var uniqueCode = UUID().uuidString.prefix(8).description // Generate short unique code
    @State private var isNavigationActive = false // State to control navigation

    var body: some View {
        NavigationView {
            ZStack {
                // Background radial gradient
                RadialGradient(
                    gradient: Gradient(colors: [Color(hex: "FF996D"), Color(hex: "F99D9D")]),
                    center: .center,
                    startRadius: 0,
                    endRadius: UIScreen.main.bounds.width
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Login")
                        .font(.custom("Cantora One", size: 28))
                        .bold()
                        .padding(.bottom, 10)
                        .foregroundColor(.white)
                    
                    TextField("Enter Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)

                    TextField("Enter Device ID", text: $deviceID)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)

                    TextField("Enter IP Address", text: $ipAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)

                    NavigationLink(destination: CraftPageView(currentUsername: username), isActive: $isNavigationActive) {
                        EmptyView()
                    }

                    Button(action: {
                        saveUser()
                    }) {
                        Text("Generate & Save")
                            .font(.custom("Cantora One", size: 18))
                            .padding()
                            .frame(width: 200)
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    func saveUser() {
        if username.isEmpty || ipAddress.isEmpty {
            print("Username or IP Address cannot be empty")
            return
        }

        DatabaseManager.shared.addUser(
            username: username,
            deviceID: deviceID,
            ipAddress: ipAddress,
            uniqueCode: uniqueCode
        )
        isNavigationActive = true
    }
}

struct NextView: View {
    var body: some View {
        Text("Welcome to the Next View!")
            .font(.largeTitle)
            .bold()
            .padding()
    }
}


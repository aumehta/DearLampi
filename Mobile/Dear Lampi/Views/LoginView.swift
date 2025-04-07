import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var deviceID = ""
    @State private var ipAddress = ""
    @State private var uniqueCode = UUID().uuidString.prefix(8).description
    @State private var isNavigationActive = false
    @State private var showAlert = false

    var body: some View {
            ZStack {
                RadialGradient(
                    gradient: Gradient(colors: [Color(hex: "FF996D"), Color(hex: "F99D9D")]),
                    center: .center,
                    startRadius: 0,
                    endRadius: UIScreen.main.bounds.width
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20){
                    Image("dear_lampi_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    
                    Text("Dear Lampi")
                        .font(.custom("Cantora One", size: 40))
                        .fontWeight(.heavy)
                        .foregroundColor(Color(hex: "530000"))

                    // Login Form
                    VStack(spacing: 15) {
                        TextField("Enter Username", text: $username)
                            .padding()
                            .background(Color.white) // Background color is white
                            .cornerRadius(10)
                            .foregroundColor(Color(hex: "530000")) // Text color set to your hex value

                        TextField("Enter Device ID", text: $deviceID)
                            .padding()
                            .background(Color.white) // Background color is white
                            .cornerRadius(10)
                            .foregroundColor(Color(hex: "530000")) // Text color set to your hex value

                        TextField("Enter IP Address", text: $ipAddress)
                            .padding()
                            .background(Color.white) // Background color is white
                            .cornerRadius(10)
                            .foregroundColor(Color(hex: "530000")) // Text color set
                        
                        NavigationLink(destination: CraftPageView(currentUsername: username), isActive: $isNavigationActive) {
                            EmptyView()
                        }
                        
                        Button(action: {
                            if username.isEmpty || ipAddress.isEmpty {
                                showAlert = true
                            } else {
                                saveUser()
                            }
                        }) {
                            Text("Create User")
                                .font(.custom("Cantora One", size: 18))
                                .padding()
                                .frame(width: 200)
                                .background(Color(hex: "530000"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Invalid Input"), message: Text("Username and IP Address cannot be empty."), dismissButton: .default(Text("OK")))
                        }
                    }
                    .padding(.horizontal)
                    .navigationBarBackButtonHidden(true)
                }
        }
    }
    
    func saveUser() {
        DatabaseManager.shared.addUser(
            username: username,
            deviceID: deviceID,
            ipAddress: ipAddress,
            uniqueCode: uniqueCode
        )
        isNavigationActive = true
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}


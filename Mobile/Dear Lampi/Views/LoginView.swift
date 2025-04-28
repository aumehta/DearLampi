import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var deviceID = ""
    @State private var password = ""
    @State private var uniqueCode = UUID().uuidString.prefix(8).description
    @State private var isNavigationActive = false
    @State private var showAlert = false
    @State private var isSignUp = true // 👈 NEW: Track if we're in SignUp or Login mode

    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [Color(hex: "FF996D"), Color(hex: "F99D9D")]),
                center: .center,
                startRadius: 0,
                endRadius: UIScreen.main.bounds.width
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("dear_lampi_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
                Text("Dear Lampi")
                    .font(.custom("Cantora One", size: 40))
                    .fontWeight(.heavy)
                    .foregroundColor(Color(hex: "530000"))

                VStack(spacing: 15) {
                    TextField("Enter Username", text: $username)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(Color(hex: "530000"))

                    SecureField("Enter Password", text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(Color(hex: "530000"))

                    if isSignUp { // 👈 Only show Device ID if signing up
                        TextField("Enter Device ID", text: $deviceID)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .foregroundColor(Color(hex: "530000"))
                    }

                    NavigationLink(destination: CraftPageView(currentUsername: username), isActive: $isNavigationActive) {
                        EmptyView()
                    }

                    Button(action: {
                        if username.isEmpty || password.isEmpty || (isSignUp && deviceID.isEmpty) {
                            // 👆 check deviceID only if it's sign up
                            showAlert = true
                        } else {
                            if isSignUp {
                                saveUser()
                            } else {
                                if DatabaseManager.shared.validateUser(username: username, password: password) {
                                    isNavigationActive = true
                                } else {
                                    showAlert = true
                                }
                            }
                        }
                    }) {
                        Text(isSignUp ? "Sign Up" : "Log In")
                            .font(.custom("Cantora One", size: 18))
                            .padding()
                            .frame(width: 200)
                            .background(Color(hex: "530000"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Invalid Input"), message: Text("Please fill in all fields correctly."), dismissButton: .default(Text("OK")))
                    }

                    Button(action: {
                        isSignUp.toggle()
                    }) {
                        Text(isSignUp ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                            .font(.custom("Cantora One", size: 14))
                            .foregroundColor(Color(hex: "530000"))
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
            password: password, // 👈 you must pass password too now
            deviceID: deviceID,
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


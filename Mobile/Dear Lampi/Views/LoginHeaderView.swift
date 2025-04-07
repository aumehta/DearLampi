import SwiftUI

struct LoginHeaderView: View {
    @State private var navigateToLogin = false // State to trigger navigation

    var body: some View {
        NavigationView { // Wrap the entire VStack in a NavigationView
            ZStack { // Use ZStack to layer the background and content
                
                // Background gradient
                RadialGradient(
                    gradient: Gradient(colors: [Color(hex: "FF996D"), Color(hex: "F99D9D")]),
                    center: .center,
                    startRadius: 0,
                    endRadius: UIScreen.main.bounds.width
                )
                .ignoresSafeArea() // Ensures the gradient fills the entire screen

                VStack(spacing: 20) {
                    Image("dear_lampi_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    
                    Text("Dear Lampi")
                        .font(.custom("Cantora One", size: 40))
                        .fontWeight(.heavy)
                        .foregroundColor(Color(hex: "530000"))
                    
                    // NavigationLink to LoginView
                    NavigationLink(destination: LoginView(), isActive: $navigateToLogin) {
                        Button(action: {
                            navigateToLogin = true
                        }) {
                            Text("Login")
                                .font(.custom("Cantora One", size: 18))
                                .padding()
                                .frame(width: 150)
                                .background(Color(hex: "530000"))
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
}


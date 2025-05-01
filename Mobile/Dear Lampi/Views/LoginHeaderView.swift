import SwiftUI
//DearLampi login page
struct LoginHeaderView: View {
    @State private var navigateToLogin = false 

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
                    Image("dear_lampi_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    
                    Text("Dear Lampi")
                        .font(.custom("Cantora One", size: 40))
                        .fontWeight(.heavy)
                        .foregroundColor(Color(hex: "530000"))
                    
                    NavigationLink(destination: LoginView(), isActive: $navigateToLogin) {
                        Button(action: {
                            navigateToLogin = true
                        }) {
                            Text("Login/Signup")
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


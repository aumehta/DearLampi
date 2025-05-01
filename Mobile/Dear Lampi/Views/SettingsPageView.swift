import SwiftUI
//Settings page
struct SettingsPageView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoggedOut = false
    @State private var showFriends = false
    @State private var userUniqueCode: String = "" 
    var currentUsername: String

    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [Color(hex: "FF996D"), Color(hex: "F99D9D")]),
                center: .center,
                startRadius: 0,
                endRadius: UIScreen.main.bounds.width
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("Settings")
                    .font(.custom("Cantora One", size: 40))
                    .foregroundColor(Color(hex: "530000"))
                    .padding(.top, 30)

                // Card for Unique Code
                VStack(spacing: 10) {
                    Text("My Unique Code")
                        .font(.custom("Cantora One", size: 22))
                        .foregroundColor(Color(hex: "530000"))

                    Text(userUniqueCode)
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(hex: "530000"))
                        .padding()
                        .frame(maxWidth: .infinity)  // 👉 ADD THIS!
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(15)
                }
                .padding()
                .background(Color.white.opacity(0.3))
                .cornerRadius(20)
                .padding(.horizontal)

                // Buttons Section
                VStack(spacing: 20) {
                    Button(action: {
                        showFriends = true
                    }) {
                        Text("View My Friends")
                            .font(.custom("Cantora One", size: 20))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "530000"))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 30)
                    .sheet(isPresented: $showFriends) {
                        FriendsListView(currentUsername: currentUsername)
                    }

                    Button(action: {
                        isLoggedOut = true
                    }) {
                        Text("Logout")
                            .font(.custom("Cantora One", size: 20))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.8)) // Different color for "Logout"
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 30)
                    .fullScreenCover(isPresented: $isLoggedOut) {
                        LoginHeaderView()
                    }
                }

                Spacer()
            
            }
            .padding()
        }
        .onAppear {
            // Fetch unique code when view appears
            if let code = DatabaseManager.shared.getUniqueCode(forUsername: currentUsername) {
                userUniqueCode = code
            } else {
                userUniqueCode = "Unavailable"
            }
        }
        .navigationBarBackButtonHidden(false)
    }
}


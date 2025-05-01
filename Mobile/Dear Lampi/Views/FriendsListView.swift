import SwiftUI

//This is the page that contains all of the friends 
struct FriendsListView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var friends: [String] = []
    
    var currentUsername: String  

    var body: some View {
        ZStack {
            Color(hex: "FFF5F5").ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("My Friends")
                    .font(.custom("Cantora One", size: 30))
                    .foregroundColor(Color(hex: "530000"))
                    .padding()

                if friends.isEmpty {
                    Text("You have no friends added yet.")
                        .foregroundColor(Color(hex: "530000"))
                        .padding()
                } else {
                    List(friends, id: \.self) { friend in
                        Text(friend)
                            .font(.custom("Cantora One", size: 20))
                            .foregroundColor(Color(hex: "530000"))
                    }
                    .listStyle(PlainListStyle())
                }
                
                Spacer()
            }
        }
        .onAppear {
            friends = DatabaseManager.shared.getFriends(forUsername: currentUsername)
        }
    }
}


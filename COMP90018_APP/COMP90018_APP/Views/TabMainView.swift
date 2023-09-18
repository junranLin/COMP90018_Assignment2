//
//  TabView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI

struct TabMainView: View {
    @State var shakeResult: String = ""
    
    var body: some View {
        TabView{
            PostsView()
                .navigationBarBackButtonHidden(true)
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Posts")
                }

            ProfileView()
                .navigationBarBackButtonHidden(true)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
        
    }
}

struct TabView_Previews: PreviewProvider {
    static var previews: some View {
            TabMainView()
    }
}

//
//  PostsView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/9/2023.
//

import SwiftUI

struct PostsView: View {
    @State var shakeResult: String  = ""
    @State private var searchCategory: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView{
            VStack{
                Text("This is the posts view!")
                Text("Here is your shake result: \(shakeResult)")
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }.foregroundColor(.black)
                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    NavigationLink {
//                        ShakeView()
//                    } label: {
//                        Image(systemName: "dice")
//                    }
//
//                }
            }
        }
    }
}

//struct PostsView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostsView()
//    }
//}

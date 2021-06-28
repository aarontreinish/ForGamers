//
//  HomeView.swift
//  ForGamers
//
//  Created by Aaron Treinish on 6/1/21.
//

import SwiftUI

struct NavView: View {
    
    var colWidth: CGFloat
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.fixed(colWidth)), GridItem(.fixed(colWidth)), GridItem(.fixed(colWidth))], content: {
            Spacer()
            Text("ForGamers")
            Button(action: {
                print("NEW POST")
            }, label: {
                Text("New Post")
            })
        })
    }
}

struct PostsListView: View {
    @ObservedObject var viewModel = PostsViewModel() // (/1)
    
    var body: some View {
        NavigationView {
            List(viewModel.sortedPosts) { post in
                Text(post.postTitle)
            }

            .navigationBarTitle("Posts")
            .onAppear() { // (3)
                self.viewModel.getPostsForUserJoinedCommunities()
            }
        }
    }
}

struct HomeTabView: View {
    var body: some View {
        GeometryReader { geometry in
            let colWidth = geometry.size.width / 3
            
            TabView {
                ScrollView {
                    PostsListView()
                }
                .tabItem { Image(systemName: "house.fill") }
                
                NavigationView {
                    VStack {
                        
                    }
                } .tabItem { Image(systemName: "camera") }
                
                NavigationView {
                    VStack {
                        
                    }
                } .tabItem { Image(systemName: "house.fill") }
            }
        }
    }
}

struct HomeView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
    }
}

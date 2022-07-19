import SwiftUI

enum HomeDestination: String, CaseIterable, Hashable {
    case hot, best, trending, new, top, rising
}
enum SubredditDestination: String, CaseIterable, Hashable {
    case news, diablo, pics, wtf, games, movies
}

enum UserDestination: String, CaseIterable, Hashable {
    case profile, inbox, posts, comments, saved
}

enum Destination: Hashable {
    case home(home: HomeDestination)
    case subreddit(subreddit: SubredditDestination)
    case user(user: UserDestination)
    case post(post: Post)
}

struct MainView: View {
    @State private var sidebarDestination: Set<Destination> = Set(arrayLiteral: .subreddit(subreddit: .games))
    @State private var detailNavigation: Destination?
    
    var body: some View {
        NavigationSplitView {
            SidebarView(destination: $sidebarDestination)
        } content: {
            switch sidebarDestination.first {
            case .home(let destination):
                HomeView(destination: destination)
            case .subreddit(let subreddit):
                SubredditView(subreddit: subreddit, destination: $detailNavigation)
            case .user(let destination):
                AccountView(destination: destination)
            case .post(let post):
                PostView(post: post)
            case .none:
                EmptyView()
            }
        } detail: {
            NavigationStack {
                Group {
                    if let detailNavigation {
                        switch detailNavigation {
                        case .post(let post):
                            PostView(post: post)
                            
                        default:
                            Text("Please select a post")
                        }
                    } else {
                        Text("Please select a post")
                    }
                }.navigationDestination(for: Destination.self) { destination in
                    switch destination {
                    case .user(let userDestination):
                        AccountView(destination: userDestination)
                    default:
                        Text("Not supported here")
                    }
                }
            }
        }
        
    }
}

struct SidebarView: View {
    @Binding var destination: Set<Destination>
    
    var body: some View {
        List(selection: $destination, content: {
            Section("Home") {
                ForEach(HomeDestination.allCases, id: \.self) { homeItem in
                    NavigationLink(value: Destination.home(home: homeItem)) {
                        Label(homeItem.rawValue.capitalized, systemImage: "globe")
                    }
                }
            }
            
            Section("Subreddit") {
                ForEach(SubredditDestination.allCases, id: \.self) { subreddit in
                    NavigationLink(value: Destination.subreddit(subreddit: subreddit)) {
                        Label(subreddit.rawValue.capitalized, systemImage: "globe")
                    }
                }
            }
            
            
            Section("Account") {
                ForEach(UserDestination.allCases, id: \.self) { userDestination in
                    NavigationLink(value: Destination.user(user: userDestination)) {
                        Label(userDestination.rawValue.capitalized, systemImage: "globe")
                    }
                }
            }
        })
    }
}


struct Post: Identifiable, Hashable {
    let id = UUID()
    let title = "A post title"
    let preview = "Some wall of text to represent the preview of a post that nobody will read if the title is not a clickbait"
}

struct SubredditView: View {
    let subreddit: SubredditDestination
    @Binding var destination: Destination?
    @State private var posts: [Post] = [Post(), Post(), Post(), Post(), Post(), Post(), Post(), Post()]
    
    var body: some View {
        List(posts, selection: $destination) { post in
            NavigationLink(value: Destination.post(post: post)) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(post.title)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text(post.preview)
                            .font(.callout)
                    }
                }
            }
        }.navigationTitle(subreddit.rawValue.capitalized)
    }
}

struct PostView: View {
    let post: Post
    
    var body: some View {
        VStack {
            Text(post.title)
                .font(.title)
            Text(post.preview)
            NavigationLink(value: Destination.user(user: .comments)) {
                Text("See some sub navigation")
            }
        }
    }
}

struct AccountView: View {
    let destination: UserDestination
    
    var body: some View {
        Text(destination.rawValue.capitalized)
    }
}

struct HomeView: View {
    let destination: HomeDestination
    
    var body: some View {
        Text(destination.rawValue.capitalized)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

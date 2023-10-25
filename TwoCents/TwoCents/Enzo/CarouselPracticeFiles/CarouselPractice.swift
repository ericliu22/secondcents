//
//  CarouselPractice.swift
//  TwoCents
//
//  Created by Enzo Tanjutco on 10/6/23.
//

import SwiftUI

struct CarouselPractice: View {
    
    @State var currentIndex: Int = 0
    @State var posts: [PostModel] = []
    
    
    var body: some View {
        NavigationStack{
            ZStack{
                
                VStack(spacing: 15) {
                    VStack(alignment: .leading, spacing: 12) {
                        Button {
                        } label: {
                            Label {
                                Text("Back")
                            } icon: {
                                Image(systemName: "chevron.left")
                                    .font(.title2.bold())
                            }
                            .foregroundColor(.primary)
                        }
                        
                        Text ("For all the Dogs")
                            .font(.title)
                            .fontWeight(.black)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    //Segment Control
                    HStack(spacing: 0){
                    }
                    
                    //Snap Carousel
                    SnapCarouselPractice(index: $currentIndex, items: posts) { post in
                        
                        GeometryReader{proxy in
                            
                            let size = proxy.size
                            
                            Image(post.postImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width)
                                .cornerRadius(12)
                        }
                        
                    }
                    
                    .padding(.vertical, 40)
                    
                    HStack(spacing: 10) {
                        ForEach(posts.indices, id: \.self) { index in
                            Circle()
                                .fill(Color.black.opacity(currentIndex == index ? 1 : 0.1))
                                .frame(width: 10, height: 10)
                                .scaleEffect(currentIndex == index ? 1.4 : 1)
                                .animation(.spring(), value: currentIndex == index)
                        }
                    }
                    
                }
                
            }
            .background(
                ZStack{
                    Color("SabotageBg")
                        .edgesIgnoringSafeArea(.all)
                    Image("eric-pic")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 1000, height: 1000)
                        .blur(radius: 80)
                }
                )
            
            .frame(maxWidth: .infinity, alignment: .top)
            
            .onAppear {
                for index in 1...4 {
                    posts.append(PostModel(postImage: "post\(index)"))
                    print("The posts are: \(posts)")
                }
            }
        }
    }
}

struct TestTest: View {
    var body: some View {
        Text("plz work")
    }
}

struct CarouselPractice_Previews: PreviewProvider {
    static var previews: some View {
        CarouselPractice()
    }
}

//Tab Button

//struct TabButton: View {
//    var title: String
//    var animation: Namespace.ID
//    @Binding var currentTab: String
//    var body: some View {
//        Button {
//            withAnimation(.spring()){
//                currentTab = title
//            }
//        } label: {
//            Text(title)
//                .fontWeight(.bold)
//                .foregroundColor(currentTab == title ? .white : .black)
//                .frame(maxWidth: .infinity)
//                .padding(.vertical, 8)
//                .background
//        }
//
//    }
//}

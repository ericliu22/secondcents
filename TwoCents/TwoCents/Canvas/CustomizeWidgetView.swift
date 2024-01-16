//
//  CustomizeWidgetView.swift
//  TwoCents
//
//  Created by jonathan on 1/14/24.
//

import SwiftUI
import PhotosUI


struct CustomizeWidgetView: View {
    @Binding var showNewWidgetView: Bool
    @Binding var showCustomizeWidgetView: Bool
    
    
    
    @State private var url: URL? = nil
    
    @StateObject private var viewModel = CustomizeWidgetViewModel()
    
    @State private var selectedPhoto: PhotosPickerItem? = nil
    
    
    
    var body: some View {
        
        VStack {
            ZStack{
                
                
                //Circle or Profile Pic
                
                if let urlString = viewModel.space?.profileImageUrl, let url = URL(string: urlString) {
                    
                    
                    //If there is URL for profile pic, show
                    //circle with stroke
                 
                            //profile pic in middle
                            AsyncImage(url: url) {image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    
                                
                            } placeholder: {
                                //else show loading after user uploads but sending/downloading from database
                                
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemBackground)))
                                    .scaleEffect(1.5, anchor: .center)
                                    .background(
                                        Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 250, height: 250)
                                    )
                                    
                            }
                            
                        
                        .frame(width: 250, height: 250)
                    
                    .frame(width: 250, height: 250)
                    .shadow(radius: 20, y: 10)
                    .cornerRadius(30)
                  
                    
                } else {
                    
                    //if user has not uploaded profile pic, show circle
                    Rectangle()
                    
//                        .strokeBorder(selectedColor, lineWidth:15)
                        .fill(Color.accentColor)
                        .frame(width: 250, height: 250)
                        .shadow(radius: 20, y: 10)
                        .cornerRadius(30)
                }
                
                
                
                
                PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()){
                   
                    
                    ZStack{
                        
                        Circle()
                            .fill(Color(UIColor.systemBackground))
                            .frame(width: 64, height: 64)
                        
                        Circle()
                            .fill(.thinMaterial)
                            .frame(width: 64, height: 64)
                        
                        Circle()
//                            .fill(selectedColor)
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(UIColor.systemBackground))
                        
                        
                    }
                    
                    
                }
               
                .offset(x:60, y:60)
                
                 
            }
           
            
            Button {
                                    showCustomizeWidgetView = false
                                    showNewWidgetView = false
                
            } label: {
                Text("Done")
                    .font(.headline)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
            }
            
            
            .buttonStyle(.bordered)
//            .tint(selectedColor)
            .frame(height: 55)
            .cornerRadius(10)
            .padding(.horizontal)
            
            
            
            
//
//
//
//
//            Button {
//
//
//
//            } label: {
//                Text("Done")
//                    .font(.headline)
//
//                    .frame(height: 55)
//                    .frame(maxWidth: .infinity)
//
//            }
//
//            .buttonStyle(.bordered)
////            .tint(selectedColor)
//            .frame(height: 55)
//            .cornerRadius(10)
//            .padding(.horizontal)
//
//
//
            
            
            
        }
     
        
        .onChange(of: selectedPhoto, perform: { newValue in
            if let newValue {
                viewModel.saveProfileImage(item: newValue)
            }
        })
        .navigationTitle("Customize Profile 🎨")
    }
    
    
}
    
//    let blur: CGFloat = 60
    
    
    
    
//
//    var body: some View {
//        //        Button(action: {
//        //            showCustomizeWidgetView = false
//        //            showNewWidgetView = false
//        //        }, label: {
//        //            /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
//        //        })
//        
//        
//        
//        
//        
//        
//        GeometryReader { proxy in
//            ZStack {
//                
//                
//                ZStack {
//                    Cloud(proxy: proxy,
//                          color: .accentColor,
//                          rotationStart: 0,
//                          duration: 60,
//                          alignment: .bottomTrailing)
//                    Cloud(proxy: proxy,
//                          color: .accentColor,
//                          rotationStart: 90,
//                          duration: 50,
//                          alignment: .topTrailing)
//                    Cloud(proxy: proxy,
//                          color: .accentColor,
//                          rotationStart: 180,
//                          duration: 80,
//                          alignment: .bottomLeading)
//                    Cloud(proxy: proxy,
//                          color: .accentColor,
//                          rotationStart: 270,
//                          duration: 70,
//                          alignment: .topLeading)
//                }
//                .blur(radius: blur)
//            }
//            .ignoresSafeArea()
//        }
//        
//    }
//}
//
//
//class CloudProvider: ObservableObject {
//    let offset: CGSize
//    let frameHeightRatio: CGFloat
//    
//    init() {
//        frameHeightRatio = CGFloat.random(in: 0.7 ..< 1.4)
//        offset = CGSize(width: CGFloat.random(in: -300 ..< 300),
//                        height: CGFloat.random(in: -300 ..< 300))
//    }
//}
//
//struct Cloud: View {
//    @StateObject var provider = CloudProvider()
//    @State var move = false
//    let proxy: GeometryProxy
//    let color: Color
//    let rotationStart: Double
//    let duration: Double
//    let alignment: Alignment
//
//    
//    var body: some View {
//        Circle()
//            .fill(color)
//            .frame(height: proxy.size.height /  provider.frameHeightRatio)
//            .offset(provider.offset)
//        
//            .rotationEffect(.init(degrees: move ? rotationStart : rotationStart + 360) )
//            
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
//            .opacity(0.1)
//            .onAppear {
//                DispatchQueue.main.async {
//                    withAnimation(.linear(duration: duration)) {
//                        move.toggle()
//                    }
//                }
//            }
//            .hueRotation(Angle(degrees: .random(in: -30 ..< 30)))
//    }
//}


#Preview {
    CustomizeWidgetView(showNewWidgetView:.constant(true), showCustomizeWidgetView: .constant(true))
}

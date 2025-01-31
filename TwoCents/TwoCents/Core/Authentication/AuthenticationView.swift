//
//  AuthenticationView.swift
//  TwoCents
//
//  Created by jonathan on 8/2/23.
//

import SwiftUI

struct AuthenticationView: View {
    
//    @Binding var showSignInView: Bool
    @Environment(AppModel.self) var appModel
//    @State private var animateGradient: Bool = false
    
//    @Binding var showCreateProfileView: Bool
    
    
    
    @Binding  var userPhoneNumber: String?
    var body: some View {
       
        VStack{
            
            
            Spacer()
                .frame(height:100)
            
            //TwoCents Text
            
            /*  First writes out the text, then overlays gradient over it (so that it scales with text instead of whole screen). Then, masks the text over it to cutout the words */
          
            
//            Text("TwoCents")
////                .frame(maxWidth: .infinity, alignment: .leading)
//                .bold()
//                .font(.system(size: 64))
//                .overlay{
//                    
//                    LinearGradient(colors: [Color("TwoCentsGreen"),Color("TwoCentsCyan")], startPoint: .leading, endPoint: .trailing)
//                        .ignoresSafeArea()
//                        .hueRotation(.degrees(animateGradient ? 45 : 0))
//                        .onAppear{
//                            
//                            //this line fixes problem of page animating around unintentionally?
//                            DispatchQueue.main.async {
//                                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses:true)){
//                                    animateGradient.toggle()
//                                }
//                            }
//                        }
//                    
//                        .mask(
//                            Text("TwoCents")
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .bold()
//                                .font(.system(size: 64))
//                        )
//                }
            
            Image("TwoCentsLogo")
                       .resizable() // Makes the image resizable
                       .scaledToFit() // Maintains the aspect ratio
                       .frame(width: 200, height: 200) // Sets the desired size
                       
                     
            
            
            Spacer()
            
            
            
            NavigationLink {
                
               
//                SignInPhoneNumberView(showSignInView: $showSignInView, showCreateProfileView: $showCreateProfileView)
//              SignInPhoneNumberView(userPhoneNumber: $userPhoneNumber )
                SignInEmailView()
                
            } label: {
                Text("Sign In With Email")
                    .font(.headline)
                    .foregroundColor(Color(UIColor.systemBackground))
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.label))
                    .cornerRadius(10)
            }
            
//            NavigationLink {
//                
//                
//                //                SignInEmailView(showSignInView: $showSignInView, showCreateProfileView: $showCreateProfileView)
//                
//                SignUpEmailView()
//                
//            } label: {
//                Text("Sign Up With Email")
//                    .font(.headline)
//                    .foregroundColor(Color(UIColor.label))
//                    .frame(height: 55)
//                    .frame(maxWidth: .infinity)
////                    .background(Color(UIColor.secondaryLabel))
//                    .overlay(
//                                  RoundedRectangle(cornerRadius: 10)
//                                    .stroke(Color(UIColor.secondaryLabel), lineWidth: 2)
//                              )
//                    .cornerRadius(10)
//            }
//            
            
            NavigationLink{
             

//              SignUpEmailView(showSignInView: $showSignInView, showCreateProfileView: $showCreateProfileView)
                SignUpEmailView()
//                SignInPhoneNumberView(appModel.activeSheet: $appModel.activeSheet, userPhoneNumber: $userPhoneNumber )

            } label: {
                Text("New? Ugh. Create a new account")
                    .font(.footnote)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .frame(height: 30)
                    .frame(maxWidth: .infinity)

            }
            
//            .padding()
            Spacer()
                .frame(height:50)
        }
        .padding(.horizontal)
     
       
//        .navigationTitle("Sign In")
//        .background(Color("bgColor"))
       
        
    }
    
}

/*
struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
//            AuthenticationView(showSignInView: .constant(false), showCreateProfileView: .constant(false))
            AuthenticationView(appModel.activeSheet: .constant(nil), userPhoneNumber: .constant(""))
        }
       
    }
}

*/

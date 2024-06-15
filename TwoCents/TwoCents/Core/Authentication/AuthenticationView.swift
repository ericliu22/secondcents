//
//  AuthenticationView.swift
//  TwoCents
//
//  Created by jonathan on 8/2/23.
//

import SwiftUI

struct AuthenticationView: View {
    
    @Binding var showSignInView: Bool
    
    @State private var animateGradient: Bool = false
    
    @Binding var showCreateProfileView: Bool
    
    
    var body: some View {
        VStack{
            
            
            Spacer()
                .frame(height:200)
            
            //TwoCents Text
            
            /*  First writes out the text, then overlays gradient over it (so that it scales with text instead of whole screen). Then, masks the text over it to cutout the words */
          
            
            Text("TwoCents")
//                .frame(maxWidth: .infinity, alignment: .leading)
                .bold()
                .font(.system(size: 64))
                .overlay{
                    
                    LinearGradient(colors: [Color("TwoCentsGreen"),Color("TwoCentsCyan")], startPoint: .leading, endPoint: .trailing)
                        .ignoresSafeArea()
                        .hueRotation(.degrees(animateGradient ? 45 : 0))
                        .onAppear{
                            
                            //this line fixes problem of page animating around unintentionally?
                            DispatchQueue.main.async {
                                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses:true)){
                                    animateGradient.toggle()
                                }
                            }
                        }
                    
                        .mask(
                            Text("TwoCents")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .bold()
                                .font(.system(size: 64))
                        )
                }
            
            Spacer()
            
            
            
            NavigationLink {
                
               
                SignInPhoneNumberView(showSignInView: $showSignInView, showCreateProfileView: $showCreateProfileView)
            } label: {
                Text("Sign In With Phone Number")
                    .font(.headline)
                    .foregroundColor(Color(UIColor.systemBackground))
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.label))
                    .cornerRadius(10)
            }
            
            
            NavigationLink {
                
               
                SignInEmailView(showSignInView: $showSignInView, showCreateProfileView: $showCreateProfileView)
            } label: {
                Text("Sign In With Email")
                    .font(.headline)
                    .foregroundColor(Color(UIColor.systemBackground))
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.label))
                    .cornerRadius(10)
            }
            

            
            
            NavigationLink{
             

                SignUpEmailView(showSignInView: $showSignInView, showCreateProfileView: $showCreateProfileView)
           

            } label: {
                Text("New? Ugh. Create a new account")
                    .font(.footnote)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .frame(height: 30)
                    .frame(maxWidth: .infinity)

            }
            
            

        }
        .padding()
//        .navigationTitle("Sign In")
        
        Spacer()
            .frame(height:50)
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            AuthenticationView(showSignInView: .constant(false), showCreateProfileView: .constant(false))
        }
       
    }
}

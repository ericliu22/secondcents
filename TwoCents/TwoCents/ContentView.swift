//
//  ContentView.swift
//  TwoCents
//
//  Created by Eric Liu on 2023/7/23.
//

import SwiftUI

struct ContentView: View {
    @State private var animateGradient: Bool = false
    @State private var email = ""
    @State private var password = ""
        
    var body: some View{
        ZStack {
            VStack {
                
                //TwoCents Text
                
                /*  First writes out the text, then overlays gradient over it (so that it scales with text instead of whole screen). Then, masks the text over it to cutout the words */
              
                
                Text("TwoCents")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bold()
                    .font(.system(size: 48))
                    .overlay{
                        
                        LinearGradient(colors: [Color("TwoCentsGreen"),Color("TwoCentsCyan")], startPoint: .leading, endPoint: .trailing)
                            .ignoresSafeArea()
                            .hueRotation(.degrees(animateGradient ? 45 : 0))
                            .onAppear{
                                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses:true)){
                                    animateGradient.toggle()
                                }
                            }
                        
                            .mask(
                                Text("TwoCents")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .bold()
                                    .font(.system(size: 48))
                            )
                    }
                
                
                //spacer
                Spacer()
                    .frame(height:10)
                
                //Email Textfield
                TextField("Email", text: $email)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    
                //spacer
                Spacer()
                    .frame(height:10)
                
                //Password Textfield
                SecureField("Password",text:$password)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .frame(height: 55)
                
                
                Spacer()
                    .frame(height:10)
                
                Button {
                    
                } label: {
                    Text("Sign Up")
                        
                        .bold()
                        .foregroundColor(Color(UIColor.systemBackground))
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        
                        
                    
                    
                        .background(Color.primary)
                        .cornerRadius(10)
                       
                        
                    
                }
            
//
//
//
//
                
                
            }
            .padding(30)
//            .frame(width:350)
              
            
            

            
            
            
            
            
            
            
            
             
            
            
            
            
            

            
        }
        .ignoresSafeArea()
    
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

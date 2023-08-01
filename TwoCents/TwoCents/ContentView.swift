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
//            Color.white
            
               
            VStack {
                
                //TwoCents Text
                //First writes out the text, then overlays gradient over it (so that it scales with text instead of whole screen). Then, masks the text over it to cutout the words
                
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
                    
                Spacer()
                    .frame(height:10)
                    
                TextField("Email", text: $email)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .padding(14)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(5)
                    
                    
                

                Spacer()
                    .frame(height:10)
                
                
                
                SecureField("Password",text:$password)
          
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .padding(14)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(5)
                
                
                Spacer()
                    .frame(height:40)
                
                Button {
                    
                } label: {
                    Text("Sign Up")
                        .bold()
                        .foregroundColor(Color(UIColor.systemBackground))
                        .frame(maxWidth: .infinity)
                        
                        .padding(14)
                    
                    
                        .background(Color.primary)
                        .cornerRadius(5)
                       
                        
                    
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

//
//  SignInEmailView.swift
//  TwoCents
//
//  Created by jonathan on 8/2/23.
//

import SwiftUI


struct SignInEmailView: View {
    @Environment(\.presentationMode) var presentation
    
    @Binding var showSignInView: Bool
    @Binding var showSheet: Bool
    
    @StateObject private var viewModel = SignInEmailViewModel()
    var body: some View {
        
        VStack {
            //Email Textfield
            TextField("Email", text: $viewModel.email)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            
            //Password Textfield
            SecureField("Password", text: $viewModel.password)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            
            
            
            Button {
                //signUp
//                Task {
//                    do {
//                        try await viewModel.signUp()
//                        showSignInView = false
//                        return
//                    } catch {
//                    }
//                }
                //signIn
                Task {
                    do {
                        try await viewModel.signIn()
                        
                        showSignInView = false
                        showSheet = false
                        return
                    } catch {
                    }
                }
                
            } label: {
                Text("Sign In")
                    .font(.headline)
//                    .foregroundColor(Color(UIColor.systemBackground))
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
//                    .background(Color(UIColor.label))
//                    .cornerRadius(10)
                   
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("TwoCentsGreen"))
            .frame(height: 55)
            .cornerRadius(10)

            
          
           
      
                
                
            
            
            
        }
        .padding()
        .navigationTitle("Sign In With Email")
        .tint(Color("TwoCentsGreen"))
        .navigationBarTitleDisplayMode(.inline)
        //make back button black... (Gotta have the enviorment line on top)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
               Image(systemName: "chevron.backward")
            .foregroundColor(Color(UIColor.label))
               .onTapGesture {
                  self.presentation.wrappedValue.dismiss()
               }
            )
      
                   
    }
        
}

struct SignInEmailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            SignInEmailView(showSignInView: .constant(false),showSheet: .constant(false))
        }
    }
}

//
//  SignUpEmailView.swift
//  TwoCents
//
//  Created by jonathan on 8/11/23.
//

import SwiftUI


struct SignUpEmailView: View {
    @Environment(\.presentationMode) var presentation
    @Binding var activeSheet: sheetTypes?
//    @Binding var showSignInView: Bool
    
    @StateObject private var viewModel = SignUpEmailViewModel()
    
//    @Binding var showCreateProfileView: Bool
    
    
    var body: some View {
        
        
        VStack {
            
        
            
            
            
            //Name Textfield
            TextField("Name", text: $viewModel.name)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            
           
            //Username Textfield
            TextField("Username", text: $viewModel.username)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            
            
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
            
            //Confirm Password Textfield
            SecureField("Confirm Password", text: $viewModel.confirmPassword)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            
            
            
            Button {
                //signUp
                Task {
                    do {
                        try await viewModel.signUp()
                        
                        
//                        showSignInView = false
                        
                        activeSheet  = .createProfileView
//                        showCreateProfileView = true
                        return
                    } catch {
                    }
                }
               
                
            } label: {
                Text("Sign Up")
                    .font(.headline)
              
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                
            }
            
            .buttonStyle(.borderedProminent)
            .tint(Color("TwoCentsGreen"))
            .frame(height: 55)
            .cornerRadius(10)
            
            
        }
        
        
        .padding()
        
        
        .navigationTitle("Welcome, I guess?")
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

struct SignUpEmailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
//            SignUpEmailView(showSignInView: .constant(false), showCreateProfileView: .constant(false))
            SignUpEmailView(activeSheet: .constant(nil))
        }
        
    }
}

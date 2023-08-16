//
//  SignUpEmailView.swift
//  TwoCents
//
//  Created by jonathan on 8/11/23.
//

import SwiftUI

struct SignUpEmailView: View {
    @Environment(\.presentationMode) var presentation
    
    @Binding var showSignInView: Bool
    
    @StateObject private var viewModel = SignUpEmailViewModel()
    
    
    private func isValidPassword(_ password: String) -> Bool {
        // minimum 6 characters long
        // 1 uppercase character
        // 1 special char
        
        let passwordRegex = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])(?=.*[A-Z]).{6,}$")
        
        return passwordRegex.evaluate(with: password)
    }
    
    
    
    
    var body: some View {
        
        
        VStack {
            
            
            
            
            //Email Textfield
            TextField("Name", text: $viewModel.name)
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
                        
                        
                        showSignInView = false
                        return
                    } catch {
                    }
                }
                //signIn
                //                Task {
                //                    do {
                //                        try await viewModel.signIn()
                //                        showSignInView = false
                //                        return
                //                    } catch {
                //                    }
                //                }
                
            } label: {
                Text("Sign Up")
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
            SignUpEmailView(showSignInView: .constant(false))
        }
        
    }
}

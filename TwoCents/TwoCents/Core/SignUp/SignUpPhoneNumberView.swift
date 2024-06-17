//
//  SignUpEmailView.swift
//  TwoCents
//
//  Created by jonathan on 8/11/23.
//

import SwiftUI


struct SignUpPhoneNumberView: View {
    @Environment(\.presentationMode) var presentation
    @Binding var activeSheet: sheetTypes?
//    @Binding var showSignInView: Bool
    
    @StateObject private var viewModel = SignUpPhoneNumberViewModel()
    
//    @Binding var showCreateProfileView: Bool
    @Binding  var userPhoneNumber: String?
    
    var body: some View {
        
        
        VStack {
            
        
            
            
            
            //Name Textfield
            TextField("Name", text: $viewModel.name)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            
            
            
            Button {
                //signUp
                Task {
                    do {
                        try await viewModel.signUp(userPhoneNumber: userPhoneNumber ?? "")
                        
                        activeSheet  = .customizeProfileView
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
//        .navigationBarBackButtonHidden(true)
//        .navigationBarItems(leading:
//                                Image(systemName: "chevron.backward")
//            .foregroundColor(Color(UIColor.label))
//            .onTapGesture {
//                self.presentation.wrappedValue.dismiss()
//            }
//        )
        
        
        
        
    }
    
    
    
    
}

struct SignUpPhoneNumberView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
//            SignUpEmailView(showSignInView: .constant(false), showCreateProfileView: .constant(false))
            SignUpEmailView(activeSheet: .constant(nil))
        }
        
    }
}

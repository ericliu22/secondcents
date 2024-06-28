//
//  SignInEmailView.swift
//  TwoCents
//
//  Created by jonathan on 8/2/23.
//

import SwiftUI


struct SignInPhoneNumberView: View {
    @Environment(\.presentationMode) var presentation
    @Binding var activeSheet: sheetTypes?
//    @Binding var showSignInView: Bool
//    @Binding var showCreateProfileView: Bool
    @State private var isActive = false
    @Binding var userPhoneNumber: String?
    
    @StateObject private var viewModel = SignInPhoneNumberViewModel()
    var body: some View {
        
        VStack {
            Text("heyy, can i get your number?")
                .font(.caption)
                .foregroundColor(Color(UIColor.secondaryLabel))
                .multilineTextAlignment(.leading)
                .padding(.bottom, 5)
            
            Text("(as a joke, haha)")
                .font(.caption2)
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .multilineTextAlignment(.leading)
                .padding(.bottom, 50)
            
            
            
            
            //Email Textfield
            TextField("Phone Number", text: $viewModel.phoneNumber)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .onChange(of: viewModel.phoneNumber, perform: { value in
                    viewModel.formatPhoneNumber()
                })
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
//
//            //Password Textfield
//            SecureField("Password", text: $viewModel.password)
//                .disableAutocorrection(true)
//                .textInputAutocapitalization(.never)
//                .padding()
//                .background(Color(UIColor.secondarySystemBackground))
//                .cornerRadius(10)
//            
                
            NavigationLink(
                destination: /*VerifyCodeView(showSignInView: $showSignInView, showCreateProfileView: $showCreateProfileView)*/ VerifyCodeView(activeSheet: $activeSheet),
                isActive: $isActive,
                label: {
                    EmptyView()
                }
            )
           
            
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
                        try await viewModel.sendCode()
                        
                        isActive = true
                        userPhoneNumber = viewModel.getCleanPhoneNumber()
                        
//                        showSignInView = false
//                        showCreateProfileView = false
                        return
                    } catch {
                    }
                }
                
            } label: {
                Text("Let's go!")
                    .font(.headline)
//                    .foregroundColor(Color(UIColor.systemBackground))
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
//                    .background(Color(UIColor.label))
//                    .cornerRadius(10)
                
                
                   
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(UIColor.label))
            .frame(height: 55)
            .cornerRadius(10)
            .padding(.top)
            .disabled(viewModel.phoneNumber.count != 14)
            .padding(.bottom, 50)
          
           
      
                
                
            
            
            
        }
        .padding()
        .navigationTitle("Portal to the Beyond")
        .tint(Color(UIColor.label))
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

struct SignInPhoneNumberView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
//            SignInEmailView(showSignInView: .constant(false),showCreateProfileView: .constant(false))
            
            SignInEmailView(activeSheet: .constant(nil))
        }
    }
}

//
//  SignInEmailView.swift
//  TwoCents
//
//  Created by jonathan on 8/2/23.
//

import SwiftUI


struct VerifyCodeView: View {
    @Environment(\.presentationMode) var presentation

//    @Binding var showSignInView: Bool
//    @Binding var showCreateProfileView: Bool
// 
    @Binding var activeSheet: sheetTypes?
      @StateObject private var viewModel = VerifyCodeViewModel()
    var body: some View {
        
        VStack {
     
            TextField("Verification Code", text: $viewModel.verificationCode)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .keyboardType(.phonePad)
          
           
            
            Button {

                Task {
                    
                   
                    
                    
                    do {
                        
                     
                        try await viewModel.verifyCode() {success in
                            
                            if success {
                                
                                                activeSheet = nil
                                                
                               
                            }
                            
                          
                        }
                        
                   
                          
                        return
                    } catch {
                        print("Error verifying code: \(error)")
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
            .padding(.top)
//            .disabled(viewModel.phoneNumber.isEmpty)


                
                
            
            
            
        }
        .padding()
        .navigationTitle("Sign In")
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

struct VerifytCodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
//            SignInEmailView(showSignInView: .constant(false),showCreateProfileView: .constant(false))
            
            SignInEmailView(activeSheet: .constant(nil))
        }
    }
}

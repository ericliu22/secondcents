//
//  AuthenticationView.swift
//  TwoCents
//
//  Created by jonathan on 8/2/23.
//

import SwiftUI

struct AuthenticationView: View {
    
    @Binding var showSignInView: Bool
    var body: some View {
        VStack{
            NavigationLink {
                SignInEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Sign In With Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .cornerRadius(10)
            }
            
            Spacer()

        }
        .padding()
        .navigationTitle("Sign In")
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            AuthenticationView(showSignInView: .constant(false))
        }
       
    }
}

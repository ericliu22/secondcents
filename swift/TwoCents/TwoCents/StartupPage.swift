//
//  ContentView.swift
//  TwoCents
//
//  Created by Eric Liu on 2023/7/7.
//
import Realm
import SwiftUI

func registerUser() {
    
}

struct StartupPage: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Form {
                Section {
                    TextField("Username", text: $username)
                }
                Section {
                    SecureField("Password",
                            text: $password)
                }
                Section {
                    SecureField("Confirm Password",
                            text: $password)
                }
            }
            Button(action: registerUser) {
                Text("Register")
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StartupPage()
    }
}

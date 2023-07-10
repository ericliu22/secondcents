//
//  ContentView.swift
//  TwoCents
//
//  Created by Eric Liu on 2023/7/7.
//
import Realm
import SwiftUI

struct StartupPage: View {
    @State private var username: String = ""
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
                    Text(username)
                }
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

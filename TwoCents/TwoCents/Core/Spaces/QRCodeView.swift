//
//  QRCodeView.swift
//  TwoCents
//
//  Created by Eric Liu on 2025/1/10.
//

import SwiftUI

struct QRCodeView: View {
    let spaceLink: String
    @State var qrCode: UIImage?
    
    init(spaceLink: String) {
        self.spaceLink = spaceLink
    }
    
    var body: some View {
        VStack {
            if let qrCode {
                Image(uiImage: qrCode)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200) // Adjust size as needed
                Text("Scan this QR Code to join the space!")
                    .font(.headline)
                    .padding()
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text("Generating QR Code...")
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            qrCode = generateQRCode(from: spaceLink)
        }
    }
}

struct QRCodeView_Preview: PreviewProvider {
    static var previews: some View {
        // Mock the qrCode generation result for the preview
        QRCodeView(spaceLink: "https://twocentsapp.com")
    }
}

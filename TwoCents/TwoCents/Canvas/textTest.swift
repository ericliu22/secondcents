import Foundation
import SwiftUI

struct testView: View {
    @State private var showPopup = false

    var body: some View {
        ZStack {
            VStack {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 100, height: 100)
                    .onLongPressGesture {
                        showPopup = true
                    }
            }
            if showPopup {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showPopup = false
                    }

                TextView(showPopup: $showPopup)
                    .transition(.scale)
                    .zIndex(1)
            }
        }
    }
}

struct testView_Previews: PreviewProvider {
    static var previews: some View {
        testView()
    }
}

import SwiftUI

struct AuthenticationView: View {
    
    @Environment(AppModel.self) var appModel
    @State private var animateGradient: Bool = false
    @Binding var userPhoneNumber: String?
    
    private let welcomeMessages = [
        "Prepare for some serious sass.",
        "This is not a safe space. It's TwoCents.",
        "If you can’t handle the heat, get out.",
        "No softies allowed.",
        "Leave your feelings at the door.",
        "You think you’re safe? Think again.",
        "This is where your ego dies.",
        "Bring your A-game or stay quiet.",
        "We roast, you suffer, it’s fun.",
        "It's not personal, you’re just easy to roast.",
        "Tears are a sign of a good joke.",
        "Your weakness is our favorite target.",
        "It’s not personal, it’s just brutal.",
        "In this kitchen, we serve only flames.",
        "Don’t cry, it’s only your dignity.",
        "We’re here to break you (in a fun way?)"
    ]
    
    @State private var shownMessages: [String] = []
    @State private var welcomeMessage = ""
    @State private var currentText = ""
    @State private var timer: Timer?

    private func startTypingAnimation() {
        var characterIndex = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if characterIndex < welcomeMessage.count {
                let index = welcomeMessage.index(welcomeMessage.startIndex, offsetBy: characterIndex)
                currentText += String(welcomeMessage[index])
                characterIndex += 1
            } else {
                timer.invalidate() // Stop the timer when the whole message is typed out
                
                // After 2 seconds, reset the current text and display a new random message
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    currentText = ""
                    showNewMessage()
                    startTypingAnimation() // Start typing the new message
                }
            }
        }
    }
    
    private func showNewMessage() {
        // If all messages have been shown, reset the shownMessages array
        if shownMessages.count == welcomeMessages.count {
            shownMessages.removeAll()
        }
        
        // Pick a random message that has not been shown yet
        var randomMessage: String
        repeat {
            randomMessage = welcomeMessages.randomElement() ?? ""
        } while shownMessages.contains(randomMessage)
        
        // Add the message to the list of shown messages
        shownMessages.append(randomMessage)
        
        // Set the new message
        welcomeMessage = randomMessage
    }
    
    var body: some View {
        VStack{
            Spacer()
                .frame(height:200)
            
            HStack {
                Image("TwoCentsLogo")
                    .resizable() // Makes the image resizable
                    .scaledToFit() // Maintains the aspect ratio
                    .frame(width: 100, height: 100) // Sets the desired size
                
                // Display typed-out welcome message
                VStack(alignment: .leading) { // Use VStack for top alignment
                    Text(currentText)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .multilineTextAlignment(.leading) // Aligns text to the leading edge
                        .padding(.bottom, 5)
                        .onAppear {
                            showNewMessage()
                            startTypingAnimation() // Start the typing animation
                        }
                        .frame(maxWidth: .infinity, alignment: .leading) // Keeps text aligned to leading edge
                        .fixedSize(horizontal: false, vertical: true) // Prevents text from causing layout issues during wrapping
                }
                .frame(maxWidth: .infinity) // Align the VStack to the top
                .frame(height:50, alignment: .top)
            }


            Spacer()
        
            
            
            NavigationLink {
                SignInEmailView()
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(Color(UIColor.systemBackground))
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.label))
                    .cornerRadius(10)
            }
            
            NavigationLink {
                SignUpEmailView()
            } label: {
                Text("New? Ugh. Create a new account")
                    .font(.footnote)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .frame(height: 30)
                    .frame(maxWidth: .infinity)
            }
            
            Spacer()
                .frame(height:50)
        }
        .padding(.horizontal)
        .background(Color("bgColor"))
    }
}

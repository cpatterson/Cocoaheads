import SwiftUI

struct SignInSheet: View {
    @Binding var name: String?
    @State var nameEntry = ""
    @FocusState var isEnteringName: Bool

    func signIn() {
        guard !nameEntry.isEmpty else {
            isEnteringName = true
            return
        }
        name = nameEntry
    }

    var body: some View {
        VStack {
            Image(systemName: "flag.checkered.circle")
                .resizable()
                .frame(width: 200, height: 200)
            Text("IndyCocoaheads WebSockets Demo")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
            TextField(text: $nameEntry) {
                Text("Enter Name")
            }
            .textFieldStyle(.roundedBorder)
            .focused($isEnteringName)
            .padding()
            .onSubmit {
                signIn()
            }
            Button(
                action: {
                    signIn()
                },
                label: {
                    Text("Sign In")
                }
            )
        }
        .onAppear {
            isEnteringName = true
        }
    }
}

#Preview {
    SignInSheet(name: Binding(get: { nil }, set: { _ in }))
}

import SwiftUI

struct PaintView: View {
    @Binding var name: String?

    var body: some View {
        NavigationView {
            VStack {
                Divider()
                Text("Color by Numbers")
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
            }
            .navigationTitle("Color by Numbers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: {
                            name = nil
                        },
                        label: {
                            Text("Sign Out")
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    PaintView(name: Binding(get: { "Chris" }, set: { _ in }))
}

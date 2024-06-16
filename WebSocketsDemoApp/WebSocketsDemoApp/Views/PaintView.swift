import SwiftUI

struct PaintView: View {
    var body: some View {
        NavigationView {
            VStack {
                Divider()
                Text("Color by Numbers")
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
            }
            .navigationTitle("Color by Numbers")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    PaintView()
}

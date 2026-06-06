struct PlayButton: View {
    var action: (() -> Void)?

    var body: some View {
        Button {
            action?()
        } label: {
            Image(systemName: "play.circle.fill")
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundColor(.accentGreen)
        }
        .buttonStyle(.plain)
    }
}

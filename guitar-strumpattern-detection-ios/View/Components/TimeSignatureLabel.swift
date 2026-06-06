// MARK: - Time Signature Label
struct TimeSignatureLabel: View {
    let signature: String

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "music.note")
                .font(.system(size: 12))
                .foregroundColor(.accentYellow)
            Text("= \(signature)")
                .font(AppFont.label(13))
                .foregroundColor(.accentYellow)
        }
    }
}

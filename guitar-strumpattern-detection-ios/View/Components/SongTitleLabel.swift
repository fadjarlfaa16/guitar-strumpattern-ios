// MARK: - Song Title Label
struct SongTitleLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .font(AppFont.body(12))
            .foregroundColor(.accentYellow)
            .lineLimit(1)
            .truncationMode(.tail)
    }
}
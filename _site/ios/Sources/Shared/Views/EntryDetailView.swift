import SwiftUI

struct EntryDetailView: View {
    let entry: JournalEntry

    private var attributed: AttributedString {
        guard let data = entry.htmlContent.data(using: .utf8),
              let attr = try? NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html,
                          .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil
              ) else {
            return AttributedString(entry.htmlContent)
        }
        return AttributedString(attr)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(entry.title).font(.title2.bold())
                Text(entry.date.formatted(date: .long, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(attributed)
            }
            .padding()
        }
        .navigationTitle(entry.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

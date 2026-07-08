import SwiftUI

struct EntryDetailView: View {
    let entry: JournalEntry

    private var attributed: AttributedString {
        // ponytail: NSAttributedString's HTML importer defaults to 12pt Times with no
        // spacing rules, which reads as "unstyled" next to system-font UI. Wrap with a
        // style block so headings/bold/paragraphs actually look distinct.
        let styledHTML = """
        <style>
        body { font-family: -apple-system; font-size: 17px; }
        h1, h2, h3 { font-family: -apple-system; font-weight: 700; }
        h1 { font-size: 22px; } h2 { font-size: 20px; } h3 { font-size: 18px; }
        p { margin: 0 0 12px 0; }
        </style>
        \(entry.htmlContent)
        """
        guard let data = styledHTML.data(using: .utf8),
              let attr = try? NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html,
                          .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil
              ) else {
            return AttributedString(entry.htmlContent)
        }
        var result = AttributedString(attr)
        // HTML import bakes in black text; strip colors so it adapts to dark mode.
        for run in result.runs {
            result[run.range].foregroundColor = nil
        }
        return result
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

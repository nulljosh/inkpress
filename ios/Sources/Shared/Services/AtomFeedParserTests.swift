import Foundation

#if DEBUG
/// ponytail: minimal self-check for the hand-rolled Atom parser, not a full test target.
func atomFeedParserDemo() {
    let xml = """
    <?xml version="1.0" encoding="UTF-8"?>
    <feed xmlns="http://www.w3.org/2005/Atom">
      <entry>
        <title>Test Entry</title>
        <link href="https://journal.heyitsmejosh.com/2026/06/26/week/" rel="alternate" type="text/html" />
        <published>2026-06-26T09:00:00-07:00</published>
        <content type="html">&lt;p&gt;Hello&lt;/p&gt;</content>
      </entry>
    </feed>
    """
    let entries = AtomFeedParser.parse(data: Data(xml.utf8))
    assert(entries.count == 1, "expected 1 entry, got \(entries.count)")
    assert(entries[0].title == "Test Entry", "title mismatch: \(entries[0].title)")
    assert(entries[0].url == "https://journal.heyitsmejosh.com/2026/06/26/week/", "url mismatch: \(entries[0].url)")
    assert(entries[0].htmlContent.contains("Hello"), "content mismatch: \(entries[0].htmlContent)")
    print("AtomFeedParser demo: OK")
}
#endif

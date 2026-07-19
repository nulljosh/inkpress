import Foundation

#if DEBUG
/// ponytail: minimal self-check for the hand-rolled parser (Atom + RSS), not a full test target.
func feedParserDemo() {
    let atom = """
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
    let a = FeedParser.parse(data: Data(atom.utf8))
    assert(a.count == 1, "atom: expected 1 entry, got \(a.count)")
    assert(a[0].title == "Test Entry", "atom title mismatch: \(a[0].title)")
    assert(a[0].url == "https://journal.heyitsmejosh.com/2026/06/26/week/", "atom url mismatch")

    let rss = """
    <?xml version="1.0"?>
    <rss version="2.0"><channel>
      <item>
        <title>RSS Item</title>
        <link>https://example.com/post</link>
        <pubDate>Fri, 26 Jun 2026 09:00:00 -0700</pubDate>
        <description>&lt;p&gt;World&lt;/p&gt;</description>
      </item>
    </channel></rss>
    """
    let r = FeedParser.parse(data: Data(rss.utf8))
    assert(r.count == 1, "rss: expected 1 entry, got \(r.count)")
    assert(r[0].title == "RSS Item", "rss title mismatch: \(r[0].title)")
    assert(r[0].url == "https://example.com/post", "rss url mismatch: \(r[0].url)")
    print("FeedParser demo: OK")
}
#endif

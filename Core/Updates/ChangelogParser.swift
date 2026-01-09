import Foundation

/// Represents a single version entry from CHANGELOG.md
struct ChangelogEntry {
    let version: String
    let date: String?
    let content: String // Raw markdown content for this version
}

/// Parses bundled CHANGELOG.md file
final class ChangelogParser {
    static let shared = ChangelogParser()

    private init() {}

    /// Get the changelog entry for the current app version
    /// - Parameter version: Optional version override. If nil, uses Bundle.main version.
    func currentVersionEntry(for version: String? = nil) -> ChangelogEntry? {
        let v = version
            ?? Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            ?? "0.0.0"
        return entry(for: v)
    }

    /// Get the changelog entry for a specific version
    func entry(for version: String) -> ChangelogEntry? {
        guard let content = loadChangelog() else { return nil }
        return extractEntry(from: content, version: version)
    }

    /// Get all changelog entries
    func allEntries() -> [ChangelogEntry] {
        guard let content = loadChangelog() else { return [] }
        return extractAllEntries(from: content)
    }

    // MARK: - Private

    private func loadChangelog() -> String? {
        guard let url = Bundle.main.url(forResource: "CHANGELOG", withExtension: "md") else {
            log("ChangelogParser: CHANGELOG.md not found in bundle")
            return nil
        }

        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            log("ChangelogParser: Failed to read CHANGELOG.md: \(error)")
            return nil
        }
    }

    private func extractEntry(from content: String, version: String) -> ChangelogEntry? {
        // Pattern: ## [0.1.0] - 2025-01-09 or ## [0.1.0]
        let pattern = #"## \[\#(version)\](?:\s*-\s*(\d{4}-\d{2}-\d{2}))?\s*\n([\s\S]*?)(?=\n## \[|\z)"#
            .replacingOccurrences(of: "#(version)", with: NSRegularExpression.escapedPattern(for: version))

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
              let match = regex.firstMatch(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        else {
            return nil
        }

        let dateRange = Range(match.range(at: 1), in: content)
        let contentRange = Range(match.range(at: 2), in: content)

        let date = dateRange.map { String(content[$0]) }
        let entryContent = contentRange.map { String(content[
            $0
        ]).trimmingCharacters(in: .whitespacesAndNewlines) } ?? ""

        return ChangelogEntry(version: version, date: date, content: entryContent)
    }

    private func extractAllEntries(from content: String) -> [ChangelogEntry] {
        // Pattern to match all version headers
        let pattern = #"## \[(\d+\.\d+\.\d+)\](?:\s*-\s*(\d{4}-\d{2}-\d{2}))?\s*\n([\s\S]*?)(?=\n## \[|\z)"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }

        let matches = regex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))

        return matches.compactMap { match -> ChangelogEntry? in
            guard let versionRange = Range(match.range(at: 1), in: content) else { return nil }

            let version = String(content[versionRange])
            let dateRange = Range(match.range(at: 2), in: content)
            let contentRange = Range(match.range(at: 3), in: content)

            let date = dateRange.map { String(content[$0]) }
            let entryContent = contentRange
                .map { String(content[$0]).trimmingCharacters(in: .whitespacesAndNewlines) } ?? ""

            return ChangelogEntry(version: version, date: date, content: entryContent)
        }
    }
}

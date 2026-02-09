import SwiftUI
import UIKit

// MARK: - MarkdownTextView

struct MarkdownTextView: View {
    let content: String
    let foregroundColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            ForEach(Array(parseBlocks().enumerated()), id: \.offset) { _, block in
                blockView(for: block)
            }
        }
    }

    // MARK: - Block Rendering

    @ViewBuilder
    private func blockView(for block: MarkdownBlock) -> some View {
        switch block {
        case .codeBlock(let code, _):
            codeBlockView(code: code)

        case .header(let text, let level):
            headerView(text: text, level: level)

        case .listItem(let text, let indentLevel):
            listItemView(text: text, indentLevel: indentLevel)

        case .paragraph(let text):
            inlineMarkdownText(text)
        }
    }

    private func codeBlockView(code: String) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(code)
                .font(.system(.callout, design: .monospaced))
                .foregroundStyle(Color.primary)
                .textSelection(.enabled)
                .padding(Theme.spacingSM + 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surfaceColorLight, in: RoundedRectangle(cornerRadius: Theme.cornerRadiusSM, style: .continuous))
    }

    private func headerView(text: String, level: Int) -> some View {
        let style: Font.TextStyle = switch level {
        case 1: .title
        case 2: .title2
        case 3: .title3
        default: .headline
        }

        return inlineMarkdownText(text)
            .font(.system(style, design: .rounded, weight: .bold))
    }

    private func listItemView(text: String, indentLevel: Int) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Theme.spacingSM) {
            Text("\u{2022}")
                .foregroundStyle(foregroundColor)
            inlineMarkdownText(text)
        }
        .padding(.leading, CGFloat(indentLevel) * Theme.spacingMD)
    }

    // MARK: - Inline Markdown

    private func inlineMarkdownText(_ text: String) -> Text {
        parseInline(text)
    }

    private func parseInline(_ text: String) -> Text {
        var result = AttributedString()
        var remaining = text[text.startIndex...]

        while !remaining.isEmpty {
            // Inline code: `code`
            if remaining.first == "`", let endIndex = remaining.dropFirst().firstIndex(of: "`") {
                let codeContent = remaining[remaining.index(after: remaining.startIndex)..<endIndex]
                var attr = AttributedString(String(codeContent))
                attr.font = .system(.body, design: .monospaced)
                attr.foregroundColor = UIColor(foregroundColor.opacity(0.85))
                result.append(attr)
                remaining = remaining[remaining.index(after: endIndex)...]
                continue
            }

            // Bold: **text**
            if remaining.hasPrefix("**") {
                let after = remaining.dropFirst(2)
                if let endRange = after.range(of: "**") {
                    let boldContent = after[after.startIndex..<endRange.lowerBound]
                    var attr = AttributedString(String(boldContent))
                    attr.font = Font.body.bold()
                    attr.foregroundColor = UIColor(foregroundColor)
                    result.append(attr)
                    remaining = after[endRange.upperBound...]
                    continue
                }
            }

            // Italic: *text* (but not **)
            if remaining.hasPrefix("*"), !remaining.hasPrefix("**") {
                let after = remaining.dropFirst()
                if let endIndex = after.firstIndex(of: "*") {
                    let italicContent = after[after.startIndex..<endIndex]
                    var attr = AttributedString(String(italicContent))
                    attr.font = Font.body.italic()
                    attr.foregroundColor = UIColor(foregroundColor)
                    result.append(attr)
                    remaining = after[after.index(after: endIndex)...]
                    continue
                }
            }

            // Plain text: consume until next special character
            let specialChars: [Character] = ["`", "*"]
            let nextSpecial = remaining.dropFirst().firstIndex(where: { specialChars.contains($0) })
            let end = nextSpecial ?? remaining.endIndex
            let plainText = remaining[remaining.startIndex..<end]
            var attr = AttributedString(String(plainText))
            attr.foregroundColor = UIColor(foregroundColor)
            result.append(attr)
            remaining = remaining[end...]
        }

        return Text(result)
    }
}

// MARK: - Markdown Block Types

private enum MarkdownBlock {
    case codeBlock(code: String, language: String?)
    case header(text: String, level: Int)
    case listItem(text: String, indentLevel: Int)
    case paragraph(text: String)
}

// MARK: - Markdown Parsing

extension MarkdownTextView {
    private func parseBlocks() -> [MarkdownBlock] {
        var blocks: [MarkdownBlock] = []
        let lines = content.components(separatedBy: "\n")
        var index = 0

        while index < lines.count {
            let line = lines[index]
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Fenced code block
            if trimmed.hasPrefix("```") {
                let language = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                var codeLines: [String] = []
                index += 1

                while index < lines.count {
                    let codeLine = lines[index]
                    if codeLine.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                        index += 1
                        break
                    }
                    codeLines.append(codeLine)
                    index += 1
                }

                let code = codeLines.joined(separator: "\n")
                blocks.append(.codeBlock(code: code, language: language.isEmpty ? nil : language))
                continue
            }

            // Header
            if trimmed.hasPrefix("#") {
                let level = trimmed.prefix(while: { $0 == "#" }).count
                if level <= 6 {
                    let headerText = String(trimmed.dropFirst(level)).trimmingCharacters(in: .whitespaces)
                    if !headerText.isEmpty {
                        blocks.append(.header(text: headerText, level: level))
                        index += 1
                        continue
                    }
                }
            }

            // List item (- or * at start, but * must be followed by space to avoid bold)
            if trimmed.hasPrefix("- ") || (trimmed.hasPrefix("* ") && !trimmed.hasPrefix("**")) {
                let indent = line.prefix(while: { $0 == " " || $0 == "\t" }).count
                let indentLevel = indent / 2
                let itemText = String(trimmed.dropFirst(2))
                blocks.append(.listItem(text: itemText, indentLevel: indentLevel))
                index += 1
                continue
            }

            // Numbered list item (1. 2. etc.)
            if let dotIndex = trimmed.firstIndex(of: "."),
               trimmed[trimmed.startIndex..<dotIndex].allSatisfy(\.isNumber),
               trimmed.index(after: dotIndex) < trimmed.endIndex,
               trimmed[trimmed.index(after: dotIndex)] == " " {
                let indent = line.prefix(while: { $0 == " " || $0 == "\t" }).count
                let indentLevel = indent / 2
                let itemText = String(trimmed[trimmed.index(dotIndex, offsetBy: 2)...])
                blocks.append(.listItem(text: itemText, indentLevel: indentLevel))
                index += 1
                continue
            }

            // Empty line - skip
            if trimmed.isEmpty {
                index += 1
                continue
            }

            // Paragraph: accumulate consecutive non-empty, non-special lines
            var paragraphLines: [String] = [line]
            index += 1

            while index < lines.count {
                let nextLine = lines[index]
                let nextTrimmed = nextLine.trimmingCharacters(in: .whitespaces)

                if nextTrimmed.isEmpty
                    || nextTrimmed.hasPrefix("```")
                    || nextTrimmed.hasPrefix("#")
                    || nextTrimmed.hasPrefix("- ")
                    || (nextTrimmed.hasPrefix("* ") && !nextTrimmed.hasPrefix("**")) {
                    break
                }

                // Check for numbered list
                if let dotIdx = nextTrimmed.firstIndex(of: "."),
                   nextTrimmed[nextTrimmed.startIndex..<dotIdx].allSatisfy(\.isNumber),
                   nextTrimmed.index(after: dotIdx) < nextTrimmed.endIndex,
                   nextTrimmed[nextTrimmed.index(after: dotIdx)] == " " {
                    break
                }

                paragraphLines.append(nextLine)
                index += 1
            }

            let paragraphText = paragraphLines.joined(separator: " ")
            blocks.append(.paragraph(text: paragraphText))
        }

        return blocks
    }
}

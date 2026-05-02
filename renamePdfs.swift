#!/usr/bin/env swift

import Foundation
import PDFKit

let manualTitles: [Int: String] = [
    1: "伝統から革新へと脱皮する昆虫食",
    2: "昆虫食王国タイにおける昆虫食の魅力",
    3: "寄稿：タイ産コオロギの魅力",
    4: "イエバエに魅せられて",
    5: "本格化する国産コオロギ生産～コオロギ生産ガイドラインを作成～",
    6: "食用昆虫文化を活かして食の多様性を確保するための取り組み",
    7: "昆虫食普及の現場から～３年間の取り組みを振り返って～",
    8: "よるのひるねに集うムシクイたち",
    9: "TAKE-NOKOに集う人と虫たち",
    10: "昨今のコオロギ食論争を巡って（１）",
    11: "昨今のコオロギ食論争を巡って（２）",
    12: "昆虫食普及ネットワークでの活動について",
    13: "小説 幼虫の出てくる入り口",
    14: "獣医学と昆虫",
    15: "まずは常識を手放して、ラオスの生態系と昆虫と、食文化をみてみよう",
    16: "ウガンダでシロアリ食にハマってますます虫が好きになった私（１）",
    17: "ウガンダでシロアリ食にハマッてますます虫が好きになった私（２）",
    18: "食の新たな可能性を伝える映画「エディブル・リバー」",
    19: "NPO法人昆虫食普及ネットワークとの出会い",
    20: "食の幅を広げてくれた昆虫食に感謝！",
    21: "まちづくりと昆虫食",
    22: "昆虫食の魅力について",
    23: "多様性、チェンマイ",
    24: "虫取り少年が昆虫食Youtuberになるまで",
    25: "塩野屋の蚕はフレッシュやし、絶対美味しいねん！",
    26: "食用コオロギ事業の立ち上げとその思い～どんなに逆風が吹いても突き進まなければならない将来本当に必要なこと～",
    27: "昆虫食としての深川蚕",
    28: "『野生食展』in MUSUBI画廊",
    29: "昆虫は自然をそのまま表現する味",
    30: "「コオロギレシピ2025」開催！",
    31: "特定外来種クビアカツヤカミキリについて",
    32: "寄稿：タイの昆虫食について",
    33: "寄稿：アートにもスパイスにもなり得る、底なし沼の昆虫の魅力",
    34: "昆虫文化を子供たちに伝える会の活動紹介",
    35: "寄稿：渋谷とCity Bug",
    36: "寄稿：養蚕の新たな価値を生み出す",
    37: "寄稿：三度の飯よりコオロギが好き！",
    38: "寄稿：沖縄県を拠点に「食用昆虫の養殖」と「昆虫食の製造・販売」に取り組む",
    39: "寄稿：イモムシ愛を語りたい",
    40: "寄稿：シルク岡谷ガストロノミーツーリズムにおける昆虫食",
    41: "寄稿：東京イナゴンピック10年を振り返って",
    42: "寄稿：棚田はいのちの宝庫",
    43: "寄稿：昨今の昆虫食動向について",
    44: "寄稿：虫フェス前夜談",
    45: "寄稿：食用昆虫の栄養価について",
    46: "寄稿：昆虫食文化を紹介する企画展「昆虫食〜これうまいでぇ」",
]

func readFirstPageLines(from url: URL) throws -> [String] {
    guard let document = PDFDocument(url: url), let page = document.page(at: 0) else {
        throw NSError(domain: "renamePdfs", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not open first page for \(url.lastPathComponent)"])
    }

    return (page.string ?? "")
        .components(separatedBy: .newlines)
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
}

func extractVolume(from header: String) -> Int? {
    guard let start = header.firstIndex(of: "第"), let end = header.firstIndex(of: "号"), start < end else {
        return nil
    }

    let digits = header[header.index(after: start)..<end]
        .unicodeScalars
        .filter { CharacterSet.decimalDigits.contains($0) }
        .compactMap(\.properties.numericValue)
        .map { String(Int($0)) }
        .joined()

    return Int(digits)
}

func looksLikeAuthor(_ line: String) -> Bool {
    let markers = ["（", "(", "株式会社", "店主", "代表", "理事長", "教授", "館長", "事務所長", "会員", "監督", "タレント"]
    return markers.contains { line.contains($0) }
}

func fallbackTitle(from lines: [String]) -> String? {
    let contentLines = Array(lines.dropFirst(2))
    guard !contentLines.isEmpty else { return nil }

    var titleLines: [String] = []
    for line in contentLines.prefix(6) {
        if !titleLines.isEmpty && looksLikeAuthor(line) {
            break
        }

        if titleLines.isEmpty {
            titleLines.append(line)
            continue
        }

        if line.hasPrefix("～") || line.hasPrefix("「") || line.hasPrefix("『") || titleLines.count == 1 {
            titleLines.append(line)
            continue
        }

        break
    }

    let joined = titleLines.joined()
    return joined.isEmpty ? nil : joined
}

func scheduleTitle(from lines: [String]) -> String? {
    guard lines.contains(where: { $0.contains("年間イベントスケジュール") }) else {
        return nil
    }

    let combined = lines.joined(separator: " ")
    let regex = try! NSRegularExpression(pattern: "[0-9]{4}年")
    let range = NSRange(combined.startIndex..<combined.endIndex, in: combined)
    guard let match = regex.firstMatch(in: combined, range: range),
          let yearRange = Range(match.range, in: combined) else {
        return "昆虫食普及ネットワーク年間イベントスケジュール"
    }

    let year = String(combined[yearRange])
        .unicodeScalars
        .filter { CharacterSet.decimalDigits.contains($0) }
        .compactMap(\.properties.numericValue)
        .map { String(Int($0)) }
        .joined()

    return "昆虫食普及ネットワーク\(year)年年間イベントスケジュール"
}

func sanitizedFilename(_ title: String) -> String {
    let invalid = CharacterSet(charactersIn: "/:")
    let cleaned = title.unicodeScalars.map { invalid.contains($0) ? "／" : Character($0) }
    return String(cleaned)
        .components(separatedBy: .whitespacesAndNewlines)
        .filter { !$0.isEmpty }
        .joined(separator: " ")
}

let fileManager = FileManager.default
let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
let pdfURLs = try fileManager.contentsOfDirectory(at: currentDirectory, includingPropertiesForKeys: nil)
    .filter { $0.pathExtension.lowercased() == "pdf" }
    .sorted { $0.lastPathComponent < $1.lastPathComponent }

var failures: [String] = []

for pdfURL in pdfURLs {
    do {
        let lines = try readFirstPageLines(from: pdfURL)

        let destinationName: String
        if let schedule = scheduleTitle(from: lines) {
            destinationName = sanitizedFilename(schedule) + ".pdf"
        } else if let volume = lines.first.flatMap(extractVolume) {
            let title = manualTitles[volume] ?? fallbackTitle(from: lines)
            guard let title else {
                throw NSError(domain: "renamePdfs", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not determine title for volume \(volume) in \(pdfURL.lastPathComponent)"])
            }
            destinationName = String(format: "Vol.%02d_%@.pdf", volume, sanitizedFilename(title))
        } else {
            throw NSError(domain: "renamePdfs", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not detect newsletter volume or event title in \(pdfURL.lastPathComponent)"])
        }

        let destinationURL = currentDirectory.appendingPathComponent(destinationName)
        if destinationURL == pdfURL {
            continue
        }

        if fileManager.fileExists(atPath: destinationURL.path) {
            throw NSError(domain: "renamePdfs", code: 4, userInfo: [NSLocalizedDescriptionKey: "Destination already exists: \(destinationName)"])
        }

        try fileManager.moveItem(at: pdfURL, to: destinationURL)
        print("\(pdfURL.lastPathComponent) -> \(destinationName)")
    } catch {
        failures.append(error.localizedDescription)
    }
}

if !failures.isEmpty {
    for failure in failures {
        fputs("error: \(failure)\n", stderr)
    }
    exit(1)
}

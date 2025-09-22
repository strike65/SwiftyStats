import Foundation
import Testing
@testable import SwiftyStats

@Suite("SSExamine file export/import")
struct SSExamineFileTests {

    private func tmpPath(_ filename: String, subdir: String = UUID().uuidString) -> String {
        let base = (NSTemporaryDirectory() as NSString).appendingPathComponent("SwiftyStatsTests")
        let path = (base as NSString).appendingPathComponent(subdir)
        return (path as NSString).appendingPathComponent(filename)
    }

    @Test("saveTo creates parents and quotes elements")
    func saveToCreatesParentsAndQuotes() throws {
        // Given: string elements containing delimiter and quotes
        let elements: [String] = ["a,b", "c\"d", "e"]
        let ex = SSExamine<String, Double>(withArray: elements, name: "test", characterSet: nil)
        let file = tmpPath("dataset.csv")

        // When: saving with enclosure
        let ok = try ex.saveTo(fileName: file, atomically: true, overwrite: true, separator: ",", encloseElementsBy: "\"", asRow: true, stringEncoding: .utf8)
        #expect(ok == true)

        // Then: file exists and elements are properly quoted with doubled quotes
        let data = try String(contentsOfFile: file, encoding: .utf8)
        // expected: "a,b","c""d","e"
        let expected = "\"a,b\",\"c\"\"d\",\"e\""
        #expect(data == expected)
    }

    @Test("exportJSONString round-trips via examine(fromJSONFile:)")
    func exportJSONRoundTrip() throws {
        let ex = SSExamine<Double, Double>(withArray: [1.0, 2.0, 3.0], name: "nums", characterSet: nil)
        let file = tmpPath("dataset.json")

        let ok = try ex.exportJSONString(fileName: file, atomically: true, overwrite: true, stringEncoding: .utf8)
        #expect(ok == true)

        let loaded = try SSExamine<Double, Double>.examine(fromJSONFile: file, stringEncoding: .utf8)
        #expect(loaded != nil)
        #expect(loaded!.isEqual(ex))
    }

    @Test("saveTo without overwrite throws fileExists")
    func saveToNoOverwriteThrows() async throws {
        let ex = SSExamine<Int, Double>(withArray: [1, 2, 3], name: "ints", characterSet: nil)
        let file = tmpPath("dataset.csv")
        _ = try ex.saveTo(fileName: file, atomically: true, overwrite: true, separator: ",", encloseElementsBy: nil, asRow: true, stringEncoding: .utf8)

        do {
            _ = try ex.saveTo(fileName: file, atomically: true, overwrite: false, separator: ",", encloseElementsBy: nil, asRow: true, stringEncoding: .utf8)
            #expect(false, "expected fileExists error")
        } catch {
            if let e = error as? SSSwiftyStatsError {
                #expect(e.type == .fileExists)
            } else {
                #expect(false, "unexpected error type: \(error)")
            }
        }
    }
}

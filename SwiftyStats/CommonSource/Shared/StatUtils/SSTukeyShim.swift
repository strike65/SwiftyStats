//
//  SSTukeyShim.swift
//  Thin shim to present the legacy API while delegating to the
//  clean Swift 6 reimplementation in SSTukeyNew.swift
//

import Foundation

/// Compatibility shim: preserves the legacy `ptukey` entrypoint while
/// delegating to the new, clean Swift 6 implementation.
///
/// This avoids GPL-derived code paths while maintaining API stability.
extension Helpers {
    internal static func ptukey(q: Double, nranges: Double, numberOfMeans: Double, df: Double, tail: SSCDFTail, returnLogP: Bool) throws -> Double {
        return try Helpers.ptukey_new(q: q, nranges: nranges, numberOfMeans: numberOfMeans, df: df, tail: tail, returnLogP: returnLogP)
    }
}

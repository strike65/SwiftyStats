//
//  Created by VT on 20.09.25.
//  Copyright © 2025 Volker Thieme. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  

import Foundation
#if canImport(CoreGraphics)
import CoreGraphics
#endif

#if canImport(RealModule)
import RealModule
public typealias RealLike = Real
#else
public protocol RealLike: BinaryFloatingPoint & LosslessStringConvertible {}
extension Float: RealLike {}
extension Double: RealLike {}
#if arch(i386) || arch(x86_64)
extension Float80: RealLike {}
#endif
#endif

public enum RealConversionError: Error, CustomStringConvertible {
    case unsupportedType(Any.Type)
    case invalidString(String)
    case outOfRange(String)
    case nonFinite(String)
    case conversionFailed(String)

    public var description: String {
        switch self {
        case .unsupportedType(let t): return "Unsupported input type: " + String(describing: t)
        case .invalidString(let s):   return "Invalid numeric representation: \"" + s + "\""
        case .outOfRange(let s):      return "Value out of representable range: " + s
        case .nonFinite(let s):       return "Non-finite value (NaN/Inf): " + s
        case .conversionFailed(let s):return "Conversion failed: " + s
        }
    }
}

public final class RealConverter {

    public static func to<T: RealLike>(_ value: Any, locale: Locale? = nil) throws -> T {
        if let t = value as? T { return t }

        switch value {
        case let s as String:
            // If `locale == nil`, runtime locales are considered as hints
            return try parseString(s, as: T.self, localeHint: locale)

        case let dec as Decimal:
            return try fromDecimal(dec, as: T.self)

        case let num as NSNumber:
            if CFGetTypeID(num) == CFBooleanGetTypeID() {
                return try fromInteger(num.boolValue ? 1 : 0, as: T.self)
            }
            let dec = num.decimalValue
            return try fromDecimal(dec, as: T.self)

        case let d as Double: return try fromFP(d, as: T.self)
        case let f as Float:  return try fromFP(f, as: T.self)
        #if arch(i386) || arch(x86_64)
        case let f80 as Float80: return try fromFP(f80, as: T.self)
        #endif

        #if canImport(CoreGraphics)
        case let cg as CGFloat:
            return try fromFP(Double(cg), as: T.self)
        #endif

        case let i as Int:     return try fromInteger(i, as: T.self)
        case let i as Int8:    return try fromInteger(i, as: T.self)
        case let i as Int16:   return try fromInteger(i, as: T.self)
        case let i as Int32:   return try fromInteger(i, as: T.self)
        case let i as Int64:   return try fromInteger(i, as: T.self)
        case let u as UInt:    return try fromInteger(u, as: T.self)
        case let u as UInt8:   return try fromInteger(u, as: T.self)
        case let u as UInt16:  return try fromInteger(u, as: T.self)
        case let u as UInt32:  return try fromInteger(u, as: T.self)
        case let u as UInt64:  return try fromInteger(u, as: T.self)

        default:
            throw RealConversionError.unsupportedType(type(of: value))
        }
    }

    @inline(__always) public static func toFloat(_ v: Any, locale: Locale? = nil) throws -> Float  { try to(v, locale: locale) as Float }
    @inline(__always) public static func toDouble(_ v: Any, locale: Locale? = nil) throws -> Double { try to(v, locale: locale) as Double }
    #if arch(i386) || arch(x86_64)
    @inline(__always) public static func toFloat80(_ v: Any, locale: Locale? = nil) throws -> Float80 { try to(v, locale: locale) as Float80 }
    #endif
}

// MARK: - Private

private extension RealConverter {

    // Locale candidates: explicit → autoupdatingCurrent → current
    static func localeCandidates(from hint: Locale?) -> [Locale] {
        var list: [Locale] = []
        if let h = hint { list.append(h) }
        list.append(Locale.autoupdatingCurrent)
        let curr = Locale.current
        if curr.identifier != Locale.autoupdatingCurrent.identifier { list.append(curr) }
        // Fallbacks: common formats (de_DE, en_US) as last resort
        list.append(contentsOf: [Locale(identifier: "de_DE"), Locale(identifier: "en_US_POSIX")])
        // Deduplicate by identifier
        var seen = Set<String>()
        return list.filter { seen.insert($0.identifier).inserted }
    }

    static func parseString<T: RealLike>(_ s: String, as _: T.Type, localeHint: Locale?) throws -> T {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)

        switch trimmed.lowercased() {
        case "nan": throw RealConversionError.nonFinite("NaN")
        case "inf", "+inf": throw RealConversionError.nonFinite("+Inf")
        case "-inf": throw RealConversionError.nonFinite("-Inf")
        default: break
        }

        // 1) Try NumberFormatter with locale candidates
        for loc in localeCandidates(from: localeHint) {
            if let d = parseWithFormatter(trimmed, locale: loc) {
                return try fromFP(d, as: T.self)
            }
        }

        // 2) Decimal → Double → direct T parser
        if let dec = Decimal(string: trimmed) {
            return try fromDecimal(dec, as: T.self)
        }
        if let d = Double(trimmed) {
            return try fromFP(d, as: T.self)
        }
        if let direct = T(trimmed) {
            if direct.isFinite { return direct }
            throw RealConversionError.nonFinite(trimmed)
        }

        // 3) Heuristic based on runtime locale (decimal/thousands separators)
        let runtime = localeCandidates(from: localeHint).first ?? .autoupdatingCurrent
        if let d = coerceLocaleAwareDecimal(trimmed, locale: runtime) {
            return try fromFP(d, as: T.self)
        }

        throw RealConversionError.invalidString(s)
    }

    static func parseWithFormatter(_ s: String, locale: Locale) -> Double? {
        let nf = NumberFormatter()
        nf.locale = locale
        nf.numberStyle = .decimal
        let decSep = nf.decimalSeparator ?? "."
        let grpSep = nf.groupingSeparator ?? ","
        // Normalize space-like separators to plain space and quote-like to the locale's grouping separator
        var cleaned = s
            .replacingOccurrences(of: "\u{00A0}", with: " ")   // NBSP → space
            .replacingOccurrences(of: "\u{202F}", with: " ")   // NNBSP → space
            .replacingOccurrences(of: "\u{2009}", with: " ")   // thin space → space
        let quoteLikes = ["'", "’", "‛", "ʼ"]
        for q in quoteLikes {
            cleaned = cleaned.replacingOccurrences(of: q, with: grpSep)
        }
        _ = decSep // kept for clarity
        return nf.number(from: cleaned)?.doubleValue
    }

    // Locale-aware heuristic (e.g., "1.234,56" for de_DE; "1,234.56" for en_US)
    static func coerceLocaleAwareDecimal(_ s: String, locale: Locale) -> Double? {
        let nf = NumberFormatter()
        nf.locale = locale
        nf.numberStyle = .decimal
        let decSep = nf.decimalSeparator ?? "."
        let grpSep = nf.groupingSeparator ?? ","

        // Remove various whitespace characters commonly used as group separators
        var t = s.replacingOccurrences(of: "\u{00A0}", with: "")
                  .replacingOccurrences(of: "\u{202F}", with: "")
                  .replacingOccurrences(of: " ", with: "")

        // If both separators appear: remove grouping separator and replace decimal separator with dot
        if t.contains(decSep) && t.contains(grpSep) {
            t = t.replacingOccurrences(of: grpSep, with: "")
                 .replacingOccurrences(of: decSep, with: ".")
            return Double(t)
        }

        // If only decimal separator appears: replace with dot
        if t.contains(decSep) {
            t = t.replacingOccurrences(of: decSep, with: ".")
            return Double(t)
        }

        // If notation is swapped (typical import error), try alternate pairs
        let altPairs: [(grp: String, dec: String)] = [
            (",", "."), (".", ","),
            ("’", ","), ("’", "."),
            ("'", ","), ("'", "."),
            ("\u{00A0}", ","), ("\u{00A0}", "."),
            ("\u{202F}", ","), ("\u{202F}", "."),
            ("\u{2009}", ","), ("\u{2009}", ".")
        ]
        for (g, d) in altPairs where t.contains(g) || t.contains(d) {
            let u = t.replacingOccurrences(of: g, with: "")
                     .replacingOccurrences(of: d, with: ".")
            if let val = Double(u) { return val }
        }
        return nil
    }

    static func fromDecimal<T: RealLike>(_ dec: Decimal, as _: T.Type) throws -> T {
        let d = (dec as NSDecimalNumber).doubleValue
        return try fromFP(d, as: T.self)
    }
    static func fromInteger<T: RealLike, I: BinaryInteger>(_ i: I, as _: T.Type) throws -> T {
        let t = T(i)
        if t.isFinite { return t }
        throw RealConversionError.outOfRange("\(i)")
    }
    static func fromFP<T: RealLike, F: BinaryFloatingPoint>(_ x: F, as _: T.Type) throws -> T {
        let t = T(x)
        if t.isFinite { return t }
        throw RealConversionError.nonFinite("\(x)")
    }
}

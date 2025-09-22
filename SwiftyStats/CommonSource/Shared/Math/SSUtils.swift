//
//  SSUtils.swift
//  SwiftyStats
//
//  Created by strike65 on 03.07.17.
//
/*
 Copyright (2017-2019) strike65
 
 GNU GPL 3+
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, version 3 of the License.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 */

import Foundation


extension Helpers {
    
    
    /// Tests whether a value is an integer (i.e. has no decimal places).
    /// - Parameter value: A Floating Point value
    internal static func isInteger<T: SSFloatingPoint>(_ value: T) -> Bool {
        return value.truncatingRemainder(dividingBy: 1).isZero
    }
    
    /// Tests whether a value is odd.
    /// - Parameter value: A Floating Point value
    internal static func isOdd<T: SSFloatingPoint>(_ value: T) -> Bool {
        let (ip, frac) = Darwin.modf(value)
        guard frac.isZero else { return false }
        return !ip.truncatingRemainder(dividingBy: 2).isZero
    }
    
    /// Returns the integer value of x.
    /// - Parameter x: Floating Point value
    internal static func integerValue<T: SSFloatingPoint, I: BinaryInteger>(_ x: T) -> I {
        #if arch(x86_64)
        if let v = x as? Float80 { return I(v) }
        #endif
        if let v = x as? Double { return I(v) }
        if let v = x as? Float { return I(v) }
        // Unreachable for current SSFloatingPoint conformers
        return 0
    }
    
    
    /// Returns the integer part of a floating point number
    /// - Parameter x: Floating Point value
    internal static func integerPart<T: SSFloatingPoint>(_ x: T) -> T {
        let (ip, _) = Darwin.modf(x)
        return ip
    }
    
    
    /// Returns the fractional part of a double-value
    /// - Parameter value: Floating Point value
    internal static func fractionalPart<T: SSFloatingPoint>(_ value: T) -> T {
        let (_, frac) = Darwin.modf(value)
        return frac
    }
    
    internal static func isNumeric<T>(_ value: T) -> Bool {
        if value is any BinaryInteger { return true }
        if value is any BinaryFloatingPoint { return true }
        if value is NSNumber { return true }
        if value is NSDecimalNumber { return true }
        return false
    }
    
    /// Tests whether a value is numeric
    /// - Parameter value: A value of type T
    internal static func isNumber<T>(_ value: T) -> Bool {
       return isNumeric(value)
    }
    
    /// Tries to convert a numerical representation of value of type `FROM` to a Floating Point Type (`TO`)
    ///
    /// - Parameter value: Value
    /// - Returns: The numerical value as a FloatingPoint if possible, TO.nan otherwise.
    internal static func makeFP<FROM, TO: SSFloatingPoint>(_ value: FROM) -> TO {
        // Swift 6 fast-path: normalize to Double and cast to TO
        do {
            let toDouble: Double? = {
                switch value {
                case let s as String:
                    return Double(s)
                case let s as NSString:
                    return Double(s as String)
                case let v as Double:
                    return v
                case let v as Float:
                    return Double(v)
                #if arch(i386) || arch(x86_64)
                case let v as Float80:
                    return Double(v)
                #endif
                case let v as Int:
                    return Double(v)
                case let v as Int8:
                    return Double(v)
                case let v as Int16:
                    return Double(v)
                case let v as Int32:
                    return Double(v)
                case let v as Int64:
                    return Double(v)
                case let v as UInt:
                    return Double(v)
                case let v as UInt8:
                    return Double(v)
                case let v as UInt16:
                    return Double(v)
                case let v as UInt32:
                    return Double(v)
                case let v as UInt64:
                    return Double(v)
                case let v as NSNumber:
                    return v.doubleValue
                case let v as NSDecimalNumber:
                    return v.doubleValue
                case let v as Decimal:
                    return NSDecimalNumber(decimal: v).doubleValue
                default:
                    return nil
                }
            }()
            if let d = toDouble {
                switch TO.self {
                case is Double.Type:
                    return d as! TO
                case is Float.Type:
                    return Float(d) as! TO
                #if arch(i386) || arch(x86_64)
                case is Float80.Type:
                    return Float80(d) as! TO
                #endif
                default:
                    break
                }
            }
        }
        switch value {
        case let s as String:
            switch TO.self {
                #if arch(i386) || arch(x86_64)
            case is Float80.Type:
                return Float80.init(s) as! TO
                #endif
            case is Float.Type:
                return Float.init(s) as! TO
            case is Double.Type:
                return Double.init(s) as! TO
            default:
                return TO.nan
            }
        case let f as Float:
            switch TO.self {
                #if arch(i386) || arch(x86_64)
            case is Float80.Type:
                return Float80.init("\(f)") as! TO
                #endif
            case is Float.Type:
                return Float.init("\(f)") as! TO
            case is Double.Type:
                return Double.init(f) as! TO
            default:
                return TO.nan
            }
        case let f as Double:
            switch TO.self {
                #if arch(i386) || arch(x86_64)
            case is Float80.Type:
                return Float80.init("\(f)") as! TO
                #endif
            case is Float.Type:
                return Float.init("\(f)") as! TO
            case is Double.Type:
                return Double.init(f) as! TO
            default:
                return TO.nan
            }
            #if arch(i386) || arch(x86_64)
        case let f as Float80:
            switch TO.self {
            case is Float80.Type:
                return Float80.init("\(f)") as! TO
            case is Float.Type:
                return Float.init("\(f)") as! TO
            case is Double.Type:
                return Double.init(f) as! TO
            default:
                return TO.nan
            }
            #endif
        case let i as Int:
            switch TO.self {
                #if arch(i386) || arch(x86_64)
            case is Float80.Type:
                return Float80.init(i) as! TO
                #endif
            case is Float.Type:
                return Float.init(i) as! TO
            case is Double.Type:
                return Double.init(i) as! TO
            default:
                return TO.nan
            }
        case let i as Int8:
            switch TO.self {
                #if arch(i386) || arch(x86_64)
            case is Float80.Type:
                return Float80.init(i) as! TO
                #endif
            case is Float.Type:
                return Float.init(i) as! TO
            case is Double.Type:
                return Double.init(i) as! TO
            default:
                return TO.nan
            }
        case let i as Int16:
            switch TO.self {
                #if arch(i386) || arch(x86_64)
            case is Float80.Type:
                return Float80.init(i) as! TO
                #endif
            case is Float.Type:
                return Float.init(i) as! TO
            case is Double.Type:
                return Double.init(i) as! TO
            default:
                return TO.nan
            }
        case let i as Int32:
            switch TO.self {
                #if arch(i386) || arch(x86_64)
            case is Float80.Type:
                return Float80.init(i) as! TO
                #endif
            case is Float.Type:
                return Float.init(i) as! TO
            case is Double.Type:
                return Double.init(i) as! TO
            default:
                return TO.nan
            }
        case let i as Int64:
            switch TO.self {
                #if arch(i386) || arch(x86_64)
            case is Float80.Type:
                return Float80.init(i) as! TO
                #endif
            case is Float.Type:
                return Float.init(i) as! TO
            case is Double.Type:
                return Double.init(i) as! TO
            default:
                return TO.nan
            }
        case let i as UInt:
            switch TO.self {
                #if arch(i386) || arch(x86_64)
            case is Float80.Type:
                return Float80.init(i) as! TO
                #endif
            case is Float.Type:
                return Float.init(i) as! TO
            case is Double.Type:
                return Double.init(i) as! TO
            default:
                return TO.nan
            }
        case let i as UInt8:
            switch TO.self {
                #if arch(i386) || arch(x86_64)
            case is Float80.Type:
                return Float80.init(i) as! TO
                #endif
            case is Float.Type:
                return Float.init(i) as! TO
            case is Double.Type:
                return Double.init(i) as! TO
            default:
                return TO.nan
            }
        case let i as UInt16:
            switch TO.self {
                #if arch(i386) || arch(x86_64)
            case is Float80.Type:
                return Float80.init(i) as! TO
                #endif
            case is Float.Type:
                return Float.init(i) as! TO
            case is Double.Type:
                return Double.init(i) as! TO
            default:
                return TO.nan
            }
        case let i as UInt32:
            switch TO.self {
                #if arch(i386) || arch(x86_64)
            case is Float80.Type:
                return Float80.init(i) as! TO
                #endif
            case is Float.Type:
                return Float.init(i) as! TO
            case is Double.Type:
                return Double.init(i) as! TO
            default:
                return TO.nan
            }
        case let i as UInt64:
            switch TO.self {
                #if arch(i386) || arch(x86_64)
            case is Float80.Type:
                return Float80.init(i) as! TO
                #endif
            case is Float.Type:
                return Float.init(i) as! TO
            case is Double.Type:
                return Double.init(i) as! TO
            default:
                return TO.nan
            }
        default:
            return TO.nan
        }
    }
    
    /// Casts the members of an array from one numeric type to a floating-point type.
    internal static func castArrayToFloatingPoint<T, FPT>(_ array: [T]) -> [FPT]? where T: Numeric & Codable & Hashable & Comparable, FPT: SSFloatingPoint & Codable {
        if array.isEmpty { return nil }
        let result: [FPT] = array.map { Helpers.makeFP($0) }
        return result
    }
    
    /// Returns an `SSExamine` object containing one unique element replicated `count` times.
    /// - Parameter value: The element value.
    /// - Parameter count: Number of repetitions.
    internal static func replicateExamine<T, FPT: SSFloatingPoint & Codable>(value: T!, count: Int!) -> SSExamine<T, FPT> where T: Comparable, T: Hashable, FPT: Codable {
        let array = Array<T>(repeating: value, count: count)
        let res = SSExamine<T, FPT>(withArray: array, name: nil, characterSet: nil)
        return res
    }
    
    /// Provides scanning helpers (text → numbers).
    enum NumberScanner {
        internal static func scanDouble(string: String?) -> Double? {
            guard let string else { return nil }
            let s = Scanner(string: string)
            return s.scanDouble() ?? Double.nan
        }
        
        internal static func scanFloat(string: String?) -> Float? {
            guard let string else { return nil }
            let s = Scanner(string: string)
            return s.scanFloat() ?? Float.nan
        }
        
        internal static func scanHexDouble(string: String?) -> Double? {
            guard let string else { return nil }
            var res: Double = 0.0
            let s = Scanner(string: string)
            if s.scanHexDouble(&res) { return res }
            return nil
        }
        
        internal static func scanHexFloat(string: String?) -> Float? {
            guard let string else { return nil }
            var res: Float = 0.0
            let s = Scanner(string: string)
            if s.scanHexFloat(&res) { return res }
            return nil
        }
                
        internal static func scanHexInt64(string: String?) -> UInt64? {
            guard let string else { return nil }
            var res: UInt64 = 0
            let s = Scanner(string: string)
            if s.scanHexInt64(&res) { return res }
            return nil
        }
        
        internal static func scanInt64(string: String?) -> Int64? {
            guard let string else { return nil }
            var res: Int64 = 0
            let s = Scanner(string: string)
            if s.scanInt64(&res) { return res }
            return nil
        }
        
        internal static func scanUInt64(string: String?) -> UInt64? {
            guard let string else { return nil }
            var res: UInt64 = 0
            let s = Scanner(string: string)
            if s.scanUnsignedLongLong(&res) { return res }
            return nil
        }
        
        
        internal static func scanInt(string: String?) -> Int? {
            guard let string else { return nil }
            var res: Int = 0
            let s = Scanner(string: string)
            if s.scanInt(&res) { return res }
            return nil
        }
        
        
        internal static func scanString(string: String?) -> String? {
            guard let string else { return nil }
            return string
        }
        
    }
}

// MARK: Logging

struct StandardErrorOutputStream: TextOutputStream {
    mutating func write(_ string: String) {
        let stdErr = FileHandle.standardError
        if let data = string.data(using: .utf8) {
            stdErr.write(data)
        }
        else {
            stdErr.write("ERROR WRITING TO stdErr in SwiftyStats".data(using: .utf8)!)
        }
    }
}

internal func printError(_ message: String) {
    var outputStream = StandardErrorOutputStream()
    print(message, to: &outputStream)
}

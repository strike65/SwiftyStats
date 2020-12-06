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
        var modr: (T, T)
        modr = modf(value)
        if !modr.1.isZero {
            return false;
        }
        else if modr.0.truncatingRemainder(dividingBy: 2).isZero {
            return false
        }
        else {
            return true
        }
    }
    
    /// Returns the integer value of x.
    /// - Parameter x: Floating Point value
    internal static func integerValue<T: SSFloatingPoint, I: BinaryInteger>(_ x: T) -> I {
        switch x {
        case let d as Double:
            switch I.self {
            case is Int32.Type:
                let r = Int32(d)
                return r as! I
            case is Int16.Type:
                let r = Int16(d)
                return r as! I
            case is Int64.Type:
                let r = Int64(d)
                return r as! I
            case is Int8.Type:
                let r = Int8(d)
                return r as! I
            case is UInt.Type:
                let r = UInt(d)
                return r as! I
            case is UInt32.Type:
                let r = UInt32(d)
                return r as! I
            case is UInt16.Type:
                let r = UInt16(d)
                return r as! I
            case is UInt8.Type:
                let r = UInt8(d)
                return r as! I
            case is UInt64.Type:
                let r = UInt64(d)
                return r as! I
            default:
                let r = Int(d)
                return r as! I
            }
        case let d as Float:
            switch I.self {
            case is Int32.Type:
                let r = Int32(d)
                return r as! I
            case is Int16.Type:
                let r = Int16(d)
                return r as! I
            case is Int64.Type:
                let r = Int64(d)
                return r as! I
            case is Int8.Type:
                let r = Int8(d)
                return r as! I
            case is UInt.Type:
                let r = UInt(d)
                return r as! I
            case is UInt32.Type:
                let r = UInt32(d)
                return r as! I
            case is UInt16.Type:
                let r = UInt16(d)
                return r as! I
            case is UInt8.Type:
                let r = UInt8(d)
                return r as! I
            case is UInt64.Type:
                let r = Int64(d)
                return r as! I
            default:
                let r = Int(d)
                return r as! I
            }
            #if arch(x86_64)
        case let d as Float80:
            switch I.self {
            case is Int32.Type:
                let r = Int32(d)
                return r as! I
            case is Int16.Type:
                let r = Int16(d)
                return r as! I
            case is Int64.Type:
                let r = Int64(d)
                return r as! I
            case is Int8.Type:
                let r = Int8(d)
                return r as! I
            case is UInt.Type:
                let r = UInt(d)
                return r as! I
            case is UInt32.Type:
                let r = UInt32(d)
                return r as! I
            case is UInt16.Type:
                let r = UInt16(d)
                return r as! I
            case is UInt8.Type:
                let r = UInt8(d)
                return r as! I
            case is UInt64.Type:
                let r = Int64(d)
                return r as! I
            default:
                let r = Int(d)
                return r as! I
            }
            #endif
        default:
            return 0
        }
    }
    
    
    /// Returns the integer part of a floating point number
    /// - Parameter x: Floating Point value
    internal static func integerPart<T: SSFloatingPoint>(_ x: T) -> T {
        var modr: (T, T)
        modr = Darwin.modf(x)
        return modr.0
    }
    
    
    /// Returns the fractional part of a double-value
    /// - Parameter value: Floating Point value
    internal static func fractionalPart<T: SSFloatingPoint>(_ value: T) -> T {
        var modr: (T, T)
        modr = Darwin.modf(value)
        return modr.1
    }
    
    internal static func isNumeric<T>(_ value: T) -> Bool {
        #if arch(arm) || arch(arm64)
         if let _ = value as? Double {
                return true
            }
            else if let _ = value as? Int {
                return true
            }
            else if let _ = value as? Int8 {
                return true
            }
            else if let _ = value as? Int32 {
                return true
            }
            else if let _ = value as? Int64 {
                return true
            }
            else if let _ = value as? UInt {
                return true
            }
            else if let _ = value as? UInt8 {
                return true
            }
            else if let _ = value as? UInt32 {
                return true
            }
            else if let _ = value as? UInt64 {
                return true
            }
            else if let _ = value as? Float {
                return true
            }
            else if let _ = value as? Float32 {
                return true
            }
            else if let _ = value as? Float64 {
                return true
            }
            else if let _ = value as? NSNumber {
                return true
            }
            else if let _ = value as? NSDecimalNumber {
                return true
            }
            else {
                return false
            }
        #endif
        #if arch(i386) || arch(x86_64)
            if let _ = value as? Double {
                return true
            }
            else if let _ = value as? Int {
                return true
            }
            else if let _ = value as? Int8 {
                return true
            }
            else if let _ = value as? Int32 {
                return true
            }
            else if let _ = value as? Int64 {
                return true
            }
            else if let _ = value as? UInt {
                return true
            }
            else if let _ = value as? UInt8 {
                return true
            }
            else if let _ = value as? UInt32 {
                return true
            }
            else if let _ = value as? UInt64 {
                return true
            }
            else if let _ = value as? Float {
                return true
            }
            else if let _ = value as? Float32 {
                return true
            }
            else if let _ = value as? Float64 {
                return true
            }
            else if let _ = value as? Float80 {
                return true
            }
            else if let _ = value as? NSNumber {
                return true
            }
            else if let _ = value as? NSDecimalNumber {
                return true
            }
            else {
                return false
            }
        #endif
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
    
    /// Casts the members of an Array form one numerical type to a Floating Point
    internal static func castArrayToFloatingPoint<T, FPT>(_ array: Array<T>) -> Array<FPT>? where T: Numeric & Codable & Hashable & Comparable, FPT: SSFloatingPoint & Codable {
        if array.isEmpty {
            return nil
        }
        let result: Array<FPT> = array.map( {(value: T) in
            return  Helpers.makeFP(value)
        })
        return result
    }
    
    /// Returns a SSExamine object of length (i.e. number of unique elements) one and count "count"
    /// - Parameter value: Value
    /// - Parameter count: Number of values
    internal static func replicateExamine<T, FPT: SSFloatingPoint & Codable>(value: T!, count: Int!) -> SSExamine<T, FPT> where T: Comparable, T: Hashable, FPT: Codable {
        let array = Array<T>.init(repeating: value, count: count)
        let res = SSExamine<T, FPT>.init(withArray: array, name: nil, characterSet: nil)
        return res
    }
    
    /// Provides scanning functions (text --> numbers)
    enum NumberScanner {
        internal static func scanDouble(string: String?) -> Double? {
            guard string != nil else {
                return nil
            }
            var res: Double = 0.0
            let s = Scanner.init(string: string!)
            if s.scanDouble(&res) {
                return res
            }
            else {
                return nil
            }
        }
        
        internal static func scanFloat(string: String?) -> Float? {
            guard string != nil else {
                return nil
            }
            var res: Float = 0.0
            let s = Scanner.init(string: string!)
            if s.scanFloat(&res) {
                return res
            }
            else {
                return nil
            }
        }
        
        internal static func scanHexDouble(string: String?) -> Double? {
            guard string != nil else {
                return nil
            }
            var res: Double = 0.0
            let s = Scanner.init(string: string!)
            if s.scanHexDouble(&res) {
                return res
            }
            else {
                return nil
            }
        }
        
        internal static func scanHexFloat(string: String?) -> Float? {
            guard string != nil else {
                return nil
            }
            var res: Float = 0.0
            let s = Scanner.init(string: string!)
            if s.scanHexFloat(&res) {
                return res
            }
            else {
                return nil
            }
        }
        
        internal static func scanHexInt32(string: String?) -> UInt32? {
            guard string != nil else {
                return nil
            }
            var res: UInt32 = 0
            let s = Scanner.init(string: string!)
            if s.scanHexInt32(&res) {
                return res
            }
            else {
                return nil
            }
        }
        
        internal static func scanHexInt64(string: String?) -> UInt64? {
            guard string != nil else {
                return nil
            }
            var res: UInt64 = 0
            let s = Scanner.init(string: string!)
            if s.scanHexInt64(&res) {
                return res
            }
            else {
                return nil
            }
        }
        
        internal static func scanInt32(string: String?) -> Int32? {
            guard string != nil else {
                return nil
            }
            var res: Int32 = 0
            let s = Scanner.init(string: string!)
            if s.scanInt32(&res) {
                return res
            }
            else {
                return nil
            }
        }
        
        
        internal static func scanInt64(string: String?) -> Int64? {
            guard string != nil else {
                return nil
            }
            var res: Int64 = 0
            let s = Scanner.init(string: string!)
            if s.scanInt64(&res) {
                return res
            }
            else {
                return nil
            }
        }
        
        internal static func scanUInt64(string: String?) -> UInt64? {
            guard string != nil else {
                return nil
            }
            var res: UInt64 = 0
            let s = Scanner.init(string: string!)
            if s.scanUnsignedLongLong(&res) {
                return res
            }
            else {
                return nil
            }
        }
        
        
        internal static func scanInt(string: String?) -> Int? {
            guard string != nil else {
                return nil
            }
            var res: Int = 0
            let s = Scanner.init(string: string!)
            if s.scanInt(&res) {
                return res
            }
            else {
                return nil
            }
        }
        
        
        internal static func scanString(string: String?) -> String? {
            guard string != nil else {
                return nil
            }
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








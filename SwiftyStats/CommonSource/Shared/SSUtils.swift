//
//  SSUtils.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 03.07.17.
//
/*
 Copyright (c) 2017 Volker Thieme
 
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


/// Binomial
internal func binomial2(_ n: Double!, _ k: Double!) -> Double {
    if k == 0.0 {
        return 1.0
    }
    let num: Double = lgamma(n + 1.0)
    let den: Double = lgamma(n - k + 1.0) + lgamma(k + 1.0)
    let q: Double = num - den
    return exp(q)
}


/// Tests, if a value is integer.
/// - Paramter value: A double-value.
internal func isInteger(_ value: Double) -> Bool {
    return value.truncatingRemainder(dividingBy: 1) == 0
}

/// Tests, if a value is odd.
/// - Paramter value: A double-value.
internal func isOdd(_ value: Double) -> Bool {
    var frac: Double
    var intp: Double = 0.0
    frac = modf(value, &intp)
    if !frac.isZero {
        return false;
    }
    else if intp.truncatingRemainder(dividingBy: 2) == 0 {
        return false
    }
    else {
        return true
    }
}

/// Returns the fractional part of a double-value
/// - Paramter value: A double-value.
internal func fractionalPart(_ value: Double) -> Double {
    var intpart: Double = 0.0
    let result: Double = modf(value, &intpart)
    return result
}

/// Tests, if a value is numeric
/// - Paramter value: A value of type T
internal func isNumber<T>(_ value: T) -> Bool {
    let valueMirror = Mirror(reflecting: value)
    #if arch(arm) || arch(arm64)
        if (valueMirror.subjectType == Int.self || valueMirror.subjectType == UInt.self || valueMirror.subjectType == Double.self || valueMirror.subjectType == Int8.self || valueMirror.subjectType == Int16.self || valueMirror.subjectType == Int32.self || valueMirror.subjectType == Int64.self || valueMirror.subjectType == UInt8.self || valueMirror.subjectType == UInt16.self || valueMirror.subjectType == UInt32.self || valueMirror.subjectType == UInt64.self || valueMirror.subjectType == Float.self || valueMirror.subjectType == Float32.self || valueMirror.subjectType == NSNumber.self || valueMirror.subjectType == NSDecimalNumber.self ) {
            return true
        }
        else {
            return false
        }
    #else
        if (valueMirror.subjectType == Int.self || valueMirror.subjectType == UInt.self || valueMirror.subjectType == Double.self || valueMirror.subjectType == Int8.self || valueMirror.subjectType == Int16.self || valueMirror.subjectType == Int32.self || valueMirror.subjectType == Int64.self || valueMirror.subjectType == UInt8.self || valueMirror.subjectType == UInt16.self || valueMirror.subjectType == UInt32.self || valueMirror.subjectType == UInt64.self || valueMirror.subjectType == Float.self || valueMirror.subjectType == Float32.self || valueMirror.subjectType == Float80.self || valueMirror.subjectType == NSNumber.self || valueMirror.subjectType == NSDecimalNumber.self ) {
            return true
        }
        else {
            return false
        }
    #endif
}

internal func castValueToDouble<T>(_ value: T) -> Double? {
    #if arch(i386) || arch(x86_64)
        if value is Float80 {
            return Double(value as! Float80)
        }
    #endif
    if value is Int {
        return Double(value as! Int)
    }
    else if value is Int8 {
        return Double(value as! Int8)
    }
    else if value is Int16 {
        return Double(value as! Int16)
    }
    else if value is Int32 {
        return Double(value as! Int32)
    }
    else if value is Int64 {
        return Double(value as! Int64)
    }
    else if value is UInt {
        return Double(value as! UInt)
    }
    else if value is UInt8 {
        return Double(value as! UInt8)
    }
    else if value is UInt16 {
        return Double(value as! UInt16)
    }
    else if value is UInt32 {
        return Double(value as! UInt32)
    }
    else if value is UInt64 {
        return Double(value as! UInt64)
    }
    else if value is Float {
        return Double(value as! Float)
    }
    else if value is Float32 {
        return Double(value as! Float32)
    }
    else if value is Double {
        return value as? Double
    }
    else {
        return nil
    }
}



/// Returns the maximum of two comparable values
internal func maximum<T>(_ t1: T, _ t2: T) -> T where T:Comparable {
    if t1 > t2 {
        return t1
    }
    else {
        return t2
    }
}

/// Returns the minimum of two comparable values
internal func minimum<T>(_ t1: T, _ t2: T) -> T where T:Comparable {
    if t1 < t2 {
        return t1
    }
    else {
        return t2
    }
}


/* The natural logarithm of factorial n! for  0 <= n <= MFACT */
fileprivate let LnFactorial: Array<Double> = [
    0, 0, 0.693147180559945309417, 1.79175946922805500081, 3.17805383034794561965, 4.78749174278204599425, 6.57925121201010099506, 8.52516136106541430017, 10.6046029027452502284, 12.8018274800814696112, 15.1044125730755152952, 17.5023078458738858393, 19.9872144956618861495, 22.5521638531234228856, 25.1912211827386815001, 27.8992713838408915661, 30.6718601060806728038, 33.5050734501368888840, 36.3954452080330535762, 39.3398841871994940362, 42.3356164607534850297, 45.3801388984769080262, 48.4711813518352238796, 51.6066755677643735704, 54.7847293981123191901, 58.0036052229805199393, 61.2617017610020019848, 64.5575386270063310590, 67.8897431371815349829, 71.2570389671680090101,  74.6582363488301643855, 78.0922235533153106314,  81.5579594561150371785, 85.0544670175815174140,  88.5808275421976788036, 92.1361756036870924833,  95.7196945421432024850, 99.3306124547874269293,  102.968198614513812699, 106.631760260643459126,  110.320639714757395429, 114.034211781461703233,  117.771881399745071539, 121.533081515438633962,  125.317271149356895125, 129.123933639127214883,  132.952575035616309883, 136.802722637326368470,  140.673923648234259399, 144.565743946344886009,  148.477766951773032068, 152.409592584497357839,  156.360836303078785194, 160.331128216630907028,  164.320112263195181412, 168.327445448427652330,  172.352797139162801564, 176.395848406997351715,  180.456291417543771052, 184.533828861449490502,  188.628173423671591187, 192.739047287844902436,  196.866181672889993991, 201.009316399281526679,  205.168199482641198536, 209.342586752536835646,  213.532241494563261191, 217.736934113954227251,  221.956441819130333950, 226.190548323727593332,  230.439043565776952321, 234.701723442818267743,  238.978389561834323054, 243.268849002982714183,  247.572914096186883937, 251.890402209723194377,  256.221135550009525456, 260.564940971863209305,  264.921649798552801042, 269.291097651019822536,  273.673124285693704149, 278.067573440366142914,  282.474292687630396027, 286.893133295426993951,  291.323950094270307566, 295.766601350760624021,  300.220948647014131754, 304.686856765668715473,  309.164193580146921945, 313.652829949879061783,  318.152639620209326850, 322.663499126726176891,  327.185287703775217201, 331.717887196928473138,  336.261181979198477034, 340.815058870799017869,  345.379407062266854107, 349.954118040770236930,  354.539085519440808849, 359.134205369575398776,  363.739375555563490144, 368.354496072404749595,  372.979468885689020676, 377.614197873918656447,  382.258588773060029111, 386.912549123217552482,  391.575988217329619626, 396.248817051791525799,  400.930948278915745492, 405.622296161144889192,  410.322776526937305421, 415.032306728249639556,  419.750805599544734099, 424.478193418257074668,  429.214391866651570128, 433.959323995014820194,  438.712914186121184840, 443.475088120918940959,  448.245772745384605719, 453.024896238496135104, 457.81238798127818109]

/*------------------------------------------------------------------------*/

/// Returns the logarithm of n!
internal func logFactorial(_ n: Int) -> Double {
    /* Returns the natural logarithm of factorial n! */
    if (n <= 60) {
        return LnFactorial[n]
        
    } else {
        let x = Double(n + 1)
        let y = 1.0 / (x * x)
        var z = ((-(5.95238095238E-4 * y) + 7.936500793651E-4) * y - 2.7777777777778E-3) * y + 8.3333333333333E-2
        z = ((x - 0.5) * log(x) - x) + 9.1893853320467E-1 + z / x
        return z
    }
}


/// Returns a SSExamine object of length one and count "count"
/// - Parameter value: Value
/// - Parameter count: Number of values
internal func replicateExamine<T>(value: T!, count: Int!) -> SSExamine<T> where T: Comparable, T: Hashable {
    let array = Array<T>.init(repeating: value, count: count)
    let res = SSExamine<T>.init(withArray: array, name: nil, characterSet: nil)
    return res
}


/*************************************************************
 scanning functions
*************************************************************/

internal func scanDouble(string: String?) -> Double? {
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

internal func scanDecimal(string: String?) -> Decimal? {
    guard string != nil else {
        return nil
    }
    var res: Decimal = 0.0
    let s = Scanner.init(string: string!)
    if s.scanDecimal(&res) {
        return res
    }
    else {
        return nil
    }
}

internal func scanFloat(string: String?) -> Float? {
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

internal func scanHexDouble(string: String?) -> Double? {
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

internal func scanHexFloat(string: String?) -> Float? {
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

internal func scanHexInt32(string: String?) -> UInt32? {
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

internal func scanHexInt64(string: String?) -> UInt64? {
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

internal func scanInt32(string: String?) -> Int32? {
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


internal func scanInt64(string: String?) -> Int64? {
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

internal func scanUInt64(string: String?) -> UInt64? {
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


internal func scanInt(string: String?) -> Int? {
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


internal func scanString(string: String?) -> String? {
    guard string != nil else {
        return nil
    }
    return string
}

class StandardErrorOutputStream: TextOutputStream {
    func write(_ string: String) {
        let stdErr = FileHandle.standardError
        if let data = string.data(using: .utf8) {
            stdErr.write(data)
        }
        else {
            stdErr.write("ERROR WRITING TO stdErr in SwiftyStats".data(using: .utf8)!)
        }
    }
}

internal func printError(_ message: String!) {
    var outputStream = StandardErrorOutputStream()
    print(message, to: &outputStream)
}










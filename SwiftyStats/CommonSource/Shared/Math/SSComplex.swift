//
//  Created by VT on 11.10.18.
//  Copyright © 2018 strike65. All rights reserved.
//
/*
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

#if os(Linux)
import Glibc
#else
import Darwin
#endif

precedencegroup ComplexAdditionPrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
    lowerThan: MultiplicationPrecedence
}

/// Complex operators 
infix operator &++: AdditionPrecedence
infix operator &+=: AssignmentPrecedence
infix operator &--: AdditionPrecedence
infix operator &-=: AssignmentPrecedence
infix operator &%: MultiplicationPrecedence
infix operator &%=: MultiplicationPrecedence
infix operator &**: MultiplicationPrecedence
infix operator &**=: MultiplicationPrecedence
prefix operator &+++
prefix operator &---
// adapted from https://github.com/dankogai/swift-complex


/// A complex numeric protocol , inspired by https://github.com/dankogai/swift-complex
/// Unfortunately by using generic types, the Swift 4.2 compiler has difficulities to typecheck some
/// more ore less complex expressions. Therefore, the additive, subtractive, multiplicative operator must be defined in some exotic notation.
/// All complex mathematical functions are defined at the top level.
internal protocol SSComplexNumeric : Hashable {
    associatedtype Element: SignedNumeric
    var re: Element { get set }
    var im: Element { get set }
    init(re r: Element, im i: Element)
}

internal extension SSComplexNumeric {
    
    init(_ re: Element, _ im: Element) {
        self.init(re: re, im: im)
    }
    init(_ re: Element) {
        self.init(re, 0)
    }
    var i: Self {
        return Self(-im, re)
    }
    static prefix func &+++(_ c: Self) -> Self {
        return c
    }
    static func &++(_ lhs: Self, rhs: Self) -> Self {
        return Self(lhs.re + rhs.re, lhs.im + rhs.im)
    }
    static func &++(_ lhs: Self, _ rhs: Element) -> Self {
        return Self(lhs.re + rhs, lhs.im)
    }
    static func &++(_ lhs: Element, _ rhs: Self) -> Self {
        return rhs &++ lhs
    }
    static func &+=(_ lhs: inout Self, _ rhs: Self) {
        lhs = lhs &++ rhs
    }
    static func &+=(_ lhs: inout Self, _ rhs: Element) {
        lhs = lhs &++ rhs
    }
    static prefix func &---(_ c: Self) -> Self {
        return Self(-c.re, -c.im)
    }
    static func &--(_ lhs: Self, _ rhs: Self) -> Self {
        return Self(lhs.re - rhs.re, lhs.im - rhs.im)
    }
    static func &--(_ lhs: Self, _ rhs: Element) -> Self {
        return Self(lhs.re - rhs, lhs.im)
    }
    static func &--(_ lhs: Element, _ rhs: Self) -> Self {
        return &---rhs &++ lhs
    }
    static func &-=(_ lhs: inout Self, _ rhs: Self) {
        lhs = lhs &-- rhs
    }
    static func &-=(_ lhs: inout Self, _ rhs: Element) {
        lhs = lhs &-- rhs
    }
    static func &**(_ lhs: Self, _ rhs: Self) -> Self {
        return Self(lhs.re * rhs.re - lhs.im * rhs.im, lhs.re * rhs.im + lhs.im * rhs.re)
    }
    static func &**(_ lhs: Self, _ rhs: Element) -> Self {
        return Self(lhs.re * rhs, lhs.im * rhs)
    }
    static func &**(_ lhs: Element, _ rhs: Self) -> Self {
        return rhs &** lhs
    }
    static func &**=(_ lhs: inout Self, _ rhs: Self) {
        lhs = lhs &** rhs
    }
    static func &**=(_ lhs: inout Self, _ rhs: Element) {
        lhs = lhs &** rhs
    }
    var conj: Self {
        return Self(self.re, -self.im)
    }
}

internal typealias SSComplexFloatElement = SSFloatingPoint

internal protocol SSComplexFloat : SSComplexNumeric & CustomStringConvertible where Element: SSFloatingPoint {
}
internal extension SSComplexFloat {

    
    init(abs: Element, arg: Element) {
        self.init(abs * SSMath.cos1(arg), abs * SSMath.sin1(arg))
    }
    
    init(_ real: Element) {
        self.init(re: real, im: 0)
    }

    var arg: Element {
        if self.re.isZero && self.im.isZero {
            return 0
        }
        else {
            return SSMath.atan21(self.im, self.re)
        }
    }

    var abs: Element {
        return self.norm
    }
    
    var norm: Element {
        if !self.re.isZero && !self.im.isZero {
            return SSMath.hypot1(self.re, self.im)
        }
        else if self.re.isZero && !self.im.isZero {
            return Swift.abs(self.im)
        }
        else if !self.re.isZero && self.im.isZero {
            return Swift.abs(self.re)
        }
        return 0
    }

    static func &%(_ lhs: Self, _ rhs: Self) -> Self {
        let ar: Element = lhs.re
        let ai: Element = lhs.im
        let br: Element = rhs.re
        let bi: Element = rhs.im
        let s: Element = 1 / rhs.norm
        let sbr: Element = s * br
        let sbi: Element = s * bi
        let zr: Element = (ar * sbr + ai * sbi) * s
        let zi: Element = (ai * sbr - ar * sbi) * s
        return Self(zr, zi)
    }
    
    static func &%(_ lhs: Self, _ rhs: Element) -> Self {
        return Self(lhs.re / rhs, lhs.im / rhs)
    }
    
    static func &%(_ lhs: Element, _ rhs: Self) -> Self {
        return Self(lhs, 0) &% rhs
    }

    static func &%=(_ lhs: inout Self, _ rhs: Self) {
        lhs = lhs &% rhs
    }
    
    static func &%=(_ lhs: inout Self, _ rhs: Element) {
        lhs = lhs &% rhs
    }

    static var nan: Self {
        return Self(Element.nan, Element.nan)
    }
    
    var isNan: Bool {
        return re.isNaN || im.isNaN
    }
    
    static var infinity: Self {
        return Self(Element.infinity, Element.infinity)
    }
    
    var isInfinite: Bool {
        return re.isInfinite || im.isInfinite
    }
    
    var isFinite: Bool {
        return !self.isInfinite
    }
    
    static var zero: Self {
        return Self(0,0)
    }
    
    var isZero: Bool {
        return re.isZero && im.isZero
    }
}

/// Provides an Complex type which conforms to SSComplexFloat. Real an Imaginary part comforms to SSFloatingPoint
internal struct Complex<T: SSComplexFloatElement> : SSComplexFloat {
    
    public typealias Element = T

    private var real: Element
    private var imag: Element

    
    /// Description string (x + y * i)
    public var description: String {
        let sign = imag.sign == .minus ? "-" : "+"
        let a: Element = Swift.abs(imag)
        return "\(real) "+sign+" \(a) i"
    }
    
    /// Real part
    public var re: Element {
        get {
            return real
        }
        set {
            real = newValue
        }
    }
    /// Imaginary Part
    public var im: Element {
        get {
            return imag
        }
        set {
            imag = newValue
        }
    }
    
    /// Euqality operator
    ///
    /// - Parameter lhs: left hand side
    /// - Parameter rhs: right hand side
    /// - Returns: True, lhs.re == rhs.re && lhs.im == rhs.im
    public static func ==(_ lhs: Complex<T>, _ rhs: Complex<T>) -> Bool {
        return lhs.re == rhs.re && rhs.re == rhs.im
    }
    
    /// Init a new complex number
    /// - Parameter re: Real part
    /// - Parameter im: Imaginary part
    public init(re r: T, im i: T) {
        real = r
        imag = i
    }
}


extension Complex : Codable where Element: Codable {
    /// Defines the coding keys for Codable
    internal enum CodingKeys : String, CodingKey {
        public typealias RawValue = String
        case real, imag
    }
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or if the data read is corrupted or otherwise invalid.
    /// - Parameter decoder: The decoder to read data from.
    internal init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.real = try values.decode(Element.self, forKey: .real)
        self.imag = try values.decode(Element.self, forKey: .imag)
    }
    
    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, encoder will encode an empty keyed container in its place.
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: This function throws an error if any values are invalid for the given encoder’s format.
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.re, forKey: .real)
        try container.encode(self.im, forKey: .imag)
    }
}

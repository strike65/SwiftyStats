//
//  Created by VT on 11.10.18.
//  Copyright © 2018 Volker Thieme. All rights reserved.
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

//import Foundation
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
public protocol SSComplexNumeric : Hashable {
    associatedtype Element: SignedNumeric
    var re: Element { get set }
    var im: Element { get set }
    init(re r: Element, im i: Element)
}

extension SSComplexNumeric {
    
    public init(_ re: Element, _ im: Element) {
        self.init(re: re, im: im)
    }
    public init(_ re: Element) {
        self.init(re, 0)
    }
    public var i: Self {
        return Self(-im, re)
    }
    public static prefix func &+++(_ c: Self) -> Self {
        return c
    }
    public static func &++(_ lhs: Self, rhs: Self) -> Self {
        return Self(lhs.re + rhs.re, lhs.im + rhs.im)
    }
    public static func &++(_ lhs: Self, _ rhs: Element) -> Self {
        return Self(lhs.re + rhs, lhs.im)
    }
    public static func &++(_ lhs: Element, _ rhs: Self) -> Self {
        return rhs &++ lhs
    }
    public static func &+=(_ lhs: inout Self, _ rhs: Self) {
        lhs = lhs &++ rhs
    }
    public static func &+=(_ lhs: inout Self, _ rhs: Element) {
        lhs = lhs &++ rhs
    }
    public static prefix func &---(_ c: Self) -> Self {
        return Self(-c.re, -c.im)
    }
    public static func &--(_ lhs: Self, _ rhs: Self) -> Self {
        return Self(lhs.re - rhs.re, lhs.im - rhs.im)
    }
    public static func &--(_ lhs: Self, _ rhs: Element) -> Self {
        return Self(lhs.re - rhs, lhs.im)
    }
    public static func &--(_ lhs: Element, _ rhs: Self) -> Self {
        return &---rhs &++ lhs
    }
    public static func &-=(_ lhs: inout Self, _ rhs: Self) {
        lhs = lhs &-- rhs
    }
    public static func &-=(_ lhs: inout Self, _ rhs: Element) {
        lhs = lhs &-- rhs
    }
    public static func &**(_ lhs: Self, _ rhs: Self) -> Self {
        return Self(lhs.re * rhs.re - lhs.im * rhs.im, lhs.re * rhs.im + lhs.im * rhs.re)
    }
    public static func &**(_ lhs: Self, _ rhs: Element) -> Self {
        return Self(lhs.re * rhs, lhs.im * rhs)
    }
    public static func &**(_ lhs: Element, _ rhs: Self) -> Self {
        return rhs &** lhs
    }
    public static func &**=(_ lhs: inout Self, _ rhs: Self) {
        lhs = lhs &** rhs
    }
    public static func &**=(_ lhs: inout Self, _ rhs: Element) {
        lhs = lhs &** rhs
    }
    public var conj: Self {
        return Self(self.re, -self.im)
    }
}

public typealias SSComplexFloatElement = SSFloatingPoint

public protocol SSComplexFloat : SSComplexNumeric & CustomStringConvertible where Element: SSFloatingPoint {
}
extension SSComplexFloat {

    
    public init(abs: Element, arg: Element) {
        self.init(abs * cos1(arg), abs * sin1(arg))
    }
    
    public init(_ real: Element) {
        self.init(re: real, im: 0)
    }

    public var arg: Element {
        if self.re.isZero && self.im.isZero {
            return 0
        }
        else {
            return atan21(self.im, self.re)
        }
    }

    public var abs: Element {
        return self.norm
//        return (self.re * self.re + self.im * self.im).squareRoot()
    }
    
    public var norm: Element {
        if !self.re.isZero && !self.im.isZero {
            return hypot1(self.re, self.im)
        }
        else if self.re.isZero && !self.im.isZero {
            return Swift.abs(self.im)
        }
        else if !self.re.isZero && self.im.isZero {
            return Swift.abs(self.re)
        }
        return 0
        //        return self.re * self.re + self.im * self.im
    }

    public static func &%(_ lhs: Self, _ rhs: Self) -> Self {
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
    
    public static func &%(_ lhs: Self, _ rhs: Element) -> Self {
        return Self(lhs.re / rhs, lhs.im / rhs)
    }
    
    public static func &%(_ lhs: Element, _ rhs: Self) -> Self {
        return Self(lhs, 0) &% rhs
    }

    public static func &%=(_ lhs: inout Self, _ rhs: Self) {
        lhs = lhs &% rhs
    }
    
    public static func &%=(_ lhs: inout Self, _ rhs: Element) {
        lhs = lhs &% rhs
    }

    public static var nan: Self {
        return Self(Element.nan, Element.nan)
    }
    
    public var isNan: Bool {
        return re.isNaN || im.isNaN
    }
    
    public static var infinity: Self {
        return Self(Element.infinity, Element.infinity)
    }
    
    public var isInfinite: Bool {
        return re.isInfinite || im.isInfinite
    }
    
    public var isFinite: Bool {
        return !self.isInfinite
    }
    
    public static var zero: Self {
        return Self(0,0)
    }
    
    public var isZero: Bool {
        return re.isZero && im.isZero
    }
}

public struct Complex<T: SSComplexFloatElement> : SSComplexFloat {
    public typealias Element = T

    private var real: Element
    private var imag: Element

    
    public var description: String {
        let sign = imag.sign == .minus ? "-" : "+"
        let a: Element = Swift.abs(imag)
        return "\(real) "+sign+" \(a) i"
    }
    

    public var re: Element {
        get {
            return real
        }
        set {
            real = newValue
        }
    }
    
    public var im: Element {
        get {
            return imag
        }
        set {
            imag = newValue
        }
    }
    
    public static func ==(_ lhs: Complex<T>, _ rhs: Complex<T>) -> Bool {
        return lhs.re == rhs.re && rhs.re == rhs.im
    }

    public init(re r: T, im i: T) {
        real = r
        imag = i
    }
}

extension Complex : Codable where Element: Codable {
    public enum CodingKeys : String, CodingKey {
        public typealias RawValue = String
        case real, imag
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.real = try values.decode(Element.self, forKey: .real)
        self.imag = try values.decode(Element.self, forKey: .imag)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.re, forKey: .real)
        try container.encode(self.im, forKey: .imag)
    }
}

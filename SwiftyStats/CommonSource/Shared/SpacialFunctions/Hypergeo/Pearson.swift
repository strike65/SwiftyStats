//
//  Created by VT on 17.09.18.
//  Copyright © 2018 strike65. All rights reserved.
//
/*
 Copyright (2017-2019) strike65
 
 GNU GPL 3+
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, version 3 of the License.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 */

import Foundation

// see : https://people.maths.ox.ac.uk/porterm/research/pearson_final.pdf
public func h1f1taylora<T: SSComplexFloatElement>(_ a: Complex<T>, _ b: Complex<T>, _ x: Complex<T>, _ tol: T) -> (h: Complex<T>, mIter: Bool) {
    var a1: Array<Complex<T>> = Array<Complex<T>>.init()
    var sum: Complex<T> = Complex<T>.init(re: 1, im: 0)
    a1.append(Complex<T>.init(re: 1, im: 0))
    var e1, e2, e3, e4, e5: Complex<T>
    var jf: Complex<T>
    var maxIter: Bool = false
    for j in stride(from: 1, through: 500, by: 1) {
        jf = Complex<T>.init(re: makeFP(j), im: 0)
        e1 = (a &++ jf &-- 1)
        e2 = (b &++ jf &-- 1)
        e3 = e1 &% e2
        e4 = x &% jf &** a1[j - 1]
        e5 = e3 &** e4
        a1.append(e5)
        sum = sum &++ a1[j]
        if ((a1[j - 1].abs / sum.abs) < tol && (a1[j].abs / sum.abs < tol)) {
            break
        }
        if j == 500 {
            maxIter = true
        }
    }
    return (h: sum, mIter: maxIter)
}

public func h1f1taylorb<T: SSComplexFloatElement>(_ a: Complex<T>, _ b: Complex<T>, _ x: Complex<T>, _ tol: T) -> (h: Complex<T>, mIter: Bool) {
    var r: Array<Complex<T>> = Array<Complex<T>>.init()
    r.append(a &% b)
    r.append((a &++ 1) &% 2 &% (b &++ 1))
    var A: Array<Complex<T>> = Array<Complex<T>>.init()
    A.append(1 &++ x &** r[0])
    A.append(A[0] &++ pow(x, 2) &** a &% b &** r[1])
    var jf: Complex<T>
    var e1, e2, e3: Complex<T>
    var maxIter: Bool = false
    for j in stride(from: 3, through: 500, by: 1) {
        jf = Complex<T>.init(re: makeFP(j), im: 0)
        e1 = (a &++ jf &-- 1) &% jf
        e2 = (b &++ jf &-- 1)
        e3 = e1 &% e2
        r.append(e3)
        e1 = A[j - 2] &++ (A[j - 2] &-- A[j - 3]) &** r[j - 2] &** x
        A.append(e1)
        if (((A[j - 1] &-- A[j - 2]).abs / A[j - 2].abs) < tol) && ((A[j - 2] &-- A[j - 3]).abs / A[j - 3].abs < tol) {
            break
        }
        if j == 500 {
            maxIter = true
        }
    }
    return (h: A.last!, mIter: maxIter)
}

public func h1f1singleFraction<T: SSComplexFloatElement>(a: Complex<T>, b: Complex<T>, z: Complex<T>, tol: T) -> (h: Complex<T>, maxiter: Bool) {
    var A1: Array<Complex<T>> = Array<Complex<T>>.init()
    var B1: Array<Complex<T>> = Array<Complex<T>>.init()
    var C1: Array<Complex<T>> = Array<Complex<T>>.init()
    var D1: Array<Complex<T>> = Array<Complex<T>>.init()
    var maxiter: Bool = false
    A1.append(Complex<T>.zero)
    A1.append(b)
    B1.append(Complex<T>.init(re: 1, im: 0))
    B1.append(a &** z)
    C1.append(Complex<T>.init(re: 1, im: 0))
    C1.append(b)
    D1.append(Complex<T>.init(re: 1, im: 0))
    D1.append((b &++ a &** z) &% b)
    var jf: Complex<T>
    for j in stride(from: 3, through: 500, by: 1) {
        jf = Complex<T>.init(re: makeFP(j), im: 0)
        A1[j - 1] = (A1[j - 2] &++ B1[j - 2]) &** (jf &-- 1) &** (b &++ jf &-- 2)
        B1[j - 1] = B1[j - 2] &** (a &++ jf &-- 2) &** z
        C1[j - 1] = C1[j - 2] &** (jf &-- 1) &** (b &++ jf &-- 2)
        if A1[j - 1].isInfinite || B1[j - 1].isInfinite || C1[j - 1].isInfinite {
            break
        }
        D1[j - 1] = (A1[j - 1] &++ B1[j - 1] &% C1[j - 1])
        if (((D1[j - 1] &-- D1[j - 2]).abs / D1[j - 2].abs) < tol) && (((D1[j - 2] &-- D1[j - 3]).abs / D1[j - 3].abs) < tol) {
            break
        }
        if j == 500 {
            maxiter = true
        }
    }
    return (h: D1.last!, maxiter: maxiter)
}

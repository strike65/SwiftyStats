//
//  Created by VT on 17.09.18.
//  Copyright © 2018 Volker Thieme. All rights reserved.
//
/*
 Copyright (c) 2017 Volker Thieme
 
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
public func taylora<T: SSFloatingPoint>(_ a: T, _ b: T, _ x: T, _ tol: T) -> (h: T, mIter: Bool) {
    var a1: Array<T> = Array<T>.init()
    var sum: T = 1
    a1.append(1)
    var e1, e2, e3, e4, e5: T
    var jf: T
    var maxIter: Bool = false
    for j in stride(from: 1, through: 500, by: 1) {
        jf = makeFP(j)
        e1 = (a + jf - 1)
        e2 = (b + jf - 1)
        e3 = e1 / e2
        e4 = x / jf * a1[j - 1]
        e5 = e3 * e4
        a1.append(e5)
        sum = sum + a1[j]
        if (abs(a1[j - 1]) / abs(sum) < tol && (abs(a1[j]) / abs(sum) < tol)) {
            break
        }
        if j == 500 {
            maxIter = true
        }
    }
    return (h: sum, mIter: maxIter)
}

public func taylorb<T: SSFloatingPoint>(_ a: T, _ b: T, _ x: T, _ tol: T) -> (h: T, mIter: Bool) {
    var r: Array<T> = Array<T>.init()
    r.append(a / b)
    r.append((a + 1) / 2 / (b + 1))
    var A: Array<T> = Array<T>.init()
    A.append(1 + x * r[0])
    A.append(A[0] + pow1(x,2) * a / b * r[1])
    var jf: T
    var e1, e2, e3: T
    var maxIter: Bool = false
    for j in stride(from: 3, through: 500, by: 1) {
        jf = makeFP(j)
        e1 = (a + jf - 1) / jf
        e2 = (b + jf - 1)
        e3 = e1 / e2
        r.append(e3)
        e1 = A[j - 2] + (A[j - 2] - A[j - 3]) * r[j - 2] * x
        A.append(e1)
        if (abs(A[j - 1] - A[j - 2]) / abs(A[j-2]) < tol) && (abs(A[j - 2] - A[j - 2]) / abs(A[j - 3]) < tol) {
            break
        }
        if j == 500 {
            maxIter = true
        }
    }
    return (h: A.last!, mIter: maxIter)
}


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

public func h2f2<T: SSFloatingPoint & Codable>(a1: T, a2: T, b1: T, b2: T, z: T) -> T {
    var sum1, s: T
    var tol: T = T.ulpOfOne
    let maxIT: T = 1000
    var k: T = 0
    sum1 = 0
    s = 0
    var p1: T = 0
    var p2: T = 0
    var temp1: T = 0
    let lz: T = log1(z)
    var kz: T
    while k < maxIT {
        p1 = lpochhammer(x: a1, n: k) + lpochhammer(x: a2, n: k)
        p2 = lpochhammer(x: b1, n: k) + lpochhammer(x: b2, n: k)
        kz = k * lz
        temp1 = p1 + kz - p2
        temp1 = temp1 - logFactorial(integerValue(k))
        s = exp1(temp1)
        if abs((sum1 - (s + sum1))) < tol {
            break
        }
        sum1 = sum1 + exp1(temp1)
        k = k + 1
    }
    return sum1
}

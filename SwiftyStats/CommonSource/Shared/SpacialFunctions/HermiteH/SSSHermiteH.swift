//
//  Created by VT on 22.08.18.
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

public func hermiteH<T: SSFloatingPoint & Codable>(ny: T, z: T) -> T {
    let hyper1: T = hypergeometric1F1(a: -(ny / 2), b: T.half, x: pow1(z, 2))
    let hyper2: T = hypergeometric1F1(a: (1 - ny) / 2, b: makeFP(1.5), x: pow1(z, 2))
    let gamma1: T = tgamma1((1 - ny) / 2)
    let gamma2: T = tgamma1(-ny / 2)
    let s1: T = hyper1 / gamma1
    let s2: T = (2 * z * hyper2) / gamma2
    let f2: T = s1 - s2
    let result: T = pow1(2, ny) * T.sqrtpi * f2
    return result
}

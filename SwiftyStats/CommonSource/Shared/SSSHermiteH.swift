//
//  Created by VT on 22.08.18.
//  Copyright © 2018 Volker Thieme. All rights reserved.
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

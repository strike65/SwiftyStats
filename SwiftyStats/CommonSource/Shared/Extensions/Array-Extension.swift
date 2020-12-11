//
//  Created by VT on 06.06.19.
//  Copyright © 2019 strike65. All rights reserved.
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

extension Array {
    /// Returns an array of indexes for which the condition is true.
    ///
    /// ### Usage ###
    ///     let A = [1,2,3,2,1,3]
    ///     var indices = A.indices(where: { $0 == 1 })
    ///     // [0, 4]
    ///     indices = A.indices(where: { $0 == 3 })
    ///     // [2, 5]
    ///     indices = A.indices(where: {(x: Int) -> Bool in
    ///        return x == 1
    ///     })
    ///     // [0, 4]
    ///
    /// - Parameter condition: condition
    /// - Returns: Array containing indices
    public func indices(where condition: (Element) -> Bool) -> [Index] {
        var result: [Index] = []
        if self.isEmpty {
            return result
        }
        var k: Index = 0
        for e in self {
            if condition(e) {
                result.append(k)
            }
            k = k + 1
        }
        return result
    }
}

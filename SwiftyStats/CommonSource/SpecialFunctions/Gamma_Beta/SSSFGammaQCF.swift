//
//  Created by VT on 27.09.18.
//  Copyright © 2018 strike65. All rights reserved.
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

/// The regularized Gamma function Q(a,z) (http://mathworld.wolfram.com/RegularizedGammaFunction.htm) function as cf
internal class SSGammaQ<T: SSFloatingPoint>: SSContFrac<T> {
    
    /// Parameter a.Must be set by the caller
    var a: T = T.nan
    /// Initializes a new instance
    override init() {
        super.init()
        self.a = T.nan
    }
    /// Returns the n_th a
    override func a_N(n: Int, point x: T) -> T {
        var ex1: T
        var ex2: T
        var ex3: T
        ex1 = Helpers.makeFP(n + n)
        ex2 = ex1 + T.one
        ex3 = ex2 - self.a
        return ex3 + x
    }
    
    /// Returns the n_th b
    override func b_N(n: Int, point x: T) -> T {
        return  Helpers.makeFP(n) * self.a -  Helpers.makeFP(n * n)
    }
}

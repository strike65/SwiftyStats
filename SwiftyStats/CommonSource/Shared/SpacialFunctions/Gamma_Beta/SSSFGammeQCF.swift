//
//  Created by VT on 27.09.18.
//  Copyright © 2018 Volker Thieme. All rights reserved.
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

/// The regularized Gamma function Q(a,z) (http://mathworld.wolfram.com/RegularizedGammaFunction.htm) function as cf
internal class SSGammaQ<T: SSFloatingPoint>: SSContFrac<T> {
    
    /// Parameter a.Must be set by the caller
    public var a: T = T.nan
    /// Initializes a new instance
    override public init() {
        super.init()
        self.a = T.nan
    }
    /// Returns the n_th a
    override public func a_N(n: Int, point x: T) -> T {
        return makeFP(n + n) + 1 - self.a + x
    }
    
    /// Returns the n_th b
    override public func b_N(n: Int, point x: T) -> T {
        return makeFP(n) * self.a - makeFP(n * n)
    }
}

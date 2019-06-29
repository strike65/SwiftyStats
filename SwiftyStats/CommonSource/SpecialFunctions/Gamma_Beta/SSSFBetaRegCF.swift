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

/// Class to compute the cf of the beta regularized function (http://dlmf.nist.gov/8.17#i) I_x(a,b)
internal class SSBetaRegularized<T: SSFloatingPoint>: SSContFrac<T> {
    
    /// Parameter a. Must be set by the caller
    var a: T = T.nan
    /// Parameter b. Must be set by the caller
    var b: T = T.nan
    
    
    /// Initializes a new instance
    override init() {
        super.init()
        self.a = T.nan
        self.b = T.nan
    }
    /// Returns the n_th a. Will always be  one in this case
    override func a_N(n: Int, point x: T) -> T {
        return  Helpers.makeFP(1.0)
    }
    
    /// Returns the nt_th b used by cf
    override func b_N(n: Int, point x: T) -> T {
        var res: T = T.nan
        var k: T
        var ex1: T
        var ex2: T
        var ex3: T
        if n % 2 == 0 {
            k =  Helpers.makeFP(n) / 2
            let expr1: T = self.b - k
            let expr2: T = k * expr1 * x
            let expr3: T = 2 * k
            let expr4: T = self.a + expr3 - 1
            res = expr2 / ( expr4 * ( self.a + expr3 ) )
        }
        else {
            k =  Helpers.makeFP(n - 1) /  Helpers.makeFP(2)
            ex1 = self.a + k
            ex2 = self.a + self.b + k
            ex3 = ex1 * ex2
            let expr1: T = ex3 * x
            let expr2: T = self.a + (2 * k)
            let expr3: T = expr2 + 1
            res = ( -1 ) * (expr1 / ( expr2 * expr3 ) )
        }
        return res
    }
    
}


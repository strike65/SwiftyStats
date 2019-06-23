//
//  SSContFrac.swift
//  SwiftyStats
//
//  Created by strike65 on 19.07.17.
//
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

/// An abstract class used to evaluate continued fractions. This class must be subclassed.
/// The n<sup>th</sup> coefficient is computed using the methods a_N:N point:x and b_N:N point:x<br/>
/// <img src="../img/cf.png" alt="">
internal class SSContFrac<T: SSFloatingPoint>: NSObject {

    /// max error
    var eps:T = T.ulpOfOne
    /// initializes a new instance
    override public init() {
        super.init()
        self.eps = T.ulpOfOne
    }
    
    /// The n<sup>th</sup> a coefficient at x. If a is a function of x, x is passed as well.
    /// - Parameter n: n
    /// - Parameter x: x
    func a_N(n: Int, point x: T) -> T {
        return T.nan
    }
    
    /// The n<sup>th</sup> b coefficient at x. If a is a function of x, x is passed as well.
    /// - Parameter n: n
    /// - Parameter x: x
    func b_N(n: Int, point x: T) -> T {
        return T.nan
    }
    
    /// Evaluates the continued fraction at point x. The evaluation will be stopped, when max iteration count is reached or one of the convergents is NAN.
    /// Algorithm according to Lentz, modified by Thompson and Barnett (http://www.fresco.org.uk/papers/Thompson-JCP64p490.pdf)
    /// - Parameter x:              x
    /// - Parameter eps:            max error allowed
    /// - Parameter maxIter:        Maximum number of iterations
    /// - Parameter converged:      TRUE if the result is valid
    /// - Parameter iterations:     On return it contains the number of iterations needed.
    /// - Returns: The result of the evaluated cf. If the cf didn't converge, converged is set to false and Double.nan is returned.
    func compute(x: T, eps: T = T.ulpOfOne, maxIter: Int, converged: UnsafeMutablePointer<Bool>!, iterations: UnsafeMutablePointer<Int>!) -> T {
        var n: Int = 1
        var hPrev: T
        let tiny: T =  Helpers.makeFP(1E-50)
        hPrev = self.a_N(n:0, point:x)
        if (hPrev == 0) {
            hPrev = tiny
        }
        var dPrev: T = 0
        var cPrev: T = hPrev
        var HN: T = hPrev
        var aN: T
        var bN: T
        var DN: T
        var CN: T
        var Delta: T
        var DeltaN: T
        while (n < maxIter) {
            aN = self.a_N(n: n, point: x)
            bN = self.b_N(n: n, point: x)
            DN = aN + bN * dPrev;
            Delta = abs(DN);
            if (Delta <= eps) {
                DN = tiny;
            }
            CN = aN + bN / cPrev
            Delta = abs(CN)
            if (CN <= eps) {
                CN = tiny
            }
            DN = 1 / DN
            DeltaN = DN * CN
            HN = hPrev * DeltaN
            if (HN.isInfinite) {
                converged.pointee = false;
                return T.nan;
            }
            if (HN.isInfinite) {
                converged.pointee = false;
                return T.nan;
            }
            if (abs(DeltaN -  Helpers.makeFP(1.0)) < eps) {
                converged.pointee = true;
                iterations.pointee = n;
                return HN;
            }
            dPrev = DN;
            cPrev = CN;
            hPrev = HN;
            n = n + 1
        }
        if (n >= maxIter) {
            converged.pointee = false;
            return T.nan;
        }
        converged.pointee = true;
        iterations.pointee = n
        return HN
    }
}


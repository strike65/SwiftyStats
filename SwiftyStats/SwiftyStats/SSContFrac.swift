//
//  SSContFrac.swift
//  SwiftyStats
//
//  Created by volker on 19.07.17.
//  Copyright © 2017 VTSoftware. All rights reserved.
//

import Foundation

/// An abstract class for the evaluation of continued fractions. This class must be subclassed.
/// The n<sup>th</sup> coefficient is computed using the methods a_N:N point:x and b_N:N point:x<br/>
/// <img src="../docs/img/cf.png" alt="">
public class SSContFrac: NSObject {

    public var eps:Double = 1E-12

    override public init() {
        super.init()
        self.eps = 1E-12
    }
    
    /// The n<sup>th</sup> a coefficient at x. If a is a function of x, x is passed as well.
    /// - Parameter n: n
    /// - Parameter x: x
    public func a_N(n: Int!, point x: Double?) -> Double {
        return Double.nan
    }
    
    /// The n<sup>th</sup> b coefficient at x. If a is a function of x, x is passed as well.
    /// - Parameter n: n
    /// - Parameter x: x
    public func b_N(n: Int!, point x: Double?) -> Double {
        return Double.nan
    }
    
    /// Evaluates the continued fraction at point x. The evaluation will be stopped, when the max iteration count is reached or one of the convergents is NAN.
    /// Algorithm according to Lentz, modified by Thompson and Barnett
    /// http://www.fresco.org.uk/papers/Thompson-JCP64p490.pdf
    /// - Parameter x: x
    /// - Parameter eps:       max error allowed
    /// - Parameter maxIter:     Maximum number of iterations
    /// - Parameter converged: TRUE if the result is valid
    /// - Parameter iterations:        On return it contains the number of iterations needed.
    /// - Returns: The result of the evaluated cf. If the cf didn't converge, converged is set to false and Double.nan is returned.
    public func compute(x: Double!, eps: Double!, maxIter: Int!, converged: UnsafeMutablePointer<Bool>!, iterations: UnsafeMutablePointer<Int>!) -> Double {
        var n: Int = 1
        var HBefore: Double
        let small: Double = 1E-50
        HBefore = self.a_N(n:0, point:x)
        if (HBefore == 0) {
            HBefore = small
        }
        var DBefore: Double = 0
        var CBefore: Double = HBefore
        var HN: Double = HBefore
        var aN: Double
        var bN: Double
        var DN: Double
        var CN: Double
        var Delta: Double
        var DeltaN: Double
        while (n < maxIter) {
            aN = self.a_N(n: n, point: x)
            bN = self.b_N(n: n, point: x)
            DN = aN + bN * DBefore;
            Delta = fabs(DN);
            if (Delta <= eps) {
                DN = small;
            }
            CN = aN + bN / CBefore;
            Delta = fabs(CN);
            if (CN <= eps) {
                CN = small;
            }
            DN = 1.0 / DN;
            DeltaN = DN * CN;
            HN = HBefore * DeltaN;
            if (HN.isInfinite) {
                converged.pointee = false;
                return Double.nan;
            }
            if (HN.isInfinite) {
                converged.pointee = false;
                return Double.nan;
            }
            if (fabs(DeltaN - 1.0) < eps) {
                converged.pointee = true;
                iterations.pointee = n;
                return HN;
            }
            DBefore = DN;
            CBefore = CN;
            HBefore = HN;
            n = n + 1
        }
        if (n >= maxIter) {
            converged.pointee = false;
            return Double.nan;
        }
        converged.pointee = true;
        iterations.pointee = n
        return HN
    }
}

/// Class to compute the cf of the beta regularized function
/// see http://dlmf.nist.gov/8.17#i
public class SSBetaRegularized: SSContFrac {
    
    public var a: Double = Double.nan
    public var b: Double = Double.nan
    
    override public init() {
        super.init()
        self.a = Double.nan
        self.b = Double.nan
    }
    
    override public func a_N(n: Int!, point x: Double?) -> Double {
        return 1.0
    }
    
    /// Returns the parameter b used by cf
    override public func b_N(n: Int!, point x: Double!) -> Double {
        var res: Double = Double.nan
        var k: Double
        if n % 2 == 0 {
            k = Double(n) / 2.0
            res = ( k * ( self.b - k ) * x ) / ( ( self.a + ( 2.0 * k ) - 1 ) * ( self.a + ( 2.0 * k ) ) )
        }
        else {
            k = ( Double(n - 1)) / 2.0;
            res = ( -1.0 ) * ( ( ( self.a + k ) * ( self.a + self.b + k ) * x ) / ( ( self.a + ( 2.0 * k ) ) * ( self.a + ( 2.0 * k ) + 1.0 ) ) );
        }
        return res
    }
    
}

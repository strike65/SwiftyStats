//
//  SSSpecialFunctions.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 19.07.17.
//
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

/*
 References:
 DiDonato,  A.    R.   and  Morris,  A.  H.   (1993)  ``Algorithm  708:
 Significant  Digit   Computation  of  the   Incomplete  Beta  Function
 Ratios.''  ACM Trans.  Math.  Softw. 18, 360-373.

 DiDonato,  A.  R.   and Morris,  A.  H.  (1986)  ``Computation of  the
 incomplete gamma function ratios and their inverse.'' ACM Trans. Math.
 Softw. 12, 377-393.
 
 Cody,  W.D. (1993).  ``ALGORITHM  715: SPECFUN  -  A Portable  FORTRAN
 Package  of   Special  Function   Routines  and  Test   Drivers''  ACM
 Trans. Math.  Softw. 19, 22-32.

 */

import Foundation
#if os(macOS) || os(iOS)
import os.log
#endif
/*                            i0.c
 *
 *    Modified Bessel function of order zero
 *
 *
 *
 * SYNOPSIS:
 *
 * double x, y, i0();
 *
 * y = i0( x );
 *
 *
 *
 * DESCRIPTION:
 *
 * Returns modified Bessel function of order zero of the
 * argument.
 *
 * The function is defined as i0(x) = j0( ix ).
 *
 * The range is partitioned into the two intervals [0,8] and
 * (8, infinity).  Chebyshev polynomial expansions are employed
 * in each interval.
 *
 *
 *
 * ACCURACY:
 *
 *                      Relative error:
 * arithmetic   domain     # trials      peak         rms
 *    DEC       0,30         6000       8.2e-17     1.9e-17
 *    IEEE      0,30        30000       5.8e-16     1.4e-16
 *
 */
/*                            i0e.c
 *
 *    Modified Bessel function of order zero,
 *    exponentially scaled
 *
 *
 *
 * SYNOPSIS:
 *
 * double x, y, i0e();
 *
 * y = i0e( x );
 *
 *
 *
 * DESCRIPTION:
 *
 * Returns exponentially scaled modified Bessel function
 * of order zero of the argument.
 *
 * The function is defined as i0e(x) = exp(-|x|) j0( ix ).
 *
 *
 *
 * ACCURACY:
 *
 *                      Relative error:
 * arithmetic   domain     # trials      peak         rms
 *    IEEE      0,30        30000       5.4e-16     1.2e-16
 * See i0().
 *
 */

/*                            i0.c        */


/*
 Cephes Math Library Release 2.8:  June, 2000
 Copyright 1984, 1987, 2000 by Stephen L. Moshier
 */


/* Chebyshev coefficients for exp(-x) I0(x)
 * in the interval [0,8].
 *
 * lim(x->0){ exp(-x) I0(x) } = 1.
 */

fileprivate let AI0: [Double] =
[
    -4.41534164647933937950E-18,
    3.33079451882223809783E-17,
    -2.43127984654795469359E-16,
    1.71539128555513303061E-15,
    -1.16853328779934516808E-14,
    7.67618549860493561688E-14,
    -4.85644678311192946090E-13,
    2.95505266312963983461E-12,
    -1.72682629144155570723E-11,
    9.67580903537323691224E-11,
    -5.18979560163526290666E-10,
    2.65982372468238665035E-9,
    -1.30002500998624804212E-8,
    6.04699502254191894932E-8,
    -2.67079385394061173391E-7,
    1.11738753912010371815E-6,
    -4.41673835845875056359E-6,
    1.64484480707288970893E-5,
    -5.75419501008210370398E-5,
    1.88502885095841655729E-4,
    -5.76375574538582365885E-4,
    1.63947561694133579842E-3,
    -4.32430999505057594430E-3,
    1.05464603945949983183E-2,
    -2.37374148058994688156E-2,
    4.93052842396707084878E-2,
    -9.49010970480476444210E-2,
    1.71620901522208775349E-1,
    -3.04682672343198398683E-1,
    6.76795274409476084995E-1]

/* Chebyshev coefficients for exp(-x) sqrt(x) I0(x)
 * in the inverted interval [8,infinity].
 *
 * lim(x->inf){ exp(-x) sqrt(x) I0(x) } = 1/sqrt(2pi).
 */

fileprivate let BI0: [Double] =
[
    -7.23318048787475395456E-18,
    -4.83050448594418207126E-18,
    4.46562142029675999901E-17,
    3.46122286769746109310E-17,
    -2.82762398051658348494E-16,
    -3.42548561967721913462E-16,
    1.77256013305652638360E-15,
    3.81168066935262242075E-15,
    -9.55484669882830764870E-15,
    -4.15056934728722208663E-14,
    1.54008621752140982691E-14,
    3.85277838274214270114E-13,
    7.18012445138366623367E-13,
    -1.79417853150680611778E-12,
    -1.32158118404477131188E-11,
    -3.14991652796324136454E-11,
    1.18891471078464383424E-11,
    4.94060238822496958910E-10,
    3.39623202570838634515E-9,
    2.26666899049817806459E-8,
    2.04891858946906374183E-7,
    2.89137052083475648297E-6,
    6.88975834691682398426E-5,
    3.36911647825569408990E-3,
    8.04490411014108831608E-1
]

/// Returns the modified Bessel function of order zero I0(x)
/// - Parameter x: Argument
///
/// ###Note###
/// adapted from Cephes with kind permission
internal func besselI0(x: Double!) -> Double {
    var y: Double
    var xx: Double
    if( x < 0 ) {
        xx = -x
    }
    else {
        xx = x
    }
    if( xx <= 8.0 ) {
        y = (xx / 2.0) - 2.0
        return( exp(x) * chebyshevEval(x: y, array: AI0, n: 30 ) )
    }
    else {
        return(  exp(x) * chebyshevEval( x: 32.0/xx - 2.0, array: BI0, n: 25 ) / sqrt(x) )
    }
    
}



/// Returns the exponentially scaled modified Bessel function of order zero I0(x) / exp(x)
/// - Parameter x: Argument
///
/// ###Note###
/// adapted from Cephes with kind permission
internal func besselI0e(x: Double!) -> Double {
    var y: Double
    var xx: Double
    
    if( x < 0 ) {
        xx = -x
    }
    else {
        xx = x
    }
    if( xx <= 8.0 ) {
        y = (xx / 2.0) - 2.0
        return( chebyshevEval( x: y,array: AI0,n: 30 ) )
    }
    else {
        return(  chebyshevEval( x: 32.0 / xx - 2.0, array: BI0, n: 25 ) / sqrt(x) )
    }
    
}

/*                            i1.c
 *
 *    Modified Bessel function of order one
 *
 *
 *
 * SYNOPSIS:
 *
 * double x, y, i1();
 *
 * y = i1( x );
 *
 *
 *
 * DESCRIPTION:
 *
 * Returns modified Bessel function of order one of the
 * argument.
 *
 * The function is defined as i1(x) = -i j1( ix ).
 *
 * The range is partitioned into the two intervals [0,8] and
 * (8, infinity).  Chebyshev polynomial expansions are employed
 * in each interval.
 *
 *
 *
 * ACCURACY:
 *
 *                      Relative error:
 * arithmetic   domain     # trials      peak         rms
 *    DEC       0, 30        3400       1.2e-16     2.3e-17
 *    IEEE      0, 30       30000       1.9e-15     2.1e-16
 *
 *
 */
/*                            i1e.c
 *
 *    Modified Bessel function of order one,
 *    exponentially scaled
 *
 *
 *
 * SYNOPSIS:
 *
 * double x, y, i1e();
 *
 * y = i1e( x );
 *
 *
 *
 * DESCRIPTION:
 *
 * Returns exponentially scaled modified Bessel function
 * of order one of the argument.
 *
 * The function is defined as i1(x) = -i exp(-|x|) j1( ix ).
 *
 *
 *
 * ACCURACY:
 *
 *                      Relative error:
 * arithmetic   domain     # trials      peak         rms
 *    IEEE      0, 30       30000       2.0e-15     2.0e-16
 * See i1().
 *
 */

/*                            i1.c 2        */


/*
 Cephes Math Library Release 2.8:  June, 2000
 Copyright 1985, 1987, 2000 by Stephen L. Moshier
 */
/* Chebyshev coefficients for exp(-x) I1(x) / x
 * in the interval [0,8].
 *
 * lim(x->0){ exp(-x) I1(x) / x } = 1/2.
 */

fileprivate let AJ: [Double] =
[
    2.77791411276104639959E-18,
    -2.11142121435816608115E-17,
    1.55363195773620046921E-16,
    -1.10559694773538630805E-15,
    7.60068429473540693410E-15,
    -5.04218550472791168711E-14,
    3.22379336594557470981E-13,
    -1.98397439776494371520E-12,
    1.17361862988909016308E-11,
    -6.66348972350202774223E-11,
    3.62559028155211703701E-10,
    -1.88724975172282928790E-9,
    9.38153738649577178388E-9,
    -4.44505912879632808065E-8,
    2.00329475355213526229E-7,
    -8.56872026469545474066E-7,
    3.47025130813767847674E-6,
    -1.32731636560394358279E-5,
    4.78156510755005422638E-5,
    -1.61760815825896745588E-4,
    5.12285956168575772895E-4,
    -1.51357245063125314899E-3,
    4.15642294431288815669E-3,
    -1.05640848946261981558E-2,
    2.47264490306265168283E-2,
    -5.29459812080949914269E-2,
    1.02643658689847095384E-1,
    -1.76416518357834055153E-1,
    2.52587186443633654823E-1
]
/*                            i1.c    */

/* Chebyshev coefficients for exp(-x) sqrt(x) I1(x)
 * in the inverted interval [8,infinity].
 *
 * lim(x->inf){ exp(-x) sqrt(x) I1(x) } = 1/sqrt(2pi).
 */

fileprivate let BJ: [Double] =
[
    7.51729631084210481353E-18,
    4.41434832307170791151E-18,
    -4.65030536848935832153E-17,
    -3.20952592199342395980E-17,
    2.96262899764595013876E-16,
    3.30820231092092828324E-16,
    -1.88035477551078244854E-15,
    -3.81440307243700780478E-15,
    1.04202769841288027642E-14,
    4.27244001671195135429E-14,
    -2.10154184277266431302E-14,
    -4.08355111109219731823E-13,
    -7.19855177624590851209E-13,
    2.03562854414708950722E-12,
    1.41258074366137813316E-11,
    3.25260358301548823856E-11,
    -1.89749581235054123450E-11,
    -5.58974346219658380687E-10,
    -3.83538038596423702205E-9,
    -2.63146884688951950684E-8,
    -2.51223623787020892529E-7,
    -3.88256480887769039346E-6,
    -1.10588938762623716291E-4,
    -9.76109749136146840777E-3,
    7.78576235018280120474E-1
]

/// Returns the modified Bessel function of order one I1(x)
/// - Parameter x: Argument
///
/// ###Note###
/// adapted from Cephes with kind permission
internal func besselI1(x: Double!) -> Double {
    var y, z: Double
    z = fabs(x)
    if( z <= 8.0 ) {
        y = (z / 2.0) - 2.0
        z = chebyshevEval(x: y,array: AJ,n: 29 ) * z * exp(z)
    }
    else {
        z = exp(z) * chebyshevEval(x: 32.0 / z - 2.0, array: BJ,n: 25 ) / sqrt(z)
    }
    if( x < 0.0 ) {
        z = -z
    }
    return z
}

/*                            i1e()    */
/// Returns the exponentially scaled modified Bessel function of order one I1(x)
/// - Parameter x: Argument
///
/// ###Note###
/// adapted from Cephes with kind permission
internal func besselI1e(x: Double!) -> Double {
    var y, z: Double
    
    z = fabs(x)
    
    if( z <= 8.0 ) {
        y = (z / 2.0) - 2.0
        z = chebyshevEval(x: y, array: AJ, n: 29 ) * z;
    }
    else {
        z = chebyshevEval( x: 32.0 / z - 2.0,array: BJ, n: 25 ) / sqrt(z);
    }
    if( x < 0.0 ) {
        z = -z
    }
    return z
}
/*                            iv.c
 *
 *    Modified Bessel function of noninteger order
 *
 *
 *
 * SYNOPSIS:
 *
 * double v, x, y, iv();
 *
 * y = iv( v, x );
 *
 *
 *
 * DESCRIPTION:
 *
 * Returns modified Bessel function of order v of the
 * argument.  If x is negative, v must be integer valued.
 *
 * The function is defined as Iv(x) = Jv( ix ).  It is
 * here computed in terms of the confluent hypergeometric
 * function, according to the formula
 *
 *              v  -x
 * Iv(x) = (x/2)  e   hyperg( v+0.5, 2v+1, 2x ) / gamma(v+1)
 *
 * If v is a negative integer, then v is replaced by -v.
 *
 *
 * ACCURACY:
 *
 * Tested at random points (v, x), with v between 0 and
 * 30, x between 0 and 28.
 *                      Relative error:
 * arithmetic   domain     # trials      peak         rms
 *    DEC       0,30          2000      3.1e-15     5.4e-16
 *    IEEE      0,30         10000      1.7e-14     2.7e-15
 *
 *
 * See also hyperg.c.
 *
 Cephes Math Library Release 2.8:  June, 2000
 Copyright 1984, 1987, 1988, 2000 by Stephen L. Moshier
 */




/// Returns the modified Bessel function of non-integer order I(v, x)
/// - Parameter x: Argument
/// - Preconditon: if x < 0, v must be an integer
/// ###NOTE###
///
/// Accuracy is diminished if v is near a negative integer.
internal func besselI(order v: Double!, x: Double!) -> Double {
    var sign: Int
    var t, ax: Double
    var vv: Double = v
    /* If v is a negative integer, invoke symmetry */
    t = floor(v)
    if( vv < 0.0 ) {
        if( t == vv ) {
            vv = -vv    /* symmetry */
            t = -t
        }
    }
    /* If x is negative, require v to be an integer */
    sign = 1
    if( x < 0.0 ) {
        if( t != vv ) {
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 10, *) {
                os_log("BesselI: for x < 0, order must be an integer", log: log_stat, type: .error)
            }
            #endif
            printError("BesselI: for x < 0, order must be an integer in the real plane")
            return 0.0
        }
        if( vv != 2.0 * floor(vv / 2.0) ) {
            sign = -1
        }
    }
    
    /* Avoid logarithm singularity */
    if( x == 0.0 ) {
        if( vv == 0.0 ) {
            return( 1.0 )
        }
        if( vv < 0.0 ) {
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 10, *) {
                os_log("BesselI: overflow", log: log_stat, type: .error)
            }
            #endif
            printError("BesselI: overflow")
            return Double.infinity
        }
        else {
            return 0.0
        }
    }
    
    ax = fabs(x)
    t = vv * log( 0.5 * ax )  -  x
    t = Double(sign) * exp(t) / tgamma( vv + 1.0 )
    ax = vv + 0.5
    return t * hypergeometric1F1(a: ax, b: 2.0 * ax, x: 2.0 * x)
}



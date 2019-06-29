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
#if os(macOS) || os(iOS)
import os.log
#endif

/*                            hyperg.c
 *
 *    Confluent hypergeometric function
 *      = M(a,b;z) (DLMF 13.2)
 *
 *
 *
 * SYNOPSIS:
 *
 * double a, b, x, y, hyperg()
 *
 * y = hyperg( a, b, x )
 *
 *
 *
 * DESCRIPTION:
 *
 * Computes the confluent hypergeometric function
 *
 *                          1           2
 *                       a x    a(a+1) x
 *   F ( a,b;x )  =  1 + ---- + --------- + ...
 *  1 1                  b 1!   b(b+1) 2!
 *
 * Many higher transcendental functions are special cases of
 * this power series.
 *
 * As is evident from the formula, b must not be a negative
 * integer or zero unless a is an integer with 0 >= a > b.
 *
 * The routine attempts both a direct summation of the series
 * and an asymptotic expansion.  In each case error due to
 * roundoff, cancellation, and nonconvergence is estimated.
 * The result with smaller estimated error is returned.
 *
 *
 *
 * ACCURACY:
 *
 * Tested at random points (a, b, x), all three variables
 * ranging from 0 to 30.
 *                      Relative error:
 * arithmetic   domain     # trials      peak         rms
 *    DEC       0,30         2000       1.2e-15     1.3e-16
 qtst1:
 21800   max =  1.4200E-14   rms =  1.0841E-15  ave = -5.3640E-17
 ltstd:
 25500   max = 1.2759e-14   rms = 3.7155e-16  ave = 1.5384e-18
 *    IEEE      0,30        30000       1.8e-14     1.1e-15
 *
 * Larger errors can be observed when b is near a negative
 * integer or zero.  Certain combinations of arguments yield
 * serious cancellation error in the power series summation
 * and also are not in the region of near convergence of the
 * asymptotic series.  An error message is printed if the
 * self-estimated relative error is greater than 1.0e-12.
 *
 */

/*                            hyperg.c */


/*
 Cephes Math Library Release 2.8:  June, 2000
 Copyright 1984, 1987, 1988, 2000 by Stephen L. Moshier
 */

/* Swift Version: Copyright strike65, 2018 */

extension SSSpecialFunctions {
    
    internal static func hypergeometric1F1<FPT: SSFloatingPoint & Codable>(a: FPT, b: FPT, x: FPT) -> FPT {
        var asum, psum, acanc, pcanc, temp: FPT
        let pcanc_limit1: FPT =  Helpers.makeFP(1e-15)
        let pcanc_limit2: FPT =  Helpers.makeFP(1e-12)
        
        // special case, M(a,b,x) = 1 if a == 0
        if a.isZero || x.isZero {
            return 1
        }
        
        if (a == 1) && (b == 2) {
            return (SSMath.exp1(x) - 1) / x
        }
        
        /* See if a Kummer transformation will help */
        temp = b - a
        let temp1: FPT = SSMath.reciprocal(1000)
        if( abs(temp) < temp1 * abs(a) ) {
            return( SSMath.exp1(x) * hypergeometric1F1(a: temp, b: b, x: -x )  )
        }
        pcanc = 0
        psum = hy1f1p( a: a, b: b, x: x, err: &pcanc )
        if pcanc < pcanc_limit1 {
            if( pcanc > pcanc_limit2 ) {
                print("Partial loss of precision")
            }
            return psum
        }
        
        /* try asymptotic series */
        acanc = 0
        asum = hy1f1a(a: a, b: b, x: x, err: &acanc )
        
        
        /* Pick the result with less estimated error */
        
        if( acanc < pcanc ) {
            if !acanc.isNaN {
                pcanc = acanc
                psum = asum
            }
        }
        
        if( pcanc > pcanc_limit2 ) {
            print("Partial loss of precision")
        }
        return( psum )
    }
    
    
    
    
    /* Power series summation for confluent hypergeometric function        */
    
    fileprivate static func hy1f1p<FPT: SSFloatingPoint & Codable>( a: FPT, b: FPT, x: FPT, err: inout FPT ) -> FPT {
        var n, a0, sum, t, u, temp: FPT
        var an, bn, maxt, pcanc: FPT
        
        
        /* set up for power series summation */
        an = a
        bn = b
        a0 = 1
        sum = 1
        n = 1
        t = 1
        maxt = 0
        
        
        while( t > FPT.ulpOfOne ) {
            if( bn == 0 )            /* check bn first since if both    */
            {
                print("Argument Singularity in hypergeometric1F1.")
                return FPT.infinity
            }
            if( an == 0 ) {          /* a singularity        */
                return( sum )
            }
            if( n > 200 ) {
                break
            }
            
            u = x * ( an / (bn * n) )
            
            /* check for blowup */
            temp = abs(u)
            if( (temp > 1 ) && (maxt > (FPT.greatestFiniteMagnitude / temp)) ) {
                pcanc = 1    /* estimate 100% error */
                err = pcanc
                return sum
            }
            
            a0 *= u
            sum += a0
            t = abs(a0)
            if( t > maxt ) {
                maxt = t
            }
            /*
             if( (maxt/fabs(sum)) > 1.0e17 )
             {
             pcanc = 1.0
             goto blowup
             }
             */
            an += 1
            bn += 1
            n += 1
        }
        /* estimate error due to roundoff and cancellation */
        if( sum != 0 ) {
            maxt = maxt / abs(sum)
        }
        maxt = maxt * FPT.ulpOfOne     /* this way avoids multiply overflow */
        pcanc = abs( FPT.ulpOfOne * n  +  maxt )
        err = pcanc
        return( sum )
    }
    
    
    /*                            hy1f1a()    */
    /* asymptotic formula for hypergeometric function:
     *
     *        (    -a
     *  --    ( |z|
     * |  (b) ( -------- 2f0( a, 1+a-b, -1/x )
     *        (  --
     *        ( |  (b-a)
     *
     *
     *                                x    a-b                     )
     *                               e  |x|                        )
     *                             + -------- 2f0( b-a, 1-a, 1/x ) )
     *                                --                           )
     *                               |  (a)                        )
     */
    
    fileprivate static func hy1f1a<FPT: SSFloatingPoint & Codable>( a: FPT, b: FPT, x:FPT, err: inout FPT ) -> FPT {
        var h1, h2, t, u, temp, acanc, asum, err1, err2: FPT
        
        if( x == 0 ) {
            acanc = 1
            asum = FPT.greatestFiniteMagnitude
            err = acanc
            return asum
        }
        temp = SSMath.log1( abs(x) )
        t = x + temp * (a-b)
        u = -temp * a
        
        if( b > 0 ) {
            temp = SSMath.lgamma1(b)
            t += temp
            u += temp
        }
        err1 = 0
        h1 = hyp2f0(a: a, b: a - b + 1, x: -1 / x, type: 1, err: &err1 )
        
        temp = SSMath.exp1(u) / SSMath.tgamma1(b-a)
        h1 = h1 * temp
        err1 = err1 * temp
        err2 = 0
        h2 = hyp2f0(a: b - a, b: 1 - a, x: 1 / x, type: 2, err: &err2 )
        
        if( a < 0 ) {
            temp = SSMath.exp1(t) / SSMath.tgamma1(a)
        }
        else {
            temp = SSMath.exp1( t - SSMath.lgamma1(a))
        }
        
        h2 = h2 * temp
        err2 = err2 * temp
        
        if( x < 0 ) {
            asum = h1
        }
        else {
            asum = h2
        }
        
        acanc = abs(err1) + abs(err2)
        
        if( b < 0 ) {
            temp = SSMath.tgamma1(b)
            asum = asum * temp
            acanc = acanc * abs(temp)
        }
        
        if( asum != 0 ) {
            acanc = acanc / abs(asum)
        }
        
        acanc = acanc * 30    /* fudge factor, since error of asymptotic formula
         * often seems this much larger than advertised */
        err = acanc
        return( asum )
    }
    
    /*                            hyp2f0()    */
    
    fileprivate static func hyp2f0<FPT: SSFloatingPoint & Codable>( a: FPT, b: FPT, x: FPT, type: Int, err: inout FPT ) -> FPT {
        var a0, alast, t, tlast, maxt: FPT
        var n, an, bn, u, sum, temp: FPT
        var ex1: FPT
        var ex2: FPT
        var ex3: FPT
        an = a
        bn = b
        a0 = 1
        alast = 1
        sum = 0
        n = 1
        t = 1
        tlast = 1000000000
        maxt = 0
        
        repeat {
            if( an == 0 ) {
                /* estimate error due to roundoff and cancellation */
                err = abs( FPT.ulpOfOne * (n + maxt) )
                alast = a0
                sum += alast
                return( sum )
            }
            if( bn == 0 ) {
                err = abs( FPT.ulpOfOne * (n + maxt) )
                alast = a0
                sum += alast
                return( sum )
            }
            
            u = an * (bn * x / n)
            
            /* check for blowup */
            temp = abs(u)
            if( (temp > 1 ) && (maxt > (FPT.greatestFiniteMagnitude / temp)) ) {
                err = FPT.greatestFiniteMagnitude
                print("Total loss of precision.")
                return( sum )
            }
            
            a0 *= u
            t = abs(a0)
            
            /* terminating condition for asymptotic series */
            if( t > tlast ) {
                /* The following "Converging factors" are supposed to improve accuracy,
                 * but do not actually seem to accomplish very much. */
                
                n -= 1
                let xx = 1 / x
                
                switch( type ) {    /* "type" given as subroutine argument */
                case 1:
                    ex1 = Helpers.makeFP(0.25 ) * b
                    let a1 =  Helpers.makeFP(0.125) +  ex1
                    ex1 = Helpers.makeFP(0.25 ) * xx
                    ex2 = Helpers.makeFP(-0.5) * a
                    let a2 =  ex2 + ex1
                    let a3 =  Helpers.makeFP(-0.25) * n
                    ex1 = a1 + a2 + a3
                    ex2 = ex1 / xx
                    ex3 = FPT.half + ex2
                    alast = alast * ex3
                    break
                case 2:
                    let e1: FPT =  Helpers.makeFP(2.0 / 3.0 ) - b
                    let e2: FPT = 2 * a
                    let e3: FPT = xx - n
                    alast = alast + e1 + e2 + e3
                    //                alast *= 2 / 3 - b + 2 * a + xx - n
                    break
                    
                default:
                    break
                }
                
                /* estimate error due to roundoff, cancellation, and nonconvergence */
                err = FPT.ulpOfOne * (n + maxt)  + abs( a0 )
                sum += alast
                return( sum )
            }
            
            tlast = t
            sum += alast    /* the sum is one term behind */
            alast = a0
            
            if( n > 200 ) {
                /* The following "Converging factors" are supposed to improve accuracy,
                 * but do not actually seem to accomplish very much. */
                
                n -= 1
                let xx = 1 / x
                
                switch( type ) {    /* "type" given as subroutine argument */
                case 1:
                    let a1 =  Helpers.makeFP(0.125 ) +  Helpers.makeFP(0.25 ) * b
                    let a2 =  -FPT.half * a +  Helpers.makeFP(0.25) * xx
                    let a3 =  Helpers.makeFP(-0.25 ) * n
                    ex1 =  a1 + a2 + a3
                    ex2 = ex1 / xx
                    ex3 = FPT.half + ex2
                    alast = alast * ex3
                    break
                    
                case 2:
                    let e1: FPT =  Helpers.makeFP(2.0 / 3.0 ) - b
                    let e2: FPT = 2 * a
                    let e3: FPT = xx - n
                    alast = alast + e1 + e2 + e3
                    //                alast *= 2 / 3 - b + 2 * a + xx - n
                    break
                    
                default:
                    break
                }
                
                /* estimate error due to roundoff, cancellation, and nonconvergence */
                err = FPT.ulpOfOne * (n + maxt)  +  abs( a0 )
                sum += alast
                return( sum )
            }
            an += 1
            bn += 1
            n += 1
            if( t > maxt ) {
                maxt = t
            }
        } while( t > FPT.ulpOfOne )
        
        
        /* series converged! */
        
        /* estimate error due to roundoff and cancellation */
        err = abs(  FPT.ulpOfOne * (n + maxt)  )
        
        alast = a0
        sum += alast
        return( sum )
    }
    
}

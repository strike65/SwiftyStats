/*
 Copyright (c) 2017 Volker Thieme
 
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

/* Swift Version: Copyright Volker Thieme, 2018 */

public func hypergeometric1F1(a: Double!, b: Double!, x: Double!) -> Double {
    var asum, psum, acanc, pcanc, temp: Double
    
    
    // special case, M(a,b,x) = 1 if a == 0
    if a.isZero || x.isZero {
        return 1.0
    }
    
    if (a == 1) && (b == 2) {
        return (exp(x) - 1.0) / x
    }

    /* See if a Kummer transformation will help */
    temp = b - a
    if( fabs(temp) < 0.001 * fabs(a) ) {
        return( exp(x) * hypergeometric1F1(a: temp, b: b, x: -x )  )
    }
    pcanc = 0.0
    psum = hy1f1p( a: a, b: b, x: x, err: &pcanc )
    if( pcanc < 1.0e-12 ) {
        #if os(macOS) || os(iOS)
        if #available(macOS 10.12, iOS 10, *) {
            os_log("Partial loss of precision", log: log_stat, type: .info)
        }
        #else
        printError("Partial loss of precision")
        #endif
        return psum
    }

    /* try asymptotic series */
    acanc = 0.0
    asum = hy1f1a(a: a, b: b, x: x, err: &acanc )
    
    
    /* Pick the result with less estimated error */
    
    if( acanc < pcanc ) {
        pcanc = acanc
        psum = asum
    }
    
    if( pcanc > 1.0e-12 ) {
        #if os(macOS) || os(iOS)
        if #available(macOS 10.12, iOS 10, *) {
            os_log("Partial loss of precision", log: log_stat, type: .info)
        }
        #else
        printError("Partial loss of precision")
        #endif
    }
    return( psum )
}




/* Power series summation for confluent hypergeometric function        */

fileprivate func hy1f1p( a: Double!, b: Double!, x: Double!, err: inout Double ) -> Double {
    var n, a0, sum, t, u, temp: Double
    var an, bn, maxt, pcanc: Double
    
    
    /* set up for power series summation */
    an = a
    bn = b
    a0 = 1.0
    sum = 1.0
    n = 1.0
    t = 1.0
    maxt = 0.0
    
    
    while( t > Double.ulpOfOne ) {
        if( bn == 0 )            /* check bn first since if both    */
        {
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 10, *) {
                os_log("Argument Singularity", log: log_stat, type: .info)
            }
            #else
            if #available(macOS 10.12, iOS 10, *) {
                printError("Argument Singularity in hypergeometric1F1.")
            }
            #endif
            return Double.infinity
        }
        if( an == 0 ) {          /* a singularity        */
            return( sum )
        }
        if( n > 200 ) {
            break
        }

        u = x * ( an / (bn * n) )
        
        /* check for blowup */
        temp = fabs(u)
        if( (temp > 1.0 ) && (maxt > (Double.greatestFiniteMagnitude / temp)) ) {
            pcanc = 1.0    /* estimate 100% error */
            err = pcanc
            return sum
        }
        
        a0 *= u
        sum += a0
        t = fabs(a0)
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
        an += 1.0
        bn += 1.0
        n += 1.0
    }
    /* estimate error due to roundoff and cancellation */
    if( sum != 0.0 ) {
        maxt = maxt / fabs(sum)
    }
    maxt = maxt * Double.ulpOfOne     /* this way avoids multiply overflow */
    pcanc = fabs( Double.ulpOfOne * n  +  maxt )
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

fileprivate func hy1f1a( a: Double!, b: Double!, x:Double!, err: inout Double ) -> Double {
    var h1, h2, t, u, temp, acanc, asum, err1, err2: Double
    
    if( x == 0 ) {
        acanc = 1.0
        asum = Double.greatestFiniteMagnitude
        err = acanc
        return asum
    }
    temp = log( fabs(x) )
    t = x + temp * (a-b)
    u = -temp * a
    
    if( b > 0 ) {
        temp = lgamma(b)
        t += temp
        u += temp
    }
    err1 = 0.0
    h1 = hyp2f0(a: a, b: a-b+1, x: -1.0/x, type: 1, err: &err1 )
    
    temp = exp(u) / tgamma(b-a)
    h1 = h1 * temp
    err1 = err1 * temp
    err2 = 0.0
    h2 = hyp2f0(a: b-a, b: 1.0-a, x: 1.0/x, type: 2, err: &err2 )
    
    if( a < 0 ) {
        temp = exp(t) / tgamma(a)
    }
    else {
        temp = exp( t - lgamma(a) )
    }
    
    h2 = h2 * temp
    err2 = err2 * temp
    
    if( x < 0.0 ) {
        asum = h1
    }
    else {
        asum = h2
    }
    
    acanc = fabs(err1) + fabs(err2)
    
    if( b < 0 ) {
        temp = tgamma(b)
        asum = asum * temp
        acanc = acanc * fabs(temp)
    }
    
    if( asum != 0.0 ) {
        acanc = acanc / fabs(asum)
    }
    
    acanc = acanc * 30.0    /* fudge factor, since error of asymptotic formula
     * often seems this much larger than advertised */
    err = acanc
    return( asum )
}

/*                            hyp2f0()    */

fileprivate func hyp2f0( a:Double!, b:Double!, x:Double!, type: Int!, err: inout Double ) -> Double {
    var a0, alast, t, tlast, maxt: Double
    var n, an, bn, u, sum, temp: Double
    
    an = a
    bn = b
    a0 = 1.0e0
    alast = 1.0e0
    sum = 0.0
    n = 1.0e0
    t = 1.0e0
    tlast = 1.0e9
    maxt = 0.0
    
    repeat {
        if( an == 0 ) {
            /* estimate error due to roundoff and cancellation */
            err = fabs( Double.ulpOfOne * (n + maxt) )
            alast = a0
            sum += alast
            return( sum )
        }
        if( bn == 0 ) {
            err = fabs( Double.ulpOfOne * (n + maxt) )
            alast = a0
            sum += alast
            return( sum )
        }
        
        u = an * (bn * x / n)
        
        /* check for blowup */
        temp = fabs(u)
        if( (temp > 1.0 ) && (maxt > (Double.greatestFiniteMagnitude / temp)) ) {
            err = Double.greatestFiniteMagnitude
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 10, *) {
                os_log("Total loss of precision", log: log_stat, type: .info)
            }
            #else
            printError("Total loss of precision.")
            #endif
            return( sum )
        }

        a0 *= u
        t = fabs(a0)
        
        /* terminating condition for asymptotic series */
        if( t > tlast ) {
            /* The following "Converging factors" are supposed to improve accuracy,
             * but do not actually seem to accomplish very much. */
            
            n -= 1.0
            let xx = 1.0 / x
            
            switch( type ) {    /* "type" given as subroutine argument */
            case 1:
                let a1 = 0.125 + 0.25 * b
                let a2 = -0.5 * a + 0.25 * xx
                let a3 = -0.25 * n
                alast *= ( 0.5 + ( a1 + a2 + a3 ) / xx )
                break
                
            case 2:
                alast *= 2.0 / 3.0 - b + 2.0 * a + xx - n
                break
                
            default:
                break
            }
            
            /* estimate error due to roundoff, cancellation, and nonconvergence */
            err = Double.ulpOfOne * (n + maxt)  +  fabs ( a0 )
            sum += alast
            return( sum )
        }
        
        tlast = t
        sum += alast    /* the sum is one term behind */
        alast = a0
        
        if( n > 200 ) {
            /* The following "Converging factors" are supposed to improve accuracy,
             * but do not actually seem to accomplish very much. */
            
            n -= 1.0
            let xx = 1.0 / x
            
            switch( type ) {    /* "type" given as subroutine argument */
            case 1:
                let  a1 = 0.125 + 0.25 * b
                let  a2 = -0.5 * a + 0.25 * xx
                let  a3 = -0.25 * n
                alast *= ( 0.5 + ( a1 + a2 + a3 ) / xx )
                break
                
            case 2:
                alast *= 2.0 / 3.0 - b + 2.0 * a + xx - n
                break
                
            default:
                break
            }
            
            /* estimate error due to roundoff, cancellation, and nonconvergence */
            err = Double.ulpOfOne * (n + maxt)  +  fabs ( a0 )
            sum += alast
            return( sum )
        }
        an += 1.0e0
        bn += 1.0e0
        n += 1.0e0
        if( t > maxt ) {
            maxt = t
        }
    } while( t > Double.ulpOfOne )
    
    
    /* series converged! */
    
    /* estimate error due to roundoff and cancellation */
    err = fabs(  Double.ulpOfOne * (n + maxt)  )
    
    alast = a0
    sum += alast
    return( sum )
//
//    /* The following "Converging factors" are supposed to improve accuracy,
//     * but do not actually seem to accomplish very much. */
//
//    n -= 1.0
//    x = 1.0/x
//
//    switch( type )    /* "type" given as subroutine argument */
//    {
//    case 1:
//        alast *= ( 0.5 + (0.125 + 0.25*b - 0.5*a + 0.25*x - 0.25*n)/x )
//        break
//
//    case 2:
//        alast *= 2.0/3.0 - b + 2.0*a + x - n
//        break
//
//    default:
//        break
//    }
//
//    /* estimate error due to roundoff, cancellation, and nonconvergence */
//    err = DBL_EPSILON * (n + maxt)  +  fabs ( a0 )
//
//
//    sum += alast
//    return( sum )
//
//    /* series blew up: */
//    err = HUGE
//    mtherr( "hyperg", TLOSS )
//    return( sum )
}

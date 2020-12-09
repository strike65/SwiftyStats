//
//  SSSpecialFunctions.swift
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

/*
 Cephes Math Library Release 2.8:  June, 2000
 Copyright 1984, 1987, 1989, 2000 by Stephen L. Moshier
 */

/* Note: all coefficients satisfy the relative error criterion
 * except YP, YQ which are designed for absolute error. */

import Foundation
import os.log


extension SSSpecialFunctions {
    
    /*                            j0.c
     *
     *    Bessel function of order zero
     *
     *
     *
     * SYNOPSIS:
     *
     * double x, y, j0();
     *
     * y = j0( x );
     *
     *
     *
     * DESCRIPTION:
     *
     * Returns Bessel function of order zero of the argument.
     *
     * The domain is divided into the intervals [0, 5] and
     * (5, infinity). In the first interval the following rational
     * approximation is used:
     *
     *
     *        2         2
     * (w - r  ) (w - r  ) P (w) / Q (w)
     *       1         2    3       8
     *
     *            2
     * where w = x  and the two r's are zeros of the function.
     *
     * In the second interval, the Hankel asymptotic expansion
     * is employed with two rational functions of degree 6/6
     * and 7/7.
     *
     *
     *
     * ACCURACY:
     *
     *                      Absolute error:
     * arithmetic   domain     # trials      peak         rms
     *    DEC       0, 30       10000       4.4e-17     6.3e-18
     *    IEEE      0, 30       60000       4.2e-16     1.1e-16
     *
     */

    /// Returns the Bessel function of order zero J0(x)
    /// - Parameter x: Argument
    internal static func besselJ0<FPT: SSFloatingPoint >(x: FPT) -> FPT {
        let DR1: FPT =  Helpers.makeFP(5.7831859629467845211759957584558070350719)
        let DR2: FPT  =  Helpers.makeFP(30.47126234366208639907816317502275584842)
        
        var w, z, p, q, xn: FPT
        var xx: FPT = x
        if( x < 0 ) {
            xx = -x
        }
        
        if( xx <= 5) {
            z = xx * xx;
            if( xx <  Helpers.makeFP(1.0e-5) ) {
                return( 1 - z / 4 )
            }
            
            p = (z - DR1) * (z - DR2)
            
            p = p * Helper.polyeval(x: z,coef: coeff("RP"),n: 3) / Helper.poly1eval(x: z, coef: coeff("RQ"), n: 8 )
            return p
        }
        
        w = 5 / xx;
        q = 25 / ( xx * xx )
        p = Helper.polyeval(x: q, coef: coeff("PP"), n: 6) / Helper.polyeval(x: q, coef: coeff("PQ"), n: 6 )
        q = Helper.polyeval(x: q, coef: coeff("QP"), n: 7) / Helper.poly1eval(x: q, coef: coeff("QQ"), n: 7 )
        xn = xx - FPT.pifourth
        p = p * SSMath.cos1(xn) - w * q * SSMath.sin1(xn);
        return ( p * FPT.sqrt2Opi / sqrt(xx) )
    }
    /*                            y0.c
     *
     *    Bessel function of the second kind, order zero
     *
     *
     *
     * SYNOPSIS:
     *
     * double x, y, y0();
     *
     * y = y0( x );
     *
     *
     *
     * DESCRIPTION:
     *
     * Returns Bessel function of the second kind, of order
     * zero, of the argument.
     *
     * The domain is divided into the intervals [0, 5] and
     * (5, infinity). In the first interval a rational approximation
     * R(x) is employed to compute
     *   y0(x)  = R(x)  +   2 * log(x) * j0(x) / PI.
     * Thus a call to j0() is required.
     *
     * In the second interval, the Hankel asymptotic expansion
     * is employed with two rational functions of degree 6/6
     * and 7/7.
     *
     *
     *
     * ACCURACY:
     *
     *  Absolute error, when y0(x) < 1; else relative error:
     *
     * arithmetic   domain     # trials      peak         rms
     *    DEC       0, 30        9400       7.0e-17     7.9e-18
     *    IEEE      0, 30       30000       1.3e-15     1.6e-16
     *
     */
    
    /// Returns the Bessel function of second kind of order zero Y0(x)
    /// - Parameter x: Argument
    internal static func besselY<FPT: SSFloatingPoint >(x: FPT) -> FPT {
        
        var w, z, p, q, xn: FPT
        
        if( x <= 5 ) {
            if( x <= 0 )
            {
                #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("BesselY: not defined in that domain", log: .log_stat, type: .error)
                }
                #endif
                printError("BesselY: not defined in that domain")
                return -FPT.infinity
            }
            z = x * x
            w = Helper.polyeval(x: z, coef: coeff("YP"), n: 7) / Helper.poly1eval( x: z, coef: coeff("YQ"), n: 7 )
            w += FPT.twopi * SSMath.log1(x) * besselJ0(x: x)
            return w
        }
        
        w = 5 / x
        z = 25 / (x * x)
        p = Helper.polyeval(x: z, coef: coeff("PP"), n: 6) / Helper.polyeval(x: z,coef: coeff("PQ"), n: 6 )
        q = Helper.polyeval(x: z,coef: coeff("QP"),n: 7) / Helper.poly1eval(x: z, coef: coeff("QQ"), n: 7 )
        xn = x - FPT.fourth
        p = p * SSMath.sin1(xn) + w * q * SSMath.cos1(xn)
        return( p * FPT.sqrt2Opi / sqrt(x) )
    }
}


/* Rational approximation coefficients YP[], YQ[] are used here.
 * The function computed is  y0(x)  -  2 * log(x) * j0(x) / PI,
 * whose value at x = 0 is  2 * ( log(0.5) + EUL ) / PI
 * = 0.073804295108687225.
 */

fileprivate func coeff<FPT: SSFloatingPoint >(_ name: String) -> [FPT] {
    let PPFloat: Array<Float> = [
        7.96936729297347051624E-4,
        8.28352392107440799803E-2,
        1.23953371646414299388E0,
        5.44725003058768775090E0,
        8.74716500199817011941E0,
        5.30324038235394892183E0,
        9.99999999999999997821E-1
    ]
    let PQFloat: Array<Float> = [
        9.24408810558863637013E-4,
        8.56288474354474431428E-2,
        1.25352743901058953537E0,
        5.47097740330417105182E0,
        8.76190883237069594232E0,
        5.30605288235394617618E0,
        1.00000000000000000218E0
    ]
    let QPFloat: Array<Float> = [
        -1.13663838898469149931E-2,
        -1.28252718670509318512E0,
        -1.95539544257735972385E1,
        -9.32060152123768231369E1,
        -1.77681167980488050595E2,
        -1.47077505154951170175E2,
        -5.14105326766599330220E1,
        -6.05014350600728481186E0
    ]
    let QQFloat: Array<Float> = [
        /*  1.00000000000000000000E0,*/
        6.43178256118178023184E1,
        8.56430025976980587198E2,
        3.88240183605401609683E3,
        7.24046774195652478189E3,
        5.93072701187316984827E3,
        2.06209331660327847417E3,
        2.42005740240291393179E2
    ]
    
    let YPFloat: Array<Float> = [
        1.55924367855235737965E4,
        -1.46639295903971606143E7,
        5.43526477051876500413E9,
        -9.82136065717911466409E11,
        8.75906394395366999549E13,
        -3.46628303384729719441E15,
        4.42733268572569800351E16,
        -1.84950800436986690637E16
    ]
    let YQFloat: Array<Float> = [
        /* 1.00000000000000000000E0,*/
        1.04128353664259848412E3,
        6.26107330137134956842E5,
        2.68919633393814121987E8,
        8.64002487103935000337E10,
        2.02979612750105546709E13,
        3.17157752842975028269E15,
        2.50596256172653059228E17
    ]
    
    
    let RPFloat: Array<Float> = [
        -4.79443220978201773821E9,
        1.95617491946556577543E12,
        -2.49248344360967716204E14,
        9.70862251047306323952E15
    ]
    let RQFloat: Array<Float> = [
        /* 1.00000000000000000000E0,*/
        4.99563147152651017219E2,
        1.73785401676374683123E5,
        4.84409658339962045305E7,
        1.11855537045356834862E10,
        2.11277520115489217587E12,
        3.10518229857422583814E14,
        3.18121955943204943306E16,
        1.71086294081043136091E18
    ]
    let PPDouble: Array<Double> = [
        7.96936729297347051624E-4,
        8.28352392107440799803E-2,
        1.23953371646414299388E0,
        5.44725003058768775090E0,
        8.74716500199817011941E0,
        5.30324038235394892183E0,
        9.99999999999999997821E-1
    ]
    let PQDouble: Array<Double> = [
        9.24408810558863637013E-4,
        8.56288474354474431428E-2,
        1.25352743901058953537E0,
        5.47097740330417105182E0,
        8.76190883237069594232E0,
        5.30605288235394617618E0,
        1.00000000000000000218E0
    ]
    let QPDouble: Array<Double> = [
        -1.13663838898469149931E-2,
        -1.28252718670509318512E0,
        -1.95539544257735972385E1,
        -9.32060152123768231369E1,
        -1.77681167980488050595E2,
        -1.47077505154951170175E2,
        -5.14105326766599330220E1,
        -6.05014350600728481186E0
    ]
    let QQDouble: Array<Double> = [
        /*  1.00000000000000000000E0,*/
        6.43178256118178023184E1,
        8.56430025976980587198E2,
        3.88240183605401609683E3,
        7.24046774195652478189E3,
        5.93072701187316984827E3,
        2.06209331660327847417E3,
        2.42005740240291393179E2
    ]
    
    let YPDouble: Array<Double> = [
        1.55924367855235737965E4,
        -1.46639295903971606143E7,
        5.43526477051876500413E9,
        -9.82136065717911466409E11,
        8.75906394395366999549E13,
        -3.46628303384729719441E15,
        4.42733268572569800351E16,
        -1.84950800436986690637E16
    ]
    let YQDouble: Array<Double> = [
        /* 1.00000000000000000000E0,*/
        1.04128353664259848412E3,
        6.26107330137134956842E5,
        2.68919633393814121987E8,
        8.64002487103935000337E10,
        2.02979612750105546709E13,
        3.17157752842975028269E15,
        2.50596256172653059228E17
    ]
    
    
    let RPDouble: Array<Double> = [
        -4.79443220978201773821E9,
        1.95617491946556577543E12,
        -2.49248344360967716204E14,
        9.70862251047306323952E15
    ]
    let RQDouble: Array<Double> = [
        /* 1.00000000000000000000E0,*/
        4.99563147152651017219E2,
        1.73785401676374683123E5,
        4.84409658339962045305E7,
        1.11855537045356834862E10,
        2.11277520115489217587E12,
        3.10518229857422583814E14,
        3.18121955943204943306E16,
        1.71086294081043136091E18
    ]
    #if arch(i386) || arch(x86_64)
    let PPFloat80: Array<Float80> = [
        7.96936729297347051624E-4,
        8.28352392107440799803E-2,
        1.23953371646414299388E0,
        5.44725003058768775090E0,
        8.74716500199817011941E0,
        5.30324038235394892183E0,
        9.99999999999999997821E-1
    ]
    let PQFloat80: Array<Float80> = [
        9.24408810558863637013E-4,
        8.56288474354474431428E-2,
        1.25352743901058953537E0,
        5.47097740330417105182E0,
        8.76190883237069594232E0,
        5.30605288235394617618E0,
        1.00000000000000000218E0
    ]
    let QPFloat80: Array<Float80> = [
        -1.13663838898469149931E-2,
        -1.28252718670509318512E0,
        -1.95539544257735972385E1,
        -9.32060152123768231369E1,
        -1.77681167980488050595E2,
        -1.47077505154951170175E2,
        -5.14105326766599330220E1,
        -6.05014350600728481186E0
    ]
    let QQFloat80: Array<Float80> = [
        /*  1.00000000000000000000E0,*/
        6.43178256118178023184E1,
        8.56430025976980587198E2,
        3.88240183605401609683E3,
        7.24046774195652478189E3,
        5.93072701187316984827E3,
        2.06209331660327847417E3,
        2.42005740240291393179E2
    ]
    
    let YPFloat80: Array<Float80> = [
        1.55924367855235737965E4,
        -1.46639295903971606143E7,
        5.43526477051876500413E9,
        -9.82136065717911466409E11,
        8.75906394395366999549E13,
        -3.46628303384729719441E15,
        4.42733268572569800351E16,
        -1.84950800436986690637E16
    ]
    let YQFloat80: Array<Float80> = [
        /* 1.00000000000000000000E0,*/
        1.04128353664259848412E3,
        6.26107330137134956842E5,
        2.68919633393814121987E8,
        8.64002487103935000337E10,
        2.02979612750105546709E13,
        3.17157752842975028269E15,
        2.50596256172653059228E17
    ]
    
    
    let RPFloat80: Array<Float80> = [
        -4.79443220978201773821E9,
        1.95617491946556577543E12,
        -2.49248344360967716204E14,
        9.70862251047306323952E15
    ]
    let RQFloat80: Array<Float80> = [
        /* 1.00000000000000000000E0,*/
        4.99563147152651017219E2,
        1.73785401676374683123E5,
        4.84409658339962045305E7,
        1.11855537045356834862E10,
        2.11277520115489217587E12,
        3.10518229857422583814E14,
        3.18121955943204943306E16,
        1.71086294081043136091E18
    ]
    #endif
    switch FPT.self {
    case is Float.Type:
        if name == "PP" {
            return PPFloat as! Array<FPT>
        }
        else if name == "PQ" {
            return PQFloat as! Array<FPT>
        }
        else if name == "PQ" {
            return PQFloat as! Array<FPT>
        }
        else if name == "QP" {
            return QPFloat as! Array<FPT>
        }
        else if name == "QQ" {
            return QQFloat as! Array<FPT>
        }
        else if name == "YP" {
            return YPFloat as! Array<FPT>
        }
        else if name == "YQ" {
            return YQFloat as! Array<FPT>
        }
        else if name == "RP" {
            return RPFloat as! Array<FPT>
        }
        else if name == "RQ" {
            return RQFloat as! Array<FPT>
        }
    case is Double.Type:
        if name == "PP" {
            return PPDouble as! Array<FPT>
        }
        else if name == "PQ" {
            return PQDouble as! Array<FPT>
        }
        else if name == "PQ" {
            return PQDouble as! Array<FPT>
        }
        else if name == "QP" {
            return QPDouble as! Array<FPT>
        }
        else if name == "QQ" {
            return QQDouble as! Array<FPT>
        }
        else if name == "YP" {
            return YPDouble as! Array<FPT>
        }
        else if name == "YQ" {
            return YQDouble as! Array<FPT>
        }
        else if name == "RP" {
            return RPDouble as! Array<FPT>
        }
        else if name == "RQ" {
            return RQDouble as! Array<FPT>
        }
        #if arch(i386) || arch(x86_64)
    case is Float80.Type:
        if name == "PP" {
            return PPFloat80 as! Array<FPT>
        }
        else if name == "PQ" {
            return PQFloat80 as! Array<FPT>
        }
        else if name == "PQ" {
            return PQFloat80 as! Array<FPT>
        }
        else if name == "QP" {
            return QPFloat80 as! Array<FPT>
        }
        else if name == "QQ" {
            return QQFloat80 as! Array<FPT>
        }
        else if name == "YP" {
            return YPFloat80 as! Array<FPT>
        }
        else if name == "YQ" {
            return YQFloat80 as! Array<FPT>
        }
        else if name == "RP" {
            return RPFloat80 as! Array<FPT>
        }
        else if name == "RQ" {
            return RQFloat80 as! Array<FPT>
        }
        #endif
    default:
        if name == "PP" {
            return PPDouble as! Array<FPT>
        }
        else if name == "PQ" {
            return PQDouble as! Array<FPT>
        }
        else if name == "PQ" {
            return PQDouble as! Array<FPT>
        }
        else if name == "QP" {
            return QPDouble as! Array<FPT>
        }
        else if name == "QQ" {
            return QQDouble as! Array<FPT>
        }
        else if name == "YP" {
            return YPDouble as! Array<FPT>
        }
        else if name == "YQ" {
            return YQDouble as! Array<FPT>
        }
        else if name == "RP" {
            return RPDouble as! Array<FPT>
        }
        else if name == "RQ" {
            return RQDouble as! Array<FPT>
        }
    }
    return Array<Double>() as! Array<FPT>
}

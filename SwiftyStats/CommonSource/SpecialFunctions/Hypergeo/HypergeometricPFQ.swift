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
import Accelerate
// naive implementation

extension SSSpecialFunctions {
    internal static func h2f2<T: SSFloatingPoint & Codable>(a1: T, a2: T, b1: T, b2: T, z: T) -> T {
        var sum1, s: T
        let tol: T = T.ulpOfOne
        let maxIT: T = 1000
        var k: T = 0
        sum1 = 0
        s = 0
        var p1: T = 0
        var p2: T = 0
        var temp1: T = 0
        let lz: T = SSMath.log1(z)
        var kz: T
        while k < maxIT {
            p1 = lpochhammer(x: a1, n: k) + lpochhammer(x: a2, n: k)
            p2 = lpochhammer(x: b1, n: k) + lpochhammer(x: b2, n: k)
            kz = k * lz
            temp1 = p1 + kz - p2
            temp1 = temp1 - SSMath.logFactorial(Helpers.integerValue(k))
            s = SSMath.exp1(temp1)
            if abs((sum1 - (s + sum1))) < tol {
                break
            }
            sum1 = sum1 + SSMath.exp1(temp1)
            k = k + 1
        }
        return sum1
    }
    
    /*
     %% Original fortran documentation
     %     ACPAPFQ.  A NUMERICAL EVALUATOR FOR THE GENERALIZED HYPERGEOMETRIC
     %
     %     1  SERIES.  W.F. PERGER, A. BHALLA, M. NARDIN.
     %
     %     REF. IN COMP. PHYS. COMMUN. 77 (1993) 249
     %
     %     ****************************************************************
     %     *                                                              *
     %     *    SOLUTION TO THE GENERALIZED HYPERGEOMETRIC FUNCTION       *
     %     *                                                              *
     %     *                           by                                 *
     %     *                                                              *
     %     *                      W. F. PERGER,                           *
     %     *                                                              *
     %     *              MARK NARDIN  and ATUL BHALLA                    *
     %     *                                                              *
     %     *                                                              *
     %     *            Electrical Engineering Department                 *
     %     *            Michigan Technological University                 *
     %     *                  1400 Townsend Drive                         *
     %     *                Houghton, MI  49931-1295   USA                *
     %     *                     Copyright 1993                           *
     %     *                                                              *
     %     *               e-mail address: wfp@mtu.edu                    *
     %     *                                                              *
     %     *  Description : A numerical evaluator for the generalized     *
     %     *    hypergeometric function for complex arguments with large  *
     %     *    magnitudes using a direct summation of the Gauss series.  *
     %     *    The method used allows an accuracy of up to thirteen      *
     %     *    decimal places through the use of large integer arrays    *
     %     *    and a single final division.                              *
     %     *    (original subroutines for the confluent hypergeometric    *
     %     *    written by Mark Nardin, 1989; modifications made to cal-  *
     %     *    culate the generalized hypergeometric function were       *
     %     *    written by W.F. Perger and A. Bhalla, June, 1990)         *
     %     *                                                              *
     %     *  The evaluation of the pFq series is accomplished by a func- *
     %     *  ion call to PFQ, which is a double precision complex func-  *
     %     *  tion.  The required input is:                               *
     %     *  1. Double precision complex arrays A and B.  These are the  *
     %     *     arrays containing the parameters in the numerator and de-*
     %     *     nominator, respectively.                                 *
     %     *  2. Integers IP and IQ.  These integers indicate the number  *
     %     *     of numerator and denominator terms, respectively (these  *
     %     *     are p and q in the pFq function).                        *
     %     *  3. Double precision complex argument Z.                     *
     %     *  4. Integer LNPFQ.  This integer should be set to '1' if the *
     %     *     result from PFQ is to be returned as the natural logaritm*
     %     *     of the series, or '0' if not.  The user can generally set*
     %     *     LNPFQ = '0' and change it if required.                   *
     %     *  5. Integer IX.  This integer should be set to '0' if the    *
     %     *     user desires the program PFQ to estimate the number of   *
     %     *     array terms (in A and B) to be used, or an integer       *
     %     *     greater than zero specifying the number of integer pos-  *
     %     *     itions to be used.  This input parameter is escpecially  *
     %     *     useful as a means to check the results of a given run.   *
     %     *     Specificially, if the user obtains a result for a given  *
     %     *     set of parameters, then changes IX and re-runs the eval- *
     %     *     uator, and if the number of array positions was insuffi- *
     %     *     cient, then the two results will likely differ.  The rec-*
     %     *     commended would be to generally set IX = '0' and then set*
     %     *     it to 100 or so for a second run.  Note that the LENGTH  *
     %     *     parameter currently sets the upper limit on IX to 777,   *
     %     *     but that can easily be changed (it is a single PARAMETER *
     %     *     statement) and the program recompiled.                   *
     %     *  6. Integer NSIGFIG.  This integer specifies the requested   *
     %     *     number of significant figures in the final result.  If   *
     %     *     the user attempts to request more than the number of bits*
     %     *     in the mantissa allows, the program will abort with an   *
     %     *     appropriate error message.  The recommended value is 10. *
     %     *                                                              *
     %     *     Note: The variable NOUT is the file to which error mess- *
     %     *           ages are written (default is 6).  This can be      *
     %     *           changed in the FUNCTION PFQ to accomodate re-      *
     %     *           of output to another file                          *
     %     *                                                              *
     %     *  Subprograms called: HYPER.                                  *
     %     *                                                              *
     %     ****************************************************************
     
     */
    
    
    internal static func hypergeometricPFQ<T: SSFloatingPoint>(a: Array<Complex<T>>, b: Array<Complex<T>>, z: Complex<T>, log: Bool = false) throws -> Complex<T> {
        var sigfig: Int
        switch z.re {
        case is Double:
            sigfig = 15
        case is Float:
            sigfig = 7
            #if arch(x86_64)
        case is Float80:
            sigfig = 19
            #endif
        default:
            sigfig = 15
        }
        var ans: Complex<T>
        var zz: Complex<T> = z
        let aa: Array<Complex<T>> = a
        let bb: Array<Complex<T>> = b
        do {
            try ans = hyper(a: aa, b: bb, ip: aa.count, iq: bb.count, z: &zz, lnpfq: log ? 1 : 0, ix: 777, nsigfig: &sigfig)
            if !ans.isNan {
                return ans
            }
        }
        catch {
            throw error
        }
        return ans
    }
}
    


/*
 %     ****************************************************************
 %     *                                                              *
 %     *                   FUNCTION HYPER                             *
 %     *                                                              *
 %     *                                                              *
 %     *  Description : Function that sums the Gauss series.          *
 %     *                                                              *
 %     *  Subprograms called: ARMULT, ARYDIV, BITS, CMPADD, CMPMUL,   *
 %     *                      IPREMAX.                                *
 %     *                                                              *
 %     ****************************************************************
 */
fileprivate func hyper<T: SSFloatingPoint>(a: Array<Complex<T>>, b: Array<Complex<T>>, ip: Int, iq: Int, z: inout Complex<T>, lnpfq: Int, ix: Int, nsigfig: inout Int) throws -> Complex<T> {
    let length: Int = 777
    var cr: Array<T> = Array<T>.init(repeating: 0, count: 10)
    var ci: Array<T> = Array<T>.init(repeating: 0, count: 10)
    var ar: Array<T> = Array<T>.init(repeating: 0, count: 10)
    var ai: Array<T> = Array<T>.init(repeating: 0, count: 10)
    var ar2: Array<T> = Array<T>.init(repeating: 0, count: 10)
    var ai2: Array<T> = Array<T>.init(repeating: 0, count: 10)
    var cr2: Array<T> = Array<T>.init(repeating: 0, count: 10)
    var ci2: Array<T> = Array<T>.init(repeating: 0, count: 10)
    var sumr: Array<T> = Array<T>.init(repeating: 0, count: length + 2)
    var sumi: Array<T> = Array<T>.init(repeating: 0, count: length + 2)
    var denomr: Array<T> = Array<T>.init(repeating: 0, count: length + 2)
    var denomi: Array<T> = Array<T>.init(repeating: 0, count: length + 2)
    var qr1: Array<T> = Array<T>.init(repeating: 0, count: length + 2)
    var qi1: Array<T> = Array<T>.init(repeating: 0, count: length + 2)
    var wk1: Array<T> = Array<T>.init(repeating: 0, count: length + 2)
    var wk2: Array<T> = Array<T>.init(repeating: 0, count: length + 2)
    var wk3: Array<T> = Array<T>.init(repeating: 0, count: length + 2)
    var wk4: Array<T> = Array<T>.init(repeating: 0, count: length + 2)
    var wk5: Array<T> = Array<T>.init(repeating: 0, count: length + 2)
    var wk6: Array<T> = Array<T>.init(repeating: 0, count: length + 2)
    var qr2: Array<T> = Array<T>.init(repeating: 0, count: length + 2)
    var qi2: Array<T> = Array<T>.init(repeating: 0, count: length + 2)
    var foo1: Array<T> = Array<T>.init(repeating: 0, count: length + 2)
    var foo2: Array<T> = Array<T>.init(repeating: 0, count: length + 2)
    var numr: Array<T> = Array<T>.init(repeating: 0, count: length + 2)
    var numi: Array<T> = Array<T>.init(repeating: 0, count: length + 2)
    var bar1: Array<T> = Array<T>.init(repeating: 0, count: length + 2)
    var bar2: Array<T> = Array<T>.init(repeating: 0, count: length + 2)
    var accy, cnt, bitss, creal, dum1, dum2, expon, mx1, mx2, ri10, rr10, sigfig, rmax, x, xi, xi2, xl, xr, xr2, log2: T
    var cdum1, cdum2, final, oldtemp, temp, temp1, ans: Complex<T>
    var goon1, i1, ibit,icount,ii10,ir10,ixcnt,l,lmax,nmach,rexp: Int
    var e1, e2, e3: T
    var ex1: T
    var ex2: T
    var ex3: T
    var ex4: T
    var ex5: T
    accy = 0
    cnt = 0
    creal = 0
    dum1 = 0
    dum2 = 0
    expon = 0
    mx1 = 0
    mx2 = 0
    ri10 = 0
    rr10 = 0
    sigfig = 0
    rmax = 0
    x = 0
    xi = 0
    xi2 = 0
    xl = 0
    xr = 0
    xr2 = 0
    cdum1 = Complex<T>(0)
    cdum2 = Complex<T>(0)
    final = Complex<T>(T.nan, T.nan)
    oldtemp = Complex<T>(0)
    temp = Complex<T>(0)
    temp1 = Complex<T>(0)
    goon1 = 0
    i1 = 0
    ibit = 0
    icount = 0
    ii10 = 0
    ir10 = 0
    ixcnt = 0
    l = 0
    lmax = 0
    nmach = 0
    rexp = 0
    bitss = bits()
    log2 = SSMath.log101(2)
    ibit = Helpers.integerValue(bitss)
    let intibito2: T =  Helpers.makeFP(ibit) / 2
    let intibito4: T =  Helpers.makeFP(ibit) / 4
    let iintibito2: Int = Helpers.integerValue(intibito2)
    let iintibito4: Int = Helpers.integerValue(intibito4)
    let intibito2f: T =  Helpers.makeFP(iintibito2)
    let intibito4f: T =  Helpers.makeFP(iintibito4)
    rmax = SSMath.pow1(2, intibito2f)
    sigfig = SSMath.pow1(2, intibito4f)
    for I1: Int in stride(from: 1, to: ip, by: 1) {
        i1 = I1
        ar2[i1 - 1] = (a[i1 - 1] &** sigfig).re
        ar[i1 - 1] = fix(ar2[i1 - 1])
        ar2[i1 - 1] = round((ar2[i1 - 1] - ar[i1 - 1]) * rmax)
        ai2[i1 - 1] = (a[i1 - 1] &** sigfig).im
        ai[i1 - 1] = fix(ai2[i1 - 1])
        ai2[i1 - 1] = round((ai2[i1 - 1] - ai[i1 - 1] * rmax))
    }
    for I1: Int in stride(from: 1, to: ip, by: 1) {
        cr2[I1 - 1] = (b[I1 - 1] &** sigfig).re
        cr[I1 - 1] = fix(cr2[i1 - 1])
        cr2[I1 - 1] = round((cr2[I1 - 1] - cr[I1 - 1]) * rmax)
        ci2[I1 - 1] = (b[I1 - 1] &** sigfig).im
        ci[I1 - 1] = fix(ci2[i1 - 1])
        ci2[I1 - 1] = round((ci2[I1 - 1] - ci[I1 - 1] * rmax))
    }
    xr2 = z.re * sigfig
    xr = fix(xr2)
    xr2 = round( (xr2 - xr) * rmax)
    xi2 = z.im * sigfig
    xi = fix(xi2)
    xi2 = round((xi2 - xi) * rmax)
    /*
     %
     %     WARN THE USER THAT THE INPUT VALUE WAS SO CLOSE TO ZERO THAT IT
     %     WAS SET EQUAL TO ZERO.
     %
     */
    for i1 in stride(from: 1, to: ip, by: 1) {
        if (!a[i1 - 1].re.isZero && ar[i1 - 1].isZero && ar2[i1 - 1].isZero) {
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Real part was set to zero (input vector a - at least one element was too close to zero)", log: .log_stat, type: .error)
            }
            #else
            print("Real part was set to zero (input vector a - at least one element was too close to zero)")
            #endif
        }
        if (!a[i1 - 1].isZero && ai[i1 - 1].isZero && ai2[i1 - 1].isZero) {
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Imaginary part was set to zero (input vector a - at least one element was too close to zero)", log: .log_stat, type: .error)
            }
            #else
            print("Imaginary part was set to zero (input vector a - at least one element was too close to zero)")
            #endif
        }
    }
    for i1 in stride(from: 1, to: iq, by: 1) {
        if (!b[i1 - 1].re.isZero && cr[i1 - 1].isZero && cr2[i1 - 1].isZero) {
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Real part was set to zero (input vector b - at least one element was too close to zero)", log: .log_stat, type: .error)
            }
            #else
            print("Real part was set to zero (input vector b - at least one element was too close to zero)")
            #endif
        }
        if (!b[i1 - 1].isZero && ci[i1 - 1].isZero && ci2[i1 - 1].isZero) {
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Imaginary part was set to zero (input vector b - at least one element was too close to zero)", log: .log_stat, type: .error)
            }
            #else
            print("Imaginary part was set to zero (input vector b - at least one element was too close to zero)")
            #endif
        }
    }
    if !z.re.isZero && xr.isZero && xr2.isZero {
        #if os(macOS) || os(iOS)
        if #available(macOS 10.12, iOS 13, *) {
            os_log("Real part was set to zero (input z - at least one element was too close to zero)", log: .log_stat, type: .error)
        }
        #else
        print("Real part was set to zero (input z - at least one element was too close to zero)")
        #endif
        z = Complex<T>.init(re: 0, im: z.im)
    }
    if !z.im.isZero && xi.isZero && xi2.isZero {
        #if os(macOS) || os(iOS)
        if #available(macOS 10.12, iOS 13, *) {
            os_log("Imaginary part was set to zero (input z - at least one element was too close to zero)", log: .log_stat, type: .error)
        }
        #else
        print("Imaginary part was set to zero (input z - at least one element was too close to zero)")
        #endif
        z = Complex<T>.init(re: z.re, im: 0)
    }
    /*
     %
     %
     %     SCREENING OF NUMERATOR ARGUMENTS FOR NEGATIVE INTEGERS OR ZERO.
     %     ICOUNT WILL FORCE THE SERIES TO TERMINATE CORRECTLY.
     %
     */
    nmach = ifix(SSMath.log101(SSMath.pow1(2, fix(bitss))))
    icount = -1
    for i1 in 1...ip {
        if ar2[i1 - 1].isZero && ar[i1 - 1].isZero && ai2[i1 - 1].isZero && ai[i1 - 1].isZero {
            ans = Complex<T>.init(re: T.one, im: 0)
            return ans
        }
        if ai[i1 - 1].isZero && ai2[i1 - 1].isZero && a[i1 - 1].re < 0 {
            ex1 = a[i1 - 1].re - round(a[i1 - 1].re)
            if abs(ex1) < SSMath.pow1(10, -Helpers.makeFP(nmach)) {
                if (icount != -1) {
                    icount = ifix(min( Helpers.makeFP(icount), -round(a[i1 - 1].re)))
                }
                else {
                    icount = -ifix(round(a[i1 - 1].re))
                }
            }
        }
    }
    /*
     %
     %     SCREENING OF DENOMINATOR ARGUMENTS FOR ZEROES OR NEGATIVE INTEGERS
     %     .
     %
     */
    for i1 in 1...iq {
        if ((cr[i1 - 1].isZero) && (cr2[i1 - 1].isZero) && (ci[i1 - 1].isZero) && (ci2[i1 - 1].isZero)) {
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Abort - denominator argument was equal to zero", log: .log_stat, type: .error)
            }
            #endif
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if ((ci[i1 - 1].isZero) && (ci2[i1 - 1].isZero) && (b[i1 - 1].re < 0)) {
            ex1 = (abs(b[i1 - 1].re) - round(b[i1 - 1].re))
            ex2 = SSMath.pow1(10,  Helpers.makeFP(-nmach))
            if ((ex1 < ex2) && (icount >= ifix(-round(b[i1 - 1].re)) || icount == -1)) {
                #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("Abort - denominator argument was equal to zero", log: .log_stat, type: .error)
                }
                #endif
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
        }
    }
    nmach = ifix(SSMath.log101(SSMath.pow1(2,  Helpers.makeFP(ibit))))
    nsigfig = min(nsigfig, nmach)
    accy = SSMath.pow1(10,  Helpers.makeFP(-nsigfig))
    do {
        l = try ipremax(a: a, b: b, ip: ip, iq: iq, z: z)
    }
    catch {
        throw error
    }
    var cex1: Complex<T>
    var cex2: Complex<T>
    if (l != 1) {
        /*
         %
         %     First, estimate the exponent of the maximum term in the pFq series
         %     .
         %*/
        expon = 0
        xl =  Helpers.makeFP(l)
        
        for i in 1...ip {
            cex1 = a[i - 1] &++ xl
            cex2 = cex1 &-- 1
            expon = expon + factor(cex2).re - factor(a[i - 1] &-- 1).re
        }
        for i in 1...iq {
            cex1 = b[i - 1] &++ xl
            cex2 = cex1 &++ 1
            expon = expon - factor(cex2).re + factor(b[i - 1] &-- 1).re
        }
        expon = (expon + xl) * SSMath.ComplexMath.log(z).re - factor(Complex<T>.init(re: xl, im: T.zero)).re
        lmax = ifix(SSMath.log101(SSMath.exp1(1)) * expon)
        l = lmax
        /*
         %
         %     Now, estimate the exponent of where the pFq series will terminate.
         %
         %
         */
        temp1 = Complex<T>.init(re: 1, im: 0)
        creal = 1
        for i1 in 1...ip {
            temp1 = temp1 &** Complex<T>(ar[i1 - 1],ai[i1 - 1]) &% sigfig
        }
        for i1 in 1...iq {
            temp1 = temp1 &% (Complex<T>(cr[i1 - 1],ci[i1 - 1]) &% sigfig)
            creal = creal * cr[i1 - 1]
        }
        temp1 = temp1 &** Complex<T>(xr,xi)
        /*
         %
         %     Triple it to make sure.
         %
         */
        l = 3 * l
        /*
         %
         %     Divide the number of significant figures necessary by the number
         %     of
         %     digits available per array position.
         %
         %
         */
        e1 =  Helpers.makeFP(l)
        e2 =  Helpers.makeFP(nsigfig)
        e3 =  Helpers.makeFP(nmach)
        l = ifix(2 * e1 + e2 / e3) + 2
    }
    /*
     %
     %     Make sure there are at least 5 array positions used.
     %
     */
    l = max(l, 5)
    l = max(l, ix)
    if l < 0 || l > length {
        #if os(macOS) || os(iOS)
        if #available(macOS 10.12, iOS 13, *) {
            os_log("Abort - error in fn hyper: l must be < 777", log: .log_stat, type: .error)
        }
        #endif
        throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
    }
    if nsigfig > nmach {
        #if os(macOS) || os(iOS)
        if #available(macOS 10.12, iOS 13, *) {
            os_log("Warning--the number of significant figures requested is greate than machine precision. Result is not as accurate as requested.", log: .log_stat, type: .error)
        }
        #else
        print("Warning--the number of significant figures requested is greate than machine precision. Result is not as accurate as requested.")
        #endif
    }
    sumr[-1 + aOffset] = 1
    sumi[-1 + aOffset] = 1
    numr[-1 + aOffset] = 1
    numi[-1 + aOffset] = 1
    denomr[-1 + aOffset] = 1
    denomi[-1 + aOffset] = 1
    for i in 0...l + 1 {
        sumr[i + aOffset] = 0
        sumi[i + aOffset] = 0
        numr[i + aOffset] = 0
        numi[i + aOffset] = 0
        denomr[i + aOffset] = 0
        denomi[i + aOffset] = 0
    }
    sumr[1 + aOffset] = 1
    numr[1 + aOffset] = 1
    denomr[1 + aOffset] = 1
    cnt = sigfig
    temp = Complex<T>(0,0)
    oldtemp = temp
    ixcnt = 0
    e1 =  Helpers.makeFP(ibit)
    e2 =  Helpers.makeFP(2)
    rexp = ifix(e1 / e2)
    x =  Helpers.makeFP(rexp) * (sumr[l + 1 + aOffset] - 2)
    rr10 = x * log2
    ir10  = ifix(rr10)
    rr10 = rr10 -  Helpers.makeFP(ir10)
    x =  Helpers.makeFP(rexp) * (sumi[l + 1 + aOffset] - 2)
    ri10 = x * log2
    ii10 = ifix(ri10)
    ri10 = ri10 -  Helpers.makeFP(ii10)
    ex1 = sumr[1 + aOffset] * rmax * rmax
    ex2 = sumr[2 + aOffset] * rmax
    ex3 = sumr[3 + aOffset]
    ex4 = ex1 + ex2 + ex3
    dum1 = abs(ex4) * SSMath.sign(sumr[-1 + aOffset])
    ex1 = sumi[1 + aOffset] * rmax * rmax
    ex2 = sumi[2 + aOffset] * rmax
    ex3 = sumi[3 + aOffset]
    ex4 = ex1 + ex2 + ex3
    dum2 = ex4 * SSMath.sign(sumi[-1 + aOffset])
    dum1 = dum1 * SSMath.pow1(10, rr10)
    dum2 = dum2 * SSMath.pow1(10, ri10)
    cdum1 = Complex<T>(dum1,dum2)
    x =  Helpers.makeFP(rexp) * (denomr[l + 1 + aOffset] - 2)
    rr10 = x * log2
    ir10 = ifix(rr10)
    rr10 = rr10 -  Helpers.makeFP(ir10)
    x =  Helpers.makeFP(rexp) * (denomi[l + 1 + aOffset] - 2)
    ri10 = x * log2
    ii10 = ifix(ri10)
    ri10 = ri10 -  Helpers.makeFP(ii10)
    ex1 = denomr[1 + aOffset] * rmax * rmax
    ex2 = denomr[2 + aOffset] * rmax
    ex3 = ex1 + ex2 + denomr[3 + aOffset]
    ex4 = abs(ex3)
    ex5 = denomr[-1 + aOffset]
    dum1 = ex4 * SSMath.sign(ex5)
    ex1 = denomi[1 + aOffset] * rmax * rmax
    ex2 = denomi[2 + aOffset] * rmax
    ex3 = ex1 + ex2 + denomi[3 + aOffset]
    dum2 = abs(ex3) * SSMath.sign(denomi[-1 + aOffset])
    dum1 = dum1 * SSMath.pow1(10, rr10)
    dum2 = dum2 * SSMath.pow1(10, ri10)
    cdum2 = Complex<T>(dum1, dum2)
    temp = cdum1 &% cdum2
    goon1 = 1
    while goon1 == 1 {
        goon1 = 0
        if (ip < 0) {
            if (sumr[1 + aOffset] < T.half) {
                mx1 = sumi[l + 1 + aOffset]
            }
            else if (sumi[1 + aOffset] < T.half) {
                mx1 = sumr[l + 1 + aOffset]
            }
            else {
                mx1 = max(sumr[l + 1 + aOffset],sumi[l + 1 + aOffset])
            }
            if (numr[1 + aOffset] < T.half) {
                mx2 = numi[l + 1 + aOffset]
            }
            else if (numi[1 + aOffset] < T.half) {
                mx2 = numr[l + 1 + aOffset]
            }
            else {
                mx2 = max(numr[l + 1 + aOffset],numi[l + 1 + aOffset])
            }
            if (mx1 - mx2 > 2) {
                if (creal >= 0) {
                    if ((temp1 &% cnt).abs <= 1) {
                        do {
                            try arydiv(ar: &sumr, ai: &sumi, br: &denomr, bi: &denomi, c: &final, l: l, lnpfq: lnpfq, rmax: rmax, ibit: ibit)
                        }
                        catch {
                            throw error
                        }
                        ans = final
                        return ans
                    }
                }
            }
        }
        else {
            do {
                try arydiv(ar: &sumr, ai: &sumi, br: &denomr, bi: &denomi, c: &temp, l: l, lnpfq: lnpfq, rmax: rmax, ibit: ibit)
            }
            catch {
                throw error
            }
            //            %
            //            %      First, estimate the exponent of the maximum term in the pFq
            //            %      series.
            //            %
            expon = 0
            xl =  Helpers.makeFP(ixcnt)
            for i in 1...ip {
                cex1 = a[i - 1] &++ xl
                cex2 = cex1 &-- 1
                expon = expon + factor(cex2).re - factor(a[i - 1] &-- T.one).re
            }
            for i in 1...iq {
                cex1 = b[i - 1] &++ xl
                cex2 = cex1 &-- 1
                expon = expon - factor(cex2).re + factor(b[i - 1] &-- T.one).re
            }
            expon = expon + xl * SSMath.ComplexMath.log(z).re - factor(Complex<T>(xl,0)).re
            lmax = ifix(SSMath.log101(SSMath.exp1(T.one)) * expon)
            if ((oldtemp &-- temp).abs < (temp &** accy).abs) {
                do {
                    try arydiv(ar: &sumr, ai: &sumi, br: &denomr, bi: &denomi, c: &final, l: l, lnpfq: lnpfq, rmax: rmax, ibit: ibit)
                }
                catch {
                    throw error
                }
                ans = final
                return ans
            }
            temp = oldtemp
        }
        if ixcnt != icount {
            ixcnt = ixcnt + 1
            for i1 in 1...iq {
                //                %
                //                %      TAKE THE CURRENT SUM AND MULTIPLY BY THE DENOMINATOR OF THE NEXT
                //                %
                //                %      TERM, FOR BOTH THE MOST SIGNIFICANT HALF (CR,CI) AND THE LEAST
                //                %
                //                %      SIGNIFICANT HALF (CR2,CI2).
                //                %
                //                %
                cmpmul(ar: &sumr, ai: &sumi, br: cr[i1 - 1], bi: ci[i1 - 1], cr: &qr1, ci: &qi1, wk1: &wk1, wk2: &wk2, cr2: &wk3, d1: &wk4, d2: &wk5, wk6: &wk6, l: l, rmax: rmax)
                cmpmul(ar: &sumr, ai: &sumi, br: cr2[i1 - 1], bi: ci2[i1 - 1], cr: &qr2, ci: &qi2, wk1: &wk1, wk2: &wk2, cr2: &wk3, d1: &wk4, d2: &wk5, wk6: &wk6, l: l, rmax: rmax)
                qr2[l + 1 + aOffset] = qr2[l + 1 + aOffset] - T.one
                qi2[l + 1 + aOffset] = qi2[l + 1 + aOffset] - T.one
                //                    %
                //                    %      STORE THIS TEMPORARILY IN THE SUM ARRAYS.
                //                    %
                //                    %
                cmpadd(ar: &qr1, ai: &qi1, br: &qr2, bi: &qi2, cr: &sumr, ci: &sumi, wk1: &wk1, l: l, rmax: rmax)
            }
            //            %
            //            %     MULTIPLY BY THE FACTORIAL TERM.
            //            %
            foo1 = sumr
            foo2 = sumr
            armult(a: &foo1, b: cnt, c: &foo2, z: &wk6, l: l, rmax: rmax)
            sumr = foo2
            foo1 = sumi
            foo2 = sumi
            armult(a: &foo1, b: cnt, c: &foo2, z: &wk6, l: l, rmax: rmax)
            sumi = foo2
            //            %
            //            %     MULTIPLY BY THE SCALING FACTOR, SIGFIG, TO KEEP THE SCALE CORRECT.
            //            %
            for _ in 1...ip-iq {
                foo1 = sumr
                foo2 = sumr
                armult(a: &foo1, b: sigfig, c: &foo2, z: &wk6, l: l, rmax: rmax)
                sumr = foo2
                foo1 = sumi
                foo2 = sumi
                armult(a: &foo1, b: sigfig, c: &foo2, z: &wk6, l: l, rmax: rmax)
                sumi = foo2
            }
            for i1 in 1...iq {
                //            %
                //            %      UPDATE THE DENOMINATOR.
                //            %
                //            %
                cmpmul(ar: &denomr, ai: &denomi, br: cr[i1 - 1], bi: ci[i1 - 1], cr: &qr1, ci: &qi1, wk1: &wk1, wk2: &wk2, cr2: &wk3, d1: &wk4, d2: &wk5, wk6: &wk6, l: l, rmax: rmax)
                cmpmul(ar: &denomr, ai: &denomi, br: cr2[i1 - 1], bi: ci2[i1 - 1], cr: &qr2, ci: &qi2, wk1: &wk1, wk2: &wk2, cr2: &wk3, d1: &wk4, d2: &wk5, wk6: &wk6, l: l, rmax: rmax)
                qr2[l + 1 + aOffset] = qr2[l + 1 + aOffset] - T.one
                qi2[l + 1 + aOffset] = qi2[l + 1 + aOffset] - T.one
                cmpadd(ar: &qr1, ai: &qi1, br: &qr2, bi: &qi2, cr: &denomr, ci: &denomi, wk1: &wk1, l: l, rmax: rmax)
            }
            //            %
            //            %
            //            %     MULTIPLY BY THE FACTORIAL TERM.
            //            %
            foo1 = denomr
            foo2 = denomr
            armult(a: &foo1, b: cnt, c: &foo2, z: &wk6, l: l, rmax: rmax)
            denomr = foo2
            foo2 = denomi
            foo1 = denomi
            armult(a: &foo1, b: cnt, c: &foo2, z: &wk6, l: l, rmax: rmax)
            denomi = foo2
            //            %
            //            %     MULTIPLY BY THE SCALING FACTOR, SIGFIG, TO KEEP THE SCALE CORRECT.
            //            %
            for _ in 1...ip-iq {
                foo1 = denomr
                foo2 = denomr
                armult(a: &foo1, b: sigfig, c: &foo2, z: &wk6, l: l, rmax: rmax)
                denomr = foo2
                foo1 = denomi
                foo2 = denomi
                armult(a: &foo1, b: sigfig, c: &foo2, z: &wk6, l: l, rmax: rmax)
                denomi = foo2
            }
            //           %
            //           %     FORM THE NEXT NUMERATOR TERM BY MULTIPLYING THE CURRENT
            //           %     NUMERATOR TERM (AN ARRAY) WITH THE A ARGUMENT (A SCALAR).
            //           %
            for i1 in 1...ip {
                cmpmul(ar: &numr, ai: &numi, br: ar[i1 - 1], bi: ai[i1 - 1], cr: &qr1, ci: &qi1, wk1: &wk1, wk2: &wk2, cr2: &wk3, d1: &wk4, d2: &wk5, wk6: &wk6, l: l, rmax: rmax)
                cmpmul(ar: &numr, ai: &numi, br: ar2[i1 - 1], bi: ai2[i1 - 1], cr: &qr2, ci: &qi2, wk1: &wk1, wk2: &wk2, cr2: &wk3, d1: &wk4, d2: &wk5, wk6: &wk6, l: l, rmax: rmax)
                qr2[l + 1 + aOffset] = qr2[l + 1 + aOffset] - T.one
                qi2[l + 1 + aOffset] = qi2[l + 1 + aOffset] - T.one
                cmpadd(ar: &qr1, ai: &qi1, br: &qr2, bi: &qi2, cr: &numr, ci: &numi, wk1: &wk1, l: l, rmax: rmax)
            }
            //            %
            //            %     FINISH THE NEW NUMERATOR TERM BY MULTIPLYING BY THE Z ARGUMENT.
            //            %
            cmpmul(ar: &numr, ai: &numi, br: xr, bi: xi, cr: &qr1, ci: &qi1, wk1: &wk1, wk2: &wk2, cr2: &wk3, d1: &wk4, d2: &wk5, wk6: &wk6, l: l, rmax: rmax)
            cmpmul(ar: &numr, ai: &numi, br: xr2, bi: xi2, cr: &qr2, ci: &qi2, wk1: &wk1, wk2: &wk2, cr2: &wk3, d1: &wk4, d2: &wk5, wk6: &wk6, l: l, rmax: rmax)
            qr2[l + 1 + aOffset] = qr2[l + 1 + aOffset] - T.one
            qi2[l + 1 + aOffset] = qi2[l + 1 + aOffset] - T.one
            cmpadd(ar: &qr1, ai: &qi1, br: &qr2, bi: &qi2, cr: &numr, ci: &numi, wk1: &wk1, l: l, rmax: rmax)
            //            %
            //            %     MULTIPLY BY THE SCALING FACTOR, SIGFIG, TO KEEP THE SCALE CORRECT.
            //            %
            for _ in 1...iq-ip {
                foo1 = numr
                foo2 = numr
                armult(a: &foo1, b: sigfig, c: &foo2, z: &wk6, l: l, rmax: rmax)
                numr = foo2
                foo1 = numi
                foo2 = numi
                armult(a: &foo1, b: sigfig, c: &foo2, z: &wk6, l: l, rmax: rmax)
                numi = foo2
            }
            //            %
            //            %     FINALLY, ADD THE NEW NUMERATOR TERM WITH THE CURRENT RUNNING
            //            %     SUM OF THE NUMERATOR AND STORE THE NEW RUNNING SUM IN SUMR, SUMI.
            //            %
            foo1 = sumr
            foo2 = sumr
            bar1 = sumi
            bar2 = sumi
            cmpadd(ar: &foo1, ai: &bar1, br: &numr, bi: &numi, cr: &foo2, ci: &bar2, wk1: &wk1, l: l, rmax: rmax)
            sumi = bar2
            sumr = foo2
            //            %
            //            %     BECAUSE SIGFIG REPRESENTS "ONE" ON THE NEW SCALE, ADD SIGFIG
            //            %     TO THE CURRENT COUNT AND, CONSEQUENTLY, TO THE IP ARGUMENTS
            //            %     IN THE NUMERATOR AND THE IQ ARGUMENTS IN THE DENOMINATOR.
            //            %
            cnt = cnt + sigfig
            for i1 in 1...ip {
                ar[i1 - 1] = ar[i1 - 1] + sigfig
            }
            for i1 in 1...iq {
                cr[i1 - 1] = cr[i1 - 1] + sigfig
            }
            goon1 = 1
        }
    }
    do {
        try arydiv(ar: &sumr, ai: &sumi, br: &denomr, bi: &denomi, c: &final, l: l, lnpfq: lnpfq, rmax: rmax, ibit: ibit)
        ans = final
    }
    catch {
        throw error
    }
    return final
}

fileprivate func fix<T: SSFloatingPoint>(_ x: T) -> T {
    let i: Int = Helpers.integerValue(x)
    let f: T =  Helpers.makeFP(i)
    return f
}

fileprivate func ifix<T: SSFloatingPoint>(_ x: T) -> Int {
    let i: Int = Helpers.integerValue(x)
    return i
}


fileprivate func bits<T: SSFloatingPoint>() -> T {
    var bit, bit2: T
    var count: T
    bit = 1
    count = 1
    count = count + 1
    bit2 = bit * 2
    bit = bit2 + 1
    while !(bit - bit2).isZero {
        count = count + 1
        bit2 = bit * 2
        bit = bit2 + 1
    }
    bit = count - 3
    return bit
}

// FORTRAN ARRAYS START WITH -1
fileprivate let aOffset = 1


/*
 %     ****************************************************************
 %     *                                                              *
 %     *                 SUBROUTINE ARADD                             *
 %     *                                                              *
 %     *                                                              *
 %     *  Description : Accepts two arrays of numbers and returns     *
 %     *    the sum of the array.  Each array is holding the value    *
 %     *    of one number in the series.  The parameter L is the      *
 %     *    size of the array representing the number and RMAX is     *
 %     *    the actual number of digits needed to give the numbers    *
 %     *    the desired accuracy.                                     *
 %     *                                                              *
 %     *  Subprograms called: none                                    *
 %     *                                                              *
 %     ****************************************************************
 */
fileprivate func aradd<T: SSFloatingPoint>(a: inout Array<T>, b: inout Array<T>, c: inout Array<T>, z: inout Array<T>, l: Int, rmax: T) {
    let one: T = T.one
    let zero: T = T.zero
    let half: T = T.half
    var ediff, I,i: Int
    var goon300: Int = 1
    var goon190: Int = 1
    I = 0
    ediff = 0
    for i in stride(from: 0, through: l + 1, by: 1) {
        z[i + aOffset] = zero
    }
    ediff = Helpers.integerValue(round(a[l + 1 + aOffset] - b[l + 1 + aOffset]))
    if (abs(a[1 + aOffset]) < half || ediff <= -l) {
        for i in -1...l + 1 {
            c[i + aOffset]  = b[i + aOffset]
            I = i
        }
        if (c[1 + aOffset] < half) {
            c[-1 + aOffset] = one
            c[l + 1 + aOffset] = zero
        }
        return;
    }
    else {
        if (abs(b[1 + aOffset]) < half || ediff >= l) {
            for i in -1...l + 1 {
                c[i + aOffset] = a[i + 2]
                I = i
            }
            if (c[1 + aOffset] < half) {
                c[-1 + aOffset] = one
                c[l + 1 + aOffset] = zero
            }
            return
        }
        else {
            z[-1 + aOffset] = a[-1 + aOffset]
            goon300 = 1
            goon190 = 1
            if (abs(a[-1 + aOffset] - b[-1 + aOffset]) >= half) {
                goon300 = 0
                if (ediff > 0) {
                    z[l + 1 + aOffset] = a[l + 1 + aOffset]
                }
                else if (ediff < 0) {
                    z[l + 1 + aOffset] = b[l + 1 + aOffset]
                    z[-1 + aOffset] = b[-1 + aOffset]
                    goon190 = 0
                }
                else {
                    for i in 1...l {
                        if (a[i + aOffset] > b[i + aOffset]) {
                            z[l+1 + aOffset] = a[l + 1 + aOffset]
                            break
                        }
                        if (a[i + aOffset] < b[i + aOffset]) {
                            z[l + 1 + aOffset] = b[l + 1 + aOffset]
                            z[-1 + aOffset] = b[-1 + aOffset]
                            goon190 = 0
                        }
                        I = i
                    }
                }
            }
            else if ediff > 0 {
                z[l + 1 + aOffset] = a[l + 1 + aOffset]
                for i in stride(from: l, through: 1 + ediff, by: -1) {
                    z[i + aOffset] = a[i + aOffset] + b[i - ediff + aOffset] + z[i + aOffset]
                    if (z[i + aOffset] >= rmax) {
                        z[i + aOffset] = z[i + aOffset] - rmax
                        z[i - 1 + aOffset] = one
                    }
                    I = i
                }
                for i in stride(from: ediff, through: 1, by: -1) {
                    z[i + aOffset] = a[i + aOffset] + z[i + aOffset]
                    if (z[i + aOffset] >= rmax) {
                        z[i + aOffset] = z[i + aOffset] - rmax
                        z[i - 1 + aOffset] = one
                    }
                    I = i
                }
                if (z[0 + aOffset] > half) {
                    for i in stride(from: l, through: 1, by: -1) {
                        z[i + aOffset] = z[i - 1 + aOffset]
                        I = i
                    }
                    z[l + 1 + aOffset] = z[l + 1 + aOffset] + 1
                    z[0 + aOffset] = zero
                }
            }
            else if ediff < 0 {
                z[l + 1 + aOffset] = b[l + 1 + aOffset]
                for i in stride(from: l, through: 1 - ediff, by: -1) {
                    z[i + aOffset] = a[i + ediff + aOffset] + b[i + aOffset] + z[i + aOffset]
                    if (z[i + aOffset] >= rmax) {
                        z[i + aOffset] = z[i + aOffset] - rmax
                        z[i - 1 + aOffset] = one
                    }
                    I = i
                }
                for i in stride(from: 0 - ediff, through: 1, by: -1) {
                    z[i + aOffset] = b[i + aOffset] + z[i + aOffset]
                    if (z[i + aOffset] >= rmax) {
                        z[i + aOffset] = z[i + aOffset] - rmax
                        z[i-1 + aOffset] = one
                    }
                    I = i
                }
                if (z[0 + aOffset] > half) {
                    for i in stride(from: l, through: 1, by: -1) {
                        z[i + aOffset] = z[i - 1 + aOffset]
                        I = i
                    }
                    z[l + 1 + aOffset] = z[l + 1 + aOffset] + one
                    z[0 + aOffset] = 0
                }
            }
            else {
                z[l + 1 + aOffset] = a[l + 1 + aOffset]
                for i in stride(from: l, through: 1, by: -1) {
                    z[i + aOffset] = a[i + aOffset] + b[i + aOffset] + z[i + aOffset]
                    if (z[i + aOffset] >= rmax) {
                        z[i + aOffset] = z[i + aOffset] - rmax
                        z[i - 1 + aOffset] = one
                    }
                    I = i
                }
                if (z[0 + aOffset] > half) {
                    for i in stride(from: l, through: 1, by: -1) {
                        z[i + aOffset] = z[i - 1 + aOffset]
                        I = i
                    }
                    z[l + 1 + aOffset] = z[l + 1 + aOffset] + one
                    z[0 + aOffset] = zero
                }
            }
            if goon300 == 1 {
                i = I       // %here is the line that had a +1 taken from it.
                while (z[i + aOffset] < half && i < l + 1) {
                    i = i + 1
                }
                if (i == l + 1) {
                    z[-1 + aOffset] = one
                    z[l + 1 + aOffset] = 0
                    for i in -1...l + 1 {
                        c[i + aOffset] = z[i + aOffset]
                    }
                    if (c[1 + aOffset] < half) {
                        c[-1 + aOffset] = one
                        c[l + 1 + aOffset] = 0
                    }
                    return
                }
                for j in 1...l + 1 - i {
                    z[j + aOffset] = z[j + i - 1 + aOffset]
                }
                /// TODO: ???
                for j in stride(from: l + 2 - 1, through: l, by: -1) {
                    z[j + aOffset] = 0
                }
                z[l + 1 + aOffset] = z[l + 1 + aOffset] -  Helpers.makeFP(i) + 1
                for i in stride(from: -1, through: l + 1, by: 1) {
                    c[i + aOffset] = z[i + aOffset]
                }
                if (c[1 + aOffset] < half) {
                    c[-1 + aOffset] = one
                    c[l + 1 + aOffset] = 0
                }
                return
            }
            if goon190 == 1{
                if ediff > 0 {
                    for i in stride(from: l, through: 1 + ediff, by: -1) {
                        z[i + aOffset] = a[i + aOffset] - b[i - ediff + aOffset] + z[i + aOffset]
                        if (z[i + aOffset] < 0) {
                            z[i + aOffset] = z[i + aOffset] + rmax
                            z[i - 1 + aOffset] = -one
                        }
                    }
                    for i in stride(from: ediff, through: 1, by: -1) {
                        z[i + aOffset] = a[i + aOffset] + z[i + aOffset]
                        if (z[i + aOffset] < 0) {
                            z[i + aOffset] = z[i + aOffset] + rmax
                            z[i - 1 + aOffset] = -one
                        }
                    }
                }
                else {
                    for i in stride(from: l, through: 1, by: -1) {
                        z[i + aOffset] = a[i + aOffset] - b[i + aOffset] + z[i + aOffset]
                        if (z[i + aOffset] < 0) {
                            z[i + aOffset] = z[i + aOffset] + rmax
                            z[i - 1 + aOffset] = -one
                        }
                    }
                }
                if (z[1 + aOffset] > half) {
                    for i in -1...l + 1 {
                        c[i + aOffset] = z[i + aOffset]
                    }
                    if (c[1 + aOffset] < half) {
                        c[-1 + aOffset] = one
                        c[l + 1 + aOffset] = 0
                    }
                    return
                }
                i = 1
                i = i + 1
                while (z[i + aOffset] < half && i < l + 1) {
                    i = i + 1
                }
                if (i == l + 1) {
                    z[-1 + aOffset] = one
                    z[l + 1 + aOffset] = 0
                    for i in -1...l + 1 {
                        c[i + aOffset] = z[i + aOffset]
                    }
                    if (c[1 + aOffset] < half) {
                        c[-1 + aOffset] = one
                        c[l + 1 + aOffset] = 0
                    }
                    return
                }
            }
        }
        if ediff < 0 {
            for i in stride(from: l, through: 1 - ediff, by: -1) {
                z[i + aOffset] = b[i + 2] - a[i + ediff + aOffset] + z[i + aOffset]
                if (z[i + aOffset] < 0) {
                    z[i + aOffset] = z[i + aOffset] + rmax
                    z[i - 1 + aOffset] = -one
                }
            }
            for i in stride(from: 0 - ediff, through: 1, by: -1) {
                z[i + aOffset] = b[i + aOffset] + z[i + aOffset]
                if (z[i + aOffset] < 0) {
                    z[i + aOffset] = z[i + aOffset] + rmax
                    z[i - 1 + aOffset] = -one
                }
            }
        } else {
            for i in stride(from: l, through: 1, by: -1) {
                z[i + aOffset] = b[i + aOffset] - a[i + aOffset] + z[i + aOffset]
                if (z[i + aOffset] < 0) {
                    z[i + aOffset] = z[i + aOffset] + rmax
                    z[i - 1 + aOffset] = -one
                }
            }
        }
    }
    if (z[1 + aOffset] > half) {
        for i in -1...l + 1 {
            c[i + aOffset] = z[i + aOffset]
        }
        if (c[1 + aOffset] < half) {
            c[-1 + aOffset] = one
            c[l + 1 + aOffset] = 0
        }
        return
    }
    i = 1
    i = i + 1
    while (z[i + aOffset] < half && i < l + 1 ) {
        i = i + 1
    }
    if (i == l + 1) {
        z[-1 + aOffset] = one
        z[l + 1 + aOffset] = 0
        for i in -1...l+1 {
            c[i + aOffset] = z[i + aOffset]
        }
        if (c[1 + aOffset] < half) {
            c[-1 + aOffset] = one
            c[l + 1 + aOffset] = 0
        }
        return
    }
    for j in 1...l + 1 - i {
        z[j + aOffset] = z[j + i - 1 + aOffset]
    }
    for j in stride(from: l + 2 - i, through: l, by: -1) {
        z[j + aOffset] = 0
    }
    z[l + 1 + aOffset] = z[l + 1 + aOffset] -  Helpers.makeFP(i) + 1
    for i in -1...l + 1 {
        c[i + aOffset] = z[i + aOffset]
    }
    if (c[1 + aOffset] < half) {
        c[-1 + aOffset]  = one
        c[l + 1 + aOffset] = 0
    }
}
/*
 %     ****************************************************************
 %     *                                                              *
 %     *                 SUBROUTINE ARSUB                             *
 %     *                                                              *
 %     *                                                              *
 %     *  Description : Accepts two arrays and subtracts each element *
 %     *    in the second array from the element in the first array   *
 %     *    and returns the solution.  The parameters L and RMAX are  *
 %     *    the size of the array and the number of digits needed for *
 %     *    the accuracy, respectively.                               *
 %     *                                                              *
 %     *  Subprograms called: ARADD                                   *
 %     *                                                              *
 %     ****************************************************************
 */
fileprivate func arsub<T: SSFloatingPoint>(a: inout Array<T>, b: inout Array<T>, c: inout Array<T>, wk1: inout Array<T>, wk2: inout Array<T>, l: Int, rmax: T) {
    let one: T = T.one
    for i in -1...l + 1 {
        wk2[i + aOffset] = b[i + aOffset]
    }
    wk2[-1 + aOffset] = -one * wk2[-1 + aOffset]
    aradd(a: &a, b: &wk2, c: &c, z: &wk1, l: l, rmax: rmax)
}

/*
 %
 %     ****************************************************************
 %     *                                                              *
 %     *                 SUBROUTINE ARMULT                            *
 %     *                                                              *
 %     *                                                              *
 %     *  Description : Accepts two arrays and returns the product.   *
 %     *    L and RMAX are the size of the arrays and the number of   *
 %     *    digits needed to represent the numbers with the required  *
 %     *    accuracy.                                                 *
 %     *                                                              *
 %     *  Subprograms called: none                                    *
 %     *                                                              *
 %     ****************************************************************
 
 */
fileprivate func armult<T: SSFloatingPoint>(a: inout Array<T>, b: T, c: inout Array<T>, z: inout Array<T>, l: Int, rmax: T) {
    let eps: T = T.ulpOfOne
    let one: T = T.one
    let half: T = T.half
    var b2: T = 0
    var carry: T = 0
    z[-1 + aOffset] = SSMath.sign(b) * a[-1 + aOffset]
    b2 = abs(b)
    z[l + 1 + aOffset] = a[l + 1 + aOffset]
    for i in 0...l {
        z[i + aOffset] = 0
    }
    if (b2 <= eps || a[1 + aOffset] <= eps) {
        z[-1 + aOffset] = one
        z[l + 1 + aOffset] = 0
    }
    else {
        for i in stride(from: l, through: 1, by: -1) {
            z[i + aOffset] = a[i + aOffset] * b2 + z[i + aOffset]
            if (z[i + aOffset] >= rmax) {
                carry = Helpers.integerPart(z[i + aOffset] / rmax)
                z[i + aOffset] = z[i + aOffset] - carry * rmax
                z[i - 1 + aOffset] = carry
            }
        }
        if (z[0 + aOffset] >= half) {
            for i in stride(from: l, through: 1, by: -1) {
                z[i + aOffset] = z[i - 1 + aOffset]
            }
            z[l + 1 + aOffset] = z[l + 1 + aOffset] + one
            if (z[1 + aOffset] >= rmax) {
                for i in stride(from: l, through: 1, by: -1) {
                    z[i + aOffset] = z[i - 1 + aOffset]
                }
                carry = Helpers.integerPart(z[1 + aOffset] / rmax)
                z[2 + aOffset] = z[2 + aOffset] - carry * rmax
                z[1 + aOffset] = carry
                z[l + 1 + aOffset] = z[l + 1 + aOffset] + one
            }
            z[0 + aOffset] = 0
        }
    }
    for i in -1...l + 1 {
        c[i + aOffset] = z[i + aOffset]
    }
    if (c[1 + aOffset] < half) {
        c[-1 + aOffset] = one
        c[l + 1 + aOffset] = 0
    }
}

/*
 %     ****************************************************************
 %     *                                                              *
 %     *                 SUBROUTINE CMPADD                            *
 %     *                                                              *
 %     *                                                              *
 %     *  Description : Takes two arrays representing one real and    *
 %     *    one imaginary part, and adds two arrays representing      *
 %     *    another complex number and returns two array holding the  *
 %     *    complex sum.                                              *
 %     *              (CR,CI) = (AR+BR, AI+BI)                        *
 %     *                                                              *
 %     *  Subprograms called: ARADD                                   *
 %     *                                                              *
 %     ****************************************************************
 */
fileprivate func cmpadd<T: SSFloatingPoint>(ar: inout Array<T>, ai: inout Array<T>, br: inout Array<T>, bi: inout Array<T>, cr: inout Array<T>, ci: inout Array<T>, wk1: inout Array<T>, l: Int, rmax: T) {
    aradd(a: &ar, b: &br, c: &cr, z: &wk1, l: l, rmax: rmax)
    aradd(a: &ai, b: &bi, c: &ci, z: &wk1, l: l, rmax: rmax)
}

/*
 !     ****************************************************************
 !     *                                                              *
 !     *                 SUBROUTINE CMPSUB                            *
 !     *                                                              *
 !     *                                                              *
 !     *  Description : Takes two arrays representing one real and    *
 !     *    one imaginary part, and subtracts two arrays representing *
 !     *    another complex number and returns two array holding the  *
 !     *    complex sum.                                              *
 !     *              (CR,CI) = (AR+BR, AI+BI)                        *
 !     *                                                              *
 !     *  Subprograms called: ARADD                                   *
 !     *                                                              *
 !     ****************************************************************
 */
fileprivate func cmpsub<T: SSFloatingPoint>(ar: inout Array<T>, ai: inout Array<T>, br: inout Array<T>, bi: inout Array<T>, cr: inout Array<T>, ci: inout Array<T>, wk1: inout Array<T>, wk2: inout Array<T>, l: Int, rmax: T) {
    arsub(a: &ar, b: &br, c: &cr, wk1: &wk1, wk2: &wk2, l: l, rmax: rmax)
    arsub(a: &ai, b: &bi, c: &ci, wk1: &wk1, wk2: &wk2, l: l, rmax: rmax)
}

/*
 %     ****************************************************************
 %     *                                                              *
 %     *                 SUBROUTINE CMPMUL                            *
 %     *                                                              *
 %     *                                                              *
 %     *  Description : Takes two arrays representing one real and    *
 %     *    one imaginary part, and multiplies it with two arrays     *
 %     *    representing another complex number and returns the       *
 %     *    complex product.                                          *
 %     *                                                              *
 %     *  Subprograms called: ARMULT, ARSUB, ARADD                    *
 %     *                                                              *
 %     ****************************************************************
 */
fileprivate func cmpmul<T: SSFloatingPoint>(ar: inout Array<T>,ai: inout Array<T>,br: T,bi: T,cr: inout Array<T>,ci: inout Array<T>,wk1: inout Array<T>,wk2: inout Array<T>,cr2: inout Array<T>,d1: inout Array<T>,d2: inout Array<T>,wk6: inout Array<T>,l: Int,rmax: T) {
    armult(a: &ar, b: br, c: &d1, z: &wk6, l: l, rmax: rmax)
    armult(a: &ai, b: bi, c: &d2, z: &wk6, l: l, rmax: rmax)
    arsub(a: &d1, b: &d2, c: &cr2, wk1: &wk1, wk2: &wk2, l: l, rmax: rmax)
    armult(a: &ar, b: bi, c: &d1, z: &wk6, l: l, rmax: rmax)
    armult(a: &ai, b: br, c: &d2, z: &wk6, l: l, rmax: rmax)
    aradd(a: &d1, b: &d2, c: &ci, z: &wk1, l: l, rmax: rmax)
    for i in -1...l + 1 {
        cr[i + aOffset] = cr2[i + aOffset]
    }
}

/*
 %     ****************************************************************
 %     *                                                              *
 %     *                 SUBROUTINE ARYDIV                            *
 %     *                                                              *
 %     *                                                              *
 %     *  Description : Returns the double precision complex number   *
 %     *    resulting from the division of four arrays, representing  *
 %     *    two complex numbers.  The number returned will be in one  *
 %     *    of two different forms:  either standard scientific or as *
 %     *    the log (base 10) of the number.                          *
 %     *                                                              *
 %     *  Subprograms called: CONV21, CONV12, EADD, ECPDIV, EMULT.    *
 %     *                                                              *
 %     ****************************************************************
 */
fileprivate func arydiv<T: SSFloatingPoint>(ar: inout Array<T>,ai: inout Array<T>,br: inout Array<T>,bi: inout Array<T>,c: inout Complex<T>,l: Int,lnpfq: Int,rmax: T,ibit: Int) throws {
    var cdum: Complex<T> = Complex<T>.init(re: 0, im: 0)
    var c: Complex<T> = Complex<T>.init(re: 0, im: 0)
    var  dum1 , dum2 , e1 , e2 ,e3 , n1 , n2 , n3 , phi , ri10 , rr10 , tenmax , x ,x1 , x2: T
    var ii10 , ir10, rexp: Int
    var be: Array<Array<T>>
    var ae: Array<Array<T>> /* = Array<Array<T>>.init(repeating: Array<T>.init(repeating: 0, count: 2), count: 2) */
    var ce: Array<Array<T>> = Array<Array<T>>.init(repeating: Array<T>.init(repeating: 0, count: 2), count: 2)
    var ex1: T
    var ex2: T
    var ex3: T
    rexp = ibit / 2
    x =  Helpers.makeFP(rexp) * (ai[l + aOffset + 1] - 2)
    rr10 = x * SSMath.log1(2) / SSMath.log101(10)
    ir10 = Helpers.integerValue(rr10)
    rr10 = rr10 -  Helpers.makeFP(ir10)
    x =  Helpers.makeFP(rexp) * (ai[l + 1 + aOffset] - 2)
    ri10 = x * SSMath.log101(2) / SSMath.log101(10)
    ii10 = Helpers.integerValue(ri10)
    ri10 = ri10 -  Helpers.makeFP(ii10)
    ex1 = ar[1 + aOffset] * rmax * rmax
    ex2 = ex1 + (ar[2 + aOffset] * rmax)
    ex3 = ex2 + ar[3 + aOffset]
    dum1 = abs(ex3) * SSMath.sign(ar[-1 + aOffset])
    ex1 = ai[1 + aOffset] * rmax * rmax
    ex2 = ex1 + ai[2 + aOffset] * rmax
    ex3 = ex2 + ai[3 + aOffset]
    dum2 = abs(ex3) * SSMath.sign(ai[-1 + aOffset])
    dum1 = dum1 * SSMath.pow1(10, rr10)
    dum2 = dum2 * SSMath.pow1(10, ri10)
    cdum.re = dum1
    cdum.im = dum2
    ae = conv12(cn: cdum)
    ae[0][1] = ae[0][1] +  Helpers.makeFP(ir10)
    ae[1][1] = ae[1][1] +  Helpers.makeFP(ii10)
    x =  Helpers.makeFP(rexp) * (br[l + 1 + aOffset] - 2)
    rr10 = x * SSMath.log101(2) / SSMath.log101(10)
    ir10 = Helpers.integerValue(rr10)
    rr10 = rr10 -  Helpers.makeFP(ir10)
    x =  Helpers.makeFP(rexp) * (bi[l + 1 + aOffset] - 2)
    ri10 = x * SSMath.log101(2) / SSMath.log101(10)
    ii10 = Helpers.integerValue(ri10)
    ri10 = ri10 -  Helpers.makeFP(ii10)
    ex1 = br[1 + aOffset] * rmax * rmax
    ex2 = ex1 + br[2 + aOffset] * rmax
    ex3 = ex2 + br[3 + aOffset]
    dum1 = abs(ex3) * SSMath.sign(br[-1 + aOffset])
    ex1 = bi[1 + aOffset] * rmax * rmax
    ex2 = ex1 + bi[2 + aOffset] * rmax
    ex3 = ex2 + bi[3 + aOffset]
    dum2 = abs(ex3) * SSMath.sign(bi[-1 + aOffset])
    dum1 = dum1 * SSMath.pow1(10, rr10)
    dum2 = dum2 * SSMath.pow1(10, ri10)
    be = conv12(cn: cdum)
    be[0][1] = be[0][1] +  Helpers.makeFP(ir10)
    be[1][1] = be[1][1] +  Helpers.makeFP(ii10)
    ecpdiv(&ae, &be, &ce)
    tenmax =  Helpers.makeFP(T.greatestFiniteMagnitude.exponent - 2) * T.ln2 / T.ln10
    if lnpfq == 0 {
        do {
            c = try conv21(cae: ce)
        }
        catch {
            throw error
        }
    }
    else {
        n1 = 0
        e1 = 0
        n2 = 0
        e2 = 0
        n3 = 0
        e3 = 0
        emult(ce[0][0], ce[0][1], ce[0][0], ce[0][1], &n1, &e1)
        emult(ce[1][0], ce[1][1], ce[1][0], ce[1][1], &n2, &e2)
        eadd(n1, e1, n2, e2, &n3, &e3)
        n1 = ce[0][0]
        e1 = ce[0][1] - ce[1][1]
        x2 = ce[1][0]
        if e1 > tenmax {
            x1 = tenmax
        }
        else if (e1 < -tenmax) {
            x1 = 0
        }
        else {
            x1 = n1 * SSMath.pow1(10, e1)
        }
        if !x2.isZero {
            phi = SSMath.atan21(x2, x1)
        }
        else {
            phi = T.zero
        }
        c = Complex<T>.init(re: 0, im: 0)
        c.re = T.half * (SSMath.log1(n3) + e3 * T.ln10)
        c.im = phi
    }
}



/*
 %     ****************************************************************
 %     *                                                              *
 %     *                 SUBROUTINE CONV12                            *
 %     *                                                              *
 %     *                                                              *
 %     *  Description : Converts a number from complex notation to a  *
 %     *    form of a 2x2 real array.                                 *
 %     *                                                              *
 %     *  Subprograms called: none                                    *
 %     *                                                              *
 %     ****************************************************************
 */
fileprivate func conv12<T: SSFloatingPoint>(cn: Complex<T>) -> Array<Array<T>> {
    var cae: Array<Array<T>> = Array<Array<T>>.init(repeating: Array<T>.init(repeating: 0, count: 2), count: 2)
    cae[0][0] = cn.re
    cae[0][1] = T.zero
    while true {
        if abs(cae[0][0]) < 10 {
            while true {
                if ((abs(cae[0][0]) >= T.one) || (cae[0][0].isZero)) {
                    cae[1][0] = cn.im
                    cae[1][1] = T.zero
                    while true {
                        if (abs(cae[1][0]) < 10) {
                            while ((abs(cae[1][0]) < T.one) && !cae[1][0].isZero) {
                                cae[1][0] = cae[1][0] * 10
                                cae[1][1] = cae[1][1] - T.one
                            }
                            break;
                        }
                        else {
                            cae[1][0] = cae[1][0] / 10
                            cae[1][1] = cae[1][1] + T.one
                        }
                    }
                    break;
                }
                else {
                    cae[0][0] = cae[0][0] * 10
                    cae[0][1] = cae[0][1] - T.one
                }
            }
            break;
        }
        else {
            cae[0][0] = cae[0][0] / 10
            cae[0][1] = cae[0][1] + T.one
        }
    }
    return cae
}
/*
 %     ****************************************************************
 %     *                                                              *
 %     *                 SUBROUTINE CONV21                            *
 %     *                                                              *
 %     *                                                              *
 %     *  Description : Converts a number represented in a 2x2 real   *
 %     *    array to the form of a complex number.                    *
 %     *                                                              *
 %     *  Subprograms called: none                                    *
 %     *                                                              *
 %     ****************************************************************
 */
fileprivate func conv21<T: SSFloatingPoint>(cae: Array<Array<T>>) throws -> Complex<T> {
    var cn: Complex<T> = Complex<T>.init(re: 0, im: 0)
    cn.re = 0
    cn.im = 0
    let tenmax:T =  Helpers.makeFP(T.greatestFiniteMagnitude.exponent - 2) * T.ln2 / T.ln10
    if cae[0][1] > tenmax || cae[1][1] > tenmax {
        #if os(macOS) || os(iOS)
        if #available(macOS 10.12, iOS 13, *) {
            os_log("value of exponent required for summation: pFq", log: .log_stat, type: .error)
        }
        
        #endif
        throw SSSwiftyStatsError.init(type: .maxExponentExceeded, file: #file, line: #line, function: #function)
    }
    else if cae[1][1] < -tenmax {
        cn.re = cae[0][0] * SSMath.pow1(10, cae[0][1])
        cn.im = 0
    }
    else {
        cn.re = cae[0][0] * SSMath.pow1(10, cae[0][1])
        cn.im = cae[1][0] * SSMath.pow1(10, cae[1][1])
    }
    return cn
}


/*
 %     ****************************************************************
 %     *                                                              *
 %     *                 SUBROUTINE ECPDIV                            *
 %     *                                                              *
 %     *                                                              *
 %     *  Description : Divides two numbers and returns the solution. *
 %     *    All numbers are represented by a 2x2 array.               *
 %     *                                                              *
 %     *  Subprograms called: EADD, ECPMUL, EDIV, EMULT               *
 %     *                                                              *
 %     ****************************************************************
 */
fileprivate func ecpdiv<T: SSFloatingPoint>(_ a: inout Array<Array<T>>, _ b: inout Array<Array<T>>, _ c: inout Array<Array<T>>) {
    var b2: Array<Array<T>> = Array<Array<T>>.init(repeating: Array<T>.init(repeating: 0, count: 2), count: 2)
    var c2: Array<Array<T>> = Array<Array<T>>.init(repeating: Array<T>.init(repeating: 0, count: 2), count: 2)
    var e1: T = 0
    var e2: T = 0
    var e3: T = 0
    var n1: T = 0
    var n2:T = 0
    var n3: T = 0
    b2[0][0] = b[0][0]
    b2[0][1] = b[0][1]
    b2[1][0] = -T.one * b[1][0]
    b2[1][1] = b[1][1]
    ecpmul(&a, &b2, &c2)
    emult(b[0][0], b[0][1], b[0][0], b[0][1], &n1, &e1)
    emult(b[1][0], b[1][1], b[1][0], b[1][1], &n2, &e2)
    eadd(n1, e1, n2, e2, &n3, &e3)
    ediv(c2[0][0], c2[0][1], n3, e3, &n1, &e1)
    ediv(c2[1][0], c2[1][1], n3, e3, &n2, &e2)
    c[0][0] = n1
    c[0][1] = e1
    c[1][0] = n2
    c[1][1] = e2
    
}

/*
 %     ****************************************************************
 %     *                                                              *
 %     *                 SUBROUTINE EMULT                             *
 %     *                                                              *
 %     *                                                              *
 %     *  Description : Takes one base and exponent and multiplies it *
 %     *    by another numbers base and exponent to give the product  *
 %     *    in the form of base and exponent.                         *
 %     *                                                              *
 %     *  Subprograms called: none                                    *
 %     *                                                              *
 %     ****************************************************************
 */
fileprivate func emult<T: SSFloatingPoint>(_ n1: T, _ e1: T, _ n2: T, _ e2: T, _ nf: inout T, _ ef: inout T) {
    nf = n1 * n2
    ef = e1 + e2
    if abs(nf) >= 10 {
        nf = nf / 10
        ef = ef + T.one
    }
}

/*
 %     ****************************************************************
 %     *                                                              *
 %     *                 SUBROUTINE EDIV                              *
 %     *                                                              *
 %     *                                                              *
 %     *  Description : returns the solution in the form of base and  *
 %     *    exponent of the division of two exponential numbers.      *
 %     *                                                              *
 %     *  Subprograms called: none                                    *
 %     *                                                              *
 %     ****************************************************************
 */
fileprivate func ediv<T: SSFloatingPoint>(_ n1: T, _ e1: T, _ n2: T, _ e2: T, _ nf: inout T, _ ef: inout T) {
    nf = n1 / n2
    ef = e1 - e2
    if abs(nf) < T.one && !nf.isZero {
        nf = nf * 10
        ef = ef - T.one
    }
}



/*
 %     ****************************************************************
 %     *                                                              *
 %     *                 SUBROUTINE ECPMUL                            *
 %     *                                                              *
 %     *                                                              *
 %     *  Description : Multiplies two numbers which are each         *
 %     *    represented in the form of a two by two array and returns *
 %     *    the solution in the same form.                            *
 %     *                                                              *
 %     *  Subprograms called: EMULT, ESUB, EADD                       *
 %     *                                                              *
 %     ****************************************************************
 
 */
fileprivate func ecpmul<T: SSFloatingPoint>(_ a: inout Array<Array<T>>, _ b: inout Array<Array<T>>, _ c: inout Array<Array<T>>) {
    var c2: Array<Array<T>> = Array<Array<T>>.init(repeating: Array<T>.init(repeating: 0, count: 2), count: 2)
    var e1: T = 0
    var e2: T = 0
    var n1: T = 0
    var n2:T = 0
    var n3: T = 0
    var e3: T = 0
    emult(a[0][0], a[0][1], b[0][0], b[0][1], &n1, &e1)
    emult(a[1][0], a[1][1], b[1][0], b[1][1], &n2, &e2)
    esub(n1, e1, n2, e2, &n3, &e3)
    c2[0][0] = n3
    c2[0][1] = e3
    emult(a[0][0], a[0][1], b[1][0], b[1][1], &n1, &e1)
    emult(a[1][0], a[1][1], b[0][0], b[0][0], &n2, &e2)
    eadd(n1, e1, n2, e2, &n3, &e3)
    c[1][0] = n3
    c[1][1] = e3
    c[0][0] = c2[0][0]
    c[0][1] = c2[0][1]
    
}

/*
 %     ****************************************************************
 %     *                                                              *
 %     *                 SUBROUTINE ESUB                              *
 %     *                                                              *
 %     *                                                              *
 %     *  Description : Returns the solution to the subtraction of    *
 %     *    two numbers in the form of base and exponent.             *
 %     *                                                              *
 %     *  Subprograms called: EADD                                    *
 %     *                                                              *
 %     ****************************************************************
 */
fileprivate func esub<T: SSFloatingPoint>(_ n1: T, _ e1: T, _ n2: T, _ e2: T, _ nf: inout T, _ ef: inout T) {
    let dummy: T = -T.one * n2
    eadd(n1, e1, dummy, e2, &nf, &ef)
}

/*
 %     ****************************************************************
 %     *                                                              *
 %     *                 SUBROUTINE EADD                              *
 %     *                                                              *
 %     *                                                              *
 %     *  Description : Returns the sum of two numbers in the form    *
 %     *    of a base and an exponent.                                *
 %     *                                                              *
 %     *  Subprograms called: none                                    *
 %     *                                                              *
 %     ****************************************************************
 */
fileprivate func eadd<T: SSFloatingPoint>(_ n1: T, _ e1: T, _ n2: T, _ e2: T, _ nf: inout T, _ ef: inout T) {
    let ediff: T = e1 - e2
    if (ediff > 36) {
        nf = n1
        ef = e1
    }
    else if (ediff < -36) {
        nf = n2
        ef = e2
    }
    else {
        nf = n1 * SSMath.pow1( Helpers.makeFP(10), ediff) + n2
        ef = e2
        while true {
            if (abs(nf) < 10) {
                while ((abs(nf) < T.one) && (!nf.isZero)) {
                    nf = nf * 10
                    ef = ef - T.one
                }
                break;
            }
            else {
                nf = nf / 10
                ef = ef + T.one
            }
        }
    }
}

/*
 %     ****************************************************************
 %     *                                                              *
 %     *                   FUNCTION IPREMAX                           *
 %     *                                                              *
 %     *                                                              *
 %     *  Description : Predicts the maximum term in the pFq series   *
 %     *    via a simple scanning of arguments.                       *
 %     *                                                              *
 %     *  Subprograms called: none.                                   *
 %     *                                                              *
 %     ****************************************************************
 */
fileprivate func ipremax<T: SSFloatingPoint>(a: Array<Complex<T>>, b: Array<Complex<T>>, ip: Int, iq: Int, z: Complex<T>) throws -> Int {
    var expon, xl, xmax, xterm: T
    var cex1: Complex<T>
    var cex2: Complex<T>
    var cex3: Complex<T>
    var ex1: T
    var ex2: T
    expon = 0
    xl = 0
    xmax = 0
    xterm = 0
    var ans: Int = 0
    for j in stride(from: 1, through: 100000, by: 1) {
        expon = T.zero
        xl =  Helpers.makeFP(j)
        for i in stride(from: 1, through: ip, by: 1) {
            cex1 = a[i - 1] &++ xl
            cex2 = cex1 &-- T.one
            cex3 = a[i - 1] &-- T.one
            expon = expon + (factor(cex2)).re - factor(cex3).re
        }
        for i in stride(from: 1, to: iq, by: 1) {
            cex1 = b[i - 1] &++ xl
            cex2 = cex1 &-- T.one
            cex3 = b[i - 1] &-- T.one
            expon = expon - factor(cex1).re + factor(cex2).re
        }
        ex1 = xl * SSMath.ComplexMath.log(z).re
        ex2 = expon + ex1
        expon = ex2 - factor(Complex<T>(xl)).re
        xmax = SSMath.log101(SSMath.exp1(T.one)) * expon
        if ((xmax < xterm) && (j > 2)) {
            ans = j
            break
        }
        xterm = max(xmax, xterm)
    }
    if ans == 0 {
        #if os(macOS) || os(iOS)
        if #available(macOS 10.12, iOS 13, *) {
            os_log("Max exponent not found", log: .log_stat, type: .error)
        }
        #endif
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    else {
        return ans
    }
}

/*
 %     ****************************************************************
 %     *                                                              *
 %     *                   FUNCTION FACTOR                            *
 %     *                                                              *
 %     *                                                              *
 %     *  Description : This function is the log of the factorial.    *
 %     *                                                              *
 %     *  Subprograms called: none.                                   *
 %     *                                                              *
 %     ****************************************************************
 %
 */
fileprivate func factor<T: SSFloatingPoint>(_ z: Complex<T>) -> Complex<T> {
    var pi: T = 0
    var f: Complex<T>
    if (((z.re == T.one) && (z.im.isZero)) || z.abs.isZero) {
        f = Complex<T>.init(re: T.zero, im: T.zero)
        return f
    }
    else {
        pi = T.pi
        var e1: T
        var e3, e4: Complex<T>
        e1 = (T.half * SSMath.log1(2 * pi))
        e3 = (z &++ T.half)
        e4 = (1 &% (12 &** z))
        f =  e1 &++ e3 &** SSMath.ComplexMath.log(z) &-- z &++ e4;
        e3 = (1 &% (30 &** z &** z))
        e4 = (2 &% (7 &** z &** z))
        f = f &** (1 &-- e3 &** (1 &-- e4))
        return f
    }
}


/*
 %     ****************************************************************
 %     *                                                              *
 %     *                   FUNCTION CGAMMA                            *
 %     *                                                              *
 %     *                                                              *
 %     *  Description : Calculates the complex gamma function.  Based *
 %     *     on a program written by F.A. Parpia published in Computer*
 %     *     Physics Communications as the `GRASP2' program (public   *
 %     *     domain).                                                 *
 %     *                                                              *
 %     *                                                              *
 %     *  Subprograms called: none.                                   *
 %     *                                                              *
 %     *****************************************************************/
fileprivate func cgamma<T: SSFloatingPoint>(_ arg: Complex<T>, lnpfq: Int) throws -> Complex<T> {
    var argi: T = 0
    var argr: T = 0
    var argui: T = 0
    var argui2: T = 0
    var argum: T = 0
    var argur: T = 0
    var argur2: T = 0
    var clngi: T = 0
    var clngr: T = 0
    var diff: T = 0
    var dnum: T = 0
    var expmax: T = 0
    var fac: T = 0
    var facneg: T = 0
    var hlntpi: T = 0
    var obasq: T = 0
    var obasqi: T = 0
    var obasqr: T = 0
    var ovlfac: T = 0
    var ovlfi: T = 0
    var ovlfr: T = 0
    var pi: T = 0
    var precis: T = 0
    var tenmax: T = 0
    var tenth: T = 0
    var termi: T = 0
    var termr: T = 0
    var twoi: T = 0
    var zfaci: T = 0
    var zfacr: T = 0
    var ex1: T
    var ex2: T
    var ex3: T
    var first : Bool = true
    var negarg : Bool = true
    var fn: Array<T> = [1,-1, 1,-1, 5, -691, 7, -3617, 43867, -174611, 854513, -236364091, 8553103, -23749461029, 8615841276005, -7709321041217, 2577687858367, -26315271553053477373,2929993913841559,-261082718496449122051, 1520097643918070802691,27833269579301024235023]
    let fd: Array<T> = [6,30,42,30,66,2730,6,510,789,330,138,2730, 6, 870,14322,510,6,1919190,6,13530,1806,960]
    var ans: Complex<T> = Complex<T>.init(re: 0, im: 0)
    hlntpi =  Helpers.makeFP(1)
    tenth =  Helpers.makeFP(0.1)
    argr = arg.re
    argi = arg.im
    if first {
        pi = 4 * SSMath.atan1(T.one)
    }
    tenmax =  Helpers.makeFP(T.greatestFiniteMagnitude.exponent - 1) * T.ln2 / T.ln10
    dnum = SSMath.pow1(tenth, tenmax)
    expmax = -SSMath.log1(dnum)
    precis = T.one
    precis = precis / 2
    dnum = precis + T.one
    while dnum > T.one {
        precis = precis / 2
        dnum = precis + T.one
    }
    precis = SSMath.pow1(2, precis)
    hlntpi = T.half * SSMath.log1(2 * pi)
    for i in stride(from: 1, through: fd.count, by: 1) {
        fn[i] = fn[i - 1] / fd[i - 1]
        twoi = 2 *  Helpers.makeFP(i)
        fn[i - 1] = fn[i - 1] / (twoi * (twoi - T.one))
    }
    first = false
    
    if argi.isZero {
        if argr <= 0 {
            diff = abs(round(argr) - argr)
            if diff <= 2 * precis {
                #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("Argument to close to a pols, mo imaginary part", log: .log_stat, type: .error)
                }
                #endif
                throw SSSwiftyStatsError.init(type: .singularity, file: #file, line: #line, function: #function)
            }
            else {
                if lnpfq == 1 {
                    ans.re = SSMath.lgamma1(argr)
                }
                else {
                    ans.re = SSMath.tgamma1(argr)
                }
                argum = pi / (-argr * SSMath.sin1(pi * argr))
                if (argum < 0) {
                    argum = -argum
                    clngi = pi
                }
                else {
                    clngi = 0
                }
                facneg = SSMath.log1(argum)
                argur = -argr
                negarg = true
            }
        }
        else {
            clngi = 0
            argur = argr
            negarg = false
        }
        ovlfac = T.one
        while argur < 10 {
            ovlfac = ovlfac * argur;
            argur = argur + T.one
        }
        ex1 = (argur - T.half)
        ex2 = ex1 * SSMath.log1(argur)
        ex3 = ex2 - argur
        clngr = ex3 + hlntpi
        fac = argur
        obasq = T.one / (argur * argur)
        for i in stride(from: 1, through: fn.count, by: 1) {
            fac = fac * obasq
            clngr = clngr + fn[i - 1] * fac
        }
        
        clngr = clngr - SSMath.log1(ovlfac)
        if negarg {
            clngr = facneg - clngr
        }
    }
    else {
        argur = argr
        argui = argi
        argui2 = argui * argui
        ovlfr = T.one
        ovlfi = T.zero
        ex1 = argur * argur
        argum = sqrt(ex1 + argui2)
        while (argum < 10) {
            termr = ovlfr * argur - ovlfi * argui
            termi = ovlfr * argui + ovlfi * argur
            ovlfr = termr
            ovlfi = termi
            argur = argur + T.one
            argum = sqrt(argur * argur + argui2)
        }
        argur2 = argur * argur
        termr = T.half * SSMath.log1(argur2 + argui2)
        termi = SSMath.atan21(argui, argur)
        ex1 = (argur - T.half) * termr
        ex2 = argui * termi
        ex3 = argur + hlntpi
        clngr = ex1 - ex2 - ex3
        ex1 = (argur - T.half) * termi
        ex2 = argui * termr
        clngi = ex1 + ex2 - argui
        fac = SSMath.pow1(argur2 + argui2, -2)
        obasqr = (argur2 - argui2) * fac
        obasqi = -2 * argur * argui * fac
        zfacr = argur
        zfaci = argui
        for i in stride(from: 1, through: fn.count, by: 1) {
            termr = zfacr * obasqr - zfaci * obasqi
            termi = zfacr * obasqi + zfaci * obasqr
            fac = fn[i - 1]
            clngr = clngr + termr * fac
            clngi = clngi + termi * fac
            zfacr = termr
            zfaci = termi
        }
        ex1 = ovlfr * ovlfr
        ex2 = ovlfi * ovlfi
        ex3 = ex1 + ex2
        clngr = clngr - T.half * SSMath.log1(ex3)
        clngi = clngi - SSMath.atan21(ovlfi, ovlfr)
        if lnpfq == 1 {
            ans.re = clngr
            ans.im = clngi
            return ans
        }
        else {
            if ((clngr <= expmax) && (clngr >= -expmax)) {
                fac = SSMath.exp1(clngr)
            }
            else {
                ans = Complex<T>.nan
            }
            ans.re = fac * SSMath.cos1(clngi)
            ans.im = fac * SSMath.sin1(clngi)
        }
    }
    return ans
}

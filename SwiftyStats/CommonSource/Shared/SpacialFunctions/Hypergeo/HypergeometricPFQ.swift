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
import Accelerate
// naive implementation

struct Complex<T: SSFloatingPoint> {
    var re: T = 0
    var im: T = 0
}

public func h2f2<T: SSFloatingPoint & Codable>(a1: T, a2: T, b1: T, b2: T, z: T) -> T {
    var sum1, s: T
    let tol: T = T.ulpOfOne
    let maxIT: T = 1000
    var k: T = 0
    sum1 = 0
    s = 0
    var p1: T = 0
    var p2: T = 0
    var temp1: T = 0
    let lz: T = log1(z)
    var kz: T
    while k < maxIT {
        p1 = lpochhammer(x: a1, n: k) + lpochhammer(x: a2, n: k)
        p2 = lpochhammer(x: b1, n: k) + lpochhammer(x: b2, n: k)
        kz = k * lz
        temp1 = p1 + kz - p2
        temp1 = temp1 - logFactorial(integerValue(k))
        s = exp1(temp1)
        if abs((sum1 - (s + sum1))) < tol {
            break
        }
        sum1 = sum1 + exp1(temp1)
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
func bits<T: SSFloatingPoint>() -> T {
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
let aOffset = 1


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
func aradd<T: SSFloatingPoint>(a: inout Array<T>, b: inout Array<T>, c: inout Array<T>, z: inout Array<T>, l: Int, rmax: T) {
    let one: T = T.one
    let zero: T = T.zero
    let half: T = T.half
    var ediff, I, J,i: Int
    var goon300: Int = 1
    var goon190: Int = 1
    I = 0
    ediff = 0
    for i in stride(from: 0, through: l + 1, by: 1) {
        z[i + aOffset] = zero
    }
    ediff = integerValue(round(a[l + 1 + aOffset] - b[l + 1 + aOffset]))
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
//                    J = j
                }
                /// TODO: ???
                for j in stride(from: l + 2 - 1, through: l, by: -1) {
                    z[j + aOffset] = 0
                }
                z[l + 1 + aOffset] = z[l + 1 + aOffset] - makeFP(i) + 1
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
    z[l + 1 + aOffset] = z[l + 1 + aOffset] - makeFP(i) + 1
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
func arsub<T: SSFloatingPoint>(a: inout Array<T>, b: inout Array<T>, c: inout Array<T>, wk1: inout Array<T>, wk2: inout Array<T>, l: Int, rmax: T) {
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
func armult<T: SSFloatingPoint>(a: inout Array<T>, b: T, c: inout Array<T>, z: inout Array<T>, l: Int, rmax: T) {
    let eps: T = T.ulpOfOne
    let one: T = T.one
    let half: T = T.half
    var b2: T = 0
    var carry: T = 0
    z[-1 + aOffset] = sign(b) * a[-1 + aOffset]
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
                carry = integerPart(z[i + aOffset] / rmax)
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
                carry = integerPart(z[1 + aOffset] / rmax)
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
func cmpadd<T: SSFloatingPoint>(ar: inout Array<T>, ai: inout Array<T>, br: inout Array<T>, bi: inout Array<T>, cr: inout Array<T>, ci: inout Array<T>, wk1: inout Array<T>, l: Int, rmax: T) {
    aradd(a: &ar, b: &br, c: &cr, z: &wk1, l: l, rmax: rmax)
    aradd(a: &ai, b: &bi, c: &ci, z: &wk1, l: l, rmax: rmax)
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
func cmpsub<T: SSFloatingPoint>(ar: inout Array<T>, ai: inout Array<T>, br: inout Array<T>, bi: inout Array<T>, cr: inout Array<T>, ci: inout Array<T>, wk1: inout Array<T>, wk2: inout Array<T>, l: Int, rmax: T) {
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
func cmpmul<T: SSFloatingPoint>(ar: inout Array<T>,ai: inout Array<T>,br: T,bi: T,cr: inout Array<T>,ci: inout Array<T>,wk1: inout Array<T>,wk2: inout Array<T>,cr2: inout Array<T>,d1: inout Array<T>,d2: inout Array<T>,wk6: inout Array<T>,l: Int,rmax: T) {
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
func arydiv<T: SSFloatingPoint>(ar: inout Array<T>,ai: inout Array<T>,br: inout Array<T>,bi: inout Array<T>,c: Complex<T>,l: Int,lnpfq: Int,rmax: T,ibit: Int) {
    let one: T = T.one
    let zero: T = T.zero
    let half: T = T.half
    var cdum: Complex<T> = Complex<T>.init()
    var  dum1 , dum2 , e1 , e2 ,e3 , n1 , n2 , n3 , phi , ri10 , rr10 , tenmax , x ,x1 , x2: T
    var ii10 , ir10 , itnmax , rexp: Int
    rexp = ibit / 2
    x = makeFP(rexp) * (ai[l + aOffset + 1] - 2)
    rr10 = x * log1(2) / log101(10)
    ir10 = integerValue(rr10)
    rr10 = rr10 - makeFP(ir10)
    x = makeFP(rexp) * (ai[l + 1 + aOffset] - 2)
    ri10 = x * log101(2) / log101(10)
    ii10 = integerValue(ri10)
    ri10 = ri10 - makeFP(ii10)
    dum1 = (abs(ar[1 + aOffset] * rmax * rmax + ar[2 + aOffset] * rmax + ar[3 + aOffset]) * sign(ar[-1 + aOffset]))
    dum2 = (abs(ai[1 + aOffset] * rmax * rmax + ai[2 + aOffset] * rmax + ai[3 + aOffset]) * sign(ai[-1 + aOffset]))
    dum1 = dum1 * pow1(rr10, 10)
    dum2 = dum2 * pow1(ri10, 10)
    cdum.re = dum1
    cdum.im = dum2
}

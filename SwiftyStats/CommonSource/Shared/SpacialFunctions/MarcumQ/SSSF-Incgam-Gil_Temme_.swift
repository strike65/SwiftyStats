//
//  Created by VT on 05.09.18.
//  Copyright © 2018 strike65. All rights reserved.
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

fileprivate let EPSS = "1.0e-15"

//FOUNDATION_EXTERN double SQRT2OPI
//FOUNDATION_EXTERN double EULERGAMMA
//FOUNDATION_EXTERN double SQRTPI
//FOUNDATION_EXTERN double PIL
//FOUNDATION_EXTERN double LOGSQRT2PI
//FOUNDATION_EXTERN double SQRT2PI
//FOUNDATION_EXTERN double TWOPI
//FOUNDATION_EXTERN double OOSQRTPI
//FOUNDATION_EXTERN double SQRTTWO


fileprivate func alfa<T: SSFloatingPoint>(_ x: T) -> T {
    var lnx, res: T
    lnx = log1(x)
    let dwarf = T.ulpOfOne * 10
    let const = log1(T.half)
    if (x > makeFP(0.25)) {
        res = x + makeFP(0.25)
    } else if (x >= dwarf) {
        res = const / lnx
    } else {
        res = const / log1(dwarf)
    }
    return res
}

internal func gamstar<T: SSFloatingPoint>(_ x: T) -> T {
    //    !  {gamstar(x)=exp(stirling(x)), x>0 or }
    //    !  {gamma(x)/(exp(-x+(x-0.5)*ln(x))/sqrt(2pi)}
    var res: T
    if (x >= 3) {
        res = exp1(stirling(x))
    } else if (x > 0) {
        res = gamma1(x) / (exp1(-x + (x - T.half) * log1(x)) * T.sqrtpi)
    } else {
        res = T.infinity
    }
    return res
}


internal func stirling<T:SSFloatingPoint>(_ x: T) -> T {
    //    !{Stirling series, function corresponding with}
    //    !{asymptotic series for log(gamma(x))}
    //    !{that is:  1/(12x)-1/(360x**3)... x>= 3}
    var res, z: T
    var a: Array<T> = Array<T>.init(repeating: 0, count: 18)
    var c: Array<T> = Array<T>.init(repeating: 0, count: 7)
    
    var ex1, ex2, ex3, ex4, ex5, ex6: T
    let dwarf = T.ulpOfOne * 10
    if (x < dwarf) {
        res = T.greatestFiniteMagnitude
    } else if (x < 1) {
        ex1 = (x + T.half) * log1(x)
        ex2 = ex1 + x - T.lnsqrt2pi
        res = lgamma1(x + 1) - ex2
//        res = lgamma1(x + 1) - (x + T.half) * log1(x) + x - T.lnsqrt2pi
    } else if (x < 2) {
        res = lgamma1(x) - (x - T.half) * log1(x) + x - T.lnsqrt2pi
    } else if (x < 3) {
        ex1 = (x - T.half) * log1(x) + x
        res = lgamma1(x - 1) - ex1 - T.lnsqrt2pi + log1(x - 1)
    } else if (x < 12) {
        a[0] = makeFP(1.996379051590076518221)
        a[1] = makeFP(-0.17971032528832887213e-2)
        a[2] = makeFP(0.131292857963846713e-4)
        a[3] = makeFP(-0.2340875228178749e-6)
        a[4] = makeFP(0.72291210671127e-8)
        a[5] = makeFP(-0.3280997607821e-9)
        a[6] = makeFP(0.198750709010e-10)
        a[7] = makeFP(-0.15092141830e-11)
        a[8] = makeFP(0.1375340084e-12)
        a[9] = makeFP(-0.145728923e-13)
        a[10] = makeFP(0.17532367e-14)
        a[11] = makeFP(-0.2351465e-15)
        a[12] = makeFP(0.346551e-16)
        a[13] = makeFP(-0.55471e-17)
        a[14] = makeFP(0.9548e-18)
        a[15] = makeFP(-0.1748e-18)
        a[16] = makeFP(0.332e-19)
        a[17] = makeFP(-0.58e-20)
        z = 18 / (x * x) - 1
        res = chepolsum(17,z,a) / (12 * x)
    } else {
        z = 1 / (x * x)
        if (x < 1000) {
            c[0] = makeFP(0.25721014990011306473e-1)
            c[1] = makeFP(0.82475966166999631057e-1)
            c[2] = makeFP(-0.25328157302663562668e-2)
            c[3] = makeFP(0.60992926669463371e-3)
            c[4] = makeFP(-0.33543297638406e-3)
            c[5] = makeFP(0.250505279903e-3)
            c[6] = makeFP(0.30865217988013567769)
            ex1 = (c[5] * z) + c[4]
            ex2 = (ex1 * z) + c[3]
            ex3 = (ex2 * z) + c[2]
            ex4 = (ex3 * z) + c[1]
            ex5 = (ex4 * z) + c[0]
            ex6 = ex5 / (c[6] + z) / x
//            res=((((((c[5]*z + c[4])*z + c[3])*z + c[2])*z + c[1])*z + c[0])/(c[6]+z)/x);
            res = ex6
        } else {
            ex1 = -z / 1680 + 1 / 1260
            ex2 = ex1 * z - 1/360
            ex3 = ex2 * z + 1/12
            res = ex3 / x
//            res=(((-z / 1680.0 + 1.0/1260.0)*z-1.0/360.0)*z+1.0/12.0)/x;
        }
    }
    return res
}

internal func exmin1minx<T: SSFloatingPoint>(_ x: T,_ eps: T) -> T {
    // !{computes (exp(x)-1-x)/(0.5*x*x) }
    var t, t2, y: T
    var ex1, ex2: T

    if(x.isZero){
        y = 1
    } else if (abs(x) > makeFP(0.9)) {
        y = (exp1(x) - 1 - x) / (x * x / 2)
    } else {
        t = sinh1(x / 2)
        t2 = t * t
        ex1 = 2 * t * sqrt(1 + t2)
        ex2 = x * x / 2
//        y=(2 * t2 + (2 * t * sqrt(1 + t2) - x)) / (x * x / 2);
        y = (2 * t2 + (ex1 - x)) / (ex2)
    }
    return y
}

internal func lnec<T: SSFloatingPoint>(_ x: T) -> T {
    //IMPLICIT NONE
    var ln1, y0, z, e2, r, s: T
    z = log1p1(x)
    y0 = z - x
    e2 = exmin1minx(z, T.ulpOfOne)
    s = e2 * z * z / 2
    r = (s + y0) / (s + 1 + z)
    ln1 = y0 - r * (6 - r) / (6 - 4 * r)
    return ln1
}


internal func dompart<T: SSFloatingPoint>(_ a: T,_ x: T,_ qt: Bool) -> T {
    //! dompart is approx. of  x^a * exp(-x) / gamma(a+1)
    var lnx, c, dp, la, mu, r: T
    lnx = log1(x)
    if (a <= 1) {
        r = -x + a * lnx
    } else {
        if (x == a) {
            r = 0
        } else {
            la = x / a
            r = a * (1 - la + log1(la))
        }
        r = r - T.half * log1(2 * T.pi * a)
    }
    if (r < -300) {
        dp = 0
    } else {
        dp = exp1(r)
    }
    if (qt) {
        return dp
    } else {
        if ((a < 3) || (x < makeFP(0.2))) {
            dp = exp1(a * lnx - x) / tgamma1( a + 1)
        } else {
            mu = (x - a) / a
            c = lnec(mu)
            if ((a * c) > log1(T.greatestFiniteMagnitude)) {
                dp = -100
            } else if ((a * c) < log1(T.ulpOfOne * 10)) {
                dp = 0
            }
            else {
                dp = exp1(a * c)/(sqrt(a * 2 * T.pi) * gamstar(a))
            }
        }
    }
    return dp
}

fileprivate func chepolsum<T: SSFloatingPoint>(_ n: Int, _ x: T,_ a: [T]) -> T {
    var res: T
    var h, r, s, tx: T
    //!{a[0]/2+a[1]T1(x)+...a[n]Tn(x) series of Chebychev polynomials}
    if (n == 0) {
        res = a[0] / 2
    } else if (n == 1) {
        res = a[0] / makeFP(2.08) + a[1] * x
    } else {
        tx = x + x
        r = a[n]
        h = a[n-1] + r * tx
        for k in stride(from: n - 2, through: 1, by: -1) {
            s = r
            r = h
            h = a[k] + r * tx - s
        }
        res = a[0] / 2 - r + h * x
    }
    return res
}


//MODULE IncgamFI
//IMPLICIT NONE
//INTEGER, PARAMETER  :: r8 = KIND(0.0d0)
//PRIVATE
//PUBLIC  :: incgam, invincgam, loggam, gamma, dompart
//CONTAINS
internal func incgam<T: SSFloatingPoint>(a: T, x: T) -> (p: T, q: T, ierr: Int) {
    //SUBROUTINE incgam(a,x,p,q,ierr)
    //! -------------------------------------------------------------
    //! Calculation of the incomplete gamma functions ratios P(a,x)
    //! && Q(a,x).
    //! -------------------------------------------------------------
    //! Inputs:
    //!   a ,    argument of the functions
    //!   x ,    argument of the functions
    //! Outputs:
    //!   p,     function P(a,x)
    //!   q,     function Q(a,x)
    //!   ierr , error flag
    //!          ierr=0, computation succesful
    //!          ierr=1, overflow/underflow problems. The function values
    //!          (P(a,x) && Q(a,x)) are set to zero.
    //! ----------------------------------------------------------------------
    //! Authors:
    //!  Amparo Gil    (U. Cantabria, San && r, Spain)
    //!                 e-mail: amparo.gil@unican.es
    //!  Javier Segura (U. Cantabria, San && r, Spain)
    //!                 e-mail: javier.segura@unican.es
    //!  Nico M. Temme (CWI, Amsterdam, The Nether && )
    //!                 e-mail: nico.temme@cwi.nl
    //! -------------------------------------------------------------
    //!  References: "Efficient && accurate algorithms for
    //!  the computation && inversion of the incomplete gamma function ratios",
    //!  A. Gil, J. Segura && N.M. Temme. SIAM J Sci Comput (2012)
    //! -------------------------------------------------------------------
    var p, q: T
    p = 0
    q = 0
    var lnx, dp: T
    var ierr: Int = 0
    let dwarf = T.ulpOfOne * 10
    if (x < dwarf) {
        lnx = log1(dwarf)
    } else {
        lnx = log1(x)
    }
    if (a > alfa(x)) {
        dp = dompart(a,x,false)
        if (dp < 0) {
            ierr = 1
            p = 0
            q = 0
        } else {
            if ((x < makeFP(0.3) * a) || (a < 12)) {
                p = ptaylor(a,x,dp)
            } else {
                p = pqasymp(a,x,dp,true)
            }
            q = 1 - p
        }
    }
    else {
        if (a < -dwarf/lnx) {
            q=0
        } else if (x < 1) {
            dp = dompart(a,x,true)
            if (dp < 0) {
                ierr = 1
                q = 0
                p = 0
            } else {
                q = qtaylor(a,x,dp)
                p = 1 - q
            }
        } else {
            dp = dompart(a,x,false)
            if (dp < 0) {
                ierr = 1
                p = 0
                q = 0
            } else {
                if ((x > makeFP(1.5) * a) || (a < 12)) {
                    q = qfraction(a,x,dp)
                } else {
                    q = pqasymp(a,x,dp,false)
                    if (dp.isZero) {
                        q = 0
                    }
                }
                p = 1 - q
            }
        }
    }
    return (p: p, q: q, ierr: ierr)
}
//
fileprivate func invincgam<T: SSFloatingPoint>(_ a: T,_ p: inout T,_ q: inout T,_ xr: inout T,_ ierr: inout Int) {
    //! -------------------------------------------------------------
    //! invincgam computes xr in the equations P(a,xr)=p && Q(a,xr)=q
    //! with a as a given positive parameter.
    //! In most cases, we invert the equation with min(p,q)
    //! -------------------------------------------------------------
    //! Inputs:
    //!   a ,    argument of the functions
    //!   p,     function P(a,x)
    //!   q,     function Q(a,x)
    //! Outputs:
    //!   xr   , soluction of the equations P(a,xr)=p && Q(a,xr)=q
    //!          with a as a given positive parameter.
    //!   ierr , error flag
    //!          ierr=0,  computation succesful
    //!          ierr=-1, overflow problem in the computation of one of the
    //!                   gamma factors before starting the Newton iteration.
    //!                   The initial approximation to the root is given
    //!                   as output.
    //!          ierr=-2, the number of iterations in the Newton method
    //!                   reached the upper limit N=15. The last value
    //!                   obtained for the root is given as output.
    //! ------------------------------------------------------------------
    var porq, s, dlnr, logr, r, a2, a3, a4, ap1, ap12, ap13, ap14,ap2, ap22, x0, b, eta, L, L2, L3, L4,b2, b3, x, x2, t, px, qx, y, fp: T
    var ck: Array<T> = Array<T>.init(repeating: 0, count: 6)
    var ex1, ex2, ex3, ex4, ex5, ex6, ex7, ex8, ex9, ex10, ex11, ex12, ex13: T
    eta = 0
    var n, m: Int
    var pcase: Bool
    ierr = 0
    if (p < T.half) {
        pcase = true
        porq = p
        s = -1
    } else {
        pcase = false
        porq = q
        s = 1
    }
    logr = (1 / a) * (log1(p) + loggam(a + 1))
    if (logr < log1(makeFP(0.2) * ( 1 + a))) {
        r = exp1(logr)
        m = 0
        a2 = a * a
        a3 = a2 * a
        a4 = a3 * a
        ap1 = a + 1
        ap12 = (a + 1) * ap1
        ap13 = (a + 1) * ap12
        ap14 = ap12 * ap12
        ap2 = a + 2
        ap22 = ap2 * ap2
        ck[1] = 1
        ck[2] = 1 / (1 + a)
        ex1 = 3 * a + 5
        ex2 = ap12 * (a + 2)
        //        ck[3]=0.5*(3*a+5)/(ap12*(a+2));
        ck[3] = T.half * ( ex1 ) / (ex2)
        ex1 = 31 + 8 * a2 + 33 * a
        ex2 = ap13 * ap2 * (a + 3)
        //        ck[4]= (1.0/3.0)*(31+8*a2+33*a)/(ap13*ap2*(a+3));
        ck[4] = (1 / 3) * ( ex1 ) / (ex2)
        ex1 = 2888
        ex2 = ex1 + 1179 * a3
        ex3 = ex2 + 125 * a4
        ex4 = ex3 + 3971 * a2
        ex5 = ex4 + 5661 * a
        ex6 = ap14 * ap22
        ex7 = (a + 3) * (a + 4)
        ck[5] = (1 / 24) * (ex5) / (ex6 * ex7)
        //        ck[5]= (1.0/24.0)*(2888+1179*a3+125*a4+3971*a2+5661*a)/(ap14*ap22*(a+3)*(a+4));
        ex1 = r * (ck[4] + r * ck[5])
        ex2 = r * (ck[3] + ex1)
        ex3 = r * (ck[2] + ex2)
        ex4 = 1 + ex3
        x0 = r * ex3
//        x0=r*(1+r*(ck[2]+r*(ck[3] + r * (ex1))));

    }
    else if ((q < min(makeFP(0.02), exp1(makeFP(-1.5) * a) / gamma1(a))) && (a < 10)) {
        m = 0
        b = 1 - a
        b2 = b * b
        b3 = b2 * b
        eta = sqrt(-2 / a * log1(q * gamstar(a) * T.sqrt2pi / sqrt(a)))
        x0 = a * lambdaeta(eta)
        L = log1(x0)
        if ((a > makeFP(0.12)) || (x0 > 5)) {
            L2 = L * L
            L3 = L2 * L
            L4 = L3 * L
            r = 1 / x0
            /*
             ck[1]=L-1;
             ck[3]=(24*b*L-11*b2-24*b-6*L2+12*L-12-9*b*L2+6*b2*L+2*L3)/6.0;
            ck[4]=(-12*b3*L+84*b*L2-114*b2*L+72+36*L2+3*L4-72*L+162*b-168*b*L-12*L3+25*b3-22*b*L3+36*b2*L2+120*b2)/12.0;
             x0=x0-L+b*r*(ck[1]+r*(ck[2]+r*(ck[3]+r*ck[4])));
            */
            ck[1] = L - 1
            let two: T = makeFP(2)
            ex1 = makeFP(3) * b - two * b * L
            ex2 = ex1 + L2 - two * L + two
//            ck[2]=(3*b-2*b*L+L2-2*L+2)/2.0;
            ck[2] = ex2 * T.half
            ex1 = 24 * b * L
            ex2 = ex1 - 11 * b2 - 24 * b
            ex3 = ex2 - 6 * L2 + 12 * L - 12
            ex4 = ex3 - 9 * b * L2
            ex5 = ex4 + 6 * b2 * L
            ex6 = ex5 + two * L3
//            ck[3]=(24*b*L-11*b2-24*b-6*L2+12*L-12-9*b*L2+6*b2*L+2*L3)/6.0;
            ck[3] = ex6 / 6
            ex1 = makeFP(-12) * b3 * L
            ex2 = ex1 + 84 * b * L2
            ex3 = ex2 - 114 * b2 * L
            ex4 = ex3 + 72 + 36 * L2
            ex5 = ex4 + 3 * L4
            ex6 = ex5 - 72 * L
            ex7 = ex6 + 162 * b
            ex8 = ex7 - 168 * b * L
            ex9 = ex8 - 12 * L3
            ex10 = ex9 + 25 * b3
            ex11 = ex10 - 22 * b * L3
            ex12 = ex11 + 36 * b2 * L2
            ex13 = ex12 + 120 * b2
            ck[4] = ex13 / 12
//            ck[4]=(-12*b3*L+ 84*b*L2- 114*b2*L + 72+36*L2 + 3*L4 -72*L +162*b -168*b*L -12*L3 +25*b3 -22*b*L3 +36*b2*L2 +120*b2 )/12.0;
            ex1 = ck[3] + r * ck[4]
            ex2 = r * ex1
            ex3 = ck[1] + ex2
            ex4 = b * r * ex3
            ex5 = L + ex4
            x0 = x0 - ex5
        }
        else {
            r = 1 / x0
            L2 = L * L
            ck[1] = L - 1
            x0 = x0 - L + b * r * ck[1]
        }
    }
    else if (abs(porq - T.half) < makeFP(1.0e-5)) {
        m = 0
        ex1 = makeFP(8) / makeFP(405) + makeFP(184) / makeFP(25515)
        ex2 = ex1 / a
        ex3 = a - T.third
        ex4 = ex2 / a
        x0 = ex3 + ex4
//        x0 = a - T.third + (makeFP(8) / makeFP(405) + makeFP(184) / makeFP(25515) / a) / a
    }
    else if (abs(a - 1) < makeFP(1.0e-4)) {
        m = 0
        if (pcase) {
            x0 = -log1(1 - p)
        } else {
            x0 = -log1(q)
        }
    }
    else if (a < 1) {
        m = 0
        if (pcase) {
            x0 = exp1((1 / a) * (log1(porq) + loggam(a + 1)))
        } else {
            x0 = exp1((1 / a) * (log1(1 - porq) + loggam(a + 1)))
        }
    }
    else {
        m = 1
        r = inverfc(2 * porq)
        ex1 = s * r / sqrt(a * T.half)
        ex2 = eps2(ex1) + eps3(ex1) / a
        ex3 = eps1(ex1) + (ex2) / a
        eta = ex1 + (ex3) / a
//        eta = s * r / sqrt(a * T.half)
//        eta = eta + (eps1(eta) + (eps2(eta) + eps3(eta) / a) / a) / a
        x0 = a * lambdaeta(eta)
    }
    t = 1
    x = x0
    n = 1
    a2 = a * a
    a3 = a2 * a
    //! Implementation of the high order Newton-like method
    var incGammaAns: (p: T, q: T, ierr: Int)
    while ((t > makeFP(1.0e-15)) || (n < 15)) {
        x = x0
        x2 = x * x
        if (m == 0) {
            dlnr = (1 - a) * log1(x) + x + loggam(a)
            if (dlnr > log1(T.greatestFiniteMagnitude)) {
                n = 20
                ierr = -1
            } else {
                r = exp1(dlnr)
                if (pcase) {
                    incGammaAns = incgam(a: a,x: x)
                    px = incGammaAns.p
                    qx = incGammaAns.q
                    ierr = incGammaAns.ierr
                    ck[1] = -r * (px - p)
                } else {
//                    incgam(a,x,&px,&qx,&ierrf)
                    incGammaAns = incgam(a: a,x: x)
                    px = incGammaAns.p
                    qx = incGammaAns.q
                    ierr = incGammaAns.ierr
                    ck[1] = r * (qx - q)
                }
                ck[2] = (x - a + 1) / (2 * x)
                ex1 = 2 * x2
                ex2 = ex1 - 4 * x * a
                ex1 = ex2 + 4 * x
                ex2 = ex1 + 2 * a2
                ex1 = ex2 - 3 * a
                ex2 = ex1 + 1
                ex1 = 6 * x2
                ck[3] = ex2 / ex1
//                ck[3] = (2 * x2 - 4 * x * a + 4 * x + 2 * a2 - 3 * a + 1) / (6 * x2)
                r = ck[1]
                if (a > makeFP(0.1)) {
                    ex1 = ck[2] + r * ck[3]
                    ex2 = r * ex1
                    ex3 = 1 + ex2
                    ex4 = r * ex3
                    x0 = x + ex4
//                    x0 = x + r * (1 + r * (ck[2] + r * ck[3]))
                } else {
                    if (a > makeFP(0.05)) {
                        x0 = x + r * (1 + r * (ck[2]))
                    } else {
                        x0 = x + r
                    }
                }
            }
        } else {
            y = eta
            ex1 = T.minusOne * sqrt(a / T.twopi)
            ex2 = y * y
            ex3 = T.minusOne * T.half * a
            ex4 = ex2 * ex3
            fp = ex1 * exp1(ex4) / (gamstar(a))
//            fp = -sqrt(a / T.twopi) * exp1(-T.half * a * y * y) / (gamstar(a))
            r = -(1 / fp) * x
            if (pcase) {
                incGammaAns = incgam(a: a,x: x)
                px = incGammaAns.p
                qx = incGammaAns.q
                ierr = incGammaAns.ierr
//                incgam(a,x,&px,&qx,&ierrf)
                ck[1] = -r * (px - p)
            } else {
                incGammaAns = incgam(a: a,x: x)
                px = incGammaAns.p
                qx = incGammaAns.q
                ierr = incGammaAns.ierr
//              incgam(a,x,&px,&qx,&ierrf)
                ck[1] = r * (qx - q)
            }
            ck[2] = (x - a + 1)  / (2 * x)
            ex1 = 2 * x2
            ex2 = ex1 - 4 * x * a
            ex3 = ex2 + 4 * x
            ex4 = ex3 + 2 * a2
            ex5 = ex4 - 3 * a + 1
            ex6 = 6 * x2
            ck[3] = ex5 / ex6
//            ck[3] = (2 * x2 - 4 * x * a + 4 * x + 2 * a2 - 3 * a + 1) / (6 * x2)
            r = ck[1]
            if (a > makeFP(0.1)) {
                x0 = x + r * (1 + r * (ck[2] + r * ck[3]))
            } else {
                if (a > makeFP(0.05)) {
                    x0 = x + r * (1 + r * (ck[2]))
                }
                else {
                    x0 = x + r
                }
            }
        }
        t = abs(x / x0 - 1)
        n = n + 1
        x = x0
    }
    if (n == 15) {
        ierr = -2
    }
    xr = x
}
//END SUBROUTINE invincgam
//

fileprivate func sinh1<T: SSFloatingPoint>(_ x: T,_ eps: T) -> T {
    //! to compute hyperbolic function sinh1 (x)}
    var ax, e, t, x2, y: T
    var u, k: Int
    ax = abs(x)
    if (x.isZero) {
        y = 0
    }
    else if (ax < makeFP(0.12)) {
        e = eps / 10
        x2 = x * x
        y = 1
        t = 1
        u = 0
        k = 1
        while (t > e) {
            u = u + 8 * k - 2
            k = k + 1
            t = t * x2 / makeFP(u)
            y = y + t
        }
        y = x * y
    }
    else if (ax < makeFP(0.36)) {
        t = sinh1( x / 3, eps)
        y = t * (3 + 4 * t * t)
    } else {
        t = exp1(x)
        y = (t - 1/t) / 2
    }
    return y
}

fileprivate func exmin1<T: SSFloatingPoint>(_ x: T,_ eps: T) -> T {
    //! computes (exp(x)-1)/x
    var res: T
    var t, y: T
    if (x.isZero) {
        y = 1
    }
    else if ((x < makeFP(-0.69)) || (x > makeFP(0.4))) {
        y = (exp1(x) - 1) / x
    } else {
        t = x / 2
        y = exp1(t) * sinh1(t,eps) / t
    }
    res = y
    return res
}

fileprivate func logoneplusx<T: SSFloatingPoint>(_ t: T) -> T {
    return log1p1(t)
//
//FUNCTION logoneplusx(x)
//USE Someconstants
//IMPLICIT NONE
//!{x >-1 computes ln(1+x) with good}
//!{relative precision when |x| is small}
//REAL(r8) :: x, logoneplusx
//REAL(r8) :: y0, r, s
//y0=log(1.0+x)
//if ((-0.2928 < x) && (x < 0.4142)) {
//s=y0*exmin1(y0, machtol)
//r=(s-x)/(s+1.0)
//y0=y0-r*(6-r)/(6-4*r)
//ENDIF
//logoneplusx= y0
//END FUNCTION logoneplusx
//
//
//
}


fileprivate func auxloggam<T: SSFloatingPoint>(_ x: T) -> T {
    //! {function g in ln(Gamma(1+x))=x*(1-x)*g(x), 0<=x<=1}
    var ak: Array<T> = Array.init(repeating: 0, count: 26)
    var g, t: T
    let dwarf = T.leastNormalMagnitude * 10
    var ex1, ex2, ex3, ex4, ex5: T
    if (x < -1) {
        g = T.infinity
    }
    else if (abs(x) <= dwarf) {
        g = -T.eulergamma
    }
    else if (abs(x - 1) <= T.ulpOfOne) {
        g = T.eulergamma - 1
    }
    else if (x < 0) {
        ex1 = x * (1 + x)
        ex2 = ex1 * auxloggam(x + 1)
        ex3 = ex2 + log1p1(x)
        ex4 = x * (1 - x)
        g = -ex3 / ex4
//        g = -(x * (1 + x) * auxloggam(x + 1) + log1p1(x)) / (x * (1 - x))
    }
    else if (x < 1) {
        ak[0] = makeFP(-0.98283078605877425496)
        ak[1] = makeFP(0.7611416167043584304e-1)
        ak[2] = makeFP(-0.843232496593277796e-2)
        ak[3] = makeFP(0.107949372632860815e-2)
        ak[4] = makeFP(-0.14900748003692965e-3)
        ak[5] = makeFP(0.2151239988855679e-4)
        ak[6] = makeFP(-0.319793298608622e-5)
        ak[7] = makeFP(0.48516930121399e-6)
        ak[8] = makeFP(-0.7471487821163e-7)
        ak[9] = makeFP(0.1163829670017e-7)
        ak[10] = makeFP(-0.182940043712e-8)
        ak[11] = makeFP(0.28969180607e-9)
        ak[12] = makeFP(-0.4615701406e-10)
        ak[13] = makeFP(0.739281023e-11)
        ak[14] = makeFP(-0.118942800e-11)
        ak[15] = makeFP(0.19212069e-12)
        ak[16] = makeFP(-0.3113976e-13)
        ak[17] = makeFP(0.506284e-14)
        ak[18] = makeFP(-0.82542e-15)
        ak[19] = makeFP(0.13491e-15)
        ak[20] = makeFP(-0.2210e-16)
        ak[21] = makeFP(0.363e-17)
        ak[22] = makeFP(-0.60e-18)
        ak[23] = makeFP(0.98e-19)
        ak[24] = makeFP(-0.2e-19)
        ak[25] = makeFP(0.3e-20)
        t = 2 * x - 1
        g = chepolsum(25, t, ak)
    }
    else if (x < makeFP(1.5)) {
        ex1 = log1p1(x - 1)
        ex2 = (x - 1) * (2 - x)
        ex3 = ex2 * auxloggam(x - 1)
        ex4 = ex1 + ex3
        ex5 = (x * (1 - x))
        g = ex4 / ex5
//        g = (log1p1(x - 1) + (x - 1) * (2 - x) * auxloggam(x - 1)) / (x * (1 - x))
    }
    else {
        ex1 = log1(x)
        ex2 = (x - 1) * (2 - x)
        ex3 = ex2 * auxloggam(x - 1)
        ex4 = ex1 + ex3
        ex5 = (x * (1 - x))
        g = ex4 / ex5
//        g = (log1(x) + (x - 1) * (2 - x) * auxloggam(x - 1)) / (x * (1 - x))
    }
    return g
}

internal func loggam<T: SSFloatingPoint>(_ x: T) -> T {
    //! Computation of ln(gamma1(x)), x>0
    var res: T
    var ex1, ex2: T
    if (x >= 3) {
        res = (x - T.half) * log1(x) - x + T.lnsqrt2pi + stirling(x)
    }
    else if (x >= 2) {
        ex1 = (x - 2) * (3 - x)
        ex2 = ex1 * auxloggam(x - 2)
        res = ex2 + log1p1(x - 2)
//        res = (x - 2) * (3 - x) * auxloggam(x - 2) + log1p1(x - 2)
    }
    else if (x >= 1) {
        res = (x - 1) * (2 - x) * auxloggam(x - 1)
    }
    else if (x > T.half) {
        res = x * (1 - x) * auxloggam(x) - log1p1(x - 1)
    }
    else if (x > 0) {
        res = x * (1 - x) * auxloggam(x) - log1(x)
    } else {
        res = T.infinity
    }
    return res
}

fileprivate func gamma1<T: SSFloatingPoint>(_ x: T) -> T {
    var dw, gam, z: T
    var k, k1: Int
    let dwarf = T.ulpOfOne * 10
    // ! {Euler gamma function Gamma(x), x real}
    k = nint(x)
    k1 = k - 1
    if (k == 0) {
        dw = dwarf
    } else {
        dw = T.ulpOfOne
    }
    if ((k <= 0) && (abs(makeFP(k) - x) <= dw)) {
        if (k % 2 > 0) {
            //    ! k is odd
            gam = sign(makeFP(k) - x) * T.greatestFiniteMagnitude
        } else {
            //    ! k is even
            gam = sign(x - makeFP(k)) * T.greatestFiniteMagnitude
        }
    } else if (x < makeFP(0.45)) {
        gam = T.pi / (sin1(T.pi * x) * gamma1(1 - x))
    } else if ((abs(makeFP(k) - x) < dw) && (x < 21)) {
        gam = 1
        for n in stride(from: 2, to: k1, by: 1) {
//        for (n= 2; n<= k1;n++) {
            gam = gam * makeFP(n)
        }
    } else if ((abs(makeFP(k) - x - T.half) < dw) && (x < 21)) {
        gam = sqrt(T.pi)
        for n in stride(from: 1, to: k1, by: 1) {
//        for (n=1;n<=k1;n++) {
            gam = gam * (makeFP(n) - T.half)
        }
    } else if (x < 3) {
        if (makeFP(k) > x) {
            k = k1
        }
        k1 = 3 - k
        z = makeFP(k1) + x
        gam = gamma1(z)
        for n in stride(from: 1, to: k1, by: 1) {
//        for( n=1;n <=k1;n++) {
            gam = gam / (z - makeFP(n))
        }
    } else {
        gam = T.sqrt2Opi * exp1(-x + (x - T.half) * log1(x) + stirling(x))
    }
    return gam
}



fileprivate func auxgam<T: SSFloatingPoint>(_ x: T) -> T {
//    //!{function g in 1/gamma1(x+1)=1+x*(x-1)*g(x), -1<=x<=1}
    var t: T
    var dr: Array<T> = Array<T>.init(repeating: 0, count: 18)
    var ans: T
    var ex1, ex2, ex3: T
    if (x < 0) {
        ex1 = (1 + x)
        ex2 = ex1 * ex1 * auxgam(ex1)
        ex3 = 1 + ex2
        ans = -ex3 / (1 - x)
//        res = -(1 + (1 + x) * (1 + x) * auxgam(1 + x))/(1 - x)
    } else {
        dr[0] = makeFP(-1.013609258009865776949)
        dr[1] = makeFP(0.784903531024782283535e-1)
        dr[2] = makeFP(0.67588668743258315530e-2)
        dr[3] = makeFP(-0.12790434869623468120e-2)
        dr[4] = makeFP(0.462939838642739585e-4)
        dr[5] = makeFP(0.43381681744740352e-5)
        dr[6] = makeFP(-0.5326872422618006e-6)
        dr[7] = makeFP(0.172233457410539e-7)
        dr[8] = makeFP(0.8300542107118e-9)
        dr[9] = makeFP(-0.10553994239968e-9)
        dr[10] = makeFP(0.39415842851e-11)
        dr[11] = makeFP(0.362068537e-13)
        dr[12] = makeFP(-0.107440229e-13)
        dr[13] = makeFP(0.5000413e-15)
        dr[14] = makeFP(-0.62452e-17)
        dr[15] = makeFP(-0.5185e-18)
        dr[16] = makeFP(0.347e-19)
        dr[17] = makeFP(-0.9e-21)
        t = 2 * x - 1
        ans = chepolsum(17, t, dr)
    }
    return ans
}


fileprivate func lngam1<T: SSFloatingPoint>(_ x: T) -> T {
    //! {ln(gamma1(1+x)), -1<=x<=1}
    return -log1p1(x * (x - 1) * auxgam(x))
}


//
fileprivate func nint<T: SSFloatingPoint>(_ x: T) -> Int {
    let c = ceil(x)
    let t = floor(x)
    if (abs(x - c) > abs(x - t)) {
        return integerValue(t)
    }
    else {
        return integerValue(c)
    }
}


fileprivate func errorfunction1<T: SSFloatingPoint>(_ x: T, _ erfcc: Bool,_ expo: Bool) -> T {
    var y, z, errfu: T
    var r, s: Array<T>
    r = Array<T>.init(repeating: 0, count: 9)
    s = Array<T>.init(repeating: 0, count: 9)
    if (erfcc) {
        if (x < makeFP(-6.5)) {
            y = 2
        } else if  (x < 0) {
            y = 2 - errorfunction1(-x, true, false)
        } else if  (x.isZero) {
            y = 1
        } else if  (x < T.half) {
            if (expo) {
                y = exp1(x * x)
            }
            else {
                y = 1
            }
            y = y * (1 - errorfunction1(x, false, false))
        } else if  (x < 4) {
            if (expo) {
                y = 1
            } else {
                y = exp1(-x * x)
            }
            r[0] = makeFP( 1.230339354797997253e3)
            r[1] = makeFP( 2.051078377826071465e3)
            r[2] = makeFP( 1.712047612634070583e3)
            r[3] = makeFP( 8.819522212417690904e2)
            r[4] = makeFP( 2.986351381974001311e2)
            r[5] = makeFP( 6.611919063714162948e1)
            r[6] = makeFP( 8.883149794388375941)
            r[7] = makeFP( 5.641884969886700892e-1)
            r[8] = makeFP( 2.153115354744038463e-8)
            s[0] = makeFP( 1.230339354803749420e3)
            s[1] = makeFP( 3.439367674143721637e3)
            s[2] = makeFP( 4.362619090143247158e3)
            s[3] = makeFP( 3.290799235733459627e3)
            s[4] = makeFP( 1.621389574566690189e3)
            s[5] = makeFP( 5.371811018620098575e2)
            s[6] = makeFP( 1.176939508913124993e2)
            s[7] = makeFP( 1.574492611070983473e1)
            y = y * fractio(x, 8, r, s)
        } else {
            z = x * x
            if (expo) {
                y = 1
            } else {
                y = exp1(-z)
            }
            z = 1 / z
            r[0] = makeFP(6.587491615298378032e-4)
            r[1] = makeFP(1.608378514874227663e-2)
            r[2] = makeFP(1.257817261112292462e-1)
            r[3] = makeFP(3.603448999498044394e-1)
            r[4] = makeFP(3.053266349612323440e-1)
            r[5] = makeFP(1.631538713730209785e-2)
            s[0] = makeFP(2.335204976268691854e-3)
            s[1] = makeFP(6.051834131244131912e-2)
            s[2] = makeFP(5.279051029514284122e-1)
            s[3] = makeFP(1.872952849923460472)
            s[4] = makeFP(2.568520192289822421)
            y = y * (T.oosqrtpi - z * fractio(z, 5, r, s)) / x
        }
        errfu = y
    } else {
        if (x.isZero) {
            y = 0
        } else if  (abs(x) > makeFP(6.5)) {
            y = x / abs(x)
        } else if  (x > T.half) {
            y = 1 - errorfunction1(x, true, false)
        } else if  (x < -T.half) {
            y = errorfunction1(-x, true, false) - 1
        } else {
            r[0] = makeFP(3.209377589138469473e3)
            r[1] = makeFP(3.774852376853020208e2)
            r[2] = makeFP(1.138641541510501556e2)
            r[3] = makeFP(3.161123743870565597e0)
            r[4] = makeFP(1.857777061846031527e-1)
            s[0] = makeFP(2.844236833439170622e3)
            s[1] = makeFP(1.282616526077372276e3)
            s[2] = makeFP(2.440246379344441733e2)
            s[3] = makeFP(2.360129095234412093e1)
            z = x * x
            y = x * fractio(z, 4, r, s)
        }
        errfu = y
    }
    return errfu
}

fileprivate func fractio<T: SSFloatingPoint>(_ x: T,_ n: Int,_ r: Array<T>, _ s: Array<T>) -> T {
    var a, b: T
    a = r[n]
    b = 1
    for k in stride(from: n - 1, through: 0, by: -1) {
        a = a * x + r[k]
        b = b * x + s[k]
    }
    return a/b
}


fileprivate func pqasymp<T: SSFloatingPoint>(_ a: T,_ x: T,_ dp: T,_ p: Bool) -> T {
    var res, y, mu, eta, u, v: T
    var s: T
    if (dp.isZero) {
        if (p) {
            res = 0
        } else {
            res = 1
        }
    }
    else {
        if (p) {
            s = -1
        } else {
            s = 1
        }
        mu = (x - a) / a
        y = -lnec(mu)
        if (y < 0) {
            eta = 0
        } else {
            eta = sqrt(2 * y)
        }
        y = y * a
        v = sqrt(abs(y))
        if (mu < 0) {
            eta = -eta
            v = -v
        }
        u = T.half * errorfunction1(s * v,true,false)
        v = s * exp1(-y) * saeta(a,eta) / sqrt(2 * T.pi * a)
        res = u + v
    }
    return res
}

fileprivate func saeta<T: SSFloatingPoint>(_ a: T,_ eta: T) -> T {
    var res, y, s, t, eps: T
    var fm: Array<T> = Array<T>.init(repeating: 0, count: 27)
    var bm: Array<T> = Array<T>.init(repeating: 0, count: 27)
    var  m: Int
    eps = makeFP(EPSS)
    fm[0] = makeFP(1.0)
    fm[1] = makeFP(-1.0/3.0)
    fm[2] = makeFP(1.0/12.0)
    fm[3] = makeFP(-2.0/135.0)
    fm[4] = makeFP(1.0/864.0)
    fm[5] = makeFP(1.0 / 2835.0)
    fm[6] = makeFP(-139.0/777600.0)
    fm[7] = makeFP(1.0/25515.0)
    fm[8] = makeFP(-571.0/261273600.0)
    fm[9] = makeFP(-281.0/151559100.0)
    fm[10] = makeFP(8.29671134095308601e-7)
    fm[11] = makeFP(-1.76659527368260793e-7)
    fm[12] = makeFP(6.70785354340149857e-9)
    fm[13] = makeFP(1.02618097842403080e-8)
    fm[14] = makeFP(-4.38203601845335319e-9)
    fm[15] = makeFP(9.14769958223679023e-10)
    fm[16] = makeFP(-2.55141939949462497e-11)
    fm[17] = makeFP(-5.83077213255042507e-11)
    fm[18] = makeFP(2.43619480206674162e-11)
    fm[19] = makeFP(-5.02766928011417559e-12)
    fm[20] = makeFP(1.10043920319561347e-13)
    fm[21] = makeFP(3.37176326240098538e-13)
    fm[22] = makeFP(-1.39238872241816207e-13)
    fm[23] = makeFP(2.85348938070474432e-14)
    fm[24] = makeFP(-5.13911183424257258e-16)
    fm[25] = makeFP(-1.97522882943494428e-15)
    fm[26] = makeFP( 8.09952115670456133e-16)
    bm[25] = fm[26]
    bm[24] = fm[25]
    for m in stride(from: 24, through: 1, by: -1) {
        bm[m-1] = fm[m] + makeFP(m + 1) * bm[m + 1] / a
    }
    s = bm[0]
    t = s
    y = eta
    m = 1
    while ((abs(t / s) > eps) && (m < 25)) {
        t = bm[m] * y
        s = s + t
        m = m + 1
        y = y * eta
    }
    res = s / (1 + bm[1] / a)
    return res
}

fileprivate func qfraction<T: SSFloatingPoint>(_ a: T,_ x: T,_ dp: T) -> T {
    var res, eps, g, p, q, r, s, t, tau, ro: T
    eps = makeFP(EPSS)
    if (dp.isZero) {
        q = 0
    } else {
        p = 0
        q = (x - 1 - a) * ( x + 1 - a)
        r = 4 * (x + 1 - a)
        s = 1 - a
        ro = 0
        t = 1
        g = 1
        while(abs(t / g) >= eps) {
            p = p + s
            q = q + r
            r = r + 8
            s = s + 2
            tau = p * (1 + ro)
            ro = tau / (q - tau)
            t = ro * t
            g = g + t
        }
        q = (a / (x + 1 - a)) * g * dp
    }
    res = q
    return res
}

fileprivate func qtaylor<T: SSFloatingPoint>(_ a: T,_ x: T,_ dp: T) -> T {
    var res, eps, lnx, p, q, r, s, t, u, v, ex1, ex2, ex3: T
    eps = makeFP(EPSS)
    lnx = log1(x)
    if (dp.isZero) {
        q = 0
    } else {
        r = a * lnx
        //{q = x^a - 1 }
        q = r * exmin1(r,eps)
        // {s = 1-1/Gamma(1+a) }
        s = a * (1 - a) * auxgam(a)
        q = (1 - s) * q
        // {u = 1 - x^a/Gamma(1+a)}
        u = s - q
        p = a * x
        q = a + 1
        r = a + 3
        t = 1
        v = 1
        while (abs(t/v) > eps) {
            p = p + x
            q = q + r
            r = r + 2
            t = -p * t / q
            v = v + t
        }
        ex1 = a * (1 - s)
        ex2 = (a + 1) * lnx
        ex3 = v / (a + 1)
        v = ex1 * exp1(ex2) * ex3
//        v = a * (1 - s) * exp1((a + 1) * lnx) * v / (a + 1)
        q=u+v
    }
    res = q
    return res
}

fileprivate func ptaylor<T: SSFloatingPoint>(_ a: T,_ x: T,_ dp: T) -> T {
    var res, eps,p,c,r: T
    eps = makeFP(EPSS)
    if (dp.isZero) {
        p = 0
    } else {
        p = 1
        c = 1
        r = a
        while ((c / p) > eps) {
            r = r + 1
            c = x * c / r
            p = p + c
        }
        p = p * dp
    }
    res = p
    return res
}


fileprivate func eps1<T: SSFloatingPoint>(_ eta: T) -> T {
    var res,la: T
    var ak: Array<T> = Array<T>.init(repeating: 0, count: 5)
    var bk: Array<T> = Array<T>.init(repeating: 0, count: 5)
    if (abs(eta) < 1) {
        ak[0] = makeFP(-3.333333333438e-1)
        bk[0] = makeFP(1.000000000000e+0)
        ak[1] = makeFP(-2.070740359969e-1)
        bk[1] = makeFP(7.045554412463e-1)
        ak[2] = makeFP(-5.041806657154e-2)
        bk[2] = makeFP(2.118190062224e-1)
        ak[3] = makeFP(-4.923635739372e-3)
        bk[3] = makeFP(3.048648397436e-2)
        ak[4] = makeFP(-4.293658292782e-5)
        bk[4] = makeFP(1.605037988091e-3)
        res = ratfun(eta, ak, bk)
    } else {
        la = lambdaeta(eta)
        res = log1(eta / (la - 1)) / eta
    }
    return res
}

fileprivate func eps2<T: SSFloatingPoint>(_ eta: T) -> T {
    var res, x, lnmeta: T
    var ex1, ex2, ex3: T
    var ak: Array<T> = Array<T>.init(repeating: 0, count: 5)
    var bk: Array<T> = Array<T>.init(repeating: 0, count: 5)
    if (eta < -5) {
        x = eta * eta
        lnmeta = log1(-eta)
        ex1 = 12 - x - 6
        ex2 = (lnmeta * lnmeta)
        ex3 = 12 * x * eta
        res = (ex1 * ex2) / ex3
//        res = (12 - x - 6 * (lnmeta * lnmeta)) / (12 * x * eta)
    } else if (eta < -2) {
        ak[0] = makeFP(-1.72847633523e-2);  bk[0] = makeFP(1.00000000000e+0)
        ak[1] = makeFP(-1.59372646475e-2);  bk[1] = makeFP(7.64050615669e-1)
        ak[2] = makeFP(-4.64910887221e-3);  bk[2] = makeFP(2.97143406325e-1)
        ak[3] = makeFP(-6.06834887760e-4);  bk[3] = makeFP(5.79490176079e-2)
        ak[4] = makeFP(-6.14830384279e-6);  bk[4] = makeFP(5.74558524851e-3)
        res = ratfun(eta,ak,bk)
    } else if (eta < 2) {
        ak[0] = makeFP(-1.72839517431e-2);  bk[0] = makeFP(1.00000000000e+0)
        ak[1] = makeFP(-1.46362417966e-2);  bk[1] = makeFP(6.90560400696e-1)
        ak[2] = makeFP(-3.57406772616e-3);  bk[2] = makeFP(2.49962384741e-1)
        ak[3] = makeFP(-3.91032032692e-4);  bk[3] = makeFP(4.43843438769e-2)
        ak[4] = makeFP(2.49634036069e-6);   bk[4] = makeFP(4.24073217211e-3)
        res = ratfun(eta,ak,bk)
    } else if (eta < 1000) {
        ak[0] = makeFP(9.99944669480e-1);  bk[0] = makeFP(1.00000000000e+0)
        ak[1] = makeFP(1.04649839762e+2);  bk[1] = makeFP(1.04526456943e+2)
        ak[2] = makeFP(8.57204033806e+2);  bk[2] = makeFP(8.23313447808e+2)
        ak[3] = makeFP(7.31901559577e+2);  bk[3] = makeFP(3.11993802124e+3)
        ak[4] = makeFP(4.55174411671e+1);  bk[4] = makeFP(3.97003311219e+3)
        x = 1 / eta
        res = ratfun(x, ak, bk) / (-12 * eta)
    } else {
        res = -1 / (12 * eta)
    }
    return res
}

fileprivate func eps3<T: SSFloatingPoint>(_ eta: T) -> T {
    var res, eta3, x, y: T
    var ex1, ex2, ex3, ex4, ex5: T
    var ak:Array<T> = Array<T>.init(repeating: 0, count: 5)
    var bk:Array<T> = Array<T>.init(repeating: 0, count: 5)
    if (eta < -8) {
        x = eta * eta
        y = log1(-eta) / eta
        ex1 = 6 * x * y * y
        ex2 = ex1 - 12 + x
        ex3 = eta * y * ex2
        ex4 = -30 + ex3
        ex5 = (12 * eta * x * x)
        res = ex4 / ex5
    } else if (eta < -4) {
        ak[0] = makeFP(4.95346498136e-2);  bk[0] = makeFP(1.00000000000e+0)
        ak[1] = makeFP(2.99521337141e-2);  bk[1] = makeFP(7.59803615283e-1)
        ak[2] = makeFP(6.88296911516e-3);  bk[2] = makeFP(2.61547111595e-1)
        ak[3] = makeFP(5.12634846317e-4);  bk[3] = makeFP(4.64854522477e-2)
        ak[4] = makeFP(-2.01411722031e-5); bk[4] = makeFP(4.03751193496e-3)
        res = ratfun(eta,ak,bk) / (eta * eta)
    } else if (eta < -2) {
        ak[0] = makeFP(4.52313583942e-3);  bk[0] = makeFP(1.00000000000e+0)
        ak[1] = makeFP(1.20744920113e-3);  bk[1] = makeFP(9.12203410349e-1)
        ak[2] = makeFP(-7.89724156582e-5); bk[2] = makeFP(4.05368773071e-1)
        ak[3] = makeFP(-5.04476066942e-5); bk[3] = makeFP(9.01638932349e-2)
        ak[4] = makeFP(-5.35770949796e-6); bk[4] = makeFP(9.48935714996e-3)
        res = ratfun(eta,ak,bk)
    } else if (eta < 2) {
        ak[0] = makeFP(4.39937562904e-3);  bk[0] = makeFP(1.00000000000e+0)
        ak[1] = makeFP(4.87225670639e-4);  bk[1] = makeFP(7.94435257415e-1)
        ak[2] = makeFP(-1.28470657374e-4); bk[2] = makeFP(3.33094721709e-1)
        ak[3] = makeFP(5.29110969589e-6); bk[3] = makeFP(7.03527806143e-2)
        ak[4] = makeFP(1.57166771750e-7);  bk[4] = makeFP(8.06110846078e-3)
        res = ratfun(eta,ak,bk)
    } else if (eta < 10) {
        ak[0] = makeFP(-1.14811912320e-3);  bk[0] = makeFP(1.00000000000e+0)
        ak[1] = makeFP(-1.12850923276e-1);  bk[1] = makeFP(1.42482206905e+1)
        ak[2] = makeFP(1.51623048511e+0);   bk[2] = makeFP(6.97360396285e+1)
        ak[3] = makeFP(-2.18472031183e-1);  bk[3] = makeFP(2.18938950816e+2)
        ak[4] = makeFP(7.30002451555e-2);   bk[4] = makeFP(2.77067027185e+2)
        x = 1 / eta
        res = ratfun(x,ak,bk) / (eta * eta)
    } else if (eta < 100) {
        ak[0] = makeFP(-1.45727889667e-4);  bk[0] = makeFP(1.00000000000e+0)
        ak[1] = makeFP(-2.90806748131e-1);  bk[1] = makeFP(1.39612587808e+2)
        ak[2] = makeFP(-1.33085045450e+1);  bk[2] = makeFP(2.18901116348e+3)
        ak[3] = makeFP(1.99722374056e+2);   bk[3] = makeFP(7.11524019009e+3)
        ak[4] = makeFP(-1.14311378756e+1);  bk[4] = makeFP(4.55746081453e+4)
        x = 1 / eta
        res = ratfun(x,ak,bk) / (eta * eta)
    } else {
        eta3 = eta * eta * eta
        res = -log1(eta) / (12 * eta3)
    }
    return res
}

fileprivate func lambdaeta<T: SSFloatingPoint>(_ eta: T) -> T {
    //     ! lambdaeta is the positive number satisfying
    //     ! eta^2/2=lambda-1-ln(lambda)
    //     ! with sign(lambda-1)=sign(eta)
    var ak: Array<T> = Array<T>.init(repeating: 0, count: 7)
    var q, r, s, L, la: T
    var res: T
    var L2, L3, L4, L5: T
    var ex1, ex2, ex3, ex4, ex5: T
    s = eta * eta * T.half
    if (eta.isZero) {
        la = 1
    } else if (eta < -1) {
        r = exp1(-1 - s)
        ak[1] = makeFP(1)
        ak[2] = makeFP(1)
        ak[3] = makeFP(3.0 / 2)
        ak[4] = makeFP(8.0 / 3)
        ak[5] = makeFP(125.0 / 24)
        ak[6] = makeFP(54.0 / 5)
        ex1 = ak[5] + r * ak[6]
        ex2 = r * ex1
        ex3 = r * (ak[4] + ex2)
        ex4 = r * (ak[3] + ex3)
        ex5 = r * (ak[2] + ex4)
        la = r * (ak[1] + ex5)
//        la = r * (ak[1] + r * (ak[2] + r * (ak[3] + r * (ak[4] + r * (ak[5] + r * ak[6])))))
    } else if (eta < 1) {
        ak[1] = makeFP(1.0)
        ak[2] = makeFP(1.0/3.0)
        ak[3] = makeFP(1.0/36.0)
        ak[4] = makeFP(-1.0/270.0)
        ak[5] = makeFP(1.0/4320.0)
        ak[6] = makeFP(1.0/17010.0)
        r = eta
        ex1 = ak[5] + r * ak[6]
        ex2 = r * ex1
        ex3 = r * (ak[4] + ex2)
        ex4 = r * (ak[3] + ex3)
        ex5 = r * (ak[2] + ex4)
        la = 1 + r * (ak[1] + ex5)
//        la=1+r*(ak[1]+r*(ak[2]+r*(ak[3]+r*(ak[4]+r*(ak[5]+r*ak[6])))));
    } else {
        r = 11 + s
        L = log1(r)
        la = r + L
        r = 1 / r
        L2 = L * L
        L3 = L2 * L
        L4 = L3 * L
        L5 = L4 * L
        ak[1] = 1
        ak[2] = (2 - L) * T.half
        ak[3] = (-9 * L + 6 + 2 * L2) / 6
        ex1 = 3 * L3
        ex2 = 36 * L
        ex3 = -22 * L2
        ex4 = ex1 + ex2 + ex3 - 12
        ak[4] = -ex4 / 12
        ex1 = -125 * L3 + 12 * L4
        ex2 = 60 + 350 * L2 - 300 * L
        ak[5] = (ex2 + ex1) / 60
//        ak[5] = (60 + 350 * L2 - 300 * L - 125 * L3 + 12 * L4) / 60
        ex1 = -120 - 274 * L4
        ex2 = 900 * L - 1700 * L2
        ex3 = 1125 * L3 + 20 * L5
        ex4 = ex1 + ex2 + ex3
        ak[6] = -ex4 / 120
//        ak[6] = -(-120 - 274 * L4 + 900 * L - 1700 * L2 + 1125 * L3 + 20 * L5) / 120
        ex1 = ak[5] + r * ak[6]
        ex2 = r * ex1
        ex3 = r * (ak[4] + ex2)
        ex4 = r * (ak[3] + ex3)
        ex5 = r * (ak[2] + ex4)
        la = la + L * r * (ak[1] + ex5)
//        la = la + L * r * (ak[1] + r * (ak[2] + r * (ak[3] + r * (ak[4] + r * (ak[5] + r * ak[6])))))
    }
    r = 1
    if (((eta > makeFP(-3.5)) && (eta < makeFP(-0.03))) || ((eta > makeFP(0.03)) && (eta < makeFP(40.0)))) {
        r = 1
        q = la
        while (r > makeFP(1.0e-8)) {
            la = q * (s + log1(q)) / (q - 1)
            r = abs(q / la - 1)
            q = la
        }
    }
    res = la
    return res
}


fileprivate func invq<T: SSFloatingPoint>(_ x: T) -> T {
    var res, t: T
    // Abramowitx & Stegun 26.2.23
    t = sqrt(-2 * log1(x))
    var ex1, ex2, ex3, ex4, ex5: T
    ex1 = makeFP(2.515517)
    ex2 = makeFP(0.802853) + t * makeFP(0.010328)
    ex3 = makeFP(1.432788)
    ex4 = makeFP(0.189269) + t * makeFP(0.001308)
    ex5 = t * (ex3 + t * ex4)
    t = t - (ex1 + t * ex2) / (1 + ex5)
    res = t
    return res
}

fileprivate func inverfc<T: SSFloatingPoint>(_ x: T) -> T {
    var y, y0, y02, h, r, f, fp, c1, c2, c3, c4, c5: T
    var ex1, ex2, ex3: T
    if (x > 1) {
        y = -inverfc(2 - x)
    } else {
        // FIXME: CHECK THIS!
        y0 = T.sqrt2 * T.half * invq(x / 2)
        f = erfc1(y0) - x
        f = errorfunction1(y0,true,false) - x
        y02 = y0 * y0
        fp = -2 / sqrt(T.pi) * exp1(-y02)
        c1 = -1 / fp
        c2 = y0
        c3 = (4 * y02 + 1) / 3
        c4 = y0 * (12 * y02 + 7) / 6
        ex1 = 8 * y02 + 7
        ex2 = 12 * y02 + 1
        c5 = ex1 * ex2 / 30
        r = f * c1
        ex1 = r * (c4 + r * c5)
        ex2 = r * (c3 + ex1)
        ex3 = r * (c2 + ex2)
        h = r * (1 + ex3)
//        h = r * (1 + r * (c2 + r * (c3 + r * (c4 + r * c5))))
        y=y0+h
    }
    return y
}

fileprivate func ratfun<T: SSFloatingPoint>(_ x: T,_ ak: [T],_ bk: [T]) -> T {
    var res, p, q: T
    var ex1, ex2, ex3, ex4: T
    ex1 = ak[3] + x * ak[4]
    ex2 = x * ex1
    ex3 = x * (ak[2] + ex2)
    ex4 = x * (ak[1] + ex3)
    p = ak[0] + ex4
//    p = ak[0] + x * (ak[1] + x * (ak[2] + x * (ak[3] + x * ak[4])))
    ex1 = bk[3] + x * bk[4]
    ex2 = x * ex1
    ex3 = x * (bk[2] + ex2)
    ex4 = x * (bk[1] + ex3)
    q = bk[0] + ex4
//    q = bk[0] + x * (bk[1] + x * (bk[2] + x * (bk[3] + x * bk[4])))
    res = p / q
    return res
}

fileprivate func invgam<T: SSFloatingPoint>(_ a: T, _ q: T,_ pgam: Bool) -> T {
    var res,a1, a2, a3, a4, sq2, q0, t, x, x2, x3, x4, y, y2, y3, y4, y5, y6, z: T
    var mu, mu2, mu3, mu4, mup, f, a12, fp, f2, fpp, a1p, a1pp, a2p: T
    var ex1, ex2, ex3, ex4, ex5,ex6, ex7: T
    y = 0
    y2 = 0
    y3 = 0
    y4 = 0
    y5 = 0
    y6 = 0
    x = 0
    x2 = 0
    x3 = 0
    x4 = 0
    if (pgam) {
        q0 = 1 - q
    } else {
        q0 = q
    }
    t = 2 * q0
    if (abs(t - 1) < makeFP(1.0e-10)) {
        ex1 = makeFP(8.0 / 405.0)
        ex2 = makeFP(184.0 / 25515.0) / a
        ex3 = ex1 + ex2
        ex4 = ex3 / a
        x = a - T.third + ex4
//        x = a - T.third + (makeFP(8.0 / 405.0) + makeFP(184.0 / 25515.0) / a) / a
    } else {
        if (t == 2) {
            z = -6
        } else if (t < makeFP(1.0e-50)) {
            z = 15
        } else {
            z = inverfc(t)
            y = z / sqrt(a / 2)
            y2 = y * y
            y3 = y * y2
            y4 = y2 * y2
            y5 = y * y4
            y6 = y3 * y3
            sq2 = T.sqrt2
            if (abs(y) < makeFP(0.3)) {
                ex1 = makeFP(1.0/36.0) * y
                ex2 = ex1 + makeFP(1.0/1620.0) * y2
                ex3 = ex2 + makeFP(-7.0/6480.0) * y3
                ex4 = ex3 + makeFP(5.0/18144.0) * y4
                ex5 = ex4 + makeFP(-11.0/382725.0) * y5
                ex6 = ex5 + makeFP(-101.0/16329600.0) * y6
                a1 = -T.third + ex6
//                a1= -1.0/3.0 + 1.0/36.0*y + 1.0/1620.0*y2 - 7.0/6480.0*y3+ 5.0/18144.0*y4 - 11.0/382725.0*y5 - 101.0/16329600.0*y6
                ex1 = makeFP(-7.0/2592.0) * y
                ex2 = ex1 + makeFP(533.0/204120.0) * y2
                ex3 = ex2 + makeFP(-1579.0/2099520.0) * y3
                ex4 = ex3 + makeFP(109.0/1749600.0) * y4
                ex5 = ex4 + makeFP(10217.0/251942400.0) * y5
                a2 = makeFP(-7.0/405.0) + ex5
//                a2= -7.0/405.0 - 7.0/2592.0*y + 533.0/204120.0*y2- 1579.0/2099520.0*y3 + 109.0/1749600.0*y4 + 10217.0/251942400.0*y5
                ex1 = makeFP(-63149.0/20995200.0) * y
                ex2 = ex1 + makeFP(29233.0/36741600.0) * y2
                ex3 = ex2 + makeFP(346793.0/5290790400.0) * y3
                ex4 = ex3 + makeFP(-18442139.0/130947062400.0) * y4
                a3 = makeFP(449.0/102060.0) + ex4
//                a3= 449.0/102060.0 - 63149.0/20995200.0*y + 29233.0/36741600.0*y2+ 346793.0/5290790400.0*y3 - 18442139.0/130947062400.0*y4
            }
            else {
                f = inveta(y / sq2)
                mu = f - 1
                mu2 = mu * mu
                mu3 = mu * mu2
                mup = (mu + 1) * y / mu
                f = y / mu
                f2 = f * f
                fp = f * (1 - f2 - y * f) / y
                ex1 = 3 * f * fp
                ex2 = 2 * y * fp
                fpp = -f * (ex1 + f + ex2) / y
//                fpp = -f * (3 * f * fp + f + 2 * y * fp)/y
                a1 = log1(f) / y
                a12 = a1 * a1
                ex1 = -a1 / y
                ex2 = ex1 + T.one / y2
                a1p = ex1 - mup / (mu * y)
//                a1p = -a1 / y + 1 / y2 - mup / (mu * y)
                ex1 = a1 / y2
                ex2 = ex1 + a1p / y
                ex3 = ex2 + -2 / y3
                a1pp = ex3 + mup * (2 + mu) / mu3
//                a1pp = a1 / y2 - a1p / y - 2 / y3 + mup * (2 + mu) / mu3
                ex1 = -12 * a1p * f
                ex2 = ex1 + (-12 * fp * a1)
                ex3 = ex2 + f + (6 * a12 * f)
                ex4 = 12 * f * y
                a2 = ex3 / ex4
//                a2 = -(-12 * a1p * f - 12 * fp * a1 + f + 6 * a12 * f) / (12 * f * y)
                ex5 = a1pp * f
                ex6 = ex5 + makeFP(2.0) * a1p * fp
                ex7 = ex6 + fpp * a1
                ex1 = makeFP(12.0) * ex7
//                ex1 = 12 * (a1pp * f + 2 * a1p * fp + fpp * a1)
                ex2 = 12 * f * a1 * a1p
                ex3 = 6 * fp * a12
                ex4 = ex1 - fp - ex2 - ex3
                ex5 = ex4 / (12 * f * y)
                a2p = -a2/y - a2 * fp / f + ex5
                ex1 = 2 * a1 - a12 * y
                ex2 = a12 * (fpp * f * y + a1 * f2)
                ex3 = a1p * a1p * f2 * y
                ex4 = 6 * (ex1 * fp * fp + ex2 - ex3)
                let A1: T = ex4
                ex1 = (a2p * y - a1 * a1p) * f2
                ex2 = fp * a1p * f
                let A2: T = 12 * (ex1 + ex2)
                ex1 = -f * (fp + 18 * fp * a12)
                let A3: T = ex1
                let A4: T = 12 * f2 * y2
                
                a3 = (A1 + A2 + a1 * f2 + A3) / A4
//                a3 =(ex4 + 12 * (ex5 + ex6) + a1 * f2 - f * (fp + 18 * fp * a12)) / (12 * f2 * y2)
//                a3=(6*((2*a1 - a12*y)*fp*fp + a12*(fpp*f*y + a1*f2)- a1p*a1p*f2*y) + 12*((a2p*y - a1*a1p)*f2 + fp*a1p*f)+ a1*f2 - f*(fp + 18*fp*a12))/(12*f2*y2);

            }
            y = y + (a1 + (a2 + a3 / a) / a) / a
            x = a * inveta(y / sq2)
        }
        var ig: (p: T, q: T, ierr: Int)
        ig = incgam(a: a,x: x)
//        p = ig.p
        f = ig.q
//        ierr = ig.ierr
        ex1 = -sqrt(a / T.twopi)
        ex2 = ex1 * exp1(-T.half * y * y)
        fp = ex2 / gamstar(a)
//        fp = -sqrt( a / T.twopi ) * exp1(-T.half * y * y) / (gamstar(a))
        y = (f - q0) / fp
        x2 = x * x
        x3 = x * x2
        x4 = x * x3
        y2 = y * y
        y3 = y * y2
        y4 = y * y3
        a2 = a * a
        a3 = a * a2
        a4 = a * a3
        mu = 60 * (-x + a - 1)
        ex1 = 2 * x2
        ex2 = ex1 - (4 * a * x)
        ex3 = ex2 + 4 * x
        ex4 = ex3 + 2 * a2
        ex5 = ex4 - 3 * a + 1
        mu2 = 20 * ex5
//        mu2 = 20 * (2 * x2 - 4 * a * x + 4 * x + 2 * a2 - 3 * a + 1)
        ex1 = 6 * a + 6 * a3
        ex2 = ex1 - 6 * x3 - 11 * x - 1
        ex3 = ex2 - 29 * a * x - 11 * a2
        ex4 = ex3 - 18 * x2 - 18 * a2 * x
        ex5 = ex4 + 18 * a * x2
        mu3 = 5 * ex5
//        mu3 = 5 * (6 * a + 6 * a3 - 6 * x3 - 11 * x - 1 + 29 * a * x - 11 * a2 - 18 * x2 - 18 * a2 * x + 18 * a * x2)
        ex1 = 24 * x4 - 10 * a
        ex2 = ex1 - 50 * a3 + 96 * x3
        ex3 = ex2 + 26 * x + 24 * a4
        ex4 = ex3 + 144 * a2 * x2 - 96 * a3 * x
        ex5 = ex4 - 126 * a * x - 96 * a * x3
        ex6 = ex5 + 35 * a2 + 98 * x2
        ex7 = ex6 + 196 * a2 * x
        mu4 = ex7 - 242 * a * x2 + T.one
//        mu4 = ex6 + 196 * a2 * x - 242 * a * x2 + 1
//        mu4 = (24 * x4 - 10 * a - 50 * a3 + 96 * x3 + 26 * x + 24 * a4 + 144 * a2 * x2 - 96 * a3 * x - 126 * a * x - 96 * a * x3 + 35 * a2 + 98 * x2 + 196 * a2 * x - 242 * a * x2 + 1)
        ex1 = 120 + mu * y + mu2 * y2
        ex2 = mu3 * y3 + mu4 * y4
        ex3 = y * (ex1 + ex2)
        ex4 = ex3 + 144 * a2 * x2 - 96 * a3 * x
        ex5 = ex4 - 126 * a * x - 96 * a * x3
        ex6 = ex5 + 35 * a2 + 98 * x2
        x = x * (1 - ex3 / 120)
//        x = x * (1 - y * (120 + mu * y + mu2 * y2 + mu3 * y3 + mu4 * y4) / 120)
    }
    res = x
    return res
}

fileprivate func inveta<T: SSFloatingPoint>(_ x: T) -> T {
    var res, mu, a, b, p, q, r, t, x2, z: T
    var ex1, ex2, ex3, ex4: T
    var k: Int
    var ready: Bool = false
    k = 0
    if (x < -26) {
        t = 0
        mu = -1
    } else if (x.isZero) {
        t = 1
        mu = 0
    } else {
        z = x * x
        x2 = x * T.sqrt2
        if (x2 > 2) {
            p = z + 1
            q = log1(p)
            a = 1 / q
            b = T.third + a * (a - makeFP(1.5))
            r = q / p
            ex1 = a - T.half + b * r
            ex2 = 1 + r * ex1
            ex3 = r * ex2
            mu = z + q + ex3
//            mu = z + q + r * (1 + r * (a - T.half + b * r))
            t = mu + 1
        } else if (x2 > makeFP(-1.5)) {
            ex1 = x2 * (makeFP(1.0/4320.0) + x2 / 17010)
            ex2 = x2 * (makeFP(-1.0/270.0) + ex1)
            ex3 = x2 * (makeFP(1.0/36.0) + ex2)
            ex4 = x2 * (T.third + ex3)
            mu = x2 * (1 + ex4)
//            mu = x2 * (1 + x2 * (T.third + x2 * (makeFP(1.0/36.0) + x2 * (makeFP(-1.0/270.0) + x2 * (makeFP(1.0/4320.0) + x2 / 17010)))))
            t = mu + 1
        } else {
            p = exp1(-z - 1)
            ex1 = p * (makeFP(8.0/3.0) + p * makeFP(125.0/24.0))
            ex2 = p * (makeFP(1.5) + ex1)
            ex3 = p * (1 + ex2)
            t = p * (1 + ex3)
//            t = p * (1 + p * (1 + p * (makeFP(1.5) + p * (makeFP(8.0/3.0) + p * makeFP(125.0/24.0)))))
            mu = t - 1
        }
        ready = false
        while (!ready) {
            ready = true
            p = lnec(mu)
            r = -p - z
            if (abs(r) > makeFP(1.0e-18)) {
                r = r * t / mu
                p = r / t / mu
                ex1 = 1 - p * (2 * t + 1)
                ex2 = 1 - p * (4 * t - 1)
                q = r * (ex2 / 6) / (ex1 / 3)
//                q = r * (1 - p * (4 * t - 1) / 6) / (1 - p * (2 * t + 1) / 3)
                mu = mu - q
                t = t - q
                k = k + 1
                if ((t <= 0) || (mu <= -1)) {
                    t = 0
                    mu = -1
                    ready = true
                } else if (k > 5) || (abs(q) < (makeFP(1.0e-10) * (abs(mu) + 1))) {
                    ready = true
                } else {
                    ready = false
                }
            }
        }
    }
    res = t
    return res
}

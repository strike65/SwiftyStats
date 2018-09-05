//
//  Created by VT on 03.09.18.
//  Copyright © 2018 Volker Thieme. All rights reserved.
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
import Foundation

/*
 ! -------------------------------------------------------------
 ! Calculation of the Marcum Q-functions P_mu(x,y) and Q_mu(x,y).
 !
 ! In order to avoid, overflow/underflow problems in IEEE double
 !  precision arithmetic, the admissible parameter ranges
 !  for computation are:
 !
 !      0<=x<=10000,   0<=y<=10000,    1<=mu<=10000
 !
 !  The aimed relative accuracy is close to 1.0e-11 in the
 !  previous parameter domain.
 ! -------------------------------------------------------------
 ! Inputs:
 !   mu ,   argument of the functions
 !   x ,    argument of the functions
 !   y ,    argument of the functions
 !
 ! Outputs:
 !   p,     function P_mu(a,x)
 !   q,     function Q_mu(a,x)
 !   ierr , error flag
 !          ierr=0, computation succesful
 !          ierr=1, Underflow problems. The function values
 !                  are set to zero and one.
 !          ierr=2, any of the arguments of the function is
 !                  out of range. The function values
 !                  (P_mu(a,x) and Q_mu(a,x)) are set to zero.
 ! --------------------------------------------------------------------
 !           METHODS OF COMPUTATION
 ! --------------------------------------------------------------------
 ! The present code uses different methods of computation
 ! depending on the values of mu, x and y: series expansions in terms
 ! of incomplete gamma functions, integral representations,
 ! asymptotic expansions, and use of three-term homogeneous
 ! recurrence relations.
 !
 !---------------------------------------------------------------------
 !     RELATION WITH OTHER STANDARD NOTATION FOR THE
 !     GENERALIZED MARCUM FUNCTIONS
 !---------------------------------------------------------------------
 !  The relation with the Marcum functions computed by
 !  Matlab or Mathematica (QM_(mu)(x,y),PM_(mu)(x,y))
 !  is the following:
 !
 !        Q_(mu)(x,y)=QM_(mu)(sqrt(2*x),sqrt(2*y))
 !
 !   and similarly for the P function.
 ! --------------------------------------------------------------------
 ! Authors:
 !
 !  Amparo Gil    (U. Cantabria, Santander, Spain)
 !                 e-mail: amparo.gil@unican.es
 !  Javier Segura (U. Cantabria, Santander, Spain)
 !                 e-mail: javier.segura@unican.es
 !  Nico M. Temme (CWI, Amsterdam, The Netherlands)
 !                 e-mail: nico.temme@cwi.nl
 ! ---------------------------------------------------------------
 !  References:
 !  1. A. Gil, J. Segura and N.M. Temme, Accompanying paper in
 !     ACM Trans Math Soft
 !  2. A. Gil, J. Segura and N.M. Temme. Efficient and accurate
 !     algorithms for the computation and inversion
 !     of the incomplete gamma function ratios. SIAM J Sci Comput.
 !     (2012) 34(6), A2965-A2981
 ! ---------------------------------------------------------------
*/
fileprivate func zeta<T: SSFloatingPoint>(_ x: T, _ y: T) -> T {
    var ck: Array<T> = Array<T>.init(repeating: 0, count: 10)
    var w,z,z2,S,t: T
    var x2,x3,x4,x5,x6,x7,x8,x9,x10,x2p1: T
    var k: Int
    var ans: T
    z = (y - x - 1)
    x2 = x * x
    x3 = x2 * x
    x4 = x3 * x
    x5 = x4 * x
    x6 = x5 * x
    x7 = x6 * x
    x8 = x7 * x
    x9 = x8 * x
    x2p1 = 2 * x + 1
    // due to a compiler bug in Xcode 10 beta 6 -> Expression too complex
    var ex1, ex2, ex3, ex4, ex5, ex6, ex7, ex8, ex9, ex10, ex11, ex12: T
    if abs(z) < makeFP(0.05) {
        ck[0] = 1
        ck[1] =  -T.third * ( 3 * x + 1)
        ck[2] = makeFP(1.0 / 36.0) * (72 * x2 + 42 * x + 7)
        ex1 = makeFP(1.0 / 540.0)
        ex2 = 2700 * x3
        ex3 = 2142 * x2
        ex4 = 657 * x
        ck[3] = -ex1 * (ex2 + ex3 + ex4 + 73)
        ex1 = makeFP(1.0 / 12960.0)
        ex2 = 1331
        ex3 = 15972 * x
        ex4 = 76356 * x2
        ex5 = 177552 * x3
        ex6 = 181440 * x4
        ck[4] = ex1 * (ex2 + ex3 + ex4 + ex5 + ex6)
        ex1 = makeFP(1.0/272160.0)
        ex2 = 22409
        ex3 = 336135 * x
        ex4 = 2115000 * x2
        ex5 = 7097868 * x3
        ex6 = 13105152 * x4
        ex7 = 11430720 * x5
        ck[5] = -ex1 * (ex2 + ex3 + ex4 + ex5 + ex6 + ex7)
        ex1 = makeFP(1.0/5443200.0)
        ex2 = 6706278 * x
        ex3 = ex2 + 52305684 * x2
        ex4 = ex3 + 228784392 * x3
        ex5 = ex4 + 602453376 * x4
        ex6 = ex5 + 935038080 * x5
        ex7 = ex6 + 718502400 * x6
        ex8 =  ex7 + 372571
        ck[6] = ex1 * (ex8)
        ex1 = makeFP(1.0 / 16329600.0)
        ex2 = 953677
        ex3 = ex2 + 20027217 * x
        ex4 = ex3 + 186346566 * x2
        ex5 = ex4 + 1003641768 * x3
        ex6 = ex5 + 3418065864 * x4
        ex7 = ex6 + 7496168976 * x5
        ex8 = ex7 + 10129665600 * x6
        ex9 = ex8 + 7005398400 * x7
        ck[7] = -ex1 * (ex9)
        ex1 = makeFP(1.0 / 783820800.0)
        ex2 = 39833047
        ex3 = ex2 + 955993128 * x
        ex4 = ex3 + 1120863744000 * x8
        ex5 = ex4 + 10332818424 * x2
        ex6 = ex5 + 66071604672 * x3
        ex7 = ex6 + 275568952176 * x4
        ex8 = ex7 + 776715910272 * x5
        ex9 = ex8 + 1472016602880 * x6
        ex10 = ex9 + 1773434373120 * x7
        ck[8] = ex1 * (ex10)
        ex1 = makeFP(1.0 / 387991296000.0)
        ex2 = 17422499659
        ex3 = ex2 + 470407490793 * x
        ex4 = ex3 + 3228423729868800 * x8
        ex5 = ex4 + 1886413681152000 * x9
        ex6 = ex5 + 5791365522720 * x2
        ex7 = ex6 + 42859969263000 * x3
        ex8 = ex7 + 211370902874640 * x4
        ex9 = ex8 + 726288467241168 * x5
        ex10 = ex9 + 1759764571151616 * x6
        ex11 = ex10 + 2954947944510720 * x7
        ck[9] = -ex1 * (ex11)
        ex1 = makeFP(1.0/6518253772800.0)
        ex2 = 261834237251
        ex3 = ex2 + 7855027117530 * x
        ex4 = ex3 + 200149640441008128 * x8
        ex5 = ex4 + 200855460151664640 * x9
        ex6 = ex5 + 109480590367948800 * x10
        ex7 = ex6 + 108506889674064 * x2
        ex8 = ex7 + 912062714644368 * x3
        ex9 = ex8 + 5189556987668592 * x4
        ex10 = ex9 + 21011917557260448 * x5
        ex11 = ex10 + 61823384007654528 * x6
        ex12 = ex11 + 132131617757148672 * x7
        ck[10] = ex1 * (ex12)
        z2 = z / (x2p1 * x2p1)
        S=1
        t=1
        k=1
        while ((abs(t) > makeFP(1.0e-15)) && (k < 11)) {
            t = ck[k] * pow1(z2, makeFP(k))
            S = S + t
            k = k + 1
        }
        ans = -z / sqrt(x2p1) * S
    }
    else {
        w = sqrt(1 + 4 * x * y)
        ans = sqrt(2 * (x + y - w - log1(2 * y / (1 + w))))
        if (x + 1 < y) {
            ans = -ans
        }
    }
    return ans
}

fileprivate func chepolsum<T: SSFloatingPoint>(_ n: Int,_ t: T,_ ak: Array<T>) -> T {
    var u0, u1, u2, s, tt: T
    var k: Int
    u0 = 0
    u1 = 0
    k = n
    tt = t+t
    while (k >= 0) {
        u2 = u1
        u1 = u0
        u0 = tt * u1 - u2 + ak[k]
        k = k - 1
    }
    s = (u0 - u2) / 2
    return s
}


fileprivate func chepolsum1<T: SSFloatingPoint>(_ n: Int, _ x: T,_ a: [T]) -> T {
    var res: T
    var h, r, s, tx: T
    //!{a[0]/2+a[1]T1(x)+...a[n]Tn(x); series of Chebychev polynomials}
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


fileprivate func oddchepolsum<T: SSFloatingPoint>(_ n: Int, _ x: T, _ ak: Array<T>) -> T {
    var h, r, s, y: T
    var k: Int
    if (n==0) {
        s = ak[0] * x
    }
    else if (n == 1) {
        s = x * ( ak[0] + ak[1] * ( 4 * x * x - 3))
    }
    else {
        y = 2 * ( 2 * x * x - 1)
        r = ak[n]
        h = ak[n-1] + r * y
        k=n-2
        while (k >= 0) {
            s = r
            r = h
            h = ak[k] + r * y - s
            k = k - 1
        }
        s = x * (h - r)
    }
    return s
}


fileprivate func logoneplusx<T: SSFloatingPoint>(_ t: T) -> T {
    return log1p1(t)
//    var ck: Array<T> = Array<T>.init(repeating: 0, count: 100)
//    var c, p, p2, pj, x, y: T
//    var j: Int
//    if ((makeFP(-0.2928) < t) && (t < makeFP(0.4142))) {
//        p = makeFP(1.18920711500272106671749997056047591529)
//        p = (p - 1) / (p + 1)
//        pj=p
//        ck[0] = pj
//        p2 = p * p
//        j = 1
//        c = 1
//        while (abs(c) > T.ulpOfOne) {
//            pj = pj * p2
//            c = pj / (2 * makeFP(j) + 1)
//            ck[j] = c
//            j = j + 1
//        }
//        x = t / (2 + t) * (1 + p2 ) / (2 * p)
//        y = 4 * oddchepolsum(j - 1, x, ck)
//    }
//    else {
//        y = log1( 1 + t)
//    }
//    return y
}

fileprivate func xminsinx<T: SSFloatingPoint>(_ x: T) -> T {
//    !  {(x-sin(x))/(x^3/6)
    var f: T
    var fk: Array<T> = Array<T>.init(repeating: 0, count: 8)
    var t: T
    if (abs(x) > 1) {
        f = 6 * (x - sin1(x)) / (x * x * x)
    }
    else {
        fk[0] = makeFP(1.95088260487819821294e-0)
        fk[1] = makeFP(-0.244124470324439564863e-1)
        fk[2] = makeFP(0.14574198156365500e-3)
        fk[3] = makeFP(-0.5073893903402518e-6)
        fk[4] = makeFP(0.11556455068443e-8)
        fk[5] = makeFP(-0.185522118416e-11)
        fk[6] = makeFP(0.22117315e-14)
        fk[7] = makeFP(-0.2035e-17)
        fk[8] = makeFP(0.15e-20)
        t = 2 * x * x - 1
        f = chepolsum(8, t, fk)
    }
    return f
    
}

fileprivate func integrand<T: SSFloatingPoint>(_ theta: T,_ b0: inout T,_ inte: inout T,_ xis2: T,_ mu: T,_ wxis: T,_ ys: T)  {
    var eps, lneps, psitheta, p, ft, f, theta2, sintheta, costheta: T
    var term1, term2, sinth, dr, s2, wx, ts, rtheta, xminsinxtheta: T
    eps = makeFP(1.0e-16)
    lneps = log1(eps)
    var ex1, ex2, ex3, ex4: T
    if (theta > b0) {
        f = 0
    }
    else if (abs(theta) < makeFP(1.0e-10)) {
            rtheta = (1 + wxis) / (2 * ys)
            theta2 = theta * theta
            psitheta = -wxis * theta2 * T.half
            f = rtheta / (1 - rtheta) * exp1(mu * psitheta)
    }
    else {
        theta2 = theta * theta
        sintheta = sin1(theta)
        costheta = cos1(theta)
        ts = theta / sintheta
        s2 = sintheta * sintheta
        wx = sqrt(ts * ts + xis2)
        xminsinxtheta = xminsinx(theta)
        ex1 = xminsinxtheta * theta2
        ex2 = ts / 6
        p = ex1 * ex2
        ex1 = p * (ts + 1)
        ex2 = theta2 - s2 * xis2
        ex3 = costheta * wx + wxis
        term1 = ((ex1 - ex2) / (ex3))
        ex1 = (ts + 1) / (wx + wxis)
        ex2 = p * (1 + ex1)
        p = (ex2 / (1 + wxis))
        term2 = -logoneplusx(p)
        p = term1 + term2
        psitheta = p
        f = mu * psitheta
        if (f > lneps) {
            f = exp1(f)
        }
        else {
            f = 0
            b0 = min(theta, b0)
        }
        rtheta = (ts + wx)/(2 * ys)
        sinth = sin1(theta / 2)
        ex1 = 2 * theta * sinth * sinth
        ex2 = xminsinxtheta * theta2 * theta / 6
        p = (ex1 - ex2) / (2 * ys * s2)
        dr = p * (1 + ts / wx)
        ex1 = dr * sintheta
        ex2 = costheta-rtheta
        ex3 = rtheta - 2 * costheta
        p=((ex1 + (ex2) * rtheta)/(rtheta * ex3 + 1))
        ft = p
        f = f * ft
    }
    inte = f
}

fileprivate func trapsum<T: SSFloatingPoint>(_ a: T, _ b: T, _ h: T, _ d: T,_ xis2: T,_ mu: T,_ wxis: T,_ ys: T) -> T {
    var trapsum, b0, inte, s, aa, bb: T
    inte = 0
    b0 = 0
    s = 0
    b0 = b
    if (d.isZero) {
//        integra
//        CALL integrand(a,b0,inte,xis2,mu,wxis,ys)
        integrand(a, &b0, &inte, xis2, mu, wxis, ys)
        s = inte / 2
        aa = a + h
        bb = b - h / 2
    }
    else {
        aa = a + d
        bb = b
    }
    while ((aa < bb) && (aa < b0)) {
        integrand(aa,&b0,&inte,xis2,mu,wxis,ys)
        s = s + inte
        aa = aa + h
    }
    trapsum = s * h
    return trapsum
}

fileprivate func trap<T: SSFloatingPoint>(_ a: T, _ b: T,_  e: T, _ xis2: T, _ mu: T, _ wxis: T, _ ys: T) -> T {
    var trap, h, p, q, v, nc: T
    h = (b - a) / 8
    p = trapsum(a,b,h,0,xis2,mu,wxis,ys)
    nc = 0
    v = 1
    while (((v > e) && (nc < 10)) || (nc <= 2)) {
        nc = nc + 1
        q = trapsum(a,b,h,h/2,xis2,mu,wxis,ys)
        if (abs(q) > 0) {
            v = abs(p / q - 1)
        }
        else {
            v = 0
        }
        h = h / 2
        p = (p + q) / 2
    }
    trap = p
    return trap
}

fileprivate func qser<T: SSFloatingPoint>(_ mu: T,_ x: T,_ y: T,_ p: inout T,_ q: inout T,_ ierro: inout Int) -> (p: T, q: T) {
/*    !----------------------------------------------------
    ! Computes the series expansion for Q.
        ! For computing the incomplete gamma functions we
        ! use the routine incgam included in the module
        ! IncgamFI. Reference: A. Gil, J. Segura and
        ! NM Temme, Efficient and accurate algorithms for
! the computation and inversion of the incomplete
! gamma function ratios. SIAM J Sci Comput.
!----------------------------------------------------
 */
    var delta, lh0, h0, q0, xy: T
    var x1, p1, q1, t, k, S, a: T
    var n, m, ierr: Int
    ierr = 0
    var conv: Bool = false
    let dwarf: T = T.ulpOfOne * 10
    let epss: T = makeFP(1e-15)
    // FIXME:
    p = gammaNormalizedP(x: y, a: mu, converged: &conv)
    q = gammaNormalizedQ(x: y, a: mu, converged: &conv)
//    CALL incgam(mu,y,p,q,ierr)
    q0 = q
    lh0 = mu * log1(y) - y - lgamma1(mu + 1)
    if ((lh0 > log1(dwarf)) && ( x < 100)) {
        h0 = exp1(lh0)
        n = 0
        xy = x * y
        delta = epss / 100
        while ((q0 / q > delta) && (n < 1000)) {
            q0 = x * (q0 + h0) / makeFP(n + 1)
            h0 = xy * h0 / (makeFP(n + 1) * (mu + makeFP(n + 1)))
            q = q + q0
            n = n + 1
        }
        q = exp1(-x) * q
        p = 1
    }
    else {
        // ! Computing Q forward
        x1 = y
        S = 0
        t = 1
        k = 0
        m = 0
        while ((k < 10000) && (m == 0)) {
            a = mu + k
            q1 = gammaNormalizedQ(x: x1, a: a, converged: &conv)
            p1 = gammaNormalizedP(x: x1, a: a, converged: &conv)
//            CALL  incgam(a,x1,p1,q1,ierr)
            t = dompart(k,x,false) * q1
            S = S + t
            k = k + 1
            if (S.isZero && (k > 150)) {
                m = 1
            }
            if (S > 0) {
                if (((t / S) < makeFP(1e-16)) && (k > 10)) {
                    m=1
                }
            }
        }
        if (ierr == 0) {
            q = S
            p = 1 - q
        }
        else {
            q = 0
            p = 1
            ierro = 1
        }
    }
    return (p: p, q: q)
}

fileprivate func dompart<T: SSFloatingPoint>(_ a: T,_ x: T,_ qt: Bool) -> T {
    //! dompart is approx. of  x^a * exp(-x) / gamma(a+1)
    var lnx, c, dp, la, mu, r: T
    var res: T
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
        r = r - T.half * log1(makeFP(6.2832) * a)
    }
    if (r < -300) {
        dp = 0
    } else {
        dp = exp1(r)
    }
    if (qt) {
        res = dp
    } else {
        if ((a < 3) || (x < makeFP(0.2))) {
            res = exp1(a * lnx - x) / tgamma1(a + 1)
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

fileprivate func lnec<T: SSFloatingPoint>(_ x: T) -> T {
    //IMPLICIT NONE
    var ln1, y0, z, e2, r, s: T
    z = log1p1(x)
    y0 = z - x
    e2 = exmin1minx(z, T.ulpOfOne)
    s = e2 * z * z / 2
    r = (s + y0) / (s + 1 + z)
    ln1 = y0 - r * (6 - r) / (6 - 4 * r)
    return ln1;
}

fileprivate func gamstar<T: SSFloatingPoint>(_ x: T) -> T {
    //    !  {gamstar(x)=exp(stirling(x)), x>0; or }
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


fileprivate func stirling<T:SSFloatingPoint>(_ x: T) -> T {
    //    !{Stirling series, function corresponding with}
    //    !{asymptotic series for log(gamma(x))}
    //    !{that is:  1/(12x)-1/(360x**3)...; x>= 3}
    var res, z: T
    var a: Array<T> = Array<T>.init(repeating: 0, count: 18)
    var c: Array<T> = Array<T>.init(repeating: 0, count: 7)
    
    var ex1, ex2, ex3, ex4, ex5, ex6: T
    let dwarf = T.ulpOfOne * 10
    if (x < dwarf) {
        res = T.greatestFiniteMagnitude
    } else if (x < 1) {
        res = lgamma1(x + 1) - (x + T.half) * log1(x) + x - T.lnsqrt2pi
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
        res = chepolsum1(17,z,a) / (12 * x)
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
            ex1 = c[5] * z + c[4]
            ex2 = z + c[3]
            ex3 = z + c[2]
            ex4 = z + c[1]
            ex5 = z + c[0]
            ex6 = c[6] + z
            res=((ex1 * ex2 * ex3 * ex4 * ex5) / (ex6) / x)
        } else {
            ex1 = -z / 1680 + 1 / 1260
            ex2 = z - 1/360
            ex3 = z + 1/12
            res = (((ex1) * ex2) * ex3) / x
        }
    }
    return res;
}

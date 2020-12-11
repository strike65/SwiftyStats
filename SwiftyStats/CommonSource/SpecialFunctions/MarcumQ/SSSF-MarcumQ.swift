//
//  Created by VT on 03.09.18.
//  Copyright © 2018 strike65. All rights reserved.
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

extension SSSpecialFunctions {
    
    // MARK: Marcum Functions
    
    /// Computes the Marcum-Functions P(µ,x,y) and Q(µ,x,y)
    /// - Parameter mu: Parameter µ
    /// - Parameter x: Parameter x
    /// - Parameter y: Parameter y
    /// - Returns: (p: T, q: T, err: Int, underflow: false)
    ///
    ///     err = 0: there are no errors
    ///
    ///     err = 1: Under-/Overflow problems. The function values are set to zero
    ///
    ///     err = 2: At least one parameter is out of range. The function values are set to zero
    /// - Warning: In order to avoid overflow/underflow problems the admissible parameter ranges are
    ///
    /// 0 <= x <= 10000,    0 <= y <= 10000,      0 <= µ <= 10000
    ///
    /// - Authors:
    /// The original authors of the algorithms (and the FORTRAN module) are (Gil, Segura, Temme: Algorithm 993: Computation of the Marcum Q-function. Nov. 2013. ACM Trans Math Soft):
    /// Amparo Gil    (U. Cantabria, Santander, Spain)
    ///
    /// Javier Segura (U. Cantabria, Santander, Spain)
    ///
    /// Nico M. Temme (CWI, Amsterdam, The Netherlands)
    ///
    /// Copyright Swift Version: strike65, 2018
    ///
    /// - Note:
    /// The present code uses different methods of computation
    /// depending on the values of mu, x and y: series expansions in terms
    /// of incomplete gamma functions, integral representations,
    /// asymptotic expansions, and use of three-term homogeneous
    /// recurrence relations.
    /// The current algorithm is valid for Single and Double precision. The relative error is close to 10^-11 and 10^-15, if the results are larger than 10^-290.
    /// Results for p and q smaller than 10^-290 are set to zero.
    /// Due to current compiler restrictions, the function fjkproc16() is divided into small parts.
    /// - TODO:
    /// Adapt the algorithm for long double (Float80) precision.
    internal static func marcum<T: SSFloatingPoint>(_ mu: T, _ x: T, _ y: T) -> (p: T, q: T, err: Int, underflow: Bool) {
        //! -------------------------------------------------------------
        //! Calculation of the Marcum Q-functions P_mu(x,y) and Q_mu(x,y).
        //!
        //! In order to avoid, overflow/underflow problems in IEEE double
        //!  precision arithmetic, the admissible parameter ranges
        //!  for computation are:
        //!
        //!      0<=x<=10000,   0<=y<=10000,    1<=mu<=10000
        //!
        //!  The aimed relative accuracy is close to 1.0e-11 in the
        //!  previous parameter domain.
        //! -------------------------------------------------------------
        //! Inputs:
        //!   mu ,   argument of the functions
        //!   x ,    argument of the functions
        //!   y ,    argument of the functions
        //!
        //! Outputs:
        //!   p,     function P_mu(a,x)
        //!   q,     function Q_mu(a,x)
        //!   ierr , error flag
        //!          ierr=0, computation succesful
        //!          ierr=1, Underflow problems. The function values
        //!                  are set to zero and one.
        //!          ierr=2, any of the arguments of the function is
        //!                  out of range. The function values
        //!                  (P_mu(a,x) and Q_mu(a,x)) are set to zero.
        //! --------------------------------------------------------------------
        //!           METHODS OF COMPUTATION
        //! --------------------------------------------------------------------
        //! The present code uses different methods of computation
        //! depending on the values of mu, x and y: series expansions in terms
        //! of incomplete gamma functions, integral representations,
        //! asymptotic expansions, and use of three-term homogeneous
        //! recurrence relations.
        //!
        /// NOT
        //!---------------------------------------------------------------------
        //!     RELATION WITH OTHER STANDARD NOTATION FOR THE
        //!     GENERALIZED MARCUM FUNCTIONS
        //!---------------------------------------------------------------------
        //!  The relation with the Marcum functions computed by
        //!  Matlab or Mathematica (QM_(mu)(x,y),PM_(mu)(x,y))
        //!  is the following:
        //!
        //!        Q_(mu)(x,y)=QM_(mu)(sqrt(2*x),sqrt(2*y))
        //!
        //!   and similarly for the P function.
        //! --------------------------------------------------------------------
        //! Authors:
        //!
        //!  Amparo Gil    (U. Cantabria, Santander, Spain)
        //!                 e-mail: amparo.gil@unican.es
        //!  Javier Segura (U. Cantabria, Santander, Spain)
        //!                 e-mail: javier.segura@unican.es
        //!  Nico M. Temme (CWI, Amsterdam, The Netherlands)
        //!                 e-mail: nico.temme@cwi.nl
        //! ---------------------------------------------------------------
        //!  References:
        //!  1. A. Gil, J. Segura and N.M. Temme, Accompanying paper in
        //!     ACM Trans Math Soft
        //!  2. A. Gil, J. Segura and N.M. Temme. Efficient and accurate
        //!     algorithms for the computation and inversion
        //!     of the incomplete gamma function ratios. SIAM J Sci Comput.
        //!     (2012) 34(6), A2965-A2981
        //! ---------------------------------------------------------------
        var p,q,b,w,xi,y0,y1,mulim: T
        var ierr: Int = 0
        let xx: T = (x * x) / 2
        let yy: T = (y * y) / 2
        var ex1: T
        var ex2: T
        var ex3: T
        p = T.zero
        q = T.zero
        if (((xx > 10000) || (yy > 10000)) || (mu > 10000)) {
            p = T.zero
            q = T.zero
            ierr = 2
        }
        if (((xx < 0) || (yy < 0)) || (mu < 1)) {
            p = T.zero
            q = T.zero
            ierr = 2
        }
        ierr = 0
        if (ierr == 0) {
            mulim = 135
            b = 1
            ex1 =  Helpers.makeFP(4) * xx
            ex2 =  Helpers.makeFP(2) * mu
            ex3 = ex1 + ex2
            w = b * sqrt(ex3)
            xi = 2 * sqrt(xx * yy)
            y0 = xx + mu - w
            y1 = xx + mu + w
            if ((yy > (xx + mu)) && (xx < 30)) {
                //! Series for Q in terms of ratios of Gamma functions
                qser(mu,xx,yy,&p,&q,&ierr)
            } else if ((yy <= (xx + mu)) && (xx < 30)) {
                //! Series for P in terms of ratios of Gamma functions
                pser(mu,xx,yy,&p,&q,&ierr)
            } else if (((mu * mu) < (2 * xi)) && (xi > 30)) {
                //! Asymptotic expansion for xy large
                pqasyxy(mu,xx,yy,&p,&q,&ierr)
            } else if (((mu >= mulim) && (y0 <= yy)) && (yy <= y1)) {
                //! Asymptotic expansion for mu large
                pqasymu(mu,xx,yy,&p,&q,&ierr)
            } else if (((yy <= y1) && (yy > (xx + mu))) && (mu < mulim)) {
                //! Recurrence relation for Q
                qrec(mu,xx,yy,&p,&q,&ierr)
            } else if  (((yy >= y0) && (yy <= (xx + mu))) && (mu < mulim)) {
                //! Recurrence relation for P
                prec(mu,xx,yy,&p,&q,&ierr)
            }
            else {
                //! Integral representation
                MarcumPQtrap(mu,xx,yy,&p,&q,&ierr)
            }
        }
        var underflow: Bool = false
        if (ierr == 0) {
            if (p <  Helpers.makeFP(1e-290)) {
                p = T.zero
                q = 1
                ierr = 1
            }
            if (q <  Helpers.makeFP(1e-290)) {
                q = T.zero
                p = 1
                ierr = 1
            }
        }
        if (ierr == 1) {
            underflow = true
        }
        return (p: p, q: q, err: ierr, underflow: underflow)
    }
}


fileprivate func epss<T: SSFloatingPoint>() -> T {
    return  Helpers.makeFP(1E-15)
}

/** Evaluation of the cf for the ratio Ipnu(z)/Ipnu-1(z)
 We use Lentz-Thompson algorithm.
 */
fileprivate func fc<T: SSFloatingPoint>(_ pnu: T, _ z: T) -> T {
    var fc,b,a,c0,d0,delta: T
    var m: Int
    let dwarf: T = T.ulpOfOne * 10
    m = 0
    b = 2 * pnu / z
    a = 1
    fc = dwarf
    c0 = fc
    d0 = T.zero
    delta = T.zero
    let eps:T = epss()
    while (abs(delta - 1) > eps) {
        d0 = b + a * d0
        if(abs(d0) < dwarf) {
            d0=dwarf
        }
        c0 = b + a / c0
        if(abs(c0) < dwarf) {
            c0 = dwarf
        }
        d0 = 1 / d0
        delta = c0 * d0
        fc = fc * delta
        m = m + 1
        a = 1
        b = 2 * (pnu +  Helpers.makeFP(m)) / z
    }
    return fc
}



//!---------------------------------------------------------
//! Computes a starting value for the backward summation of
//! the series in pmuxyser
//!---------------------------------------------------------
fileprivate func nmax<T: SSFloatingPoint>(_ mu: T, _ x: T, _ y: T) -> Int {
    var lneps, c, n, n1: T
    var nmax: Int
    var ex1, ex2, ex3, ex21, ex22 : T
    lneps = -36
    ex1 = -mu + y
    ex2 = -mu * SSMath.log1(y)
    c = ex1 + ex2 + lneps
    ex1 = mu * mu + 4 * x * y
    ex2 = -mu + sqrt(ex1)
    n = 10 + 2 * ex2
    n1 = T.zero
    while ((abs(n - n1) > 1) && (n > 0)) {
        ex1 = SSMath.log1(mu + n) * mu
        ex2 = ex1 - 2 * n + c
        ex21 = n / (x * y)
        ex22 = mu + n
        ex3 = SSMath.log1(ex21) + SSMath.log1(ex22)
        n = -ex1 / ex3
    }
    if (n < 0) {
        n = T.zero
    }
    nmax = Helpers.integerValue(n) + 1
    return nmax
}


fileprivate func factor<T: SSFloatingPoint>(_ x: T, _ n: Int) -> T {
    var facto: T
    facto = 1
    for i in stride(from: 1, through: n, by: 1) {
        //    for (i=1; i <= n; i++) {
        facto = facto * ( x /  Helpers.makeFP(i))
    }
    return facto
}

fileprivate func pol<T: SSFloatingPoint>(_ fjkm: Array<T>, _ d: Int, _ v: T) -> T {
    var s: T
    var m: Int
    m = d
    s = fjkm[d]
    while (m > 0) {
        m = m - 1
        s = s * v + fjkm[m]
    }
    return s
}
// Due to current compiler restrictions, the original procedure fjkporc16 has been splitted into multiple parts.
fileprivate func fjkproc16_001<T: SSFloatingPoint>(fjk: inout Array<Array<T>>, un: Array<T>, v: T) {
    var d, j, k: Int
    var fjkm:Array<T> = Array<T>.init(repeating: 0, count: 33)
    fjkm[0] = T.half
    fjkm[1] = T.oo6
    j = 1
    k = 0
    d = j + 2 * k
    fjk[j][k] = un[d] * pol(fjkm, d, v)
    
    // 002
    fjkm[0] =  Helpers.makeFP(-0.125)
    fjkm[1] = 0
    fjkm[2] =  Helpers.makeFP(2.083333333333333333333e-1)
    j = 2
    k = 0
    d = j + 2 * k
    fjk[j][k] = un[d] * pol(fjkm,d,v)
    
    fjkm[0] =  Helpers.makeFP(0.0625)
    fjkm[1] =  Helpers.makeFP(-0.54166666666666666667e-1)
    fjkm[2] =  Helpers.makeFP(-0.31250000000000000000)
    fjkm[3] =  Helpers.makeFP(0.28935185185185185185)
    j = 3
    k = 0
    d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v)
    
    // A03
    fjkm[0] =  Helpers.makeFP(-0.39062500000000000000e-1)
    fjkm[1] =  Helpers.makeFP(0.83333333333333333333e-1)
    fjkm[2] =  Helpers.makeFP(0.36631944444444444444)
    fjkm[3] =  Helpers.makeFP(-0.83333333333333333333)
    fjkm[4] =  Helpers.makeFP(0.42390046296296296296)
    j = 4; k = 0; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v)
    
    // A04
    fjkm[0] =  Helpers.makeFP(0.27343750000000000000e-1)
    fjkm[1] =  Helpers.makeFP(-0.10145089285714285714)
    fjkm[2] =  Helpers.makeFP(-0.38281250000000000000)
    fjkm[3] =  Helpers.makeFP(1.6061921296296296296)
    fjkm[4] =  Helpers.makeFP(-1.7903645833333333333)
    fjkm[5] =  Helpers.makeFP(0.64144483024691358025)
    j = 5; k = 0; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v)
    
    // A05
    fjkm[0] =  Helpers.makeFP(-0.20507812500000000000e-1)
    fjkm[1] =  Helpers.makeFP(0.11354166666666666667)
    fjkm[2] =  Helpers.makeFP(0.36983072916666666667)
    fjkm[3] =  Helpers.makeFP(-2.5763888888888888889)
    fjkm[4] =  Helpers.makeFP(4.6821108217592592593)
    fjkm[5] =  Helpers.makeFP(-3.5607638888888888889)
    fjkm[6] =  Helpers.makeFP(0.99199861754115226337)
    j = 6; k = 0; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v)
    
    // A06
    fjkm[0] =  Helpers.makeFP(0.16113281250000000000e-1)
    fjkm[1] =  Helpers.makeFP(-0.12196955605158730159)
    fjkm[2] =  Helpers.makeFP(-0.33297526041666666667)
    fjkm[3] =  Helpers.makeFP(3.7101836350859788360)
    fjkm[4] =  Helpers.makeFP(-9.7124626253858024691)
    fjkm[5] =  Helpers.makeFP(11.698143727494855967)
    fjkm[6] =  Helpers.makeFP(-6.8153513213734567901)
    fjkm[7] =  Helpers.makeFP(1.5583573120284636488)
    j = 7; k = 0; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v)
    // A07
    fjkm[0] =  Helpers.makeFP(-0.13092041015625000000e-1)
    fjkm[1] =  Helpers.makeFP(0.12801339285714285714)
    fjkm[2] =  Helpers.makeFP(0.27645252046130952381)
    fjkm[3] =  Helpers.makeFP(-4.9738777281746031746)
    fjkm[4] =  Helpers.makeFP(17.501935105096726190)
    fjkm[5] =  Helpers.makeFP(-29.549479166666666667)
    fjkm[6] =  Helpers.makeFP(26.907133829250257202)
    fjkm[7] =  Helpers.makeFP(-12.754267939814814815)
    fjkm[8] =  Helpers.makeFP(2.4771798425577632030)
    j = 8; k = 0; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    // A08
    fjkm[0] =  Helpers.makeFP(0.10910034179687500000e-1)
    fjkm[1] =  Helpers.makeFP(-0.13242874035415539322)
    fjkm[2] =  Helpers.makeFP(-0.20350690569196428571)
    fjkm[3] =  Helpers.makeFP(6.3349384739790013228)
    fjkm[4] =  Helpers.makeFP(-28.662114811111800044)
    fjkm[5] =  Helpers.makeFP(63.367483364421434083)
    fjkm[6] =  Helpers.makeFP(-79.925485618811085391)
    fjkm[7] =  Helpers.makeFP(58.757341382271304870)
    fjkm[8] =  Helpers.makeFP(-23.521455678429623200)
    fjkm[9] =  Helpers.makeFP(3.9743166454849898231)
    j = 9; k = 0; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    // A09
    fjkm[0] =  Helpers.makeFP(-0.92735290527343750000e-2)
    fjkm[1] =  Helpers.makeFP(0.13569064670138888889)
    fjkm[2] =  Helpers.makeFP(0.11668911254144670021)
    fjkm[3] =  Helpers.makeFP(-7.7625075954861111111)
    fjkm[4] =  Helpers.makeFP(43.784562625335567773)
    fjkm[5] =  Helpers.makeFP(-121.31910738398368607)
    fjkm[6] =  Helpers.makeFP(198.20121981295421734)
    fjkm[7] =  Helpers.makeFP(-200.43673900016432327)
    fjkm[8] =  Helpers.makeFP(123.80342757950794259)
    fjkm[9] =  Helpers.makeFP(-42.937783937667895519)
    fjkm[10] =  Helpers.makeFP(6.4238224989853211488)
    j = 10; k = 0; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    // A10
    fjkm[0] =  Helpers.makeFP(0.80089569091796875000e-2)
    fjkm[1] =  Helpers.makeFP(-0.13811212730852318255)
    fjkm[2] =  Helpers.makeFP(-0.18036238655211433532e-1)
    fjkm[3] =  Helpers.makeFP(9.2275853445797140866)
    fjkm[4] =  Helpers.makeFP(-63.433189058657045718)
    fjkm[5] =  Helpers.makeFP(213.60596888977804302)
    fjkm[6] =  Helpers.makeFP(-432.96183396641609600)
    fjkm[7] =  Helpers.makeFP(563.58282810729226948)
    fjkm[8] =  Helpers.makeFP(-476.64858951490111802)
    fjkm[9] =  Helpers.makeFP(254.12602383553942414)
    fjkm[10] =  Helpers.makeFP(-77.797248335368675787)
    fjkm[11] =  Helpers.makeFP(10.446593930548512362)
    j = 11; k = 0; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    // A11
    fjkm[0] =  Helpers.makeFP(-0.70078372955322265625e-2)
    fjkm[1] =  Helpers.makeFP(0.13990718736965074856)
    fjkm[2] =  Helpers.makeFP(-0.90802493534784075207e-1)
    fjkm[3] =  Helpers.makeFP(-10.703046719402920575)
    fjkm[4] =  Helpers.makeFP(88.139055705916160082)
    fjkm[5] =  Helpers.makeFP(-352.55365414896970073)
    fjkm[6] =  Helpers.makeFP(860.26747669490580229)
    fjkm[7] =  Helpers.makeFP(-1381.3884907075539460)
    fjkm[8] =  Helpers.makeFP(1497.5262381375579615)
    fjkm[9] =  Helpers.makeFP(-1089.5695395426785795)
    fjkm[10] =  Helpers.makeFP(511.32054028583482617)
    fjkm[11] =  Helpers.makeFP(-140.15612725058882506)
    fjkm[12] =  Helpers.makeFP(17.075450695147740963)
    j = 12; k = 0; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    // A12
    fjkm[0] =  Helpers.makeFP(0.61992406845092773438e-2)
    fjkm[1] =  Helpers.makeFP(-0.14122658948520402530)
    fjkm[2] =  Helpers.makeFP(0.20847570003254474385)
    fjkm[3] =  Helpers.makeFP(12.163573370672875144)
    fjkm[4] =  Helpers.makeFP(-118.39689039212288489)
    fjkm[5] =  Helpers.makeFP(552.67487991757989471)
    fjkm[6] =  Helpers.makeFP(-1587.5976792806460534)
    fjkm[7] =  Helpers.makeFP(3052.8623335041016490)
    fjkm[8] =  Helpers.makeFP(-4067.0706975337409188)
    fjkm[9] =  Helpers.makeFP(3781.4312193762993828)
    fjkm[10] =  Helpers.makeFP(-2415.5306966669781670)
    fjkm[11] =  Helpers.makeFP(1012.7298787459738084)
    fjkm[12] =  Helpers.makeFP(-251.37116645382357870)
    fjkm[13] =  Helpers.makeFP(28.031797071713952493)
    j = 13; k = 0; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    // A13
    fjkm[0] =  Helpers.makeFP(-0.55350363254547119141e-2)
    fjkm[1] =  Helpers.makeFP(0.14217921713372686883)
    fjkm[2] =  Helpers.makeFP(-0.33386405994128191388)
    fjkm[3] =  Helpers.makeFP(-13.585546133738642981)
    fjkm[4] =  Helpers.makeFP(154.66282442015249412)
    fjkm[5] =  Helpers.makeFP(-830.71069930083407076)
    fjkm[6] =  Helpers.makeFP(2761.0291182562342601)
    fjkm[7] =  Helpers.makeFP(-6219.8351157050681259)
    fjkm[8] =  Helpers.makeFP(9888.1927799238643295)
    fjkm[9] =  Helpers.makeFP(-11266.694472611704499)
    fjkm[10] =  Helpers.makeFP(9175.5017581920039296)
    fjkm[11] =  Helpers.makeFP(-5225.7429703251833306)
    fjkm[12] =  Helpers.makeFP(1980.4053574007652015)
    fjkm[13] =  Helpers.makeFP(-449.21570290311749301)
    fjkm[14] =  Helpers.makeFP(46.189888661376921323)
    j = 14; k = 0; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    // A14
    fjkm[0] =  Helpers.makeFP(0.49815326929092407227e-2)
    fjkm[1] =  Helpers.makeFP(-0.14284537645361756992)
    fjkm[2] =  Helpers.makeFP(0.46603144339556328292)
    fjkm[3] =  Helpers.makeFP(14.946922390174830635)
    fjkm[4] =  Helpers.makeFP(-197.35300817536964730)
    fjkm[5] =  Helpers.makeFP(1205.6532423474201960)
    fjkm[6] =  Helpers.makeFP(-4572.9473467250314847)
    fjkm[7] =  Helpers.makeFP(11865.183572985041892)
    fjkm[8] =  Helpers.makeFP(-22026.784993357215819)
    fjkm[9] =  Helpers.makeFP(29873.206689727991728)
    fjkm[10] =  Helpers.makeFP(-29749.925047590507307)
    fjkm[11] =  Helpers.makeFP(21561.076414337110462)
    fjkm[12] =  Helpers.makeFP(-11081.438701085531999)
    fjkm[13] =  Helpers.makeFP(3832.1051284526998677)
    fjkm[14] =  Helpers.makeFP(-800.40791995840375064)
    fjkm[15] =  Helpers.makeFP(76.356879052900946470)
    j = 15; k = 0; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    // A15
    fjkm[0] =  Helpers.makeFP(-0.45145140029489994049e-2)
    fjkm[1] =  Helpers.makeFP(0.14328537051348750262)
    fjkm[2] =  Helpers.makeFP(-0.60418804953366830816)
    fjkm[3] =  Helpers.makeFP(-16.227111168548122706)
    fjkm[4] =  Helpers.makeFP(246.84286168977111296)
    fjkm[5] =  Helpers.makeFP(-1698.7528990888950203)
    fjkm[6] =  Helpers.makeFP(7270.2387180078329370)
    fjkm[7] =  Helpers.makeFP(-21434.839860240815288)
    fjkm[8] =  Helpers.makeFP(45694.866035689911070)
    fjkm[9] =  Helpers.makeFP(-72195.530107556687632)
    fjkm[10] =  Helpers.makeFP(85409.022842807474925)
    fjkm[11] =  Helpers.makeFP(-75563.234444869051891)
    fjkm[12] =  Helpers.makeFP(49344.501227769590532)
    fjkm[13] =  Helpers.makeFP(-23110.149147008741710)
    fjkm[14] =  Helpers.makeFP(7349.7909384681412957)
    fjkm[15] =  Helpers.makeFP(-1422.6485707704091767)
    fjkm[16] =  Helpers.makeFP(126.58493346342458430)
    j = 16; k = 0; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    // A16
    fjkm[0] =  Helpers.makeFP(0.12500000000000000000)
    fjkm[1] = T.zero
    fjkm[2] =  Helpers.makeFP(-0.20833333333333333333)
    j = 0; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-0.62500000000000000000e-1)
    fjkm[1] =  Helpers.makeFP(0.14583333333333333333)
    fjkm[2] =  Helpers.makeFP(0.52083333333333333333)
    fjkm[3] =  Helpers.makeFP(-0.65972222222222222222)
    j = 1; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(0.46875000000000000000e-1)
    fjkm[1] =  Helpers.makeFP(-0.25000000000000000000)
    fjkm[2] =  Helpers.makeFP(-0.69791666666666666667)
    fjkm[3] =  Helpers.makeFP(2.5000000000000000000)
    fjkm[4] =  Helpers.makeFP(-1.6059027777777777778)
    j = 2; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-0.39062500000000000000e-1)
    fjkm[1] =  Helpers.makeFP(0.34218750000000000000)
    fjkm[2] =  Helpers.makeFP(0.72916666666666666667)
    fjkm[3] =  Helpers.makeFP(-5.6712962962962962963)
    fjkm[4] =  Helpers.makeFP(8.1640625000000000000)
    fjkm[5] =  Helpers.makeFP(-3.5238233024691358025)
    j = 3; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(0.34179687500000000000e-1)
    fjkm[1] =  Helpers.makeFP(-0.42708333333333333333)
    fjkm[2] =  Helpers.makeFP(-0.59798177083333333333)
    fjkm[3] =  Helpers.makeFP(10.208333333333333333)
    fjkm[4] =  Helpers.makeFP(-24.385308159722222222)
    fjkm[5] =  Helpers.makeFP(22.482638888888888889)
    fjkm[6] =  Helpers.makeFP(-7.3148750964506172840)
    j = 4; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-0.30761718750000000000e-1)
    fjkm[1] =  Helpers.makeFP(0.50665457589285714286)
    fjkm[2] =  Helpers.makeFP(0.29326171875000000000)
    fjkm[3] =  Helpers.makeFP(-16.044663008432539683)
    fjkm[4] =  Helpers.makeFP(56.156774450231481481)
    fjkm[5] =  Helpers.makeFP(-82.372823832947530864)
    fjkm[6] =  Helpers.makeFP(56.160933883101851852)
    fjkm[7] =  Helpers.makeFP(-14.669405462319958848)
    j = 5; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(0.28198242187500000000e-1)
    fjkm[1] =  Helpers.makeFP(-0.58203125000000000000)
    fjkm[2] =  Helpers.makeFP(0.19236328125000000000)
    fjkm[3] =  Helpers.makeFP(23.032335069444444444)
    fjkm[4] =  Helpers.makeFP(-110.33599717881944444)
    fjkm[5] =  Helpers.makeFP(227.74508101851851852)
    fjkm[6] =  Helpers.makeFP(-243.01300676761831276)
    fjkm[7] =  Helpers.makeFP(131.66775173611111111)
    fjkm[8] =  Helpers.makeFP(-28.734679254811814129)
    j = 6; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-0.26184082031250000000e-1)
    fjkm[1] =  Helpers.makeFP(0.65396069723462301587)
    fjkm[2] =  Helpers.makeFP(-0.86386369977678571429)
    fjkm[3] =  Helpers.makeFP(-30.956497628348214286)
    fjkm[4] =  Helpers.makeFP(194.54890778287588183)
    fjkm[5] =  Helpers.makeFP(-527.74348743041776896)
    fjkm[6] =  Helpers.makeFP(780.79702721113040123)
    fjkm[7] =  Helpers.makeFP(-656.29672278886959877)
    fjkm[8] =  Helpers.makeFP(295.22178492918917181)
    fjkm[9] =  Helpers.makeFP(-55.334928257039108939)
    j = 7; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(0.24547576904296875000e-1)
    fjkm[1] =  Helpers.makeFP(-0.72297712053571428571)
    fjkm[2] =  Helpers.makeFP(1.7246239871070498512)
    fjkm[3] =  Helpers.makeFP(39.546341145833333333)
    fjkm[4] =  Helpers.makeFP(-316.99617299397786458)
    fjkm[5] =  Helpers.makeFP(1081.5824590773809524)
    fjkm[6] =  Helpers.makeFP(-2074.4037171674994144)
    fjkm[7] =  Helpers.makeFP(2398.8177766525205761)
    fjkm[8] =  Helpers.makeFP(-1664.7533222350236974)
    fjkm[9] =  Helpers.makeFP(640.37285196437757202)
    fjkm[10] =  Helpers.makeFP(-105.19241070496638071)
    j = 8; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-0.23183822631835937500e-1)
    fjkm[1] =  Helpers.makeFP(0.78948182770700165720)
    fjkm[2] =  Helpers.makeFP(-2.7769457196432446677)
    fjkm[3] =  Helpers.makeFP(-48.483511725054617511)
    fjkm[4] =  Helpers.makeFP(486.26944746794524016)
    fjkm[5] =  Helpers.makeFP(-2023.8687997794445650)
    fjkm[6] =  Helpers.makeFP(4819.5203340475451309)
    fjkm[7] =  Helpers.makeFP(-7173.8455521540386687)
    fjkm[8] =  Helpers.makeFP(6815.5497547693867415)
    fjkm[9] =  Helpers.makeFP(-4029.1488859965138299)
    fjkm[10] =  Helpers.makeFP(1353.9765257894256969)
    fjkm[11] =  Helpers.makeFP(-197.95866455017786514)
    j = 9; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(0.22024631500244140625e-1)
    fjkm[1] =  Helpers.makeFP(-0.85378706190321180556)
    fjkm[2] =  Helpers.makeFP(4.0223697649378354858)
    fjkm[3] =  Helpers.makeFP(57.408728524667245370)
    fjkm[4] =  Helpers.makeFP(-711.17788174487525874)
    fjkm[5] =  Helpers.makeFP(3529.7027186963924024)
    fjkm[6] =  Helpers.makeFP(-10126.360073656459287)
    fjkm[7] =  Helpers.makeFP(18593.571833843032106)
    fjkm[8] =  Helpers.makeFP(-22636.974191769862737)
    fjkm[9] =  Helpers.makeFP(18256.758136740546277)
    fjkm[10] =  Helpers.makeFP(-9401.7390963482140877)
    fjkm[11] =  Helpers.makeFP(2805.1309521324368189)
    fjkm[12] =  Helpers.makeFP(-369.51173382133760772)
    j = 10; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-0.21023511886596679688e-1)
    fjkm[1] =  Helpers.makeFP(0.91614229084450603921)
    fjkm[2] =  Helpers.makeFP(-5.4618897365663646792)
    fjkm[3] =  Helpers.makeFP(-65.927090730899790043)
    fjkm[4] =  Helpers.makeFP(1000.5846459432155138)
    fjkm[5] =  Helpers.makeFP(-5819.5104958244309663)
    fjkm[6] =  Helpers.makeFP(19669.512303383909626)
    fjkm[7] =  Helpers.makeFP(-43248.109984766956219)
    fjkm[8] =  Helpers.makeFP(64686.833219925562541)
    fjkm[9] =  Helpers.makeFP(-66644.721592787005810)
    fjkm[10] =  Helpers.makeFP(46700.224876576248105)
    fjkm[11] =  Helpers.makeFP(-21305.241783200054197)
    fjkm[12] =  Helpers.makeFP(5716.0564388863858560)
    fjkm[13] =  Helpers.makeFP(-685.13376643364457482)
    j = 11; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(0.20147532224655151367e-1)
    fjkm[1] =  Helpers.makeFP(-0.97675104265089158888)
    fjkm[2] =  Helpers.makeFP(7.0960977732520869186)
    fjkm[3] =  Helpers.makeFP(73.612404446931816840)
    fjkm[4] =  Helpers.makeFP(-1363.2529599857205103)
    fjkm[5] =  Helpers.makeFP(9163.5749605651064785)
    fjkm[6] =  Helpers.makeFP(-35864.832027517679572)
    fjkm[7] =  Helpers.makeFP(92376.947946883135629)
    fjkm[8] =  Helpers.makeFP(-164834.83784046136147)
    fjkm[9] =  Helpers.makeFP(208040.74214864238663)
    fjkm[10] =  Helpers.makeFP(-185789.85543054601897)
    fjkm[11] =  Helpers.makeFP(115101.05980498683057)
    fjkm[12] =  Helpers.makeFP(-47134.497747406170101)
    fjkm[13] =  Helpers.makeFP(11488.455724263405622)
    fjkm[14] =  Helpers.makeFP(-1263.2564781342309572)
    j = 12; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-0.19372627139091491699e-1)
    fjkm[1] =  Helpers.makeFP(1.0357822247248985273)
    fjkm[2] =  Helpers.makeFP(-8.9252867409545555669)
    fjkm[3] =  Helpers.makeFP(-80.010760848208515926)
    fjkm[4] =  Helpers.makeFP(1807.7010112763722305)
    fjkm[5] =  Helpers.makeFP(-13886.239779926939526)
    fjkm[6] =  Helpers.makeFP(62074.025784691064765)
    fjkm[7] =  Helpers.makeFP(-184145.36258906485362)
    fjkm[8] =  Helpers.makeFP(383582.03973738516554)
    fjkm[9] =  Helpers.makeFP(-576038.14802241650407)
    fjkm[10] =  Helpers.makeFP(628833.57177487054480)
    fjkm[11] =  Helpers.makeFP(-495573.34466362548232)
    fjkm[12] =  Helpers.makeFP(275136.26556037481059)
    fjkm[13] =  Helpers.makeFP(-102207.94135045741701)
    fjkm[14] =  Helpers.makeFP(22823.518594320784899)
    fjkm[15] =  Helpers.makeFP(-2318.1664194368241801)
    j = 13; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(0.18680747598409652710e-1)
    fjkm[1] =  Helpers.makeFP(-1.0933780262877533843)
    fjkm[2] =  Helpers.makeFP(10.949523517716476548)
    fjkm[3] =  Helpers.makeFP(84.643531757174997082)
    fjkm[4] =  Helpers.makeFP(-2342.0651134541361650)
    fjkm[5] =  Helpers.makeFP(20369.770814493525849)
    fjkm[6] =  Helpers.makeFP(-102837.36670370684414)
    fjkm[7] =  Helpers.makeFP(346648.70123159565251)
    fjkm[8] =  Helpers.makeFP(-828961.75261733863230)
    fjkm[9] =  Helpers.makeFP(1449716.2069081751493)
    fjkm[10] =  Helpers.makeFP(-1879301.2063630471735)
    fjkm[11] =  Helpers.makeFP(1807331.1927210534022)
    fjkm[12] =  Helpers.makeFP(-1274496.0479553760313)
    fjkm[13] =  Helpers.makeFP(641015.88735632964269)
    fjkm[14] =  Helpers.makeFP(-217895.35698164739918)
    fjkm[15] =  Helpers.makeFP(44894.191761385746325)
    fjkm[16] =  Helpers.makeFP(-4236.6734164587391641)
    j = 14; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-0.18058056011795997620e-1)
    fjkm[1] =  Helpers.makeFP(1.1496596058234620572)
    fjkm[2] =  Helpers.makeFP(-13.168702574894088581)
    fjkm[3] =  Helpers.makeFP(-87.009904621222723801)
    fjkm[4] =  Helpers.makeFP(2973.9704746271364310)
    fjkm[5] =  Helpers.makeFP(-29057.863221639334277)
    fjkm[6] =  Helpers.makeFP(164134.77797509230729)
    fjkm[7] =  Helpers.makeFP(-621775.71008157787326)
    fjkm[8] =  Helpers.makeFP(1684395.4811437516714)
    fjkm[9] =  Helpers.makeFP(-3374103.7733925392782)
    fjkm[10] =  Helpers.makeFP(5084254.0101088150007)
    fjkm[11] =  Helpers.makeFP(-5797111.7426650438469)
    fjkm[12] =  Helpers.makeFP(4981685.5893221501493)
    fjkm[13] =  Helpers.makeFP(-3178510.0651440248351)
    fjkm[14] =  Helpers.makeFP(1461172.7927229457558)
    fjkm[15] =  Helpers.makeFP(-457795.06653758949338)
    fjkm[16] =  Helpers.makeFP(87552.178162658627517)
    fjkm[17] =  Helpers.makeFP(-7715.5318619797584859)
    j = 15; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(0.70312500000000000000e-1)
    fjkm[1] = T.zero
    fjkm[2] =  Helpers.makeFP(-0.40104166666666666667)
    fjkm[3] = T.zero
    fjkm[4] =  Helpers.makeFP(0.33420138888888888889)
    j = 0; k = 2; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-0.10546875000000000000)
    fjkm[1] =  Helpers.makeFP(0.15234375000000000000)
    fjkm[2] =  Helpers.makeFP(1.4036458333333333333)
    fjkm[3] =  Helpers.makeFP(-1.6710069444444444444)
    fjkm[4] =  Helpers.makeFP(-1.8381076388888888889)
    fjkm[5] =  Helpers.makeFP(2.0609085648148148148)
    j = 1; k = 2; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(0.13183593750000000000)
    fjkm[1] =  Helpers.makeFP(-0.42187500000000000000)
    fjkm[2] =  Helpers.makeFP(-2.8623046875000000000)
    fjkm[3] =  Helpers.makeFP(8.0208333333333333333)
    fjkm[4] =  Helpers.makeFP(1.0777994791666666667)
    fjkm[5] =  Helpers.makeFP(-14.036458333333333333)
    fjkm[6] =  Helpers.makeFP(8.0904586226851851852)
    j = 2; k = 2; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-0.15380859375000000000)
    fjkm[1] =  Helpers.makeFP(0.79892578125000000000)
    fjkm[2] =  Helpers.makeFP(4.5903320312500000000)
    fjkm[3] =  Helpers.makeFP(-22.751985677083333333)
    fjkm[4] =  Helpers.makeFP(14.934624565972222222)
    fjkm[5] =  Helpers.makeFP(42.526662567515432099)
    fjkm[6] =  Helpers.makeFP(-65.691460503472222222)
    fjkm[7] =  Helpers.makeFP(25.746658387988683128)
    j = 3; k = 2; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(0.17303466796875000000)
    fjkm[1] =  Helpers.makeFP(-1.2773437500000000000)
    fjkm[2] =  Helpers.makeFP(-6.3615722656250000000)
    fjkm[3] =  Helpers.makeFP(50.011935763888888889)
    fjkm[4] =  Helpers.makeFP(-73.559339735243055556)
    fjkm[5] =  Helpers.makeFP(-70.026331018518518519)
    fjkm[6] =  Helpers.makeFP(271.34066056616512346)
    fjkm[7] =  Helpers.makeFP(-242.71375868055555556)
    fjkm[8] =  Helpers.makeFP(72.412718470695087449)
    j = 4; k = 2; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-0.19033813476562500000)
    fjkm[1] =  Helpers.makeFP(1.8524126325334821429)
    fjkm[2] =  Helpers.makeFP(7.9220947265625000000)
    fjkm[3] =  Helpers.makeFP(-94.174715169270833333)
    fjkm[4] =  Helpers.makeFP(221.09830050998263889)
    fjkm[5] =  Helpers.makeFP(13.578712293836805556)
    fjkm[6] =  Helpers.makeFP(-765.03722541714891975)
    fjkm[7] =  Helpers.makeFP(1204.5108913845486111)
    fjkm[8] =  Helpers.makeFP(-777.22725008740837191)
    fjkm[9] =  Helpers.makeFP(187.66711848589945559)
    j = 5; k = 2; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(0.20619964599609375000)
    fjkm[1] =  Helpers.makeFP(-2.5202636718750000000)
    fjkm[2] =  Helpers.makeFP(-8.9979495239257812500)
    fjkm[3] =  Helpers.makeFP(159.65856119791666667)
    fjkm[4] =  Helpers.makeFP(-527.02200527615017361)
    fjkm[5] =  Helpers.makeFP(337.21907552083333333)
    fjkm[6] =  Helpers.makeFP(1618.7873626708984375)
    fjkm[7] =  Helpers.makeFP(-4211.0382245852623457)
    fjkm[8] =  Helpers.makeFP(4434.1363497656886306)
    fjkm[9] =  Helpers.makeFP(-2259.2768162856867284)
    fjkm[10] =  Helpers.makeFP(458.84770992088928362)
    j = 6; k = 2; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-0.22092819213867187500)
    fjkm[1] =  Helpers.makeFP(3.2776113237653459821)
    fjkm[2] =  Helpers.makeFP(9.3003209795270647321)
    fjkm[3] =  Helpers.makeFP(-250.77115683984504175)
    fjkm[4] =  Helpers.makeFP(1087.8174260457356771)
    fjkm[5] =  Helpers.makeFP(-1404.3028911260910976)
    fjkm[6] =  Helpers.makeFP(-2563.9444452795962738)
    fjkm[7] =  Helpers.makeFP(11622.495969086321293)
    fjkm[8] =  Helpers.makeFP(-17934.344163614699543)
    fjkm[9] =  Helpers.makeFP(14479.313178892270800)
    fjkm[10] =  Helpers.makeFP(-6122.6397406024697386)
    fjkm[11] =  Helpers.makeFP(1074.0188194633057124)
    j = 7; k = 2; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(0.23473620414733886719)
    fjkm[1] =  Helpers.makeFP(-4.1216033935546875000)
    fjkm[2] =  Helpers.makeFP(-8.5290844099862234933)
    fjkm[3] =  Helpers.makeFP(371.57630452473958333)
    fjkm[4] =  Helpers.makeFP(-2030.4431650042155432)
    fjkm[5] =  Helpers.makeFP(3928.2498148600260417)
    fjkm[6] =  Helpers.makeFP(2472.6031768756442600)
    fjkm[7] =  Helpers.makeFP(-26784.706192883150077)
    fjkm[8] =  Helpers.makeFP(57707.467479758203765)
    fjkm[9] =  Helpers.makeFP(-65779.375284558624561)
    fjkm[10] =  Helpers.makeFP(43428.755429000357378)
    fjkm[11] =  Helpers.makeFP(-15731.921483001918296)
    fjkm[12] =  Helpers.makeFP(2430.2098720207426574)
    j = 8; k = 2; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-0.24777710437774658203)
    fjkm[1] =  Helpers.makeFP(5.0497246547178788619)
    fjkm[2] =  Helpers.makeFP(6.3753494648706345331)
    fjkm[3] =  Helpers.makeFP(-525.77763195628211612)
    fjkm[4] =  Helpers.makeFP(3515.3901490500364354)
    fjkm[5] =  Helpers.makeFP(-9098.9465854134383025)
    fjkm[6] =  Helpers.makeFP(1501.4499341175879961)
    fjkm[7] =  Helpers.makeFP(52968.402569427411743)
    fjkm[8] =  Helpers.makeFP(-156962.17039551999834)
    fjkm[9] =  Helpers.makeFP(237710.55444046526561)
    fjkm[10] =  Helpers.makeFP(-217889.76091367761240)
    fjkm[11] =  Helpers.makeFP(122183.02599420558225)
    fjkm[12] =  Helpers.makeFP(-38765.366765003690558)
    fjkm[13] =  Helpers.makeFP(5352.0219072834891857)
    j = 9; k = 2; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(0.26016595959663391113)
    fjkm[1] =  Helpers.makeFP(-6.0597300529479980469)
    fjkm[2] =  Helpers.makeFP(-2.5233336282830660035)
    fjkm[3] =  Helpers.makeFP(716.61609867398701017)
    fjkm[4] =  Helpers.makeFP(-5739.3531518108567233)
    fjkm[5] =  Helpers.makeFP(18710.056678357368214)
    fjkm[6] =  Helpers.makeFP(-15227.052778022872591)
    fjkm[7] =  Helpers.makeFP(-90410.693429278463984)
    fjkm[8] =  Helpers.makeFP(374173.78606362103489)
    fjkm[9] =  Helpers.makeFP(-726678.85908967426430)
    fjkm[10] =  Helpers.makeFP(867690.63613487545936)
    fjkm[11] =  Helpers.makeFP(-669330.97296360068003)
    fjkm[12] =  Helpers.makeFP(326923.43164094028666)
    fjkm[13] =  Helpers.makeFP(-92347.975136788220980)
    fjkm[14] =  Helpers.makeFP(11528.702830431737704)
    j = 10; k = 2; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-0.27199168503284454346)
    fjkm[1] =  Helpers.makeFP(7.1495960926884537810)
    fjkm[2] =  Helpers.makeFP(-3.3482232633271774688)
    fjkm[3] =  Helpers.makeFP(-946.77886875050071077)
    fjkm[4] =  Helpers.makeFP(8937.5223755513871158)
    fjkm[5] =  Helpers.makeFP(-35337.290730230231910)
    fjkm[6] =  Helpers.makeFP(49459.110954680523755)
    fjkm[7] =  Helpers.makeFP(130172.10642681313787)
    fjkm[8] =  Helpers.makeFP(-799759.43622037315810)
    fjkm[9] =  Helpers.makeFP(1951258.3781149473349)
    fjkm[10] =  Helpers.makeFP(-2917568.5809228727915)
    fjkm[11] =  Helpers.makeFP(2902364.7717490216619)
    fjkm[12] =  Helpers.makeFP(-1939009.9106363828308)
    fjkm[13] =  Helpers.makeFP(839993.29007310418975)
    fjkm[14] =  Helpers.makeFP(-213947.07574365748020)
    fjkm[15] =  Helpers.makeFP(24380.364047003816130)
    j = 11; k = 2; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(0.28332467190921306610)
    fjkm[1] =  Helpers.makeFP(-8.3174842023230218268)
    fjkm[2] =  Helpers.makeFP(11.564968830087189329)
    fjkm[3] =  Helpers.makeFP(1218.3176746274854345)
    fjkm[4] =  Helpers.makeFP(-13385.506466376132701)
    fjkm[5] =  Helpers.makeFP(62540.301444639907312)
    fjkm[6] =  Helpers.makeFP(-122382.91365675340023)
    fjkm[7] =  Helpers.makeFP(-143089.29056273054521)
    fjkm[8] =  Helpers.makeFP(1554707.5273250397863)
    fjkm[9] =  Helpers.makeFP(-4718379.1202435790866)
    fjkm[10] =  Helpers.makeFP(8605382.3882172381886)
    fjkm[11] =  Helpers.makeFP(-10599895.885891960945)
    fjkm[12] =  Helpers.makeFP(9077838.6492033673420)
    fjkm[13] =  Helpers.makeFP(-5358306.8036736424269)
    fjkm[14] =  Helpers.makeFP(2087192.8797093735160)
    fjkm[15] =  Helpers.makeFP(-484205.51887813298356)
    fjkm[16] =  Helpers.makeFP(50761.444989589644273)
    j = 12; k = 2; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-0.29422177467495203018)
    fjkm[1] =  Helpers.makeFP(9.5617123863640260863)
    fjkm[2] =  Helpers.makeFP(-22.456083202924761739)
    fjkm[3] =  Helpers.makeFP(-1532.5752010328979216)
    fjkm[4] =  Helpers.makeFP(19400.899387993296528)
    fjkm[5] =  Helpers.makeFP(-105087.87893355958488)
    fjkm[6] =  Helpers.makeFP(262967.92353732330762)
    fjkm[7] =  Helpers.makeFP(61613.709412718183861)
    fjkm[8] =  Helpers.makeFP(-2770349.5737553264845)
    fjkm[9] =  Helpers.makeFP(10454840.708341905254)
    fjkm[10] =  Helpers.makeFP(-22841191.197018135498)
    fjkm[11] =  Helpers.makeFP(33883152.513403664925)
    fjkm[12] =  Helpers.makeFP(-35702419.891311431439)
    fjkm[13] =  Helpers.makeFP(26908321.887260639130)
    fjkm[14] =  Helpers.makeFP(-14241918.449935481857)
    fjkm[15] =  Helpers.makeFP(5042187.1772326832703)
    fjkm[16] =  Helpers.makeFP(-1074259.7908211056482)
    fjkm[17] =  Helpers.makeFP(104287.72699173731366)
    j = 13; k = 2; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(0.30472969519905745983)
    fjkm[1] =  Helpers.makeFP(-10.880732823367957230)
    fjkm[2] =  Helpers.makeFP(36.353598566849979929)
    fjkm[3] =  Helpers.makeFP(1890.1183163422473995)
    fjkm[4] =  Helpers.makeFP(-27344.503966626558254)
    fjkm[5] =  Helpers.makeFP(169206.00701162634518)
    fjkm[6] =  Helpers.makeFP(-515265.57929420780237)
    fjkm[7] =  Helpers.makeFP(248217.18376755761876)
    fjkm[8] =  Helpers.makeFP(4532205.9690912962460)
    fjkm[9] =  Helpers.makeFP(-21492951.405026820809)
    fjkm[10] =  Helpers.makeFP(55557247.108151935296)
    fjkm[11] =  Helpers.makeFP(-97285892.160889723465)
    fjkm[12] =  Helpers.makeFP(122607925.76741209887)
    fjkm[13] =  Helpers.makeFP(-113234217.41453912066)
    fjkm[14] =  Helpers.makeFP(76312885.330872101297)
    fjkm[15] =  Helpers.makeFP(-36634431.269047918012)
    fjkm[16] =  Helpers.makeFP(11891540.519643040965)
    fjkm[17] =  Helpers.makeFP(-2342835.9225964451203)
    fjkm[18] =  Helpers.makeFP(211794.47349942484210)
    j = 14; k = 2; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(0.73242187500000000000e-1)
    fjkm[1] = T.zero
    fjkm[2] =  Helpers.makeFP(-0.89121093750000000000)
    fjkm[3] = T.zero
    fjkm[4] =  Helpers.makeFP(1.8464626736111111111)
    fjkm[5] = T.zero
    fjkm[6] =  Helpers.makeFP(-1.0258125964506172840)
    j = 0; k = 3; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-0.18310546875000000000)
    fjkm[1] =  Helpers.makeFP(0.23193359375000000000)
    fjkm[2] =  Helpers.makeFP(4.0104492187500000000)
    fjkm[3] =  Helpers.makeFP(-4.6045898437500000000)
    fjkm[4] =  Helpers.makeFP(-12.002007378472222222)
    fjkm[5] =  Helpers.makeFP(13.232982494212962963)
    fjkm[6] =  Helpers.makeFP(8.7194070698302469136)
    fjkm[7] =  Helpers.makeFP(-9.4032821341306584362)
    j = 1; k = 3; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(0.32043457031250000000)
    fjkm[1] =  Helpers.makeFP(-0.87890625000000000000)
    fjkm[2] =  Helpers.makeFP(-10.464160156250000000)
    fjkm[3] =  Helpers.makeFP(26.736328125000000000)
    fjkm[4] =  Helpers.makeFP(29.225667317708333333)
    fjkm[5] =  Helpers.makeFP(-103.40190972222222222)
    fjkm[6] =  Helpers.makeFP(17.131070360725308642)
    fjkm[7] =  Helpers.makeFP(92.323133680555555556)
    fjkm[8] =  Helpers.makeFP(-50.991434481899434156)
    j = 2; k = 3; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-0.48065185546875000000)
    fjkm[1] =  Helpers.makeFP(2.1109008789062500000)
    fjkm[2] =  Helpers.makeFP(21.025415039062500000)
    fjkm[3] =  Helpers.makeFP(-89.876334092881944444)
    fjkm[4] =  Helpers.makeFP(-15.284450954861111111)
    fjkm[5] =  Helpers.makeFP(411.04911024305555556)
    fjkm[6] =  Helpers.makeFP(-389.32152566792052469)
    fjkm[7] =  Helpers.makeFP(-293.92095419801311728)
    fjkm[8] =  Helpers.makeFP(567.72315884813850309)
    fjkm[9] =  Helpers.makeFP(-213.02470796338270176)
    j = 3; k = 3; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(0.66089630126953125000)
    fjkm[1] =  Helpers.makeFP(-4.0893554687500000000)
    fjkm[2] =  Helpers.makeFP(-36.043276468912760417)
    fjkm[3] =  Helpers.makeFP(229.67792968750000000)
    fjkm[4] =  Helpers.makeFP(-150.64704827202690972)
    fjkm[5] =  Helpers.makeFP(-1115.0236545138888889)
    fjkm[6] =  Helpers.makeFP(2175.9328758333936150)
    fjkm[7] =  Helpers.makeFP(-176.78170412165637860)
    fjkm[8] =  Helpers.makeFP(-2817.5643744553721654)
    fjkm[9] =  Helpers.makeFP(2651.5545930587705761)
    fjkm[10] =  Helpers.makeFP(-757.67687847693870206)
    j = 4; k = 3; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-0.85916519165039062500)
    fjkm[1] =  Helpers.makeFP(6.9690023149762834821)
    fjkm[2] =  Helpers.makeFP(55.378133392333984375)
    fjkm[3] =  Helpers.makeFP(-495.03058466109018477)
    fjkm[4] =  Helpers.makeFP(733.55991770426432292)
    fjkm[5] =  Helpers.makeFP(2262.8678469622576678)
    fjkm[6] =  Helpers.makeFP(-7898.5588740407684703)
    fjkm[7] =  Helpers.makeFP(5695.1407000317985629)
    fjkm[8] =  Helpers.makeFP(7718.7923309734328784)
    fjkm[9] =  Helpers.makeFP(-16089.784052072184022)
    fjkm[10] =  Helpers.makeFP(10424.896645958040967)
    fjkm[11] =  Helpers.makeFP(-2413.3719004256171872)
    j = 5; k = 3; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(1.0739564895629882812)
    fjkm[1] =  Helpers.makeFP(-10.898971557617187500)
    fjkm[2] =  Helpers.makeFP(-78.354169082641601562)
    fjkm[3] =  Helpers.makeFP(948.65802978515625000)
    fjkm[4] =  Helpers.makeFP(-2219.4645106141832140)
    fjkm[5] =  Helpers.makeFP(-3394.0875061035156250)
    fjkm[6] =  Helpers.makeFP(22215.581371235788604)
    fjkm[7] =  Helpers.makeFP(-30531.682191548916538)
    fjkm[8] =  Helpers.makeFP(-6945.0954169277301051)
    fjkm[9] =  Helpers.makeFP(63170.236743335697713)
    fjkm[10] =  Helpers.makeFP(-72433.473359744190134)
    fjkm[11] =  Helpers.makeFP(36368.490166893057699)
    fjkm[12] =  Helpers.makeFP(-7090.9841426397698721)
    j = 6; k = 3; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-1.3040900230407714844)
    fjkm[1] =  Helpers.makeFP(16.023568312327067057)
    fjkm[2] =  Helpers.makeFP(103.72332413083031064)
    fjkm[3] =  Helpers.makeFP(-1667.3156506674630301)
    fjkm[4] =  Helpers.makeFP(5406.6561977448034539)
    fjkm[5] =  Helpers.makeFP(2872.9832533515445770)
    fjkm[6] =  Helpers.makeFP(-52104.157882492630570)
    fjkm[7] =  Helpers.makeFP(110439.44251210509668)
    fjkm[8] =  Helpers.makeFP(-46659.137282813036883)
    fjkm[9] =  Helpers.makeFP(-173333.53977304078369)
    fjkm[10] =  Helpers.makeFP(339551.86235951279889)
    fjkm[11] =  Helpers.makeFP(-281181.85781749484440)
    fjkm[12] =  Helpers.makeFP(116143.52270798282713)
    fjkm[13] =  Helpers.makeFP(-19586.901426503340492)
    j = 7; k = 3; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(1.5486069023609161377)
    fjkm[1] =  Helpers.makeFP(-22.482862472534179688)
    fjkm[2] =  Helpers.makeFP(-129.63729095714432853)
    fjkm[3] =  Helpers.makeFP(2741.6385669817243304)
    fjkm[4] =  Helpers.makeFP(-11510.430102675971531)
    fjkm[5] =  Helpers.makeFP(3157.6331450774177672)
    fjkm[6] =  Helpers.makeFP(105738.58606273177860)
    fjkm[7] =  Helpers.makeFP(-320687.78222286271460)
    fjkm[8] =  Helpers.makeFP(312110.04133755429291)
    fjkm[9] =  Helpers.makeFP(306706.99777237116391)
    fjkm[10] =  Helpers.makeFP(-1199602.2626751819183)
    fjkm[11] =  Helpers.makeFP(1489876.7581807900958)
    fjkm[12] =  Helpers.makeFP(-983301.03812460934208)
    fjkm[13] =  Helpers.makeFP(346445.22525468589947)
    fjkm[14] =  Helpers.makeFP(-51524.795648340968513)
    j = 8; k = 3; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    
}

fileprivate func fjkproc16_002<T: SSFloatingPoint>(fjk: inout Array<Array<T>>, un: Array<T>, v: T) {
    var d, j, k: Int
    var fjkm:Array<T> = Array<T>.init(repeating: 0, count: 33)
    fjkm[0] =  Helpers.makeFP(-1.8067080527544021606)
    fjkm[1] =  Helpers.makeFP(30.413155585075869705)
    fjkm[2] =  Helpers.makeFP(153.62532423010894230)
    fjkm[3] =  Helpers.makeFP(-4275.6818557748761872)
    fjkm[4] =  Helpers.makeFP(22280.234407631843178)
    fjkm[5] =  Helpers.makeFP(-22294.360392132099974)
    fjkm[6] =  Helpers.makeFP(-188892.07658652729984)
    fjkm[7] =  Helpers.makeFP(800265.57729686724177)
    fjkm[8] =  Helpers.makeFP(-1211192.8548070343556)
    fjkm[9] =  Helpers.makeFP(-77428.408184713489979)
    fjkm[10] =  Helpers.makeFP(3343683.8379703140094)
    fjkm[11] =  Helpers.makeFP(-6075462.1554119391419)
    fjkm[12] =  Helpers.makeFP(5742939.8025630234344)
    fjkm[13] =  Helpers.makeFP(-3178262.5289756645302)
    fjkm[14] =  Helpers.makeFP(978732.98065558879521)
    fjkm[15] =  Helpers.makeFP(-130276.59845140693203)
    j = 9; k = 3; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(2.0777142606675624847)
    fjkm[1] =  Helpers.makeFP(-39.947360754013061523)
    fjkm[2] =  Helpers.makeFP(-172.57638879468381540)
    fjkm[3] =  Helpers.makeFP(6386.1869555628867376)
    fjkm[4] =  Helpers.makeFP(-40128.233950133856041)
    fjkm[5] =  Helpers.makeFP(67957.947814703914434)
    fjkm[6] =  Helpers.makeFP(297268.90885718166849)
    fjkm[7] =  Helpers.makeFP(-1779345.5277624794845)
    fjkm[8] =  Helpers.makeFP(3703482.9515239098067)
    fjkm[9] =  Helpers.makeFP(-1986101.2546910898185)
    fjkm[10] =  Helpers.makeFP(-7335848.9571808003709)
    fjkm[11] =  Helpers.makeFP(20236466.148311260729)
    fjkm[12] =  Helpers.makeFP(-26009069.048248407006)
    fjkm[13] =  Helpers.makeFP(20168378.697199375155)
    fjkm[14] =  Helpers.makeFP(-9655403.7938215681211)
    fjkm[15] =  Helpers.makeFP(2644939.5099481697170)
    fjkm[16] =  Helpers.makeFP(-318773.08892039496616)
    j = 10; k = 3; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-2.3610389325767755508)
    fjkm[1] =  Helpers.makeFP(51.215318048867833364)
    fjkm[2] =  Helpers.makeFP(182.72462206625770697)
    fjkm[3] =  Helpers.makeFP(-9201.6026100350086393)
    fjkm[4] =  Helpers.makeFP(68268.256270370096570)
    fjkm[5] =  Helpers.makeFP(-162141.74207057405274)
    fjkm[6] =  Helpers.makeFP(-402709.29424480088095)
    fjkm[7] =  Helpers.makeFP(3603004.6646962551842)
    fjkm[8] =  Helpers.makeFP(-9740822.7436915944519)
    fjkm[9] =  Helpers.makeFP(10107345.074822039354)
    fjkm[10] =  Helpers.makeFP(11498843.003383757375)
    fjkm[11] =  Helpers.makeFP(-56841651.345428293012)
    fjkm[12] =  Helpers.makeFP(97219891.251414595951)
    fjkm[13] =  Helpers.makeFP(-99519441.572391483730)
    fjkm[14] =  Helpers.makeFP(65942266.170395132237)
    fjkm[15] =  Helpers.makeFP(-27893470.527717198286)
    fjkm[16] =  Helpers.makeFP(6888375.1431181415309)
    fjkm[17] =  Helpers.makeFP(-758786.31484749532876)
    j = 11; k = 3; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(2.6561687991488724947)
    fjkm[1] =  Helpers.makeFP(-64.344060508074698510)
    fjkm[2] =  Helpers.makeFP(-179.63738093291836674)
    fjkm[3] =  Helpers.makeFP(12860.884276726402663)
    fjkm[4] =  Helpers.makeFP(-110864.10416322604021)
    fjkm[5] =  Helpers.makeFP(338921.66960863282529)
    fjkm[6] =  Helpers.makeFP(430704.46372470858983)
    fjkm[7] =  Helpers.makeFP(-6738355.6173354573243)
    fjkm[8] =  Helpers.makeFP(22959038.837731227338)
    fjkm[9] =  Helpers.makeFP(-34599901.818598601926)
    fjkm[10] =  Helpers.makeFP(-5491093.1482636375735)
    fjkm[11] =  Helpers.makeFP(136348100.13563343194)
    fjkm[12] =  Helpers.makeFP(-311391327.48073317359)
    fjkm[13] =  Helpers.makeFP(406747852.87490380879)
    fjkm[14] =  Helpers.makeFP(-350465400.65634558429)
    fjkm[15] =  Helpers.makeFP(203621539.64411279745)
    fjkm[16] =  Helpers.makeFP(-77285292.825523293342)
    fjkm[17] =  Helpers.makeFP(17387623.032021543609)
    fjkm[18] =  Helpers.makeFP(-1764164.5657772609975)
    j = 12; k = 3; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-2.9626498144352808595)
    fjkm[1] =  Helpers.makeFP(79.458041370067243966)
    fjkm[2] =  Helpers.makeFP(158.20533868869907341)
    fjkm[3] =  Helpers.makeFP(-17512.092404496780068)
    fjkm[4] =  Helpers.makeFP(173186.23779115767550)
    fjkm[5] =  Helpers.makeFP(-648825.90238130558651)
    fjkm[6] =  Helpers.makeFP(-226118.57798798103100)
    fjkm[7] =  Helpers.makeFP(11744385.639221317992)
    fjkm[8] =  Helpers.makeFP(-49655262.440949257658)
    fjkm[9] =  Helpers.makeFP(97992370.806143206674)
    fjkm[10] =  Helpers.makeFP(-45563229.252833811893)
    fjkm[11] =  Helpers.makeFP(-276725901.55879139753)
    fjkm[12] =  Helpers.makeFP(874903955.44068001049)
    fjkm[13] =  Helpers.makeFP(-1431639430.0141678479)
    fjkm[14] =  Helpers.makeFP(1544324559.7308983592)
    fjkm[15] =  Helpers.makeFP(-1156507831.0309397511)
    fjkm[16] =  Helpers.makeFP(599846625.33396072076)
    fjkm[17] =  Helpers.makeFP(-206711172.70469868149)
    fjkm[18] =  Helpers.makeFP(42729154.354849580701)
    fjkm[19] =  Helpers.makeFP(-4019188.6691200667599)
    j = 13; k = 3; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(0.11215209960937500000)
    fjkm[1] = T.zero
    fjkm[2] =  Helpers.makeFP(-2.3640869140625000000)
    fjkm[3] = T.zero
    fjkm[4] =  Helpers.makeFP(8.7891235351562500000)
    fjkm[5] = T.zero
    fjkm[6] =  Helpers.makeFP(-11.207002616222993827)
    fjkm[7] = T.zero
    fjkm[8] =  Helpers.makeFP(4.6695844234262474280)
    j = 0; k = 4; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-0.39253234863281250000)
    fjkm[1] =  Helpers.makeFP(0.46730041503906250000)
    fjkm[2] =  Helpers.makeFP(13.002478027343750000)
    fjkm[3] =  Helpers.makeFP(-14.578535970052083333)
    fjkm[4] =  Helpers.makeFP(-65.918426513671875000)
    fjkm[5] =  Helpers.makeFP(71.777842203776041667)
    fjkm[6] =  Helpers.makeFP(106.46652485411844136)
    fjkm[7] =  Helpers.makeFP(-113.93785993160043724)
    fjkm[8] =  Helpers.makeFP(-53.700220869401845422)
    fjkm[9] =  Helpers.makeFP(56.813277151686010374)
    j = 1; k = 4; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(0.88319778442382812500)
    fjkm[1] =  Helpers.makeFP(-2.2430419921875000000)
    fjkm[2] =  Helpers.makeFP(-40.888863372802734375)
    fjkm[3] =  Helpers.makeFP(99.291650390625000000)
    fjkm[4] =  Helpers.makeFP(222.92270863850911458)
    fjkm[5] =  Helpers.makeFP(-632.81689453125000000)
    fjkm[6] =  Helpers.makeFP(-205.55324667471426505)
    fjkm[7] =  Helpers.makeFP(1232.7702877845293210)
    fjkm[8] =  Helpers.makeFP(-339.12856875133121946)
    fjkm[9] =  Helpers.makeFP(-728.45517005449459877)
    fjkm[10] =  Helpers.makeFP(393.21792165601858550)
    j = 2; k = 4; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-1.6191959381103515625)
    fjkm[1] =  Helpers.makeFP(6.5174388885498046875)
    fjkm[2] =  Helpers.makeFP(97.292139053344726562)
    fjkm[3] =  Helpers.makeFP(-384.72013047112358941)
    fjkm[4] =  Helpers.makeFP(-422.46132278442382812)
    fjkm[5] =  Helpers.makeFP(2925.8162224946198640)
    fjkm[6] =  Helpers.makeFP(-1437.2810672241964458)
    fjkm[7] =  Helpers.makeFP(-5929.6163575631600839)
    fjkm[8] =  Helpers.makeFP(6678.9649706318545243)
    fjkm[9] =  Helpers.makeFP(1992.7516382310725152)
    fjkm[10] =  Helpers.makeFP(-5560.5995012212682653)
    fjkm[11] =  Helpers.makeFP(2034.9551693024277015)
    j = 3; k = 4; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(2.6311933994293212891)
    fjkm[1] =  Helpers.makeFP(-14.813423156738281250)
    fjkm[2] =  Helpers.makeFP(-194.76567316055297852)
    fjkm[3] =  Helpers.makeFP(1116.2957621256510417)
    fjkm[4] =  Helpers.makeFP(214.74175742997063531)
    fjkm[5] =  Helpers.makeFP(-9500.2007904052734375)
    fjkm[6] =  Helpers.makeFP(12733.852428636433166)
    fjkm[7] =  Helpers.makeFP(15619.117721871584041)
    fjkm[8] =  Helpers.makeFP(-43856.442195416477973)
    fjkm[9] =  Helpers.makeFP(16041.189890575016477)
    fjkm[10] =  Helpers.makeFP(30538.376827393703173)
    fjkm[11] =  Helpers.makeFP(-31457.433732481486840)
    fjkm[12] =  Helpers.makeFP(8757.4502329231489542)
    j = 4; k = 4; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-3.9467900991439819336)
    fjkm[1] =  Helpers.makeFP(28.973631262779235840)
    fjkm[2] =  Helpers.makeFP(345.96240515708923340)
    fjkm[3] =  Helpers.makeFP(-2698.2640026051657540)
    fjkm[4] =  Helpers.makeFP(1749.1663194396760729)
    fjkm[5] =  Helpers.makeFP(24230.291604531833104)
    fjkm[6] =  Helpers.makeFP(-57186.682706525590685)
    fjkm[7] =  Helpers.makeFP(-12268.269917924904529)
    fjkm[8] =  Helpers.makeFP(179642.68522044022878)
    fjkm[9] =  Helpers.makeFP(-184075.59647969633791)
    fjkm[10] =  Helpers.makeFP(-55836.464134952713487)
    fjkm[11] =  Helpers.makeFP(219854.46366368396092)
    fjkm[12] =  Helpers.makeFP(-146898.32628401899970)
    fjkm[13] =  Helpers.makeFP(33116.007471226346158)
    j = 5; k = 4; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(5.5912859737873077393)
    fjkm[1] =  Helpers.makeFP(-51.149418354034423828)
    fjkm[2] =  Helpers.makeFP(-562.32073248028755188)
    fjkm[3] =  Helpers.makeFP(5740.3790382385253906)
    fjkm[4] =  Helpers.makeFP(-8505.8885195685227712)
    fjkm[5] =  Helpers.makeFP(-51098.161945523156060)
    fjkm[6] =  Helpers.makeFP(189688.56368664133696)
    fjkm[7] =  Helpers.makeFP(-98986.676113505422333)
    fjkm[8] =  Helpers.makeFP(-524313.33320720157996)
    fjkm[9] =  Helpers.makeFP(1006412.2572891519230)
    fjkm[10] =  Helpers.makeFP(-338656.53584266578056)
    fjkm[11] =  Helpers.makeFP(-879242.30314162838225)
    fjkm[12] =  Helpers.makeFP(1184856.1356540792633)
    fjkm[13] =  Helpers.makeFP(-599009.59593194338847)
    fjkm[14] =  Helpers.makeFP(113723.03789882673771)
    j = 6; k = 4; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-7.5881738215684890747)
    fjkm[1] =  Helpers.makeFP(83.791322236259778341)
    fjkm[2] =  Helpers.makeFP(852.65149199664592743)
    fjkm[3] =  Helpers.makeFP(-11106.114063047180100)
    fjkm[4] =  Helpers.makeFP(25906.550896742895797)
    fjkm[5] =  Helpers.makeFP(90628.038560826472504)
    fjkm[6] =  Helpers.makeFP(-518627.00526554010007)
    fjkm[7] =  Helpers.makeFP(625235.13813439073187)
    fjkm[8] =  Helpers.makeFP(1093177.6471805288836)
    fjkm[9] =  Helpers.makeFP(-3890056.2699064931220)
    fjkm[10] =  Helpers.makeFP(3443257.5304835279133)
    fjkm[11] =  Helpers.makeFP(1688397.8063561002636)
    fjkm[12] =  Helpers.makeFP(-6072278.7538110165925)
    fjkm[13] =  Helpers.makeFP(5368522.3053911687123)
    fjkm[14] =  Helpers.makeFP(-2206353.9977704553128)
    fjkm[15] =  Helpers.makeFP(362368.26917284610367)
    j = 7; k = 4; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(9.9594781408086419106)
    fjkm[1] =  Helpers.makeFP(-129.64064240455627441)
    fjkm[2] =  Helpers.makeFP(-1221.6473410353064537)
    fjkm[3] =  Helpers.makeFP(19961.318612462793078)
    fjkm[4] =  Helpers.makeFP(-64135.377206358956439)
    fjkm[5] =  Helpers.makeFP(-132491.34865988838862)
    fjkm[6] =  Helpers.makeFP(1231383.3446542421759)
    fjkm[7] =  Helpers.makeFP(-2354589.9435372119185)
    fjkm[8] =  Helpers.makeFP(-1264272.3547066582332)
    fjkm[9] =  Helpers.makeFP(11829877.236705665039)
    fjkm[10] =  Helpers.makeFP(-17640228.849921599961)
    fjkm[11] =  Helpers.makeFP(3679036.5985685346058)
    fjkm[12] =  Helpers.makeFP(21328290.463957701877)
    fjkm[13] =  Helpers.makeFP(-31765842.068457922539)
    fjkm[14] =  Helpers.makeFP(21552604.862053478433)
    fjkm[15] =  Helpers.makeFP(-7505720.5013225646891)
    fjkm[16] =  Helpers.makeFP(1087467.9477654193166)
    j = 8; k = 4; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-12.725999846588820219)
    fjkm[1] =  Helpers.makeFP(191.72191139924424616)
    fjkm[2] =  Helpers.makeFP(1668.3300609576205413)
    fjkm[3] =  Helpers.makeFP(-33822.376037367149478)
    fjkm[4] =  Helpers.makeFP(139670.53397437636223)
    fjkm[5] =  Helpers.makeFP(142413.44221576977052)
    fjkm[6] =  Helpers.makeFP(-2615894.9488370680107)
    fjkm[7] =  Helpers.makeFP(7028008.7411020993735)
    fjkm[8] =  Helpers.makeFP(-1692308.6869349767646)
    fjkm[9] =  Helpers.makeFP(-29470781.812749969812)
    fjkm[10] =  Helpers.makeFP(66963160.307047821471)
    fjkm[11] =  Helpers.makeFP(-48089009.180540108686)
    fjkm[12] =  Helpers.makeFP(-47220345.652008289171)
    fjkm[13] =  Helpers.makeFP(138176622.72569342840)
    fjkm[14] =  Helpers.makeFP(-141477318.49446414033)
    fjkm[15] =  Helpers.makeFP(78991076.066288083382)
    fjkm[16] =  Helpers.makeFP(-23950277.790642797164)
    fjkm[17] =  Helpers.makeFP(3106959.7999206284827)
    j = 9; k = 4; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(15.907499808236025274)
    fjkm[1] =  Helpers.makeFP(-273.33609867841005325)
    fjkm[2] =  Helpers.makeFP(-2184.4474298407246048)
    fjkm[3] =  Helpers.makeFP(54603.014533953543693)
    fjkm[4] =  Helpers.makeFP(-277734.45331034886641)
    fjkm[5] =  Helpers.makeFP(-41109.662796960089573)
    fjkm[6] =  Helpers.makeFP(5064705.8054347585059)
    fjkm[7] =  Helpers.makeFP(-18090940.629099192262)
    fjkm[8] =  Helpers.makeFP(15917528.891696545807)
    fjkm[9] =  Helpers.makeFP(60220437.637860917599)
    fjkm[10] =  Helpers.makeFP(-208561974.26419501420)
    fjkm[11] =  Helpers.makeFP(250941409.40257928779)
    fjkm[12] =  Helpers.makeFP(12084648.536915454989)
    fjkm[13] =  Helpers.makeFP(-458976381.31741616556)
    fjkm[14] =  Helpers.makeFP(699975914.26074700776)
    fjkm[15] =  Helpers.makeFP(-563757375.34166870146)
    fjkm[16] =  Helpers.makeFP(269426949.85344351478)
    fjkm[17] =  Helpers.makeFP(-72497863.184361287773)
    fjkm[18] =  Helpers.makeFP(8519623.3256649401434)
    j = 10; k = 4; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-19.522840673744212836)
    fjkm[1] =  Helpers.makeFP(378.05442703043402114)
    fjkm[2] =  Helpers.makeFP(2752.8286152184838570)
    fjkm[3] =  Helpers.makeFP(-84659.009316768248795)
    fjkm[4] =  Helpers.makeFP(515277.57789757005885)
    fjkm[5] =  Helpers.makeFP(-327436.12858763123432)
    fjkm[6] =  Helpers.makeFP(-9039645.4021864355266)
    fjkm[7] =  Helpers.makeFP(41795541.145581633576)
    fjkm[8] =  Helpers.makeFP(-61523469.344794095368)
    fjkm[9] =  Helpers.makeFP(-95072522.336003533273)
    fjkm[10] =  Helpers.makeFP(557312492.76991978150)
    fjkm[11] =  Helpers.makeFP(-963898631.17215744429)
    fjkm[12] =  Helpers.makeFP(480963077.05278739701)
    fjkm[13] =  Helpers.makeFP(1131925258.2353560419)
    fjkm[14] =  Helpers.makeFP(-2762861092.1224474487)
    fjkm[15] =  Helpers.makeFP(3066633312.6192085228)
    fjkm[16] =  Helpers.makeFP(-2065683582.7903266052)
    fjkm[17] =  Helpers.makeFP(866733914.71761334168)
    fjkm[18] =  Helpers.makeFP(-209952808.47963646972)
    fjkm[19] =  Helpers.makeFP(22561861.306890567863)
    j = 11; k = 4; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(23.590099147440923844)
    fjkm[1] =  Helpers.makeFP(-509.71270865877158940)
    fjkm[2] =  Helpers.makeFP(-3345.7051051560481552)
    fjkm[3] =  Helpers.makeFP(126830.08496875773140)
    fjkm[4] =  Helpers.makeFP(-904536.17796320887184)
    fjkm[5] =  Helpers.makeFP(1241459.9239568200231)
    fjkm[6] =  Helpers.makeFP(14964746.535519588726)
    fjkm[7] =  Helpers.makeFP(-88697323.877097900818)
    fjkm[8] =  Helpers.makeFP(182496348.04247934870)
    fjkm[9] =  Helpers.makeFP(82548357.373675412652)
    fjkm[10] =  Helpers.makeFP(-1305701152.6740455738)
    fjkm[11] =  Helpers.makeFP(3075905875.9322221769)
    fjkm[12] =  Helpers.makeFP(-2915784132.1314453282)
    fjkm[13] =  Helpers.makeFP(-1631935529.3260648957)
    fjkm[14] =  Helpers.makeFP(8923557290.4467172403)
    fjkm[15] =  Helpers.makeFP(-13522339111.332256776)
    fjkm[16] =  Helpers.makeFP(12138202400.912393639)
    fjkm[17] =  Helpers.makeFP(-7081644626.2422883477)
    fjkm[18] =  Helpers.makeFP(2655510812.9195669082)
    fjkm[19] =  Helpers.makeFP(-585530475.83660861349)
    fjkm[20] =  Helpers.makeFP(57986597.253985419492)
    j = 12; k = 4; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
}

fileprivate func fjkproc16_003<T: SSFloatingPoint>(fjk: inout Array<Array<T>>, un: Array<T>, v: T) {
    var d, j, k: Int
    var fjkm:Array<T> = Array<T>.init(repeating: 0, count: 33)
    fjkm[0] =  Helpers.makeFP(0.22710800170898437500)
    fjkm[1] = T.zero
    fjkm[2] =  Helpers.makeFP(-7.3687943594796316964)
    fjkm[3] = T.zero
    fjkm[4] =  Helpers.makeFP(42.534998745388454861)
    fjkm[5] = T.zero
    fjkm[6] =  Helpers.makeFP(-91.818241543240017361)
    fjkm[7] = T.zero
    fjkm[8] =  Helpers.makeFP(84.636217674600734632)
    fjkm[9] = T.zero
    fjkm[10] =  Helpers.makeFP(-28.212072558200244877)
    j = 0; k = 5; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-1.0219860076904296875)
    fjkm[1] =  Helpers.makeFP(1.1733913421630859375)
    fjkm[2] =  Helpers.makeFP(47.897163336617606027)
    fjkm[3] =  Helpers.makeFP(-52.809692909604027158)
    fjkm[4] =  Helpers.makeFP(-361.54748933580186632)
    fjkm[5] =  Helpers.makeFP(389.90415516606083623)
    fjkm[6] =  Helpers.makeFP(964.09153620402018229)
    fjkm[7] =  Helpers.makeFP(-1025.3036972328468605)
    fjkm[8] =  Helpers.makeFP(-1057.9527209325091829)
    fjkm[9] =  Helpers.makeFP(1114.3768660489096727)
    fjkm[10] =  Helpers.makeFP(409.07505209390355072)
    fjkm[11] =  Helpers.makeFP(-427.88310046603704731)
    j = 1; k = 5; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(2.8104615211486816406)
    fjkm[1] =  Helpers.makeFP(-6.8132400512695312500)
    fjkm[2] =  Helpers.makeFP(-175.59265831538609096)
    fjkm[3] =  Helpers.makeFP(412.65248413085937500)
    fjkm[4] =  Helpers.makeFP(1483.6983865298922100)
    fjkm[5] =  Helpers.makeFP(-3828.1498870849609375)
    fjkm[6] =  Helpers.makeFP(-3429.1824372044316045)
    fjkm[7] =  Helpers.makeFP(12120.007883707682292)
    fjkm[8] =  Helpers.makeFP(557.04779563126740632)
    fjkm[9] =  Helpers.makeFP(-15403.791616777333703)
    fjkm[10] =  Helpers.makeFP(5099.3321148946942616)
    fjkm[11] =  Helpers.makeFP(6770.8974139680587706)
    fjkm[12] =  Helpers.makeFP(-3602.9167662868229396)
    j = 2; k = 5; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-6.0893332958221435547)
    fjkm[1] =  Helpers.makeFP(23.218954324722290039)
    fjkm[2] =  Helpers.makeFP(480.30594648633684431)
    fjkm[3] =  Helpers.makeFP(-1808.5316684886387416)
    fjkm[4] =  Helpers.makeFP(-3878.5356589824434311)
    fjkm[5] =  Helpers.makeFP(19896.567837257637549)
    fjkm[6] =  Helpers.makeFP(-442.43697992960611979)
    fjkm[7] =  Helpers.makeFP(-68889.990792852959025)
    fjkm[8] =  Helpers.makeFP(51994.291933598341765)
    fjkm[9] =  Helpers.makeFP(82310.686911069807202)
    fjkm[10] =  Helpers.makeFP(-107791.27622674358562)
    fjkm[11] =  Helpers.makeFP(-11421.030640241631355)
    fjkm[12] =  Helpers.makeFP(61775.622629784098705)
    fjkm[13] =  Helpers.makeFP(-22242.802900370862046)
    j = 3; k = 5; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(11.417499929666519165)
    fjkm[1] =  Helpers.makeFP(-60.543208122253417969)
    fjkm[2] =  Helpers.makeFP(-1092.4312783437115805)
    fjkm[3] =  Helpers.makeFP(5864.8337360927036830)
    fjkm[4] =  Helpers.makeFP(6502.6598836863797808)
    fjkm[5] =  Helpers.makeFP(-73117.673620733634505)
    fjkm[6] =  Helpers.makeFP(62464.986490075687042)
    fjkm[7] =  Helpers.makeFP(248344.19895160816334)
    fjkm[8] =  Helpers.makeFP(-446788.55343178424816)
    fjkm[9] =  Helpers.makeFP(-141685.28980603760980)
    fjkm[10] =  Helpers.makeFP(805685.00855625677338)
    fjkm[11] =  Helpers.makeFP(-411181.55351158250234)
    fjkm[12] =  Helpers.makeFP(-353321.84981767407842)
    fjkm[13] =  Helpers.makeFP(410732.51135669781511)
    fjkm[14] =  Helpers.makeFP(-112357.72180097660343)
    j = 4; k = 5; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-19.409749880433082581)
    fjkm[1] =  Helpers.makeFP(133.60695303976535797)
    fjkm[2] =  Helpers.makeFP(2184.1347855359315872)
    fjkm[3] =  Helpers.makeFP(-15685.927751365060709)
    fjkm[4] =  Helpers.makeFP(-3330.0494749048683378)
    fjkm[5] =  Helpers.makeFP(213065.39140775687165)
    fjkm[6] =  Helpers.makeFP(-371035.73548135295431)
    fjkm[7] =  Helpers.makeFP(-595658.10351999312306)
    fjkm[8] =  Helpers.makeFP(2217706.3121620208025)
    fjkm[9] =  Helpers.makeFP(-928359.76150830112939)
    fjkm[10] =  Helpers.makeFP(-3462387.4565158783367)
    fjkm[11] =  Helpers.makeFP(4492508.5831562094441)
    fjkm[12] =  Helpers.makeFP(-105953.60990151918538)
    fjkm[13] =  Helpers.makeFP(-3174045.4228780972346)
    fjkm[14] =  Helpers.makeFP(2222890.1148558130258)
    fjkm[15] =  Helpers.makeFP(-492012.66653936007240)
    j = 5; k = 5; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(30.732103977352380753)
    fjkm[1] =  Helpers.makeFP(-262.68730902671813965)
    fjkm[2] =  Helpers.makeFP(-3966.7030987024307251)
    fjkm[3] =  Helpers.makeFP(36616.605837684018271)
    fjkm[4] =  Helpers.makeFP(-23288.020921949948583)
    fjkm[5] =  Helpers.makeFP(-522073.19210540329968)
    fjkm[6] =  Helpers.makeFP(1445873.6105443313563)
    fjkm[7] =  Helpers.makeFP(729826.91993359621660)
    fjkm[8] =  Helpers.makeFP(-8027322.7404775209228)
    fjkm[9] =  Helpers.makeFP(9022069.9722413070898)
    fjkm[10] =  Helpers.makeFP(8528377.7669713558429)
    fjkm[11] =  Helpers.makeFP(-26111911.326974580072)
    fjkm[12] =  Helpers.makeFP(15072848.600502055062)
    fjkm[13] =  Helpers.makeFP(11547035.062352154444)
    fjkm[14] =  Helpers.makeFP(-20141460.694713124158)
    fjkm[15] =  Helpers.makeFP(10381853.494410238157)
    fjkm[16] =  Helpers.makeFP(-1934247.3992962518385)
    j = 6; k = 5; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-46.098155966028571129)
    fjkm[1] =  Helpers.makeFP(474.28179555572569370)
    fjkm[2] =  Helpers.makeFP(6683.6986173737261977)
    fjkm[3] =  Helpers.makeFP(-77185.928108340199369)
    fjkm[4] =  Helpers.makeFP(113831.12007369411134)
    fjkm[5] =  Helpers.makeFP(1111273.3131467255535)
    fjkm[6] =  Helpers.makeFP(-4487654.8822124313622)
    fjkm[7] =  Helpers.makeFP(1363280.0193113290821)
    fjkm[8] =  Helpers.makeFP(22934079.022569534587)
    fjkm[9] =  Helpers.makeFP(-45086888.891430235790)
    fjkm[10] =  Helpers.makeFP(-1310272.8912292084566)
    fjkm[11] =  Helpers.makeFP(103829405.25391139096)
    fjkm[12] =  Helpers.makeFP(-124354846.65650933807)
    fjkm[13] =  Helpers.makeFP(7129538.3762123397968)
    fjkm[14] =  Helpers.makeFP(107358912.41929520843)
    fjkm[15] =  Helpers.makeFP(-104902766.60439072992)
    fjkm[16] =  Helpers.makeFP(43358616.238781106380)
    fjkm[17] =  Helpers.makeFP(-6986431.7916780392488)
    j = 7; k = 5; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(66.266099201166070998)
    fjkm[1] =  Helpers.makeFP(-801.85159036517143250)
    fjkm[2] =  Helpers.makeFP(-10599.673972529735017)
    fjkm[3] =  Helpers.makeFP(150238.26124378282197)
    fjkm[4] =  Helpers.makeFP(-349014.85897753891605)
    fjkm[5] =  Helpers.makeFP(-2089251.7495501184712)
    fjkm[6] =  Helpers.makeFP(11932847.810754978267)
    fjkm[7] =  Helpers.makeFP(-12233248.989355019522)
    fjkm[8] =  Helpers.makeFP(-52996346.810335384350)
    fjkm[9] =  Helpers.makeFP(167552806.49381000405)
    fjkm[10] =  Helpers.makeFP(-104151238.67453537869)
    fjkm[11] =  Helpers.makeFP(-295472139.38679802840)
    fjkm[12] =  Helpers.makeFP(638921130.05027917750)
    fjkm[13] =  Helpers.makeFP(-364575119.55069248400)
    fjkm[14] =  Helpers.makeFP(-321938848.50186568760)
    fjkm[15] =  Helpers.makeFP(670099675.87405621186)
    fjkm[16] =  Helpers.makeFP(-477068925.07477830810)
    fjkm[17] =  Helpers.makeFP(165792634.22539301473)
    fjkm[18] =  Helpers.makeFP(-23563863.859185525714)
    j = 8; k = 5; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-92.036248890508431941)
    fjkm[1] =  Helpers.makeFP(1286.5459820115674202)
    fjkm[2] =  Helpers.makeFP(15984.246642014751810)
    fjkm[3] =  Helpers.makeFP(-274251.94134559012498)
    fjkm[4] =  Helpers.makeFP(875242.48789234256927)
    fjkm[5] =  Helpers.makeFP(3479369.5294348938478)
    fjkm[6] =  Helpers.makeFP(-28243123.382389417092)
    fjkm[7] =  Helpers.makeFP(48978753.833933594038)
    fjkm[8] =  Helpers.makeFP(96403146.255130900766)
    fjkm[9] =  Helpers.makeFP(-511553591.82361285211)
    fjkm[10] =  Helpers.makeFP(629980523.20384634815)
    fjkm[11] =  Helpers.makeFP(530948403.41019250637)
    fjkm[12] =  Helpers.makeFP(-2455930387.0192782105)
    fjkm[13] =  Helpers.makeFP(2650615136.5125114389)
    fjkm[14] =  Helpers.makeFP(-13787083.107153494438)
    fjkm[15] =  Helpers.makeFP(-2934135354.5042859293)
    fjkm[16] =  Helpers.makeFP(3427343175.1586684272)
    fjkm[17] =  Helpers.makeFP(-1959752975.9949664819)
    fjkm[18] =  Helpers.makeFP(590135160.40330437780)
    fjkm[19] =  Helpers.makeFP(-75099321.778257988527)
    j = 9; k = 5; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(124.24893600218638312)
    fjkm[1] =  Helpers.makeFP(-1977.9098049255553633)
    fjkm[2] =  Helpers.makeFP(-23091.371137548782696)
    fjkm[3] =  Helpers.makeFP(474842.97883978903678)
    fjkm[4] =  Helpers.makeFP(-1940160.8026042800714)
    fjkm[5] =  Helpers.makeFP(-5051698.1764753913085)
    fjkm[6] =  Helpers.makeFP(60910728.961121054906)
    fjkm[7] =  Helpers.makeFP(-150451158.23316204445)
    fjkm[8] =  Helpers.makeFP(-115862597.99920025974)
    fjkm[9] =  Helpers.makeFP(1340568362.9608932867)
    fjkm[10] =  Helpers.makeFP(-2534626023.8559564861)
    fjkm[11] =  Helpers.makeFP(57223508.996001180928)
    fjkm[12] =  Helpers.makeFP(7462542511.1368897210)
    fjkm[13] =  Helpers.makeFP(-12803010436.906857334)
    fjkm[14] =  Helpers.makeFP(6529418551.9917203148)
    fjkm[15] =  Helpers.makeFP(8333347633.6309463361)
    fjkm[16] =  Helpers.makeFP(-17879701023.370781023)
    fjkm[17] =  Helpers.makeFP(15384544080.383156452)
    fjkm[18] =  Helpers.makeFP(-7429525037.6309918827)
    fjkm[19] =  Helpers.makeFP(1979364564.1715841600)
    fjkm[20] =  Helpers.makeFP(-228201703.20311712289)
    j = 10; k = 5; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-163.78268836651841411)
    fjkm[1] =  Helpers.makeFP(2934.5753597465244149)
    fjkm[2] =  Helpers.makeFP(32133.674298098814287)
    fjkm[3] =  Helpers.makeFP(-786448.50173515116761)
    fjkm[4] =  Helpers.makeFP(3940574.6676366506081)
    fjkm[5] =  Helpers.makeFP(6023482.0215492578926)
    fjkm[6] =  Helpers.makeFP(-121576300.80985078356)
    fjkm[7] =  Helpers.makeFP(396478314.88388992406)
    fjkm[8] =  Helpers.makeFP(-28867608.104982563453)
    fjkm[9] =  Helpers.makeFP(-3079357130.2226958330)
    fjkm[10] =  Helpers.makeFP(8249384124.8426910359)
    fjkm[11] =  Helpers.makeFP(-5275292901.0490022350)
    fjkm[12] =  Helpers.makeFP(-17864885603.458945318)
    fjkm[13] =  Helpers.makeFP(48480263067.875486448)
    fjkm[14] =  Helpers.makeFP(-46292296797.993831733)
    fjkm[15] =  Helpers.makeFP(-6808810264.3074322272)
    fjkm[16] =  Helpers.makeFP(70205428541.430035549)
    fjkm[17] =  Helpers.makeFP(-89866265315.798467190)
    fjkm[18] =  Helpers.makeFP(62728346454.981427111)
    fjkm[19] =  Helpers.makeFP(-26379975109.497266807)
    fjkm[20] =  Helpers.makeFP(6313975478.5070403854)
    fjkm[21] =  Helpers.makeFP(-665761463.93251599995)
    j = 11; k = 5; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(0.57250142097473144531)
    fjkm[1] = T.zero
    fjkm[2] =  Helpers.makeFP(-26.491430486951555525)
    fjkm[3] = T.zero
    fjkm[4] =  Helpers.makeFP(218.19051174421159048)
    fjkm[5] = T.zero
    fjkm[6] =  Helpers.makeFP(-699.57962737613254123)
    fjkm[7] = T.zero
    fjkm[8] =  Helpers.makeFP(1059.9904525279998779)
    fjkm[9] = T.zero
    fjkm[10] =  Helpers.makeFP(-765.25246814118164230)
    fjkm[11] = T.zero
    fjkm[12] =  Helpers.makeFP(212.57013003921712286)
    j = 0; k = 6; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-3.1487578153610229492)
    fjkm[1] =  Helpers.makeFP(3.5304254293441772461)
    fjkm[2] =  Helpers.makeFP(198.68572865213666643)
    fjkm[3] =  Helpers.makeFP(-216.34668231010437012)
    fjkm[4] =  Helpers.makeFP(-2072.8098615700101096)
    fjkm[5] =  Helpers.makeFP(2218.2702027328178365)
    fjkm[6] =  Helpers.makeFP(8045.1657148255242242)
    fjkm[7] =  Helpers.makeFP(-8511.5521330762792517)
    fjkm[8] =  Helpers.makeFP(-14309.871109127998352)
    fjkm[9] =  Helpers.makeFP(15016.531410813331604)
    fjkm[10] =  Helpers.makeFP(11861.413256188315456)
    fjkm[11] =  Helpers.makeFP(-12371.581568282436550)
    fjkm[12] =  Helpers.makeFP(-3719.9772756862996501)
    fjkm[13] =  Helpers.makeFP(3861.6906957124443986)
    j = 1; k = 6; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(10.233462899923324585)
    fjkm[1] =  Helpers.makeFP(-24.045059680938720703)
    fjkm[2] =  Helpers.makeFP(-830.55504153881754194)
    fjkm[3] =  Helpers.makeFP(1907.3829950605119978)
    fjkm[4] =  Helpers.makeFP(9817.0755057463759468)
    fjkm[5] =  Helpers.makeFP(-24000.956291863274953)
    fjkm[6] =  Helpers.makeFP(-37145.398656393453558)
    fjkm[7] =  Helpers.makeFP(109134.42187067667643)
    fjkm[8] =  Helpers.makeFP(44836.131085879493643)
    fjkm[9] =  Helpers.makeFP(-222597.99503087997437)
    fjkm[10] =  Helpers.makeFP(21083.102663859050460)
    fjkm[11] =  Helpers.makeFP(208148.67133440140671)
    fjkm[12] =  Helpers.makeFP(-75945.993209761297570)
    fjkm[13] =  Helpers.makeFP(-72698.984473412256018)
    fjkm[14] =  Helpers.makeFP(38306.908850817252349)
    j = 2; k = 6; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-25.583657249808311462)
    fjkm[1] =  Helpers.makeFP(94.002347901463508606)
    fjkm[2] =  Helpers.makeFP(2561.4464542163269860)
    fjkm[3] =  Helpers.makeFP(-9323.5958246609994343)
    fjkm[4] =  Helpers.makeFP(-30925.007683879997995)
    fjkm[5] =  Helpers.makeFP(137806.75057795568307)
    fjkm[6] =  Helpers.makeFP(66832.114908046586804)
    fjkm[7] =  Helpers.makeFP(-695211.42408942898710)
    fjkm[8] =  Helpers.makeFP(297044.24306208789349)
    fjkm[9] =  Helpers.makeFP(1456689.0310313083630)
    fjkm[10] =  Helpers.makeFP(-1349408.4412036920976)
    fjkm[11] =  Helpers.makeFP(-1160751.9107670259288)
    fjkm[12] =  Helpers.makeFP(1778986.1326650806502)
    fjkm[13] =  Helpers.makeFP(2732.4118798791034334)
    fjkm[14] =  Helpers.makeFP(-771855.42780552482418)
    fjkm[15] =  Helpers.makeFP(274755.25810395356345)
    j = 3; k = 6; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(54.365271655842661858)
    fjkm[1] =  Helpers.makeFP(-276.51818633079528809)
    fjkm[2] =  Helpers.makeFP(-6505.3076391667127609)
    fjkm[3] =  Helpers.makeFP(33393.909001989024026)
    fjkm[4] =  Helpers.makeFP(70377.367684318314469)
    fjkm[5] =  Helpers.makeFP(-559956.42247611134141)
    fjkm[6] =  Helpers.makeFP(214189.08434628603635)
    fjkm[7] =  Helpers.makeFP(2932546.1434609688359)
    fjkm[8] =  Helpers.makeFP(-3873550.9334950489425)
    fjkm[9] =  Helpers.makeFP(-5169809.5626455059758)
    fjkm[10] =  Helpers.makeFP(12515387.720161636405)
    fjkm[11] =  Helpers.makeFP(-485287.10103841189331)
    fjkm[12] =  Helpers.makeFP(-14696506.049911874334)
    fjkm[13] =  Helpers.makeFP(8973612.6112505443054)
    fjkm[14] =  Helpers.makeFP(4358025.7113579717181)
    fjkm[15] =  Helpers.makeFP(-5899263.9630258568617)
    fjkm[16] =  Helpers.makeFP(1593568.9458830170786)
    j = 4; k = 6; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-103.29401614610105753)
    fjkm[1] =  Helpers.makeFP(679.49573871586471796)
    fjkm[2] =  Helpers.makeFP(14406.592158034443855)
    fjkm[3] =  Helpers.makeFP(-97833.485413427407644)
    fjkm[4] =  Helpers.makeFP(-109874.73447139263153)
    fjkm[5] =  Helpers.makeFP(1806898.4781330669971)
    fjkm[6] =  Helpers.makeFP(-2228617.5688649368428)
    fjkm[7] =  Helpers.makeFP(-9039218.0698707036945)
    fjkm[8] =  Helpers.makeFP(22913970.357558080752)
    fjkm[9] =  Helpers.makeFP(6014580.7747564135778)
    fjkm[10] =  Helpers.makeFP(-67365551.082731008652)
    fjkm[11] =  Helpers.makeFP(49347945.008100392566)
    fjkm[12] =  Helpers.makeFP(61291772.218955972273)
    fjkm[13] =  Helpers.makeFP(-101851641.61990357673)
    fjkm[14] =  Helpers.makeFP(18812228.438435360796)
    fjkm[15] =  Helpers.makeFP(48878028.306514326695)
    fjkm[16] =  Helpers.makeFP(-36319210.680616361669)
    fjkm[17] =  Helpers.makeFP(7931540.8655372143613)
    j = 5; k = 6; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(180.76452825567685068)
    fjkm[1] =  Helpers.makeFP(-1472.1516226977109909)
    fjkm[2] =  Helpers.makeFP(-28789.438034501904622)
    fjkm[3] =  Helpers.makeFP(248412.49281514968191)
    fjkm[4] =  Helpers.makeFP(57720.374439080618322)
    fjkm[5] =  Helpers.makeFP(-4919773.7285477433167)
    fjkm[6] =  Helpers.makeFP(10556839.574755387407)
    fjkm[7] =  Helpers.makeFP(20546468.524262875642)
    fjkm[8] =  Helpers.makeFP(-95782021.413901062575)
    fjkm[9] =  Helpers.makeFP(47859753.794019524423)
    fjkm[10] =  Helpers.makeFP(248947938.76422519634)
    fjkm[11] =  Helpers.makeFP(-397302112.77505450021)
    fjkm[12] =  Helpers.makeFP(-60373613.593196943601)
    fjkm[13] =  Helpers.makeFP(619895830.67946774788)
    fjkm[14] =  Helpers.makeFP(-460542977.57691540068)
    fjkm[15] =  Helpers.makeFP(-133881283.62288371220)
    fjkm[16] =  Helpers.makeFP(360816116.57296145253)
    fjkm[17] =  Helpers.makeFP(-191228273.50596204944)
    fjkm[18] =  Helpers.makeFP(35131056.264643928958)
    j = 6; k = 6; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-296.97029642004054040)
    fjkm[1] =  Helpers.makeFP(2903.8678610353963450)
    fjkm[2] =  Helpers.makeFP(53085.574017544759304)
    fjkm[3] =  Helpers.makeFP(-566162.21564224131681)
    fjkm[4] =  Helpers.makeFP(351303.05079310148650)
    fjkm[5] =  Helpers.makeFP(11717363.296337798053)
    fjkm[6] =  Helpers.makeFP(-37248885.401731669600)
    fjkm[7] =  Helpers.makeFP(-29556393.543845627395)
    fjkm[8] =  Helpers.makeFP(317963019.15514055453)
    fjkm[9] =  Helpers.makeFP(-391675101.18705789558)
    fjkm[10] =  Helpers.makeFP(-632571201.89067213266)
    fjkm[11] =  Helpers.makeFP(2001265322.6458411313)
    fjkm[12] =  Helpers.makeFP(-1008064787.2696644192)
    fjkm[13] =  Helpers.makeFP(-2363398838.2753953344)
    fjkm[14] =  Helpers.makeFP(3743079200.5912006268)
    fjkm[15] =  Helpers.makeFP(-1091651847.4629542050)
    fjkm[16] =  Helpers.makeFP(-1902208028.0358040356)
    fjkm[17] =  Helpers.makeFP(2133928476.4409109596)
    fjkm[18] =  Helpers.makeFP(-893289789.98112876745)
    fjkm[19] =  Helpers.makeFP(141870657.61208999896)
    j = 7; k = 6; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(464.01608815631334437)
    fjkm[1] =  Helpers.makeFP(-5325.3068480961956084)
    fjkm[2] =  Helpers.makeFP(-91725.505981153156193)
    fjkm[3] =  Helpers.makeFP(1185316.6466349283157)
    fjkm[4] =  Helpers.makeFP(-1734253.4162956622921)
    fjkm[5] =  Helpers.makeFP(-24965643.657687719930)
    fjkm[6] =  Helpers.makeFP(109865301.06964371257)
    fjkm[7] =  Helpers.makeFP(-7842536.5990090553082)
    fjkm[8] =  Helpers.makeFP(-882004248.16533042144)
    fjkm[9] =  Helpers.makeFP(1812569161.1229405097)
    fjkm[10] =  Helpers.makeFP(796190115.17482420785)
    fjkm[11] =  Helpers.makeFP(-7547640676.2891254543)
    fjkm[12] =  Helpers.makeFP(8606208381.3162846761)
    fjkm[13] =  Helpers.makeFP(4634326771.3840251843)
    fjkm[14] =  Helpers.makeFP(-19504767652.151161478)
    fjkm[15] =  Helpers.makeFP(15458811432.485826518)
    fjkm[16] =  Helpers.makeFP(3233232293.8508888375)
    fjkm[17] =  Helpers.makeFP(-14292761227.388542723)
    fjkm[18] =  Helpers.makeFP(10872211035.524945516)
    fjkm[19] =  Helpers.makeFP(-3794154076.5815443275)
    fjkm[20] =  Helpers.makeFP(531367092.46942384383)
    j = 8; k = 6; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-696.02413223447001656)
    fjkm[1] =  Helpers.makeFP(9211.7329484450783639)
    fjkm[2] =  Helpers.makeFP(150176.80785295595602)
    fjkm[3] =  Helpers.makeFP(-2316795.9016969799608)
    fjkm[4] =  Helpers.makeFP(5353301.7267099139240)
    fjkm[5] =  Helpers.makeFP(48240128.320645392607)
    fjkm[6] =  Helpers.makeFP(-285088568.66606943443)
    fjkm[7] =  Helpers.makeFP(236539658.57255855849)
    fjkm[8] =  Helpers.makeFP(2091063546.0424140229)
    fjkm[9] =  Helpers.makeFP(-6478408107.9479218188)
    fjkm[10] =  Helpers.makeFP(2114947617.4171696310)
    fjkm[11] =  Helpers.makeFP(22484222108.370436724)
    fjkm[12] =  Helpers.makeFP(-43504182331.312579142)
    fjkm[13] =  Helpers.makeFP(9073306866.7430378915)
    fjkm[14] =  Helpers.makeFP(72378013713.663446159)
    fjkm[15] =  Helpers.makeFP(-104755002543.75143509)
    fjkm[16] =  Helpers.makeFP(35288894490.708636111)
    fjkm[17] =  Helpers.makeFP(58426452630.062379587)
    fjkm[18] =  Helpers.makeFP(-83650899080.625595930)
    fjkm[19] =  Helpers.makeFP(49569134901.994243944)
    fjkm[20] =  Helpers.makeFP(-14909719423.420583328)
    fjkm[21] =  Helpers.makeFP(1869289195.4875346262)
    j = 9; k = 6; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(1009.2349917399815240)
    fjkm[1] =  Helpers.makeFP(-15188.489623096204014)
    fjkm[2] =  Helpers.makeFP(-234912.74468029359442)
    fjkm[3] =  Helpers.makeFP(4278033.8338821994157)
    fjkm[4] =  Helpers.makeFP(-13570280.995019535225)
    fjkm[5] =  Helpers.makeFP(-85095459.392767211454)
    fjkm[6] =  Helpers.makeFP(669951675.09023006543)
    fjkm[7] =  Helpers.makeFP(-1041016026.5703218480)
    fjkm[8] =  Helpers.makeFP(-4241350570.5261899700)
    fjkm[9] =  Helpers.makeFP(19536358548.670235798)
    fjkm[10] =  Helpers.makeFP(-19158789931.456781880)
    fjkm[11] =  Helpers.makeFP(-52588961930.566950783)
    fjkm[12] =  Helpers.makeFP(168223251386.27505861)
    fjkm[13] =  Helpers.makeFP(-131543443714.17931735)
    fjkm[14] =  Helpers.makeFP(-183278984759.32788630)
    fjkm[15] =  Helpers.makeFP(500731039137.68584765)
    fjkm[16] =  Helpers.makeFP(-395175402811.80868032)
    fjkm[17] =  Helpers.makeFP(-83866621459.668331313)
    fjkm[18] =  Helpers.makeFP(443918936157.05017610)
    fjkm[19] =  Helpers.makeFP(-420471377306.84165961)
    fjkm[20] =  Helpers.makeFP(207052924562.97132855)
    fjkm[21] =  Helpers.makeFP(-54907932888.507130529)
    fjkm[22] =  Helpers.makeFP(6236056730.2635893277)
    j = 10; k = 6; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(1.7277275025844573975)
    fjkm[1] = T.zero
    fjkm[2] =  Helpers.makeFP(-108.09091978839465550)
    fjkm[3] = T.zero
    fjkm[4] =  Helpers.makeFP(1200.9029132163524628)
    fjkm[5] = T.zero
    fjkm[6] =  Helpers.makeFP(-5305.6469786134031084)
    fjkm[7] = T.zero
    fjkm[8] =  Helpers.makeFP(11655.393336864533248)
    fjkm[9] = T.zero
    fjkm[10] =  Helpers.makeFP(-13586.550006434137439)
    fjkm[11] = T.zero
    fjkm[12] =  Helpers.makeFP(8061.7221817373093845)
    fjkm[13] = T.zero
    fjkm[14] =  Helpers.makeFP(-1919.4576623184069963)
    j = 0; k = 7; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-11.230228766798973083)
    fjkm[1] =  Helpers.makeFP(12.382047101855278015)
    fjkm[2] =  Helpers.makeFP(918.77281820135457175)
    fjkm[3] =  Helpers.makeFP(-990.83343139361767542)
    fjkm[4] =  Helpers.makeFP(-12609.480588771700859)
    fjkm[5] =  Helpers.makeFP(13410.082530915935834)
    fjkm[6] =  Helpers.makeFP(66320.587232667538855)
    fjkm[7] =  Helpers.makeFP(-69857.685218409807594)
    fjkm[8] =  Helpers.makeFP(-169003.20338453573209)
    fjkm[9] =  Helpers.makeFP(176773.46560911208759)
    fjkm[10] =  Helpers.makeFP(224178.07510616326774)
    fjkm[11] =  Helpers.makeFP(-233235.77511045269270)
    fjkm[12] =  Helpers.makeFP(-149141.86036214022361)
    fjkm[13] =  Helpers.makeFP(154516.34181663176320)
    fjkm[14] =  Helpers.makeFP(39348.882077527343424)
    fjkm[15] =  Helpers.makeFP(-40628.520519072948089)
    j = 1; k = 7; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(42.113357875496149063)
    fjkm[1] =  Helpers.makeFP(-96.752740144729614258)
    fjkm[2] =  Helpers.makeFP(-4309.3875268953187125)
    fjkm[3] =  Helpers.makeFP(9728.1827809555189950)
    fjkm[4] =  Helpers.makeFP(67131.493914289162272)
    fjkm[5] =  Helpers.makeFP(-158519.18454455852509)
    fjkm[6] =  Helpers.makeFP(-361549.21741861661275)
    fjkm[7] =  Helpers.makeFP(965627.75010763936573)
    fjkm[8] =  Helpers.makeFP(791368.90269480066167)
    fjkm[9] =  Helpers.makeFP(-2797294.4008474879795)
    fjkm[10] =  Helpers.makeFP(-473067.29978352049251)
    fjkm[11] =  Helpers.makeFP(4157484.3019688460562)
    fjkm[12] =  Helpers.makeFP(-742925.21875958646140)
    fjkm[13] =  Helpers.makeFP(-3063454.4290601775661)
    fjkm[14] =  Helpers.makeFP(1186992.6183777028865)
    fjkm[15] =  Helpers.makeFP(886789.43999110403230)
    fjkm[16] =  Helpers.makeFP(-463948.91246287829107)
    j = 2; k = 7; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-119.32118064723908901)
    fjkm[1] =  Helpers.makeFP(426.72709654457867146)
    fjkm[2] =  Helpers.makeFP(14774.672950860112906)
    fjkm[3] =  Helpers.makeFP(-52455.440737222809167)
    fjkm[4] =  Helpers.makeFP(-242280.57068559899926)
    fjkm[5] =  Helpers.makeFP(994102.67395229967167)
    fjkm[6] =  Helpers.makeFP(1032233.4449197463691)
    fjkm[7] =  Helpers.makeFP(-6741567.1085603777512)
    fjkm[8] =  Helpers.makeFP(646495.83215296654790)
    fjkm[9] =  Helpers.makeFP(20680668.518424851831)
    fjkm[10] =  Helpers.makeFP(-13425393.794712164658)
    fjkm[11] =  Helpers.makeFP(-29950004.715897617246)
    fjkm[12] =  Helpers.makeFP(32133326.488920312047)
    fjkm[13] =  Helpers.makeFP(16877471.905929211282)
    fjkm[14] =  Helpers.makeFP(-30879035.210339582752)
    fjkm[15] =  Helpers.makeFP(1961435.1350279426026)
    fjkm[16] =  Helpers.makeFP(10741165.112229910651)
    fjkm[17] =  Helpers.makeFP(-3791244.3495002070744)
    j = 3; k = 7; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(283.38780403719283640)
    fjkm[1] =  Helpers.makeFP(-1397.7315495908260345)
    fjkm[2] =  Helpers.makeFP(-41380.460209263255820)
    fjkm[3] =  Helpers.makeFP(205570.88069305533455)
    fjkm[4] =  Helpers.makeFP(656958.69278146053058)
    fjkm[5] =  Helpers.makeFP(-4406726.3053560412498)
    fjkm[6] =  Helpers.makeFP(-460386.15389300137896)
    fjkm[7] =  Helpers.makeFP(31745963.553354091997)
    fjkm[8] =  Helpers.makeFP(-30185144.899501059008)
    fjkm[9] =  Helpers.makeFP(-92885893.761842946947)
    fjkm[10] =  Helpers.makeFP(159671874.67639934532)
    fjkm[11] =  Helpers.makeFP(89037317.391947147287)
    fjkm[12] =  Helpers.makeFP(-324112057.62064508289)
    fjkm[13] =  Helpers.makeFP(75417289.288447113978)
    fjkm[14] =  Helpers.makeFP(275169534.60077554540)
    fjkm[15] =  Helpers.makeFP(-191141129.57979682342)
    fjkm[16] =  Helpers.makeFP(-56632059.761422146328)
    fjkm[17] =  Helpers.makeFP(92789782.492575658213)
    fjkm[18] =  Helpers.makeFP(-24828398.690560814574)
    j = 4; k = 7; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-595.11438847810495645)
    fjkm[1] =  Helpers.makeFP(3784.5764889410929754)
    fjkm[2] =  Helpers.makeFP(100370.50080364884343)
    fjkm[3] =  Helpers.makeFP(-654419.09384311857985)
    fjkm[4] =  Helpers.makeFP(-1371381.6192330607878)
    fjkm[5] =  Helpers.makeFP(15498343.812751787009)
    fjkm[6] =  Helpers.makeFP(-11665144.592299357907)
    fjkm[7] =  Helpers.makeFP(-112601561.49426607138)
    fjkm[8] =  Helpers.makeFP(219262318.25667364074)
    fjkm[9] =  Helpers.makeFP(254104121.37964987144)
    fjkm[10] =  Helpers.makeFP(-1006396481.7103226659)
    fjkm[11] =  Helpers.makeFP(253036623.98729691889)
    fjkm[12] =  Helpers.makeFP(1831393810.4978639927)
    fjkm[13] =  Helpers.makeFP(-1774529065.4266491466)
    fjkm[14] =  Helpers.makeFP(-1003472637.9292914864)
    fjkm[15] =  Helpers.makeFP(2290280875.9786741918)
    fjkm[16] =  Helpers.makeFP(-651246794.10887221841)
    fjkm[17] =  Helpers.makeFP(-803784902.98109705890)
    fjkm[18] =  Helpers.makeFP(640483342.29369123263)
    fjkm[19] =  Helpers.makeFP(-138440607.21363135318)
    j = 5; k = 7; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(1140.6359112497011665)
    fjkm[1] =  Helpers.makeFP(-8957.2682584379799664)
    fjkm[2] =  Helpers.makeFP(-218407.33629125532461)
    fjkm[3] =  Helpers.makeFP(1794837.6930232931017)
    fjkm[4] =  Helpers.makeFP(2046161.0563529025012)
    fjkm[5] =  Helpers.makeFP(-45986041.828079905965)
    fjkm[6] =  Helpers.makeFP(74544641.814482732603)
    fjkm[7] =  Helpers.makeFP(314850611.45725349592)
    fjkm[8] =  Helpers.makeFP(-1044136171.4521382041)
    fjkm[9] =  Helpers.makeFP(-187106978.33355739111)
    fjkm[10] =  Helpers.makeFP(4438953626.0956817754)
    fjkm[11] =  Helpers.makeFP(-4408582954.0483059788)
    fjkm[12] =  Helpers.makeFP(-6264272163.4397192983)
    fjkm[13] =  Helpers.makeFP(14149702487.577580987)
    fjkm[14] =  Helpers.makeFP(-2713149740.6519136094)
    fjkm[15] =  Helpers.makeFP(-14233558941.890554329)
    fjkm[16] =  Helpers.makeFP(12753481214.719287040)
    fjkm[17] =  Helpers.makeFP(934842459.40433410209)
    fjkm[18] =  Helpers.makeFP(-6845048171.9341116529)
    fjkm[19] =  Helpers.makeFP(3754053882.0127951637)
    fjkm[20] =  Helpers.makeFP(-682202534.28377278514)
    j = 6; k = 7; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-2036.8498415173235117)
    fjkm[1] =  Helpers.makeFP(19163.284363303755526)
    fjkm[2] =  Helpers.makeFP(436370.36938456366105)
    fjkm[3] =  Helpers.makeFP(-4395730.5804739226086)
    fjkm[4] =  Helpers.makeFP(-1112960.9840974107984)
    fjkm[5] =  Helpers.makeFP(119491789.40923461317)
    fjkm[6] =  Helpers.makeFP(-304912988.84344882540)
    fjkm[7] =  Helpers.makeFP(-691963837.01336538937)
    fjkm[8] =  Helpers.makeFP(3885386169.7360802683)
    fjkm[9] =  Helpers.makeFP(-2313847981.3260245039)
    fjkm[10] =  Helpers.makeFP(-14816925759.772210986)
    fjkm[11] =  Helpers.makeFP(28337891715.905708458)
    fjkm[12] =  Helpers.makeFP(7872387353.1924133326)
    fjkm[13] =  Helpers.makeFP(-72435569735.091307437)
    fjkm[14] =  Helpers.makeFP(59410896148.189366465)
    fjkm[15] =  Helpers.makeFP(46141874867.831978016)
    fjkm[16] =  Helpers.makeFP(-105411711029.14681739)
    fjkm[17] =  Helpers.makeFP(45764643115.283153298)
    fjkm[18] =  Helpers.makeFP(33619493138.706044340)
    fjkm[19] =  Helpers.makeFP(-45524891856.627263052)
    fjkm[20] =  Helpers.makeFP(19398990085.810093364)
    fjkm[21] =  Helpers.makeFP(-3046176001.4829695650)
    j = 7; k = 7; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(3437.1841075604834259)
    fjkm[1] =  Helpers.makeFP(-37884.316448339552153)
    fjkm[2] =  Helpers.makeFP(-813572.82790964112831)
    fjkm[3] =  Helpers.makeFP(9844700.1196742646463)
    fjkm[4] =  Helpers.makeFP(-5932665.5737596173789)
    fjkm[5] =  Helpers.makeFP(-278602941.80981757775)
    fjkm[6] =  Helpers.makeFP(999702331.75599910068)
    fjkm[7] =  Helpers.makeFP(1082145758.5676864833)
    fjkm[8] =  Helpers.makeFP(-12097872233.934345656)
    fjkm[9] =  Helpers.makeFP(16269568192.896168430)
    fjkm[10] =  Helpers.makeFP(37442906272.629884505)
    fjkm[11] =  Helpers.makeFP(-127678482632.39934914)
    fjkm[12] =  Helpers.makeFP(56533169829.379619075)
    fjkm[13] =  Helpers.makeFP(263705962704.22363017)
    fjkm[14] =  Helpers.makeFP(-430880513772.40015440)
    fjkm[15] =  Helpers.makeFP(28685028305.645455607)
    fjkm[16] =  Helpers.makeFP(544657720548.16430202)
    fjkm[17] =  Helpers.makeFP(-543385080747.85240194)
    fjkm[18] =  Helpers.makeFP(33319140131.863860742)
    fjkm[19] =  Helpers.makeFP(311025095335.01861076)
    fjkm[20] =  Helpers.makeFP(-257492440682.78870598)
    fjkm[21] =  Helpers.makeFP(90635479554.844098597)
    fjkm[22] =  Helpers.makeFP(-12545989968.390205031)
    j = 8; k = 7; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-5537.6855066252232973)
    fjkm[1] =  Helpers.makeFP(70275.288364441469184)
    fjkm[2] =  Helpers.makeFP(1432194.8403133915934)
    fjkm[3] =  Helpers.makeFP(-20502591.084346145880)
    fjkm[4] =  Helpers.makeFP(29691158.739889488095)
    fjkm[5] =  Helpers.makeFP(592508323.24904278254)
    fjkm[6] =  Helpers.makeFP(-2831998971.7799303680)
    fjkm[7] =  Helpers.makeFP(-487772628.07968000257)
    fjkm[8] =  Helpers.makeFP(32638786024.059947790)
    fjkm[9] =  Helpers.makeFP(-70496897875.469508762)
    fjkm[10] =  Helpers.makeFP(-62531875035.153643030)
    fjkm[11] =  Helpers.makeFP(456706039700.77564846)
    fjkm[12] =  Helpers.makeFP(-503779673552.18388727)
    fjkm[13] =  Helpers.makeFP(-650638245764.84731771)
    fjkm[14] =  Helpers.makeFP(2119375307389.9958522)
    fjkm[15] =  Helpers.makeFP(-1373635599107.5234068)
    fjkm[16] =  Helpers.makeFP(-1758554601545.7817139)
    fjkm[17] =  Helpers.makeFP(3640007756944.3988399)
    fjkm[18] =  Helpers.makeFP(-1912987782878.0613666)
    fjkm[19] =  Helpers.makeFP(-1044942776057.9478291)
    fjkm[20] =  Helpers.makeFP(2082243082925.6114167)
    fjkm[21] =  Helpers.makeFP(-1292209352199.4454475)
    fjkm[22] =  Helpers.makeFP(389815335189.77376153)
    fjkm[23] =  Helpers.makeFP(-48292926381.689492854)
    j = 9; k = 7; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(6.0740420012734830379)
    fjkm[1] = T.zero
    fjkm[2] =  Helpers.makeFP(-493.91530477308801242)
    fjkm[3] = T.zero
    fjkm[4] =  Helpers.makeFP(7109.5143024893637214)
    fjkm[5] = T.zero
    fjkm[6] =  Helpers.makeFP(-41192.654968897551298)
    fjkm[7] = T.zero
    fjkm[8] =  Helpers.makeFP(122200.46498301745979)
    fjkm[9] = T.zero
    fjkm[10] =  Helpers.makeFP(-203400.17728041553428)
    fjkm[11] = T.zero
    fjkm[12] =  Helpers.makeFP(192547.00123253153236)
    fjkm[13] = T.zero
    fjkm[14] =  Helpers.makeFP(-96980.598388637513489)
    fjkm[15] = T.zero
    fjkm[16] =  Helpers.makeFP(20204.291330966148643)
    j = 0; k = 8; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-45.555315009551122785)
    fjkm[1] =  Helpers.makeFP(49.604676343733444810)
    fjkm[2] =  Helpers.makeFP(4692.1953953443361180)
    fjkm[3] =  Helpers.makeFP(-5021.4722651930614596)
    fjkm[4] =  Helpers.makeFP(-81759.414478627682797)
    fjkm[5] =  Helpers.makeFP(86499.090680287258611)
    fjkm[6] =  Helpers.makeFP(556100.84208011694252)
    fjkm[7] =  Helpers.makeFP(-583562.61205938197672)
    fjkm[8] =  Helpers.makeFP(-1894107.2072367706267)
    fjkm[9] =  Helpers.makeFP(1975574.1838921155999)
    fjkm[10] =  Helpers.makeFP(3559503.1024072718499)
    fjkm[11] =  Helpers.makeFP(-3695103.2205942155394)
    fjkm[12] =  Helpers.makeFP(-3754666.5240343648810)
    fjkm[13] =  Helpers.makeFP(3883031.1915227192359)
    fjkm[14] =  Helpers.makeFP(2085082.8653557065400)
    fjkm[15] =  Helpers.makeFP(-2149736.5976147982157)
    fjkm[16] =  Helpers.makeFP(-474800.84627770449312)
    fjkm[17] =  Helpers.makeFP(488270.37383168192555)
    j = 1; k = 8; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(193.61008879059227183)
    fjkm[1] =  Helpers.makeFP(-437.33102409169077873)
    fjkm[2] =  Helpers.makeFP(-24389.798720089893322)
    fjkm[3] =  Helpers.makeFP(54330.683525039681367)
    fjkm[4] =  Helpers.makeFP(481258.52318321001006)
    fjkm[5] =  Helpers.makeFP(-1109084.2311883407405)
    fjkm[6] =  Helpers.makeFP(-3433050.7548587226633)
    fjkm[7] =  Helpers.makeFP(8650457.5434684857726)
    fjkm[8] =  Helpers.makeFP(11004225.300068311602)
    fjkm[9] =  Helpers.makeFP(-33238526.475380749062)
    fjkm[10] =  Helpers.makeFP(-15303078.309507955098)
    fjkm[11] =  Helpers.makeFP(69562860.629902112723)
    fjkm[12] =  Helpers.makeFP(1830924.9239440239572)
    fjkm[13] =  Helpers.makeFP(-80869740.517663243591)
    fjkm[14] =  Helpers.makeFP(18943271.994495349280)
    fjkm[15] =  Helpers.makeFP(49072182.784650581825)
    fjkm[16] =  Helpers.makeFP(-19806771.899029389669)
    fjkm[17] =  Helpers.makeFP(-12122574.798579689186)
    fjkm[18] =  Helpers.makeFP(6307948.1226220563244)
    j = 2; k = 8; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-613.09861450354219414)
    fjkm[1] =  Helpers.makeFP(2147.8571771753195208)
    fjkm[2] =  Helpers.makeFP(91956.399098661058815)
    fjkm[3] =  Helpers.makeFP(-320284.80771632295052)
    fjkm[4] =  Helpers.makeFP(-1938565.2131506522862)
    fjkm[5] =  Helpers.makeFP(7533108.6348155997448)
    fjkm[6] =  Helpers.makeFP(12364512.209251265036)
    fjkm[7] =  Helpers.makeFP(-65358277.938386196419)
    fjkm[8] =  Helpers.makeFP(-16530840.331176116137)
    fjkm[9] =  Helpers.makeFP(269292234.00676317160)
    fjkm[10] =  Helpers.makeFP(-105780946.98529899276)
    fjkm[11] =  Helpers.makeFP(-575008738.51905591292)
    fjkm[12] =  Helpers.makeFP(462747211.13824444405)
    fjkm[13] =  Helpers.makeFP(619754381.87898314676)
    fjkm[14] =  Helpers.makeFP(-755460241.94008607635)
    fjkm[15] =  Helpers.makeFP(-252322946.06096464110)
    fjkm[16] =  Helpers.makeFP(569416784.91969405599)
    fjkm[17] =  Helpers.makeFP(-61357261.820865861243)
    fjkm[18] =  Helpers.makeFP(-164974352.55837953060)
    fjkm[19] =  Helpers.makeFP(57850732.229668052938)
    j = 3; k = 8; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(1609.3838630717982596)
    fjkm[1] =  Helpers.makeFP(-7751.9961041252827272)
    fjkm[2] =  Helpers.makeFP(-281313.57426896920515)
    fjkm[3] =  Helpers.makeFP(1362914.7891508336068)
    fjkm[4] =  Helpers.makeFP(5966457.1081110733990)
    fjkm[5] =  Helpers.makeFP(-36097318.956064416329)
    fjkm[6] =  Helpers.makeFP(-22309783.293551422257)
    fjkm[7] =  Helpers.makeFP(336158425.14225148967)
    fjkm[8] =  Helpers.makeFP(-205028522.03506721003)
    fjkm[9] =  Helpers.makeFP(-1388339192.4100137759)
    fjkm[10] =  Helpers.makeFP(1836112835.6997822732)
    fjkm[11] =  Helpers.makeFP(2556726458.1368042032)
    fjkm[12] =  Helpers.makeFP(-5652778880.4580993178)
    fjkm[13] =  Helpers.makeFP(-1072688790.0156425156)
    fjkm[14] =  Helpers.makeFP(8223828086.6764744334)
    fjkm[15] =  Helpers.makeFP(-2962125430.6175380614)
    fjkm[16] =  Helpers.makeFP(-5363095697.4586512056)
    fjkm[17] =  Helpers.makeFP(4151384158.2283357977)
    fjkm[18] =  Helpers.makeFP(758617226.29066830002)
    fjkm[19] =  Helpers.makeFP(-1589602926.9007581937)
    fjkm[20] =  Helpers.makeFP(422197436.26031767718)
    j = 4; k = 8; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-3701.5828850651359971)
    fjkm[1] =  Helpers.makeFP(22929.423816498228916)
    fjkm[2] =  Helpers.makeFP(740942.45462626213339)
    fjkm[3] =  Helpers.makeFP(-4683368.4794967535629)
    fjkm[4] =  Helpers.makeFP(-14688082.295896812171)
    fjkm[5] =  Helpers.makeFP(136985890.98054216279)
    fjkm[6] =  Helpers.makeFP(-37063877.251336542111)
    fjkm[7] =  Helpers.makeFP(-1319571104.7402945920)
    fjkm[8] =  Helpers.makeFP(2005453574.1427636671)
    fjkm[9] =  Helpers.makeFP(4917316117.1324589056)
    fjkm[10] =  Helpers.makeFP(-13428166320.891447862)
    fjkm[11] =  Helpers.makeFP(-3828355991.3598264145)
    fjkm[12] =  Helpers.makeFP(37778220592.815991623)
    fjkm[13] =  Helpers.makeFP(-20635506272.066951931)
    fjkm[14] =  Helpers.makeFP(-47082248514.737817855)
    fjkm[15] =  Helpers.makeFP(56649997707.122923550)
    fjkm[16] =  Helpers.makeFP(14169411429.388481941)
    fjkm[17] =  Helpers.makeFP(-52510965464.207838905)
    fjkm[18] =  Helpers.makeFP(18673363121.781645026)
    fjkm[19] =  Helpers.makeFP(14082226269.939926879)
    fjkm[20] =  Helpers.makeFP(-12159500780.523353877)
    fjkm[21] =  Helpers.makeFP(2607014902.9539700770)
    j = 5; k = 8; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(7711.6310105523666607)
    fjkm[1] =  Helpers.makeFP(-58858.321154496479721)
    fjkm[2] =  Helpers.makeFP(-1741907.2159207465870)
    fjkm[3] =  Helpers.makeFP(13794087.929804007718)
    fjkm[4] =  Helpers.makeFP(28916480.065464689455)
    fjkm[5] =  Helpers.makeFP(-437983696.24595980730)
    fjkm[6] =  Helpers.makeFP(494945307.55363422412)
    fjkm[7] =  Helpers.makeFP(4180226129.2961517207)
    fjkm[8] =  Helpers.makeFP(-10954467146.581302332)
    fjkm[9] =  Helpers.makeFP(-11060935369.012122216)
    fjkm[10] =  Helpers.makeFP(67274495072.654389414)
    fjkm[11] =  Helpers.makeFP(-33385597946.547532147)
    fjkm[12] =  Helpers.makeFP(-168738543918.69430001)
    fjkm[13] =  Helpers.makeFP(236353638119.12099768)
    fjkm[14] =  Helpers.makeFP(123426482948.35286349)
    fjkm[15] =  Helpers.makeFP(-460569493399.15116382)
    fjkm[16] =  Helpers.makeFP(183685386812.60549147)
    fjkm[17] =  Helpers.makeFP(323426896220.20397235)
    fjkm[18] =  Helpers.makeFP(-345059927788.03296106)
    fjkm[19] =  Helpers.makeFP(18066712637.598243570)
    fjkm[20] =  Helpers.makeFP(137638821647.93765226)
    fjkm[21] =  Helpers.makeFP(-78528723144.419087956)
    fjkm[22] =  Helpers.makeFP(14147149999.271829167)
    j = 6; k = 8; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    
}

fileprivate func fjkproc16_004<T: SSFloatingPoint>(fjk: inout Array<Array<T>>, un: Array<T>, v: T) {
    var d, j, k: Int
    var fjkm:Array<T> = Array<T>.init(repeating: 0, count: 33)
    fjkm[0] =  Helpers.makeFP(-14872.431234636707131)
    fjkm[1] =  Helpers.makeFP(135739.23591067179473)
    fjkm[2] =  Helpers.makeFP(3743563.4066693378186)
    fjkm[3] =  Helpers.makeFP(-36117123.586437547311)
    fjkm[4] =  Helpers.makeFP(-41857416.064054280688)
    fjkm[5] =  Helpers.makeFP(1225475415.8400151136)
    fjkm[6] =  Helpers.makeFP(-2467842162.9074118554)
    fjkm[7] =  Helpers.makeFP(-10944143126.183310329)
    fjkm[8] =  Helpers.makeFP(45219896350.687109257)
    fjkm[9] =  Helpers.makeFP(3706147531.3941538260)
    fjkm[10] =  Helpers.makeFP(-259638349679.49799671)
    fjkm[11] =  Helpers.makeFP(331511238218.36097150)
    fjkm[12] =  Helpers.makeFP(503674442974.85219625)
    fjkm[13] =  Helpers.makeFP(-1481164218255.8010841)
    fjkm[14] =  Helpers.makeFP(369277357070.34485189)
    fjkm[15] =  Helpers.makeFP(2339646237464.7011180)
    fjkm[16] =  Helpers.makeFP(-2569885298111.3265694)
    fjkm[17] =  Helpers.makeFP(-667794049596.58740652)
    fjkm[18] =  Helpers.makeFP(2906153064933.9250617)
    fjkm[19] =  Helpers.makeFP(-1575977334606.5289263)
    fjkm[20] =  Helpers.makeFP(-578377418663.53101806)
    fjkm[21] =  Helpers.makeFP(1021516684285.5146634)
    fjkm[22] =  Helpers.makeFP(-444821917816.52114438)
    fjkm[23] =  Helpers.makeFP(69214137882.703873029)
    j = 7; k = 8; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(26956.281612779031676)
    fjkm[1] =  Helpers.makeFP(-287752.74431752909550)
    fjkm[2] =  Helpers.makeFP(-7479028.3293311244821)
    fjkm[3] =  Helpers.makeFP(86134990.009811768863)
    fjkm[4] =  Helpers.makeFP(23679004.644932133834)
    fjkm[5] =  Helpers.makeFP(-3077161905.3885988089)
    fjkm[6] =  Helpers.makeFP(9103660424.3905427045)
    fjkm[7] =  Helpers.makeFP(23518972784.280263949)
    fjkm[8] =  Helpers.makeFP(-154703115855.86457830)
    fjkm[9] =  Helpers.makeFP(108277078595.12757644)
    fjkm[10] =  Helpers.makeFP(805587125662.51652400)
    fjkm[11] =  Helpers.makeFP(-1805165807562.2091925)
    fjkm[12] =  Helpers.makeFP(-672890155245.49490410)
    fjkm[13] =  Helpers.makeFP(6669143665397.1378050)
    fjkm[14] =  Helpers.makeFP(-6132703262892.6427237)
    fjkm[15] =  Helpers.makeFP(-7384886877294.0818151)
    fjkm[16] =  Helpers.makeFP(17989877009001.983669)
    fjkm[17] =  Helpers.makeFP(-6680625953666.2171081)
    fjkm[18] =  Helpers.makeFP(-14315112877022.322823)
    fjkm[19] =  Helpers.makeFP(17853687377733.207721)
    fjkm[20] =  Helpers.makeFP(-3800827233430.3173356)
    fjkm[21] =  Helpers.makeFP(-6918410846679.1440993)
    fjkm[22] =  Helpers.makeFP(6365772360949.3812603)
    fjkm[23] =  Helpers.makeFP(-2267586042740.4274751)
    fjkm[24] =  Helpers.makeFP(310920009576.22258316)
    j = 8; k = 8; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(24.380529699556063861)
    fjkm[1] = T.zero
    fjkm[2] =  Helpers.makeFP(-2499.8304818112096241)
    fjkm[3] = T.zero
    fjkm[4] =  Helpers.makeFP(45218.768981362726273)
    fjkm[5] = T.zero
    fjkm[6] =  Helpers.makeFP(-331645.17248456357783)
    fjkm[7] = T.zero
    fjkm[8] =  Helpers.makeFP(1268365.2733216247816)
    fjkm[9] = T.zero
    fjkm[10] =  Helpers.makeFP(-2813563.2265865341107)
    fjkm[11] = T.zero
    fjkm[12] =  Helpers.makeFP(3763271.2976564039964)
    fjkm[13] = T.zero
    fjkm[14] =  Helpers.makeFP(-2998015.9185381067501)
    fjkm[15] = T.zero
    fjkm[16] =  Helpers.makeFP(1311763.6146629772007)
    fjkm[17] = T.zero
    fjkm[18] =  Helpers.makeFP(-242919.18790055133346)
    j = 0; k = 9; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-207.23450244622654282)
    fjkm[1] =  Helpers.makeFP(223.48818891259725206)
    fjkm[2] =  Helpers.makeFP(26248.220059017701053)
    fjkm[3] =  Helpers.makeFP(-27914.773713558507469)
    fjkm[4] =  Helpers.makeFP(-565234.61226703407842)
    fjkm[5] =  Helpers.makeFP(595380.45825460922926)
    fjkm[6] =  Helpers.makeFP(4808855.0010261718786)
    fjkm[7] =  Helpers.makeFP(-5029951.7826825475971)
    fjkm[8] =  Helpers.makeFP(-20928027.009806808897)
    fjkm[9] =  Helpers.makeFP(21773603.858687892085)
    fjkm[10] =  Helpers.makeFP(52050919.691850881048)
    fjkm[11] =  Helpers.makeFP(-53926628.509575237122)
    fjkm[12] =  Helpers.makeFP(-77147061.601956281926)
    fjkm[13] =  Helpers.makeFP(79655909.133727217924)
    fjkm[14] =  Helpers.makeFP(67455358.167107401877)
    fjkm[15] =  Helpers.makeFP(-69454035.446132806377)
    fjkm[16] =  Helpers.makeFP(-32138208.559242941417)
    fjkm[17] =  Helpers.makeFP(33012717.635684926217)
    fjkm[18] =  Helpers.makeFP(6437358.4793646103367)
    fjkm[19] =  Helpers.makeFP(-6599304.6046316445590)
    j = 1; k = 9; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(984.36388661957607837)
    fjkm[1] =  Helpers.makeFP(-2194.2476729600457475)
    fjkm[2] =  Helpers.makeFP(-149715.34984220301505)
    fjkm[3] =  Helpers.makeFP(329977.62359907967038)
    fjkm[4] =  Helpers.makeFP(3636074.9553359345392)
    fjkm[5] =  Helpers.makeFP(-8229815.9546080161817)
    fjkm[6] =  Helpers.makeFP(-32850375.705398849013)
    fjkm[7] =  Helpers.makeFP(79594841.396295258680)
    fjkm[8] =  Helpers.makeFP(140766384.09976010426)
    fjkm[9] =  Helpers.makeFP(-388119773.63641718318)
    fjkm[10] =  Helpers.makeFP(-302391232.58882834949)
    fjkm[11] =  Helpers.makeFP(1069154026.1028829621)
    fjkm[12] =  Helpers.makeFP(267438889.51147761435)
    fjkm[13] =  Helpers.makeFP(-1738631339.5172586463)
    fjkm[14] =  Helpers.makeFP(117013574.77418801057)
    fjkm[15] =  Helpers.makeFP(1654904787.0330349261)
    fjkm[16] =  Helpers.makeFP(-452792004.09905362650)
    fjkm[17] =  Helpers.makeFP(-852646349.53093518044)
    fjkm[18] =  Helpers.makeFP(354479824.94387953335)
    fjkm[19] =  Helpers.makeFP(183646906.05281680809)
    fjkm[20] =  Helpers.makeFP(-95153470.227211795243)
    j = 2; k = 9; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-3445.2736031685162743)
    fjkm[1] =  Helpers.makeFP(11875.044917870854988)
    fjkm[2] =  Helpers.makeFP(615370.50617503436198)
    fjkm[3] =  Helpers.makeFP(-2111012.2880743031723)
    fjkm[4] =  Helpers.makeFP(-16085470.193130487741)
    fjkm[5] =  Helpers.makeFP(60142798.465327082670)
    fjkm[6] =  Helpers.makeFP(138071565.42237886418)
    fjkm[7] =  Helpers.makeFP(-645362876.57211229968)
    fjkm[8] =  Helpers.makeFP(-403042168.77936625406)
    fjkm[9] =  Helpers.makeFP(3392353592.8461412643)
    fjkm[10] =  Helpers.makeFP(-459521271.54126358493)
    fjkm[11] =  Helpers.makeFP(-9731832243.4128846845)
    fjkm[12] =  Helpers.makeFP(5664098916.1399176504)
    fjkm[13] =  Helpers.makeFP(15628587453.068137370)
    fjkm[14] =  Helpers.makeFP(-14586127233.110452133)
    fjkm[15] =  Helpers.makeFP(-13112286301.064475188)
    fjkm[16] =  Helpers.makeFP(18076138583.500999115)
    fjkm[17] =  Helpers.makeFP(3815036344.9012045022)
    fjkm[18] =  Helpers.makeFP(-11188129037.135692765)
    fjkm[19] =  Helpers.makeFP(1563031125.3210441483)
    fjkm[20] =  Helpers.makeFP(2774182673.1720275815)
    fjkm[21] =  Helpers.makeFP(-967769239.01720317824)
    j = 3; k = 9; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(9905.1616091094842886)
    fjkm[1] =  Helpers.makeFP(-46820.775577189124306)
    fjkm[2] =  Helpers.makeFP(-2040487.1579820312439)
    fjkm[3] =  Helpers.makeFP(9691735.5725892393225)
    fjkm[4] =  Helpers.makeFP(54815060.692073363805)
    fjkm[5] =  Helpers.makeFP(-309390686.57090219229)
    fjkm[6] =  Helpers.makeFP(-360017948.08027628199)
    fjkm[7] =  Helpers.makeFP(3579817310.0615042649)
    fjkm[8] =  Helpers.makeFP(-975311608.49901937973)
    fjkm[9] =  Helpers.makeFP(-19324823653.635730322)
    fjkm[10] =  Helpers.makeFP(19615966368.548239543)
    fjkm[11] =  Helpers.makeFP(52313543472.729543241)
    fjkm[12] =  Helpers.makeFP(-87319509031.594965641)
    fjkm[13] =  Helpers.makeFP(-62880701946.001201560)
    fjkm[14] =  Helpers.makeFP(187577712375.82047424)
    fjkm[15] =  Helpers.makeFP(-5014883987.8038807144)
    fjkm[16] =  Helpers.makeFP(-210187382319.75343210)
    fjkm[17] =  Helpers.makeFP(95721572764.807326435)
    fjkm[18] =  Helpers.makeFP(109424352395.85297165)
    fjkm[19] =  Helpers.makeFP(-93578868051.240421500)
    fjkm[20] =  Helpers.makeFP(-10054064393.166929203)
    fjkm[21] =  Helpers.makeFP(29497575770.435656525)
    fjkm[22] =  Helpers.makeFP(-7788016225.4016704591)
    j = 4; k = 9; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-24762.904022773710722)
    fjkm[1] =  Helpers.makeFP(150202.12250011534820)
    fjkm[2] =  Helpers.makeFP(5795836.3854749992775)
    fjkm[3] =  Helpers.makeFP(-35748503.915727151813)
    fjkm[4] =  Helpers.makeFP(-151894819.53780369009)
    fjkm[5] =  Helpers.makeFP(1257834576.5897312294)
    fjkm[6] =  Helpers.makeFP(283767191.88351472079)
    fjkm[7] =  Helpers.makeFP(-15254386392.322461649)
    fjkm[8] =  Helpers.makeFP(17551211231.567450237)
    fjkm[9] =  Helpers.makeFP(79224659176.160664514)
    fjkm[10] =  Helpers.makeFP(-169127446206.19948897)
    fjkm[11] =  Helpers.makeFP(-159965663833.05011647)
    fjkm[12] =  Helpers.makeFP(667618088176.46828695)
    fjkm[13] =  Helpers.makeFP(-96638419442.062469711)
    fjkm[14] =  Helpers.makeFP(-1307530021252.0141810)
    fjkm[15] =  Helpers.makeFP(998989571129.40670193)
    fjkm[16] =  Helpers.makeFP(1171444346499.5230642)
    fjkm[17] =  Helpers.makeFP(-1737201461305.1621935)
    fjkm[18] =  Helpers.makeFP(-114746520425.41058268)
    fjkm[19] =  Helpers.makeFP(1243665816084.6793073)
    fjkm[20] =  Helpers.makeFP(-512525557301.93515073)
    fjkm[21] =  Helpers.makeFP(-261796114655.33666678)
    fjkm[22] =  Helpers.makeFP(247688439610.96543843)
    fjkm[23] =  Helpers.makeFP(-52756420815.901269809)
    j = 5; k = 9; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(55716.534051240849124)
    fjkm[1] =  Helpers.makeFP(-415613.72155461745024)
    fjkm[2] =  Helpers.makeFP(-14629090.289521179515)
    fjkm[3] =  Helpers.makeFP(112517365.15692088569)
    fjkm[4] =  Helpers.makeFP(349569807.61470724572)
    fjkm[5] =  Helpers.makeFP(-4300749690.4008170962)
    fjkm[6] =  Helpers.makeFP(2780201489.2284702260)
    fjkm[7] =  Helpers.makeFP(53008111096.391616511)
    fjkm[8] =  Helpers.makeFP(-112833892526.88952297)
    fjkm[9] =  Helpers.makeFP(-236800084652.33408957)
    fjkm[10] =  Helpers.makeFP(948058960807.18952080)
    fjkm[11] =  Helpers.makeFP(15893204800.580178374)
    fjkm[12] =  Helpers.makeFP(-3467524908336.7843972)
    fjkm[13] =  Helpers.makeFP(3164309467171.3659456)
    fjkm[14] =  Helpers.makeFP(5582435675279.1817146)
    fjkm[15] =  Helpers.makeFP(-10541249137249.730392)
    fjkm[16] =  Helpers.makeFP(-1168774181536.2029753)
    fjkm[17] =  Helpers.makeFP(14413943369875.125772)
    fjkm[18] =  Helpers.makeFP(-7960463497916.1060492)
    fjkm[19] =  Helpers.makeFP(-7323822211977.2888688)
    fjkm[20] =  Helpers.makeFP(9405979314966.6882022)
    fjkm[21] =  Helpers.makeFP(-1275663773372.9196006)
    fjkm[22] =  Helpers.makeFP(-2930439830152.3544240)
    fjkm[23] =  Helpers.makeFP(1747630840980.1348510)
    fjkm[24] =  Helpers.makeFP(-312613977240.16973767)
    j = 6; k = 9; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-115412.82053471318747)
    fjkm[1] =  Helpers.makeFP(1027788.8260207103833)
    fjkm[2] =  Helpers.makeFP(33623754.973679064933)
    fjkm[3] =  Helpers.makeFP(-313584768.22511895708)
    fjkm[4] =  Helpers.makeFP(-659891574.79280520771)
    fjkm[5] =  Helpers.makeFP(12850764070.127691360)
    fjkm[6] =  Helpers.makeFP(-19440345035.583477731)
    fjkm[7] =  Helpers.makeFP(-155138555406.99154257)
    fjkm[8] =  Helpers.makeFP(516911193990.92260102)
    fjkm[9] =  Helpers.makeFP(451041007491.51124256)
    fjkm[10] =  Helpers.makeFP(-4074544650661.9635765)
    fjkm[11] =  Helpers.makeFP(3101195098601.7687528)
    fjkm[12] =  Helpers.makeFP(13186035652463.635190)
    fjkm[13] =  Helpers.makeFP(-24971415775329.260965)
    fjkm[14] =  Helpers.makeFP(-10847664957177.134063)
    fjkm[15] =  Helpers.makeFP(66205224018265.472705)
    fjkm[16] =  Helpers.makeFP(-37500185472771.584184)
    fjkm[17] =  Helpers.makeFP(-69777795804669.385671)
    fjkm[18] =  Helpers.makeFP(99311193873506.569397)
    fjkm[19] =  Helpers.makeFP(-492168373279.20159968)
    fjkm[20] =  Helpers.makeFP(-80134019127845.984412)
    fjkm[21] =  Helpers.makeFP(51160427044311.739411)
    fjkm[22] =  Helpers.makeFP(9045641917569.2467301)
    fjkm[23] =  Helpers.makeFP(-24123027505367.165512)
    fjkm[24] =  Helpers.makeFP(10768904399045.846700)
    fjkm[25] =  Helpers.makeFP(-1663085461560.5466581)
    j = 7; k = 9; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(110.01714026924673817)
    fjkm[1] = T.zero
    fjkm[2] =  Helpers.makeFP(-13886.089753717040532)
    fjkm[3] = T.zero
    fjkm[4] =  Helpers.makeFP(308186.40461266239848)
    fjkm[5] = T.zero
    fjkm[6] =  Helpers.makeFP(-2785618.1280864546890)
    fjkm[7] = T.zero
    fjkm[8] =  Helpers.makeFP(13288767.166421818329)
    fjkm[9] = T.zero
    fjkm[10] =  Helpers.makeFP(-37567176.660763351308)
    fjkm[11] = T.zero
    fjkm[12] =  Helpers.makeFP(66344512.274729026665)
    fjkm[13] = T.zero
    fjkm[14] =  Helpers.makeFP(-74105148.211532657748)
    fjkm[15] = T.zero
    fjkm[16] =  Helpers.makeFP(50952602.492664642206)
    fjkm[17] = T.zero
    fjkm[18] =  Helpers.makeFP(-19706819.118432226927)
    fjkm[19] = T.zero
    fjkm[20] =  Helpers.makeFP(3284469.8530720378211)
    j = 0; k = 0; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-1045.1628325578440126)
    fjkm[1] =  Helpers.makeFP(1118.5075927373418381)
    fjkm[2] =  Helpers.makeFP(159690.03216774596612)
    fjkm[3] =  Helpers.makeFP(-168947.42533689065981)
    fjkm[4] =  Helpers.makeFP(-4160516.4622709423795)
    fjkm[5] =  Helpers.makeFP(4365974.0653460506451)
    fjkm[6] =  Helpers.makeFP(43177080.985340047679)
    fjkm[7] =  Helpers.makeFP(-45034159.737397684138)
    fjkm[8] =  Helpers.makeFP(-232553425.41238182077)
    fjkm[9] =  Helpers.makeFP(241412603.52332969965)
    fjkm[10] =  Helpers.makeFP(732559944.88488535051)
    fjkm[11] =  Helpers.makeFP(-757604729.32539425138)
    fjkm[12] =  Helpers.makeFP(-1426407013.9066740733)
    fjkm[13] =  Helpers.makeFP(1470636688.7564934244)
    fjkm[14] =  Helpers.makeFP(1741470982.9710174571)
    fjkm[15] =  Helpers.makeFP(-1790874415.1120392289)
    fjkm[16] =  Helpers.makeFP(-1299291363.5629483763)
    fjkm[17] =  Helpers.makeFP(1333259765.2247248044)
    fjkm[18] =  Helpers.makeFP(541937525.75688624049)
    fjkm[19] =  Helpers.makeFP(-555075405.16917439177)
    fjkm[20] =  Helpers.makeFP(-96891860.665625115724)
    fjkm[21] =  Helpers.makeFP(99081507.234339807604)
    j = 1; k = 0; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(5487.1048709286810663)
    fjkm[1] =  Helpers.makeFP(-12101.885429617141199)
    fjkm[2] =  Helpers.makeFP(-991438.75239470139087)
    fjkm[3] =  Helpers.makeFP(2166230.0015798583230)
    fjkm[4] =  Helpers.makeFP(28994419.876786743130)
    fjkm[5] =  Helpers.makeFP(-64719144.968659103681)
    fjkm[6] =  Helpers.makeFP(-321629835.31147623339)
    fjkm[7] =  Helpers.makeFP(757688130.83951567540)
    fjkm[8] =  Helpers.makeFP(1749409837.5100643555)
    fjkm[9] =  Helpers.makeFP(-4544758370.9162618687)
    fjkm[10] =  Helpers.makeFP(-5113992851.9544763313)
    fjkm[11] =  Helpers.makeFP(15778214197.520607549)
    fjkm[12] =  Helpers.makeFP(7774473545.9444870052)
    fjkm[13] =  Helpers.makeFP(-33570323211.012887492)
    fjkm[14] =  Helpers.makeFP(-3804246527.4759322626)
    fjkm[15] =  Helpers.makeFP(44463088926.919594649)
    fjkm[16] =  Helpers.makeFP(-5920634247.3331925357)
    fjkm[17] =  Helpers.makeFP(-35768726949.850578829)
    fjkm[18] =  Helpers.makeFP(10834752690.813605970)
    fjkm[19] =  Helpers.makeFP(16001937124.166968265)
    fjkm[20] =  Helpers.makeFP(-6803368741.9070923418)
    fjkm[21] =  Helpers.makeFP(-3054556963.3569951737)
    fjkm[22] =  Helpers.makeFP(1577229794.0273014954)
    j = 2; k = 0; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-21033.902005226610754)
    fjkm[1] =  Helpers.makeFP(71551.022388357981754)
    fjkm[2] =  Helpers.makeFP(4410889.4214898588524)
    fjkm[3] =  Helpers.makeFP(-14945521.653227529678)
    fjkm[4] =  Helpers.makeFP(-139310283.22771754330)
    fjkm[5] =  Helpers.makeFP(506112018.78208167499)
    fjkm[6] =  Helpers.makeFP(1519598088.8133635683)
    fjkm[7] =  Helpers.makeFP(-6552067582.0564506220)
    fjkm[8] =  Helpers.makeFP(-6692370095.4282068536)
    fjkm[9] =  Helpers.makeFP(42444451633.414257582)
    fjkm[10] =  Helpers.makeFP(5560288488.7766793217)
    fjkm[11] =  Helpers.makeFP(-155035909620.11651130)
    fjkm[12] =  Helpers.makeFP(57543525805.054081844)
    fjkm[13] =  Helpers.makeFP(335136386281.40047184)
    fjkm[14] =  Helpers.makeFP(-242028870673.91835183)
    fjkm[15] =  Helpers.makeFP(-425158049601.57076545)
    fjkm[16] =  Helpers.makeFP(447281929473.23048294)
    fjkm[17] =  Helpers.makeFP(285539009675.26705395)
    fjkm[18] =  Helpers.makeFP(-446532174700.75534828)
    fjkm[19] =  Helpers.makeFP(-56114815650.416797381)
    fjkm[20] =  Helpers.makeFP(234199738711.39910784)
    fjkm[21] =  Helpers.makeFP(-38367666879.807869654)
    fjkm[22] =  Helpers.makeFP(-50717346515.577689017)
    fjkm[23] =  Helpers.makeFP(17618025541.849480837)
    j = 3; k = 0; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(65730.943766333158607)
    fjkm[1] =  Helpers.makeFP(-305976.00327882005331)
    fjkm[2] =  Helpers.makeFP(-15752484.913133094466)
    fjkm[3] =  Helpers.makeFP(73626048.766219891723)
    fjkm[4] =  Helpers.makeFP(517727813.38636845015)
    fjkm[5] =  Helpers.makeFP(-2779778621.0311819654)
    fjkm[6] =  Helpers.makeFP(-4848484539.3006943808)
    fjkm[7] =  Helpers.makeFP(38867748248.486701209)
    fjkm[8] =  Helpers.makeFP(2816113040.3833130041)
    fjkm[9] =  Helpers.makeFP(-261989764937.19714608)
    fjkm[10] =  Helpers.makeFP(193832179511.35043238)
    fjkm[11] =  Helpers.makeFP(941830771354.52418439)
    fjkm[12] =  Helpers.makeFP(-1252062600825.4805385)
    fjkm[13] =  Helpers.makeFP(-1788586580037.9230755)
    fjkm[14] =  Helpers.makeFP(3715406759129.6400037)
    fjkm[15] =  Helpers.makeFP(1338049108553.0784173)
    fjkm[16] =  Helpers.makeFP(-6078517409833.2670243)
    fjkm[17] =  Helpers.makeFP(1046877894952.0462047)
    fjkm[18] =  Helpers.makeFP(5489626110236.1661278)
    fjkm[19] =  Helpers.makeFP(-2928719118680.3861544)
    fjkm[20] =  Helpers.makeFP(-2340856193318.6421567)
    fjkm[21] =  Helpers.makeFP(2206204676067.3123808)
    fjkm[22] =  Helpers.makeFP(119173943641.45927347)
    fjkm[23] =  Helpers.makeFP(-589883942966.21075926)
    fjkm[24] =  Helpers.makeFP(154983207892.81174977)
    j = 4; k = 0; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
}

fileprivate func fjkproc16_005<T: SSFloatingPoint>(fjk: inout Array<Array<T>>, un: Array<T>, v: T) {
    var d, j, k: Int
    var fjkm:Array<T> = Array<T>.init(repeating: 0, count: 33)
    fjkm[0] =  Helpers.makeFP(-177473.54816909952824)
    fjkm[1] =  Helpers.makeFP(1058104.4704696212045)
    fjkm[2] =  Helpers.makeFP(47977824.897952560186)
    fjkm[3] =  Helpers.makeFP(-290115715.66147843083)
    fjkm[4] =  Helpers.makeFP(-1577194622.2444813090)
    fjkm[5] =  Helpers.makeFP(12040320836.774941282)
    fjkm[6] =  Helpers.makeFP(8938496432.7761692719)
    fjkm[7] =  Helpers.makeFP(-177729149538.54760085)
    fjkm[8] =  Helpers.makeFP(142764258530.36399735)
    fjkm[9] =  Helpers.makeFP(1190892990607.9998843)
    fjkm[10] =  Helpers.makeFP(-2059313111949.9121859)
    fjkm[11] =  Helpers.makeFP(-3727699663610.1911429)
    fjkm[12] =  Helpers.makeFP(10889256225145.522967)
    fjkm[13] =  Helpers.makeFP(3246312869985.9515053)
    fjkm[14] =  Helpers.makeFP(-29702334678008.056483)
    fjkm[15] =  Helpers.makeFP(12354361209407.777556)
    fjkm[16] =  Helpers.makeFP(43335047349400.917011)
    fjkm[17] =  Helpers.makeFP(-41504037524268.002306)
    fjkm[18] =  Helpers.makeFP(-28336804589555.309295)
    fjkm[19] =  Helpers.makeFP(52945932725332.519399)
    fjkm[20] =  Helpers.makeFP(-2984104941157.1313565)
    fjkm[21] =  Helpers.makeFP(-30618403352283.411013)
    fjkm[22] =  Helpers.makeFP(14099792752244.009722)
    fjkm[23] =  Helpers.makeFP(5138575314225.4923364)
    fjkm[24] =  Helpers.makeFP(-5394419195595.0379138)
    fjkm[25] =  Helpers.makeFP(1142750145697.5795143)
    j = 5; k = 0; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(428894.40807532385991)
    fjkm[1] =  Helpers.makeFP(-3139491.0587579525708)
    fjkm[2] =  Helpers.makeFP(-129346362.91769878378)
    fjkm[3] =  Helpers.makeFP(971658116.23636815026)
    fjkm[4] =  Helpers.makeFP(4056885717.6650654269)
    fjkm[5] =  Helpers.makeFP(-43776518263.068506188)
    fjkm[6] =  Helpers.makeFP(6886509445.7336568338)
    fjkm[7] =  Helpers.makeFP(666192636622.63242699)
    fjkm[8] =  Helpers.makeFP(-1146605162893.2335873)
    fjkm[9] =  Helpers.makeFP(-4150515189210.3819757)
    fjkm[10] =  Helpers.makeFP(12899393468582.902633)
    fjkm[11] =  Helpers.makeFP(7742402532790.6606612)
    fjkm[12] =  Helpers.makeFP(-63390570866544.420475)
    fjkm[13] =  Helpers.makeFP(31574846906545.697293)
    fjkm[14] =  Helpers.makeFP(155509830706127.21122)
    fjkm[15] =  Helpers.makeFP(-197328514020298.70121)
    fjkm[16] =  Helpers.makeFP(-161495194791368.91656)
    fjkm[17] =  Helpers.makeFP(431593958485279.11169)
    fjkm[18] =  Helpers.makeFP(-57955664355845.420187)
    fjkm[19] =  Helpers.makeFP(-444813800230214.83356)
    fjkm[20] =  Helpers.makeFP(304547176185415.82363)
    fjkm[21] =  Helpers.makeFP(164529366533754.02760)
    fjkm[22] =  Helpers.makeFP(-262168848376474.26253)
    fjkm[23] =  Helpers.makeFP(51430539333046.601717)
    fjkm[24] =  Helpers.makeFP(65933562346693.241986)
    fjkm[25] =  Helpers.makeFP(-41287526582645.050139)
    fjkm[26] =  Helpers.makeFP(7341963962580.3111652)
    j = 6; k = 0; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(551.33589612202058561)
    fjkm[1] = T.zero
    fjkm[2] =  Helpers.makeFP(-84005.433603024085289)
    fjkm[3] = T.zero
    fjkm[4] =  Helpers.makeFP(2243768.1779224494292)
    fjkm[5] = T.zero
    fjkm[6] =  Helpers.makeFP(-24474062.725738728468)
    fjkm[7] = T.zero
    fjkm[8] =  Helpers.makeFP(142062907.79753309519)
    fjkm[9] = T.zero
    fjkm[10] =  Helpers.makeFP(-495889784.27503030925)
    fjkm[11] = T.zero
    fjkm[12] =  Helpers.makeFP(1106842816.8230144683)
    fjkm[13] = T.zero
    fjkm[14] =  Helpers.makeFP(-1621080552.1083370752)
    fjkm[15] = T.zero
    fjkm[16] =  Helpers.makeFP(1553596899.5705800562)
    fjkm[17] = T.zero
    fjkm[18] =  Helpers.makeFP(-939462359.68157840255)
    fjkm[19] = T.zero
    fjkm[20] =  Helpers.makeFP(325573074.18576574902)
    fjkm[21] = T.zero
    fjkm[22] =  Helpers.makeFP(-49329253.664509961973)
    j = 0; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-5789.0269092812161489)
    fjkm[1] =  Helpers.makeFP(6156.5841733625632060)
    fjkm[2] =  Helpers.makeFP(1050067.9200378010661)
    fjkm[3] =  Helpers.makeFP(-1106071.5424398171230)
    fjkm[4] =  Helpers.makeFP(-32534638.579875516724)
    fjkm[5] =  Helpers.makeFP(34030484.031823816343)
    fjkm[6] =  Helpers.makeFP(403822034.97468901972)
    fjkm[7] =  Helpers.makeFP(-420138076.79184817203)
    fjkm[8] =  Helpers.makeFP(-2628163794.2543622609)
    fjkm[9] =  Helpers.makeFP(2722872399.4527176577)
    fjkm[10] =  Helpers.makeFP(10165740577.638121340)
    fjkm[11] =  Helpers.makeFP(-10496333767.154808213)
    fjkm[12] =  Helpers.makeFP(-24903963378.517825536)
    fjkm[13] =  Helpers.makeFP(25641858589.733168515)
    fjkm[14] =  Helpers.makeFP(39716473526.654258344)
    fjkm[15] =  Helpers.makeFP(-40797193894.726483060)
    fjkm[16] =  Helpers.makeFP(-41170317838.620371488)
    fjkm[17] =  Helpers.makeFP(42206049105.000758192)
    fjkm[18] =  Helpers.makeFP(26774677250.924984473)
    fjkm[19] =  Helpers.makeFP(-27400985490.712703408)
    fjkm[20] =  Helpers.makeFP(-9929978762.6658553451)
    fjkm[21] =  Helpers.makeFP(10147027478.789699178)
    fjkm[22] =  Helpers.makeFP(1603200744.0965737641)
    fjkm[23] =  Helpers.makeFP(-1636086913.2062470721)
    j = 1; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(33286.904728366992856)
    fjkm[1] =  Helpers.makeFP(-72776.338288106717300)
    fjkm[2] =  Helpers.makeFP(-7048423.0820374073034)
    fjkm[3] =  Helpers.makeFP(15288988.915750383523)
    fjkm[4] =  Helpers.makeFP(243935418.08573977628)
    fjkm[5] =  Helpers.makeFP(-538504362.70138786302)
    fjkm[6] =  Helpers.makeFP(-3246894911.6396827767)
    fjkm[7] =  Helpers.makeFP(7489063194.0760509112)
    fjkm[8] =  Helpers.makeFP(21666937100.705365161)
    fjkm[9] =  Helpers.makeFP(-53983904963.062576171)
    fjkm[10] =  Helpers.makeFP(-80910564664.877465851)
    fjkm[11] =  Helpers.makeFP(229101080335.06400288)
    fjkm[12] =  Helpers.makeFP(172760876423.44066571)
    fjkm[13] =  Helpers.makeFP(-610977234886.30398648)
    fjkm[14] =  Helpers.makeFP(-187937135374.72033958)
    fjkm[15] =  Helpers.makeFP(1053702358870.4190989)
    fjkm[16] =  Helpers.makeFP(18639458829.443774842)
    fjkm[17] =  Helpers.makeFP(-1174519256075.3585225)
    fjkm[18] =  Helpers.makeFP(213630362751.48244186)
    fjkm[19] =  Helpers.makeFP(817332252922.97321022)
    fjkm[20] =  Helpers.makeFP(-266086886489.81593243)
    fjkm[21] =  Helpers.makeFP(-322968489592.27962303)
    fjkm[22] =  Helpers.makeFP(139744842706.19027127)
    fjkm[23] =  Helpers.makeFP(55347422611.580177333)
    fjkm[24] =  Helpers.makeFP(-28497920919.101275948)
    j = 2; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-138695.43636819580357)
    fjkm[1] =  Helpers.makeFP(466698.94436858890046)
    fjkm[2] =  Helpers.makeFP(33739004.101605793511)
    fjkm[3] =  Helpers.makeFP(-113151831.10727233791)
    fjkm[4] =  Helpers.makeFP(-1262494179.8855194512)
    fjkm[5] =  Helpers.makeFP(4485679097.1221702841)
    fjkm[6] =  Helpers.makeFP(16876412838.414698204)
    fjkm[7] =  Helpers.makeFP(-68734331237.685231727)
    fjkm[8] =  Helpers.makeFP(-99319007190.867271605)
    fjkm[9] =  Helpers.makeFP(535143925100.64569760)
    fjkm[10] =  Helpers.makeFP(219559829042.68087919)
    fjkm[11] =  Helpers.makeFP(-2402169771537.2297740)
    fjkm[12] =  Helpers.makeFP(385225420494.61274582)
    fjkm[13] =  Helpers.makeFP(6605716163805.3629860)
    fjkm[14] =  Helpers.makeFP(-3536807746028.4626688)
    fjkm[15] =  Helpers.makeFP(-11320974870399.200872)
    fjkm[16] =  Helpers.makeFP(9487604757721.1762395)
    fjkm[17] =  Helpers.makeFP(11727696199159.893852)
    fjkm[18] =  Helpers.makeFP(-13727281916428.067929)
    fjkm[19] =  Helpers.makeFP(-6409955842808.2983124)
    fjkm[20] =  Helpers.makeFP(11468445778721.253331)
    fjkm[21] =  Helpers.makeFP(723160235150.79794197)
    fjkm[22] =  Helpers.makeFP(-5214971540434.5399686)
    fjkm[23] =  Helpers.makeFP(952560905703.62661138)
    fjkm[24] =  Helpers.makeFP(1001898723474.6755508)
    fjkm[25] =  Helpers.makeFP(-346817425242.52751961)
    j = 3; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
}

fileprivate func fjkproc16_006<T: SSFloatingPoint>(fjk: inout Array<Array<T>>, un: Array<T>, v: T) {
    var d, j, k: Int
    var fjkm:Array<T> = Array<T>.init(repeating: 0, count: 33)
    fjkm[0] =  Helpers.makeFP(468097.09774266083704)
    fjkm[1] =  Helpers.makeFP(-2151404.5559841446618)
    fjkm[2] =  Helpers.makeFP(-129076990.59865050915)
    fjkm[3] =  Helpers.makeFP(595316208.51428773472)
    fjkm[4] =  Helpers.makeFP(5064273602.5906671292)
    fjkm[5] =  Helpers.makeFP(-26185510869.073114681)
    fjkm[6] =  Helpers.makeFP(-61837037264.905576505)
    fjkm[7] =  Helpers.makeFP(433386998010.23271090)
    fjkm[8] =  Helpers.makeFP(186443883288.37312122)
    fjkm[9] =  Helpers.makeFP(-3537220973754.0018335)
    fjkm[10] =  Helpers.makeFP(1681730347233.8501195)
    fjkm[11] =  Helpers.makeFP(15988837394678.875714)
    fjkm[12] =  Helpers.makeFP(-16993822946683.547492)
    fjkm[13] =  Helpers.makeFP(-41340811227869.288548)
    fjkm[14] =  Helpers.makeFP(67591520066179.679649)
    fjkm[15] =  Helpers.makeFP(56621717984129.588648)
    fjkm[16] =  Helpers.makeFP(-149792388677379.47570)
    fjkm[17] =  Helpers.makeFP(-20183328379251.847125)
    fjkm[18] =  Helpers.makeFP(196651762467137.74506)
    fjkm[19] =  Helpers.makeFP(-54964390301576.370525)
    fjkm[20] =  Helpers.makeFP(-147653284026647.88789)
    fjkm[21] =  Helpers.makeFP(88925712863728.440410)
    fjkm[22] =  Helpers.makeFP(52472318964377.745533)
    fjkm[23] =  Helpers.makeFP(-54571161032830.893735)
    fjkm[24] =  Helpers.makeFP(-776744894101.81078918)
    fjkm[25] =  Helpers.makeFP(12653076888080.966521)
    fjkm[26] =  Helpers.makeFP(-3310861678129.4432166)
    j = 4; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-1357481.5834537164274)
    fjkm[1] =  Helpers.makeFP(7977851.1535147665703)
    fjkm[2] =  Helpers.makeFP(419517728.92817665197)
    fjkm[3] =  Helpers.makeFP(-2495517054.7161424403)
    fjkm[4] =  Helpers.makeFP(-16720780562.050493234)
    fjkm[5] =  Helpers.makeFP(120296564778.19436333)
    fjkm[6] =  Helpers.makeFP(154404724838.89607546)
    fjkm[7] =  Helpers.makeFP(-2110123804399.9206379)
    fjkm[8] =  Helpers.makeFP(974123695127.88869692)
    fjkm[9] =  Helpers.makeFP(17443881430511.946630)
    fjkm[10] =  Helpers.makeFP(-24448434409173.656268)
    fjkm[11] =  Helpers.makeFP(-73513952038406.365892)
    fjkm[12] =  Helpers.makeFP(169708094306922.00526)
    fjkm[13] =  Helpers.makeFP(139392884698962.95542)
    fjkm[14] =  Helpers.makeFP(-607701552209729.47437)
    fjkm[15] =  Helpers.makeFP(42904363912061.406899)
    fjkm[16] =  Helpers.makeFP(1241046770899817.3524)
    fjkm[17] =  Helpers.makeFP(-768125556097572.10187)
    fjkm[18] =  Helpers.makeFP(-1403171934960438.0242)
    fjkm[19] =  Helpers.makeFP(1622188475923667.7103)
    fjkm[20] =  Helpers.makeFP(657623934547413.88722)
    fjkm[21] =  Helpers.makeFP(-1631882122398223.2875)
    fjkm[22] =  Helpers.makeFP(237083343503533.13124)
    fjkm[23] =  Helpers.makeFP(785835171244720.50574)
    fjkm[24] =  Helpers.makeFP(-396417689594574.31797)
    fjkm[25] =  Helpers.makeFP(-105868095076065.58561)
    fjkm[26] =  Helpers.makeFP(125179414423474.77661)
    fjkm[27] =  Helpers.makeFP(-26396909127729.654202)
    j = 5; k = 1; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(3038.0905109223842686)
    fjkm[1] = T.zero
    fjkm[2] =  Helpers.makeFP(-549842.32757228868713)
    fjkm[3] = T.zero
    fjkm[4] =  Helpers.makeFP(17395107.553978164538)
    fjkm[5] = T.zero
    fjkm[6] =  Helpers.makeFP(-225105661.88941527780)
    fjkm[7] = T.zero
    fjkm[8] =  Helpers.makeFP(1559279864.8792575133)
    fjkm[9] = T.zero
    fjkm[10] =  Helpers.makeFP(-6563293792.6192843320)
    fjkm[11] = T.zero
    fjkm[12] =  Helpers.makeFP(17954213731.155600080)
    fjkm[13] = T.zero
    fjkm[14] =  Helpers.makeFP(-33026599749.800723140)
    fjkm[15] = T.zero
    fjkm[16] =  Helpers.makeFP(41280185579.753973955)
    fjkm[17] = T.zero
    fjkm[18] =  Helpers.makeFP(-34632043388.158777923)
    fjkm[19] = T.zero
    fjkm[20] =  Helpers.makeFP(18688207509.295824922)
    fjkm[21] = T.zero
    fjkm[22] =  Helpers.makeFP(-5866481492.0518472276)
    fjkm[23] = T.zero
    fjkm[24] =  Helpers.makeFP(814789096.11831211495)
    j = 0; k = 2; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-34938.040875607419089)
    fjkm[1] =  Helpers.makeFP(36963.434549555675268)
    fjkm[2] =  Helpers.makeFP(7422871.4222258972763)
    fjkm[3] =  Helpers.makeFP(-7789432.9739407564011)
    fjkm[4] =  Helpers.makeFP(-269624167.08666155034)
    fjkm[5] =  Helpers.makeFP(281220905.45598032670)
    fjkm[6] =  Helpers.makeFP(3939349083.0647673616)
    fjkm[7] =  Helpers.makeFP(-4089419524.3243775468)
    fjkm[8] =  Helpers.makeFP(-30405957365.145521510)
    fjkm[9] =  Helpers.makeFP(31445477275.065026519)
    fjkm[10] =  Helpers.makeFP(141110816541.31461314)
    fjkm[11] =  Helpers.makeFP(-145486345736.39413603)
    fjkm[12] =  Helpers.makeFP(-421924022682.15660188)
    fjkm[13] =  Helpers.makeFP(433893498502.92700194)
    fjkm[14] =  Helpers.makeFP(842178293619.91844007)
    fjkm[15] =  Helpers.makeFP(-864196026786.45225550)
    fjkm[16] =  Helpers.makeFP(-1135205103443.2342838)
    fjkm[17] =  Helpers.makeFP(1162725227163.0702664)
    fjkm[18] =  Helpers.makeFP(1021645279950.6839487)
    fjkm[19] =  Helpers.makeFP(-1044733308876.1231340)
    fjkm[20] =  Helpers.makeFP(-588678536542.81848505)
    fjkm[21] =  Helpers.makeFP(601137341549.01570167)
    fjkm[22] =  Helpers.makeFP(196527129983.73688212)
    fjkm[23] =  Helpers.makeFP(-200438117645.10478028)
    fjkm[24] =  Helpers.makeFP(-28925012912.200080081)
    fjkm[25] =  Helpers.makeFP(29468205642.945621491)
    j = 1; k = 2; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(218362.75547254636931)
    fjkm[1] =  Helpers.makeFP(-473942.11970389194590)
    fjkm[2] =  Helpers.makeFP(-53559985.272697166145)
    fjkm[3] =  Helpers.makeFP(115466888.79018062430)
    fjkm[4] =  Helpers.makeFP(2162702487.2919505639)
    fjkm[5] =  Helpers.makeFP(-4731469254.6820607544)
    fjkm[6] =  Helpers.makeFP(-33930459549.835830283)
    fjkm[7] =  Helpers.makeFP(76986136366.180025009)
    fjkm[8] =  Helpers.makeFP(271095146839.75321729)
    fjkm[9] =  Helpers.makeFP(-654897543249.28815561)
    fjkm[10] =  Helpers.makeFP(-1244130265844.5028996)
    fjkm[11] =  Helpers.makeFP(3321026659065.3578720)
    fjkm[12] =  Helpers.makeFP(3434492363731.4649585)
    fjkm[13] =  Helpers.makeFP(-10772528238693.360048)
    fjkm[14] =  Helpers.makeFP(-5553407245149.3813559)
    fjkm[15] =  Helpers.makeFP(23184673024360.107644)
    fjkm[16] =  Helpers.makeFP(4148109873524.0835034)
    fjkm[17] =  Helpers.makeFP(-33519510690760.226852)
    fjkm[18] =  Helpers.makeFP(1766187462911.1875877)
    fjkm[19] =  Helpers.makeFP(32207800350987.663468)
    fjkm[20] =  Helpers.makeFP(-7064569616534.6127663)
    fjkm[21] =  Helpers.makeFP(-19734747129816.391118)
    fjkm[22] =  Helpers.makeFP(6780185269401.9041713)
    fjkm[23] =  Helpers.makeFP(6981112975541.6982009)
    fjkm[24] =  Helpers.makeFP(-3063627371132.2565100)
    fjkm[25] =  Helpers.makeFP(-1085299076029.5917371)
    fjkm[26] =  Helpers.makeFP(557485489473.28346831)
    j = 2; k = 2; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-982632.39962645866188)
    fjkm[1] =  Helpers.makeFP(3276416.0527937831379)
    fjkm[2] =  Helpers.makeFP(274430595.86767397376)
    fjkm[3] =  Helpers.makeFP(-912438377.61048048104)
    fjkm[4] =  Helpers.makeFP(-11979589299.502912885)
    fjkm[5] =  Helpers.makeFP(41816043571.570359444)
    fjkm[6] =  Helpers.makeFP(191330729548.58232223)
    fjkm[7] =  Helpers.makeFP(-746943185635.96708583)
    fjkm[8] =  Helpers.makeFP(-1416198224023.6464721)
    fjkm[9] =  Helpers.makeFP(6856956393274.5884258)
    fjkm[10] =  Helpers.makeFP(4829515891796.9969935)
    fjkm[11] =  Helpers.makeFP(-36877687475484.603376)
    fjkm[12] =  Helpers.makeFP(-2050957082915.0942624)
    fjkm[13] =  Helpers.makeFP(124378250253033.78820)
    fjkm[14] =  Helpers.makeFP(-44312193894090.533579)
    fjkm[15] =  Helpers.makeFP(-271207689501172.62955)
    fjkm[16] =  Helpers.makeFP(179586202876957.77361)
    fjkm[17] =  Helpers.makeFP(381618869449173.21877)
    fjkm[18] =  Helpers.makeFP(-359490061117882.96881)
    fjkm[19] =  Helpers.makeFP(-330393612742248.46582)
    fjkm[20] =  Helpers.makeFP(427952236370799.92495)
    fjkm[21] =  Helpers.makeFP(148052565489017.04595)
    fjkm[22] =  Helpers.makeFP(-307266140839707.15754)
    fjkm[23] =  Helpers.makeFP(-4687264091266.0864760)
    fjkm[24] =  Helpers.makeFP(123260326898726.61625)
    fjkm[25] =  Helpers.makeFP(-24376238900981.871642)
    fjkm[26] =  Helpers.makeFP(-21272360948501.370513)
    fjkm[27] =  Helpers.makeFP(7341892911307.8818418)
    j = 3; k = 2; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(3562042.4486459126493)
    fjkm[1] =  Helpers.makeFP(-16196313.687936474068)
    fjkm[2] =  Helpers.makeFP(-1119546446.8249808309)
    fjkm[3] =  Helpers.makeFP(5105896697.6570577310)
    fjkm[4] =  Helpers.makeFP(51476060928.630380287)
    fjkm[5] =  Helpers.makeFP(-258447407741.23544355)
    fjkm[6] =  Helpers.makeFP(-779649080899.64056288)
    fjkm[7] =  Helpers.makeFP(4982179421789.6942804)
    fjkm[8] =  Helpers.makeFP(4004696303571.8542110)
    fjkm[9] =  Helpers.makeFP(-48152095258426.146318)
    fjkm[10] =  Helpers.makeFP(10206156605278.263985)
    fjkm[11] =  Helpers.makeFP(264344253278752.35082)
    fjkm[12] =  Helpers.makeFP(-218798857956960.84499)
    fjkm[13] =  Helpers.makeFP(-868622560677829.56823)
    fjkm[14] =  Helpers.makeFP(1161601525559524.2658)
    fjkm[15] =  Helpers.makeFP(1687979001191903.2190)
    fjkm[16] =  Helpers.makeFP(-3349241418127553.8805)
    fjkm[17] =  Helpers.makeFP(-1649878672532120.5740)
    fjkm[18] =  Helpers.makeFP(5897451215285124.6365)
    fjkm[19] =  Helpers.makeFP(-125952827188585.92633)
    fjkm[20] =  Helpers.makeFP(-6433283969334751.7469)
    fjkm[21] =  Helpers.makeFP(2343935079955608.5977)
    fjkm[22] =  Helpers.makeFP(4106725553395393.7642)
    fjkm[23] =  Helpers.makeFP(-2735980005540132.5807)
    fjkm[24] =  Helpers.makeFP(-1230142327980830.8915)
    fjkm[25] =  Helpers.makeFP(1417490532431040.0017)
    fjkm[26] =  Helpers.makeFP(-23384761374805.900562)
    fjkm[27] =  Helpers.makeFP(-289892454526107.40352)
    fjkm[28] =  Helpers.makeFP(75592403781851.468191)
    j = 4; k = 2; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(18257.755474293174691)
    fjkm[1] = T.zero
    fjkm[2] =  Helpers.makeFP(-3871833.4425726126206)
    fjkm[3] = T.zero
    fjkm[4] =  Helpers.makeFP(143157876.71888898129)
    fjkm[5] = T.zero
    fjkm[6] =  Helpers.makeFP(-2167164983.2237950935)
    fjkm[7] = T.zero
    fjkm[8] =  Helpers.makeFP(17634730606.834969383)
    fjkm[9] = T.zero
    fjkm[10] =  Helpers.makeFP(-87867072178.023265677)
    fjkm[11] = T.zero
    fjkm[12] =  Helpers.makeFP(287900649906.15058872)
    fjkm[13] = T.zero
    fjkm[14] =  Helpers.makeFP(-645364869245.37650328)
    fjkm[15] = T.zero
    fjkm[16] =  Helpers.makeFP(1008158106865.3820948)
    fjkm[17] = T.zero
    fjkm[18] =  Helpers.makeFP(-1098375156081.2233068)
    fjkm[19] = T.zero
    fjkm[20] =  Helpers.makeFP(819218669548.57732864)
    fjkm[21] = T.zero
    fjkm[22] =  Helpers.makeFP(-399096175224.46649796)
    fjkm[23] = T.zero
    fjkm[24] =  Helpers.makeFP(114498237732.02580995)
    fjkm[25] = T.zero
    fjkm[26] =  Helpers.makeFP(-14679261247.695616661)
    j = 0; k = 3; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-228221.94342866468364)
    fjkm[1] =  Helpers.makeFP(240393.78041152680010)
    fjkm[2] =  Helpers.makeFP(56141584.917302882999)
    fjkm[3] =  Helpers.makeFP(-58722807.212351291413)
    fjkm[4] =  Helpers.makeFP(-2362104965.8616681913)
    fjkm[5] =  Helpers.makeFP(2457543550.3409275122)
    fjkm[6] =  Helpers.makeFP(40092552189.640209230)
    fjkm[7] =  Helpers.makeFP(-41537328845.122739292)
    fjkm[8] =  Helpers.makeFP(-361511977440.11687235)
    fjkm[9] =  Helpers.makeFP(373268464511.34018528)
    fjkm[10] =  Helpers.makeFP(1977009124005.5234777)
    fjkm[11] =  Helpers.makeFP(-2035587172124.2056548)
    fjkm[12] =  Helpers.makeFP(-7053565922700.6894237)
    fjkm[13] =  Helpers.makeFP(7245499689304.7898162)
    fjkm[14] =  Helpers.makeFP(17102169035002.477337)
    fjkm[15] =  Helpers.makeFP(-17532412281166.061672)
    fjkm[16] =  Helpers.makeFP(-28732506045663.389701)
    fjkm[17] =  Helpers.makeFP(29404611450240.311097)
    fjkm[18] =  Helpers.makeFP(33500442260477.310858)
    fjkm[19] =  Helpers.makeFP(-34232692364531.459729)
    fjkm[20] =  Helpers.makeFP(-26624606760328.763181)
    fjkm[21] =  Helpers.makeFP(27170752540027.814733)
    fjkm[22] =  Helpers.makeFP(13768818045244.094179)
    fjkm[23] =  Helpers.makeFP(-14034882162060.405178)
    fjkm[24] =  Helpers.makeFP(-4179185677218.9420633)
    fjkm[25] =  Helpers.makeFP(4255517835706.9592699)
    fjkm[26] =  Helpers.makeFP(565151558036.28124143)
    fjkm[27] =  Helpers.makeFP(-574937732201.41165254)
    j = 1; k = 3; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(1540498.1181434866146)
    fjkm[1] =  Helpers.makeFP(-3322911.4963213577938)
    fjkm[2] =  Helpers.makeFP(-433313348.25129661430)
    fjkm[3] =  Helpers.makeFP(929240026.21742702895)
    fjkm[4] =  Helpers.makeFP(20173953055.394385937)
    fjkm[5] =  Helpers.makeFP(-43806310275.980028275)
    fjkm[6] =  Helpers.makeFP(-367752562201.24170098)
    fjkm[7] =  Helpers.makeFP(823522693625.04213554)
    fjkm[8] =  Helpers.makeFP(3453452850623.2709660)
    fjkm[9] =  Helpers.makeFP(-8147245540357.7558550)
    fjkm[10] =  Helpers.makeFP(-18967395863304.498472)
    fjkm[11] =  Helpers.makeFP(48502623842268.842654)
    fjkm[12] =  Helpers.makeFP(64652876623215.013090)
    fjkm[13] =  Helpers.makeFP(-187135422438997.88267)
    fjkm[14] =  Helpers.makeFP(-137928375585894.45832)
    fjkm[15] =  Helpers.makeFP(487895841149504.63648)
    fjkm[16] =  Helpers.makeFP(171009666849543.97695)
    fjkm[17] =  Helpers.makeFP(-877097552972882.42245)
    fjkm[18] =  Helpers.makeFP(-74254863627598.106482)
    fjkm[19] =  Helpers.makeFP(1089588154832573.5204)
    fjkm[20] =  Helpers.makeFP(-116085557257555.85969)
    fjkm[21] =  Helpers.makeFP(-919163347233503.76274)
    fjkm[22] =  Helpers.makeFP(228872931917376.68922)
    fjkm[23] =  Helpers.makeFP(502861180782827.78742)
    fjkm[24] =  Helpers.makeFP(-180138187046491.99093)
    fjkm[25] =  Helpers.makeFP(-160984522251228.28879)
    fjkm[26] =  Helpers.makeFP(71472589051967.572740)
    fjkm[27] =  Helpers.makeFP(22899647546405.161991)
    fjkm[28] =  Helpers.makeFP(-11739127546959.248774)
    j = 2; k = 3; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
}

fileprivate func fjkproc16_007<T: SSFloatingPoint>(fjk: inout Array<Array<T>>, un: Array<T>, v: T) {
    var d, j, k: Int
    var fjkm:Array<T> = Array<T>.init(repeating: 0, count: 33)
    fjkm[0] =  Helpers.makeFP(-7445740.9043601853037)
    fjkm[1] =  Helpers.makeFP(24634048.351746637287)
    fjkm[2] =  Helpers.makeFP(2366020806.0262900637)
    fjkm[3] =  Helpers.makeFP(-7808648260.6425043412)
    fjkm[4] =  Helpers.makeFP(-118977141825.00262846)
    fjkm[5] =  Helpers.makeFP(409347654830.37623610)
    fjkm[6] =  Helpers.makeFP(2227886871742.0341399)
    fjkm[7] =  Helpers.makeFP(-8418196051278.7614582)
    fjkm[8] =  Helpers.makeFP(-19993114336865.499162)
    fjkm[9] =  Helpers.makeFP(89749606285710.604304)
    fjkm[10] =  Helpers.makeFP(91027650219177.795567)
    fjkm[11] =  Helpers.makeFP(-567320456048460.00800)
    fjkm[12] =  Helpers.makeFP(-158541319151866.40491)
    fjkm[13] =  Helpers.makeFP(2286994298876364.5224)
    fjkm[14] =  Helpers.makeFP(-406108119093234.18714)
    fjkm[15] =  Helpers.makeFP(-6109006264284954.9274)
    fjkm[16] =  Helpers.makeFP(3061509093597577.3617)
    fjkm[17] =  Helpers.makeFP(10949569443954370.550)
    fjkm[18] =  Helpers.makeFP(-8409227264715248.2782)
    fjkm[19] =  Helpers.makeFP(-12972671111828071.122)
    fjkm[20] =  Helpers.makeFP(13506857028733485.383)
    fjkm[21] =  Helpers.makeFP(9542099548494263.3202)
    fjkm[22] =  Helpers.makeFP(-13665198589678693.875)
    fjkm[23] =  Helpers.makeFP(-3500771616752033.2515)
    fjkm[24] =  Helpers.makeFP(8599505926079281.8598)
    fjkm[25] =  Helpers.makeFP(-192584364085979.71888)
    fjkm[26] =  Helpers.makeFP(-3085105840164255.6689)
    fjkm[27] =  Helpers.makeFP(648294322883069.58159)
    fjkm[28] =  Helpers.makeFP(483163296698761.31750)
    fjkm[29] =  Helpers.makeFP(-166336791576720.83219)
    j = 3; k = 3; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(118838.42625678325312)
    fjkm[1] = T.zero
    fjkm[2] =  Helpers.makeFP(-29188388.122220813403)
    fjkm[3] = T.zero
    fjkm[4] =  Helpers.makeFP(1247009293.5127103248)
    fjkm[5] = T.zero
    fjkm[6] =  Helpers.makeFP(-21822927757.529223729)
    fjkm[7] = T.zero
    fjkm[8] =  Helpers.makeFP(205914503232.41001569)
    fjkm[9] = T.zero
    fjkm[10] =  Helpers.makeFP(-1196552880196.1815990)
    fjkm[11] = T.zero
    fjkm[12] =  Helpers.makeFP(4612725780849.1319668)
    fjkm[13] = T.zero
    fjkm[14] =  Helpers.makeFP(-12320491305598.287160)
    fjkm[15] = T.zero
    fjkm[16] =  Helpers.makeFP(23348364044581.840938)
    fjkm[17] = T.zero
    fjkm[18] =  Helpers.makeFP(-31667088584785.158403)
    fjkm[19] = T.zero
    fjkm[20] =  Helpers.makeFP(30565125519935.320612)
    fjkm[21] = T.zero
    fjkm[22] =  Helpers.makeFP(-20516899410934.437391)
    fjkm[23] = T.zero
    fjkm[24] =  Helpers.makeFP(9109341185239.8989559)
    fjkm[25] = T.zero
    fjkm[26] =  Helpers.makeFP(-2406297900028.5039611)
    fjkm[27] = T.zero
    fjkm[28] =  Helpers.makeFP(286464035717.67904299)
    j = 0; k = 4; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-1604318.7544665739172)
    fjkm[1] =  Helpers.makeFP(1683544.3719710960859)
    fjkm[2] =  Helpers.makeFP(452420015.89442260775)
    fjkm[3] =  Helpers.makeFP(-471878941.30923648336)
    fjkm[4] =  Helpers.makeFP(-21822662636.472430684)
    fjkm[5] =  Helpers.makeFP(22654002165.480904234)
    fjkm[6] =  Helpers.makeFP(425547091271.81986272)
    fjkm[7] =  Helpers.makeFP(-440095709776.83934521)
    fjkm[8] =  Helpers.makeFP(-4427161819496.8153373)
    fjkm[9] =  Helpers.makeFP(4564438154985.0886811)
    fjkm[10] =  Helpers.makeFP(28118992684610.267576)
    fjkm[11] =  Helpers.makeFP(-28916694604741.055309)
    fjkm[12] =  Helpers.makeFP(-117624507411652.86515)
    fjkm[13] =  Helpers.makeFP(120699657932218.95313)
    fjkm[14] =  Helpers.makeFP(338813510903952.89689)
    fjkm[15] =  Helpers.makeFP(-347027171774351.75500)
    fjkm[16] =  Helpers.makeFP(-688776739315164.30766)
    fjkm[17] =  Helpers.makeFP(704342315344885.53495)
    fjkm[18] =  Helpers.makeFP(997513290420732.48968)
    fjkm[19] =  Helpers.makeFP(-1018624682810589.2619)
    fjkm[20] =  Helpers.makeFP(-1023931704917833.2405)
    fjkm[21] =  Helpers.makeFP(1044308455264456.7876)
    fjkm[22] =  Helpers.makeFP(728349929088172.52737)
    fjkm[23] =  Helpers.makeFP(-742027862028795.48563)
    fjkm[24] =  Helpers.makeFP(-341600294446496.21085)
    fjkm[25] =  Helpers.makeFP(347673188569989.47682)
    fjkm[26] =  Helpers.makeFP(95048767051125.906463)
    fjkm[27] =  Helpers.makeFP(-96652965651144.909104)
    fjkm[28] =  Helpers.makeFP(-11888257482283.680284)
    fjkm[29] =  Helpers.makeFP(12079233506095.466313)
    j = 1; k = 4; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(11631310.969882660899)
    fjkm[1] =  Helpers.makeFP(-24956069.513924483156)
    fjkm[2] =  Helpers.makeFP(-3719130469.3827566264)
    fjkm[3] =  Helpers.makeFP(7939241569.2440612457)
    fjkm[4] =  Helpers.makeFP(197650420583.57805736)
    fjkm[5] =  Helpers.makeFP(-426477178381.34693109)
    fjkm[6] =  Helpers.makeFP(-4137136219101.0505865)
    fjkm[7] =  Helpers.makeFP(9165629658162.2739663)
    fjkm[8] =  Helpers.makeFP(44999979919399.924736)
    fjkm[9] =  Helpers.makeFP(-104192738635599.46794)
    fjkm[10] =  Helpers.makeFP(-290053332678279.44824)
    fjkm[11] =  Helpers.makeFP(717931728117708.95938)
    fjkm[12] =  Helpers.makeFP(1184950942733150.9332)
    fjkm[13] =  Helpers.makeFP(-3238133498156090.6407)
    fjkm[14] =  Helpers.makeFP(-3148099361614567.8423)
    fjkm[15] =  Helpers.makeFP(10004238940145809.174)
    fjkm[16] =  Helpers.makeFP(5326672157182975.4416)
    fjkm[17] =  Helpers.makeFP(-21713978561461112.072)
    fjkm[18] =  Helpers.makeFP(-4997511985428331.4237)
    fjkm[19] =  Helpers.makeFP(33440445545533127.273)
    fjkm[20] =  Helpers.makeFP(429328409587666.98618)
    fjkm[21] =  Helpers.makeFP(-36372499368723031.528)
    fjkm[22] =  Helpers.makeFP(5419838346824587.4483)
    fjkm[23] =  Helpers.makeFP(27328510015364670.604)
    fjkm[24] =  Helpers.makeFP(-7462027883028047.7909)
    fjkm[25] =  Helpers.makeFP(-13500043636525530.253)
    fjkm[26] =  Helpers.makeFP(5000259547410615.2462)
    fjkm[27] =  Helpers.makeFP(3946328556046746.4962)
    fjkm[28] =  Helpers.makeFP(-1769166076587921.0596)
    fjkm[29] =  Helpers.makeFP(-517354048506128.35163)
    fjkm[30] =  Helpers.makeFP(264752449010576.61885)
    j = 2; k = 4; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(832859.30401628929898)
    fjkm[1] = T.zero
    fjkm[2] =  Helpers.makeFP(-234557963.52225152478)
    fjkm[3] = T.zero
    fjkm[4] =  Helpers.makeFP(11465754899.448237157)
    fjkm[5] = T.zero
    fjkm[6] =  Helpers.makeFP(-229619372968.24646817)
    fjkm[7] = T.zero
    fjkm[8] =  Helpers.makeFP(2485000928034.0853236)
    fjkm[9] = T.zero
    fjkm[10] =  Helpers.makeFP(-16634824724892.480519)
    fjkm[11] = T.zero
    fjkm[12] =  Helpers.makeFP(74373122908679.144941)
    fjkm[13] = T.zero
    fjkm[14] =  Helpers.makeFP(-232604831188939.92523)
    fjkm[15] = T.zero
    fjkm[16] =  Helpers.makeFP(523054882578444.65558)
    fjkm[17] = T.zero
    fjkm[18] =  Helpers.makeFP(-857461032982895.05140)
    fjkm[19] = T.zero
    fjkm[20] =  Helpers.makeFP(1026955196082762.4888)
    fjkm[21] = T.zero
    fjkm[22] =  Helpers.makeFP(-889496939881026.44181)
    fjkm[23] = T.zero
    fjkm[24] =  Helpers.makeFP(542739664987659.72270)
    fjkm[25] = T.zero
    fjkm[26] =  Helpers.makeFP(-221349638702525.19597)
    fjkm[27] = T.zero
    fjkm[28] =  Helpers.makeFP(54177510755106.049005)
    fjkm[29] = T.zero
    fjkm[30] =  Helpers.makeFP(-6019723417234.0054450)
    j = 0; k = 5; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(-12076459.908236194835)
    fjkm[1] =  Helpers.makeFP(12631699.444247054368)
    fjkm[2] =  Helpers.makeFP(3870206398.1171501588)
    fjkm[3] =  Helpers.makeFP(-4026578373.7986511753)
    fjkm[4] =  Helpers.makeFP(-212116465639.79238740)
    fjkm[5] =  Helpers.makeFP(219760302239.42454551)
    fjkm[6] =  Helpers.makeFP(4707197145849.0525974)
    fjkm[7] =  Helpers.makeFP(-4860276727827.8835762)
    fjkm[8] =  Helpers.makeFP(-55912520880766.919782)
    fjkm[9] =  Helpers.makeFP(57569188166122.976664)
    fjkm[10] =  Helpers.makeFP(407553205759865.77271)
    fjkm[11] =  Helpers.makeFP(-418643088909794.09305)
    fjkm[12] =  Helpers.makeFP(-1970887757079997.3409)
    fjkm[13] =  Helpers.makeFP(2020469839019116.7709)
    fjkm[14] =  Helpers.makeFP(6629237688884787.8691)
    fjkm[15] =  Helpers.makeFP(-6784307576344081.1526)
    fjkm[16] =  Helpers.makeFP(-15953173918642561.995)
    fjkm[17] =  Helpers.makeFP(16301877173694858.432)
    fjkm[18] =  Helpers.makeFP(27867483571944089.170)
    fjkm[19] =  Helpers.makeFP(-28439124260599352.538)
    fjkm[20] =  Helpers.makeFP(-35429954264855305.864)
    fjkm[21] =  Helpers.makeFP(36114591062243814.190)
    fjkm[22] =  Helpers.makeFP(32466638305657465.126)
    fjkm[23] =  Helpers.makeFP(-33059636265578149.421)
    fjkm[24] =  Helpers.makeFP(-20895477102024899.324)
    fjkm[25] =  Helpers.makeFP(21257303545350005.806)
    fjkm[26] =  Helpers.makeFP(8964660367452270.4366)
    fjkm[27] =  Helpers.makeFP(-9112226793253953.9006)
    fjkm[28] =  Helpers.makeFP(-2302544207092007.0827)
    fjkm[29] =  Helpers.makeFP(2338662547595411.1154)
    fjkm[30] =  Helpers.makeFP(267877692066913.24230)
    fjkm[31] =  Helpers.makeFP(-271890841011735.91260)
    j = 1; k = 5; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
    fjkm[0] =  Helpers.makeFP(6252951.4934347970025)
    fjkm[1] = T.zero
    fjkm[2] =  Helpers.makeFP(-2001646928.1917763315)
    fjkm[3] = T.zero
    fjkm[4] =  Helpers.makeFP(110997405139.17901279)
    fjkm[5] = T.zero
    fjkm[6] =  Helpers.makeFP(-2521558474912.8546213)
    fjkm[7] = T.zero
    fjkm[8] =  Helpers.makeFP(31007436472896.461417)
    fjkm[9] = T.zero
    fjkm[10] =  Helpers.makeFP(-236652530451649.25168)
    fjkm[11] = T.zero
    fjkm[12] =  Helpers.makeFP(1212675804250347.4165)
    fjkm[13] = T.zero
    fjkm[14] =  Helpers.makeFP(-4379325838364015.4378)
    fjkm[15] = T.zero
    fjkm[16] =  Helpers.makeFP(11486706978449752.110)
    fjkm[17] = T.zero
    fjkm[18] =  Helpers.makeFP(-22268225133911142.562)
    fjkm[19] = T.zero
    fjkm[20] =  Helpers.makeFP(32138275268586241.200)
    fjkm[21] = T.zero
    fjkm[22] =  Helpers.makeFP(-34447226006485144.698)
    fjkm[23] = T.zero
    fjkm[24] =  Helpers.makeFP(27054711306197081.241)
    fjkm[25] = T.zero
    fjkm[26] =  Helpers.makeFP(-15129826322457681.181)
    fjkm[27] = T.zero
    fjkm[28] =  Helpers.makeFP(5705782159023670.8096)
    fjkm[29] = T.zero
    fjkm[30] =  Helpers.makeFP(-1301012723549699.4268)
    fjkm[31] = T.zero
    fjkm[32] =  Helpers.makeFP(135522158703093.69029)
    j = 0; k = 6; d = j + 2 * k; fjk[j][k] = un[d] * pol(fjkm,d,v);
}

fileprivate func fjkproc16<T: SSFloatingPoint>(_ u: T,_ fjk: inout Array<Array<T>>) {
    var un:Array<T> = Array<T>.init(repeating: 0, count: 65)
    var v: T
    v = u * u
    un[1] = u
    un[2] = v
    for n in stride(from: 2, through: 64, by: 1) {
        un[n] = u * un[n-1]
    }
    fjk[0][0] = 1
    fjkproc16_001(fjk: &fjk, un: un, v: v)
    fjkproc16_002(fjk: &fjk, un: un, v: v)
    fjkproc16_003(fjk: &fjk, un: un, v: v)
    fjkproc16_004(fjk: &fjk, un: un, v: v)
    fjkproc16_005(fjk: &fjk, un: un, v: v)
    fjkproc16_006(fjk: &fjk, un: un, v: v)
    fjkproc16_007(fjk: &fjk, un: un, v: v)
}

fileprivate func startingpser<T: SSFloatingPoint>(_ mu: T,_ x: T,_  y: T) -> Int {
    // Computes a starting value for the backward summation of the series in pser}
    var n, n1, lnx, lny, mulnmu: T
    var a, b: Int
    mulnmu = mu * SSMath.log1(mu)
    lnx = SSMath.log1(x)
    lny = SSMath.log1(y)
    if (x < 2) {
        n = x + 5
    } else {
        n =  Helpers.makeFP(1.5) * x
    }
    n1 = 0
    a = 0
    b = 0
    while (abs(n - n1) > 1) {
        n1 = n
        n = ps(mu,mulnmu,lnx,y,lny,n,a,b)
    }
    n = n + 1
    if ((mu + n) > y) {
        if (y > mu) {
            a = 1
        }
        else {
            b = 1
        }
        n1 = 0
        while (abs(n - n1) > 1) {
            n1 = n
            n = ps(mu,mulnmu,lnx,y,lny,n,a,b)
        }
    }
    return Helpers.integerValue(n) + 1
}

fileprivate func ps<T: SSFloatingPoint>(_ mu: T,_ mulnmu: T,_ lnx: T,_ y: T,_ lny: T,_ n: T,_ a: Int, _ b: Int) -> T {
    var lneps, f:T
    f = T.nan
    lneps = T.nan
    lneps = SSMath.log1(epss())
    var ex1: T
    var ex2: T
    var ex3: T
    var ex4: T
    var ex5: T
    var ex6: T
    var ex7: T
    if ((a == 0) && (b == 0)) {
        ex1 = n - lneps
        ex2 = SSMath.log1(n) - lnx
        f = ex1 / ex2
    } else if  ((a==0) && (b==1)) {
        ex1 =  Helpers.makeFP(2) * n - lneps + mulnmu
        ex2 = ex1 - mu * SSMath.log1(mu + n)
        let ex21: T = SSMath.log1(n) - lnx
        ex3 = ex21 - lny + SSMath.log1(mu + n)
        f = ex2 / ex3
        ex1 = 2 * n
        ex2 = SSMath.log1(mu + n)
        ex3 = ex1 - lneps
        ex4 = ex3 + mulnmu
        ex5 = ex4 - (mu * ex2)
        ex6 = SSMath.log1(n) - lnx
        ex7 = ex6 - lny + ex2
        f = ex5 / ex7
        //        f = (2 * n - lneps + mulnmu - mu * SSMath.log1(mu + n)) / (SSMath.log1(n) - lnx - lny + SSMath.log1(mu+n))
    } else if ((a==1) && (b==0)) {
        ex1 = 2 * n
        ex2 = ex1 - lneps - y
        ex3 = ex2 +  mu * lny
        ex4 = ex3 - mu * SSMath.log1(mu + n)
        ex5 = ex4 + mu
        ex6 = SSMath.log1(n) - lnx
        ex7 = ex6 - lny + SSMath.log1(mu + n)
        f = ex5 / ex7
    }
    return f
}



fileprivate func hypfun<T: SSFloatingPoint>(_ x: T,_ sinh: inout T,_ cosh: inout T) {
    var ss: T
    var ax, y, f, f2: T
    var ex1, ex2: T
    y = T.nan
    ax = abs(x)
    if (ax <  Helpers.makeFP(0.21)) {
        if (ax <  Helpers.makeFP(0.07)) {
            y = x * x
        } else {
            y = x * x / 9
        }
    }
    ex1 = y * 28 + 2520
    ex2 = y * (y + 420) + 15120
    f = 2 + y * (ex1) / (ex2)
    f2 = f * f
    sinh = 2 * x * f / (f2 - y)
    cosh = (f2 + y) / (f2 - y)
    if (ax >=  Helpers.makeFP(0.07)) {
        ss = 2 * sinh / 3
        f = ss * ss
        sinh = sinh * (1 + f / 3)
        cosh = cosh * (1 + f)
    } else {
        y = SSMath.exp1(x)
        f = 1 / y
        cosh = (y + f) / 2
        sinh = (y - f) / 2
    }
}
//



fileprivate func ignega<T: SSFloatingPoint>(_ n: Int,_ x: T, _ eps: T) -> T {
    //!------------------------------------------------
    //! Computes the Incomplete Gama(1/2-n,x), x >= 0,
    //! n=0,1,2, ...
    //!------------------------------------------------
    var a, delta, g, p, q, r, s, t, tau, ro: T
    var k: Int
    var ex1: T
    var ex2: T
    var ex3: T
    a = T.half -  Helpers.makeFP(n)
    delta = epss() / 100
    if (x >  Helpers.makeFP(1.5)) {
        p = 0
        ex1 = x - T.one - a
        ex2 = x + T.one - a
        ex3 = ex1 * ex2
        q = ex3
        r = 4 * (x + 1 - a)
        s = 1 - a
        ro = 0
        t = 1
        k = 0
        g = 1
        while ((t / g) > delta) {
            p = p + s
            q = q + r
            r = r + 8
            s = s + 2
            tau = p * (1 + ro)
            ro = tau / (q - tau)
            t = ro * t
            g = g + t
            k = k + 1
        }
        ex1 = a * SSMath.log1(x)
        ex2 = g * SSMath.exp1(ex1)
        ex3 = x + T.one - a
        g = ex2 / ex3
    } else {
        t = 1
        s = 1 / a
        k = 1
        while (abs(t / s) > delta) {
            t = -x * t /  Helpers.makeFP(k)
            s = s + t / ( Helpers.makeFP(k) + a);
            k = k + 1
        }
        g = T.sqrtpi
        for k in stride(from: 1, through: n, by: 1) {
            //        for (k=1;k<=n;k++) {
            g = g / (T.half -  Helpers.makeFP(k))
        }
        ex1 = a * SSMath.log1(x)
        ex2 = SSMath.exp1(ex1) * s
        ex3 = g - ex2
        g = SSMath.exp1(x) * ex3
    }
    return g
}

fileprivate func startkbes<T: SSFloatingPoint>(_ x: T, _ eps: T) -> Int {
    var y, p, q, r, s, c, del, r2, r4: T
    var ex1, ex2: T
    if (eps < T.ulpOfOne) {
        del = -SSMath.log1(T.ulpOfOne / 2)
    } else {
        del = -SSMath.log1(eps / 2)
    }
    p = x + del
    q = p / x
    if (q < 2) {
        ex1 = q + T.one
        ex2 = q - T.one
        r = SSMath.log1(ex1 / ex2) * T.half
        ex1 = r * (q + 1 / q)
        ex2 = 2 / (1 + ex1)
        y = r * (1 + ex2)
    } else {
        r = 2 * x / p
        r2 = r * r
        r4 = r2 * r2
        ex1 = r4 / 45
        ex2 = T.one + ex1
        y = r * ex2
    }
    s = 0
    c = 0
    hypfun(y, &s, &c)
    return 1 + Helpers.integerValue(x / (2 * s * s))
}


fileprivate func startijbes<T: SSFloatingPoint>(_ x: T,_ n: Int, _ t: Int,_ eps: T) -> Int {
    var p, q, r, y, del: T
    var s: Int
    if (x <= 0) {
        return 0
    } else {
        s = 2 * t - 1
    }
    if (eps < T.ulpOfOne) {
        del = -SSMath.log1(T.ulpOfOne / 2)
    } else {
        del = -SSMath.log1(eps / 2)
    }
    p = del / x -  Helpers.makeFP(t)
    r =  Helpers.makeFP(n) / x
    if ((r > 1) || (t == 1)) {
        q = sqrt(r * r +  Helpers.makeFP(s))
        r = r * SSMath.log1(q + r) - q
    } else {
        r = 0
    }
    q = del / (2 * x) + r
    if (p > q) {
        r = p
    } else {
        r = q
    }
    y = alfinv(t, r, &p, &q)
    hypfun(y, &p, &q)
    if (t == 0) {
        s = Helpers.integerValue(x * q) + 1
    } else {
        s = Helpers.integerValue(x * p) + 1
    }
    if ((s % 2) > 0) {
        s = s + 1
    }
    return s
}





fileprivate func alfinv<T: SSFloatingPoint>(_ t: Int, _ r: T, _ p: inout T, _ q: inout T) -> T {
    var a, b, a2, lna: T
    var ex1, ex2, ex3: T
    //    int t;
    //    r = *rr;
    //    p = *pp;
    //    t = *tt;
    //    q = *qq;
    if (( Helpers.makeFP(t) + r) <  Helpers.makeFP(2.7)) {
        if (t == 0) {
            a = SSMath.exp1(SSMath.log1(3 * r) / 3)
            a2 = a * a
            ex1 =  Helpers.makeFP(0.004312) * a2
            ex2 =  Helpers.makeFP(-1.0/30.0) + ex1
            ex3 = T.one + a2 * ex2
            b = a * ex3
            //            b = a * (1 + a2 * ( Helpers.makeFP(-1.0/30.0) +  Helpers.makeFP(0.004312) * a2))
        } else {
            a = sqrt(2 * (1 + r))
            a2 = a * a
            b = a / (1 + a2 / 8)
        }
    } else {
        a = SSMath.log1( Helpers.makeFP(0.7357589) * ( Helpers.makeFP(t) + r))
        lna = SSMath.log1(a) / a
        ex1 = T.half * lna * lna
        ex2 = SSMath.log1(a) * (1 / a - 1)
        ex3 = ex2 + ex1
        b = 1 + a + ex3
        //        b = 1 + a + SSMath.log1(a) * (1 / a - 1) + T.half * lna * lna
    }
    while (abs(a / b - 1) >  Helpers.makeFP(1.0e-2)) {
        a = b
        b = fi(a,r,t,q);
    }
    return b;
}


fileprivate func falfa<T: SSFloatingPoint>(_ al: T,_ r: T,_ t: Int, _ df: inout T) -> T {
    var sh, ch: T
    var res: T
    sh = 0
    ch = 0
    var ex1: T
    var ex2: T
    var ex3: T
    hypfun(al, &sh, &ch)
    if (t == 1) {
        ex1 = r / ch
        ex2 = al * sh / ch
        res = ex2 - T.one - ex1
        ex1 = al + r * sh
        ex2 = ex1 / ch
        ex3 = sh + ex2
        df = ex3 / ch
    } else {
        res = al - (sh + r) / ch
        df = sh * (r + sh) / (ch * ch)
    }
    return res;
}

fileprivate func fi<T: SSFloatingPoint>(_ al: T,_ r: T,_ t: Int, _ q: T) -> T {
    var res, p:T
    var qq: T = q
    p = falfa(al,r,t,&qq)
    res = al - p / qq
    return res
}

fileprivate func fractio1<T: SSFloatingPoint>(_ x: T,_ n: Int,_ r: Array<T>, _ s: Array<T>) -> T {
    var a, b: T
    a = r[n]
    b = 1
    for k in stride(from: n - 1, through: 0, by: -1) {
        a = a * x + r[k]
        b = b * x + s[k]
    }
    return a/b
}


fileprivate func recipgam<T: SSFloatingPoint>(_ x: T,_ q: inout T, _ r: inout T) -> T {
    //!recipgam(x)=1/gamma(x+1)=1 + x * (q + x * r); -0.5<=x<=0.5}
    var t, tx: T
    var ex1: T
    var ex2: T
    var ex3: T
    var c : Array<T> = Array<T>.init(repeating: 0, count: 9)
    if (x.isZero) {
        q = T.eulergamma
        r =  Helpers.makeFP(-0.6558780715202538811)
    } else {
        c[0] =  Helpers.makeFP(1.142022680371167841)
        c[1] =  Helpers.makeFP(-6.5165112670736881e-3)
        c[2] =  Helpers.makeFP(-3.087090173085368e-4)
        c[3] =  Helpers.makeFP(3.4706269649043e-6)
        c[4] =  Helpers.makeFP(-6.9437664487e-9)
        c[5] =  Helpers.makeFP(-3.67795399e-11)
        c[6] =  Helpers.makeFP(1.356395e-13)
        c[7] =  Helpers.makeFP(3.68e-17)
        c[8] =  Helpers.makeFP(-5.5e-19)
        tx = 2 * x
        t = 2 * tx * tx - 1
        q = chepolsum(8,t,c)
        c[0] =  Helpers.makeFP(-1.270583625778727532)
        c[1] =  Helpers.makeFP(2.05083241859700357e-2)
        c[2] =  Helpers.makeFP(-7.84761097993185e-5)
        c[3] =  Helpers.makeFP(-5.377798984020e-7)
        c[4] =  Helpers.makeFP(+3.8823289907e-9)
        c[5] =  Helpers.makeFP(-2.6758703e-12)
        c[6] =  Helpers.makeFP(-2.39860e-14)
        c[7] =  Helpers.makeFP(3.80e-17)
        c[8] =  Helpers.makeFP(4e-20)
        r = chepolsum(8,t,c)
    }
    ex1 = x * r
    ex2 = q + ex1
    ex3 = x * ex2
    return T.one + ex3
}

fileprivate func errorfunction<T: SSFloatingPoint>(_ x: T, _ erfcc: Bool,_ expo: Bool) -> T {
    var y, z, errfu: T
    var r, s: Array<T>
    r = Array<T>.init(repeating: 0, count: 9)
    s = Array<T>.init(repeating: 0, count: 9)
    if (erfcc) {
        if (x <  Helpers.makeFP(-6.5)) {
            y = 2
        } else if  (x < 0) {
            y = 2 - errorfunction(-x, true, false)
        } else if  (x.isZero) {
            y = 1
        } else if  (x < T.half) {
            if (expo) {
                y = SSMath.exp1(x * x)
            }
            else {
                y = 1
            }
            y = y * (1 - errorfunction(x, false, false))
        } else if  (x < 4) {
            if (expo) {
                y = 1
            } else {
                y = SSMath.exp1(-x * x)
            }
            r[0] =  Helpers.makeFP( 1.230339354797997253e3)
            r[1] =  Helpers.makeFP( 2.051078377826071465e3)
            r[2] =  Helpers.makeFP( 1.712047612634070583e3)
            r[3] =  Helpers.makeFP( 8.819522212417690904e2)
            r[4] =  Helpers.makeFP( 2.986351381974001311e2)
            r[5] =  Helpers.makeFP( 6.611919063714162948e1)
            r[6] =  Helpers.makeFP( 8.883149794388375941)
            r[7] =  Helpers.makeFP( 5.641884969886700892e-1)
            r[8] =  Helpers.makeFP( 2.153115354744038463e-8)
            s[0] =  Helpers.makeFP( 1.230339354803749420e3)
            s[1] =  Helpers.makeFP( 3.439367674143721637e3)
            s[2] =  Helpers.makeFP( 4.362619090143247158e3)
            s[3] =  Helpers.makeFP( 3.290799235733459627e3)
            s[4] =  Helpers.makeFP( 1.621389574566690189e3)
            s[5] =  Helpers.makeFP( 5.371811018620098575e2)
            s[6] =  Helpers.makeFP( 1.176939508913124993e2)
            s[7] =  Helpers.makeFP( 1.574492611070983473e1)
            y = y * fractio(x, 8, r, s)
        } else {
            z = x * x
            if (expo) {
                y = 1
            } else {
                y = SSMath.exp1(-z)
            }
            z = 1 / z
            r[0] =  Helpers.makeFP(6.587491615298378032e-4)
            r[1] =  Helpers.makeFP(1.608378514874227663e-2)
            r[2] =  Helpers.makeFP(1.257817261112292462e-1)
            r[3] =  Helpers.makeFP(3.603448999498044394e-1)
            r[4] =  Helpers.makeFP(3.053266349612323440e-1)
            r[5] =  Helpers.makeFP(1.631538713730209785e-2)
            s[0] =  Helpers.makeFP(2.335204976268691854e-3)
            s[1] =  Helpers.makeFP(6.051834131244131912e-2)
            s[2] =  Helpers.makeFP(5.279051029514284122e-1)
            s[3] =  Helpers.makeFP(1.872952849923460472)
            s[4] =  Helpers.makeFP(2.568520192289822421)
            y = y * (T.oosqrtpi - z * fractio(z, 5, r, s)) / x
        }
        errfu = y
    } else {
        if (x.isZero) {
            y = 0
        } else if  (abs(x) >  Helpers.makeFP(6.5)) {
            y = x / abs(x)
        } else if  (x > T.half) {
            y = 1 - errorfunction(x, true, false)
        } else if  (x < -T.half) {
            y = errorfunction(-x, true, false) - 1
        } else {
            r[0] =  Helpers.makeFP(3.209377589138469473e3)
            r[1] =  Helpers.makeFP(3.774852376853020208e2)
            r[2] =  Helpers.makeFP(1.138641541510501556e2)
            r[3] =  Helpers.makeFP(3.161123743870565597e0)
            r[4] =  Helpers.makeFP(1.857777061846031527e-1)
            s[0] =  Helpers.makeFP(2.844236833439170622e3)
            s[1] =  Helpers.makeFP(1.282616526077372276e3)
            s[2] =  Helpers.makeFP(2.440246379344441733e2)
            s[3] =  Helpers.makeFP(2.360129095234412093e1)
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


fileprivate func zetaxy<T: SSFloatingPoint>(_ x: inout T,_ y: inout T) -> T {
    var w, z, z2, S, t: T
    var ck: Array<T> = Array<T>.init(repeating: 0, count: 11)
    var res: T
    var x2, x3, x4, x5, x6, x7, x8, x9, x10, x2p1: T
    var k: Int
    var ex1, ex2, ex3, ex4, ex5, ex6: T
    z = (y - x - 1)
    x2 = x * x
    x3 = x2 * x
    x4 = x3 * x
    x5 = x4 * x
    x6 = x5 * x
    x7 = x6 * x
    x8 = x7 * x
    x9 = x8 * x
    x10 = x9 * x
    x2p1 = 2 * x + 1
    if (abs(z) <  Helpers.makeFP(0.05)) {
        ck[0] = 1
        ck[1] = -T.third * (3 * x + 1)
        ex1 = 72 * x2
        ex2 = 42 * x
        ex3 = ex1 + ex2
        ex4 = ex3 + 7
        ck[2] =  Helpers.makeFP(1.0/36.0) * ex4
        ex1 = 2700 * x3
        ex2 = ex1 + 2142 * x2
        ex3 = ex2 + 657 * x + 73
        ck[3] =  Helpers.makeFP(-1.0/540.0) * ex3
        ex1 = 1331 + 15972 * x
        ex2 = ex1 + 76356 * x2
        ex3 = ex2 + 177552 * x3
        ex4 = ex3 + 181440 * x4
        ck[4] =  Helpers.makeFP(1.0/12960.0) * ex4
        ex1 = 22409 + 336135 * x
        ex2 = ex1 + 2115000 * x2
        ex3 = ex2 + 7097868 * x3
        ex4 = ex3 + 13105152 * x4
        ex5 = ex4 + 11430720 * x5
        ck[5] =  Helpers.makeFP(-1.0/272160.0) * ex5
        ex1 = 6706278 * x + 52305684 * x2
        let ex11: T = 228784392 * x3
        let ex12: T = 602453376 * x4
        ex2 = ex1 + ex11 + ex12
        var ex21: T = 935038080 * x5
        var ex22: T =  718502400 * x6
        ex3 = ex2 + ex21 + ex22
        ex4 = ex3 + 372571
        ck[6] =  Helpers.makeFP(1.0/5443200.0) * ex4
        ex1 = 953677 + 20027217 * x
        ex21 = 186346566 * x2
        ex22 = 1003641768 * x3
        ex2 = ex1 + ex21 + ex22
        ex21 = 3418065864 * x4
        ex22 = 7496168976 * x5
        ex3 = ex2 + ex21 + ex22
        ex21 = 10129665600 * x6
        ex22 =  7005398400 * x7
        ex4 = ex3 + ex21 + ex22
        ck[7] =  Helpers.makeFP(-1.0/16329600.0) * ex4
        ex1 = 39833047 + 955993128 * x
        ex21 = 1120863744000 * x8
        ex22 = 10332818424 * x2
        ex2 = ex1 + ex21 + ex22
        ex21 = 66071604672 * x3
        ex22 = 275568952176 * x4
        ex3 = ex2 + ex21 + ex22
        ex21 = 776715910272 * x5
        ex22 = 1472016602880 * x6
        ex4 = ex3 + ex21 + ex22
        ex5 = ex4 + 1773434373120 * x7
        ck[8] =  Helpers.makeFP(1.0/783820800.0) * ex5
        ex1 = 17422499659 + 470407490793 * x
        ex21 = 3228423729868800 * x8
        ex22 = 1886413681152000 * x9
        ex2 = ex1 + ex21 + ex22
        ex21 = 5791365522720 * x2
        ex22 = 42859969263000 * x3
        ex3 = ex2 + ex21 + ex22
        ex21 = 211370902874640 * x4
        ex22 = 726288467241168 * x5
        ex4 = ex3 + ex21 + ex22
        ex21 = 1759764571151616 * x6
        ex22 = 2954947944510720 * x7
        ex5 = ex4 + ex21 + ex22
        ck[9] =  Helpers.makeFP(-1.0/387991296000.0) * ex5
        ex1 = 261834237251 + 7855027117530 * x
        ex21 = 200149640441008128 * x8
        ex22 = 200855460151664640 * x9
        ex2 = ex1 + ex21 + ex22
        ex21 = 109480590367948800 * x10
        ex22 = 108506889674064 * x2
        ex3 = ex2 + ex21 + ex22
        ex21 = 912062714644368 * x3
        ex22 = 5189556987668592 * x4
        ex4 = ex3 + ex21 + ex22
        ex21 = 21011917557260448 * x5
        ex22 = 61823384007654528 * x6
        ex5 = ex4 + ex21 + ex22
        ex6 = ex5 + 132131617757148672 * x7
        ck[10] =  Helpers.makeFP(1.0/6518253772800.0) * ex6
        z2 = z / (x2p1 * x2p1)
        S = 1; t = 1; k = 1;
        while ((abs(t) >  Helpers.makeFP(1.0e-15)) && (k < 11)) {
            t = ck[k] * SSMath.pow1(z2,  Helpers.makeFP(k))
            S = S + t
            k = k + 1
        }
        res = -z / sqrt(x2p1) * S
    } else {
        w = sqrt(1 + 4 * x * y)
        ex1 = 2 * y / (1 + w)
        ex2 = x + y - w
        res = sqrt(2 * (ex2 - SSMath.log1(ex1)))
        if (x + 1 < y) {
            res = -res
        }
    }
    return res
}

fileprivate func chepolsum<T: SSFloatingPoint>(_ n: Int,_ t: T,_ ak: Array<T>) -> T {
    var u0, u1, u2, s, tt: T
    var k: Int
    u0 = 0
    u1 = 0
    u2 = u1
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

fileprivate func oddchepolsum<T: SSFloatingPoint>(_ n: Int, _ x: T, _ ak: Array<T>) -> T {
    var h, r, s, y: T
    var k: Int
    var ex1: T
    var ex2: T
    var ex3: T
    var ex4: T
    if (n==0) {
        s = ak[0] * x
    }
    else if (n == 1) {
        ex1 =  Helpers.makeFP(4.0) * x * x
        ex2 = ex1 -  Helpers.makeFP(3.0)
        ex3 = ak[1] * ex2
        ex4 = ak[0] + ex3
        s = x * ex4
    }
    else {
        ex1 = 2 * x * x
        ex3 = ex1 - T.one
        y = 2 * ex3
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
    return SSMath.log1p1(t)
}

fileprivate func xminsinx<T: SSFloatingPoint>(_ x: T) -> T {
    //    !  {(x-sin(x))/(x^3/6)
    var f: T
    var fk: Array<T> = Array<T>.init(repeating: 0, count: 9)
    var t: T
    var ex1: T
    var ex2: T
    var ex3: T
    var ex4: T
    if (abs(x) > 1) {
        ex1 = x * x
        ex2 = ex1 * x
        ex3 = x - SSMath.sin1(x)
        ex4 = ex3 / ex2
        f = 6 * ex4
    }
    else {
        fk[0] =  Helpers.makeFP(1.95088260487819821294e-0)
        fk[1] =  Helpers.makeFP(-0.244124470324439564863e-1)
        fk[2] =  Helpers.makeFP(0.14574198156365500e-3)
        fk[3] =  Helpers.makeFP(-0.5073893903402518e-6)
        fk[4] =  Helpers.makeFP(0.11556455068443e-8)
        fk[5] =  Helpers.makeFP(-0.185522118416e-11)
        fk[6] =  Helpers.makeFP(0.22117315e-14)
        fk[7] =  Helpers.makeFP(-0.2035e-17)
        fk[8] =  Helpers.makeFP(0.15e-20)
        t = 2 * x * x - 1
        f = chepolsum(8, t, fk)
    }
    return f
    
}

fileprivate func trapsum<T: SSFloatingPoint>(_ a: T, _ b: T, _ h: T, _ d: T,_ xis2: T,_ mu: T,_ wxis: T,_ ys: T) -> T {
    var trapsum, b0, inte, s, aa, bb: T
    inte = 0
    b0 = 0
    s = 0
    b0 = b
    if (d.isZero) {
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


fileprivate func integrand<T: SSFloatingPoint>(_ theta: T,_ b0: inout T,_ inte: inout T,_ xis2: T,_ mu: T,_ wxis: T,_ ys: T)  {
    var eps, lneps, psitheta, p, ft, f, theta2, sintheta, costheta: T
    var term1, term2, sinth, dr, s2, wx, ts, rtheta, xminsinxtheta: T
    eps =  Helpers.makeFP(1.0e-16)
    lneps = SSMath.log1(eps)
    var ex1, ex2, ex3, ex4: T
    if (theta > b0) {
        f = 0
    }
    else if (abs(theta) <  Helpers.makeFP(1.0e-10)) {
        rtheta = (1 + wxis) / (2 * ys)
        theta2 = theta * theta
        psitheta = -wxis * theta2 * T.half
        f = rtheta / (1 - rtheta) * SSMath.exp1(mu * psitheta)
    }
    else {
        theta2 = theta * theta
        sintheta = SSMath.sin1(theta)
        costheta = SSMath.cos1(theta)
        ts = theta / sintheta
        s2 = sintheta * sintheta
        wx = sqrt(ts * ts + xis2)
        xminsinxtheta = xminsinx(theta)
        ex1 = xminsinxtheta * theta2
        ex2 = ts / 6
        p = ex1 * ex2
        ex1 = p * (ts + 1) - theta2
        ex2 = -s2 * xis2
        ex3 = costheta * wx + wxis
        term1 = ((ex1 + ex2) / (ex3))
        ex1 = (ts + 1) / (wx + wxis)
        ex2 = p * (1 + ex1)
        p = (ex2 / (1 + wxis))
        term2 = -logoneplusx(p)
        p = term1 + term2
        psitheta = p
        f = mu * psitheta
        if (f > lneps) {
            f = SSMath.exp1(f)
        }
        else {
            f = 0
            b0 = min(theta, b0)
        }
        rtheta = (ts + wx)/(2 * ys)
        sinth = SSMath.sin1(theta / 2)
        ex1 = 2 * theta * sinth * sinth
        ex2 = -xminsinxtheta * theta2 * theta / 6
        p = (ex1 + ex2) / (2 * ys * s2)
        dr = p * (1 + ts / wx)
        ex1 = dr * sintheta
        ex2 = (costheta - rtheta) * rtheta
        ex3 = rtheta - 2 * costheta
        ex4 = rtheta * ex3 + 1
        p = (ex1 + ex2) / ex4
        ft = p
        f = f * ft
    }
    inte = f
}



fileprivate func qser<T: SSFloatingPoint>(_ mu: T,_ x: T,_ y: T,_ p: inout T,_ q: inout T,_ ierro: inout Int) {
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
    var x1, q1, t, k, S, a: T
    var n, m, ierr: Int
    var ex1: T
    var ex2: T
    ierr = 0
    ierro = 0
    var conv: Bool = false
    let dwarf: T = T.ulpOfOne * 10
    let epss: T =  Helpers.makeFP(1e-15)
    p = SSSpecialFunctions.gammaNormalizedP(x: y, a: mu, converged: &conv)
    if !conv {
        ierr = 1
    }
    q0 = q
    ex1 = mu * SSMath.log1(y)
    ex2 = ex1 - y
    lh0 = ex2 - SSMath.lgamma1(mu + 1)
    if ((lh0 > SSMath.log1(dwarf)) && ( x < 100)) {
        h0 = SSMath.exp1(lh0)
        n = 0
        xy = x * y
        delta = epss / 100
        var ex1: T
        var ex2: T
        var ex3: T
        var ex4: T
        while ((q0 / q > delta) && (n < 1000)) {
            q0 = x * (q0 + h0) /  Helpers.makeFP(n + 1)
            ex1 =  Helpers.makeFP(n) + T.one
            ex2 = mu + ex1
            ex3 = ex1 * ex2
            ex4 = h0 / ex3
            h0 = xy * ex4
            q = q + q0
            n = n + 1
        }
        q = SSMath.exp1(-x) * q
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
            q1 = SSSpecialFunctions.gammaNormalizedQ(x: x1, a: a, converged: &conv)
            if !conv {
                ierr = 1
            }
            t = SSSpecialFunctions.GammaHelper.dompart(k,x,false) * q1
            S = S + t
            k = k + 1
            if (S.isZero && (k > 150)) {
                m = 1
            }
            if (S > 0) {
                if (((t / S) <  Helpers.makeFP(1e-16)) && (k > 10)) {
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
}

fileprivate func pser<T: SSFloatingPoint>(_ mu: T, _ x: T, _ y: T, _ p: inout T, _ q: inout T, _ ierr: inout Int) {
    //    !----------------------------------------------
    //    ! Computes backward the series expansion for P
    //    ! For computing the incomplete gamma functions we
    //    ! use the routine incgam included in the module
    //    ! IncgamFI. Reference: A. Gil, J. Segura and
    //    ! NM Temme, Efficient and accurate algorithms for
    //    ! the computation and inversion of the incomplete
    //    ! gamma function ratios. SIAM J Sci Comput.
    //    !----------------------------------------------
    var lh0, h0, p1, xy, S: T
    let dwarf = T.ulpOfOne * 10
    var a, x1, expo, facto, t: T
    var  n, k, nnmax: Int
    var ex1: T
    var ex2: T
    var ex3: T
    var ex4: T
    var ex5: T
    ierr = 0
    xy = x * y
    nnmax = startingpser(mu,x,y)
    n = 1 + nnmax
    ex1 = -x - y
    ex2 = ex1 +  Helpers.makeFP(n) * SSMath.log1(x)
    ex3 = ex2 + ( Helpers.makeFP(n) + mu) * SSMath.log1(y)
    ex4 = ex3 - SSSpecialFunctions.GammaHelper.loggam(mu +  Helpers.makeFP(n + 1))
    lh0 = ex4 - SSSpecialFunctions.GammaHelper.loggam( Helpers.makeFP(n + 1))
    var incg: (p:T, q: T, ierr: Int)
    if (lh0 < SSMath.log1(dwarf)) {
        x1 = y
        expo = SSMath.exp1(-x)
        facto = 1
        S = 0
        t = 1
        k = 0
        k = startingpser(mu,x,y) + 1
        while ((k > 0) && (ierr == 0)) {
            a = mu +  Helpers.makeFP(k)
            facto = factor(x,k)
            incg = SSSpecialFunctions.GammaHelper.incgam(a: a, x: x1)
            p1 = incg.p
            ierr = incg.ierr
            t = facto * p1
            S = S + t
            k = k - 1
        }
        if (ierr == 0) {
            incg = SSSpecialFunctions.GammaHelper.incgam(a: mu, x: x1)
            p1 = incg.p
            ierr = incg.ierr
            S = S + p1
            p = S * expo
            q = 1 - p
        } else {
            ierr = 1
            p = 0
            q = 1
        }
    } else {
        h0 = SSMath.exp1(lh0)
        let temp: T = mu +  Helpers.makeFP(n)
        incg = SSSpecialFunctions.GammaHelper.incgam(a: temp, x: y)
        p = incg.p
        q = incg.q
        ierr = incg.ierr
        if (ierr == 0) {
            ex1 =  Helpers.makeFP(n) + T.one
            ex2 = SSSpecialFunctions.GammaHelper.loggam(ex1)
            ex3 = (ex1 - T.one) * SSMath.log1(x)
            ex4 = -x + ex3 - ex2
            ex5 = SSMath.exp1(ex4)
            p1 = p * ex5
            p = 0
            while (n > 0) {
                h0 = h0 *  Helpers.makeFP(n) * (mu +  Helpers.makeFP(n)) / xy
                p1 =  Helpers.makeFP(n) * p1 / x + h0
                p = p + p1
                n = n - 1
            }
            q = 1 - p
        } else {
            ierr = 1
            p = 0
            q = 1
        }
    }
}

fileprivate func prec<T: SSFloatingPoint>(_ mu: T, _ x: T, _ y:T , _ p: inout T, _ q: inout T, _ ierr: inout Int) {
    var b, nu, mur, cmu, xi, p0, p1: T
    var n1, n2, n3: Int
    ierr = 0
    b = 1
    var ex1: T
    var ex2: T
    var ex3: T
    var ex4: T
    var ex5: T
    var ex6: T
    ex3 = x + y
    ex4 = 2 * ex3
    ex5 = b * b
    ex6 = ex4 + ex5
    ex1 = b * sqrt(ex6)
    ex2 = b * b + b * ex1
    nu = y - x + ex2
    n1 = Helpers.integerValue(mu)
    n2 = Helpers.integerValue(nu) + 2
    n3 = n2 - n1
    mur = mu +  Helpers.makeFP(n3)
    xi = 2 * sqrt(x * y)
    cmu = sqrt(y / x) * fc(mur,xi)
    //    ! Numerical quadrature
    p1 = 0
    p0 = 0
    MarcumPQtrap(mur + 1,x,y,&p1,&q,&ierr)
    MarcumPQtrap(mur,x,y,&p0,&q,&ierr)
    if (ierr == 0) {
        for n in stride(from: 0, through: n3 - 1, by: 1) {
            p = ((1 + cmu) * p0 - p1) / cmu
            p1 = p0
            p0 = p
            ex1 = x * cmu
            ex2 = mur -  Helpers.makeFP(n)
            ex3 = ex2 - T.one + ex1
            cmu = y / ex3
        }
        q = 1 - p
    } else {
        p = 0
        q = 1
        ierr = 1
    }
}

fileprivate func qrec<T: SSFloatingPoint>(_ mu: T, _ x: T, _ y: T, _ p: inout T, _ q: inout T, _ ierr: inout Int) {
    var b, c, nu, mur, xi, q0, q1: T
    var ex1: T
    var ex2: T
    var ex3: T
    var ex4: T
    var ex5: T
    var cmu: Array<T> = Array<T>.init(repeating: 0, count: 301)
    var n1, n2, n3: Int
    ierr = 0
    b = 1
    ex1 = x + y
    ex2 = b * b
    ex3 = 2 * ex1 + ex2
    ex4 = sqrt(ex3)
    ex5 = b * ( b - ex4)
    nu = y - x + ex5
    if (nu < 5) {
        if (x < 200) {
            qser(mu, x, y, &p, &q, &ierr)
        } else {
            prec(mu, x, y, &p, &q, &ierr);
        }
    } else {
        n1 = Helpers.integerValue(mu)
        n2 = Helpers.integerValue(nu - 1)
        n3 = n1 - n2
        mur = mu -  Helpers.makeFP(n3)
        xi = 2 * sqrt(x * y)
        cmu[0] = sqrt(y / x) * fc(mu,xi)
        for n in stride(from: 1, through: n3, by: 1) {
            ex1 = mu - Helpers.makeFP(n)
            ex2 = ex1 + x * cmu[n-1]
            cmu[n] = y / ex2
        }
        //    ! Numerical quadrature
        q0 = 0
        q1 = 0
        MarcumPQtrap(mur - 1,x,y,&p,&q0,&ierr)
        MarcumPQtrap(mur,x,y,&p,&q1,&ierr)
        if (ierr == 0) {
            for n in stride(from: 1, through: n3, by: 1) {
                c = cmu[n3 + 1 - n]
                q = (1 + c) * q1 - c * q0
                q0 = q1
                q1 = q
            }
            p = 1 - q
        } else {
            q = 0
            p = 1
            ierr = 1
        }
    }
}

fileprivate func pqasyxy<T: SSFloatingPoint>(_ mu: T, _ x: T, _ y: T, _ p: inout T, _ q: inout T, _ ierr: inout Int) {
    //    ! ----------------------------------------------------------
    //    ! Computes P_{\mu}(x,y) and Q_{\mu}(x,y)
    //    ! using an asymptotic expansion for large xi.
    //        ! ----------------------------------------------------------
    var delta, c, psi, psi0, an, xi, sqxi, pq,rho, mulrho, rhom, rhop, sigmaxi, er, nu, mu2, rhomu, s, tnm1: T
    var phin: Array<T> = Array<T>.init(repeating: 0, count: 101)
    var bn: Array<T> = Array<T>.init(repeating: 0, count: 101)
    var n, n0, nrec, ierro: Int
    let dwarf = T.ulpOfOne * 10
    var ex1: T
    var ex2: T
    var ex3: T
    var ex4: T
    ierro = 0
    if (y >= x) {
        s = 1
    } else {
        s = -1
    }
    delta = epss() / 100
    xi = 2 * sqrt(x * y)
    sqxi = sqrt(xi)
    rho = sqrt(y / x)
    ex1 = y - x
    ex2 = ex1 * ex1
    ex3 = x + y
    ex4 = ex3 + xi
    sigmaxi = ex2 / ex4
    mulrho = mu * SSMath.log1(rho)
    if ((mulrho < SSMath.log1(dwarf)) || (mulrho > SSMath.log1(T.greatestFiniteMagnitude / 1000))) {
        if (s == 1) {
            q = 0
            p = 1
        } else {
            p = 0
            q = 1
        }
        ierro = 1
    } else {
        rhomu = SSMath.exp1(mulrho)
        er = errorfunction(sqrt(sigmaxi),true,true)
        psi0 = T.half * rhomu * er / sqrt(rho)
        nu = 2 * mu - 1
        rhom = nu * (rho - 1)
        rhop = 2 * (rho + 1)
        mu2 = 4 * mu * mu
        c = s * rhomu / sqrt(8 * T.pi)
        an = sqxi
        n = 0
        n0 = 100
        bn[0] = 1
        var ex1, ex2, ex3: T
        while ((abs(bn[n]) > delta) && (n < n0)) {
            n = n + 1
            tnm1 =  Helpers.makeFP(2 * n - 1)
            ex1 = mu2 - tnm1 * tnm1
            ex2 =  Helpers.makeFP(8.0) *  Helpers.makeFP(n) * xi
            ex3 = an / ex2
            an = ex1 * ex3
            ex1 = rhom -  Helpers.makeFP(n) * rhop
            ex2 = nu +  Helpers.makeFP(2 * n)
            ex3 = rho * ex2
            bn[n] = an * ex1 / (ex3)
        }
        n0 = n
        nrec = Helpers.integerValue(sigmaxi) + 1
        if (nrec > n0) {
            nrec=n0
        }
        let eps: T = epss()
        phin[nrec] = SSMath.exp1(( Helpers.makeFP(nrec) - T.half) * SSMath.log1(sigmaxi)) * ignega(nrec,sigmaxi,eps)
        for n in stride(from: nrec + 1, through: n0, by: 1) {
            ex1 = -sigmaxi * phin[n-1]
            ex2 = ex1 + T.one
            ex3 =  Helpers.makeFP(n) - T.half
            phin[n] = ex2 / ex3
        }
        for n in stride(from: nrec - 1, through: 1, by: -1) {
            ex1 = Helpers.makeFP(n) + T.half
            ex2 = ex1 * phin[n + 1]
            ex3 = T.one - ex2
            phin[n] = ex3 / sigmaxi
        }
        pq = psi0
        for n in stride(from: 1, through: n0, by: 1) {
            c = -c
            psi = c * bn[n] * phin[n];
            pq = pq + psi
        }
        pq = pq * SSMath.exp1(-sigmaxi)
        ierr = ierro
        if (s == 1) {
            q = pq
            p = 1 - q
        }
        else {
            p = pq
            q = 1 - p
        }
    }
}

fileprivate func pqasymu<T: SSFloatingPoint>(_ mu0: T, _ x0: T, _ y0: T, _ p: inout T, _ q: inout T, _ ierr: inout Int) {
    var mu, x, y, r, s, u, zeta, zetaj, bk, lexpor: T
    var ex1: T
    var ex2: T
    var ex3: T
    var muk: [T] = Array<T>.init(repeating: 0, count: 17)
    var psik: [T] = Array<T>.init(repeating: 0, count: 18)
    var fjk: [[T]] = Array<Array<T>>.init(repeating: Array<T>.init(repeating: 0, count: 17), count: 17)
    let dwarf = T.ulpOfOne * 10
    var a, b, k, t: Int
    ierr = 1
    mu = mu0 - 1
    x = x0 / mu
    y = y0 / mu
    zeta = zetaxy(&x,&y)
    if (zeta < 0) {
        a = 1
    } else {
        a = -1
    }
    u = 1 / sqrt(2 * x + 1)
    fjkproc16(u, &fjk)
    zeta =  Helpers.makeFP(a) * zeta
    r = zeta * sqrt(mu / 2)
    psik[1] = sqrt(T.pi / (2 * mu)) * errorfunction(-r,true,false)
    s = psik[1]
    lexpor = -mu * T.half * zeta * zeta
    if ((lexpor < SSMath.log1(dwarf)) || (lexpor > SSMath.log1(T.greatestFiniteMagnitude / 1000))) {
        if (a == 1) {
            q = 0
            p = 1
        }
        else {
            p = 0
            q = 1
        }
        ierr = 1
    } else {
        r = SSMath.exp1(lexpor)
        psik[0] = T.zero
        muk[0] = 1
        bk = s
        k = 1
        zetaj = 1
        while ((abs(bk / s) >  Helpers.makeFP(1e-30)) && (k <= 16)) {
            muk[k] = mu * muk[k-1]
            ex1 =  Helpers.makeFP(k - 1)
            ex2 = ex1 * psik[k - 1]
            ex3 = ex2 + r * zetaj
            psik[k + 1] = ex3 / mu
            bk = 0; b = 1; zetaj = -zeta * zetaj
            for j in stride(from: 0, through: k, by: 1) {
                //            for (j=0;j<=k;j++) {
                if ((a == -1) && (b == -1)) {
                    t = -1
                } else {
                    t = 1
                }
                b = -b
                bk = bk +  Helpers.makeFP(t) * fjk[j][k-j] * psik[j+1] / muk[k-j]
            }
            s = s + bk
            k = k + 1
        }
        r = sqrt(mu / ( Helpers.makeFP(2.08) * T.pi)) * s
        if (a == 1) {
            q = r
            p = 1 - q
        }
        else {
            p = r
            q = 1 - p
        }
    }
}


fileprivate func MarcumPQtrap<T: SSFloatingPoint>(_ mu: T,_ x: T,_ y: T,_ p: inout T,_ q: inout T,_ ierr: inout Int) {
    //!---------------------------------------------------------------
    //! Computes the P and Q using an integral representation which
    //! is approximated using the trapezoidal rule
    //!---------------------------------------------------------------
    var ex1: T
    var ex2: T
    var ex3: T
    var ex4: T
    let dwarf: T = T.ulpOfOne * 10
    var pq, a, b, zeta, epstrap, xs, ys, xis2, wxis: T
    xs = x / mu
    ys = y / mu
    xis2 = 4 * xs * ys
    wxis = sqrt(1 + xis2)
    a = 0
    b = 3
    epstrap =  Helpers.makeFP(1.0e-13)
    pq = trap(a, b, epstrap, xis2, mu, wxis, ys)
    zeta = zetaxy(&xs, &ys)
    ex1 = zeta * zeta
    ex2 = ex1 * T.half
    ex3 = -mu * ex2
    if (ex3 < SSMath.log1(dwarf)) {
        if (y > (x + mu)) {
            p = 1
            q = 0
        }
        else {
            p = 0
            q = 1
        }
        ierr = 1
    }
    else {
        ex1 = -mu * T.half
        ex2 = zeta * zeta
        ex3 = ex1 * ex2
        ex4 = SSMath.exp1(ex3) / T.pi
        pq = pq * ex4
        if (zeta < 0) {
            q = pq
            p = 1 - q
        }
        else {
            p = -pq
            q = 1 - p
        }
    }
}

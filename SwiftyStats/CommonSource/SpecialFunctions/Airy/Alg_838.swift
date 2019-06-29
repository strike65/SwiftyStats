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

internal class Airy<T: SSFloatingPoint>: NSObject {

    private var iflag: Int
    private var iregion: Int
    private var vars: AiryVariables<T>!
    override init() {
        vars = AiryVariables.init()
        iflag = 0
        iregion = 0
    }
    
    internal func airy_bir(x: T) -> (bi: T, dbi: T, error: Int) {
        var nn: Int
        var Pxi, Qxi, Rxi, Sxi, bi0s, bi1s, a, b: T
        var bi, dbi: T
        var err: Int
        var tsm: Array<Array<T>> = Array<Array<T>>.init(repeating: Array<T>.init(repeating: 0, count: 2), count: 2)
        iflag = 0
        vars.r_global = abs(x)
        vars.x_global = x
        bi0s = 0
        bi1s = 0
        flows()
        var ex1: T
        var ex2: T
        var ex3: T
        if iflag == 0 {
            vars.xi_global = T.twothirds * vars.r_global * sqrt(vars.r_global)
            iregion = 0
            if (vars.r_global >= vars.r_min) {
                if (vars.x_global > T.zero) {
                    iregion = 1
                }
                else {
                    iregion = 2
                }
            }
            else {
                iregion = 3
            }
            switch iregion {
            case 1:
                bi0s = SSMath.pow1(vars.x_global, T.fourth)
                bi1s = 0
                a = 1 / (T.sqrtpi * bi0s)
                b = bi0s / T.sqrtpi
                asymp1r(F1: &bi0s, F2: &bi1s)
                bi0s = a * bi0s
                bi1s = b * bi1s
                bi0s = SSMath.exp1(vars.xi_global) * bi0s
                bi1s = SSMath.exp1(vars.xi_global) * bi1s
            case 2:
                bi1s = SSMath.pow1(vars.r_global, T.fourth)             /* dummy storage of number */
                bi0s = vars.xi_global - T.pi * T.fourth
                a = 1 / (T.sqrtpi * bi1s)
                b = bi1s / T.sqrtpi
                Rxi = 0
                Sxi = 0
                Qxi = 0
                Pxi = 0
                asymp2r(Pxi: &Pxi, Qxi: &Qxi, Rxi: &Rxi, Sxi: &Sxi)
                bi1s = vars.xi_global - T.pi * T.fourth
                ex1 = -Pxi * SSMath.sin1(bi1s)
                ex2 = Qxi * SSMath.cos1(bi1s)
                ex3 = ex1 + ex2
                bi0s = a * ex3
                ex1 = Rxi * SSMath.cos1(bi1s)
                ex2 = Sxi * SSMath.sin1(bi1s)
                ex3 = ex1 + ex2
                bi1s = b * ex3
            case 3:
                nn = Helpers.integerValue(ceil( Helpers.makeFP(vars.n_parts) * vars.r_global / vars.r_min))
                taylorr(nn: nn, x_start: 0, tsm: &tsm)
                bi0s = tsm[0][0] * bi0zer() + tsm[0][1] * bi1zer()
                bi1s = tsm[1][0] * bi0zer() + tsm[1][1] * bi1zer()
            default:
                bi0s = T.zero
                bi1s = T.zero
                iflag = -100
            }
        }
        switch iflag {
        case -10..<(-1):
            bi  = 0
	        dbi = 0
            err = iflag
        case 0...2:
            bi  = bi0s
            dbi = bi1s
            err = 0
        case 5:
            bi  = bi0zer()
            dbi = bi1zer()
	        err = 0
        default:
            bi  = 0
            dbi = 0
            err = 0
        }
        return (bi: bi, dbi: dbi, error: err)
    }
    
    internal func airy_air(x: T) -> (ai: T, dai: T, error: Int) {
        var nn: Int
        var Pxi, Qxi, Rxi, Sxi, ai0s, ai1s, a, b, xi0: T
        var ai, dai: T
        var err: Int
        var tsm: Array<Array<T>> = Array<Array<T>>.init(repeating: Array<T>.init(repeating: 0, count: 2), count: 2)
        iflag = 0
        vars.r_global = abs(x)
        vars.x_global = x
        if vars.x_global < 0 {
            err = -1
        }
        ai0s = 0
        ai1s = 0
        flows()
        var ex1: T
        var ex2: T
        var ex3: T
        if iflag == 0 {
            vars.xi_global = T.twothirds * vars.r_global * sqrt(vars.r_global)
            iregion = 0
            if vars.r_global >= vars.r_min {
                if vars.x_global > T.zero {
                    iregion = 1
                }
                else {
                    iregion = 2
                }
            }
            else if vars.x_global > T.zero {
                iregion = 3
            }
            else {
                iregion = 4
            }
            switch iregion {
            case 1:
                ai1s = 2 * T.sqrtpi
                ai0s = SSMath.pow1(vars.x_global, T.fourth)
                a = 1 / (ai1s * ai0s)
                b = -ai0s / ai1s
                iflag = 10
                asymp1r(F1: &ai0s, F2: &ai1s)
                ai0s = a * ai0s
                ai1s = b * ai1s
                ai0s = SSMath.exp1(-vars.xi_global) * ai0s
                ai1s = SSMath.exp1(-vars.xi_global) * ai1s
            case 2:
                ai1s = SSMath.pow1(vars.r_global, T.fourth)
                a = 1 / (T.sqrtpi * ai1s)
                b = ai1s / T.sqrtpi
                Rxi = 0
                Sxi = 0
                Qxi = 0
                Pxi = 0
                asymp2r(Pxi: &Pxi, Qxi: &Qxi, Rxi: &Rxi, Sxi: &Sxi)
                ai1s = vars.xi_global - T.pifourth
                ex1 = Pxi * SSMath.cos1(ai1s)
                ex2 = Qxi * SSMath.sin1(ai1s)
                ex3 = ex1 + ex2
                ai0s = a * ex3
                ex1 = Rxi * SSMath.sin1(ai1s)
                ex2 = Sxi * SSMath.cos1(ai1s)
                ex3 = ex1 - ex2
                ai1s = b * ex3
            case 3:
                ex1 = (T.one - vars.r_global / vars.r_min)
                ex2 =  Helpers.makeFP(vars.n_parts)
                ex3 = ex2 / ex1
                nn = Helpers.integerValue(ceil(ex3))
                ai1s = T.twosqrtpi
                ai0s = SSMath.pow1(vars.r_min, T.fourth)
                a = 1 / (ai1s * ai0s)
                b = -ai0s / ai1s
                xi0 = T.twothirds * vars.r_min * sqrt(vars.r_min)
                iflag = 10
                asymp1r(F1: &ai0s, F2: &ai1s, x_in: xi0)
                taylorr(nn: nn, x_start: vars.r_min, tsm: &tsm)
                a = a * SSMath.exp1(-xi0) * ai0s
                b = b * SSMath.exp1(-xi0) * ai1s
                ai0s = tsm[0][0] * a + tsm[0][1] * b
                ai1s = tsm[1][0] * a + tsm[1][1] * b
                /*
                 if (mod_local) then
                 ai0s  = exp(xi_global)*ai0s
                 ai1s  = exp(xi_global)*ai1s
                 end if
                 */
            case 4:
                nn = Helpers.integerValue(ceil( Helpers.makeFP(vars.n_parts) * vars.r_global / vars.r_min))
                taylorr(nn: nn, x_start: T.zero, tsm: &tsm)
                ai0s = tsm[0][0] * ai0zer() + tsm[0][1] * ai1zer()
                ai1s = tsm[1][0] * ai0zer() + tsm[1][1] * ai1zer()
            default:
                ai0s = T.zero
                ai1s = T.zero
                iflag = -100
            }
        }
        switch iflag {
        case -10..<(-1):
            ai = T.zero
            dai = T.zero
            err = iflag
        case 0...2:
            ai = ai0s
            dai = ai1s
            err = 0
        case 5:
            ai = ai0zer()
            dai = ai1zer()
            err = 0
        default:
            ai = T.zero
            dai = T.zero
            err = iflag
        }
        return (ai: ai, dai: dai, error: err)
    }

    private func flows() {
        var tol: T
        var e1, e2, e3, e4: T
        if vars.r_global >= vars.r_uplimit {
            iflag = -6
            return
        }
        if vars.r_global <= vars.r_lolimit {
            iflag = 5
            return
        }
        if vars.x_global > T.zero {
            e1 = -SSMath.log1(T.twosqrtpi * SSMath.pow1(vars.r_global, T.fourth)) - SSMath.log1(T.leastNormalMagnitude)
            e2 = -SSMath.log1(T.twosqrtpi / SSMath.pow1(vars.r_global, T.fourth)) - SSMath.log1(T.leastNormalMagnitude)
            e3 = SSMath.log1(T.twosqrtpi / SSMath.pow1(vars.r_global, T.fourth)) + SSMath.log1(T.greatestFiniteMagnitude)
            e4 = SSMath.log1(T.twosqrtpi * SSMath.pow1(vars.r_global, T.fourth)) + SSMath.log1(T.greatestFiniteMagnitude)
            tol = min( e1,e2,e3,e4) - 15
            if vars.r_global >= ( Helpers.makeFP(1.5) * SSMath.pow1(tol, T.twothirds)) {
                iflag = -7
                return
            }
        }
    }
    
    private func asymp1r(F1: inout T, F2: inout T, x_in: T? = nil) {
        var xir: T
        F1 = vars.ucoef[vars.n_asymp - 1]
        F2 = vars.vcoef[vars.n_asymp - 1]
        if x_in != nil {
            xir = 1 / x_in!
        }
        else {
            xir = 1 / vars.xi_global
        }
        if iflag == 10 {
            xir = -xir
        }
        for i in stride(from: vars.n_asymp - 2, through: 0, by: -1) {
            F1 = vars.ucoef[i] + xir * F1
            F2 = vars.vcoef[i] + xir * F2
        }
        F1 = 1 + xir * F1
        F2 = 1 + xir * F2
        iflag = 0
    }

    private func asymp2r(Pxi: inout T, Qxi: inout T, Rxi: inout T, Sxi: inout T) {
        var xir: T
        var itemp: Int = Helpers.integerValue(floor(T.half *  Helpers.makeFP(vars.n_asymp) - T.half))
        if itemp % 2 != 0 {
            itemp = itemp - 1
        }
        Pxi = vars.ucoef[itemp - 1]
        Qxi = vars.ucoef[itemp - 2]
        Rxi = vars.vcoef[itemp - 1]
        Sxi = vars.vcoef[itemp - 2]
        xir = 1 / SSMath.pow1(vars.xi_global, 2)
        for i in stride(from: itemp - 3, through: 1, by: -2) {
            Pxi = (vars.ucoef[i] - xir * Pxi)
            Rxi = (vars.vcoef[i] - xir * Rxi)
            Qxi = (vars.ucoef[i - 1] - xir * Qxi)
            Sxi = (vars.vcoef[i - 1] - xir * Sxi)
        }
        Pxi = 1 - xir * Pxi
        Rxi = 1 - xir * Rxi
        Qxi = Qxi / vars.xi_global
        Sxi = Sxi / vars.xi_global
        iflag = 0
    }

    private func taylorr(nn: Int, x_start: T, tsm: inout Array<Array<T>>) {
        var ifl, jfl: T
        var h, xm: T
        var pterm: Array<T> = Array<T>.init(repeating: 0, count: vars.n_taylor + 1)
        var qterm: Array<T> = Array<T>.init(repeating: 0, count: vars.n_taylor + 1)
        
        var Phi: Array<Array<Array<T>>> = Array<Array<Array<T>>>.init(repeating: Array<Array<T>>.init(repeating: Array<T>.init(repeating: 0, count: 2), count: 2), count: nn)
        h = (vars.x_global - x_start) /  Helpers.makeFP(nn)
        var ex1: T
        var ex2: T
        var ex3: T
        for i in stride(from: 1, through: nn, by: 1) {
            ifl =  Helpers.makeFP(i)
            xm = (x_start + h * (ifl - 1))
            pterm[0] = 1
            pterm[1] = T.zero
            pterm[2] = xm * pterm[0] * T.half
            qterm[0] = T.zero
            qterm[1] = 1
            qterm[2] = T.zero
            for j in stride(from: 3, through: vars.n_taylor, by: 1) {
                jfl =  Helpers.makeFP(j)
                ex1 = jfl * jfl - jfl
                ex2 = xm * pterm[j - 2]
                ex3 = ex2 + pterm[j - 3]
                pterm[j] = ex3 / ex1
                ex1 = jfl * jfl - jfl
                ex2 = xm * qterm[j - 2]
                ex3 = ex2 + qterm[j - 3]
                qterm[j] = ex3 / ex1
            }
            Phi[i - 1][0][0] = pterm[vars.n_taylor]
            Phi[i - 1][1][0] = pterm[vars.n_taylor] *  Helpers.makeFP(vars.n_taylor)
            Phi[i - 1][0][1] = qterm[vars.n_taylor]
            Phi[i - 1][1][1] = qterm[vars.n_taylor] *  Helpers.makeFP(vars.n_taylor)
            for j in stride(from: vars.n_taylor - 1, through: 1, by: -1) {
                jfl =  Helpers.makeFP(j)
                Phi[i - 1][0][0] = pterm[j] + h * Phi[i - 1][0][0]
                Phi[i - 1][1][0] = pterm[j] * jfl + h * Phi[i - 1][1][0]
                Phi[i - 1][0][1] = qterm[j] + h * Phi[i - 1][0][1]
                Phi[i - 1][1][1] = qterm[j] * jfl + h * Phi[i - 1][1][1]
            }
            Phi[i - 1][0][0] = pterm[0] + h * Phi[i - 1][0][0]
            Phi[i - 1][0][1] = qterm[0] + h * Phi[i - 1][0][1]
        }
        for i in stride(from: 0, to: nn - 1, by: 1) {
            Phi[i + 1] = matmul(matA: Phi[i + 1], aRows: 2, aCols: 2, matB: Phi[i], bRows: 2, bCols: 2)
        }
        tsm = Phi.last!
    }
    
    private func matmul<T: FloatingPoint>(matA: Array<Array<T>>, aRows m: Int, aCols n: Int, matB: Array<Array<T>>, bRows p: Int, bCols q: Int) -> Array<Array<T>> {
        if n != p {
            fatalError()
        }
        var sum: T = 0
        var C: Array<Array<T>> = Array<Array<T>>.init(repeating: Array<T>.init(repeating: 0, count: q), count: m)
        for c in stride(from: 0, to: m, by: 1) {
            for d in stride(from: 0, to: q, by: 1) {
                for k in stride(from: 0, to: p, by: 1) {
                    sum = sum + matA[c][k] * matB[k][d]
                }
                C[c][d] = sum
                sum = 0
            }
        }
        return C
    }

}

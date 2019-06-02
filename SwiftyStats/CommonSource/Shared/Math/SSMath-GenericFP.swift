//
//  Created by VT on 04.08.18.
//  Copyright © 2018 strike65. All rights reserved.
//
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
import Darwin
import Accelerate.vecLib


internal func hypot1<T: SSFloatingPoint>(_ x: T, _ y: T) -> T {
    switch x {
    case let d as Double:
        return hypot(d, y as! Double) as Double as! T
    case let f as Float:
        return hypotf(f, y as! Float) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return hypotl(f80, y as! Float80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}


internal func tgamma1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return tgamma(d) as Double as! T
    case let f as Float:
        return tgammaf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return tgammal(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func lgamma1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return lgamma(d) as Double as! T
    case let f as Float:
        return lgammaf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return lgammal(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func exp1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return exp(d) as Double as! T
    case let f as Float:
        return expf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return expl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func log1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return log(d) as Double as! T
    case let f as Float:
        return logf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return logl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func log21<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return log2(d) as Double as! T
    case let f as Float:
        return log2f(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return log2l(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func log101<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return log10(d) as Double as! T
    case let f as Float:
        return log10f(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return log10l(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}



internal func log1p1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return log1p(d) as Double as! T
    case let f as Float:
        return log1pf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return log1pl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func expm11<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return expm1(d) as Double as! T
    case let f as Float:
        return expm1(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return expm1(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func pow1<T: SSFloatingPoint>(_ x: T, _ e: T) -> T {
    switch x {
    case let d as Double:
        return pow(d, e as! Double) as Double as! T
    case let f as Float:
        return powf(f, e as! Float) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return powl(f80, e as! Float80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func erfc1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return erfc(d) as Double as! T
    case let f as Float:
        return erfcf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return erfcl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func erf1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return erf(d) as Double as! T
    case let f as Float:
        return erff(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return erfl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}


internal func sign1<T: SSFloatingPoint>(_ x: T) -> T {
    return x < 0 ? -1 : 1
}

internal func sin1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        if isInteger(d / Double.pi) {
            return T.zero
        }
        else {
            return sin(d) as Double as! T
        }
    case let f as Float:
        if isInteger(f / Float.pi) {
            return T.zero
        }
        else {
            return sinf(f) as Float as! T
        }
        #if arch(x86_64)
    case let f80 as Float80:
        if isInteger(f80 / Float80.pi) {
            return T.zero
        }
        else {
            return sinl(f80) as Float80 as! T
        }
        #endif
    default:
        return T.nan
    }
}

internal func sinh1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return sinh(d) as Double as! T
    case let f as Float:
        return sinhf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return sinhl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}


internal func cosh1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return cosh(d) as Double as! T
    case let f as Float:
        return coshf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return coshl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func cos1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return cos(d) as Double as! T
    case let f as Float:
        return cosf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return cosl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func tan1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return tan(d) as Double as! T
    case let f as Float:
        return tanf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return tanl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}
internal func tanh1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return tanh(d) as Double as! T
    case let f as Float:
        return tanhf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return tanhl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}
internal func cot1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return 1.0 / tan(d) as Double as! T
    case let f as Float:
        return 1.0 / tanf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return 1.0 / tanl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func acos1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return acos(d) as Double as! T
    case let f as Float:
        return acosf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return acosl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}


internal func asin1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return asin(d) as Double as! T
    case let f as Float:
        return asinf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return asinl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}


internal func atan1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return atan(d) as Double as! T
    case let f as Float:
        return atanf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return atanl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func atan21<T: SSFloatingPoint>(_ x: T, _ y: T) -> T {
    switch x {
    case let d as Double:
        switch y {
        case let yd as Double:
            return atan2(d, yd) as Double as! T
        default:
            return T.nan
        }
    case let f as Float:
        switch y {
        case let yf as Float:
            return atan2f(f, yf) as Float as! T
        default:
            return T.nan
        }
        #if arch(x86_64)
    case let f80 as Float80:
        switch y {
        case let yf80 as Float80:
            return atan2l(f80, yf80) as Float80 as! T
        default:
            return T.nan
        }
        #endif
    default:
        return T.nan
    }
}

internal func sign<T: SSFloatingPoint>(_ x: T) -> T {
    var ans: T
    if x.sign == .minus {
        ans = makeFP(-1)
    }
    else {
        ans = makeFP(1)
    }
    return ans
}


internal func sign<T: SignedInteger, FPT: SSFloatingPoint>(_ n: T) -> FPT {
    let ans: FPT = makeFP(n.signum())
    return ans
}

internal func fmin1<T: SSFloatingPoint>(_ x: T, _ y: T) -> T {
    switch x {
    case let d as Double:
        switch y {
        case let yd as Double:
            return fmin(d, yd) as Double as! T
        default:
            return T.nan
        }
    case let f as Float:
        switch y {
        case let yf as Float:
            return fminf(f, yf) as Float as! T
        default:
            return T.nan
        }
        #if arch(x86_64)
    case let f80 as Float80:
        switch y {
        case let yf80 as Float80:
            return fminl(f80, yf80) as Float80 as! T
        default:
            return T.nan
        }
        #endif
    default:
        return T.nan
    }
}


// Matrix

internal func matAdd<FPT: SSFloatingPoint & Codable>(a: Array<FPT>, b: Array<FPT>) -> Array<FPT> {
    if a.count !=  b.count {
        fatalError()
    }
    var c = Array<FPT>.init(repeating: 0, count: a.count)
    for i in stride(from: 0, to: a.count, by: 1) {
        c[i] = a[i] + b[i]
    }
    return c
}

// Row first order
// ROW1 = [Item1, Item2, Item2, Item4 ... ItemN]
// ROW2 = [Item1, Item2, Item2, Item4 ... ItemN]
// ROW3 = [Item1, Item2, Item2, Item4 ... ItemN]
// ROW4 = [Item1, Item2, Item2, Item4 ... ItemN]
// MATRIX = [ROW1, ROW2, ROW3, ROW4]
internal func matMulScalar<FPT: SSFloatingPoint & Codable>(A: inout Array<FPT>, alpha: FPT) {
    for i in stride(from: 0, to: A.count, by: 1) {
        A[i] = alpha * A[i]
    }
}



enum CgemmError: Error {
    case unknownOperation
}

internal func ddgemm<FPT: SSFloatingPoint>(Order: CBLAS_ORDER, TransA: CBLAS_TRANSPOSE, TransB: CBLAS_TRANSPOSE, M: Int, N: Int, K: Int, alpha: FPT, A: Array<FPT>, lda: Int, B: Array<FPT>, ldb: Int, beta: FPT, C: inout Array<FPT>, ldc: Int) throws {
    if alpha.isZero && beta.isZero {
        return
    }
    var TransG, TransF: CBLAS_TRANSPOSE
    var n1, n2, ldf, ldg: Int
    var F, G: Array<FPT>
    if Order == CblasRowMajor {
        n1 = M
        n2 = N
        F = A
        ldf = lda
        TransF = (TransA == CblasConjTrans) ? CblasTrans : TransA
        G = B
        ldg = ldb
        TransG = (TransB == CblasConjTrans) ? CblasTrans : TransB
    }
    else {
        n1 = N
        n2 = M
        F = B
        ldf = ldb
        TransF = (TransA == CblasConjTrans) ? CblasTrans : TransA
        G = A
        ldg = lda
        TransG = (TransB == CblasConjTrans) ? CblasTrans : TransB
    }
    
    if beta.isZero {
        for i in stride(from: 0, to: n1, by: 1) {
            for j in stride(from: 0, to: n2, by: 1) {
                C[ldc * i + j] = 0
            }
        }
    }
    else if beta != 1 {
        for i in stride(from: 0, to: n1, by: 1) {
            for j in stride(from: 0, to: n2, by: 1) {
                C[ldc * i + j] *= beta
            }
        }
    }
    
    if alpha.isZero {
        return
    }
    
    if (TransF == CblasNoTrans && TransG == CblasNoTrans) {
        
        /* form  C := alpha*A*B + C */
        for k in stride(from: 0, to: K, by: 1) {
            for i in stride(from: 0, to: n1, by: 1) {
                let temp: FPT = alpha * F[ldf * i + k]
                if (!temp.isZero) {
                    for j in stride(from: 0, to: n2, by: 1) {
                        C[ldc * i + j] += temp * G[ldg * k + j]
                    }
                }
            }
        }
        
    } else if (TransF == CblasNoTrans && TransG == CblasTrans) {
        
        /* form  C := alpha*A*B' + C */
        for i in stride(from: 0, to: n1, by: 1) {
            for j in stride(from: 0, to: n2, by: 1) {
                var temp: FPT = 0
                for k in stride(from: 0, to: K, by: 1) {
                    temp += F[ldf * i + k] * G[ldg * j + k]
                }
                C[ldc * i + j] += alpha * temp
            }
        }
        
    } else if (TransF == CblasTrans && TransG == CblasNoTrans) {
        
        for k in stride(from: 0, to: K, by: 1) {
            for i in stride(from: 0, to: n1, by: 1) {
                let temp: FPT = alpha * F[ldf * k + i]
                if (!temp.isZero) {
                    for j in stride(from: 0, to: n2, by: 1) {
                        C[ldc * i + j] += temp * G[ldg * k + j]
                    }
                }
            }
        }
        
    } else if (TransF == CblasTrans && TransG == CblasTrans) {
        
        for i in stride(from: 0, to: n1, by: 1) {
            //        for (i = 0; i < n1; i++) {
            for j in stride(from: 0, to: n2, by: 1) {
                //            for (j = 0; j < n2; j++) {
                var temp: FPT = 0
                for k in stride(from: 0, to: K, by: 1) {
                    //                for (k = 0; k < K; k++) {
                    temp += F[ldf * k + i] * G[ldg * j + k]
                }
                C[ldc * i + j] += alpha * temp
            }
        }
    } else {
        throw CgemmError.unknownOperation
    }
    
}

internal func matMul<FPT: SSFloatingPoint>(a: Array<FPT>, aCols: Int, aRows: Int, b: Array<FPT>, bCols: Int, bRows: Int) -> Array<FPT> {
    var c: Array<FPT> = Array<FPT>.init(repeating: 0, count: aRows * bCols)
    try! ddgemm(Order: CblasRowMajor, TransA: CblasNoTrans, TransB: CblasNoTrans, M: aRows, N: bCols, K: aCols, alpha: 1, A: a, lda: aCols, B: b, ldb: aCols, beta: 0, C: &c, ldc: bCols)
    return c
}


/// Binomial
internal func binomial2<FPT: SSFloatingPoint>(_ n: FPT, _ k: FPT) -> FPT {
    var ans: UInt64 = 1
    var kk: UInt64 = integerValue(k)
    var nn: UInt64 = integerValue(n)
    var overflow: Bool = false
    var ex1: (UInt64, Bool) = (0, false)
    var ex2: (UInt64, Bool) = (0, false)
    kk = k > n - k ? nn - kk : kk
    for j: UInt64 in stride(from: 1, through: kk, by: 1) {
        if nn % j == 0 {
            ex1 = nn.dividedReportingOverflow(by: j)
            if ex1.1 {
                overflow = true
                break
            }
            ex2 = ans.multipliedReportingOverflow(by: ex1.0)
            if ex2.1 {
                overflow = true
                break
            }
            ans = ex2.0
        }
        else {
            if ans % j == 0 {
                ex1 = ans.dividedReportingOverflow(by: j)
                if ex1.1 {
                    overflow = true
                    break
                }
                ans = ex1.0
                ex2 = ans.multipliedReportingOverflow(by: nn)
                if ex2.1 {
                    overflow = true
                    break
                }
                ans = ex2.0
            }
            else {
                ex1 = ans.multipliedReportingOverflow(by: nn)
                if ex1.1 {
                    overflow = true
                    break
                }
                ans = ex1.0
                ex2 = ans.dividedReportingOverflow(by: j)
                if ex2.1 {
                    overflow = true
                    break
                }
                ans = ex2.0
            }
        }
        nn = nn - 1
    }
    if !overflow {
        return makeFP(ans)
    }
    else {
        let num: FPT = lgamma1(makeFP(n) + 1)
        let den: FPT = lgamma1(makeFP(n - k + 1)) + lgamma1(makeFP(k + 1))
        let q: FPT = num - den
        return exp1(q).rounded(FloatingPointRoundingRule.toNearestOrAwayFromZero)

    }
}

    /// Returns the logarithm of n!
internal func logFactorial<FPT: SSFloatingPoint>(_ n: Int) -> FPT {
        return lgamma1(makeFP(n + 1))
}



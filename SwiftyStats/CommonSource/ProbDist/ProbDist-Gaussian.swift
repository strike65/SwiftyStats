//
//  swift
//  SwiftyStats
//
//  Created by strike65 on 18.07.17.
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
#if os(macOS) || os(iOS)
import os.log
#endif

extension SSProbDist {
    /// Gaussian distribution
    public enum Gaussian {
        
        /// Returns a SSProbDistParams struct containing mean, variance, kurtosis and skewness of the Gaussian distribution.
        /// - Parameter m: Mean
        /// - Parameter sd: Standard deviation
        /// - Throws: SSSwiftyStatsError if df <= 0
        public static func para<FPT: SSFloatingPoint & Codable>(mean m: FPT, standardDeviation s: FPT) -> SSProbDistParams<FPT>? {
            var result: SSProbDistParams<FPT> = SSProbDistParams<FPT>()
            result.mean = m
            result.variance = SSMath.pow1(s, 2)
            result.skewness = 0
            result.kurtosis = 3
            return result
        }
        
        /// Returns the CDF of a Gaussian distribution
        /// <img src="../img/Gaussian_def.png" alt="">
        /// - Parameter x: x
        /// - Parameter m: Mean
        /// - Parameter sd: Standard deviation
        /// - Throws: SSSwiftyStatsError if sd <= 0.0
        public static func cdf<FPT: SSFloatingPoint & Codable>(x: FPT, mean m: FPT, standardDeviation sd: FPT) throws -> FPT {
            if sd <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("sd is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            let n: FPT = FPT.half * SSMath.erfc1((m - x) / (FPT.sqrt2 * sd))
            return n
        }
        
        /// Returns the CDF of a Gaussian distribution
        /// - Parameter x: x
        /// - Parameter m: Mean
        /// - Parameter v: Variance
        /// - Throws: SSSwiftyStatsError if v <= 0.0
        public static func cdf<FPT: SSFloatingPoint & Codable>(x: FPT, mean m: FPT, variance v: FPT) throws -> FPT {
            if v <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("v is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            ex1 = m - x
            ex2 = FPT.sqrt2 * sqrt(v)
            ex3 = ex1 / ex2
            let n: FPT =  FPT.half * SSMath.erfc1(ex3)
            return n
        }
        
        /// Returns the PDF of a Gaussian distribution
        /// - Parameter m: Mean
        /// - Parameter sd: Standard deviation
        /// - Throws: SSSwiftyStatsError if sd <= 0.0
        public static func pdf<FPT: SSFloatingPoint & Codable>(x: FPT, mean m: FPT, standardDeviation sd: FPT) throws -> FPT  {
            if sd <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("sd is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            let e1: FPT = FPT.one / (sd * FPT.sqrt2pi)
            let e2: FPT = FPT.minusOne * SSMath.pow1(x - m, 2)
            let e3: FPT = 2 * SSMath.pow1(sd, 2)
            let e4: FPT = SSMath.exp1(e2 / e3)
            let pdf: FPT = e1 * e4
            return pdf
        }
        
        /// Returns the PDF of a Gaussian distribution
        /// - Parameter x: x
        /// - Parameter m: Mean
        /// - Parameter v: Variance
        /// - Throws: SSSwiftyStatsError if v <= 0.0
        public static func pdf<FPT: SSFloatingPoint & Codable>(x: FPT, mean m: FPT, variance v: FPT) throws -> FPT  {
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            var ex4: FPT
            if v <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("v is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            let expr1:FPT = v.squareRoot() * FPT.sqrt2pi
            ex1 = x - m
            ex2 = FPT.minusOne * SSMath.pow1(ex1, 2)
            ex3 = 2 * v
            ex4 = ex2 / ex3
            let pdf: FPT = SSMath.reciprocal(expr1) * SSMath.exp1(ex4)
            return pdf
        }
        
        /// Returns the quantile function of a Gaussian distribution
        /// - Parameter p: p
        /// - Parameter m: Mean
        /// - Parameter sd: Standard deviation
        /// - Throws: SSSwiftyStatsError if sd <= 0.0
        public static func quantile<FPT: SSFloatingPoint & Codable>(p: FPT, mean m: FPT, standardDeviation sd: FPT) throws -> FPT {
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            var ex4: FPT
            if sd <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("sd is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if p < 0 {
                return -FPT.infinity
            }
            if p > 1 {
                return FPT.infinity
            }
            do {
                ex1 = 2 * p
                ex2 = FPT.minusOne + ex1
                ex3 = try sd * inverf(z: ex2)
                ex4 = FPT.sqrt2 * ex3
                return m + ex4
            }
            catch {
                return FPT.nan
            }
        }
        
        /// Returns the quantile function of a Gaussian distribution
        /// - Parameter p: p
        /// - Parameter m: Mean
        /// - Parameter v: Variance
        /// - Throws: SSSwiftyStatsError if v <= 0.0
        public static func quantile<FPT: SSFloatingPoint & Codable>(p: FPT, mean m: FPT, variance v: FPT) throws -> FPT {
            if v <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("v is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if p < 0 {
                return -FPT.infinity
            }
            if p > 1 {
                return FPT.infinity
            }
            do {
                return try quantile(p:p, mean:m, standardDeviation: v.squareRoot())
            }
            catch {
                return FPT.nan
            }
        }
    }
}
extension SSProbDist {
    /// Standard Gaussian distribution
    public enum StandardNormal {
        /// Returns the CDF of the standard Gaussian distribution (mean = 0.0, standard deviation = 1.0)
        /// - Parameter u: Standardized variate (u = (x - mean)/sd)
        public static func cdf<FPT: SSFloatingPoint & Codable>(u: FPT) -> FPT {
            return  Helpers.makeFP(1.0 / 2.0 ) * SSMath.erfc1(-u / FPT.sqrt2)
        }
        
        
        
        /// Returns the PDF of the standard Gaussian distribution (mean = 0.0, standard deviation = 1.0)
        /// - Parameter u: Standardized variate (u = (x - mean)/sd)
        public static func pdf<FPT: SSFloatingPoint & Codable>(u: FPT!) -> FPT {
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            ex1 = FPT.minusOne * u
            ex2 = ex1 * u
            ex3 = ex2 / 2
            return FPT.sqrt2piinv * SSMath.exp1(ex3)
        }
        
        /// Returns the quantile function of the standard Gaussian distribution. Uses algorithm AS241 at
        /// http://lib.stat.cmu.edu/apstat/241 (ALGORITHM AS241  APPL. STATIST. (1988) VOL. 37, NO. 3, 477-484.)
        /// - Parameter p: P
        /// - Throws: SSSwiftyStatsError if p < 0.0 or p > 1
        public static func quantile<T: SSFloatingPoint & Codable>(p: T) throws -> T {
            if p.isZero {
                return -T.infinity
            }
            if p == 1 {
                return T.infinity
            }
            if ((p < 0) || (p > 1)) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("p is expected to be > 0.0 and < 1.0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var R: T
            let ZERO: T = 0
            let ONE: T = 1
            let HALF: T = T.half
            let SPLIT1: T =  Helpers.makeFP(0.425)
            let SPLIT2: T = 5
            let CONST1: T =  Helpers.makeFP(0.180625)
            let CONST2: T =  Helpers.makeFP(1.6)
            let A0: T =  Helpers.makeFP(3.3871328727963666080)
            let A1: T =  Helpers.makeFP(1.3314166789178437745E02)
            let A2: T =  Helpers.makeFP(1.9715909503065514427E03)
            let A3: T =  Helpers.makeFP(1.3731693765509461125E04)
            let A4: T =  Helpers.makeFP(4.5921953931549871457E04)
            let A5: T =  Helpers.makeFP(6.7265770927008700853E04)
            let A6: T =  Helpers.makeFP(3.3430575583588128105E04)
            let A7: T =  Helpers.makeFP(2.5090809287301226727E03)
            let B1: T =  Helpers.makeFP(4.2313330701600911252E01)
            let B2: T =  Helpers.makeFP(6.8718700749205790830E02)
            let B3: T =  Helpers.makeFP(5.3941960214247511077E03)
            let B4: T =  Helpers.makeFP(2.1213794301586595867E04)
            let B5: T =  Helpers.makeFP(3.9307895800092710610E04)
            let B6: T =  Helpers.makeFP(2.8729085735721942674E04)
            let B7: T =  Helpers.makeFP(5.2264952788528545610E03)
            let C0: T =  Helpers.makeFP(1.42343711074968357734)
            let C1: T =  Helpers.makeFP(4.63033784615654529590)
            let C2: T =  Helpers.makeFP(5.76949722146069140550)
            let C3: T =  Helpers.makeFP(3.64784832476320460504)
            let C4: T =  Helpers.makeFP(1.27045825245236838258)
            let C5: T =  Helpers.makeFP(2.41780725177450611770E-01)
            let C6: T =  Helpers.makeFP(2.27238449892691845833E-02)
            let C7: T =  Helpers.makeFP(7.74545014278341407640E-04)
            let D1: T =  Helpers.makeFP(2.05319162663775882187)
            let D2: T =  Helpers.makeFP(1.67638483018380384940)
            let D3: T =  Helpers.makeFP(6.89767334985100004550E-01)
            let D4: T =  Helpers.makeFP(1.48103976427480074590E-01)
            let D5: T =  Helpers.makeFP(1.51986665636164571966E-02)
            let D6: T =  Helpers.makeFP(5.47593808499534494600E-04)
            let D7: T =  Helpers.makeFP(1.05075007164441684324E-09)
            let E0: T =  Helpers.makeFP(6.65790464350110377720)
            let E1: T =  Helpers.makeFP(5.46378491116411436990)
            let E2: T =  Helpers.makeFP(1.78482653991729133580)
            let E3: T =  Helpers.makeFP(2.96560571828504891230E-01)
            let E4: T =  Helpers.makeFP(2.65321895265761230930E-02)
            let E5: T =  Helpers.makeFP(1.24266094738807843860E-03)
            let E6: T =  Helpers.makeFP(2.71155556874348757815E-05)
            let E7: T =  Helpers.makeFP(2.01033439929228813265E-07)
            let F1: T =  Helpers.makeFP(5.99832206555887937690E-01)
            let F2: T =  Helpers.makeFP(1.36929880922735805310E-01)
            let F3: T =  Helpers.makeFP(1.48753612908506148525E-02)
            let F4: T =  Helpers.makeFP(7.86869131145613259100E-04)
            let F5: T =  Helpers.makeFP(1.84631831751005468180E-05)
            let F6: T =  Helpers.makeFP(1.42151175831644588870E-07)
            let F7: T =  Helpers.makeFP(2.04426310338993978564E-15)
            let Q: T = p - HALF
            var _res: T
            var ex1: T
            var ex2: T
            var ex3: T
            var ex4: T
            var ex5: T
            if(abs(Q) <= SPLIT1)
            {
                R = CONST1 - Q * Q
                let _e1: T = (A7 * R + A6) * R + A5
                let _e2: T = (_e1 * R + A4) * R + A3
                let _e3: T = (_e2 * R + A2) * R + A1
                let _e4: T = (B7 * R + B6) * R + B5
                let _e5: T = (_e4 * R + B4) * R + B3
                let _e6: T = (_e5 * R + B2) * R + B1
                ex1 = _e3 * R
                ex2 = ex1 + A0
                ex3 = _e6 * R
                ex4 = ex3 + T.one
                ex5 = ex2 / ex4
                _res = Q * ex5
                //                    _res = Q * (_e3 * R + A0) / ( _e6 * R + ONE)
                //        _res = Q * ((((((((A7 * R + A6) * R + A5) * R + A4) * R + A3) * R + A2) * R + A1) * R + A0) / (((((((B7 * R + B6) * R + B5) * R + B4) * R + B3) * R + B2) * R + B1) * R + ONE)
                return _res
            }
            else
            {
                if(Q < ZERO) {
                    R = p
                }
                else {
                    R = ONE - p
                }
                if(R <= ZERO) {
                    _res = T.nan
                    return _res
                }
                R = (-SSMath.log1(R)).squareRoot()
                if (R <= SPLIT2)
                {
                    R = R - CONST2
                    ex1 = C7 * R + C6
                    ex2 = ex1 * R
                    let _e1: T = ex2 + C5
                    ex1 = _e1 * R + C4
                    ex2 = ex1 * R
                    let _e2: T = ex2 + C3
                    ex1 = _e2 * R + C2
                    ex2 = ex1 * R
                    let _e3: T = ex2 + C1
                    ex1 = D7 * R + D6
                    ex2 = ex1 * R
                    let _e4: T = (ex2 + D5)
                    ex1 = (_e4 * R + D4)
                    ex2 = ex1 * R
                    let _e5: T = (ex2 + D3)
                    ex1 = _e5 * R + D2
                    ex2 = ex1 * R
                    let _e6: T = (ex2 + D1)
                    ex1 = _e3 * R
                    ex2 = ex1 + C0
                    ex3 = _e6 * R
                    ex4 = ex3 + T.one
                    _res = ex2 / ex4
                }
                else
                {
                    R = R - SPLIT2
                    ex1 = (E7 * R + E6)
                    ex2 = ex1 * R
                    let _e1: T = (ex2 + E5)
                    ex1 = (_e1 * R + E4)
                    ex2 = ex1 * R
                    let _e2: T = (ex2 + E3)
                    ex1 = (_e2 * R + E2)
                    ex2 = ex1 * R
                    let _e3: T = (ex2 + E1)
                    ex1 = (F7 * R + F6)
                    ex2 = ex1 * R
                    let _e4: T = (ex2 + F5)
                    ex1 = (_e4 * R + F4)
                    ex2 = ex1 * R
                    let _e5: T = (ex2 + F3)
                    ex1 = (_e5 * R + F2)
                    ex2 = ex1 * R
                    let _e6: T = (ex2 + F1)
                    ex1 = _e3 * R
                    ex2 = ex1 + E0
                    ex3 = _e6 * R
                    ex4 = ex3 + T.one
                    _res = ex2 / ex4
                }
                if(Q < ZERO) {
                    _res = -_res
                }
                return _res
            }
            
        }
    }
}



/// Inverse error function using the identity inverf(x) = InverseCDFStdNormal( ( x + 1 ) / 2) / sqrt(2)
/// - Parameter z: Z
/// - Throws: SSSwiftyStatsError if z < -1.0 or z > 1.0
fileprivate func inverf<FPT: SSFloatingPoint & Codable>(z: FPT) throws -> FPT {
    if (z == -1) {
        return -FPT.infinity
    }
    if z == 1 {
        return FPT.infinity
    }
    if ((z < -1) || (z > 1)) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 13, *) {
            os_log("z is expected to be > -1.0 and < 1.0", log: .log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    let x:FPT = (z + 1) / 2
    do {
        let invCDF = try SSProbDist.StandardNormal.quantile(p: x)
        let result = invCDF / FPT.sqrt2
        return result
    }
    catch {
        return FPT.nan
    }
}

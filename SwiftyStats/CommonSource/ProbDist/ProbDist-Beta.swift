//
//  Created by VT on 20.07.18.
//  Copyright © 2018 strike65. All rights reserved.
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
    /// Beta distribution
    public enum Beta {
        
        /// Returns a SSProbDistParams struct containing mean, variance, kurtosis and skewness of the Beta distribution.
        /// - Parameter a: Shape parameter a
        /// - Parameter b: Shape parameter b
        /// - Throws: SSSwiftyStatsError if a and/or b <= 0
        public static func para<FPT: SSFloatingPoint & Codable>(shapeA a:FPT, shapeB b: FPT) throws -> SSProbDistParams<FPT> {
            var result: SSProbDistParams<FPT> = SSProbDistParams<FPT>()
            if (a <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("shape parameter a is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("shape parameter b is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            var ex4: FPT
            result.mean = (a / (a + b))
            ex1 = a * b
            ex2 = a + b
            ex3 = ex2 + 1
            ex4 = SSMath.pow1(ex2, 2) * ex3
            result.variance = ex1 / ex4
            let s1:FPT = (2 * (b - a))
            let s2:FPT = (a + b + 1)
            let s3:FPT = sqrt(a) * sqrt(b)
            let s4:FPT = (2 + a + b)
            result.skewness = (s1 * sqrt(s2)) / (s3 * s4)
            let k1:FPT = (a + b + 1)
            let k2:FPT = SSMath.pow1(a, 2) * (b + 2)
            let k3:FPT = SSMath.pow1(b, 2) * (a + 2)
            let k4:FPT = 2 * a * b
            let k5:FPT = a + b + 2
            let k6:FPT = (a + b + 3)
            ex1 = k2 + k3 - k4
            ex2 = 3 * k1 * ex1
            ex3 = a * b * k5 * k6
            result.kurtosis = ex2 / ex3
            return result
        }
        
        
        /// Returns the pdf of the Beta distribution
        /// - Parameter x: x
        /// - Parameter a: Shape parameter a
        /// - Parameter b: Shape parameter b
        /// - Throws: SSSwiftyStatsError if a and/or b <= 0
        public static func pdf<FPT: SSFloatingPoint & Codable>(x: FPT, shapeA a: FPT, shapeB b: FPT) throws -> FPT {
            if (a <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("shape parameter a is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("shape parameter b is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            var ex4: FPT
            var ex6: FPT
            var ex7: FPT
            ex1 = a - FPT.one
            ex2 = SSMath.pow1(x, ex1)
            ex3 = FPT.one - x
            ex4 = b - FPT.one
            ex6 = SSMath.pow1(ex3, ex4)
            ex7 = ex2 * ex6
            let result = ex7 / SSSpecialFunctions.betaFunction(a: a, b: b)
            return result
        }
        
        /// Returns the cdf of the Beta distribution
        /// - Parameter x: x
        /// - Parameter a: Shape parameter a
        /// - Parameter b: Shape parameter b
        /// - Throws: SSSwiftyStatsError if a and/or b <= 0
        public static func cdf<FPT: SSFloatingPoint & Codable>(x: FPT, shapeA a: FPT, shapeB b: FPT) throws -> FPT {
            if (a <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("shape parameter a is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("shape parameter b is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (x <= 0) {
                return 0
            }
            else if (x >= 1) {
                return 1
            }
            else {
                let result = SSSpecialFunctions.betaNormalized(x: x, a: a, b: b)
                return result
            }
        }
        
        /// Returns the quantile of the Beta distribution
        /// - Parameter p: p
        /// - Parameter a: Shape parameter a
        /// - Parameter b: Shape parameter b
        /// - Throws: SSSwiftyStatsError if a and/or b <= 0 and/or p < 0 and/or p > 1
        public static func quantile<FPT: SSFloatingPoint & Codable>(p: FPT, shapeA a: FPT, shapeB b: FPT) throws -> FPT {
            if (a <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("shape parameter a is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("shape parameter b is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if p < 0 || p > 1 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("p is expected to be >= 0 and <= 1.0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if abs(p - 1) < FPT.ulpOfOne {
                return 1
            }
            else if p.isZero {
                return 0
            }
            var bVal: FPT
            var maxB: FPT
            var minB: FPT
            var it: Int = 0
            maxB = 1
            minB = 0
            bVal =  Helpers.makeFP(1.0 / 2.0 )
            var pVal: FPT
            while (maxB - minB) > FPT.ulpOfOne {
                if it > 500 {
                    break
                }
                do {
                    pVal = try cdf(x: bVal, shapeA: a, shapeB: b)
                }
                catch {
                    return FPT.nan
                }
                if  pVal > p {
                    maxB = bVal
                }
                else {
                    minB = bVal
                }
                bVal = (maxB + minB) / 2
                it = it + 1
            }
            return bVal
        }
    }
}

extension SSProbDist {
    /// Beta distribution
    public enum NoncentralBeta {
        
        // noncentral
        
        /// Returns the cdf of the noncentral Beta distribution
        /// - Parameter x: x
        /// - Parameter a: Shape parameter a
        /// - Parameter b: Shape parameter b
        /// - Parameter lambda: Noncentrality
        /// - Note: Uses an algorithm described in Harry Posten, An Effective Algorithm for the Noncentral Beta Distribution Function,The American Statistician,Volume 47, Number 2, May 1993, pages 129-131.
        ///
        /// C version by John Burkardt
        /// Swift port by strike65
        ///
        /// - Throws: SSSwiftyStatsError if a and/or b <= 0
        internal static func cdf<FPT: SSFloatingPoint & Codable>(x: FPT, shapeA a: FPT, shapeB b: FPT, lambda: FPT) throws -> FPT {
            if (a <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("shape parameter a is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("shape parameter b is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if lambda.isZero {
                do {
                    return try SSProbDist.Beta.cdf(x: x, shapeA: a, shapeB: b)
                }
                catch {
                    throw error
                }
            }
            if (x <= 0) {
                return 0
            }
            else if (x >= 1) {
                return 1
            }
            else {
                var e1, e2, e3, e4, e5: FPT
                var i, beta_log,bi, bj, p_sum, pb_sum, pi, pj, si, sj: FPT
                let errorMax: FPT = FPT.ulpOfOne * 10
                i = 0
                pi = SSMath.exp1(-lambda * FPT.half)
                beta_log = SSMath.lgamma1(a) + SSMath.lgamma1(b) - SSMath.lgamma1(a + b)
                
                bi = SSSpecialFunctions.betaNormalized(x: x, a: a, b: b)
                e1 = a * SSMath.log1(x)
                e2 = b * SSMath.log1(1 - x)
                e3 = -beta_log - SSMath.log1(a)
                si = SSMath.exp1(e1 + e2 + e3)
                p_sum = pi
                pb_sum = pi * bi
                
                while (p_sum < (1 - errorMax)) {
                    pj = pi
                    bj = bi
                    sj = si
                    i = i + 1
                    pi = FPT.half * lambda * pj / i
                    bi = bj - sj
                    e4 = a + b
                    e5 = e4 + i
                    e1 = e5 - FPT.one
                    e2 = sj / (a + i)
                    si = x * e1 * e2
                    
                    p_sum = p_sum + pi
                    pb_sum = pb_sum + pi * bi
                    
                }
                return pb_sum
            }
        }
        
        
        /// Returns the pdf of the noncentral Beta distribution
        /// - Parameter x: x
        /// - Parameter a: Shape parameter a
        /// - Parameter b: Shape parameter b
        /// - Parameter lambda: Noncentrality
        /// - Note: Uses an algorithm described in Harry Posten, An Effective Algorithm for the Noncentral Beta Distribution Function,The American Statistician,Volume 47, Number 2, May 1993, pages 129-131.
        ///
        /// C version by John Burkardt
        /// Swift port by strike65
        ///
        /// - Throws: SSSwiftyStatsError if a and/or b <= 0
        internal static func pdf<FPT: SSFloatingPoint & Codable>(x: FPT, shapeA a: FPT, shapeB b: FPT, lambda: FPT) throws -> FPT {
            if (a <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("shape parameter a is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("shape parameter b is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if lambda.isZero {
                do {
                    return try SSProbDist.Beta.pdf(x: x, shapeA: a, shapeB: b)
                }
                catch {
                    throw error
                }
            }
            if (x <= 0) {
                return 0
            }
            else if (x >= 1) {
                return 1
            }
            else {
                var e1, e2, e3, e4: FPT
                // use log
                let betal: FPT = SSSpecialFunctions.betaFunction(a: a, b: b)
                if betal.isInfinite {
                    return 0
                }
                let l_half: FPT = -lambda * FPT.half
                e1 = (b - 1) * SSMath.log1(1 - x)
                e2 = (a - 1) * SSMath.log1(x)
                e3 = SSMath.exp1(l_half + e1 + e2)
                e4 = SSSpecialFunctions.hypergeometric1F1(a: a + b, b: a, x: lambda * x * FPT.half)
                
                let ans: FPT = (e3 * e4) / betal
                return ans
            }
        }
    }
    
}


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

/// Probability Distributions
extension SSProbDist {
    /// Student T distribution
    public enum StudentT {
        
        /// Returns a SSProbDistParams struct containing mean, variance, kurtosis and skewness of the Student's T distribution.
        /// - Parameter df: Degrees of freedom
        /// - Throws: SSSwiftyStatsError if df <= 0
        public static func para<FPT: SSFloatingPoint & Codable>(degreesOfFreedom df: FPT) throws -> SSProbDistParams<FPT> {
            var result: SSProbDistParams<FPT> = SSProbDistParams<FPT>()
            if df < 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    SSLog.statError("Degrees of freedom are expected to be > 0")
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var ex1: FPT
            var ex2: FPT
            result.mean = 0
            if df > 2 {
                result.variance = df / (df - 2)
            }
            else {
                result.variance = 0
            }
            result.skewness = 0
            if df > 4 {
                ex1 = df - 4
                ex2 = 6 / ex1
                result.kurtosis = 3 + ex2
            }
            else {
                result.kurtosis = FPT.nan
            }
            return result
        }
        
        
        /// Returns the pdf of Student's t-distribution
        /// - Parameter t: t
        /// - Parameter df: Degrees of freedom
        /// - Parameter rlog: Return log(T_PDF(t, df))
        /// - Throws: SSSwiftyStatsError if df <= 0
        public static func pdf<FPT: SSFloatingPoint & Codable>(t: FPT, degreesOfFreedom df: FPT, rlog: Bool! = false) throws -> FPT {
            if df < 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    SSLog.statError("Degrees of freedom are expected to be > 0")
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            var ex4: FPT
            var ex5: FPT
            var ex6: FPT
            var ex7: FPT
            var ex8: FPT
            var ex9: FPT
            ex1 = df + FPT.one
            ex2 = ex1 / 2
            ex3 = t * t
            ex4 = FPT.one + ex3 / df
            let expr: FPT = ex2 * SSMath.log1(ex4)
            ex2 = FPT.half * ex1
            ex3 = SSMath.lgamma1(ex2)
            ex4 = df * FPT.pi
            ex5 = FPT.half * SSMath.log1(ex4)
            ex6 = FPT.half * df
            ex7 = SSMath.lgamma1(ex6)
            ex8 = ex3 - ex5
            ex9 = ex8 - ex7
            let lpdf:FPT = ex9 - expr
            if rlog {
                return lpdf
            }
            else {
                return SSMath.exp1(lpdf)
            }
        }
        
        /// Returns the cdf of Student's t-distribution
        /// - Parameter t: t
        /// - Parameter df: Degrees of freedom
        /// - Throws: SSSwiftyStatsError if df <= 0
        public static func cdf<FPT: SSFloatingPoint & Codable>(t: FPT, degreesOfFreedom df: FPT) throws -> FPT {
            if df < 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    SSLog.statError("Degrees of freedom are expected to be > 0")
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var correctedDoF: FPT
            var halfDoF: FPT
            var constant: FPT
            var result: FPT
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            halfDoF = df / 2
            correctedDoF = df / ( df + ( t * t ) )
            constant = FPT.half
            let t1: FPT = SSSpecialFunctions.betaNormalized(x: 1, a: halfDoF, b: constant)
            let t2: FPT = SSSpecialFunctions.betaNormalized(x: correctedDoF, a: halfDoF, b: constant)
            ex1 = t1 - t2
            ex2 = ex1 * SSMath.sign1(t)
            ex3 = FPT.one + ex2
            result = FPT.half * ex3
//            result = half * (1 + (t1 - t2) * SSMath.sign1(t))
            return result
        }
        
        /// Returns the quantile (inverse CDF) of Student's t-distribution.
        ///
        /// Implementation: monotone bracketing + bisection on the lower-tail CDF,
        /// leveraging symmetry to reduce search to t >= 0 and reflecting the sign
        /// when `p < 0.5`. The bracket is expanded geometrically until it contains
        /// the target probability, then bisected to a tight tolerance.
        /// - Parameter p: Probability
        /// - Parameter df: Degrees of freedom
        /// - Throws: SSSwiftyStatsError if df <= 0 and/or p < 0 or p > 1.0
        public static func quantile<FPT: SSFloatingPoint & Codable>(p: FPT, degreesOfFreedom df: FPT) throws -> FPT {
            if df < 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    SSLog.statError("Degrees of freedom are expected to be > 0")
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if p < 0 || p > 1 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    SSLog.statError("p is expected to be >= 0.0 and <= 1.0")
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            // Boundary handling
            if p <= 0 { return -FPT.infinity }
            if p >= 1 { return FPT.infinity }

            // Use symmetry: solve for lower-tail p' >= 0.5, then apply sign
            let lower = p <= FPT.half
            let target = lower ? (FPT.one - p) : p
            let q = try Helpers.invertCDFMonotone(
                lowerBound: .zero,
                upperSeed: FPT(1),
                target: target,
                cdf: { try cdf(t: $0, degreesOfFreedom: df) }
            )
            return lower ? (-q) : q
        }
        
    }
}

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
    /// Laplace distribution
    public enum Laplace {
        
        /// Returns a SSProbDistParams struct containing mean, variance, kurtosis and skewness of the Laplace distribution.
        /// - Parameter mean: mean
        /// - Parameter b: Scale parameter b
        /// - Throws: SSSwiftyStatsError if b <= 0
        public static func para<FPT: SSFloatingPoint & Codable>(mean: FPT, scale b: FPT) throws -> SSProbDistParams<FPT> {
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("scale parameter b is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var result: SSProbDistParams<FPT> = SSProbDistParams<FPT>()
            result.mean = mean
            result.variance = 2 * SSMath.pow1(b, 2)
            result.kurtosis = 6
            result.skewness = 0
            return result
        }
        
        
        /// Returns the pdf of the Laplace distribution.
        /// - Parameter x: x
        /// - Parameter mean: mean
        /// - Parameter b: Scale parameter b
        /// - Throws: SSSwiftyStatsError if b <= 0
        public static func pdf<FPT: SSFloatingPoint & Codable>(x: FPT, mean: FPT, scale b: FPT) throws -> FPT {
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("scale parameter b is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            var ex4: FPT
            var ex5: FPT
            ex1 = SSMath.reciprocal(2 * b)
            ex2 = x - mean
            ex3 = -abs(ex2)
            ex4 = ex3 / b
            ex5 = SSMath.exp1(ex4)
            let result = ex1 * ex5
            return result
        }
        
        /// Returns the cdf of the Laplace distribution.
        /// - Parameter x: x
        /// - Parameter mean: mean
        /// - Parameter b: Scale parameter b
        /// - Throws: SSSwiftyStatsError if b <= 0
        public static func cdf<FPT: SSFloatingPoint & Codable>(x: FPT, mean: FPT, scale b: FPT) throws -> FPT {
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("scale parameter b is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            let xm: FPT = x - mean
            let expr1: FPT = (1 - SSMath.exp1(-abs(xm) / b))
            let half: FPT =  Helpers.makeFP(1.0 / 2.0 )
            let result: FPT = half * (1 + SSMath.sign(xm) * expr1)
            return result
        }
        
        /// Returns the quantile of the Laplace distribution.
        /// - Parameter p: p
        /// - Parameter mean: mean
        /// - Parameter b: Scale parameter b
        /// - Throws: SSSwiftyStatsError if b <= 0 || p < 0 || p > 1
        public static func quantile<FPT: SSFloatingPoint & Codable>(p: FPT, mean: FPT, scale b: FPT) throws -> FPT {
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("scale parameter b is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if p < 0 || p > 1 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("p is expected to be >= 0 or <= 1.0 ", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            let result: FPT
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            if p.isZero {
                return -FPT.infinity
            }
            else if abs(p - 1) < FPT.ulpOfOne {
                return FPT.infinity
            }
            else if (p <=  Helpers.makeFP(0.5 )) {
                ex1 = 2 * p - FPT.one
                ex2 = b * SSMath.log1p1(ex1)
                result = mean + ex2
            }
            else {
                ex1 = FPT.one - p
                ex2 = 2 * ex1 - FPT.one
                ex3 = b * SSMath.log1p1(ex2)
                result = mean - ex3
            }
            return result
        }
    }
}


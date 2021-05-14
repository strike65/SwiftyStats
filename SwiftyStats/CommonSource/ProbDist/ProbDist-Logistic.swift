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
    /// Logistic
    public enum Logistic {

        /// Returns the Logit for a given p
        /// - Parameter p: p
        /// - Throws: SSSwiftyStatsError if p <= 0 || p >= 1
        public static func logit<FPT: SSFloatingPoint & Codable>(p: FPT) throws -> FPT {
            if p <= 0 || p >= 1 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("p is expected to be >= 0 or <= 1.0 ", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            return SSMath.log1p1(p / (1 - p))
        }
        
        /// Returns a SSProbDistParams struct containing mean, variance, kurtosis and skewness of the Logistic distribution.
        /// - Parameter mean: mean
        /// - Parameter b: Scale parameter b
        /// - Throws: SSSwiftyStatsError if b <= 0
        public static func para<FPT: SSFloatingPoint & Codable>(mean: FPT, scale b: FPT) throws -> SSProbDistParams<FPT> {
            if b <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("scale parameter b is expected to be > 0 ", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var result: SSProbDistParams<FPT> = SSProbDistParams<FPT>()
            result.mean = mean
            result.variance = SSMath.pow1(b, 2) * SSMath.pow1(FPT.pi, 2) / 3
            result.kurtosis =  Helpers.makeFP(4.2)
            result.skewness = 0
            return result
        }
        
        /// Returns the pdf of the Logistic distribution.
        /// - Parameter x: x
        /// - Parameter mean: mean
        /// - Parameter b: Scale parameter b
        /// - Throws: SSSwiftyStatsError if b <= 0
        public static func pdf<FPT: SSFloatingPoint & Codable>(x: FPT, mean: FPT, scale b: FPT) throws -> FPT {
            if b <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("scale parameter b is expected to be > 0 ", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            let expr1: FPT = SSMath.exp1(-(x - mean) / b)
            let expr2: FPT = SSMath.exp1(-(x - mean) / b)
            let result: FPT = expr1 / (b * SSMath.pow1(1 + expr2, 2))
            return result
        }
        
        /// Returns the cdf of the Logistic distribution.
        /// - Parameter x: x
        /// - Parameter mean: mean
        /// - Parameter b: Scale parameter b
        /// - Throws: SSSwiftyStatsError if b <= 0
        public static func cdf<FPT: SSFloatingPoint & Codable>(x: FPT, mean: FPT, scale b: FPT) throws -> FPT {
            if b <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("scale parameter b is expected to be > 0 ", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            ex1 = x - mean
            ex2 = ex1 / b
            ex3 = FPT.one + SSMath.tanh1(FPT.half * ex2)
            let result = FPT.half * ex3
            return result
        }
        
        /// Returns the quantile of the Logistic distribution.
        /// - Parameter p: p
        /// - Parameter mean: mean
        /// - Parameter b: Scale parameter b
        /// - Throws: SSSwiftyStatsError if b <= 0 || p < 0 || p > 1
        public static func quantile<FPT: SSFloatingPoint & Codable>(p: FPT, mean: FPT, scale b: FPT) throws -> FPT {
            if b <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("scale parameter b is expected to be > 0 ", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if p < 0 || p > 1 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("p is expected to be >= 0 and <= 1 ", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var ex1: FPT
            var ex2: FPT
            let result: FPT
            if p.isZero {
                return -FPT.infinity
            }
            else if abs(1 - p) < FPT.ulpOfOne {
                return FPT.infinity
            }
            else {
                ex1 = FPT.minusOne + SSMath.reciprocal(p)
                ex2 = b * SSMath.log1(ex1)
                result = mean - ex2
                return result
            }
        }
    }
}


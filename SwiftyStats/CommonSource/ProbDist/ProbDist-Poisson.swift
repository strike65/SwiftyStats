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
    /// Poisson distribution
    public enum Poisson {
        
        /// Returns a SSProbDistParams struct containing mean, variance, kurtosis and skewness of the Binomial distribution.
        /// - Parameter n: Number of events
        /// - Parameter lambda: rate
        /// - Throws: SSSwiftyStatsError if lambda <= 0, n < 0
        public static func para<FPT: SSFloatingPoint & Codable>(numberOfEvents n: Int, rate lambda: FPT) throws -> SSProbDistParams<FPT> {
            if lambda <= 0 {
                #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("lambda is expected to be > 0", log: .log_stat, type: .error)
                }
                #endif
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if n < 0 {
                #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("n is expected to be >= 0", log: .log_stat, type: .error)
                }
                #endif
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var result: SSProbDistParams<FPT> = SSProbDistParams<FPT>()
            result.mean = lambda
            result.variance = lambda
            result.kurtosis = 3 + FPT.one / lambda
            result.skewness = FPT.one / sqrt(lambda)
            return result
        }

        
        /// Returns the cdf of the Poisson Distribution
        /// - Parameter k: number of events
        /// - Parameter lambda: rate
        /// - Parameter tail: .lower, .upper
        /// - Throws: SSSwiftyStatsError if lambda <= 0, k < 0
        public static func cdf<FPT: SSFloatingPoint & Codable>(k: Int, rate lambda: FPT, tail: SSCDFTail) throws -> FPT {
            if lambda <= 0 {
                #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("lambda is expected to be > 0", log: .log_stat, type: .error)
                }
                #endif
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if k < 0 {
                #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("k is expected to be > 0", log: .log_stat, type: .error)
                }
                #endif
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var conv: Bool = false
            let result: FPT = SSSpecialFunctions.gammaNormalizedQ(x: lambda, a: 1 +  Helpers.makeFP(k), converged: &conv)
            if conv {
                switch tail {
                case .lower:
                    return result
                case .upper:
                    return 1 - result
                }
            }
            else {
                return FPT.nan
            }
        }
        
        
        /// Returns the pdf of the Poisson Distribution
        /// - Parameter k: number of events
        /// - Parameter lambda: rate
        /// - Throws: SSSwiftyStatsError if lambda <= 0, k < 0
        public static func pdf<FPT: SSFloatingPoint & Codable>(k: Int, rate lambda: FPT) throws -> FPT {
            if lambda <= 0 {
                #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("lambda is expected to be > 0", log: .log_stat, type: .error)
                }
                #endif
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if k < 0 {
                #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("k is expected to be > 0", log: .log_stat, type: .error)
                }
                #endif
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            let result: FPT =  Helpers.makeFP(k) * SSMath.log1(lambda) - lambda - SSMath.logFactorial(k)
            return SSMath.exp1(result)
        }
    }
}


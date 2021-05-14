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
    /// Extreme value distribution
    public enum ExtremeValue {
        
        /// Returns a SSProbDistParams struct containing mean, variance, kurtosis and skewness of the Extrem Value distribution.
        /// - Parameter a: location
        /// - Parameter b: scale
        /// - Throws: SSSwiftyStatsError if b <= 0
        public static func para<FPT: SSFloatingPoint & Codable>(location a: FPT, scale b: FPT) throws -> SSProbDistParams<FPT> {
            var result: SSProbDistParams<FPT> = SSProbDistParams<FPT>()
            if b <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("scale parameter are expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            let ZETA3: FPT =  Helpers.makeFP(1.202056903159594285399738161511449990764986292340498881792271555)
            result.mean = a + FPT.eulergamma
            result.variance = (b * b * FPT.pisquared) / 6
            result.skewness = (12 * FPT.sqrt6 * ZETA3) / (FPT.pisquared * FPT.pi)
            result.kurtosis =  Helpers.makeFP(5.4)
            return result
        }
        
        
        /// Returns the pdf of the Extrem Value distribution.
        /// - Parameter a: location
        /// - Parameter b: scale
        /// - Parameter x: x
        /// - Throws: SSSwiftyStatsError if b <= 0
        public static func pdf<FPT: SSFloatingPoint & Codable>(x: FPT, location a: FPT, scale b: FPT) throws -> FPT {
            if b <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("scale parameter are expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var result: FPT = 0
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            var ex4: FPT
            ex1 = x - a
            ex2 = ex1 / b
            ex3 = SSMath.exp1(-ex2)
            ex4 = SSMath.exp1(-ex3)
            result = SSMath.exp1(-ex2) * ex4 / b
            return result
        }
        
        /// Returns the cdf of the Extrem Value distribution.
        /// - Parameter a: location
        /// - Parameter b: scale
        /// - Parameter x: x
        /// - Throws: SSSwiftyStatsError if b <= 0
        public static func cdf<FPT: SSFloatingPoint & Codable>(x: FPT, location a: FPT, scale b: FPT) throws -> FPT {
            if b <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("scale parameter are expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            var result: FPT = 0
            ex1 = -a + x
            ex2 = ex1 / b
            ex3 = SSMath.exp1(-ex2)
            result = SSMath.exp1(-ex3)
            return result
        }
        
        
        /// Returns the p-quantile of the Extrem Value distribution.
        /// - Parameter a: location
        /// - Parameter b: scale
        /// - Parameter p: p
        /// - Throws: SSSwiftyStatsError if b <= 0
        public static func quantile<FPT: SSFloatingPoint & Codable>(p: FPT, location a: FPT, scale b: FPT) throws -> FPT {
            if b <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("scale parameter are expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if p < 0 || p > 1 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("p is expected to be >= 0.0 and <= 1.0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if p <= 0 {
                return -FPT.infinity
            }
            else if (p >= 1) {
                return FPT.infinity
            }
            else {
                return a - b * SSMath.log1(-SSMath.log1(p))
            }
        }
    }
}


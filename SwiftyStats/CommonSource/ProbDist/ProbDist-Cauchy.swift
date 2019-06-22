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
    enum Cauchy {
        // MARK: Cauchy
        /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Cauchy distribution.
        /// - Parameter a: Location parameter a
        /// - Parameter b: Scale parameter b
        /// - Throws: SSSwiftyStatsError if b <= 0
        public static func para<FPT: SSFloatingPoint & Codable>(location a: FPT, scale b: FPT) throws -> SSContProbDistParams<FPT> {
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            return SSContProbDistParams()
        }
        
        /// Returns the pdf of the Cauchy distribution.
        /// - Parameter x: x
        /// - Parameter a: Location parameter a
        /// - Parameter b: Scale parameter b
        /// - Throws: SSSwiftyStatsError if b <= 0
        public static func pdf<FPT: SSFloatingPoint & Codable>(x: FPT, location a: FPT, scale b: FPT) throws -> FPT {
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            let p = (x - a) / b
            let result = FPT.pi * b * (1 + (p * p))
            //    let result = Double.pi * b * (1.0 * pow((x - a) / b, 2.0))
            return 1 / result
        }
        
        /// Returns the cdf of the Cauchy distribution.
        /// - Parameter x: x
        /// - Parameter a: Location parameter a
        /// - Parameter b: Scale parameter b
        /// - Throws: SSSwiftyStatsError if b <= 0
        public static func cdf<FPT: SSFloatingPoint & Codable>(x: FPT, location a: FPT, scale b: FPT) throws -> FPT {
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            ex1 = FPT.half
            ex2 = (x - a) / b
            ex3 = FPT.oopi * SSMath.atan1(ex2)
            let result = ex1 + ex3
            //    let result =  Helpers.makeFP(1.0 / 2.0 ) + 1 / FPT.pi * SSMath.atan1((x - a) / b)
            return result
        }
        
        /// Returns the pdf of the Cauchy distribution.
        /// - Parameter x: x
        /// - Parameter a: Location parameter a
        /// - Parameter b: Scale parameter b
        /// - Throws: SSSwiftyStatsError if (b <= 0 || p < 0 || p > 1)
        public static func quantile<FPT: SSFloatingPoint & Codable>(p: FPT, location a: FPT, scale b: FPT) throws -> FPT {
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if p < 0 || p > 1 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("p is expected to be >= 0 and <= 1.0", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if p.isZero {
                return -FPT.infinity
            }
            if abs(p - 1) < FPT.ulpOfOne {
                return FPT.infinity
            }
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            ex1 = -FPT.half + p
            ex2 = ex1 * FPT.pi
            ex3 = b * SSMath.tan1(ex2)
            let result = a + ex3
            //    let result = a + b * tan1((- Helpers.makeFP(1.0 / 2.0 ) + p) * FPT.pi)
            return result
        }
        
    }
}

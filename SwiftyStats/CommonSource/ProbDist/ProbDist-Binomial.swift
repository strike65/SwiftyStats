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
    enum Binomial {
        
        // MARK: binomial
        
        /// Returns the cdf of the Binomial Distribution
        /// - Parameter k: number of successes
        /// - Parameter n: number of trials
        /// - Parameter p0: probability fpr success
        /// - Parameter tail: .lower, .upper
        public static func cdfBinomialDistribution<FPT: SSFloatingPoint & Codable>(k: Int, n: Int, probability p0: FPT, tail: SSCDFTail) -> FPT {
            var i: Int = 0
            var lowerSum: FPT = 0
            var upperSum: FPT = 0
            while i <= k {
                lowerSum += SSMath.binomial2( Helpers.makeFP(n),  Helpers.makeFP(i)) * SSMath.pow1(p0,  Helpers.makeFP(i)) * SSMath.pow1(1 - p0,  Helpers.makeFP(n - i))
                i += 1
            }
            upperSum = 1 - lowerSum
            switch tail {
            case .lower:
                return lowerSum
            case .upper:
                return upperSum
            }
        }
        
        
        /// Returns the pdf of the Binomial Distribution
        /// - Parameter k: number of successes
        /// - Parameter n: number of trials
        /// - Parameter p0: probability fpr success
        public static func pdfBinomialDistribution<FPT: SSFloatingPoint & Codable>(k: Int, n: Int, probability p0: FPT) -> FPT {
            var result: FPT
            result = SSMath.binomial2( Helpers.makeFP(n),  Helpers.makeFP(k)) * SSMath.pow1(p0,  Helpers.makeFP(k)) * SSMath.pow1(1 - p0,  Helpers.makeFP(n - k))
            return result
        }
    }
}


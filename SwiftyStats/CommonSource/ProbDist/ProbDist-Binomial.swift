//
//  Created by VT on 20.07.18.
//  Copyright © 2018 Volker Thieme. All rights reserved.
/*
 Copyright (c) 2017 Volker Thieme
 
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

// MARK: binomial

/// Returns the cdf of the Binomial Distribution
/// - Parameter k: number of successes
/// - Parameter n: number of trials
/// - Parameter p0: probability fpr success
/// - Parameter tail: .lower, .upper
public func cdfBinomialDistribution(k: Int, n: Int, probability p0: Double!, tail: SSCDFTail) -> Double {
    var i = 0
    var lowerSum: Double = 0.0
    var upperSum: Double = 0.0
    while i <= k {
        lowerSum += binomial2(Double(n), Double(i)) * pow(p0, Double(i)) * pow(1.0 - p0, Double(n - i))
        i += 1
    }
    upperSum = 1.0 - lowerSum
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
public func pdfBinomialDistribution(k: Int, n: Int, probability p0: Double!) -> Double {
    var result: Double
    result = binomial2(Double(n), Double(k)) * pow(p0, Double(k)) * pow(1.0 - p0, Double(n - k))
    return result
}

//
//  SSHypothesisTesting-Randomness.swift
//  SwiftyStats
//
//  Created by strike65 on 20.07.17.
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


extension SSHypothesisTesting {
    
    /// Performs the runs test for the given sample. Tests for randomness.
    /// ### Important Note ###
    /// It is important that the data are numerical. To recode non-numerical data follow the procedure as described below.<br/>
    ///
    ///
    /// * Suppose the original data is a string containing only "H" and "L": `HLHHLHHLHLLHLHHL`
    /// * Setting "H" = 1 and "L" = 3 results in the recoded sequence:
    ///   * `1311311313313113`
    ///   * In this case a cutting point of 2 must be used.
    /// * Setting "H" = 1 and "L" = 2 results in the recoded sequence:
    ///   * `1211211212212112`
    ///   * In this case a cutting point of 1.5 must be used.
    ///
    ///
    /// - Parameter data: Array<Double>
    /// - Parameter alpha: Alpha
    /// - Parameter useCuttingPoint: SSRunsTestCuttingPoint.median || SSRunsTestCuttingPoint.mean || SSRunsTestCuttingPoint.mode || SSRunsTestCuttingPoint.userDefined
    /// - Parameter cP: A user defined cutting point. Must not be nil if SSRunsTestCuttingPoint.userDefined is set
    /// - Throws: SSSwiftyStatsError iff data.sampleSize < 2
    public static func runsTest<FPT: SSFloatingPoint & Codable>(array: Array<FPT>, alpha: FPT, useCuttingPoint useCP: SSRunsTestCuttingPoint, userDefinedCuttingPoint cuttingPoint: FPT?, alternative: SSAlternativeHypotheses) throws -> SSRunsTestResult<FPT> {
        if array.count < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample size is expected to be >= 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try SSHypothesisTesting.runsTest(data: SSExamine<FPT, FPT>.init(withArray: array, name: nil,  characterSet: nil), alpha: alpha, useCuttingPoint: useCP, userDefinedCuttingPoint: cuttingPoint, alternative: alternative)
        }
        catch {
            throw error
        }
    }
    
    
    /// Performs the runs test for the given sample. Tests for randomness.
    /// ### Important Note ###
    /// It is important that the data are numerical. To recode non-numerical data follow the procedure as described below.<br/>
    ///
    /// * Suppose the original data is a string containing only "H" and "L": `HLHHLHHLHLLHLHHL`
    /// * Setting "H" = 1 and "L" = 3 results in the recoded sequence:
    ///   * `1311311313313113`
    ///   * In this case a cutting point of 2 must be used.
    /// * Setting "H" = 1 and "L" = 2 results in the recoded sequence:
    ///   * `1211211212212112`
    ///   * In this case a cutting point of 1.5 must be used.
    ///
    /// - Parameter data: Array<Double>
    /// - Parameter alpha: Alpha
    /// - Parameter useCuttingPoint: SSRunsTestCuttingPoint.median || SSRunsTestCuttingPoint.mean || SSRunsTestCuttingPoint.mode || SSRunsTestCuttingPoint.userDefined
    /// - Parameter cP: A user defined cutting point. Must not be nil if SSRunsTestCuttingPoint.userDefined is set
    /// - Throws: SSSwiftyStatsError iff data.sampleSize < 2
    public static func runsTest<FPT: SSFloatingPoint & Codable>(data: SSExamine<FPT, FPT>!, alpha: FPT, useCuttingPoint useCP: SSRunsTestCuttingPoint, userDefinedCuttingPoint cuttingPoint: FPT?, alternative: SSAlternativeHypotheses) throws -> SSRunsTestResult<FPT> {
        if data.sampleSize < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample size is expected to be >= 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var diff = Array<FPT>()
        let elements = data.elementsAsArray(sortOrder: .raw)!
        var dtemp: FPT = 0
        var n2: FPT = 0
        var n1: FPT = 0
        var r: Int = 1
        var cp: FPT = 0
        switch useCP {
        case .mean:
            cp = data.arithmeticMean!
        case .median:
            cp = data.median!
        case .mode:
            if let modes = data.commonest {
                cp = modes.sorted(by: {$0 > $1})[0]
            }
        case .userDefined:
            if let _ = cuttingPoint {
                cp = cuttingPoint!
            }
            else {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("no user defined cutting point specified", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
        }
        var RR = 1
        var s = (elements.first! - cp).sign
        var i = 0
        for element in elements {
            dtemp = element - cp
            diff.append(dtemp)
            if dtemp.sign != s {
                s = dtemp.sign
                RR += 1
            }
            i += 1
            if dtemp >= 0 {
                n2 += 1
            }
            else {
                n1 += 1
            }
        }
        /* keep this for historical reasons ;-)
         for d in diff {
         if d.sign != s {
         s = d.sign
         RR += 1
         }
         i += 1
         }
         */
        r = RR
        dtemp = n1 + n2
        let ex11: FPT = 2 * n2
        let ex1: FPT = ex11 * n1 - n1 - n2
        let ex2: FPT = 2 * n2 * n1
        let ex3: FPT = (n2 + n1 - 1)
        let sigma: FPT = sqrt((ex2 * ex1) / ((dtemp * dtemp * ex3)))
        let mean: FPT = (2 * n2 * n1) / dtemp + 1
        var z: FPT = 0
        dtemp =  Helpers.makeFP(r) - mean
        let pExact: FPT = FPT.nan
        var pAsymp: FPT = 0
        var cv: FPT
        do {
            cv = try SSProbDist.StandardNormal.quantile(p: 1 - alpha / 2)
        }
        catch {
            throw error
        }
        z = dtemp / sigma
        switch alternative {
        case .twoSided:
            pAsymp = 2 * min(SSProbDist.StandardNormal.cdf(u: z), 1 - SSProbDist.StandardNormal.cdf(u: z))
        case .less:
            pAsymp = SSProbDist.StandardNormal.cdf(u: z)
        case .greater:
            pAsymp = 1 - SSProbDist.StandardNormal.cdf(u: z)
        }
        var result: SSRunsTestResult<FPT> = SSRunsTestResult<FPT>()
        result.nGTEcp = n2
        result.nLTcp = n1
        result.nRuns = Double(r) as? FPT
        result.zStat = z
        result.pValueExact = pExact
        result.pValueAsymp = pAsymp
        result.cp = cp
        result.diffs = diff
        result.criticalValue = cv
        result.randomness = abs(z) <= cv
        return result
    }
    
    
}

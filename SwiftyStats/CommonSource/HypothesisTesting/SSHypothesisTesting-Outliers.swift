//
//  SSHypothesisTesting-Outliers.swift
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
    /// Performs the Grubbs outlier test
    /// - Parameter data: An Array<Double> containing the data
    /// - Parameter alpha: Alpha
    /// - Returns: SSGrubbsTestResult
    public static func grubbsTest<T, FPT>(array: Array<T>, alpha: FPT) throws -> SSGrubbsTestResult<T, FPT> where T: Codable & Comparable & Hashable, FPT: SSFloatingPoint & Codable {
        if array.count == 3 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample size is expected to be >= 3", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if alpha <= 0 || alpha >= 1 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Alpha must be > 0.0 and < 1.0", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if !Helpers.isNumber(array[0]) {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("expected numerical type", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            let examine = SSExamine<T, FPT>.init(withArray: array, name: nil, characterSet: nil)
            return try SSHypothesisTesting.grubbsTest(data: examine, alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    /************************************************************************************************/
    
    /// Performs the Grubbs outlier test
    /// - Parameter data: An Array<Double> containing the data
    /// - Parameter alpha: Alpha
    /// - Returns: SSGrubbsTestResult
    public static func grubbsTest<T, FPT>(data: SSExamine<T, FPT>, alpha: FPT) throws -> SSGrubbsTestResult<T, FPT>  where T: Codable & Comparable & Hashable, FPT: SSFloatingPoint & Codable {
        if data.sampleSize <= 3 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample size is expected to be >= 3", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if alpha <= 0 || alpha >= 1 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Alpha must be > 0.0 and < 1.0", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if !data.isNumeric {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("expected numerical type", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var g: FPT
        var maxDiff:FPT = 0
        let mean = data.arithmeticMean!
        let quantile: FPT
        var mi: FPT, ma: FPT
        if let s = data.standardDeviation(type: .unbiased) {
            ma =  Helpers.makeFP(data.maximum!)
            mi =  Helpers.makeFP(data.minimum!)
            maxDiff = max(abs(ma - mean), abs(mi - mean))
            g = maxDiff / s
            do {
                let pp: FPT = alpha / (2 *  Helpers.makeFP(data.sampleSize))
                quantile = try SSProbDist.StudentT.quantile(p: pp, degreesOfFreedom:  Helpers.makeFP(data.sampleSize - 2))
            }
            catch {
                throw error
            }
            let t2 = SSMath.pow1(quantile, 2)
            let e1: FPT =  Helpers.makeFP(data.sampleSize) - 1
            let e2: FPT = ( Helpers.makeFP(data.sampleSize) - 2 + t2)
            let e3: FPT = sqrt( Helpers.makeFP(data.sampleSize))
            let t: FPT = e1 * sqrt(t2 / e2) / e3
            var res:SSGrubbsTestResult<T, FPT> = SSGrubbsTestResult<T, FPT>()
            res.sampleSize = data.sampleSize
            res.maxDiff = maxDiff
            res.largest = data.maximum!
            res.smallest = data.minimum!
            res.criticalValue = t
            res.mean = mean
            res.G = g
            res.stdDev = s
            res.hasOutliers = g > t
            return res
        }
        else {
            return SSGrubbsTestResult()
        }
    }
    
    /************************************************************************************************/
    
    /// Returns p for run i
    fileprivate static func rosnerP<FPT: SSFloatingPoint & Codable>(alpha: FPT, sampleSize: Int, run i: Int) -> FPT {
        let n: FPT =  Helpers.makeFP(sampleSize)
        let ii: FPT =  Helpers.makeFP(i)
        var ex1: FPT
        var ex2: FPT
        var ex3: FPT
        var ex4: FPT
        ex1 = n - ii
        ex2 = ex1 + FPT.one
        ex3 = 2 * ex2
        ex4 = alpha / ex3
        return FPT.one - ex4
    }
    
    fileprivate static func rosnerLambdaRun<FPT: SSFloatingPoint & Codable>(alpha: FPT, sampleSize: Int, run i: Int!) -> FPT {
        let p: FPT = rosnerP(alpha: alpha, sampleSize: sampleSize, run: i)
        let df: FPT =  Helpers.makeFP(sampleSize - i - 1)
        var ex1: FPT
        var ex2: FPT
        var ex3: FPT
        var ex4: FPT
        let cdfStudentT: FPT
        do {
            cdfStudentT = try SSProbDist.StudentT.quantile(p: p, degreesOfFreedom: df)
        }
        catch {
            return FPT.nan
        }
        let num: FPT =  Helpers.makeFP(sampleSize - i) * cdfStudentT
        let ni: FPT =  Helpers.makeFP(sampleSize - i)
        ex1 = ni - FPT.one
        ex2 = ex1 + SSMath.pow1(cdfStudentT, 2)
        ex3 = df + 2
        ex4 = ex2 * ex3
        let denom: FPT = sqrt(ex4)
        return num / denom
    }
    
    
    /// Uses the Rosner test (generalized extreme Studentized deviate = ESD test) to detect up to maxOutliers outliers. This test is more accurate than the Grubbs test (for Grubbs test the suspected number of outliers must be specified exactly.)
    /// <img src="../img/esd.png" alt="">
    /// - Parameter data: Array<Double>
    /// - Parameter alpha: Alpha
    /// - Parameter maxOutliers: Upper bound for the number of outliers to detect
    /// - Parameter testType: SSESDTestType.lowerTail or SSESDTestType.upperTail or SSESDTestType.bothTailes (This should be default.)
    public static func esdOutlierTest<T: Codable & Comparable & Hashable, FPT: SSFloatingPoint & Codable>(array: Array<T>, alpha: FPT, maxOutliers: Int!, testType: SSESDTestType) throws -> SSESDTestResult<T, FPT>? {
        if array.count == 0 {
            return nil
        }
        if maxOutliers >= array.count {
            return nil
        }
        let examine: SSExamine<T, FPT> = SSExamine<T, FPT>.init(withArray: array, name: nil, characterSet: nil)
        do {
            return try SSHypothesisTesting.esdOutlierTest(data: examine, alpha: alpha, maxOutliers: maxOutliers, testType: testType)
        }
        catch {
            throw error
        }
    }
    
    
    /// Uses the Rosner test (generalized extreme Studentized deviate = ESD test) to detect up to maxOutliers outliers. This test is more accurate than the Grubbs test (for Grubbs test the suspected number of outliers must be specified exactly.)
    /// - Parameter data: Array<Double>
    /// - Parameter alpha: Alpha
    /// - Parameter maxOutliers: Upper bound for the number of outliers to detect
    /// - Parameter testType: SSESDTestType.lowerTail or SSESDTestType.upperTail or SSESDTestType.bothTailes (This should be default.)
    public static func esdOutlierTest<T: Codable & Comparable & Hashable, FPT: SSFloatingPoint & Codable>(data: SSExamine<T, FPT>, alpha: FPT, maxOutliers: Int!, testType: SSESDTestType) throws -> SSESDTestResult<T, FPT>? {
        if data.sampleSize == 0 {
            return nil
        }
        if !data.isNumeric {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("expected numerical type", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if maxOutliers >= data.sampleSize {
            return nil
        }
        let examine = data
        var sortedData = examine.elementsAsArray(sortOrder: .ascending)!
        let orgMean: FPT = examine.arithmeticMean!
        let sd: FPT = examine.standardDeviation(type: .unbiased)!
        var maxDiff: FPT = 0
        var difference: FPT = 0
        var currentMean: FPT = orgMean
        var currentSd = sd
        var currentTestStat: FPT = 0
        var currentLambda: FPT
        var itemToRemove: T
        var itemsRemoved: Array<T> = Array<T>()
        var means: Array<FPT> = Array<FPT>()
        var stdDevs: Array<FPT> = Array<FPT>()
        let currentData: SSExamine<T, FPT> = SSExamine<T, FPT>()
        var currentIndex: Int = 0
        var testStats: Array<FPT> = Array<FPT>()
        var lambdas: Array<FPT> = Array<FPT>()
        currentData.append(contentOf: sortedData)
        var i: Int = 0
        var k: Int = 1
        var t: FPT
        while k <= maxOutliers {
            i = 0
            while i <= (sortedData.count - 1) {
                t =  Helpers.makeFP(sortedData[i])
                currentMean = currentData.arithmeticMean!
                difference = abs(t - currentMean)
                if difference > maxDiff {
                    switch testType {
                    case .bothTails:
                        maxDiff = difference
                        currentIndex = i
                    case .lowerTail:
                        if t < currentMean {
                            maxDiff = difference
                            currentIndex = i
                        }
                    case .upperTail:
                        if t > currentMean {
                            maxDiff = difference
                            currentIndex = i
                        }
                    }
                }
                i = i + 1
            }
            itemToRemove = sortedData[currentIndex]
            currentSd = currentData.standardDeviation(type: .unbiased)!
            currentMean = currentData.arithmeticMean!
            currentTestStat = maxDiff / currentSd
            currentLambda = rosnerLambdaRun(alpha: alpha, sampleSize: examine.sampleSize, run: k)
            sortedData.remove(at: currentIndex)
            currentData.removeAll()
            currentData.append(contentOf: sortedData)
            testStats.append(currentTestStat)
            lambdas.append(currentLambda)
            itemsRemoved.append(itemToRemove)
            means.append(currentMean)
            stdDevs.append(currentSd)
            maxDiff = 0
            difference = 0
            k = k + 1
        }
        var countOfOL = 0
        var outliers: Array<T> = Array<T>()
        i = maxOutliers
        for i in stride(from: maxOutliers - 1, to: 0, by: -1) {
            if testStats[i] > lambdas[i] {
                countOfOL = i + 1
                break
            }
        }
        i = 0
        while i < countOfOL {
            outliers.append(itemsRemoved[i])
            i = i + 1
        }
        var res: SSESDTestResult<T, FPT> = SSESDTestResult<T, FPT>()
        res.alpha = alpha
        res.countOfOutliers = countOfOL
        res.itemsRemoved = itemsRemoved
        res.lambdas = lambdas
        res.maxOutliers = maxOutliers
        res.means = means
        res.outliers = outliers
        res.stdDeviations = stdDevs
        res.testStatistics = testStats
        res.testType = testType
        return res
    }
}

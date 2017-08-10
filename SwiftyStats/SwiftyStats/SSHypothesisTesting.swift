//
//  SSSSHypothesisTesting.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 20.07.17.
//  Copyright © 2017 VTSoftware. All rights reserved.
//
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
import os.log

public class SSHypothesisTesting {
    
    /************************************************************************************************/
    // MARK: Grubbs test
    
    /// Performs the Grubbs outlier test
    /// - Parameter data: An Array<Double> containing the data
    /// - Parameter alpha: Alpha
    /// - Returns: SSGrubbsTestResult
    public class func grubbsTest(data: Array<Double>, alpha: Double!) -> SSGrubbsTestResult? {
        if data.count == 0 {
            return nil
        }
        if alpha <= 0 || alpha >= 1.0 {
            os_log("Alpha must be > 0.0 and < 1.0", log: log_stat, type: .error)
            return nil
        }
        let examine = SSExamine<Double>.init(withArray: data, characterSet: nil)
        var g: Double
        var maxDiff = 0.0
        let mean = examine.arithmeticMean!
        let quantile: Double
        if let s = examine.standardDeviation(type: .unbiased) {
            maxDiff = maximum(t1: fabs(examine.maximum! - mean), t2: fabs(examine.minimum! - mean))
            g = maxDiff / s
            do {
                quantile = try SSProbabilityDistributions.quantileStudentTDist(p: alpha / (2.0 * Double(examine.sampleSize)), degreesOfFreedom: Double(examine.sampleSize) - 2.0)
            }
            catch {
                return nil
            }
            let t2 = pow(quantile, 2.0)
            let t = ( Double(examine.sampleSize) - 1.0 ) * sqrt(t2 / (Double(examine.sampleSize) - 2.0 + t2)) / sqrt(Double(examine.sampleSize))
            var res:SSGrubbsTestResult = SSGrubbsTestResult()
            res.sampleSize = examine.sampleSize
            res.maxDiff = maxDiff
            res.largest = examine.maximum!
            res.smallest = examine.minimum!
            res.criticalValue = t
            res.mean = mean
            res.G = g
            res.stdDev = s
            res.hasOutliers = g > t
            return res
        }
        else {
            return nil
        }
    }
    
    /************************************************************************************************/
    // MARK: ESD test
    
    /// Returns p for run i
    fileprivate class func rosnerP(alpha: Double!, sampleSize: Int!, run i: Int!) -> Double! {
        return 1.0 - ( alpha / ( 2.0 * (Double(sampleSize) - Double(i) + 1.0 ) ) )
    }
    
    fileprivate class func rosnerLambdaRun(alpha: Double!, sampleSize: Int!, run i: Int!) -> Double! {
        let p = rosnerP(alpha: alpha, sampleSize: sampleSize, run: i)
        let df = Double(sampleSize - i) - 1.0
        let cdfStudentT: Double
        do {
            cdfStudentT = try SSProbabilityDistributions.quantileStudentTDist(p: p, degreesOfFreedom: df)
        }
        catch {
            return Double.nan
        }
        let num = Double(sampleSize - i) * cdfStudentT
        let denom = sqrt((Double(sampleSize - i) - 1.0 + pow(cdfStudentT, 2.0 ) ) * ( df + 2.0 ) )
        return num / denom
    }
    
    
    /// Uses the Rosner test (generalized extreme Studentized deviate = ESD test) to detect up to maxOutliers outliers. This test ist more accurate than the Grubbs test (For Grubbs test the suspected number of outliers must be specified exactly.)
    /// - Parameter data: Array<Double>
    /// - Parameter alpha: Alpha
    /// - Parameter maxOutliers: Upper bound for the number of outliers to detect
    /// - Parameter testType: SSESDTestType.lowerTail or SSESDTestType.upperTail or SSESDTestType.bothTailes (This should be default.)
    public class func esdOutlierTest(data: Array<Double>, alpha: Double!, maxOutliers: Int!, testType: SSESDTestType) -> SSESDTestResult? {
        if data.count == 0 {
            return nil
        }
        if maxOutliers >= data.count {
            return nil
        }
        let examine = SSExamine<Double>.init(withArray: data, characterSet: nil)
        var sortedData = examine.elementsAsArray(sortOrder: .ascending)!
        // var dataRed: Array<Double> = Array<Double>()
        let orgMean: Double = examine.arithmeticMean!
        let sd: Double = examine.standardDeviation(type: .unbiased)!
        var maxDiff: Double = 0.0
        var difference: Double = 0.0
        var currentMean = orgMean
        var currentSd = sd
        var currentTestStat = 0.0
        var currentLambda: Double
        var itemToRemove: Double
        var itemsRemoved: Array<Double> = Array<Double>()
        var means: Array<Double> = Array<Double>()
        var stdDevs: Array<Double> = Array<Double>()
        let currentData: SSExamine<Double> = SSExamine<Double>()
        var currentIndex: Int = 0
        var testStats: Array<Double> = Array<Double>()
        var lambdas: Array<Double> = Array<Double>()
        currentData.append(fromArray: sortedData)
        var i: Int = 0
        var k: Int = 1
        var t: Double
        while k <= maxOutliers {
            i = 0
            while i <= (sortedData.count - 1) {
                t = sortedData[i]
                currentMean = currentData.arithmeticMean!
                difference = fabs(t - currentMean)
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
            currentData.append(fromArray: sortedData)
            testStats.append(currentTestStat)
            lambdas.append(currentLambda)
            itemsRemoved.append(itemToRemove)
            means.append(currentMean)
            stdDevs.append(currentSd)
            maxDiff = 0.0
            difference = 0.0
            k = k + 1
        }
        var countOfOL = 0
        var outliers: Array<Double> = Array<Double>()
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
        var res = SSESDTestResult()
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
    
    
    /// Returns the autocorrelation coefficient for a particular lag
    /// - Parameter data: Array<Double> object
    /// - Parameter lag: Lag
    /// - Throws: SSSwiftyStatsError iff data.count < 2
    public class func autocorrelationCoefficient(array: Array<Double>!, lag: Int!) throws -> Double {
        if array.count < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try autocorrelationCoefficient(data: SSExamine<Double>.init(withArray: array, characterSet: nil), lag: lag)
        }
        catch {
            throw error
        }
    }
    
    
    /// Returns the autocorrelation coefficient for a particular lag
    /// - Parameter data: SSExamine<Double> object
    /// - Parameter lag: Lag
    /// - Throws: SSSwiftyStatsError iff data.sampleSize < 2
    public class func autocorrelationCoefficient(data: SSExamine<Double>!, lag: Int!) throws -> Double {
        if data.sampleSize < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var r: Double
        var num: Double = 0.0
        var den: Double = 0.0
        let mean: Double = data.arithmeticMean!
        var i: Int = 0
        let n = data.sampleSize
        let elements = data.elementsAsArray(sortOrder: .original)!
        while i < n - 1 {
            num += (elements[i] - mean) * (elements[i + 1] - mean)
            i += 1
        }
        i = 0
        while i < n {
            den += pow(elements[i] - mean, 2.0)
            i += 1
        }
        r = num / den
        return r
    }
    
    
    /// Performs a Box-Ljung test for autocorrelation for all possible lags
    ///
    /// ### Usage ###
    /// ````
    /// let lew1: Array<Double> = [-213,-564,-35,-15,141,115,-420]
    /// let result: SSBoxLjungResult = try! SSHypothesisTesting.autocorrelation(data:lew1)
    /// ````
    /// - Parameter data: Array<Double>
    /// - Throws: SSSwiftyStatsError iff data.sampleSize < 2
    public class func autocorrelation(data: Array<Double>!) throws -> SSBoxLjungResult {
        if data.count < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let examine = SSExamine<Double>.init(withArray: data, characterSet: nil)
        do {
            return try autocorrelation(data: examine)
        }
        catch {
            throw error
        }
    }
    
    /// Performs a Box-Ljung test for autocorrelation for all possible lags
    ///
    /// ### Usage ###
    /// ````
    /// let lew1: Array<Double> = [-213,-564,-35,-15,141,115,-420]
    /// let lewdat = SSExamine<Double>.init(withArray: lew1, characterSet: nil)
    /// let result: SSBoxLjungResult = try! SSHypothesisTesting.autocorrelation(data:lewdat)
    /// ````
    /// - Parameter data: SSExamine object
    /// - Throws: SSSwiftyStatsError iff data.sampleSize < 2
    public class func autocorrelation(data: SSExamine<Double>!) throws -> SSBoxLjungResult {
        if data.sampleSize < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var acr = Array<Double>()
        var serWhiteNoise = Array<Double>()
        var serBartlett = Array<Double>()
        var statBoxLjung = Array<Double>()
        var sig = Array<Double>()
        var r: Double
        var num: Double = 0.0
        var den: Double = 0.0
        let mean: Double = data.arithmeticMean!
        var i: Int = 0
        var k: Int = 0
        let n = data.sampleSize
        let elements = data.elementsAsArray(sortOrder: .original)!
        while i < n {
            den += pow(elements[i] - mean, 2.0)
            i += 1
        }
        var l = 0
        while l <= n - 2 {
            i = 0
            while i < n - l {
                num += (elements[i] - mean) * (elements[i + l] - mean)
                i += 1
            }
            r = num / den
            acr.append(r)
            num = 0.0
            l += 1
        }
        var sum = 0.0
        let nr = 1.0 / Double(n)
        k = 0
        while k < acr.count {
            l = 1
            while l < k {
                sum += pow(acr[l], 2.0)
                l += 1
            }
            serBartlett.append(nr * (1.0 + 2.0 * sum))
            sum = 0.0
            k += 1
        }
        serBartlett[0] = 0.0
        serWhiteNoise.append(0.0)
        statBoxLjung.append(Double.infinity)
        sig.append(0.0)
        sum = 0.0
        let f = Double(n) * (Double(n) * 2.0)
        k = 1
        while k < acr.count {
            serWhiteNoise.append(sqrt(nr * ((Double(n) - Double(k)) / (Double(n) + 2.0))))
            l = 1
            while l <= k {
                sum += sum + (pow(acr[l], 2.0) / (Double(n) - Double(l)))
                l += 1
            }
            statBoxLjung.append(f * sum)
            do {
                try sig.append(1.0 - SSProbabilityDistributions.cdfChiSquareDist(chi: statBoxLjung[k], degreesOfFreedom: Double(k)))
            }
            catch {
                throw error
            }
            sum = 0.0
            k += 1
        }
        var coeff: Dictionary<String, Double> = Dictionary<String, Double>()
        var bartlettStandardError: Dictionary<String, Double> = Dictionary<String, Double>()
        var pValues: Dictionary<String, Double> = Dictionary<String, Double>()
        var boxLjungStatistics: Dictionary<String, Double> = Dictionary<String, Double>()
        var whiteNoiseStandardError: Dictionary<String, Double> = Dictionary<String, Double>()
        i = 0
        while i < acr.count {
            coeff["\(i)"] = acr[i]
            i += 1
        }
        i = 0
        while i < serBartlett.count {
            bartlettStandardError["\(i)"] = serBartlett[i]
            i += 1
        }
        i = 0
        while i < sig.count {
            pValues["\(i)"] = sig[i]
            i += 1
        }
        i = 0
        while i < statBoxLjung.count {
            boxLjungStatistics["\(i)"] = statBoxLjung[i]
            i += 1
        }
        i = 0
        while i < serWhiteNoise.count {
            whiteNoiseStandardError["\(i)"] = serWhiteNoise[i]
            i += 1
        }
        var result = SSBoxLjungResult()
        result.coefficients = acr
        result.seBartlett = serBartlett
        result.seWN = serWhiteNoise
        result.pValues = sig
        result.testStatistic = statBoxLjung
        return result
    }

    // MARK: Randomness
    
    /// Performs the runs test for the given sample. Tests for randomness.
    /// ### Important Note ###
    /// It is important that the data are numerical. To recode non-numerical data follow the procedure as described below.<br/>
    ///
    /// ````
    /// Suppose the original data is a string containing only "H" and "L":
    /// HLHHLHHLHLLHLHHL
    /// Setting "H" = 1 and "L" = 3 results in the recoded sequence:
    /// 1311311313313113
    /// In this case a cutting point of 2 must be used.
    /// Setting "H" = 1 and "L" = 2 results in the recoded sequence:
    /// 1211211212212112
    /// In this case a cutting point of 1.5 must be used.
    /// ````
    ///
    /// - Parameter data: Array<Double>
    /// - Parameter alpha: Alpha
    /// - Parameter useCuttingPoint: SSRunsTestCuttingPoint.median || SSRunsTestCuttingPoint.mean || SSRunsTestCuttingPoint.mode || SSRunsTestCuttingPoint.userDefined
    /// - Parameter cP: A user defined cutting point. Must not be nil if SSRunsTestCuttingPoint.userDefined is set
    /// - Throws: SSSwiftyStatsError iff data.sampleSize < 2
    public class func runsTest(array: Array<Double>!, alpha: Double!, useCuttingPoint useCP: SSRunsTestCuttingPoint, userDefinedCuttingPoint cuttingPoint: Double?, alternative: SSAlternativeHypotheses) throws -> SSRunsTestResult {
        if array.count < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try SSHypothesisTesting.runsTest(data: SSExamine<Double>.init(withArray: array, characterSet: nil), alpha: alpha, useCuttingPoint: useCP, userDefinedCuttingPoint: cuttingPoint, alternative: alternative)
        }
        catch {
            throw error
        }
    }
    
    
    /// Performs the runs test for the given sample. Tests for randomness.
    /// ### Important Note ###
    /// It is important that the data are numerical. To recode non-numerical data follow the procedure as described below.<br/>
    ///
    /// ````
    /// Suppose the original data is a string containing only "H" and "L":
    /// HLHHLHHLHLLHLHHL
    /// Setting "H" = 1 and "L" = 3 results in the recoded sequence:
    /// 1311311313313113
    /// In this case a cutting point of 2 must be used.
    /// Setting "H" = 1 and "L" = 2 results in the recoded sequence:
    /// 1211211212212112
    /// In this case a cutting point of 1.5 must be used.
    /// ````
    ///
    /// - Parameter data: Array<Double>
    /// - Parameter alpha: Alpha
    /// - Parameter useCuttingPoint: SSRunsTestCuttingPoint.median || SSRunsTestCuttingPoint.mean || SSRunsTestCuttingPoint.mode || SSRunsTestCuttingPoint.userDefined
    /// - Parameter cP: A user defined cutting point. Must not be nil if SSRunsTestCuttingPoint.userDefined is set
    /// - Throws: SSSwiftyStatsError iff data.sampleSize < 2
    public class func runsTest(data: SSExamine<Double>!, alpha: Double!, useCuttingPoint useCP: SSRunsTestCuttingPoint, userDefinedCuttingPoint cuttingPoint: Double?, alternative: SSAlternativeHypotheses) throws -> SSRunsTestResult {
        if data.sampleSize < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var diff = Array<Double>()
        let elements = data.elementsAsArray(sortOrder: .original)!
        var dtemp: Double = 0.0
        var n2: Double = 0.0
        var n1: Double = 0.0
        var r: Int = 1
        var cp: Double = 0.0
//        var isPrevPos: Bool
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
                os_log("no user defined cutting point specified", log: log_stat, type: .error)
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
            if dtemp >= 0.0 {
                n2 += 1.0
            }
            else {
                n1 += 1.0
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
        let sigma = sqrt((2.0 * n2 * n1 * (2.0 * n2 * n1 - n1 - n2)) / ((dtemp * dtemp * (n2 + n1 - 1.0))))
        let mean = (2.0 * n2 * n1) / dtemp + 1.0
        var z: Double = 0.0
        dtemp = Double(r) - mean
        let pExact: Double = Double.nan
        var pAsymp: Double = 0.0
        var cv: Double
        do {
            cv = try SSProbabilityDistributions.quantileStandardNormalDist(p: 1 - alpha / 2.0)
        }
        catch {
            throw error
        }
//        if n1 + n2 >= 60 {
            z = dtemp / sigma
//        }
//        else {
//            z = (dtemp - 0.5) / sigma
//        }
        switch alternative {
        case .twoSided:
            pAsymp = 2.0 * SSProbabilityDistributions.cdfStandardNormalDist(u: -fabs(z))
        case .less:
            pAsymp = SSProbabilityDistributions.cdfStandardNormalDist(u: z)
        case .greater:
            pAsymp = 1.0 - SSProbabilityDistributions.cdfStandardNormalDist(u: z)
        }
//        if pAsymp > 0.5 {
//            pAsymp = (1.0 - pAsymp) * 2.0
//        }
//        else {
//            pAsymp *= 2.0
//        }
//        if n1 + n2 <= 30 {
//            if r % 2 == 0 {
//                var rr = 2
//                var sum = 0.0
//                var q = 0.0
//                while rr <= r {
//                    q = Double(rr) / 2.0
//                    sum += binomial2(n1 - 1.0, q - 1.0) * binomial2(n2 - 1.0,q - 1)
//                    rr += 1
//                }
//                pExact = 2.0 * sum / binomial2((n1 + n2), n1)
//            }
//            else {
//                var rr = 2
//                var sum = 0.0
//                var q = 0.0
//                while rr <= r {
//                    q = Double(rr - 1) / 2.0
//                    sum += (binomial2(n1 - 1.0, q) * binomial2(n2 - 1.0, q - 1) / 2.0) + binomial2(n1 - 1.0, q - 1.0) * binomial2(n2 - 1.0, q)
//                    rr += 1
//                }
//                pExact = sum / binomial2((n1 + n2), n1)
//            }
//        }
        var result = SSRunsTestResult()
        result.nGTEcp = n2
        result.nLTcp = n1
        result.nRuns = Double(r)
        result.ZStatistic = z
        result.pValueExact = pExact
        result.pValueAsymp = pAsymp
        result.cp = cp
        result.diffs = diff
        result.criticalValue = cv
        result.randomness = fabs(z) <= cv
        return result
    }
    
    
//    public class func waldWolfowitzTwoSampleRunsTest<T>(array1: Array<T>)
    
    
    /************************************************************************************************/
    // MARK: GoF test
    
    /// Performs the goodness of fit test according to Kolmogorov and Smirnov
    /// The K-S distribution is computed according to Richard Simard and Pierre L'Ecuyer (Journal of Statistical Software March 2011, Volume 39, Issue 11.)
    /// ### Note ###
    /// Calls ksGoFTest(data: Array<Double>!, targetDistribution target: SSGoFTarget) throws -> SSKSTestResult?
    /// - Parameter data: Array<Double>
    /// - Parameter target: Distribution to test for
    /// - Throws: SSSwiftyStatsError if data.count < 2
    public class func kolmogorovSmirnovGoFTest(array: Array<Double>!, targetDistribution target: SSGoFTarget) throws -> SSKSTestResult? {
        if array.count >= 2 {
            do {
                return try ksGoFTest(data: SSExamine<Double>.init(withArray: array, characterSet: nil), targetDistribution: target)
            }
            catch {
                throw error
            }
        }
        else {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        
    }

    
    /// Performs the goodness of fit test according to Kolmogorov and Smirnov
    /// The K-S distribution is computed according to Richard Simard and Pierre L'Ecuyer (Journal of Statistical Software March 2011, Volume 39, Issue 11.)
    /// - Parameter data: Array<Double>
    /// - Parameter target: Distribution to test for
    /// - Throws: SSSwiftyStatsError if data.count < 2
    public class func ksGoFTest(array: Array<Double>!, targetDistribution target: SSGoFTarget) throws -> SSKSTestResult? {
        if array.count >= 2 {
            do {
                return try ksGoFTest(data: SSExamine<Double>.init(withArray: array, characterSet: nil), targetDistribution: target)
            }
            catch {
                throw error
            }
        }
        else {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        
    }
    
    
    /// Performs the goodness of fit test according to Kolmogorov and Smirnov.
    /// The K-S distribution is computed according to Richard Simard and Pierre L'Ecuyer (Journal of Statistical Software March 2011, Volume 39, Issue 11.)
    /// ### Note ###
    /// Calls ksGoFTest(data: SSExamine<Double>!, targetDistribution target: SSGoFTarget) throws -> SSKSTestResult?
    /// - Parameter data: SSExamine<Double>!
    /// - Parameter target: Distribution to test for
    /// - Throws: SSSwiftyStatsError if data.count < 2
    public class func kolmogorovSmirnovGoFTest(data: SSExamine<Double>!, targetDistribution target: SSGoFTarget) throws -> SSKSTestResult? {
        do {
            return try ksGoFTest(data: data, targetDistribution: target)
        }
        catch {
            throw error
        }
    }

    /// Performs the goodness of fit test according to Kolmogorov and Smirnov.
    /// The K-S distribution is computed according to Richard Simard and Pierre L'Ecuyer (Journal of Statistical Software March 2011, Volume 39, Issue 11.)
    /// - Parameter data: SSExamine<Double>!
    /// - Parameter target: Distribution to test for
    /// - Throws: SSSwiftyStatsError if data.count < 2
    public class func ksGoFTest(data: SSExamine<Double>!, targetDistribution target: SSGoFTarget) throws -> SSKSTestResult? {
        // error handling
        if data.sampleSize < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let sortedData = data.uniqueElements(sortOrder: .ascending)!
        var dD: Double = 0.0
        var dz: Double
        var dtestCDF: Double = 0.0
        var dtemp1: Double = 0.0
        var dmax1n: Double = 0.0
        var dmax2n: Double = 0.0
        var dmax1p: Double = 0.0
        var dmax2p: Double = 0.0
        var dmaxn: Double = 0.0
        var dmaxp: Double = 0.0
        var dest1: Double = 0.0
        var dest2: Double = 0.0
        var dest3: Double = 0.0
        var ii: Int = 0
        var ik: Int = 0
        var bok: Bool = false
        var bok1 = true
        var nt: Double
        var ecdf: Dictionary<Double, Double> = Dictionary<Double,Double>()
        var lds: Double = 0.0
        switch target {
        case .gaussian:
            dest1 = data.arithmeticMean!
            if let test = data.standardDeviation(type: .unbiased) {
                dest2 = test
            }
        case .exponential:
            dest3 = 0.0
            ik = 0
            for value in sortedData {
                if value <= 0 {
                    ik = ik + data.frequency(item: value)
                    dest3 = Double(ik) * value
                }
            }
            for value in sortedData {
                if value < 0 {
                    lds = 0
                }
                else {
                    lds = lds + Double(data.frequency(item: value)) / (Double(data.sampleSize) - Double(ik))
                }
                ecdf[value] = lds
            }
            if lds == 0.0 || ik > (data.sampleSize - 2) {
                bok1 = false
            }
            dest1 = (Double(data.sampleSize) - Double(ik)) / (data.total - dest3)
        case .uniform:
            dest1 = data.minimum!
            dest2 = data.maximum!
            ik = 0
        case .studentT:
            dest1 = Double(data.sampleSize)
            ik = 0
        case .laplace:
            dest1 = data.median!
            dest2 = data.medianAbsoluteDeviation(aroundReferencePoint: dest1)!
            ik = 0
        case .none:
            return nil
        }
        ii = 0
        for value in sortedData {
            switch target {
            case .gaussian:
                do {
                    dtestCDF = try SSProbabilityDistributions.cdfNormalDist(x: (value - dest1) / dest2, mean: 0, variance: 1)
                    bok = true
                }
                catch {
                    throw error
                }
            case .exponential:
                do {
                    dtestCDF = try SSProbabilityDistributions.cdfExponentialDist(x: value, lambda: dest1)
                    bok = true
                }
                catch {
                    throw error
                }
            case .uniform:
                do {
                    dtestCDF = try SSProbabilityDistributions.cdfUniformDist(x: value, lowerBound: dest1, upperBound: dest2)
                    bok = true
                }
                catch {
                    throw error
                }
            case .studentT:
                do {
                    dtestCDF = try SSProbabilityDistributions.cdfStudentTDist(t: value, degreesOfFreedom: dest1)
                    bok = true
                }
                catch {
                    throw error
                }
            case .laplace:
                do {
                    dtestCDF = try SSProbabilityDistributions.cdfLaplaceDist(x: value, mean: dest1, scale: dest2)
                    bok = true
                }
                catch {
                    throw error
                }
            case .none:
                return nil
            }
            if bok {
                if target == .exponential {
                    dtemp1 = ecdf[value]! - dtestCDF
                }
                else {
                    dtemp1 = data.empiricalCDF(of: value) - dtestCDF
                }
                if dtemp1 < dmax1n {
                    dmax1n = dtemp1
                }
                if dtemp1 > dmax1p {
                    dmax1p = dtemp1
                }
                if ii > 0 {
                    nt = sortedData[ii - 1]
                    if target == .exponential {
                        dtemp1 = ecdf[nt]! - dtestCDF
                    }
                    else {
                        dtemp1 = data.empiricalCDF(of: nt) - dtestCDF
                    }
                }
                else {
                    dtemp1 = -dtestCDF
                }
                if dtemp1 < dmax2n {
                    dmax2n = dtemp1
                }
                if dtemp1 > dmax2p {
                    dmax2p = dtemp1
                }
            }
            ii = ii + 1
        }
        dmaxn = (fabs(dmax1n) > fabs(dmax2n)) ? dmax1n : dmax2n
        dmaxp = (dmax1p > dmax2p) ? dmax1p : dmax2p
        dD = (fabs(dmaxn) > fabs(dmaxp)) ? fabs(dmaxn) : fabs(dmaxp)
        dz = sqrt(Double(data.sampleSize - ik)) * dD
        let dp: Double = 1.0 - KScdf(n: data.sampleSize, x: dD)
        var result = SSKSTestResult()
        switch target {
        case .gaussian:
            result.targetDistribution = .gaussian
            result.estimatedMean = dest1
            result.estimatedSd = dest2
            result.estimatedVar = dest2 * dest2
            result.pValue = dp
            result.maxAbsDifference = dD
            result.maxNegDifference = dmaxn
            result.maxPosDifference = dmaxp
            result.zStatistics = dz
            result.sampleSize = data.sampleSize
            
        case .exponential:
            result.targetDistribution = .exponential
            if bok1 {
                result.estimatedMean = 1.0 / dest1
            }
            if ik > 0 {
                result.infoString = "\(ik) elements skipped. User result with care!"
            }
            result.pValue = dp
            result.maxAbsDifference = dD
            result.maxNegDifference = dmaxn
            result.maxPosDifference = dmaxp
            result.zStatistics = dz
            result.sampleSize = data.sampleSize
        case .uniform:
            result.estimatedLowerBound = dest1
            result.estimatedUpperBound = dest2
            result.pValue = dp
            result.maxAbsDifference = dD
            result.maxNegDifference = dmaxn
            result.maxPosDifference = dmaxp
            result.zStatistics = dz
            result.sampleSize = data.sampleSize
        case .studentT:
            result.estimatedDegreesOfFreedom = dest1
            result.pValue = dp
            result.maxAbsDifference = dD
            result.maxNegDifference = dmaxn
            result.maxPosDifference = dmaxp
            result.zStatistics = dz
            result.sampleSize = data.sampleSize
        case .laplace:
            result.estimatedMean = dest1
            result.estimatedShapeParam = dest2
            result.pValue = dp
            result.maxAbsDifference = dD
            result.maxNegDifference = dmaxn
            result.maxPosDifference = dmaxp
            result.zStatistics = dz
            result.sampleSize = data.sampleSize
        case .none:
            break
        }
        return result
    }
    
    /************************************************************************************************/
    /************************************************************************************************/
    // Marsaglia et al.: Evaluating the Anderson-Darling Distribution. Journal of
    // Statistical Software 9 (2), 1–5. February 2004. http://www.jstatsoft.org/v09/i02
    /************************************************************************************************/
    /************************************************************************************************/
    
    fileprivate class func PRIV_ADf(_ z: Double!, _ j: Int!) -> Double {
        var t: Double
        var f: Double
        var fnew: Double
        var a: Double
        var b: Double
        var c: Double
        var r: Double
        var i: Int
        t = (4.0 * Double(j) + 1.0) * (4.0 * Double(j) + 1.0) * 1.23370055013617 / z
        if t > 150 {
            return 0.0
        }
        a = 2.22144146907918 * exp(-t) / sqrt(t)
        b = 3.93740248643060 * erfc(sqrt(t))
        r = z * 0.125
        f = a + b * r
        // 200
        i = 1
        while i < 500 {
            c = ((Double(i) - 0.5 - t) * b + t * a) / Double(i)
            a = b
            b = c
            r *= z / (8.0 * Double(i) + 8.0)
            if (fabs(r) < 1E-40 || fabs(c) < 1E-40) {
                return f
            }
            fnew = f + c * r
            if (f == fnew) {
                return f
            }
            f = fnew
            i += 1
        }
        return f
    }
    
    fileprivate class func PRIV_ADinf(_ z: Double!) -> Double {
        var j: Int
        var ad: Double
        var adnew: Double
        var r: Double
        if z < 0.01 {
            return 0.0
        }
        r = 1.0 / z
        ad = r * PRIV_ADf(z, 0)
        // 100
        j = 1
        while j < 400 {
            r *= (0.5 - Double(j)) / Double(j)
            adnew = ad + (4.0 * Double(j) + 1.0) * r * PRIV_ADf(z, j)
            if ad == adnew {
                return ad
            }
            ad = adnew
            j += 1
        }
        return ad
    }
    
    fileprivate class func PRIV_AD_Prob(_ n: Int,_ z: Double) -> Double {
        var c: Double
        var v: Double
        var x: Double
        x = PRIV_ADinf(z)
        /* now x=adinf(z). Next, get v=errfix(n,x) and return x+v; */
        if x > 0.8 {
            v = (-130.2137 + (745.2337 - (1705.091 - (1950.646 - (1116.360 - 255.7844 * x) * x) * x) * x) * x) / Double(n)
            return x + v
        }
        c = 0.01265 + 0.1757 / Double(n)
        if x < c {
            v = x / c
            v = sqrt(v) * (1.0 - v) * (49.0 * v - 102.0)
            return x + v * (0.0037 / pow(Double(n), 2.0) + 0.00078 / Double(n) + 0.00006) / Double(n)
        }
        v = (x - c)/(0.8 - c)
        v = -0.00022633 + (6.54034 - (14.6538 - (14.458 - (8.259 - 1.91864 * v) * v) * v) * v) * v
        return x + v * (0.04213 + 0.01365 / Double(n)) / Double(n)
    }
    
    /// Performs the Anderson Darling test for normality. Returns a SSADTestResult struct.
    /// Adapts an algorithm originally developed by Marsaglia et al.(Evaluating the Anderson-Darling Distribution. Journal of Statistical Software 9 (2), 1–5. February 2004)
    /// - Parameter data: Data as SSExamine object
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if data.count < 2
    public class func adNormalityTest(data: SSExamine<Double>!, alpha: Double!) throws -> SSADTestResult? {
        if !data.isEmpty {
            do {
                return try adNormalityTest(array: data.elementsAsArray(sortOrder: .original)!, alpha: alpha)
            }
            catch {
                throw error
            }
        }
        else {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
    }
    
    
    /// Performs the Anderson Darling test for normality. Returns a SSADTestResult struct.
    /// Adapts an algorithm originally developed by Marsaglia et al.(Evaluating the Anderson-Darling Distribution. Journal of Statistical Software 9 (2), 1–5. February 2004)
    /// - Parameter data: Data
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if data.count < 2
    public class func adNormalityTest(array: Array<Double>!, alpha: Double!) throws -> SSADTestResult? {
        var ad: Double = 0.0
        var a2: Double
        var estMean: Double
        var estSd: Double
        var n: Int
        var tempArray: Array<Double>
        var pValue: Double
        if array.count < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let _data: SSExamine<Double>
        do {
            _data = try SSExamine<Double>.init(withObject: array, levelOfMeasurement: .interval, characterSet: nil)
        }
        catch {
            os_log("unable to create examine object", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        estMean = _data.arithmeticMean!
        estSd = _data.standardDeviation(type: .unbiased)!
        n = _data.sampleSize
        tempArray = _data.elementsAsArray(sortOrder: .ascending)! as Array<Double>
        var i = 0
        var val: Double
        var val1: Double
        while i < n {
            val = tempArray[i]
            tempArray[i] = (val - estMean) / estSd
            i += 1
        }
        i = 0
        var k: Double
        while i < n {
            val = tempArray[i]
            val1 = tempArray[n - i - 1]
            k = Double(i)
            ad += (((2.0 * (k + 1) - 1.0) / Double(n)) * (log(SSProbabilityDistributions.cdfStandardNormalDist(u: val)) + log(1.0 - SSProbabilityDistributions.cdfStandardNormalDist(u: val1))))
            i += 1
        }
        a2 = -1.0 * Double(n) - ad
        ad = a2
        if n > 8 {
            a2 = a2 * (1.0 + 0.75 / Double(n) + 2.25 / (Double(n) * Double(n)))
        }
        pValue = 1.0 - PRIV_AD_Prob(n, a2)
        var result: SSADTestResult = SSADTestResult()
        result.pValue = pValue
        result.AD = ad
        result.ADStar = a2
        result.sampleSize = n
        result.stdDev = estSd
        result.variance = estSd * estSd
        result.mean = estMean
        result.isNormal = (pValue >= alpha)
        return result
    }
    
    /************************************************************************************************/
    // MARK: Equality of variances
    
    /// Performs the Bartlett test for two or more samples
    /// - Parameter data: Array containing samples as SSExamine objects
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if data.count < 2 or no variances are obtainable
    public class func bartlettTest(data: Array<SSExamine<Double>>!, alpha: Double!) throws -> SSVarianceEqualityTestResult? {
        if data.count < 2 {
            os_log("number of samples is expected to be > 1", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var array: Array<Array<Double>> = Array<Array<Double>>()
        for examine in data {
            if !examine.isEmpty {
                array.append(examine.elementsAsArray(sortOrder: .original)!)
            }
            else {
                os_log("sample size is expected to be > 2", log: log_stat, type: .error)
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
        }
        do {
            return try bartlettTest(array: array, alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    
    /// Performs the Bartlett test for two or more samples
    /// - Parameter data: Array containing samples
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if data.count < 2 or no variances are obtainable
    public class func bartlettTest(array: Array<Array<Double>>!, alpha: Double!) throws -> SSVarianceEqualityTestResult? {
        var _N = 0.0
        var _pS = 0.0
        var _s1 = 0.0
        var _s2 = 0.0
        var _k = 0.0
        var _df = 0.0
        var _testStatisticValue = 0.0
        var _cdfChiSquare = 0.0
        var _cutoff90Percent = 0.0
        var _cutoff95Percent = 0.0
        var _cutoff99Percent = 0.0
        var _cutoffAlpha = 0.0
        var _data:Array<SSExamine<Double>> = Array<SSExamine<Double>>()
        var result: SSVarianceEqualityTestResult
        if array.count < 2 {
            os_log("number of samples is expected to be > 1", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        for a in array {
            _data.append(SSExamine<Double>.init(withArray: a, characterSet: nil))
        }
        _k = Double(_data.count)
        for examine in _data {
            _N += Double(examine.sampleSize)
            if let v = examine.variance(type: .unbiased) {
                _s1 += (Double(examine.sampleSize) - 1.0) * log(v)
            }
            else {
                os_log("for at least one sample a variance is not obtainable", log: log_stat, type: .error)
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
        }
        for examine in _data {
            _pS += (Double(examine.sampleSize) - 1.0) * examine.variance(type: .unbiased)! / (_N - _k)
            _s2 += 1.0 / (Double(examine.sampleSize) - 1.0)
        }
        _testStatisticValue = ((_N - _k) * log(_pS) - _s1) / (1.0 + (1.0 / (3.0 * (_k - 1.0))) * (_s2 - 1.0 / (_N - _k)))
        do {
            _cdfChiSquare = try SSProbabilityDistributions.cdfChiSquareDist(chi: _testStatisticValue, degreesOfFreedom: _k - 1.0)
            _cutoff90Percent = try SSProbabilityDistributions.quantileChiSquareDist(p: 0.9, degreesOfFreedom: _k - 1.0)
            _cutoff95Percent = try SSProbabilityDistributions.quantileChiSquareDist(p: 0.95, degreesOfFreedom: _k - 1.0)
            _cutoff99Percent = try SSProbabilityDistributions.quantileChiSquareDist(p: 0.99, degreesOfFreedom: _k - 1.0)
            _cutoffAlpha = try SSProbabilityDistributions.quantileChiSquareDist(p: 1.0 - alpha, degreesOfFreedom: _k - 1.0)
            _df = _k - 1.0
            result = SSVarianceEqualityTestResult()
            result.testStatistic = _testStatisticValue
            result.pValue = 1.0 - _cdfChiSquare
            result.cv90Pct = _cutoff90Percent
            result.cv95Pct = _cutoff95Percent
            result.cv99Pct = _cutoff99Percent
            result.cvAlpha = _cutoffAlpha
            result.df = _df
            result.equality = !(_cdfChiSquare > (1.0 - alpha))
            return result
        }
        catch {
            throw error
        }
    }
    
    /// Performs the Levene / Brown-Forsythe test for two or more samples
    /// - Parameter data: Array containing SSExamine objects
    /// - Parameter testType: .median (Brown-Forsythe test), .mean (Levene test), .trimmedMean (10% trimmed mean)
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if data.count < 2 or no variances are obtainable
    public class func leveneTest(data: Array<SSExamine<Double>>!, testType: SSLeveneTestType, alpha: Double!) throws -> SSVarianceEqualityTestResult? {
        if data.count < 2 {
            os_log("number of samples is expected to be > 1", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var array: Array<Array<Double>> = Array<Array<Double>>()
        for examine in data {
            if !examine.isEmpty {
                array.append(examine.elementsAsArray(sortOrder: .original)!)
            }
            else {
                os_log("sample size is expected to be > 2", log: log_stat, type: .error)
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
        }
        do {
            return try leveneTest(array: array, testType: testType, alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    
    /// Performs the Levene / Brown-Forsythe test for two or more samples
    /// - Parameter data: Array containing samples
    /// - Parameter testType: .median (Brown-Forsythe test), .mean (Levene test), .trimmedMean (10% trimmed mean)
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if data.count < 2 or no variances are obtainable
    public class func leveneTest(array: Array<Array<Double>>!, testType: SSLeveneTestType, alpha: Double!) throws -> SSVarianceEqualityTestResult? {
        var _N = 0.0
        var _s1 = 0.0
        var _s2 = 0.0
        var _t = 0.0
        var _zMean = 0.0
        var _cutoff90Percent: Double
        var _cutoff95Percent: Double
        var _cutoff99Percent: Double
        var _cdfFRatio: Double
        var _cutoffAlpha: Double
        var _testStatisticValue: Double
        var _variancesAreEqual = false
        var _ntemp: Double
        var _k: Double
        var _data: Array<SSExamine<Double>> = Array<SSExamine<Double>>()
        if array.count < 2 {
            os_log("number of samples is expected to be > 1", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        for a in array {
            if array.count >= 2 {
                _data.append(SSExamine<Double>.init(withArray: a, characterSet: nil))
            }
            else {
                os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
        }
        _k = Double(_data.count)
        var _zi: Array<Double>
        var _zij: Array<Array<Double>>
        var _ni: Array<Double>
        var _y: Array<Array<Double>>
        var _means: Array<Double>
        var _temp: Array<Double>
        var i: Int
        var j: Int
        _ni = Array<Double>()
        _y = Array<Array<Double>>()
        _means = Array<Double>()
        do {
            for examine in _data {
                _ntemp = Double(examine.sampleSize)
                _N += _ntemp
                _ni.append(_ntemp)
                _y.append(examine.elementsAsArray(sortOrder: .original)!)
                switch testType {
                case .mean:
                    if let m = examine.arithmeticMean {
                        _means.append(m)
                    }
                    else {
                        return nil
                    }
                case .median:
                    if let m = examine.median {
                        _means.append(m)
                    }
                    else {
                        return nil
                    }
                case .trimmedMean:
                    if let m = try examine.trimmedMean(alpha: 0.1) {
                        _means.append(m)
                    }
                    else {
                        return nil
                    }
                }
            }
            _zi = Array<Double>()
            _zij = Array<Array<Double>>()
            _s2 = 0.0
            i = 0
            _temp = Array<Double>()
            while i < Int(_k) {
                _s1 = 0.0
                _temp.removeAll()
                j = 0
                while j < Int(_ni[i]) {
                    _t = fabs(_y[i][j] - _means[i])
                    _temp.append(_t)
                    _s1 += _t
                    _s2 += _t
                    j += 1
                }
                _zi.append(_s1 / _ni[i])
                _zij.append(_temp)
                i += 1
            }
            _zMean = _s2 / _N
            _s1 = 0.0
            _s2 = 0.0
            i = 0
            while i < Int(_k) {
                _s1 += _ni[i] * ((_zi[i] - _zMean) * (_zi[i] - _zMean))
                i += 1
            }
            i = 0
            while i < Int(_k) {
                j = 0
                while j < Int(_ni[i]) {
                    _s2 += (_zij[i][j] - _zi[i]) * (_zij[i][j] - _zi[i])
                    j += 1
                }
                i += 1
            }
            _testStatisticValue = ((_N - _k) * _s1) / ((_k - 1.0) * _s2)
            _cdfFRatio = try SSProbabilityDistributions.cdfFRatio(f: _testStatisticValue, numeratorDF: _k - 1.0, denominatorDF: _N - _k)
            _cutoffAlpha = try SSProbabilityDistributions.quantileFRatioDist(p: 1.0 - alpha, numeratorDF: _k - 1.0, denominatorDF: _N - _k)
            _cutoff90Percent = try SSProbabilityDistributions.quantileFRatioDist(p: 0.9, numeratorDF: _k - 1.0, denominatorDF: _N - _k)
            _cutoff95Percent = try SSProbabilityDistributions.quantileFRatioDist(p: 0.95, numeratorDF: _k - 1.0, denominatorDF: _N - _k)
            _cutoff99Percent = try SSProbabilityDistributions.quantileFRatioDist(p: 0.99, numeratorDF: _k - 1.0, denominatorDF: _N - _k)
            _variancesAreEqual = !(_testStatisticValue > _cutoffAlpha)
            var result = SSVarianceEqualityTestResult()
            result.cv90Pct = _cutoff90Percent
            result.cv99Pct = _cutoff99Percent
            result.cv95Pct = _cutoff95Percent
            result.pValue = 1.0 - _cdfFRatio
            result.cvAlpha = _cutoffAlpha
            result.testStatistic = _testStatisticValue
            result.equality = _variancesAreEqual
            result.df = Double.nan
            return result
        }
        catch {
            throw error
        }
    }
    
    /// Performs the Chi^2 variance equality test
    /// - Parameter data: Data as Array<Double>
    /// - Parameter s0: nominal variance
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if data.sampleSize < 2 || s0 <= 0
    public class func chiSquareVarianceTest(array: Array<Double>, nominalVariance s0: Double!, alpha: Double!) throws -> SSChiSquareVarianceTestResult? {
        if array.count < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if s0 <= 0 {
            os_log("nominal variance is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try chiSquareVarianceTest(sample: SSExamine<Double>.init(withArray: array, characterSet: nil), nominalVariance: s0, alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    /// Performs the Chi^2 variance equality test
    /// - Parameter sample: Data as SSExamine<Double>
    /// - Parameter s0: nominal variance
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if sample.sampleSize < 2 || s0 <= 0
    public class func chiSquareVarianceTest(sample: SSExamine<Double>, nominalVariance s0: Double!, alpha: Double!) throws -> SSChiSquareVarianceTestResult {
        if sample.sampleSize < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if s0 <= 0 {
            os_log("nominal variance is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            let df = Double(sample.sampleSize) - 1.0
            let ratio = sample.variance(type: .unbiased)! / s0
            let testStatisticValue = df * ratio
            let cdfChiSquare = try SSProbabilityDistributions.cdfChiSquareDist(chi: testStatisticValue, degreesOfFreedom: df)
            let twoTailed: Double
            let oneTailed: Double
            if cdfChiSquare > 0.5 {
                twoTailed = (1.0 - cdfChiSquare) * 2.0
                oneTailed = 1.0 - cdfChiSquare
            }
            else {
                twoTailed = cdfChiSquare * 2.0
                oneTailed = cdfChiSquare
            }
            var result = SSChiSquareVarianceTestResult()
            result.df = df
            result.ratio = ratio
            result.testStatisticValue = testStatisticValue
            result.p1Value = oneTailed
            result.p2Value = twoTailed
            result.sampleSize = Double(sample.sampleSize)
            result.sigmaUEQs0 = (cdfChiSquare < alpha || cdfChiSquare > (1.0 - alpha)) ? true : false
            result.sigmaLTEs0 = (cdfChiSquare < alpha) ? true : false
            result.sigmaGTEs0 = (cdfChiSquare > (1.0 - alpha)) ? true : false
            result.sd = sample.standardDeviation(type: .unbiased)
            return result
        }
        catch {
            throw error
        }
    }
    
    /// Performs the F ratio test for variance equality
    /// - Parameter data1: Data as Array<Double>
    /// - Parameter data1: Data as Array<Double>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff data1.sampleSize < 2 || data1.sampleSize < 2
    public class func fTestVarianceEquality(data1: Array<Double>!, data2: Array<Double>!, alpha: Double!) throws -> SSFTestResult {
        if data1.count < 2 {
            os_log("sample1 size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if data2.count < 2 {
            os_log("sample2 size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try SSHypothesisTesting.fTestVarianceEquality(sample1: SSExamine<Double>.init(withArray: data1, characterSet: nil), sample2: SSExamine<Double>.init(withArray: data2, characterSet: nil), alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    /// Performs the F ratio test for variance equality
    /// - Parameter sample1: Data as SSExamine<Double>
    /// - Parameter sample2: Data as SSExamine<Double>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff sample1.sampleSize < 2 || sample1.sampleSize < 2
    public class func fTestVarianceEquality(sample1: SSExamine<Double>!, sample2: SSExamine<Double>!, alpha: Double!) throws -> SSFTestResult {
        if sample1.sampleSize < 2 {
            os_log("sample1 size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if sample2.sampleSize < 2 {
            os_log("sample2 size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let s1: Double
        let s2: Double
        let testStat: Double
        if let a = sample1.variance(type: .unbiased), let b = sample2.variance(type: .unbiased) {
            s1 = a
            s2 = b
            testStat = s1 / s2
        }
        else {
            os_log("error in obtaining the f ratio", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let df1 = Double(sample1.sampleSize) - 1.0
        let df2 = Double(sample2.sampleSize) - 1.0
        let cdfTestStat: Double
        do {
            cdfTestStat = try SSProbabilityDistributions.cdfFRatio(f: testStat, numeratorDF: df1, denominatorDF: df2)
        }
        catch {
            throw error
        }
        var pVVarEqual: Double
        if cdfTestStat > 0.5 {
            pVVarEqual = 2.0 * (1.0 - cdfTestStat)
        }
        else {
            pVVarEqual = 2.0 * cdfTestStat
        }
        let pVVar1LTEVar2 = 1.0 - cdfTestStat
        let pVVar1GTEVar2 = cdfTestStat
        var var1EQvar2: Bool
        var var1GTEvar2: Bool
        var var1LTEvar2: Bool
        if pVVarEqual < alpha {
            var1EQvar2 = false
        }
        else {
            var1EQvar2 = true
        }
        if pVVar1LTEVar2 < alpha {
            var1LTEvar2 = false
        }
        else {
            var1LTEvar2 = true
        }
        if pVVar1GTEVar2 < alpha {
            var1GTEvar2 = false
        }
        else {
            var1GTEvar2 = true
        }
        var ciTwoSidedAlphaLower: Double
        var ciTwoSidedAlphaUpper: Double
        var ciLessAlphaLower: Double
        var ciLessAlphaUpper: Double
        var ciGreaterAlphaLower: Double
        var ciGreaterAlphaUpper: Double
        do {
            ciTwoSidedAlphaUpper = try (testStat / SSProbabilityDistributions.quantileFRatioDist(p: alpha / 2.0, numeratorDF: df1, denominatorDF: df2))
            ciTwoSidedAlphaLower = try (testStat * SSProbabilityDistributions.quantileFRatioDist(p: alpha / 2.0, numeratorDF: df2, denominatorDF: df1))
            ciLessAlphaLower = 0.0
            ciLessAlphaUpper = try (testStat / SSProbabilityDistributions.quantileFRatioDist(p: alpha, numeratorDF: df1, denominatorDF: df2))
            ciGreaterAlphaLower = try (testStat * SSProbabilityDistributions.quantileFRatioDist(p: alpha, numeratorDF: df2, denominatorDF: df1))
            ciGreaterAlphaUpper = Double.infinity
        }
        catch {
            throw error
        }
        var result = SSFTestResult()
        result.sampleSize1 = Double(sample1.sampleSize)
        result.sampleSize2 = Double(sample2.sampleSize)
        result.dfNumerator = df1
        result.dfDenominator = df2
        result.variance1 = s1;
        result.variance2 = s2;
        result.FRatio = testStat;
        result.p2Value = pVVarEqual;
        result.p1Value = pVVarEqual / 2.0;
        result.FRatioEQ1 = var1EQvar2;
        result.FRatioGTE1 = var1GTEvar2;
        result.FRatioLTE1 = var1LTEvar2;
        var cieq = SSConfIntv()
        cieq.lowerBound = ciTwoSidedAlphaLower
        cieq.upperBound = ciTwoSidedAlphaUpper
        cieq.intervalWidth = ciTwoSidedAlphaUpper - ciTwoSidedAlphaLower
        var cilt = SSConfIntv()
        cilt.intervalWidth = ciLessAlphaUpper - ciLessAlphaLower;
        cilt.lowerBound = ciLessAlphaLower;
        cilt.upperBound = ciLessAlphaUpper;
        var cigt = SSConfIntv()
        cigt.intervalWidth = ciGreaterAlphaUpper - ciGreaterAlphaLower;
        cigt.lowerBound = ciGreaterAlphaLower;
        cigt.upperBound = ciGreaterAlphaUpper;
        result.ciRatioEQ1 = cieq
        result.ciRatioGTE1 = cigt
        result.ciRatioLTE1 = cilt
        return result
    }
    
    /************************************************************************************************/
    // MARK: t-Tests
    
    
    /// Performs the two sample t test
    /// - Parameter sample1: Data1 as Array<Double>
    /// - Parameter sample2: Data2 as Array<Double>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff sample1.sampleSize < 2 || sample2.sampleSize < 2
    public class func twoSampleTTest(data1: Array<Double>!, data2: Array<Double>, alpha: Double!) throws -> SSTwoSampleTTestResult {
        if data1.count < 2 {
            os_log("sample1 size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if data2.count < 2 {
            os_log("sample2 size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let sample1 = SSExamine<Double>.init(withArray: data1, characterSet: nil)
        let sample2 = SSExamine<Double>.init(withArray: data2, characterSet: nil)
        do {
            return try twoSampleTTest(sample1: sample1, sample2: sample2, alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    /// Performs the two sample t test
    /// - Parameter sample1: Data1 as SSExamine<Double>
    /// - Parameter sample2: Data2 as SSExamine<Double>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff sample1.sampleSize < 2 || sample2.sampleSize < 2
    public class func twoSampleTTest(sample1: SSExamine<Double>!, sample2: SSExamine<Double>, alpha: Double!) throws -> SSTwoSampleTTestResult {
        if sample1.sampleSize < 2 {
            os_log("sample1 size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if sample2.sampleSize < 2 {
            os_log("sample2 size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var cdfLeveneMedian: Double = 0.0
        var cdfTValueEqualVariances: Double = 0.0
        var cdfTValueUnequalVariances: Double = 0.0
        var dfEqualVariances: Double = 0.0
        var dfUnequalVariances: Double = 0.0
        var differenceInMeans: Double = 0.0
        var mean1: Double = 0.0
        var mean2: Double = 0.0
        var criticalValueEqualVariances: Double = 0.0
        var criticalValueUnequalVariances: Double = 0.0
        var pooledStdDev: Double = 0.0
        var pooledVariance: Double = 0.0
        var stdDev1: Double = 0.0
        var stdDev2: Double = 0.0
        var tValueEqualVariances: Double = 0.0
        var tValueUnequalVariances: Double = 0.0
        var variancesAreEqualMedian: Bool = false
        var twoTailedEV: Double = 0.0
        var twoTailedUEV: Double = 0.0
        var oneTailedEV: Double = 0.0
        var oneTailedUEV: Double = 0.0
        var var1: Double = 0.0
        var var2: Double = 0.0
        let n1 = Double(sample1.sampleSize)
        let n2 = Double(sample2.sampleSize)
        var1 = sample1.variance(type: .unbiased)!
        var2 = sample2.variance(type: .unbiased)!
        mean1 = sample1.arithmeticMean!
        mean2 = sample2.arithmeticMean!
        let k = (var1 / n1) / ((var1 / n1) + (var2 / n2))
        dfUnequalVariances = ceil( 1.0 / ( ( (k * k) / (n1 - 1.0) ) + ( (1.0 - ( k + k) + k * k) / (n2 - 1.0) ) ) )
        dfEqualVariances = n1 + n2 - 2.0
        stdDev1 = sample1.standardDeviation(type: .unbiased)!
        stdDev2 = sample2.standardDeviation(type: .unbiased)!
        pooledVariance = ((n1 - 1.0) * var1 + (n2 - 1.0) * var2) / dfEqualVariances
        pooledStdDev = sqrt(pooledVariance)
        differenceInMeans = mean1 - mean2
        tValueEqualVariances = differenceInMeans / (pooledStdDev * sqrt(1.0 / n1 + 1.0 / n2))
        tValueUnequalVariances = differenceInMeans / sqrt(var1 / n1 + var2 / n2)
        do {
            cdfTValueEqualVariances = try SSProbabilityDistributions.cdfStudentTDist(t: tValueEqualVariances, degreesOfFreedom: dfEqualVariances)
            cdfTValueUnequalVariances = try SSProbabilityDistributions.cdfStudentTDist(t: tValueUnequalVariances, degreesOfFreedom: dfUnequalVariances)
            criticalValueEqualVariances = try SSProbabilityDistributions.quantileStudentTDist(p: 1.0 - alpha, degreesOfFreedom: dfEqualVariances)
            criticalValueUnequalVariances = try SSProbabilityDistributions.quantileStudentTDist(p: 1.0 - alpha, degreesOfFreedom: dfUnequalVariances)
            let lArray:Array<SSExamine<Double>> = [sample1, sample2]
            if let leveneResult: SSVarianceEqualityTestResult = try leveneTest(data: lArray, testType: .median, alpha: alpha) {
                cdfLeveneMedian = leveneResult.pValue!
                variancesAreEqualMedian = leveneResult.equality!
            }
            else {
                os_log("data are not sufficient. skewness/kurtosis not obtainable", log: log_stat, type: .error)
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
            if cdfTValueEqualVariances > 0.5 {
                twoTailedEV = (1.0 - cdfTValueEqualVariances) * 2.0
                oneTailedEV = 1.0 - cdfTValueEqualVariances
            }
            else {
                twoTailedEV = cdfTValueEqualVariances * 2.0
                oneTailedEV = cdfTValueEqualVariances
            }
            if cdfTValueEqualVariances > 0.5 {
                twoTailedUEV = (1.0 - cdfTValueUnequalVariances) * 2.0
                oneTailedUEV = 1.0 - cdfTValueUnequalVariances
            }
            else {
                twoTailedUEV = cdfTValueUnequalVariances * 2.0
                oneTailedUEV = cdfTValueUnequalVariances
            }
            let effectSize_EV = sqrt((tValueEqualVariances * tValueEqualVariances) / ((tValueEqualVariances * tValueEqualVariances) + dfEqualVariances))
            let effectSize_UEV = sqrt((tValueUnequalVariances * tValueUnequalVariances) / ((tValueUnequalVariances * tValueUnequalVariances) + dfUnequalVariances))
            // Welch
            let var1OverN1 = var1 / n1
            let var2OverN2 = var2 / n2
            let sumVar = var1OverN1 + var2OverN2
            let denomnatorWelchDF = (var1 * var1 ) / ( n1 * n1 * (n1 - 1.0)) + ( var2 * var2 ) / ( n2 * n2 * (n2 - 1.0))
            let welchT = (mean1 - mean2) / sqrt(var1OverN1 + var2OverN2 )
            let welchDF = (sumVar * sumVar) / denomnatorWelchDF
            let cdfWelch = try SSProbabilityDistributions.cdfStudentTDist(t: welchT, degreesOfFreedom: welchDF)
            var twoSidedWelch: Double
            var oneTailedWelch: Double
            if cdfWelch > 0.5 {
                twoSidedWelch = (1.0 - cdfWelch) * 2.0
                oneTailedWelch = 1.0 - cdfWelch
            }
            else {
                twoSidedWelch = cdfWelch * 2.0
                oneTailedWelch = cdfWelch
            }
            var result: SSTwoSampleTTestResult = SSTwoSampleTTestResult()
            result.p2EQVAR = twoTailedEV
            result.p2UEQVAR = twoTailedUEV
            result.p1UEQVAR = oneTailedUEV
            result.p1EQVAR = oneTailedEV
            result.mean1 = mean1
            result.mean2 = mean2
            result.sampleSize1 = n1
            result.sampleSize2 = n2
            result.stdDev1 = stdDev1
            result.stdDev2 = stdDev2
            result.pooledStdDev = pooledStdDev
            result.pooledVariance = pooledVariance
            result.differenceInMeans  = differenceInMeans
            result.tEQVAR = tValueEqualVariances
            result.tUEQVAR = tValueUnequalVariances
            result.LeveneP = cdfLeveneMedian
            result.dfEQVAR = dfEqualVariances
            result.dfUEQVAR = dfUnequalVariances
            result.mean1GTEmean2 = variancesAreEqualMedian ? ((cdfTValueEqualVariances > (1.0 - alpha)) ? true : false) : ((cdfTValueUnequalVariances > (1.0 - alpha)) ?  true : false)
            result.mean1LTEmean2 = (variancesAreEqualMedian) ? ((cdfTValueEqualVariances < alpha) ? true : false) : ((cdfTValueUnequalVariances < alpha) ? true : false)
            result.mean1EQmean2 = (variancesAreEqualMedian) ? ((cdfTValueEqualVariances >= alpha && cdfTValueEqualVariances <= (1.0 - alpha)) ? true : false) : ((cdfTValueUnequalVariances >= alpha && cdfTValueUnequalVariances <= (1.0 - alpha)) ? true : false)
            result.mean1UEQmean2 = (variancesAreEqualMedian) ? ((cdfTValueEqualVariances < alpha || cdfTValueEqualVariances > (1.0 - alpha)) ? true : false ) : ((cdfTValueUnequalVariances < alpha || cdfTValueUnequalVariances > (1.0 - alpha)) ? true : false)
            result.CVEQVAR = criticalValueEqualVariances
            result.CVUEQVAR = criticalValueUnequalVariances
            result.rUEQVAR = effectSize_UEV
            result.rEQVAR = effectSize_EV
            result.tWelch = welchT
            result.dfWelch = welchDF
            result.p2Welch = twoSidedWelch
            result.p1Welch = oneTailedWelch
            return result
        }
        catch {
            throw error
        }
    }
    
    
    /// Performs the one sample t test
    /// - Parameter sample: Data as SSExamine<Double>
    /// - Parameter mean: Reference mean
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff sample.sampleSize < 2
    public class func oneSampleTTest(sample: SSExamine<Double>, mean: Double!, alpha: Double!) throws -> SSOneSampleTTestResult {
        if sample.sampleSize < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var testStatisticValue: Double = 0.0
        var pValue: Double = 0.0
        let N = Double(sample.sampleSize)
        let diffmean = sample.arithmeticMean! - mean
        let twoTailed: Double
        let oneTailed: Double
        do {
            testStatisticValue = diffmean / (sample.standardDeviation(type: .unbiased)! / sqrt(N))
            pValue = try SSProbabilityDistributions.cdfStudentTDist(t: testStatisticValue, degreesOfFreedom: N - 1.0)
            if pValue > 0.5 {
                twoTailed = (1.0 - pValue) * 2.0
                oneTailed = 1.0 - pValue
            }
            else {
                twoTailed = pValue * 2.0
                oneTailed = pValue
            }
            var result = SSOneSampleTTestResult()
            result.p1Value = oneTailed
            result.p2Value = twoTailed
            result.tStat = testStatisticValue
            result.cv90Pct = try SSProbabilityDistributions.quantileStudentTDist(p: 1 - 0.05, degreesOfFreedom: N - 1.0)
            result.cv95Pct = try SSProbabilityDistributions.quantileStudentTDist(p: 1 - 0.025, degreesOfFreedom: N - 1.0)
            result.cv99Pct = try SSProbabilityDistributions.quantileStudentTDist(p: 1 - 0.005, degreesOfFreedom: N - 1.0)
            result.mean = sample.arithmeticMean!
            result.sampleSize = N
            result.mean0 = mean
            result.difference = diffmean
            result.stdDev = sample.standardDeviation(type: .unbiased)!
            result.stdErr = sample.standardError!
            result.df = N - 1.0
            result.meanEQtestValue = ((pValue < (alpha / 2.0)) || (pValue > (1.0 - (alpha / 2.0)))) ? false : true
            result.meanLTEtestValue = (pValue < alpha) ? true : false
            result.meanGTEtestValue = (pValue > (1.0 - alpha)) ? true : false
            return result
        }
        catch {
            throw error
        }
    }
    
    /// Performs the one sample t test
    /// - Parameter data: Data as Array<Double>
    /// - Parameter mean: Reference mean
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff sample.sampleSize < 2
    public class func oneSampleTTEst(data: Array<Double>!, mean: Double!, alpha: Double!) throws -> SSOneSampleTTestResult {
        if data.count < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let sample:SSExamine<Double> = SSExamine<Double>.init(withArray: data, characterSet: nil)
        do {
            return try oneSampleTTest(sample: sample, mean: mean, alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    /// Performs the t test for matched pairs
    /// - Parameter set1: data of set1 as SSExamine<Double>
    /// - Parameter set2: data of set2 as SSExamine<Double>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff set1.sampleSize < 2 || set2.sampleSize < 2 || (set1.sampleSize != set2.sampleSize)
    public class func matchedPairsTTest(set1: SSExamine<Double>!, set2: SSExamine<Double>, alpha: Double!) throws -> SSMatchedPairsTTestResult {
        if set1.sampleSize < 2 || set2.sampleSize < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set1.sampleSize != set2.sampleSize {
            os_log("sample sizes are expected to be equal", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let m1 = set1.arithmeticMean!
        let m2 = set2.arithmeticMean!
        let s1 = set1.variance(type: .unbiased)!
        let s2 = set2.variance(type: .unbiased)!
        let diffMeans = m1 - m2
        let a1 = set1.elementsAsArray(sortOrder: .original)!
        let a2 = set2.elementsAsArray(sortOrder: .original)!
        var sum: Double = 0.0
        let n: Int = set1.sampleSize
        var i: Int = 0
        let pSum = m1 * m2
        while i < n {
            sum += a1[i] * a2[i] - pSum
            i += 1
        }
        let df = Double(n) - 1.0
        let cov = sum / df
        let sed = sqrt((s1 + s2 - 2.0 * cov) / (df + 1.0))
        let sdDiff = sqrt(s1 + s2 - 2.0 * cov)
        let t = diffMeans / sed
        let corr = cov / (sqrt(s1) * sqrt(s2))
        do {
            let pCorr = try (2.0 * (1.0 - SSProbabilityDistributions.cdfStudentTDist(t: corr * sqrt(df - 1.0) / (1.0 - corr * corr), degreesOfFreedom: df - 1.0)))
            let lowerCIDiff =  try (diffMeans - SSProbabilityDistributions.quantileStudentTDist(p: 0.975, degreesOfFreedom: df) * sed)
            let upperCIDiff =  try (diffMeans + SSProbabilityDistributions.quantileStudentTDist(p: 0.975, degreesOfFreedom: df) * sed)
            var pTwoTailed = try SSProbabilityDistributions.cdfStudentTDist(t: t, degreesOfFreedom: df)
            if pTwoTailed > 0.5 {
                pTwoTailed = 1.0 - pTwoTailed
            }
            pTwoTailed *= 2.0
            if sed.isZero {
                pTwoTailed = 1.0
            }
            let effectSize = sqrt((t * t) / ((t * t) + df))
            var result = SSMatchedPairsTTestResult()
            result.sampleSize = Double(n)
            result.covariance = cov
            result.stdEDiff = sed
            result.stdDevDiff = sdDiff
            result.tStat = t
            result.correlation = corr
            result.pValueCorr = pCorr
            result.p2Value = pTwoTailed
            result.effectSizeR = effectSize
            result.ci95lower = lowerCIDiff
            result.ci95upper = upperCIDiff
            result.df = df
            return result
        }
        catch {
            throw error
        }
    }
    
    /// Performs the t test for matched pairs
    /// - Parameter set1: data of set1 as Array<Double>
    /// - Parameter set2: data of set2 as Array<Double>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff data1.count < 2 || data2.count < 2 || data1.count != data2.count
    public class func matchedPairsTTest(data1: Array<Double>!, data2: Array<Double>, alpha: Double!) throws -> SSMatchedPairsTTestResult {
        if data1.count < 2 || data2.count < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if data1.count != data2.count {
            os_log("sample sizes are expected to be equal", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let set1 = SSExamine<Double>.init(withArray: data1, characterSet: nil)
        let set2 = SSExamine<Double>.init(withArray: data2, characterSet: nil)
        do {
            return try matchedPairsTTest(set1: set1, set2: set2, alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    
    /// Performs a one way ANOVA (multiple means test)
    /// - Parameter data: data as Array<Double>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff data.count <= 2
    public class func oneWayANOVA(data: Array<Array<Double>>!, alpha: Double!) throws -> SSOneWayANOVATestResult? {
        if data.count <= 2 {
            os_log("number of samples is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try SSHypothesisTesting.multipleMeansTest(data: data, alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    /// Performs a one way ANOVA (multiple means test)
    /// - Parameter data: data as SSExamine<Double>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff data.count <= 2
    public class func oneWayANOVA(data: Array<SSExamine<Double>>!, alpha: Double!) throws -> SSOneWayANOVATestResult? {
        if data.count <= 2 {
            os_log("number of samples is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try SSHypothesisTesting.multipleMeansTest(data: data, alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    /// Performs a one way ANOVA (multiple means test)
    /// - Parameter data: data as Array<Double>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff data.count <= 2
    public class func multipleMeansTest(data: Array<Array<Double>>!, alpha: Double!) throws -> SSOneWayANOVATestResult? {
        if data.count <= 2 {
            os_log("number of samples is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var examines: Array<SSExamine<Double>> = Array<SSExamine<Double>>()
        for array in data {
            examines.append(SSExamine<Double>.init(withArray: array, characterSet: nil))
        }
        do {
            return try SSHypothesisTesting.multipleMeansTest(data: examines, alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    /// Performs a one way ANOVA (multiple means test)
    /// - Parameter data: data as SSExamine<Double>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff data.count <= 2
    public class func multipleMeansTest(data: Array<SSExamine<Double>>!, alpha: Double!) throws -> SSOneWayANOVATestResult? {
        if data.count <= 2 {
            os_log("number of samples is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var overallMean: Double
        var sum: Double = 0.0
        var N: Int = 0
        var pBartlett: Double
        var pLevene: Double
        var numerator = 0.0
        var denominator = 0.0
        var testStatistics: Double
        var pValue: Double
        var cdfValue: Double
        var cutoffAlpha: Double
        var meansEqual: Bool
        let groups: Double = Double(data.count)
        do {
            if let bartlettTest = try SSHypothesisTesting.bartlettTest(data: data, alpha: alpha), let leveneTest = try SSHypothesisTesting.leveneTest(data: data, testType: .median, alpha: alpha) {
                pBartlett = bartlettTest.pValue!
                pLevene = leveneTest.pValue!
            }
            else {
                return nil
            }
        }
        catch {
            throw error
        }
        for examine in data {
            if examine.sampleSize == 0 {
                os_log("at least one sample is empty", log: log_stat, type: .error)
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
            sum += examine.total
            N += examine.sampleSize
        }
        overallMean = sum / Double(N)
        for examine in data {
            numerator += pow(examine.arithmeticMean! - overallMean, 2.0) * Double(examine.sampleSize)
            denominator += (Double(examine.sampleSize) - 1.0) * examine.variance(type: .unbiased)!
        }
        testStatistics = ((Double(N) - groups) / (groups - 1.0)) * numerator / denominator
        do {
            cdfValue = try SSProbabilityDistributions.cdfFRatio(f: testStatistics, numeratorDF: groups - 1.0 , denominatorDF: Double(N) - groups)
            cutoffAlpha = try SSProbabilityDistributions.quantileFRatioDist(p: 1.0 - alpha, numeratorDF: groups - 1.0, denominatorDF: Double(N) - groups)
        }
        catch {
            throw error
        }
        pValue = 1.0 - cdfValue
        meansEqual = testStatistics <= cutoffAlpha
        var result = SSOneWayANOVATestResult()
        result.p2Value = pValue
        result.FStatistic = testStatistics
        result.alpha = alpha
        result.meansEQUAL = meansEqual
        result.cv = cutoffAlpha
        result.pBartlett = pBartlett
        result.pLevene = pLevene
        return result
    }
    
    // MARK: non parametric
    
    
    /// Algorithm AS 62 Applied Statistics (1973) Vol 22, No. 2
    fileprivate class func cdfMannWhitney(U: Double!, m: Int!, n: Int!) throws -> Double {
        // Algorithm AS 62 Applied Statistics (1973) Vol 22, No. 2
        if m <= 0 || n <= 0 {
            os_log("m and n is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if U > (Double(m) * Double(n)) {
            return Double.nan
        }
        var freq: Array<Double> = Array<Double>.init(repeating: 0.0, count: m * n * 2)
        var work: Array<Double> = Array<Double>.init(repeating: 0.0, count: m * n * 2)
        var minmn: Int
        var maxmmn: Int
        var mn1: Int
        var n1: Int
        var i: Int
        var _in: Int
        var l: Int
        var k: Int
        var j: Int
        var sum: Double
        let one = 1.0
        let zero = 0.0
        minmn = minimum(t1: m, t2: n)
        if minmn < 1 {
            os_log("m and n is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        mn1 = m * n + 1
        maxmmn = maximum(t1: m, t2: n)
        n1 = maxmmn + 1
        i = 1
        while i <= n1 {
            freq[i - 1] = one
            i += 1
        }
        if minmn > 1 {
            n1 = n1 + 1
            i = n1
            while i <= mn1 {
                freq[i - 1] = zero
                i += 1
            }
            work[0] = zero
            _in = maxmmn
            i = 2
            while i <= minmn {
                work[i - 1] = zero
                _in = _in + maxmmn
                n1 = _in + 2
                l = 1 + _in / 2
                k = i
                j = 1
                
                while j <= l {
                    k = k + 1
                    n1 = n1 - 1
                    sum = freq[j - 1] + work[j - 1]
                    freq[j - 1] = sum
                    work[k - 1] = sum - freq[n1 - 1]
                    freq[n1 - 1] = sum
                    j += 1
                }
                i += 1
            }
        }
        sum = 0.0
        i = 1
        while i <= mn1 {
            sum = sum + freq[i - 1]
            freq[i - 1] = sum
            i += 1
        }
        i = 1
        while i <= mn1 {
            freq[i - 1] = freq[i - 1] / sum
            i += 1
        }
        return freq[Int(floor(U))]
    }

    /// Returns the sum of i for i = start...end
    fileprivate class func sumUp(start: Int!, end: Int!) -> Double {
        var sum = Double(start)
        var i: Int = start
        while i < end {
            sum += Double(i)
            i += 1
        }
        return sum
    }


    /// Ranking
    /// - Parameter set1: set1
    /// - Parameter set2: set2
    /// - Parameter identifierSet1: identifier for set1
    /// - Parameter identifierSet2: identifier for set2
    /// - Parameter inout ranks: contains the ranks upon return
    /// - Parameter inout groups: contains the grpups upon return
    /// - Parameter inout sumRanksSet1: contains the sum of ranks for set1 upon return
    /// - Parameter inout sumRanksSet2: contains the sum of ranks for set2 upon return
    fileprivate class func rank2Arrays<T, U>(array1: Array<T>!, array2: Array<T>!, identifierSet1: U!, identifierSet2: U!, ranks: inout Array<Double>, groups: inout Array<U>, ties: inout Array<Double>, sumRanksSet1: inout Double, sumRanksSet2: inout Double) -> Bool where T: Comparable, T: Hashable, U: Comparable, U: Hashable{
        var hasTies: Bool = false
        let set1:SSExamine<T> = SSExamine<T>.init(withArray: array1, characterSet: nil)
        let set2:SSExamine<T> = SSExamine<T>.init(withArray: array2, characterSet: nil)
        let a = set1.elementsAsArray(sortOrder: .original)
        let b = set2.elementsAsArray(sortOrder: .original)
        var combined: Array<T> = a!
        combined.append(contentsOf: b!)
        var combined_sorted = combined.sorted(by: {$0 < $1})
        var i: Int = 0
        var k: Int = 1
        var sum: Double = 1.0
        while i <= combined_sorted.count - 1 {
            // determine frequencies in set1 and set2
            let freq1 = set1.frequency(item: combined_sorted[i])
            let freq2 = set2.frequency(item: combined_sorted[i])
            if set1.contains(item: combined_sorted[i]) && set2.contains(item: combined_sorted[i]) {
                hasTies = true
                let freq: Int = freq1 + freq2
                ties.append(Double(freq))
                k = 1
                sum = 0.0
                while k <= freq {
                    sum += Double(i + k)
                    k += 1
                }
                k = 1
                while k <= freq {
                    ranks.append(sum / Double(freq))
                    if k <= set1.frequency(item: combined_sorted[i])  {
                        groups.append(identifierSet1)
                    }
                    else {
                        groups.append(identifierSet2)
                    }
                    k += 1
                }
                i += freq
            }
            else if set1.contains(item: combined_sorted[i]) {
                if freq1 > 1 {
                    ties.append(Double(freq1))
                    k = 1
                    sum = 0.0
                    while k <= freq1 {
                        sum += Double(i + k)
                        k += 1
                    }
                    k = 1
                    while k <= freq1 {
                        ranks.append(sum / Double(freq1))
                        groups.append(identifierSet1)
                        k += 1
                    }
                    i += freq1
                }
                else {
                    ranks.append(Double(i + 1))
                    groups.append(identifierSet1)
                    i += 1
                }
            }
            else if set2.contains(item: combined_sorted[i]) {
                if freq2 > 1 {
                    ties.append(Double(freq2))
                    k = 1
                    sum = 0.0
                    while k <= freq2 {
                        sum += Double(i + k)
                        k += 1
                    }
                    k = 1
                    while k <= freq2 {
                        ranks.append(sum / Double(freq2))
                        groups.append(identifierSet2)
                        k += 1
                    }
                    i += freq2
                }
                else {
                    ranks.append(Double(i + 1))
                    groups.append(identifierSet2)
                    i += 1
                }
            }
        }
        i = 0
        while i < ranks.count {
            if groups[i] == identifierSet1 {
                sumRanksSet1 = sumRanksSet1 + ranks[i]
            }
            else {
                sumRanksSet2 = sumRanksSet2 + ranks[i]
            }
            i += 1
        }
        return hasTies

    }
    
    /// Ranking
    /// - Parameter set1: set1
    /// - Parameter set2: set2
    /// - Parameter identifierSet1: identifier for set1
    /// - Parameter identifierSet2: identifier for set2
    /// - Parameter inout ranks: contains the ranks upon return
    /// - Parameter inout groups: contains the grpups upon return
    /// - Parameter inout sumRanksSet1: contains the sum of ranks for set1 upon return
    /// - Parameter inout sumRanksSet2: contains the sum of ranks for set2 upon return
    fileprivate class func rank2Arrays<T, U>(set1: SSExamine<T>!, set2: SSExamine<T>!, identifierSet1: U!, identifierSet2: U!, ranks: inout Array<Double>, groups: inout Array<U>, sortedItems: inout Array<T>, ties: inout Array<Double>, sumRanksSet1: inout Double, sumRanksSet2: inout Double) -> Bool where T: Comparable, T: Hashable, U: Comparable, U: Hashable {
        var hasTies: Bool = false
        let a = set1.elementsAsArray(sortOrder: .original)!
        let b = set2.elementsAsArray(sortOrder: .original)!
        var combined: Array<T> = a
        combined.append(contentsOf: b)
        var combined_sorted = combined.sorted(by: {$0 < $1})
        var i: Int = 0
        var k: Int = 1
        var sum: Double = 1.0
        while i <= combined_sorted.count - 1 {
            // determine frequencies in set1 and set2
            let freq1 = set1.frequency(item: combined_sorted[i])
            let freq2 = set2.frequency(item: combined_sorted[i])
            if set1.contains(item: combined_sorted[i]) && set2.contains(item: combined_sorted[i]) {
                hasTies = true
                let freq: Int = freq1 + freq2
                ties.append(Double(freq))
                k = 1
                sum = 0.0
                while k <= freq {
                    sum += Double(i + k)
                    k += 1
                }
                k = 1
                while k <= freq {
                    ranks.append(sum / Double(freq))
                    if k <= set1.frequency(item: combined_sorted[i])  {
                        groups.append(identifierSet1)
                        sortedItems.append(combined_sorted[i])
                    }
                    else {
                        groups.append(identifierSet2)
                        sortedItems.append(combined_sorted[i])
                    }
                    k += 1
                }
                i += freq
            }
            else if set1.contains(item: combined_sorted[i]) {
                if freq1 > 1 {
                    ties.append(Double(freq1))
                    k = 1
                    sum = 0.0
                    while k <= freq1 {
                        sum += Double(i + k)
                        k += 1
                    }
                    k = 1
                    while k <= freq1 {
                        ranks.append(sum / Double(freq1))
                        groups.append(identifierSet1)
                        sortedItems.append(combined_sorted[i])
                        k += 1
                    }
                    i += freq1
                }
                else {
                    ranks.append(Double(i + 1))
                    groups.append(identifierSet1)
                    sortedItems.append(combined_sorted[i])
                    i += 1
                }
            }
            else if set2.contains(item: combined_sorted[i]) {
                if freq2 > 1 {
                    ties.append(Double(freq2))
                    k = 1
                    sum = 0.0
                    while k <= freq2 {
                        sum += Double(i + k)
                        k += 1
                    }
                    k = 1
                    while k <= freq2 {
                        ranks.append(sum / Double(freq2))
                        groups.append(identifierSet2)
                        sortedItems.append(combined_sorted[i])
                        k += 1
                    }
                    i += freq2
                }
                else {
                    ranks.append(Double(i + 1))
                    groups.append(identifierSet2)
                    sortedItems.append(combined_sorted[i])
                    i += 1
                }
            }
        }
        i = 0
        while i < ranks.count {
            if groups[i] == identifierSet1 {
                sumRanksSet1 = sumRanksSet1 + ranks[i]
            }
            else {
                sumRanksSet2 = sumRanksSet2 + ranks[i]
            }
            i += 1
        }
        return hasTies
    }
    
    /// Perform the Mann-Whitney U test for independent samples.
    /// ### Note ###
    /// If there are ties between the sets, only an asymptotic p-value is returned. Exact p-values are computed using the Algorithm by Dineen and Blakesley (1973)
    /// - Parameter set1: Observations of group1 as Array<T>
    /// - Parameter set2: Observations of group2 as Array<T>
    /// - Throws: SSSwiftyStatsError iff set1.sampleSize <= 2 || set2.sampleSize <= 2
    public class func mannWhitneyUTest<T>(set1: Array<T>!, set2: Array<T>!)  throws -> SSMannWhitneyUTestResult where T: Comparable, T: Hashable {
        if set1.count <= 2 {
            os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.count <= 2 {
            os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try mannWhitneyUTest(set1: SSExamine<T>.init(withArray: set1, characterSet: nil) , set2: SSExamine<T>.init(withArray: set2, characterSet: nil))
        }
        catch {
            throw error
        }
    }
    
    /// Perform the Mann-Whitney U test for independent samples.
    /// ### Note ###
    /// If there are ties between the sets, only an asymptotic p-value is returned. Exact p-values are computed using the Algorithm by Dineen and Blakesley (1973)
    /// - Parameter set1: Observations of group1
    /// - Parameter set2: Observations of group2
    /// - Throws: SSSwiftyStatsError iff set1.sampleSize <= 2 || set2.sampleSize <= 2
    public class func mannWhitneyUTest<T>(set1: SSExamine<T>!, set2: SSExamine<T>!)  throws -> SSMannWhitneyUTestResult where T: Comparable, T: Hashable {
        if set1.sampleSize <= 2 {
            os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.sampleSize <= 2 {
            os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var ranks:Array<Double> = Array<Double>()
        var groups:Array<String> = Array<String>()
        var ties: Array<Double> = Array<Double>()
        var sortedData: Array<T> = Array<T>()
        var sumRanksSet1: Double = 0.0
        var sumRanksSet2: Double = 0.0
        var hasTies: Bool
        hasTies = rank2Arrays(set1: set1, set2: set2, identifierSet1: "A", identifierSet2: "B", ranks: &ranks, groups: &groups, sortedItems: &sortedData, ties: &ties, sumRanksSet1: &sumRanksSet1, sumRanksSet2: &sumRanksSet2)
        let U1 = (Double(set1.sampleSize) * Double(set2.sampleSize)) + (Double(set1.sampleSize) * (Double(set1.sampleSize) + 1)) / 2.0 - sumRanksSet1
        let U2 = (Double(set1.sampleSize) * Double(set2.sampleSize)) + (Double(set2.sampleSize) * (Double(set2.sampleSize) + 1)) / 2.0 - sumRanksSet2
        let nm = Double(set1.sampleSize) * Double(set2.sampleSize)
        let n1 = Double(set1.sampleSize)
        let n2 = Double(set2.sampleSize)
        if (U1 + U2) != nm {
            os_log("internal error", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .internalError, file: #file, line: #line, function: #function)
        }
        let S = n1 + n2
        var z: Double = 0.0
        var pasymp1: Double = 0.0
        var pasymp2: Double = 0.0
        var pexact1: Double = 0.0
        var pexact2: Double = 0.0
        
        z = Double.nan
        var temp1: Double = 0.0
        var denom: Double = 0.0
        var num: Double = 0.0
        var i: Int = 0
        let U: Double
        if U1 > (n1 * n2) / 2.0 {
            U = nm - U1
        }
        else {
            U = U1
        }
        if hasTies {
            while i < ties.count {
                temp1 += (pow(Double(ties[i]), 3.0) - ties[i]) / 12.0
                i += 1
            }
            denom = sqrt((nm / (S * (S - 1.0))) * ((pow(S, 3.0) - S) / 12.0 - temp1))
            num = fabs(U - nm / 2.0)
            z = num / denom
            pasymp1 = 1.0 - SSProbabilityDistributions.cdfStandardNormalDist(u: fabs(z))
            pasymp2 = pasymp1 * 2.0
            pexact1 = Double.nan
            pexact2 = Double.nan
        }
        else {
            z = fabs(U - nm / 2.0) / sqrt((nm * (n1 + n2 + 1)) / 12.0)
            if (n1 * n2) <= 400 && ((n1 * n2) + minimum(t1: n1, t2: n2)) <= 220 {
                do {
                    if U <= (n1 * n2 + 1) / 2.0 {
                        pexact1 = try cdfMannWhitney(U: U, m: set1.sampleSize, n: set2.sampleSize)
                    }
                    else {
                        pexact1 = try cdfMannWhitney(U: U, m: set1.sampleSize, n: set2.sampleSize)
                        pexact1 = 1.0 - pexact1
                    }
                    pexact2 = 2.0 * pexact1
                }
                catch {
                    throw error
                }
            }
            else {
                pexact1 = Double.nan
                pexact2 = Double.nan
            }
            pasymp1 = 1.0 - SSProbabilityDistributions.cdfStandardNormalDist(u: fabs(z))
            pasymp2 = 2.0 * pasymp1
        }
        let W = sumRanksSet2
        var result = SSMannWhitneyUTestResult()
        result.sumRanks1 = sumRanksSet1
        result.sumRanks2 = sumRanksSet2
        result.meanRank1 = sumRanksSet1 / n1
        result.meanRank2 = sumRanksSet2 / n2
        result.UMannWhitney = U
        result.WilcoxonW = W
        result.ZStatistic = z
        result.p2Approx = pasymp2
        result.p2Exact = pexact2
        result.p1Approx = pasymp1
        result.p1Exact = pexact1
        result.effectSize = z / sqrt(n1 + n2)
        return result
    }

    /// Performs the Wilcoxon signed ranks test for matched pairs
    /// - Parameter set1: Observations 1 as Array<Double>
    /// - Parameter set2: Observations 2 as Array<Double>
    /// - Throws: SSSwiftyStatsError iff set1.count <= 2 || set1.count <= 2 || set1.count != set2.count
    public class func wilcoxonMatchedPairs(set1: Array<Double>!, set2: Array<Double>!) throws -> SSWilcoxonMatchedPairsTestResult {
        if set1.count <= 2 {
            os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.count <= 2 {
            os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set1.count != set2.count {
            os_log("sample size of set 1 is expected to be equal to sample size of set2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try SSHypothesisTesting.wilcoxonMatchedPairs(set1: SSExamine<Double>.init(withArray: set1, characterSet: nil), set2: SSExamine<Double>.init(withArray: set2, characterSet: nil))
        }
        catch {
            throw error
        }
    }
    
    
    /// Performs the Wilcoxon signed ranks test for matched pairs
    /// - Parameter set1: Observations 1
    /// - Parameter set2: Observations 2
    /// - Throws: SSSwiftyStatsError iff set1.sampleSize <= 2 || set1.sampleSize <= 2 || set1.sampleSize != set2.sampleSize
    public class func wilcoxonMatchedPairs(set1: SSExamine<Double>!, set2: SSExamine<Double>!) throws -> SSWilcoxonMatchedPairsTestResult {
        if set1.sampleSize <= 2 {
            os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.sampleSize <= 2 {
            os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set1.sampleSize != set2.sampleSize {
            os_log("sample size of set 1 is expected to be equal to sample size of set2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var i: Int
        var np: Int = 0
        var nn: Int = 0
        var nties: Int = 0
        var temp: Double = 0.0
        var diff:Array<Double> = Array<Double>()
        let a1: Array<Double> = set1.elementsAsArray(sortOrder: .original)!
        let a2: Array<Double> = set2.elementsAsArray(sortOrder: .original)!
        let N = set1.sampleSize
        i = 0
        while i < N {
            temp = a2[i] - a1[i]
            if temp < 0.0 {
                nn += 1
            }
            else if temp > 0.0 {
                np += 1
            }
            if temp != 0.0 {
                diff.append(temp)
            }
            i += 1
        }
        var sorted = diff.sorted(by: {fabs($0) < fabs($1) } )
        var signs: Array<Double> = Array<Double>()
        var absDiffSorted:Array<Double> = Array<Double>()
        i = 0
        while i < sorted.count {
            signs.append(sorted[i] > 0.0 ? 1.0 : -1.0)
            absDiffSorted.append(fabs(sorted[i]))
            i += 1
        }
        let examine = SSExamine<Double>.init(withArray: absDiffSorted, characterSet: nil)
        var ranks: Array<Double> = Array<Double>()
        var ties: Array<Double> = Array<Double>()
        var ptemp: Int
        var freq: Int
        var sum: Double = 0.0
        let n = absDiffSorted.count
        var pos: Int = 0
        while pos < n {
            ptemp = pos + 1
            sum = Double(ptemp)
            freq = examine.frequency(item: absDiffSorted[pos])
            if freq == 1 {
                ranks.append(sum)
                pos += 1
            }
            else {
                nties += 1
                ties.append(Double(freq))
                sum = Double(freq) * Double(ptemp) + sumUp(start: 1, end: freq - 1)
                i = 1
                while i <= freq {
                    ranks.append(sum / Double(freq))
                    i += 1
                }
                pos = ptemp + freq - 1
            }
        }
        var nposranks: Int = 0
        var nnegranks: Int = 0
        var sumposranks: Double = 0.0
        var sumnegranks: Double = 0.0
        var meanposranks: Double
        var meannegranks: Double
        i = 0
        while i < n {
            if signs[i] == 1.0 {
                nposranks += 1
                sumposranks += ranks[i]
            }
            else {
                nnegranks += 1
                sumnegranks += ranks[i]
            }
            i += 1
        }
        if sumnegranks + sumposranks != (Double(n) * (Double(n) + 1.0)) / 2.0 {
            os_log("internal error", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .internalError, file: #file, line: #line, function: #function)
        }
        meannegranks = nnegranks > 0 ? sumnegranks / Double(nnegranks) : 0.0
        meanposranks = nposranks > 0 ? sumposranks / Double(nposranks) : 0.0
        var z: Double
        var ts: Double = 0.0
        i = 0
        while i < ties.count {
            ts += (pow(ties[i], 3.0) - ties[i]) / 48.0
            i += 1
        }
        z = (fabs(min(sumnegranks, sumposranks) - (Double(n) * (Double(n) + 1.0) / 4.0))) / sqrt(Double(n) * (Double(n) + 1.0) * (2.0 * Double(n) + 1.0) / 24.0 - ts)
        let p = 1.0 - SSProbabilityDistributions.cdfStandardNormalDist(u: fabs(z))
        let cohenD = fabs(z) / sqrt(2.0 * Double(N))
        var result = SSWilcoxonMatchedPairsTestResult()
        result.p2Value = 2.0 * p
        result.sampleSize = Double(N)
        result.nPosRanks = nposranks
        result.nNegRanks = nnegranks
        result.nTies = nties
        result.nZeroDiff = N - np - nn
        result.sumNegRanks = sumnegranks
        result.sumPosRanks = sumposranks
        result.meanPosRanks = meanposranks
        result.meanNegRanks = meannegranks
        result.ZStatistic = z
        result.dCohen = cohenD
        return result
    }

    
    /// Performs the sign test
    /// - Parameter set1: Observations 1
    /// - Parameter set2: Observations 2
    /// - Throws: SSSwiftyStatsError iff set1.count <= 2 || set1.count <= 2 || set1.count != set2.count
    public class func signTest(set1: Array<Double>, set2: Array<Double>) throws -> SSSignTestRestult {
        if set1.count <= 2 {
            os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.count <= 2 {
            os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set1.count != set2.count {
            os_log("sample size of set 1 is expected to be equal to sample size of set2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try signTest(set1: SSExamine<Double>.init(withArray: set1, characterSet: nil), set2: SSExamine<Double>.init(withArray: set2, characterSet: nil))
        }
        catch {
            throw error
        }
    }
    
    /// Performs the sign test
    /// - Parameter set1: Observations 1
    /// - Parameter set2: Observations 2
    /// - Throws: SSSwiftyStatsError iff set1.sampleSize <= 2 || set1.sampleSize <= 2 || set1.sampleSize != set2.sampleSize
    public class func signTest(set1: SSExamine<Double>, set2: SSExamine<Double>) throws -> SSSignTestRestult {
        if set1.sampleSize <= 2 {
            os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.sampleSize <= 2 {
            os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set1.sampleSize != set2.sampleSize {
            os_log("sample size of set 1 is expected to be equal to sample size of set2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let a1 = set1.elementsAsArray(sortOrder: .original)!
        let a2 = set2.elementsAsArray(sortOrder: .original)!
        var np: Int = 0
        var nn: Int = 0
        var nties: Int = 0
        var temp: Double = 0.0
        var i: Int = 0
        while i < a1.count {
            temp = a2[i] - a1[i]
            if temp > 0.0 {
                np += 1
            }
            else if temp < 0.0 {
                nn += 1
            }
            else {
                nties += 1
            }
            i += 1
        }
        var pexact: Double = 0.0
        var z: Double
        let nnpnp = nn + np
        let r = min(np,nn)
        temp = Double(max(nn, np))
        if nnpnp <= 1000 {
            i = 0
            while i <= r {
                pexact += binomial2(Double(nnpnp), Double(i)) * pow(0.5, Double(nnpnp))
                i += 1
            }
        }
        z = (temp - 0.5 * Double(nnpnp) - 0.5)
        z = -1.0 * z / (0.5 * sqrt(Double(nnpnp)))
        let pasymp = SSProbabilityDistributions.cdfStandardNormalDist(u: z)
        var result = SSSignTestRestult()
        result.pValueExact = pexact
        result.pValueApprox = pasymp
        result.nPosDiff = np
        result.nNegDiff = nn
        result.nTies = nties
        result.total = set1.sampleSize
        result.ZStatistic = z
        return result
    }
    
    /// Performs the binomial test
    /// ### Note ###
    /// - H<sub>0</sub>: The probability of success is equal to p0
    /// - H<sub>a1</sub>: the probability of success is not equal to p0 (two sided)
    /// - H<sub>a2</sub>: the probability of success is less than p0 (one sided)
    /// - H<sub>a3</sub>: the probability of success is greater than p0 (one sided)
    ///
    /// - Parameter data: Dichotomous data
    /// - Parameter p0: Probability
    /// - Throws: SSSwiftyStatsError iff data.sampleSize <= 2 || data.uniqueElements(sortOrder: .none)?.count)! > 2
    public class func binomialTest(numberOfSuccess success: Int!, numberOfTrials trials: Int!, probability p0: Double!, alpha: Double!, alternative: SSAlternativeHypotheses) -> Double {
        if p0.isNaN {
            return Double.nan
        }
        var pV: Double = 0.0
        var pV1: Double = 0.0
        let q = 1.0 - p0
        var i: Int
        switch alternative {
        case .less:
            pV = SSProbabilityDistributions.cdfBinomialDistribution(k: success, n: trials, probability: p0, tail: .lower)
        case .greater:
            pV = SSProbabilityDistributions.cdfBinomialDistribution(k: trials - success, n: trials, probability: q, tail: .lower)
        case .twoSided:
            // algorithm adapted fropm R function binom.test
            var c1: Int = 0
            let d = SSProbabilityDistributions.pdfBinomialDistribution(k: success, n: trials, probability: p0)
            let m = Double(trials) * p0
            if success == Int(ceil(m)) {
                pV = 1.0
            }
            else if success < Int(ceil(m)) {
                i = Int(ceil(m))
                for j in i...trials {
                    if SSProbabilityDistributions.pdfBinomialDistribution(k: j, n: trials, probability: p0) <= (d * (1.0 + 1E-7)) {
                        c1 = j - 1
                        break
                    }
                }
                pV = SSProbabilityDistributions.cdfBinomialDistribution(k: success, n: trials, probability: p0, tail: .lower)
                pV1 = SSProbabilityDistributions.cdfBinomialDistribution(k: c1, n: trials, probability: p0, tail: .upper)
                pV = pV + pV1
            }
            else {
                i = 0
                for j in 0...Int(floor(m)) {
                    if SSProbabilityDistributions.pdfBinomialDistribution(k: j, n: trials, probability: p0) <= (d * (1.0 + 1E-7)) {
                        c1 = j + 1
                    }
                }
                pV = SSProbabilityDistributions.cdfBinomialDistribution(k: c1 - 1, n: trials, probability: p0, tail: .lower)
                pV1 = SSProbabilityDistributions.cdfBinomialDistribution(k: success - 1, n: trials, probability: p0, tail: .upper)
                pV = pV + pV1
            }
        }
        return pV
    }

    
    fileprivate class func lowerBoundCIBinomial(success: Double!, trials: Double!, alpha: Double) throws -> Double {
        var res: Double
        if success == 0 {
            res = 0.0
        }
        else {
            do {
                res = try SSProbabilityDistributions.quantileBetaDist(p: alpha, shapeA: success, shapeB: trials - success + 1)
//                res = try SSProbabilityDistributions.quantileBetaDist(p: alpha, shapeA: success + 0.5, shapeB: trials - success + 0.5)
            }
            catch {
                throw error
            }
        }
        return res
    }

    fileprivate class func upperBoundCIBinomial(success: Double!, trials: Double!, alpha: Double) throws -> Double {
        var res: Double
        if success == trials {
            res = 1.0
        }
        else {
            do {
                res = try SSProbabilityDistributions.quantileBetaDist(p: 1.0 - alpha, shapeA: success + 1, shapeB: trials - success)
//                res = try SSProbabilityDistributions.quantileBetaDist(p: 1.0 - alpha, shapeA: success + 0.5, shapeB: trials - success + 0.5)
            }
            catch {
                throw error
            }
        }
        return res
    }

    
    /// Performs the binomial test
    /// ### Note ###
    /// - H<sub>0</sub>: The probability of success is equal to p0
    /// - H<sub>a1</sub>: the probability of success is not equal to p0 (two sided)
    /// - H<sub>a2</sub>: the probability of success is less than p0 (one sided)
    /// - H<sub>a3</sub>: the probability of success is greater than p0 (one sided)
    /// - Parameter data: Dichotomous data
    /// - Parameter p0: Probability
    /// - Parameter alpha: alpha
    /// - Parameter alternative: .less, .greater or .twoSided
    /// - Throws: SSSwiftyStatsError iff data.sampleSize <= 2 || data.uniqueElements(sortOrder: .none)?.count)! > 2 || p0.isNaN
    public class func binomialTest<T>(data: Array<T>, characterSet: CharacterSet?, testProbability p0: Double!, successCodedAs successID: T,alpha: Double!,  alternative: SSAlternativeHypotheses) throws ->SSBinomialTestResult<T> where T: Comparable, T: Hashable {
        if p0.isNaN {
            os_log("p0 is NaN", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if data.count <= 2 {
            os_log("sample size is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let examine = SSExamine<T>.init(withArray: data, characterSet: characterSet)
        if (examine.uniqueElements(sortOrder: .none)?.count)! > 2 {
            os_log("observations are expected to be dichotomous", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try SSHypothesisTesting.binomialTest(data: examine, testProbability: p0, successCodedAs: successID, alpha: alpha, alternative: alternative)
        }
        catch {
            throw error
        }
    }
    
    
    
    /// Performs the binomial test
    /// ### Note ###
    /// - H<sub>0</sub>: The probability of success is equal to p0
    /// - H<sub>a1</sub>: the probability of success is not equal to p0 (two sided)
    /// - H<sub>a2</sub>: the probability of success is less than p0 (one sided)
    /// - H<sub>a3</sub>: the probability of success is greater than p0 (one sided)
    /// - Parameter data: Dichotomous data
    /// - Parameter p0: Probability
    /// - Parameter alpha: alpha
    /// - Parameter alternative: .less, .greater or .twoSided
    /// - Throws: SSSwiftyStatsError iff data.sampleSize <= 2 || data.uniqueElements(sortOrder: .none)?.count)! > 2 || p0.isNaN
    public class func binomialTest<T>(data: SSExamine<T>, testProbability p0: Double!, successCodedAs successID: T,alpha: Double!,  alternative: SSAlternativeHypotheses) throws ->SSBinomialTestResult<T> where T: Comparable, T: Hashable {
        if p0.isNaN {
            os_log("p0 is NaN", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if data.sampleSize <= 2 {
            os_log("sample size is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if (data.uniqueElements(sortOrder: .none)?.count)! > 2 {
            os_log("observations are expected to be dichotomous", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let success: Double = Double(data.frequency(item: successID))
        let failure: Double = Double(data.sampleSize) - success
        let n = success + failure
        let probSuccess = success / n
        var cintJeffreys = SSConfIntv()
        var cintClopperPearson = SSConfIntv()
        var fQ: Double
        switch alternative {
        case .less:
            do {
                cintJeffreys.lowerBound = 0.0
                cintJeffreys.upperBound = try upperBoundCIBinomial(success: success, trials: n, alpha: alpha)
                cintJeffreys.intervalWidth = fabs(cintJeffreys.upperBound! - cintJeffreys.lowerBound!)
                cintClopperPearson.lowerBound = 0.0
                fQ = try SSProbabilityDistributions.quantileFRatioDist(p: 1.0 - alpha / 2.0, numeratorDF: 2 * (success + 1.0), denominatorDF: 2 * (n - success))
                cintClopperPearson.upperBound = 1.0 / (1.0 + ((n - success) / ((success + 1.0) * fQ)))
                cintClopperPearson.intervalWidth = fabs(cintClopperPearson.upperBound! - cintClopperPearson.lowerBound!)
            }
            catch {
                throw error
            }
        case .greater:
            do {
                cintJeffreys.upperBound = 1.0
                cintJeffreys.lowerBound = try lowerBoundCIBinomial(success: success, trials: n, alpha: alpha)
                cintJeffreys.intervalWidth = fabs(cintJeffreys.upperBound! - cintJeffreys.lowerBound!)
                fQ = try SSProbabilityDistributions.quantileFRatioDist(p: alpha / 2.0, numeratorDF: 2 * success, denominatorDF: 2 * (n - success + 1.0))
                cintClopperPearson.lowerBound = 1.0 / (1.0 + ((n - success + 1) / (success * fQ)))
                cintClopperPearson.upperBound = 1.0
                cintClopperPearson.intervalWidth = fabs(cintClopperPearson.upperBound! - cintClopperPearson.lowerBound!)
            }
            catch {
                throw error
            }
        case .twoSided:
            do {
                cintJeffreys.upperBound = try upperBoundCIBinomial(success: success, trials: n, alpha: alpha / 2.0)
                cintJeffreys.lowerBound = try lowerBoundCIBinomial(success: success, trials: n, alpha: alpha / 2.0)
                cintJeffreys.intervalWidth = fabs(cintJeffreys.upperBound! - cintJeffreys.lowerBound!)
                fQ = try SSProbabilityDistributions.quantileFRatioDist(p: 1.0 - alpha / 2.0, numeratorDF: 2 * (success + 1.0), denominatorDF: 2 * (n - success))
                cintClopperPearson.upperBound = 1.0 / (1.0 + ((n - success) / ((success + 1.0) * fQ)))
                fQ = try SSProbabilityDistributions.quantileFRatioDist(p: alpha / 2.0, numeratorDF: 2 * success, denominatorDF: 2 * (n - success + 1.0))
                cintClopperPearson.lowerBound = 1.0 / (1.0 + ((n - success + 1) / (success * fQ)))
                cintClopperPearson.intervalWidth = fabs(cintClopperPearson.upperBound! - cintClopperPearson.lowerBound!)
            }
            catch {
                throw error
            }
        }
        var result = SSBinomialTestResult<T>()
        result.confIntJeffreys = cintJeffreys
        result.confIntClopperPearson = cintClopperPearson
        result.nTrials = Int(n)
        result.nSuccess = Int(success)
        result.nFailure = Int(failure)
        result.pValueExact = SSHypothesisTesting.binomialTest(numberOfSuccess: Int(success), numberOfTrials: Int(n), probability: p0,alpha: alpha,  alternative: alternative)
        result.probFailure = failure / n
        result.probSuccess = probSuccess
        result.probTest = p0
        result.successCode = successID
        return result
    }
    
    
    ///  Performs a two sample Kolmogorov-Smirnov test.
    /// ### Note ###
    /// H<sub>0</sub>: The two samples are from populations with same distribution function (F<sub>1</sub>(x) = F<sub>2</sub>(x))
    ///
    /// H<sub>a1</sub>:(F<sub>1</sub>(x) > F<sub>2</sub>(x))
    ///
    /// H<sub>a2</sub>:(F<sub>1</sub>(x) < F<sub>2</sub>(x))
    /// - Parameter set1: A Array object containg data for set 1
    /// - Parameter set2: A Array object containg data for set 2
    /// - Throws: SSSwiftyStatsError iff set1.sampleSize <= 2 || set2.sampleSize <= 2
    public class func kolmogorovSmirnovTwoSampleTest<T>(set1: Array<T>, set2: Array<T>, alpha: Double!) throws -> SSKSTwoSampleTestResult where T: Comparable, T: Hashable {
        if set1.count <= 2 {
            os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.count <= 2 {
            os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try SSHypothesisTesting.kolmogorovSmirnovTwoSampleTest(set1: SSExamine<T>.init(withArray: set1, characterSet: nil), set2: SSExamine<T>.init(withArray: set2, characterSet: nil), alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    
    ///  Performs a two sample Kolmogorov-Smirnov test.
    /// ### Note ###
    /// H<sub>0</sub>: The two samples are from populations with same distribution function (F<sub>1</sub>(x) = F<sub>2</sub>(x))
    ///
    /// H<sub>a1</sub>:(F<sub>1</sub>(x) > F<sub>2</sub>(x))
    ///
    /// H<sub>a2</sub>:(F<sub>1</sub>(x) < F<sub>2</sub>(x))
    /// - Parameter set1: A SSExamine object containg data for set 1
    /// - Parameter set2: A SSExamine object containg data for set 2
    /// - Throws: SSSwiftyStatsError iff set1.sampleSize <= 2 || set2.sampleSize <= 2
    public class func kolmogorovSmirnovTwoSampleTest<T>(set1: SSExamine<T>, set2: SSExamine<T>, alpha: Double!) throws -> SSKSTwoSampleTestResult where T: Comparable, T: Hashable {
        if set1.sampleSize <= 2 {
            os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.sampleSize <= 2 {
            os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var a1 = set1.elementsAsArray(sortOrder: .ascending)!
        a1.append(contentsOf: set2.elementsAsArray(sortOrder: .ascending)!)
        let n1 = Double(set1.sampleSize)
        let n2 = Double(set2.sampleSize)
        var dcdf: Double
        var maxNeg: Double = 0.0
        var maxPos: Double = 0.0
        if n1 > n2 {
            for element in a1 {
                dcdf = set1.empiricalCDF(of: element) - set2.empiricalCDF(of: element)
                if dcdf < 0.0 {
                    maxNeg = dcdf < maxNeg ? dcdf : maxNeg
                }
                else {
                    maxPos = dcdf > maxPos ? dcdf : maxPos
                }
            }
        }
        else {
            for element in a1 {
                dcdf = set2.empiricalCDF(of: element) - set1.empiricalCDF(of: element)
                if dcdf < 0.0 {
                    maxNeg = dcdf < maxNeg ? dcdf : maxNeg
                }
                else {
                    maxPos = dcdf > maxPos ? dcdf : maxPos
                }
            }
        }
        let maxD: Double
        maxD = fabs(maxNeg) > fabs(maxPos) ? fabs(maxNeg) : fabs(maxPos)
        var z: Double = 0.0
        var p: Double = 0.0
        var q: Double = 0.0
        if !maxD.isNaN {
            z = maxD * sqrt(n1 * n2 / (n1 + n2))
            if ((z >= 0) && (z < 0.27)) {
                p = 1.0
            }
            else if ((z >= 0.27) && (z < 1.0)) {
                q = exp(-1.233701 * pow(z, -2.0))
                p = 1.0 - ((2.506628 * (q + pow(q, 9.0) + pow(q, 25.0))) / z)
            }
            else if ((z >= 1.0) && (z < 3.1)) {
                q = exp(-2.0 * pow(z, 2.0))
                p = 2.0 * (q - pow(q, 4.0) + pow(q, 9.0) - pow(q, 16.0))
            }
            else if (z >= 3.1) {
                p = 0.0
            }
        }
        var result = SSKSTwoSampleTestResult()
        result.dMaxAbs = maxD
        result.dMaxNeg = maxNeg
        result.dMaxPos = maxPos
        result.zStatistic = z
        result.p2Value = p
        result.sampleSize1 = set1.sampleSize
        result.sampleSize2 = set2.sampleSize
        return result
    }
    
    
    /// Performs the two-sided Wald Wolfowitz test for two samples
    /// - Parameter set1: Observations in group 1
    /// - Parameter set2: Observations in group 2
    /// - Throws: SSSwiftyStatsError iff set1.sampleSize <= 2 || set2.sampleSize <= 2
    public class func waldWolfowitzTwoSampleTest<T>(set1: SSExamine<T>!, set2: SSExamine<T>!) throws -> SSWaldWolfowitzTwoSampleTestResult where T: Comparable, T: Hashable {
        if set1.sampleSize <= 2 {
            os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.sampleSize <= 2 {
            os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var groups = Array<Double>()
        var ranks = Array<Double>()
        var ties = Array<Double>()
//        var sortedGroups: Array<String> = Array<String>()
        var sortedData: Array<T> = Array<T>()
        var sumRanks1: Double = 0.0
        var sumRanks2: Double = 0.0
        let _ = rank2Arrays(set1: set1, set2: set2, identifierSet1: 0.0, identifierSet2: 1.0, ranks: &ranks, groups: &groups, sortedItems: &sortedData, ties: &ties, sumRanksSet1: &sumRanks1, sumRanksSet2: &sumRanks2)
        var temp = groups[0]
        var R: Int = 0
        var i: Int = 1
        while i < groups.count {
            if temp != groups[i] {
                R += 1
                temp = groups[i]
            }
            i += 1
        }
        var tempObject: T = sortedData[0]
        var nties: Int = 0
        var ntiedcases: Int = 0
        var ntiesintergroup: Int = 0
        var f1: Int
        var f2: Int
        f1 = set1.frequency(item: tempObject)
        f2 = set2.frequency(item: tempObject)
        if f1 > 0 && f2 > 0 {
            ntiedcases += f1 + f2
            ntiesintergroup += 1
        }
        i = 1
        while i < sortedData.count {
            if tempObject == sortedData[i] {
                nties += 1
            }
            else {
                f1 = set1.frequency(item: sortedData[i])
                f2 = set2.frequency(item: sortedData[i])
                if f1 > 0 && f2 > 0 {
                    ntiedcases += 1
                    ntiesintergroup += 1
                }
                tempObject = sortedData[i]
            }
            i += 1
        }
        R += 1
        var n1: Double = 0.0
        var n2: Double = 0.0
        for g in groups {
            if g == 0.0 {
                n1 += 1.0
            }
            else if g == 1.0 {
                n2 += 1.0
            }
        }
        var dtemp = n1 + n2
        var pAsymp = Double.nan
        var pExact = Double.nan
        let sigma = sqrt(2.0 * n1 * n2 * (2.0 * n1 * n2 - n1 - n2) / ((n1 + n2) * (n1 + n2) * (n1 + n2 - 1.0)))
        let mean = (2.0 * n1 * n2) / dtemp + 1.0
        var z = 0.0
        var sum = 0.0
        dtemp = Double(R) - mean
        z = dtemp / sigma
        pAsymp = 2.0 * SSProbabilityDistributions.cdfStandardNormalDist(u: -fabs(z))
        if n1 + n2 <= 30 {
            if !isOdd(Double(R)) {
                var r = 2
                var RR: Double
                while r <= R {
                    RR = Double(r)
                    sum += binomial2(n1 - 1.0, (RR / 2.0) - 1.0) * binomial2(n2 - 1.0,(RR / 2.0) - 1.0);
                    r += 1
                }
                pExact = 2.0 * sum / binomial2(n1 + n2, n1)
            }
            else {
                var r = 2
                var RR: Double
                while r <= R {
                    RR = Double(r)
                    sum += (binomial2(n1 - 1.0,(RR - 1.0) / 2.0) * binomial2(n2 - 1.0, (RR - 3.0) / 2.0) + binomial2(n1 - 1.0, (RR - 3.0) / 2.0) * binomial2(n2 - 1.0,(RR - 1.0) / 2.0))
                    r += 1
                }
                pExact = sum / binomial2(n1 + n2, n1)
            }
        }
        var result = SSWaldWolfowitzTwoSampleTestResult()
        result.ZStatistic = z
        result.pValueExact = (1.0 - pExact) / 2.0
        result.pValueAsymp = pAsymp
        result.mean = mean
        result.variance = sigma
        result.nRuns = R
        result.nTiesIntergroup = ntiesintergroup
        result.nTiedCases = ntiedcases
        result.sampleSize1 = set1.sampleSize
        result.sampleSize2 = set2.sampleSize
        return result
    }
    
    /// A more general ranking routine
    /// - Paramater data: Array with data to rank
    /// - Parameter inout ranks: Upon return contains the ranks
    /// - Parameter inout ties: Upon return contains the correction terms for ties
    /// - Parameter inout numberOfTies: Upon return contains number of ties
    public class func rank<T>(data: Array<T>, ranks: inout Array<Double>, ties: inout Array<Double>, numberOfTies: inout Int) where T: Comparable, T: Hashable {
        var pos: Int
        let examine: SSExamine<T> = SSExamine<T>.init(withArray: data, characterSet: nil)
        var ptemp: Int
        var freq: Int
        var sum = 0.0
        var sum1 = 0.0
        numberOfTies = 0
        pos = 0
        while pos < examine.sampleSize {
            ptemp = pos + 1
            sum = Double(ptemp)
            freq = examine.frequency(item: data[pos])
            if freq == 1 {
                ranks.append(sum)
                pos += 1
            }
            else {
                numberOfTies += 1
                ties.append(pow(Double(freq), 3.0) - Double(freq))
                sum1 = 0.0
                for i in 1...(freq - 1) {
                    sum1 += Double(i)
                }
                sum += sum1 + Double(ptemp)
                for _ in 1...freq {
                    ranks.append(sum / Double(freq))
                }
                pos = ptemp + freq - 1
            }
        }
    }
    

    
    
    
    
}

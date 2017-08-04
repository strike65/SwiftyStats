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
    public class func autocorrelationCoefficient(data: Array<Double>!, lag: Int!) throws -> Double {
        if data.count < 2 {
            os_log("sample size is exptected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try autocorrelationCoefficient(data: SSExamine<Double>.init(withArray: data, characterSet: nil), lag: lag)
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
            os_log("sample size is exptected to be >= 2", log: log_stat, type: .error)
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
            os_log("sample size is exptected to be >= 2", log: log_stat, type: .error)
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
            os_log("sample size is exptected to be >= 2", log: log_stat, type: .error)
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
    public class func runsTest(data: Array<Double>!, alpha: Double!, useCuttingPoint useCP: SSRunsTestCuttingPoint, userDefinedCuttingPoint cuttingPoint: Double?) throws -> SSRunsTestResult {
        if data.count < 2 {
            os_log("sample size is exptected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try SSHypothesisTesting.runsTest(data: SSExamine<Double>.init(withArray: data, characterSet: nil), alpha: alpha, useCuttingPoint: useCP, userDefinedCuttingPoint: cuttingPoint)
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
    public class func runsTest(data: SSExamine<Double>!, alpha: Double!, useCuttingPoint useCP: SSRunsTestCuttingPoint, userDefinedCuttingPoint cuttingPoint: Double?) throws -> SSRunsTestResult {
        if data.sampleSize < 2 {
            os_log("sample size is exptected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var diff = Array<Double>()
        let elements = data.elementsAsArray(sortOrder: .original)!
        var dtemp: Double = 0.0
        var np: Double = 0.0
        var nn: Double = 0.0
        var r: Int = 1
        var cp: Double = 0.0
        var isPrevPos = false
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
        for element in elements {
            dtemp = element - cp
            diff.append(dtemp)
            if isPrevPos && (dtemp < 0.0) {
                r += 1
            }
            if !isPrevPos && (dtemp >= 0.0) {
                r += 1
            }
            if dtemp >= 0.0 {
                isPrevPos = true
                np += 1.0
            }
            else {
                isPrevPos = false
                nn += 1.0
            }
        }
        dtemp = nn + np
        let sigma = sqrt((2.0 * np * nn * (2.0 * np * nn - nn - np)) / ((dtemp * dtemp * (np + nn - 1.0))))
        let mean = (2.0 * np * nn) / dtemp + 1.0
        var z: Double = 0.0
        dtemp = Double(r) - mean
        if data.sampleSize < 50 {
            if dtemp <= 0.5 {
                z = (dtemp + 0.5) / sigma
            }
            else if dtemp > 0.5 {
                z = (dtemp - 0.5) / sigma
            }
            else if fabs(dtemp) < 0.5 {
                z = 0.0
            }
        }
        else {
            z = dtemp / sigma
        }
        var p: Double = 0.0
        var cv: Double
        p = SSProbabilityDistributions.cdfStandardNormalDist(u: z)
        do {
            cv = try SSProbabilityDistributions.quantileStandardNormalDist(p: 1 - alpha / 2.0)
        }
        catch {
            throw error
        }
        if p > 0.5 {
            p = (1.0 - p) * 2.0
        }
        else {
            p *= 2.0
        }
        var result = SSRunsTestResult()
        result.nGTEcp = np
        result.nLTcp = nn
        result.nRuns = Double(r)
        result.ZStatistic = z
        result.pValue = p
        result.cp = cp
        result.diffs = diff
        result.criticalValue = cv
        result.randomness = fabs(z) <= cv
        return result
    }
    
    
    /************************************************************************************************/
    // MARK: GoF test
    
    /// Performs the goodness of fit test according to Kolmogorov and Smirnov
    /// The K-S distribution is computed according to Richard Simard and Pierre L'Ecuyer (Journal of Statistical Software March 2011, Volume 39, Issue 11.)
    /// - Parameter data: SSExamine<Double>
    /// - Parameter target: Distribution to test for
    /// - Throws: SSSwiftyStatsError if data.count < 2
    public class func ksGoFTest(data: SSExamine<Double>!, targetDistribution target: SSGoFTarget) throws -> SSKSTestResult? {
        if !data.isEmpty {
            do {
                return try ksGoFTest(data: data.elementsAsArray(sortOrder: .original)!, targetDistribution: target)
            }
            catch {
                throw error
            }
        }
        else {
            os_log("sample size is exptected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        
    }
    
    /// Performs the goodness of fit test according to Kolmogorov and Smirnov.
    /// The K-S distribution is computed according to Richard Simard and Pierre L'Ecuyer (Journal of Statistical Software March 2011, Volume 39, Issue 11.)
    /// - Parameter data: Array<Double>
    /// - Parameter target: Distribution to test for
    /// - Throws: SSSwiftyStatsError if data.count < 2
    public class func ksGoFTest(data: Array<Double>!, targetDistribution target: SSGoFTarget) throws -> SSKSTestResult? {
        // error handling
        if data.count < 2 {
            os_log("sample size is exptected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let _data: SSExamine<Double>
        do {
            _data = try SSExamine<Double>.init(withObject: data, levelOfMeasurement: .interval, characterSet: nil)
        }
        catch {
            os_log("unable to create examine object", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let sortedData = _data.uniqueElements(sortOrder: .ascending)!
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
            dest1 = _data.arithmeticMean!
            if let test = _data.standardDeviation(type: .unbiased) {
                dest2 = test
            }
        case .exponential:
            dest3 = 0.0
            ik = 0
            for value in sortedData {
                if value <= 0 {
                    ik = ik + _data.frequency(item: value)
                    dest3 = Double(ik) * value
                }
            }
            for value in sortedData {
                if value < 0 {
                    lds = 0
                }
                else {
                    lds = lds + Double(_data.frequency(item: value)) / (Double(_data.sampleSize) - Double(ik))
                }
                ecdf[value] = lds
            }
            if lds == 0.0 || ik > (_data.sampleSize - 2) {
                bok1 = false
            }
            dest1 = (Double(_data.sampleSize) - Double(ik)) / (_data.total - dest3)
        case .uniform:
            dest1 = _data.minimum!
            dest2 = _data.maximum!
            ik = 0
        case .studentT:
            dest1 = Double(_data.sampleSize)
            ik = 0
        case .laplace:
            dest1 = _data.median!
            dest2 = _data.medianAbsoluteDeviation(aroundReferencePoint: dest1)!
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
                    dtemp1 = _data.empiricalCDF(of: value) - dtestCDF
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
                        dtemp1 = _data.empiricalCDF(of: nt) - dtestCDF
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
        dz = sqrt(Double(_data.sampleSize - ik)) * dD
        //        var dp: Double
        //        var dq: Double
        //        // according to Smirnov, not as accurate as possible but simple
        //        if (!dD.isNaN)
        //        {
        //            dz = sqrt(Double(_data.sampleSize - ik)) * dD
        //            dp = 0.0
        //            if ((dz >= 0) && (dz < 0.27)) {
        //                dp = 1.0
        //            }
        //            else if ((dz >= 0.27) && (dz < 1.0)) {
        //                dq = exp(-1.233701 * pow(dz, -2.0))
        //                dp = 1.0 - ((2.506628 * (dq + pow(dq, 9.0) + pow(dq, 25.0))) / dz)
        //            }
        //            else if ((dz >= 1.0) && (dz < 3.1)) {
        //                dq = exp(-2.0 * pow(dz, 2.0))
        //                dp = 2.0 * (dq - pow(dq, 4.0) + pow(dq, 9.0) - pow(dq, 16.0))
        //            } else if (dz > 3.1) {
        //                dp = 0.0
        //            }
        //        }
        //        else {
        //            dp = Double.nan
        //        }
        //
        let dp: Double = 1.0 - KScdf(n: _data.sampleSize, x: dD)
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
            result.sampleSize = _data.sampleSize
            
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
            result.sampleSize = _data.sampleSize
        case .uniform:
            result.estimatedLowerBound = dest1
            result.estimatedUpperBound = dest2
            result.pValue = dp
            result.maxAbsDifference = dD
            result.maxNegDifference = dmaxn
            result.maxPosDifference = dmaxp
            result.zStatistics = dz
            result.sampleSize = _data.sampleSize
        case .studentT:
            result.estimatedDegreesOfFreedom = dest1
            result.pValue = dp
            result.maxAbsDifference = dD
            result.maxNegDifference = dmaxn
            result.maxPosDifference = dmaxp
            result.zStatistics = dz
            result.sampleSize = _data.sampleSize
        case .laplace:
            result.estimatedMean = dest1
            result.estimatedShapeParam = dest2
            result.pValue = dp
            result.maxAbsDifference = dD
            result.maxNegDifference = dmaxn
            result.maxPosDifference = dmaxp
            result.zStatistics = dz
            result.sampleSize = _data.sampleSize
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
                return try adNormalityTest(data: data.elementsAsArray(sortOrder: .original)!, alpha: alpha)
            }
            catch {
                throw error
            }
        }
        else {
            os_log("sample size is exptected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
    }
    
    
    /// Performs the Anderson Darling test for normality. Returns a SSADTestResult struct.
    /// Adapts an algorithm originally developed by Marsaglia et al.(Evaluating the Anderson-Darling Distribution. Journal of Statistical Software 9 (2), 1–5. February 2004)
    /// - Parameter data: Data
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if data.count < 2
    public class func adNormalityTest(data: Array<Double>!, alpha: Double!) throws -> SSADTestResult? {
        var ad: Double = 0.0
        var a2: Double
        var estMean: Double
        var estSd: Double
        var n: Int
        var tempArray: Array<Double>
        var pValue: Double
        if data.count < 2 {
            os_log("sample size is exptected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let _data: SSExamine<Double>
        do {
            _data = try SSExamine<Double>.init(withObject: data, levelOfMeasurement: .interval, characterSet: nil)
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
            os_log("number of samples is exptected to be > 1", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var array: Array<Array<Double>> = Array<Array<Double>>()
        for examine in data {
            if !examine.isEmpty {
                array.append(examine.elementsAsArray(sortOrder: .original)!)
            }
            else {
                os_log("sample size is exptected to be > 2", log: log_stat, type: .error)
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
        }
        do {
            return try bartlettTest(data: array, alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    
    /// Performs the Bartlett test for two or more samples
    /// - Parameter data: Array containing samples
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if data.count < 2 or no variances are obtainable
    public class func bartlettTest(data: Array<Array<Double>>!, alpha: Double!) throws -> SSVarianceEqualityTestResult? {
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
        if data.count < 2 {
            os_log("number of samples is exptected to be > 1", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        for array in data {
            _data.append(SSExamine<Double>.init(withArray: array, characterSet: nil))
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
            os_log("number of samples is exptected to be > 1", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var array: Array<Array<Double>> = Array<Array<Double>>()
        for examine in data {
            if !examine.isEmpty {
                array.append(examine.elementsAsArray(sortOrder: .original)!)
            }
            else {
                os_log("sample size is exptected to be > 2", log: log_stat, type: .error)
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
        }
        do {
            return try leveneTest(data: array, testType: testType, alpha: alpha)
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
    public class func leveneTest(data: Array<Array<Double>>!, testType: SSLeveneTestType, alpha: Double!) throws -> SSVarianceEqualityTestResult? {
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
        if data.count < 2 {
            os_log("number of samples is exptected to be > 1", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        for array in data {
            if array.count >= 2 {
                _data.append(SSExamine<Double>.init(withArray: array, characterSet: nil))
            }
            else {
                os_log("sample size is exptected to be >= 2", log: log_stat, type: .error)
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
    public class func chiSquareVarianceTest(data: Array<Double>, nominalVariance s0: Double!, alpha: Double!) throws -> SSChiSquareVarianceTestResult? {
        if data.count < 2 {
            os_log("sample size is exptected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if s0 <= 0 {
            os_log("nominal variance is exptected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try chiSquareVarianceTest(sample: SSExamine<Double>.init(withArray: data, characterSet: nil), nominalVariance: s0, alpha: alpha)
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
            os_log("sample size is exptected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if s0 <= 0 {
            os_log("nominal variance is exptected to be > 0", log: log_stat, type: .error)
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
            os_log("sample1 size is exptected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if data2.count < 2 {
            os_log("sample2 size is exptected to be >= 2", log: log_stat, type: .error)
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
            os_log("sample1 size is exptected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if sample2.sampleSize < 2 {
            os_log("sample2 size is exptected to be >= 2", log: log_stat, type: .error)
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
            os_log("sample1 size is exptected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if data2.count < 2 {
            os_log("sample2 size is exptected to be >= 2", log: log_stat, type: .error)
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
            os_log("sample1 size is exptected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if sample2.sampleSize < 2 {
            os_log("sample2 size is exptected to be >= 2", log: log_stat, type: .error)
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
            os_log("sample size is exptected to be >= 2", log: log_stat, type: .error)
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
            os_log("sample size is exptected to be >= 2", log: log_stat, type: .error)
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
            os_log("sample size is exptected to be >= 2", log: log_stat, type: .error)
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
            os_log("sample size is exptected to be >= 2", log: log_stat, type: .error)
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
            os_log("number of samples is exptected to be > 2", log: log_stat, type: .error)
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
            os_log("number of samples is exptected to be > 2", log: log_stat, type: .error)
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
            os_log("number of samples is exptected to be > 2", log: log_stat, type: .error)
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
            os_log("number of samples is exptected to be > 2", log: log_stat, type: .error)
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
    
    
    /// Binomial
    fileprivate func binomial2(n: Double!, k: Double!) -> Double {
        if k == 0.0 {
            return 1.0
        }
        let num: Double = lgamma(n + 1.0)
        let den: Double = lgamma(n - k + 1.0) + lgamma(k + 1.0)
        let q: Double = num - den
        return exp(q)
    }
    
    /// Algorithm AS 62 Applied Statistics (1973) Vol 22, No. 2
    fileprivate class func cdfMannWhitney(U: Double!, m: Int!, n: Int!) throws -> Double {
        // Algorithm AS 62 Applied Statistics (1973) Vol 22, No. 2
        if m <= 0 || n <= 0 {
            os_log("m and n is exptected to be > 0", log: log_stat, type: .error)
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
            os_log("m and n is exptected to be > 0", log: log_stat, type: .error)
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
        var sum = 0.0
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
    fileprivate class func rank2Arrays<T>(set1: SSExamine<T>!, set2: SSExamine<T>!, identifierSet1: String!, identifierSet2: String!, ranks: inout Array<Double>, groups: inout Array<String>, ties: inout Array<Double>, sumRanksSet1: inout Double, sumRanksSet2: inout Double) -> Bool where T: Comparable {
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
                    }
                    else {
                        groups.append(identifierSet2)
                    }
                    k += 1
                }
                print(sum)
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
    
    /// Perform the Mann-Whitney U test for independent samples.
    /// ### Note ###
    /// If there are ties between the sets, only an asymptotic p-value is returned. Exact p-values are computed using the Algorithm by Dineen and Blakesley (1973)
    /// - Parameter set1: Observations of group1
    /// - Parameter set2: Observations of group2
    /// - Throws: SSSwiftyStatsError iff set1.sampleSize <= 2 || set2.sampleSize <= 2
    public class func mannWhitneyUTest<T>(set1: SSExamine<T>!, set2: SSExamine<T>!)  throws -> SSMannWhitneyUTestResult where T: Comparable {
        if set1.sampleSize <= 2 {
            os_log("sample size of set 1 is exptected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.sampleSize <= 2 {
            os_log("sample size of set 2 is exptected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var ranks:Array<Double> = Array<Double>()
        var groups:Array<String> = Array<String>()
        var ties: Array<Double> = Array<Double>()

        var sumRanksSet1: Double = 0.0
        var sumRanksSet2: Double = 0.0
        var hasTies: Bool
        hasTies = rank2Arrays(set1: set1, set2: set2, identifierSet1: "A", identifierSet2: "B", ranks: &ranks, groups: &groups, ties: &ties, sumRanksSet1: &sumRanksSet1, sumRanksSet2: &sumRanksSet2)
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
        var testR = SSMannWhitneyUTestResult()
        testR.sumRanks1 = sumRanksSet1
        testR.sumRanks2 = sumRanksSet2
        testR.meanRank1 = sumRanksSet1 / n1
        testR.meanRank2 = sumRanksSet2 / n2
        testR.UMannWhitney = U
        testR.WilcoxonW = W
        testR.ZStatistic = z
        testR.p2Approx = pasymp2
        testR.p2Exact = pexact2
        testR.p1Approx = pasymp1
        testR.p1Exact = pexact1
        testR.effectSize = z / sqrt(n1 + n2)
        return testR
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

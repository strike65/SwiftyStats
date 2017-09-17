//
//  SSSSHypothesisTesting.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 20.07.17.
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
    // MARK: t-Tests
    
    
    /// Performs the two sample t test
    /// - Parameter sample1: Data1 as Array<Double>
    /// - Parameter sample2: Data2 as Array<Double>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff sample1.sampleSize < 2 || sample2.sampleSize < 2
    public class func twoSampleTTest(data1: Array<Double>!, data2: Array<Double>, alpha: Double!) throws -> SS2SampleTTestResult {
        if data1.count < 2 {
            os_log("sample1 size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if data2.count < 2 {
            os_log("sample2 size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let sample1 = SSExamine<Double>.init(withArray: data1, name: nil, characterSet: nil)
        let sample2 = SSExamine<Double>.init(withArray: data2, name: nil, characterSet: nil)
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
    public class func twoSampleTTest(sample1: SSExamine<Double>!, sample2: SSExamine<Double>, alpha: Double!) throws -> SS2SampleTTestResult {
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
            var result: SS2SampleTTestResult = SS2SampleTTestResult()
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
        let sample:SSExamine<Double> = SSExamine<Double>.init(withArray: data, name: nil, characterSet: nil)
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
        let set1 = SSExamine<Double>.init(withArray: data1, name: nil, characterSet: nil)
        let set2 = SSExamine<Double>.init(withArray: data2, name: nil, characterSet: nil)
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
    
    public class func oneWayANOVA(dataFrame: SSDataFrame<Double>, alpha: Double) throws -> SSOneWayANOVATestResult? {
        if dataFrame.columns <= 2 {
            os_log("number of samples is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            var exArray = Array<SSExamine<Double>>()
            for ex in dataFrame.examines {
                exArray.append(ex)
            }
            return try SSHypothesisTesting.multipleMeansTest(data: exArray, alpha: alpha)
        }
        catch {
            throw error
        }
    }

    public class func multipleMeansTest(dataFrame: SSDataFrame<Double>, alpha: Double) throws -> SSOneWayANOVATestResult? {
        if dataFrame.columns <= 2 {
            os_log("number of samples is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            var exArray = Array<SSExamine<Double>>()
            for ex in dataFrame.examines {
                exArray.append(ex)
            }
            return try SSHypothesisTesting.multipleMeansTest(data: exArray, alpha: alpha)
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
            examines.append(SSExamine<Double>.init(withArray: array, name: nil, characterSet: nil))
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
        // total number of observations
        var N: Int = 0
        // p value of Bartlett test
        var pBartlett: Double
        // p value of Levene test
        var pLevene: Double
        // explained sum of squares
        var SST = 0.0
        // residual sum of squares
        var SSE = 0.0
        // test statistic
        var F: Double
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
            if let tot = examine.total {
                sum += tot
            }
            else {
                sum = Double.nan
            }
            N += examine.sampleSize
        }
        overallMean = sum / Double(N)
        for examine in data {
            SST += pow(examine.arithmeticMean! - overallMean, 2.0) * Double(examine.sampleSize)
            SSE += (Double(examine.sampleSize) - 1.0) * examine.variance(type: .unbiased)!
        }
        let MSE = SSE / (Double(N) - groups)
        let MST = SST / (groups - 1.0)
        F = MST / MSE
        do {
            cdfValue = try SSProbabilityDistributions.cdfFRatio(f: F, numeratorDF: groups - 1.0 , denominatorDF: Double(N) - groups)
            cutoffAlpha = try SSProbabilityDistributions.quantileFRatioDist(p: 1.0 - alpha, numeratorDF: groups - 1.0, denominatorDF: Double(N) - groups)
        }
        catch {
            throw error
        }
        pValue = 1.0 - cdfValue
        meansEqual = F <= cutoffAlpha
        var result = SSOneWayANOVATestResult()
        result.p2Value = pValue
        result.FStatistic = F
        result.alpha = alpha
        result.meansEQUAL = meansEqual
        result.cv = cutoffAlpha
        result.pBartlett = pBartlett
        result.pLevene = pLevene
        result.dfTotal = Double(N) - 1.0
        result.dfError = Double(N) - groups
        result.dfTreatment = groups - 1.0
        result.SSError = SSE
        result.SSTreatment = SST
        result.MSError = MSE
        result.MSTreatment = MST
        return result
    }
    
    
    // post hoc tests
    
    
    
    
    // TUKEY KRAMER
    // All means are compared --> k(k - 1) / 2 comparisons (k = number of means)
    // find a procedure
    // 1. compute all means
    // 2. compute test statistics
    /*
     Structure of the differences array:
     
                    m(0)        m(1)        m(2)        m(3)        ...     m(k - 1)
     m(0)           -           d(0,1)      d(0,2)      m(0,3)      ...     d(0,k - 1)
     m(1)           d(1,0)      -           d(1,2)      m(1,3)      ...     d(1,k - 1)
     m(2)           d(2,0)      d(2,1)      -           m(2,3)      ...     d(2,k - 1)
     m(3)           d(3,0)      d(3,1)      -           -           ...     d(3,k - 1)
     .              .           .           .           .           ...     d(2,k - 1)
     .              .           .           .           .           ...     .
     m(k - 1)       d(k - 1,0)  d(k - 1,1)  d(k - 1,2)  d(k - 1,3)  ...     -

     
     
     Structure of the T array:
     
                    m(0)        m(1)        m(2)        ...     m(k - 1)
     m(0)           -           T(0,1)      T(0,2)      ...     T(0,k - 1)
     m(1)           T(1,0)      -           T(1,2)      ...     T(1,k - 1)
     m(2)           T(2,0)      T(2,1)      -           ...     T(2,k - 1)
     .              .           .           .           ...     .
     .              .           .           .           ...     .
     .              .           .           .           ...     .
     m(k - 1)       T(k - 1,0)  T(k - 1,1)  T(k - 1,2)  ...     -
 
 */
    /// Performs the Tukey-Kramer test for multiple comparisons
    /// - Parameter data: data as SSDataFrame<Double>
    /// - Parameter alpha: Alpha
    /// - Returns:SSHSDResultRow
    /// - Throws: SSSwiftyStatsError iff data.count <= 2
    /// - Precondition: Each examine object should be named uniquely.
    public class func tukeyKramerTest(dataFrame: SSDataFrame<Double>, alpha: Double!) throws -> Array<SSHSDResultRow>? {
        do {
            if dataFrame.examines.count <= 2 {
                os_log("number of samples is expected to be > 2", log: log_stat, type: .error)
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
            return try SSHypothesisTesting.tukeyKramerTest(data: dataFrame.examines, alpha: alpha)
        }
        catch {
            throw error
        }
    }

    /// Performs the Tukey-Kramer test for multiple comparisons
    /// - Parameter data: data as SSExamine<Double>
    /// - Parameter alpha: Alpha
    /// - Returns:SSHSDResultRow
    /// - Throws: SSSwiftyStatsError iff data.count <= 2
    /// - Precondition: Each examine object should be named uniquely.
    public class func tukeyKramerTest(data: Array<SSExamine<Double>>, alpha: Double!) throws -> Array<SSHSDResultRow>? {
        if data.count <= 2 {
            os_log("number of samples is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var means = Array<Double>()
        for examine in data {
            means.append(examine.arithmeticMean!)
        }
        var Q = Array<Array<Double>>()
        var differences = Array<Array<Double>>()
        var temp: Double
        var sum1: Double = 0.0
        var sum2: Double = 0.0
        let k: Int = data.count
        var n_total: Double = 0.0
        // compute means
        for i in stride(from: 0, through: data.count - 1, by: 1) {
            differences.append(Array<Double>())
            for j in stride(from: 0, through: data.count - 1, by: 1) {
                differences[i].append(Double.nan)
                if j >= i + 1 {
                    temp = means[i] - means[j]
                    differences[i][j] = temp
                }
            }
        }
        // compute pooled variance
        for i in stride(from: 0, through: data.count - 1, by: 1) {
            n_total = n_total + Double(data[i].sampleSize)
            sum1 = 0.0
            for j in stride(from: 0, through: data[i].sampleSize - 1, by: 1) {
                if let t = castValueToDouble(data[i][j]) {
                    sum1 = sum1 + pow(t - means[i], 2.0)
                }
                else {
                    fatalError()
                }
            }
            sum2 = sum2 + sum1
        }
        let s = sqrt(sum2 / (n_total - Double(data.count)))
        var n_i: Double
        var n_j: Double
        // compute test statistics
        for i in stride(from: 0, through: data.count - 1, by: 1) {
            Q.append(Array<Double>())
            n_i = Double(data[i].sampleSize)
            for j in stride(from: 0, through: data.count - 1, by: 1) {
                Q[i].append(Double.nan)
                if j >= i + 1 {
                    n_j = Double(data[j].sampleSize)
                    if n_i == n_j {
                        Q[i][j] = fabs(differences[i][j]) / ( s * sqrt(1.0 / n_i))
                    }
                    else {
                        Q[i][j] = fabs(differences[i][j]) / ( s * sqrt(0.5 * (1.0 / n_i + 1.0 / n_j)))
                    }
                }
            }
        }
        var pValues = Array<Array<Double>>()
        for i in stride(from: 0, through: data.count - 1, by: 1) {
            pValues.append(Array<Double>())
            for j in stride(from: 0, through: data.count - 1, by: 1) {
                pValues[i].append(Double.nan)
                if j >= i + 1 {
                    temp = Double.nan
                    do {
                        temp = try ptukey(q: Q[i][j], nranges: 1, numberOfMeans: Double(data.count), df: n_total - Double(data.count), tail: .upper, returnLogP: false)
                    }
                    catch {
                        os_log("unable to compute ptukey", log: log_stat, type: .error)
                    }
                    pValues[i][j] = temp
                }
            }
        }
        var confIntv = Array<Array<SSConfIntv>>()
        var lb: Double
        var ub: Double
        var halfWidth: Double
        var criticalQ: Double = 0.0
        do {
            criticalQ = try qtukey(p: 1.0 - alpha, nranges: 1, numberOfMeans: Double(data.count), df: n_total - Double(data.count), tail: .upper, log_p: false)
        }
        catch {
            os_log("unable to compute qtukey", log: log_stat, type: .error)
            return nil
        }
        for i in stride(from: 0, through: data.count - 1 , by: 1) {
            confIntv.append(Array<SSConfIntv>())
            n_i = Double(data[i].sampleSize)
            for j in stride(from: 0, through: data.count - 1, by: 1) {
                n_j = Double(data[j].sampleSize)
                confIntv[i].append(SSConfIntv())
                if j >= i + 1 {
                    if n_i != n_j {
                        halfWidth = criticalQ * s * sqrt((1.0 / n_i + 1.0 / n_j) / 2.0)
                    }
                    else {
                        halfWidth = criticalQ * s * sqrt(1.0 / n_i)
                    }
                    lb = differences[i][j] - halfWidth
                    ub = differences[i][j] + halfWidth
                    confIntv[i][j].lowerBound = lb
                    confIntv[i][j].upperBound = ub
                    confIntv[i][j].intervalWidth = 2.0 * halfWidth
                }
            }
        }
        
        var summary: Array<SSHSDResultRow> = Array<SSHSDResultRow>()
        var tempSummary: SSHSDResultRow
        for i in stride(from: 0, through: k - 2, by: 1) {
            for j in stride(from: i + 1, through: k - 1, by: 1) {
                tempSummary = (row: data[i].name! + "-" +  data[j].name!, meanDiff: differences[i][j], qStat: Q[i][j], pValue:  pValues[i][j])
                summary.append(tempSummary)
            }
        }
        return summary
    }
    

    
    
    
    
}

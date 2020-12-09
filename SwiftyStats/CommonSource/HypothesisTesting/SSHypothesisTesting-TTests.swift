//
//  SSSSHypothesisTesting.swift
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


/// Hypothesis tests.
extension SSHypothesisTesting {
    
    /// Performs the two sample t test
    /// - Parameter sample1: Data1 as Array<Numeric>
    /// - Parameter sample2: Data2 as Array<Numeric>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff sample1.sampleSize < 2 || sample2.sampleSize < 2
    public static func twoSampleTTest<T, FPT: SSFloatingPoint & Codable>(data1: Array<T>, data2: Array<T>, alpha: FPT) throws -> SS2SampleTTestResult<FPT> where T: Hashable & Comparable & Codable {
        if data1.count < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample1 size is expected to be >= 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if data2.count < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample2 size is expected to be >= 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if !Helpers.isNumber(data1.first) || !Helpers.isNumber(data2.first) {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("T Test is defined for numerical data only", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }

        let sample1 = SSExamine<T, FPT>.init(withArray: data1, name: nil, characterSet: nil)
        let sample2 = SSExamine<T, FPT>.init(withArray: data2, name: nil, characterSet: nil)
        do {
            return try twoSampleTTest(sample1: sample1, sample2: sample2, alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    /// Performs the two sample t test
    /// - Parameter sample1: Data1 as SSExamine<Numeric, SSFloatingPoint>
    /// - Parameter sample2: Data2 as SSExamine<Numeric, SSFloatingPoint>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff sample1.sampleSize < 2 || sample2.sampleSize < 2
    public static func twoSampleTTest<T, FPT: SSFloatingPoint & Codable>(sample1: SSExamine<T, FPT>!, sample2: SSExamine<T, FPT>, alpha: FPT) throws -> SS2SampleTTestResult<FPT> where T: Hashable & Comparable & Codable {
        if sample1.sampleSize < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample1 size is expected to be >= 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if sample2.sampleSize < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample2 size is expected to be >= 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if !sample1.isNumeric || !sample2.isNumeric {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("T Test is defined for numerical data only", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        
        var cdfLeveneMedian: FPT = 0
        var cdfTValueEqualVariances: FPT = 0
        var cdfTValueUnequalVariances: FPT = 0
        var dfEqualVariances: FPT = 0
        var dfUnequalVariances: FPT = 0
        var differenceInMeans: FPT = 0
        var mean1: FPT = 0
        var mean2: FPT = 0
        var criticalValueEqualVariances: FPT = 0
        var criticalValueUnequalVariances: FPT = 0
        var pooledStdDev: FPT = 0
        var pooledVariance: FPT = 0
        var stdDev1: FPT = 0
        var stdDev2: FPT = 0
        var tValueEqualVariances: FPT = 0
        var tValueUnequalVariances: FPT = 0
        var variancesAreEqualMedian: Bool = false
        var twoTailedEV: FPT = 0
        var twoTailedUEV: FPT = 0
        var oneTailedEV: FPT = 0
        var oneTailedUEV: FPT = 0
        var var1: FPT = 0
        var var2: FPT = 0
        var ex1: FPT
        var ex2: FPT
        var ex3: FPT
        var ex4: FPT
        let n1: FPT =  Helpers.makeFP(sample1.sampleSize)
        let n2: FPT =  Helpers.makeFP(sample2.sampleSize)
        var1 = sample1.variance(type: .unbiased)!
        var2 = sample2.variance(type: .unbiased)!
        mean1 = sample1.arithmeticMean!
        mean2 = sample2.arithmeticMean!
        ex1 = var1 / n1
        ex2 = var2 / n2
        ex3 = ex1 + ex2
        let k: FPT = ex1 / ex3
        ex1 = SSMath.pow1(k, 2) / (n1 - 1)
        let ktk: FPT = k * k
        let kpk: FPT = k + k
        ex2 = FPT.one - kpk + ktk
        ex3 = (n2 - 1)
        dfUnequalVariances = ceil( 1 / ( ex1 + ( ex2 / ex3 ) ) )
        dfEqualVariances = n1 + n2 - 2
        stdDev1 = sample1.standardDeviation(type: .unbiased)!
        stdDev2 = sample2.standardDeviation(type: .unbiased)!
        ex1 = (n1 - FPT.one) * var1
        ex2 = (n2 - FPT.one) * var2
        ex3 = ex1 + ex2
        pooledVariance = ex3 / dfEqualVariances
        pooledStdDev = sqrt(pooledVariance)
        differenceInMeans = mean1 - mean2
        ex1 = SSMath.reciprocal(n1)
        ex2 = SSMath.reciprocal(n2)
        ex3 = sqrt(ex1 + ex2)
        ex4 = pooledStdDev * ex3
        tValueEqualVariances = differenceInMeans / ex4
        ex1 = var1 / n1
        ex2 = var2 / n2
        ex3 = sqrt(ex1 + ex2)
        tValueUnequalVariances = differenceInMeans / ex3
        do {
            cdfTValueEqualVariances = try SSProbDist.StudentT.cdf(t: tValueEqualVariances, degreesOfFreedom: dfEqualVariances)
            cdfTValueUnequalVariances = try SSProbDist.StudentT.cdf(t: tValueUnequalVariances, degreesOfFreedom: dfUnequalVariances)
            criticalValueEqualVariances = try SSProbDist.StudentT.quantile(p: 1 - alpha, degreesOfFreedom: dfEqualVariances)
            criticalValueUnequalVariances = try SSProbDist.StudentT.quantile(p: 1 - alpha, degreesOfFreedom: dfUnequalVariances)
            let lArray:Array<SSExamine<T, FPT>> = [sample1, sample2]
            if let leveneResult: SSVarianceEqualityTestResult = try leveneTest(data: lArray, testType: .median, alpha: alpha) {
                cdfLeveneMedian = leveneResult.pValue!
                variancesAreEqualMedian = leveneResult.equality!
            }
            else {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("data are not sufficient. skewness/kurtosis not obtainable", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
            if cdfTValueEqualVariances > FPT.half {
                twoTailedEV = (1 - cdfTValueEqualVariances) * 2
                oneTailedEV = 1 - cdfTValueEqualVariances
            }
            else {
                twoTailedEV = cdfTValueEqualVariances * 2
                oneTailedEV = cdfTValueEqualVariances
            }
            if cdfTValueEqualVariances > FPT.half {
                twoTailedUEV = (1 - cdfTValueUnequalVariances) * 2
                oneTailedUEV = 1 - cdfTValueUnequalVariances
            }
            else {
                twoTailedUEV = cdfTValueUnequalVariances * 2
                oneTailedUEV = cdfTValueUnequalVariances
            }
            let effectSize_EV:FPT = sqrt((tValueEqualVariances * tValueEqualVariances) / ((tValueEqualVariances * tValueEqualVariances) + dfEqualVariances))
            let effectSize_UEV:FPT = sqrt((tValueUnequalVariances * tValueUnequalVariances) / ((tValueUnequalVariances * tValueUnequalVariances) + dfUnequalVariances))
            // Welch
            let var1OverN1: FPT = var1 / n1
            let var2OverN2: FPT = var2 / n2
            let sumVar: FPT = var1OverN1 + var2OverN2
            ex1 = ( n1 * n1 * (n1 - 1))
            ex2 = SSMath.pow1(var1, 2)
            ex3 = ( n2 * n2 * (n2 - 1))
            let denomnatorWelchDF: FPT = ex2 / ex1 + ex2 / ex3
            let welchT: FPT = (mean1 - mean2) / sqrt(var1OverN1 + var2OverN2 )
            let welchDF: FPT = (sumVar * sumVar) / denomnatorWelchDF
            let cdfWelch: FPT = try SSProbDist.StudentT.cdf(t: welchT, degreesOfFreedom: welchDF)
            var twoSidedWelch: FPT
            var oneTailedWelch: FPT
            if cdfWelch > FPT.half {
                twoSidedWelch = (1 - cdfWelch) * 2
                oneTailedWelch = 1 - cdfWelch
            }
            else {
                twoSidedWelch = cdfWelch * 2
                oneTailedWelch = cdfWelch
            }
            var result: SS2SampleTTestResult<FPT> = SS2SampleTTestResult<FPT>()
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
            result.mean1GTEmean2 = variancesAreEqualMedian ? ((cdfTValueEqualVariances > (1 - alpha)) ? true : false) : ((cdfTValueUnequalVariances > (1 - alpha)) ?  true : false)
            result.mean1LTEmean2 = (variancesAreEqualMedian) ? ((cdfTValueEqualVariances < alpha) ? true : false) : ((cdfTValueUnequalVariances < alpha) ? true : false)
            result.mean1EQmean2 = (variancesAreEqualMedian) ? ((cdfTValueEqualVariances >= alpha && cdfTValueEqualVariances <= (1 - alpha)) ? true : false) : ((cdfTValueUnequalVariances >= alpha && cdfTValueUnequalVariances <= (1 - alpha)) ? true : false)
            result.mean1UEQmean2 = (variancesAreEqualMedian) ? ((cdfTValueEqualVariances < alpha || cdfTValueEqualVariances > (1 - alpha)) ? true : false ) : ((cdfTValueUnequalVariances < alpha || cdfTValueUnequalVariances > (1 - alpha)) ? true : false)
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
    /// - Parameter sample: Data as SSExamine<Numeric, SSFloatingPoint>
    /// - Parameter mean: Reference mean
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff sample.sampleSize < 2
    public static func oneSampleTTest<T, FPT: SSFloatingPoint & Codable>(sample: SSExamine<T, FPT>, mean: FPT, alpha: FPT) throws -> SSOneSampleTTestResult<FPT>  where T: Hashable & Comparable & Codable {
        if sample.sampleSize < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample size is expected to be >= 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if !sample.isNumeric {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("T Test is defined for numerical data only", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var testStatisticValue: FPT = 0
        var pValue: FPT = 0
        let N: FPT =  Helpers.makeFP(sample.sampleSize)
        let diffmean: FPT = sample.arithmeticMean! - mean
        let twoTailed: FPT
        let oneTailed: FPT
        do {
            testStatisticValue = diffmean / (sample.standardDeviation(type: .unbiased)! / sqrt(N))
            pValue = try SSProbDist.StudentT.cdf(t: testStatisticValue, degreesOfFreedom: N - 1)
            if pValue > FPT.half {
                twoTailed = (1 - pValue) * 2
                oneTailed = 1 - pValue
            }
            else {
                twoTailed = pValue * 2
                oneTailed = pValue
            }
            var result: SSOneSampleTTestResult<FPT> = SSOneSampleTTestResult<FPT>()
            result.p1Value = oneTailed
            result.p2Value = twoTailed
            result.tStat = testStatisticValue
            result.cv90Pct = try SSProbDist.StudentT.quantile(p:  Helpers.makeFP(1 - 0.05), degreesOfFreedom: N - 1)
            result.cv95Pct = try SSProbDist.StudentT.quantile(p:  Helpers.makeFP(1 - 0.025), degreesOfFreedom: N - 1)
            result.cv99Pct = try SSProbDist.StudentT.quantile(p:  Helpers.makeFP(1 - 0.005), degreesOfFreedom: N - 1)
            result.mean = sample.arithmeticMean!
            result.sampleSize = N
            result.mean0 = mean
            result.difference = diffmean
            result.stdDev = sample.standardDeviation(type: .unbiased)!
            result.stdErr = sample.standardError!
            result.df = N - 1
            result.meanEQtestValue = ((pValue < (alpha / 2)) || (pValue > (1 - (alpha / 2)))) ? false : true
            result.meanLTEtestValue = (pValue < alpha) ? true : false
            result.meanGTEtestValue = (pValue > (1 - alpha)) ? true : false
            return result
        }
        catch {
            throw error
        }
    }
    
    /// Performs the one sample t test
    /// - Parameter data: Data as Array<Numeric>
    /// - Parameter mean: Reference mean
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff sample.sampleSize < 2
    public static func oneSampleTTEst<T, FPT: SSFloatingPoint & Codable>(data: Array<T>, mean: FPT, alpha: FPT) throws -> SSOneSampleTTestResult<FPT> where T: Hashable & Comparable & Codable {
        if data.count < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample size is expected to be >= 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let sample:SSExamine<T, FPT> = SSExamine<T, FPT>.init(withArray: data, name: nil, characterSet: nil)
        do {
            return try oneSampleTTest(sample: sample, mean: mean, alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    /// Performs the t test for matched pairs
    /// - Parameter set1: data of set1 as SSExamine<Numeric, SSFloatingPoint>
    /// - Parameter set2: data of set2 as SSExamine<Numeric, SSFloatingPoint>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff set1.sampleSize < 2 || set2.sampleSize < 2 || (set1.sampleSize != set2.sampleSize)
    public static func matchedPairsTTest<T, FPT: SSFloatingPoint & Codable>(set1: SSExamine<T, FPT>!, set2: SSExamine<T, FPT>, alpha: FPT) throws -> SSMatchedPairsTTestResult<FPT> where T: Hashable & Comparable & Codable {
        if set1.sampleSize < 2 || set2.sampleSize < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample size is expected to be >= 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set1.sampleSize != set2.sampleSize {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample sizes are expected to be equal", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if !set1.isNumeric || !set2.isNumeric {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("T Test is defined for numerical data only", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let m1: FPT = set1.arithmeticMean!
        let m2: FPT = set2.arithmeticMean!
        let s1: FPT = set1.variance(type: .unbiased)!
        let s2: FPT = set2.variance(type: .unbiased)!
        let diffMeans: FPT = m1 - m2
        let a1: [T] = set1.elementsAsArray(sortOrder: .raw)!
        let a2: [T] = set2.elementsAsArray(sortOrder: .raw)!
        var sum: FPT = 0
        let n: Int = set1.sampleSize
        var i: Int = 0
        let pSum = m1 * m2
        while i < n {
            sum +=  Helpers.makeFP(a1[i]) *  Helpers.makeFP(a2[i]) - pSum
            i += 1
        }
        let df: FPT =  Helpers.makeFP(n) - 1
        let cov: FPT = sum / df
        var ex1: FPT = df + FPT.one
        var ex2: FPT = 2 * cov
        var ex3: FPT = s1 + s2
        var ex4: FPT = (ex3 - ex2) / ex1
        let sed: FPT = sqrt(ex4)
        let sdDiff: FPT = sqrt(s1 + s2 - 2 * cov)
        var t: FPT = diffMeans / sed
        if t.isNaN {
            t = 0
        }
        let corr = cov / (sqrt(s1) * sqrt(s2))
        do {
            ex1 = sqrt(df - 1)
            ex2 = (1 - corr * corr)
            ex3 = ex1 / ex2
            ex4 = try FPT.one - SSProbDist.StudentT.cdf(t: corr * ex3 , degreesOfFreedom: df - 1)
            let pCorr: FPT = 2 * ex4
            let lowerCIDiff: FPT =  try (diffMeans - SSProbDist.StudentT.quantile(p:  Helpers.makeFP(0.975), degreesOfFreedom: df) * sed)
            let upperCIDiff: FPT =  try (diffMeans + SSProbDist.StudentT.quantile(p:  Helpers.makeFP(0.975), degreesOfFreedom: df) * sed)
            var pTwoTailed: FPT = try SSProbDist.StudentT.cdf(t: t, degreesOfFreedom: df)
            if pTwoTailed > FPT.half {
                pTwoTailed = 1 - pTwoTailed
            }
            pTwoTailed *= 2
            if sed.isZero {
                pTwoTailed = 1
            }
            let effectSize:FPT = sqrt((t * t) / ((t * t) + df))
            var result: SSMatchedPairsTTestResult<FPT> = SSMatchedPairsTTestResult<FPT>()
            result.sampleSize =  Helpers.makeFP(n)
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
    /// - Parameter set1: data of set1 as Array<Numeric>
    /// - Parameter set2: data of set2 as Array<Numeric>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff data1.count < 2 || data2.count < 2 || data1.count != data2.count
    public static func matchedPairsTTest<T, FPT: SSFloatingPoint & Codable>(data1: Array<T>, data2: Array<T>, alpha: FPT) throws -> SSMatchedPairsTTestResult<FPT> where T: Hashable & Comparable & Codable {
        if data1.count < 2 || data2.count < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample size is expected to be >= 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if data1.count != data2.count {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample sizes are expected to be equal", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let set1 = SSExamine<T, FPT>.init(withArray: data1, name: nil, characterSet: nil)
        let set2 = SSExamine<T, FPT>.init(withArray: data2, name: nil, characterSet: nil)
        do {
            return try matchedPairsTTest(set1: set1, set2: set2, alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    
    /// Performs a one way ANOVA (multiple means test)
    /// - Parameter data: data as Array<Numeric>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff data.count <= 2
    public static func oneWayANOVA<T, FPT: SSFloatingPoint & Codable>(data: Array<Array<T>>!, alpha: FPT) throws -> SSOneWayANOVATestResult<FPT>? where T: Hashable & Comparable & Codable {
        if data.count <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("number of samples is expected to be > 2", log: .log_stat, type: .error)
            }
            
            #endif
            
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
    /// - Parameter data: data as SSExamine<Numeric, SSFloatingPoint>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff data.count <= 2
    public static func oneWayANOVA<T, FPT: SSFloatingPoint & Codable>(data: Array<SSExamine<T, FPT>>!, alpha: FPT) throws -> SSOneWayANOVATestResult<FPT>?  where T: Hashable & Comparable & Codable {
        if data.count <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("number of samples is expected to be > 2", log: .log_stat, type: .error)
            }
            
            #endif
            
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
    /// - Parameter dataFrame: data as SSDataFrame<Numeric, SSFloatingPoint>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError.invalidArgument iff data.count <= 2
    public static func oneWayANOVA<T, FPT: SSFloatingPoint & Codable>(dataFrame: SSDataFrame<T, FPT>, alpha: FPT) throws -> SSOneWayANOVATestResult<FPT>? where T: Hashable & Comparable & Codable {
        if dataFrame.columns <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("number of samples is expected to be > 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            var exArray = Array<SSExamine<T, FPT>>()
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
    /// same as oneWayAnova(_:,_:)
    /// - Parameter dataFrame: data as SSDataFrame<Numeric, SSFloatingPoint>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError.invalidArgument iff data.count <= 2
    public static func multipleMeansTest<T, FPT: SSFloatingPoint & Codable>(dataFrame: SSDataFrame<T, FPT>, alpha: FPT) throws -> SSOneWayANOVATestResult<FPT>? where T: Hashable & Comparable & Codable {
        if dataFrame.columns <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("number of samples is expected to be > 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            var exArray = Array<SSExamine<T, FPT>>()
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
    /// same as oneWayAnova(_:,_:)
    /// - Parameter data: data as Array<Numeric>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff data.count <= 2
    public static func multipleMeansTest<T, FPT: SSFloatingPoint & Codable>(data: Array<Array<T>>!, alpha: FPT) throws -> SSOneWayANOVATestResult<FPT>? where T: Hashable & Comparable & Codable {
        if data.count <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("number of samples is expected to be > 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var examines: Array<SSExamine<T, FPT>> = Array<SSExamine<T, FPT>>()
        for array in data {
            examines.append(SSExamine<T, FPT>.init(withArray: array, name: nil, characterSet: nil))
        }
        do {
            return try SSHypothesisTesting.multipleMeansTest(data: examines, alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    /// Performs a one way ANOVA (multiple means test)
    /// same as oneWayAnova(_:,_:)
    /// - Parameter data: data as SSExamine<Numeric, SSFloatingPoint>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff data.count <= 2
    public static func multipleMeansTest<T, FPT: SSFloatingPoint & Codable>(data: Array<SSExamine<T, FPT>>!, alpha: FPT) throws -> SSOneWayANOVATestResult<FPT>? where T: Hashable & Comparable & Codable {
        if data.count <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("number of samples is expected to be > 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        for table: SSExamine<T, FPT> in data {
            if !table.isNumeric {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("ANOVA is defined for numerical data only", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
        }
        var overallMean: FPT
        var sum: FPT = 0
        // total number of observations
        var N: Int = 0
        // p value of Bartlett test
        var pBartlett: FPT
        // p value of Levene test
        var pLevene: FPT
        // explained sum of squares
        var SST: FPT = 0
        // residual sum of squares
        var SSE: FPT = 0
        // test statistic
        var F: FPT
        var pValue: FPT
        var cdfValue: FPT
        var cutoffAlpha: FPT
        var meansEqual: Bool
        let groups: FPT =  Helpers.makeFP(data.count)
        do {
            if let bartlettTest: SSVarianceEqualityTestResult<FPT> = try SSHypothesisTesting.bartlettTest(data: data, alpha: alpha), let leveneTest = try SSHypothesisTesting.leveneTest(data: data, testType: .median, alpha: alpha) {
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
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("at least one sample is empty", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
            if let tot = examine.total {
                sum += tot
            }
            else {
                sum = FPT.nan
            }
            N += examine.sampleSize
        }
        overallMean = sum /  Helpers.makeFP(N)
        for examine in data {
            SST += SSMath.pow1(examine.arithmeticMean! - overallMean, 2) *  Helpers.makeFP(examine.sampleSize)
            SSE +=  Helpers.makeFP(examine.sampleSize - 1) * examine.variance(type: .unbiased)!
        }
        let MSE: FPT = SSE / ( Helpers.makeFP(N) - groups)
        let MST: FPT = SST / (groups - 1)
        F = MST / MSE
        do {
            cdfValue = try SSProbDist.FRatio.cdf(f: F, numeratorDF: groups - 1 , denominatorDF:  Helpers.makeFP(N) - groups)
            cutoffAlpha = try SSProbDist.FRatio.quantile(p: 1 - alpha, numeratorDF: groups - 1, denominatorDF:  Helpers.makeFP(N) - groups)
        }
        catch {
            throw error
        }
        pValue = 1 - cdfValue
        meansEqual = F <= cutoffAlpha
        var result: SSOneWayANOVATestResult<FPT> = SSOneWayANOVATestResult<FPT>()
        result.p2Value = pValue
        result.FStatistic = F
        result.alpha = alpha
        result.meansEQUAL = meansEqual
        result.cv = cutoffAlpha
        result.pBartlett = pBartlett
        result.pLevene = pLevene
        result.dfTotal =  Helpers.makeFP(N) - 1
        result.dfError =  Helpers.makeFP(N) - groups
        result.dfTreatment = groups - 1
        result.SSError = SSE
        result.SSTreatment = SST
        result.MSError = MSE
        result.MSTreatment = MST
        return result
    }
    
    
    // post hoc tests
    
    
    
    
    // TUKEY KRAMER
    // All means are compared --> k(k - 1) / 2 comparisons (k = number of means)

    /// Performs the Tukey-Kramer test for multiple comparisons
    ///
    /// ### Structure of the differences array: ###
    ///
    ///                   m(0)        m(1)        m(2)        m(3)        ...     m(k - 1)
    ///    m(0)           -           d(0,1)      d(0,2)      m(0,3)      ...     d(0,k - 1)
    ///    m(1)           d(1,0)      -           d(1,2)      m(1,3)      ...     d(1,k - 1)
    ///    m(2)           d(2,0)      d(2,1)      -           m(2,3)      ...     d(2,k - 1)
    ///    m(3)           d(3,0)      d(3,1)      -           -           ...     d(3,k - 1)
    ///    .              .           .           .           .           ...     d(2,k - 1)
    ///    .              .           .           .           .           ...     .
    ///    m(k - 1)       d(k - 1,0)  d(k - 1,1)  d(k - 1,2)  d(k - 1,3)  ...     -
    ///
    ///
    ///
    /// ### Structure of the T array: ###
    ///
    ///                   m(0)        m(1)        m(2)        ...     m(k - 1)
    ///    m(0)           -           T(0,1)      T(0,2)      ...     T(0,k - 1)
    ///    m(1)           T(1,0)      -           T(1,2)      ...     T(1,k - 1)
    ///    m(2)           T(2,0)      T(2,1)      -           ...     T(2,k - 1)
    ///    .              .           .           .           ...     .
    ///    .              .           .           .           ...     .
    ///    .              .           .           .           ...     .
    ///    m(k - 1)       T(k - 1,0)  T(k - 1,1)  T(k - 1,2)  ...     -
    /// - Parameter data: data as SSDataFrame<Numeric>
    /// - Parameter alpha: Alpha
    /// - Returns:SSHSDResultRow
    /// - Throws: SSSwiftyStatsError.invalidArgument iff data.count <= 2
    /// - Precondition: Each examine object should be named uniquely.
    public static func tukeyKramerTest<T, FPT: SSFloatingPoint & Codable>(dataFrame: SSDataFrame<T, FPT>, alpha: FPT) throws -> Array<SSPostHocTestResult<FPT>>? where T: Hashable & Comparable & Codable {
        do {
            if dataFrame.examines.count <= 2 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("number of samples is expected to be > 2", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
            return try SSHypothesisTesting.tukeyKramerTest(data: dataFrame.examines, alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    /// Performs the Tukey-Kramer test for multiple comparisons
    /// - Parameter data: data as SSExamine<Numeric, SSFloatingPoint>
    /// - Parameter alpha: Alpha
    /// - Returns:SSHSDResultRow
    /// - Throws: SSSwiftyStatsError.invalidArgument iff data.count <= 2
    /// - Precondition: Each examine object should be named uniquely.
    public static func tukeyKramerTest<T, FPT: SSFloatingPoint & Codable>(data: Array<SSExamine<T, FPT>>, alpha: FPT) throws -> Array<SSPostHocTestResult<FPT>>?  where T: Hashable & Comparable & Codable {
        if data.count <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("number of samples is expected to be > 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var means = Array<FPT>()
        for examine in data {
            if examine.isNumeric {
                means.append(examine.arithmeticMean!)
            }
            else {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("Tukey Kramer is defined for numerical data only", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
        }
        var Q = Array<Array<FPT>>()
        var differences = Array<Array<FPT>>()
        var temp: FPT
        var sum1: FPT = 0
        var sum2: FPT = 0
        let k: Int = data.count
        var n_total: FPT = 0
        // compute means
        for i in stride(from: 0, through: data.count - 1, by: 1) {
            differences.append(Array<FPT>())
            for j in stride(from: 0, through: data.count - 1, by: 1) {
                differences[i].append(FPT.nan)
                if j >= i + 1 {
                    temp = means[i] - means[j]
                    differences[i][j] = temp
                }
            }
        }
        // compute pooled variance
        for i in stride(from: 0, through: data.count - 1, by: 1) {
            n_total = n_total +  Helpers.makeFP(data[i].sampleSize)
            sum1 = 0
            for j in stride(from: 0, through: data[i].sampleSize - 1, by: 1) {
                if let tempDat: T = data[i][j] {
                    let t: FPT =  Helpers.makeFP(tempDat)
                    sum1 = sum1 + SSMath.pow1(t - means[i], 2)
                }
                else {
                    fatalError()
                }
            }
            sum2 = sum2 + sum1
        }
        let s: FPT = sqrt(sum2 / (n_total -  Helpers.makeFP(data.count)))
        var n_i: FPT
        var n_j: FPT
        // compute test statistics
        let half: FPT = FPT.half
        for i in stride(from: 0, through: data.count - 1, by: 1) {
            Q.append(Array<FPT>())
            n_i =  Helpers.makeFP(data[i].sampleSize)
            for j in stride(from: 0, through: data.count - 1, by: 1) {
                Q[i].append(FPT.nan)
                if j >= i + 1 {
                    n_j =  Helpers.makeFP(data[j].sampleSize)
                    if n_i == n_j {
                        Q[i][j] = abs(differences[i][j]) / ( s * sqrt(1 / n_i))
                    }
                    else {
                        let e1: FPT = FPT.one / n_i
                        let e2: FPT = FPT.one / n_j
                        let e3: FPT = e1 / e2
                        Q[i][j] = abs(differences[i][j]) / ( s * sqrt(half * e3))
                    }
                }
            }
        }
        var pValues = Array<Array<FPT>>()
        var temp1: Double = 0.0
        for i in stride(from: 0, through: data.count - 1, by: 1) {
            pValues.append(Array<FPT>())
            for j in stride(from: 0, through: data.count - 1, by: 1) {
                pValues[i].append(FPT.nan)
                if j >= i + 1 {
                    temp1 = Double.nan
                    do {
                        temp1 = try Helpers.ptukey(q:  Helpers.makeFP(Q[i][j]), nranges: 1, numberOfMeans: Double(data.count), df:  Helpers.makeFP(n_total) - Double(data.count), tail: .upper, returnLogP: false)
                    }
                    catch {
                        #if os(macOS) || os(iOS)
                        
                        if #available(macOS 10.12, iOS 13, *) {
                            os_log("unable to compute ptukey", log: .log_stat, type: .error)
                        }
                        
                        #endif
                        
                    }
                    pValues[i][j] =  Helpers.makeFP(temp1)
                }
            }
        }
        var confIntv: Array<Array<SSConfIntv<FPT>>> = Array<Array<SSConfIntv<FPT>>>()
        var lb: FPT
        var ub: FPT
        var halfWidth: FPT
        var criticalQ: Double = 0
        do {
            criticalQ = try Helpers.qtukey(p: 1.0 -  Helpers.makeFP(alpha), nranges: 1, numberOfMeans: Double(data.count), df:  Helpers.makeFP(n_total) - Double(data.count), tail: .lower, log_p: false)
        }
        catch {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("unable to compute qtukey", log: .log_stat, type: .error)
            }
            
            #endif
            
            return nil
        }
        for i in stride(from: 0, through: data.count - 1 , by: 1) {
            confIntv.append(Array<SSConfIntv>())
            n_i =  Helpers.makeFP(data[i].sampleSize)
            for j in stride(from: 0, through: data.count - 1, by: 1) {
                n_j =  Helpers.makeFP(data[j].sampleSize)
                confIntv[i].append(SSConfIntv())
                if j >= i + 1 {
                    if n_i != n_j {
                        let e1: FPT = FPT.one / n_i
                        let e2: FPT = FPT.one / n_j
                        let e3: FPT = e1 / e2
                        halfWidth =  Helpers.makeFP(criticalQ) * s * sqrt(e3 /  Helpers.makeFP(2))
                    }
                    else {
                        halfWidth =  Helpers.makeFP(criticalQ) * s * sqrt(1 / n_i)
                    }
                    lb = differences[i][j] - halfWidth
                    ub = differences[i][j] + halfWidth
                    confIntv[i][j].lowerBound = lb
                    confIntv[i][j].upperBound = ub
                    confIntv[i][j].intervalWidth = 2 * halfWidth
                }
            }
        }
        
        var summary: Array<SSPostHocTestResult<FPT>> = Array<SSPostHocTestResult<FPT>>()
        var tempSummary: SSPostHocTestResult<FPT>
        for i in stride(from: 0, through: k - 2, by: 1) {
            for j in stride(from: i + 1, through: k - 1, by: 1) {
                tempSummary = (row: data[i].name! + "-" +  data[j].name!, meanDiff: differences[i][j], testStat: Q[i][j], pValue:  pValues[i][j], testType: .tukeyKramer)
                summary.append(tempSummary)
            }
        }
        return summary
    }
    
    /// Performs the post hoc test according to Scheffé
    ///
    /// - Parameter dataFrame: Data as SSDataFrame
    /// - Parameter alpha: Alpha
    /// - Returns: A SSPostHocTestResult struct
    /// - Throws: SSSwiftyStatsError.invalidArgument iff data.count <= 2
    public static func scheffeTest<T, FPT: SSFloatingPoint & Codable>(dataFrame: SSDataFrame<T, FPT>, alpha: FPT) throws -> Array<SSPostHocTestResult<FPT>>?   where T: Hashable & Comparable & Codable {
        do {
            var tukeyR: Array<SSPostHocTestResult<FPT>>?
            tukeyR = try SSHypothesisTesting.tukeyKramerTest(dataFrame: dataFrame, alpha: alpha)
            if let tukey = tukeyR {
                var scheffeResults: Array<SSPostHocTestResult<FPT>> = Array<SSPostHocTestResult<FPT>>()
                var n_total: FPT  = 0
                var k: FPT
                var df_error: FPT
                var tempRes: SSPostHocTestResult<FPT>
                k =  Helpers.makeFP(dataFrame.examines.count)
                for ex in dataFrame.examines {
                    n_total = n_total +  Helpers.makeFP(ex.sampleSize)
                }
                df_error = n_total - k
                for tk in tukey {
                    tempRes.meanDiff = tk.meanDiff
                    tempRes.row = tk.row
                    tempRes.testType = .scheffe
                    tempRes.testStat = tk.testStat / FPT.sqrt2
                    tempRes.pValue = try SSProbDist.FRatio.cdf(f: SSMath.pow1(tempRes.testStat, 2) / (k - 1), numeratorDF: k - 1, denominatorDF: df_error)
                    tempRes.pValue = 1 - tempRes.pValue
                    scheffeResults.append(tempRes)
                }
                return scheffeResults
            }
            else {
                return nil
            }
        }
        catch {
            throw error
        }
    }
    
    public static func bonferroniTest<T, FPT: SSFloatingPoint & Codable>(dataFrame: SSDataFrame<T, FPT>) throws -> Array<SSPostHocTestResult<FPT>>? where T: Hashable & Comparable & Codable {
        assert( false, "not implemented yet")
        return nil
    }
    
    
    
}

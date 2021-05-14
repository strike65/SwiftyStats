//
//  SSSwiftyStats-EnumsStructs.swift
//  SwiftyStats
//
//  Created by strike65 on 01.07.17.
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



/// Confidence interval struct
public struct SSConfIntv<FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable {
    /// Lower bound of the CI
    public var lowerBound: FPT?
    /// Upper bound of the CI
    public var upperBound: FPT?
    /// Range of the CI
    public var intervalWidth: FPT?
    public var description: String {
        var descr = String()
        if let lb = self.lowerBound, let ub = self.upperBound, let w = self.intervalWidth {
            descr.append("CONFIDENCE INTERVAL\n")
            descr.append("*******************\n")
            descr.append("lower bound: \(lb)\n")
            descr.append("upper bound: \(ub)\n")
            descr.append("width: \(w)\n")
        }
        return descr
    }
}


/// Quartile struct
public struct SSQuartile<FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable {
    /// 25% Quartile
    public var q25: FPT
    /// 50% Quartile
    public var q50: FPT
    /// 75% Quartile
    public var q75: FPT
    
    init(Q25: FPT, Q50: FPT, Q75: FPT) {
        q25 = Q25
        q50 = Q50
        q75 = Q75
    }
    
    init() {
        q25 = 0
        q50 = 0
        q75 = 0
    }
    
    public var description: String {
        var descr = String()
        descr.append("QUARTILES\n")
        descr.append("*********\n")
        descr.append("q25: \(self.q25)\nq50: \(self.q50)\nq75: \(self.q75)\n")
        return descr
    }
}

/// Struct containing descriptive stats
public struct SSDescriptiveStats<FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable {
    /// arithmetic mean
    public var mean: FPT
    /// Variance
    public var variance: FPT
    /// Sample size
    public var sampleSize: FPT
    /// Standard deviation
    public var standardDeviation: FPT
    
    init(mean: FPT, variance: FPT, sampleSize: FPT, standardDev: FPT) {
        self.mean = mean
        self.variance = variance
        standardDeviation = standardDev
        self.sampleSize = sampleSize
    }
    init() {
        self.mean = 0
        self.variance = 0
        standardDeviation = 0
        self.sampleSize = 0
    }
    public var description: String {
        var descr = String()
        descr.append("DESCRIPTIVES\n")
        descr.append("************\n")
        descr.append("mean:\(self.mean)\nvariance:\(self.variance)\nn:\(self.sampleSize)\nsd:\(self.standardDeviation)\n")
        return descr
    }
}

/// Parameters of a continuous probability distribution
public struct SSProbDistParams<FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable {
    /// Kurtosis
    public var kurtosis: FPT
    /// Mean
    public var mean: FPT
    /// Skewness
    public var skewness: FPT
    /// Variance
    public var variance: FPT
    
    init(mean: FPT, variance: FPT, kurtosis: FPT, skewness: FPT) {
        self.mean = mean
        self.variance = variance
        self.skewness = skewness
        self.kurtosis = kurtosis
    }
    init() {
        self.mean = FPT.nan
        self.variance = FPT.nan
        self.skewness = FPT.nan
        self.kurtosis = FPT.nan
    }
    public var description: String {
        var descr = String()
        descr.append("DSITRIBUTION PARAMETERS\n")
        descr.append("***********************\n")
        descr.append("mean:\(self.mean)\nvariance:\(self.variance)\nkurtosis:\(self.kurtosis)\nskewness:\(self.skewness)\n")
        return descr
    }
    
}


public struct SSGrubbsTestResult<T: Codable & Comparable & Hashable, FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable {
    /// ciritcal value
    public var criticalValue: FPT?
    /// largest value
    public var largest: T?
    /// smallest value
    public var smallest: T?
    /// sample size
    public var sampleSize: Int?
    /// max difference
    public var maxDiff: FPT?
    /// arithmetic mean
    public var mean: FPT?
    /// Grubbs G
    public var G: FPT?
    /// sd
    public var stdDev: FPT?
    /// true iff G > ciriticalValue
    public var hasOutliers: Bool?
    /// Returns a description
    public var description: String {
        get {
            var descr = String()
            descr.append("GRUBBS TEST FOR OUTLIERS\n")
            descr.append("***********************\n")
            if let cv = self.criticalValue, let l = self.largest, let s = self.smallest, let n = self.sampleSize, let md = self.maxDiff, let m = self.mean, let g = self.G, let sd = self.stdDev, let ho = self.hasOutliers {
                descr.append("has outliers: \(ho)\n")
                descr.append("Grubbs G: \(g)\n")
                descr.append("max diff: \(md)\n")
                descr.append("critical value: \(cv)\n")
                descr.append("mean: \(m)\n")
                descr.append("sd: \(sd)\n")
                descr.append("largest value: \(l)\n")
                descr.append("smalles value: \(s)\n")
                descr.append("sample size: \(n)\n")
            }
            return descr
        }
    }
    
    
}
public struct SSESDTestResult<T: Codable & Comparable & Hashable, FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable  {
    /// sd
    public var stdDeviations: Array<FPT>?
    /// number of items removed during procedure
    public var itemsRemoved: Array<T>?
    /// test statistic
    public var testStatistics: Array<FPT>?
    /// array of lamddas
    public var lambdas: Array<FPT>?
    /// count of outliers found
    public var countOfOutliers: Int?
    /// array containing outliers found
    public var outliers: Array<T>?
    /// alpha
    public var alpha: FPT?
    /// max number of outliers to search for
    public var maxOutliers: Int?
    /// test type
    public var testType: SSESDTestType?
    /// array of the means
    public var means: Array<FPT>?
    /// Returns a description
    public var description: String {
        get {
            var descr = String()
            descr.append("ESD TEST FOR OUTLIERS\n")
            descr.append("*********************\n")
            if let sd = self.stdDeviations, let ir = self.itemsRemoved, let s = self.testStatistics, let l = self.lambdas, let no = self.countOfOutliers, let o = self.outliers, let a = self.alpha, let tt = self.testType, let me = self.means {
                descr.append("test type: \(tt)\n")
                descr.append("alpha: \(a)\n")
                descr.append("number of detected outliers: \(no)\n")
                descr.append("outliers: \(o)\n")
                descr.append("statistics: \(s)\n")
                descr.append("removed items: \(ir)\n")
                descr.append("lambdas: \(l)\n")
                descr.append("means: \(me)\n")
                descr.append("sd: \(sd)\n")
            }
            return descr
        }
    }
}


/// Results of the KS one sample test. The fields actually used depend on the target distribution.
public struct SSKSTestResult<FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable  {
    /// emprical mean
    public var estimatedMean: FPT?
    /// empirical sd
    public var estimatedSd: FPT?
    /// empirical variance
    public var estimatedVar: FPT?
    /// empirical lower bound
    public var estimatedLowerBound: FPT?
    /// empirical upper bound
    public var estimatedUpperBound: FPT?
    /// empirical degrees of freedom
    public var estimatedDegreesOfFreedom: FPT?
    /// empirical shape parameter
    public var estimatedShapeParam: FPT?
    /// empirical scale parameter
    public var estimatedScaleParam: FPT?
    /// target distribution
    public var targetDistribution: SSGoFTarget?
    /// p value
    public var pValue: FPT?
    /// max absolute difference
    public var maxAbsDifference: FPT?
    /// max absolute positive difference
    public var maxPosDifference: FPT?
    /// max absolute negative difference
    public var maxNegDifference: FPT?
    /// z value
    public var zStatistics: FPT?
    /// sample size
    public var sampleSize: Int?
    /// a string containing additional info (for certain distributions)
    public var infoString: String?
    /// Returns a description
    public var description: String {
        get {
            var descr = String()
            descr.append("KOLMOGOROV-SMIRNOV GOF TEST\n")
            descr.append("***************************\n")
            if let am = self.estimatedMean, let esd = self.estimatedSd, let eva = self.estimatedVar, let elb = self.estimatedLowerBound, let eub = self.estimatedUpperBound, let edf = self.estimatedDegreesOfFreedom, let esp = self.estimatedShapeParam, let escp = self.estimatedScaleParam, let p = self.pValue, let mabsdif = self.maxAbsDifference, let manediff = self.maxNegDifference, let mapodiff = self.maxPosDifference, let z = self.zStatistics, let n = self.sampleSize {
                descr.append("z: \(z)\n")
                descr.append("p: \(p)\n")
                descr.append("max abs diff: \(mabsdif)\n")
                descr.append("max diff < 0: \(manediff)\n")
                descr.append("max diff > 0: \(mapodiff)\n")
                descr.append("sample size: \(n)\n")
                descr.append("estimated mean: \(am)\n")
                descr.append("estimated sd: \(esd)\n")
                descr.append("estimated variance: \(eva)\n")
                descr.append("estimated lower bound (uniform distr): \(elb)\n")
                descr.append("estimated upper bound (uniform distr): \(eub)\n")
                descr.append("estimated df: \(edf)\n")
                descr.append("estimated shape param: \(esp)\n")
                descr.append("estimated scale param: \(escp)\n")
            }
            return descr
        }
    }
    
}


/// Results of the Anderson Darling test
public struct SSADTestResult<FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable  {
    /// p value (= (1 - alpha)-quantile of testStatistic
    public var pValue: FPT?
    /// Anderson Darling statistics
    public var AD: FPT?
    /// AD*
    public var ADStar: FPT?
    /// sample size
    public var sampleSize: Int?
    /// standard deviation
    public var stdDev: FPT?
    /// variance
    public var variance: FPT?
    /// mean
    public var mean: FPT?
    /// true iff pValue >= alpha
    public var isNormal: Bool?
    
    /// Returns a description
    public var description: String {
        get {
            var descr = String()
            descr.append("ANDERSON-DARLING TEST FOR NORMALITY\n")
            descr.append("***********************************\n")
            if let ad = self.AD, let ads = self.ADStar, let sd = self.stdDev, let v = self.variance, let m = self.mean, let isn = self.isNormal, let p = self.pValue, let n = self.sampleSize {
                descr.append("normality: \(isn)\n")
                descr.append("p: \(p)\n")
                descr.append("AD: \(ad)\n")
                descr.append("AD*: \(ads)\n")
                descr.append("mean: \(m)\n")
                descr.append("sd: \(sd)\n")
                descr.append("var: \(v)\n")
                descr.append("n: \(n)\n")
            }
            return descr
        }
    }
    
}

/// Result of tests for equality of variances (Bartlett, Levene, Brown-Forsythe)
public struct SSVarianceEqualityTestResult<FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable  {
    /// degrees of freedom
    public var df: FPT?
    /// critical value for alpha = 0.1
    public var cv90Pct: FPT?
    /// critical value for alpha = 0.05
    public var cv95Pct: FPT?
    /// critical value for alpha = 0.01
    public var cv99Pct: FPT?
    /// critical value for alpha as set by the call
    public var cvAlpha: FPT?
    /// p value (= (1 - alpha)-quantile of testStatistic
    public var pValue: FPT?
    /// test statistic value
    public var testStatistic: FPT?
    /// set to true iff pValue >= alpha
    public var equality: Bool?
    /// Test type
    public var testType: SSVarTestType?
    /// Returns a description
    public var description: String {
        get {
            var descr = String()
            descr.append("TEST FOR EQUALITY OF VARIANCES\n")
            descr.append("******************************\n")
            if let tt = self.testType, let adf = self.df, let cv90 = self.cv90Pct, let cv95 = self.cv95Pct, let cv99 = self.cv99Pct, let eq = self.equality, let p = self.pValue, let ts = self.testStatistic {
                descr.append("Test: \(tt)\n")
                descr.append("variances are equal: \(eq)\n")
                descr.append("p: \(p)\n")
                descr.append("critical value for alpha = 0.01: \(cv99)\n")
                descr.append("critical value for alpha = 0.05: \(cv95)\n")
                descr.append("critical value for alpha = 0.10: \(cv90)\n")
                descr.append("test statistic*: \(ts)\n")
                descr.append("degrees of freddom: \(adf)\n")
            }
            return descr
        }
    }
}

/// Results of the two sample t-Test
public struct SS2SampleTTestResult<FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable  {
    /// one sided p value for equal variances
    public var p1EQVAR: FPT?
    /// one sided p value for unequal variances
    public var p1UEQVAR: FPT?
    /// two sided p value for equal variances
    public var p2EQVAR: FPT?
    /// two sided p value for unequal variances
    public var p2UEQVAR: FPT?
    /// mean of sample 1
    public var mean1: FPT?
    /// mean of sample 2
    public var mean2: FPT?
    /// n of sample 1
    public var sampleSize1: FPT?
    /// n of sample 2
    public var sampleSize2: FPT?
    /// sd of sample 1
    public var stdDev1: FPT?
    /// sd of sample 1
    public var stdDev2: FPT?
    /// pooled sd
    public var pooledStdDev: FPT?
    /// pooled variance
    public var pooledVariance: FPT?
    /// mean1 - mean2
    public var differenceInMeans: FPT?
    /// t Value assuming equal variances
    public var tEQVAR: FPT?
    /// t Value assuming unequal variances
    public var tUEQVAR: FPT?
    /// p Value of the Levene test
    public var LeveneP: FPT?
    /// degrees of freedom assuming equal variances
    public var dfEQVAR: FPT?
    /// degrees of freedom assuming unequal variances (Welch)
    public var dfUEQVAR: FPT?
    /// Returns `True`, if var1 is statistically equal for var2
    public var variancesAreEqual: Bool? = false
    /// mean1 >= mean2
    public var mean1GTEmean2: Bool? = false
    /// mean1 <= mean2
    public var mean1LTEmean2: Bool? = false
    /// mean1 == mean2
    public var mean1EQmean2: Bool? = false
    /// mean1 != mean2
    public var mean1UEQmean2: Bool? = false
    /// critical value assuming equal variances
    public var CVEQVAR: FPT?
    /// critical value assuming unequal variances
    public var CVUEQVAR: FPT?
    /// effect size assuming equal variances
    public var rEQVAR: FPT?
    /// effect size assuming unequal variances
    public var rUEQVAR: FPT?
    /// t value according to Welch
    public var tWelch: FPT?
    /// degrees of freedom according to Welch
    public var dfWelch: FPT?
    /// two sided p value according to Welch
    public var p2Welch: FPT?
    /// one sided p value according to Welch
    public var p1Welch: FPT?
    /// Returns a description
    public var description: String {
        get {
            var descr = String()
            if let p1ev = self.p1EQVAR, let p1ue = self.p1UEQVAR, let p1w = self.p1Welch, let m1 = self.mean1, let m2 = self.mean2, let n1 = self.sampleSize1, let n2 = self.sampleSize2, let sd1 = self.stdDev1, let sd2 = self.stdDev2, let psd = self.pooledStdDev, let diff = self.differenceInMeans, let teq = self.tEQVAR, let tueq = self.tUEQVAR, let cvue = self.CVUEQVAR, let cveq = self.CVEQVAR, let req = self.rEQVAR, let rueq = self.rUEQVAR, let tw = self.tWelch, let lev = self.LeveneP {
                descr.append("TWO-SAMPLE T-TEST\n")
                descr.append("*****************\n")
                descr.append("mean group 1: \(m1)\n")
                descr.append("mean group 2: \(m2)\n")
                descr.append("sample size group 1: \(n1)\n")
                descr.append("sample size group 2: \(n2)\n")
                descr.append("p value of Levene test: \(lev)\n")
                descr.append("sd group 1: \(sd1)\n")
                descr.append("sd group 2: \(sd2)\n")
                descr.append("pooled sd: \(psd)\n")
                descr.append("difference in means: \(diff)\n")
                descr.append("t value for equal variances: \(teq)\n")
                descr.append("t value for unequal variances: \(tueq)\n")
                descr.append("t value Welch: \(tw)\n")
                descr.append("critical value for equal variances: \(cveq)\n")
                descr.append("critical value for unequal variances: \(cvue)\n")
                descr.append("one sided p value for equal variances: \(p1ev)\n")
                descr.append("one sided p value for unequal variances: \(p1ue)\n")
                descr.append("one sided p value (Welch): \(p1w)\n")
                descr.append("effect size for equal variances*: \(req)\n")
                descr.append("effect size for unequal variances*: \(rueq)\n")
            }
            return descr
        }
    }
}

/// Struct holding the results of the one sample t test
public struct SSOneSampleTTestResult<FPT: SSFloatingPoint & Codable>: CustomStringConvertible,Codable  {
    /// one sided p value
    public var p1Value: FPT?
    /// one sided p value
    public var p2Value: FPT?
    /// t Value
    public var tStat: FPT?
    /// critical value for alpha = 0.1
    public var cv90Pct: FPT?
    /// critical value for alpha = 0.05
    public var cv95Pct: FPT?
    /// critical value for alpha = 0.01
    public var cv99Pct: FPT?
    /// critical value for alpha as set by the call
    public var cvAlpha: FPT?
    /// mean
    public var mean: FPT?
    /// reference mean
    public var mean0: FPT?
    /// mean - mean0
    public var difference: FPT?
    /// n of sample
    public var sampleSize: FPT?
    /// sd
    public var stdDev: FPT?
    /// standard error
    public var stdErr: FPT?
    /// degrees of freedom
    public var df: FPT?
    /// mean1 >= mean0
    public var meanGTEtestValue: Bool? = false
    /// mean <= mean0
    public var meanLTEtestValue: Bool? = false
    /// mean == mean0
    public var meanEQtestValue: Bool? = false
    /// Returns a description
    public var description: String {
        get {
            var descr = String()
            if let p1 = self.p1Value, let p2 = self.p2Value, let t = self.tStat, let ms = self.mean, let m0 = self.mean0, let n = self.sampleSize, let cv90 = self.cv90Pct, let cv95 = self.cv95Pct, let cv99 = self.cv99Pct, let diff = self.difference, let sd = self.stdDev, let se = self.stdErr, let sdf = self.df {
                descr.append("ONE-SAMPLE T-TEST\n")
                descr.append("*****************\n")
                descr.append("sample size: \(n)\n")
                descr.append("degrees of freedom: \(sdf)\n")
                descr.append("mean 0: \(m0)\n")
                descr.append("sample mean: \(ms)\n")
                descr.append("difference: \(diff)\n")
                descr.append("sample sd: \(sd)\n")
                descr.append("standard error: \(se)\n")
                descr.append("t value: \(t)\n")
                descr.append("critical value for alpha = 0.01: \(cv99)\n")
                descr.append("critical value for alpha = 0.05: \(cv95)\n")
                descr.append("critical value for alpha = 0.10: \(cv90)\n")
                descr.append("one sided p value: \(p1)\n")
                descr.append("two sided p value: \(p2)\n")
            }
            return descr
        }
    }
}

/// Encapsulates the results of a matched pairs t test
public struct SSMatchedPairsTTestResult<FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable {
    /// Cov
    public var covariance: FPT?
    /// standard error of the difference
    public var stdEDiff: FPT?
    /// correlatiopn
    public var correlation: FPT?
    /// p value of correlation
    public var pValueCorr: FPT?
    /// effect size
    public var effectSizeR: FPT?
    /// upper bound of the 95%-confidence interval
    public var ci95upper: FPT?
    /// lower bound of the 95%-confidence interval
    public var ci95lower: FPT?
    /// sd of the differences
    public var stdDevDiff: FPT?
    /// sample size
    public var sampleSize: FPT?
    /// p value for two sided test
    public var p2Value: FPT?
    /// degrees of freedom
    public var df: FPT?
    /// t statistics
    public var tStat: FPT?
    /// Returns a description
    public var description: String {
        get {
            var descr = String()
            if let cov = self.covariance, let sted = self.stdEDiff, let corr = self.correlation, let pcorr = self.pValueCorr, let r = self.effectSizeR, let ci95u = self.ci95upper, let ci95l = self.ci95lower, let sddiff = self.stdDevDiff, let n = self.sampleSize, let p2 = self.p2Value, let sdf = self.df, let t = self.tStat {
                descr.append("MATCHED-PAIRS T-TEST\n")
                descr.append("********************\n")
                descr.append("sample size: \(n)\n")
                descr.append("degrees of freedom: \(sdf)\n")
                descr.append("covariance: \(cov)\n")
                descr.append("correlation: \(corr)\n")
                descr.append("correlation p value: \(pcorr)\n")
                descr.append("standard error of the differences: \(sted)\n")
                descr.append("effect size r: \(r)\n")
                descr.append("t value: \(t)\n")
                descr.append("lower bound of ci 95%: \(ci95l)\n")
                descr.append("upper bound of ci 95%: \(ci95u)\n")
                descr.append("sd od differences: \(sddiff)\n")
                descr.append("two sided p value: \(p2)\n")
            }
            return descr
        }
    }
}

/// Holds the results of the chi^2 variance test
public struct SSChiSquareVarianceTestResult<FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable {
    /// degrees of freedom
    public var df: FPT?
    /// variance ratio
    public var ratio: FPT?
    /// chi^2
    public var testStatisticValue: FPT?
    /// one sided p value
    public var p1Value: FPT?
    /// two sided p value
    public var p2Value: FPT?
    /// sample size
    public var sampleSize: FPT?
    /// true iff sample variance == s0
    public var sigmaUEQs0: Bool?
    /// true iff sample variance <= s0
    public var sigmaLTEs0: Bool?
    /// true iff sample variance >= s0
    public var sigmaGTEs0: Bool?
    /// sample standard deviation
    public var sd: FPT?
    /// Returns a description
    public var description: String {
        get {
            var descr = String()
            if let fr = self.ratio, let f = self.testStatisticValue, let p1 = self.p1Value, let p2 = self.p2Value, let ssd = self.sd, let n = self.sampleSize, let sdf = self.df {
                descr.append("CHI-SQUARE-TEST FOR EQUALITY OF VARIANCES\n")
                descr.append("*****************************************\n")
                descr.append("sample size: \(n)\n")
                descr.append("degrees of freedom: \(sdf)\n")
                descr.append("sd: \(ssd)\n")
                descr.append("F ratio: \(fr)\n")
                descr.append("f: \(f)\n")
                descr.append("one sided p value: \(p1)\n")
                descr.append("two sided p value: \(p2)\n")
            }
            return descr
        }
    }
}

/// Holds the results of the multiple means tes
public struct SSOneWayANOVATestResult<FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable {
    /// two sided p value
    public var p2Value: FPT?
    /// F ratio
    public var FStatistic: FPT?
    /// p value of the Bartlett test
    public var pBartlett: FPT?
    /// Alpha
    public var alpha: FPT?
    public var meansEQUAL: Bool?
    /// critical value at alpha
    public var cv: FPT?
    /// p value of the Levene test
    public var pLevene: FPT?
    /// total sum of square
    public var SSTotal: FPT?
    /// residual sum of squares (within groups)
    public var SSError: FPT?
    /// treatment sum of squares
    public var SSTreatment: FPT?
    /// error mean sum of squares
    public var MSError: FPT?
    /// treatment mean sum of squares
    public var MSTreatment: FPT?
    /// error degrees of freedom
    public var dfError: FPT?
    /// treatment degrees of freedom
    public var dfTreatment: FPT?
    /// total degrees of freedom
    public var dfTotal: FPT?
    /// Returns a description
    public var description: String {
        get {
            var descr = String()
            if let f = self.FStatistic, let pB = self.pBartlett, let cv = self.cv, let p2 = self.p2Value, let pL = self.pLevene, let SST = SSTotal, let SSE = SSError, let SSF = SSTreatment, let MSE = MSError, let MST = MSTreatment, let dft = dfTotal, let dfF = dfTreatment, let dfe = dfError {
                descr.append("MULTIPLE MEANS TEST\n")
                descr.append("*******************\n")
                descr.append("f: \(f)\n")
                descr.append("p value Bartlett test: \(pB)\n")
                descr.append("p value Levene test: \(pL)\n")
                descr.append("critical value: \(cv)\n")
                descr.append("two sided p value: \(p2)\n")
                descr.append("SS_total: \(SST)\n")
                descr.append("SS_error: \(SSE)\n")
                descr.append("SS_Treatment: \(SSF)\n")
                descr.append("df_total: \(dft)\n")
                descr.append("df_error: \(dfe)\n")
                descr.append("df_Treatment: \(dfF)\n")
                descr.append("MS_error: \(MSE)\n")
                descr.append("MS_treatment: \(MST)\n")
            }
            return descr
        }
    }
}

/// Holds the results of the F test for equal variances
public struct SSFTestResult<FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable {
    /// size of sample 1
    public var sampleSize1: FPT?
    /// size of sample 2
    public var sampleSize2: FPT?
    /// denominator degrees of freedom
    public var dfDenominator: FPT?
    /// numerator degrees of freedom
    public var dfNumerator: FPT?
    /// variance of sample 1
    public var variance1: FPT?
    /// variance of sample 2
    public var variance2: FPT?
    /// F ratio
    public var FRatio: FPT?
    /// one sided p value
    public var p1Value: FPT?
    /// two sided p value
    public var p2Value: FPT?
    /// indicates if variances are equal
    public var FRatioEQ1: Bool?
    /// indicates if var1 <= var2
    public var FRatioLTE1: Bool?
    /// indicates if var1 >= var2
    public var FRatioGTE1: Bool?
    /// confidence intervall for var1 == var2
    public var ciRatioEQ1: SSConfIntv<FPT>?
    /// confidence intervall for var1 <= var2
    public var ciRatioLTE1: SSConfIntv<FPT>?
    /// confidence intervall for var1 >= var2
    public var ciRatioGTE1: SSConfIntv<FPT>?
    /// Returns a description
    public var description: String {
        get {
            var descr = String()
            if let dfden = self.dfDenominator, let dfnum = self.dfNumerator, let var1 = self.variance1, let var2 = self.variance2, let f = self.FRatio, let n1 = self.sampleSize1, let n2 = self.sampleSize2, let cieq = self.ciRatioEQ1, let clt = self.ciRatioLTE1, let cig = self.ciRatioGTE1, let p1 = self.p1Value, let p2 = self.p2Value {
                descr.append("F-TEST\n")
                descr.append("******\n")
                descr.append("variance 1: \(var1)\n")
                descr.append("variance 2: \(var2)\n")
                descr.append("n1: \(n1)\n")
                descr.append("n2: \(n2)\n")
                descr.append("F ratio: \(f)\n")
                descr.append("denominator df: \(dfden)\n")
                descr.append("numerator df: \(dfnum)\n")
                descr.append("one sided p value: \(p1)\n")
                descr.append("two sided p value: \(p2)\n")
                descr.append("(1 - alpha)-CI for var1 = var2 \(cieq)\n")
                descr.append("(1 - alpha)-CI for var1 <= var1 \(clt)\n")
                descr.append("(1 - alpha)-CI for var1 >= var2 \(cig)\n")
            }
            return descr
        }
    }
}

/// Holds the results of Box Ljung Autocorrelation
public struct SSBoxLjungResult<FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable {
    /// coefficients as Dictionary<lag: String, coeff: FPT>
    public var coefficients: Array<FPT>?
    /// Bartlett standard error as Dictionary<lag: String, se: FPT>
    public var seBartlett: Array<FPT>?
    /// standard error for white noise as Dictionary<lag: String, se: FPT>
    public var seWN: Array<FPT>?
    /// test statistics as Dictionary<lag: String, stat: FPT>
    public var testStatistic: Array<FPT>?
    /// pavalues as  Dictionary<lag: String, pValue: FPT>
    public var pValues: Array<FPT>?
    /// Returns a description
    public var description: String {
        get {
            var descr = String()
            if let coeff = self.coefficients, let seB = self.seBartlett, let sew = self.seWN, let stats = self.testStatistic, let p = self.pValues {
                descr.append("Autocorrelation\n")
                descr.append("***************\n")
                descr.append("coefficients: \(coeff)\n")
                descr.append("Bartlett standard error: \(seB)\n")
                descr.append("White noise standard error: \(sew)\n")
                descr.append("Box-Ljung statistics: \(stats)\n")
                descr.append("p values: \(p)\n")
            }
            return descr
        }
    }

}

/// Holds the results of the runs test
public struct SSRunsTestResult<FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable {
    /// Number of items >= cutting point
    public var nGTEcp: FPT?
    /// Number of items < cutting point
    public var nLTcp: FPT?
    /// Number of runs
    public var nRuns: FPT?
    /// z value
    public var zStat: FPT?
    /// critical value
    public var criticalValue: FPT?
    /// p value
    public var pValueExact: FPT?
    /// p value asymptotic
    public var pValueAsymp: FPT?
    // cutting point used
    public var cp: FPT?
    /// Array of differences
    public var diffs: Array<FPT>?
    /// Randomness?
    public var randomness: Bool?
    /// Returns a description
    public var description: String {
        get {
            var descr = String()
            if let ng = self.nGTEcp, let nl = self.nLTcp, let runs = self.nRuns, let z = self.zStat, let pe = self.pValueExact, let pa = self.pValueAsymp, let ccp = self.cp, let d = self.diffs, let rnd = self.randomness {
                descr.append("RUNS TEST\n")
                descr.append("*********\n")
                descr.append("randomness?: \(rnd)\n")
                descr.append("cutting point: \(ccp)\n")
                descr.append("number of values > cutting point: \(ng)\n")
                descr.append("number of values < cutting point: \(nl)\n")
                descr.append("number of runs: \(runs)\n")
                descr.append("z: \(z)\n")
                descr.append("exact p value: \(pe)\n")
                descr.append("asymp. p value: \(pa)\n")
                descr.append("differenes: \(d)\n")
            }
            return descr
        }
    }
}

/// Holds the results of the Mann-Whitney U test
public struct SSMannWhitneyUTestResult<FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable {
    /// sum of ranks in set 1
    public var sumRanks1: FPT?
    /// sum of ranks in set 2
    public var sumRanks2: FPT?
    /// mean of ranks in set 1
    public var meanRank1: FPT?
    /// mean of ranks in set 2
    public var meanRank2: FPT?
    /// sum of tied ranks
    public var sumTiedRanks: FPT?
    /// number of ties
    public var nTies: Int?
    /// U
    public var UMannWhitney: FPT?
    /// Wilcoxon W
    public var WilcoxonW: FPT?
    /// Z
    public var zStat: FPT?
    /// two sided approximated p value
    public var p2Approx: FPT?
    /// two sided exact p value
    public var p2Exact: FPT?
    /// one sided approximated p value
    public var p1Approx: FPT?
    /// one sided exact p value
    public var p1Exact: FPT?
    /// effect size
    public var effectSize: FPT?
    /// Returns a description
    public var description: String {
        get {
            var descr = String()
            if let sr1 = self.sumRanks1, let sr2 = self.sumRanks2, let mr1 = self.meanRank1, let mr2 = self.meanRank2, let str = self.sumTiedRanks, let nt = self.nTies, let U = self.UMannWhitney, let W = self.WilcoxonW, let z = self.zStat, let p1a = self.p1Approx, let p2a = self.p2Approx, let p1e = self.p1Exact, let p2e = self.p1Exact, let es = self.effectSize {
                descr.append("MANN-WHITNEY U TEST\n")
                descr.append("*******************\n")
                descr.append("Mann-Whitney U: \(U)\n")
                descr.append("Wilcoxon W: \(W)\n")
                descr.append("z: \(z)\n")
                descr.append("one sided exact p value: \(p1e)\n")
                descr.append("two sided exact p value: \(p2e)\n")
                descr.append("one sided asymp. p value: \(p1a)\n")
                descr.append("two sided asymp. p value: \(p2a)\n")
                descr.append("sum ranks group 1: \(sr1)\n")
                descr.append("sum ranks group 2: \(sr2)\n")
                descr.append("mean rank group 1: \(mr1)\n")
                descr.append("mean rank group 2: \(mr2)\n")
                descr.append("sum of tied ranks: \(str)\n")
                descr.append("count of ties: \(nt)\n")
                descr.append("effect size: \(es)\n")
            }
            return descr
        }
    }
}


/// Holds the results of the Wilcoxon test for matched pairs
public struct SSWilcoxonMatchedPairsTestResult<FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable {
    /// two sided p value
    public var p2Value: FPT?
    /// sample size
    public var sampleSize: FPT?
    /// number of ranks > 0
    public var nPosRanks: Int?
    /// number of ranks < 0
    public var nNegRanks: Int?
    /// number of ties
    public var nTies: Int?
    /// number of zero valued differences
    public var nZeroDiff: Int?
    /// sum of negative ranks
    public var sumNegRanks: FPT?
    /// sum of positive ranks
    public var sumPosRanks: FPT?
    /// mean of negative ranks
    public var meanPosRanks: FPT?
    /// mean of positive ranks
    public var meanNegRanks: FPT?
    /// z statistic
    public var zStat: FPT?
    /// Cohen's d
    public var dCohen: FPT?
    /// Returns a description
    public var description: String {
        get {
            var descr = String()
            if let p2 = self.p2Value, let n = self.sampleSize, let np = self.nPosRanks, let nn = self.nNegRanks, let nt = self.nTies, let nz = self.nZeroDiff, let snr = self.sumNegRanks, let spr = self.sumPosRanks, let mpr = self.meanPosRanks, let mnr = self.meanNegRanks, let z = self.zStat, let dc = self.dCohen {
                descr.append("WILCOXON TEST FOR MATCHED PAIRS\n")
                descr.append("*******************************\n")
                descr.append("two sided p value: \(p2)\n")
                descr.append("z: \(z)\n")
                descr.append("Cohen's d: \(dc)\n")
                descr.append("sample size: \(n)\n")
                descr.append("mean of ranks > 0: \(mpr)\n")
                descr.append("mean of ranks < 0: \(mnr)\n")
                descr.append("sum of ranks > 0: \(spr)\n")
                descr.append("sum of ranks < 0: \(snr)\n")
                descr.append("count of ranks > 0: \(np)\n")
                descr.append("count of ranks < 0: \(nn)\n")
                descr.append("count of tied ranks: \(nt)\n")
                descr.append("count of zeros: \(nz)\n")
            }
            return descr
        }
    }
    
}
/// Sign test results
public struct SSSignTestRestult<FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable {
    /// exact p value
    public var pValueExact: FPT?
    /// asymptotic p value
    public var pValueApprox: FPT?
    /// number of differences > 0
    public var nPosDiff: Int?
    /// number of differences < 0
    public var nNegDiff: Int?
    /// number of ties
    public var nTies: Int?
    /// sample size
    public var total: Int?
    /// z value
    public var zStat: FPT?
    /// Returns a description
    public var description: String {
        get {
            var descr = String()
            if let pe = self.pValueExact, let pa = self.pValueApprox, let np = self.nPosDiff, let nn = self.nNegDiff, let nt = self.nTies, let n = self.total, let z = self.zStat {
                descr.append("SIGN TEST\n")
                descr.append("*********\n")
                descr.append("p value exaxt: \(pe)\n")
                descr.append("p value asymp: \(pa)\n")
                descr.append("z: \(z)\n")
                descr.append("count of \"+\": \(np)\n")
                descr.append("count of \"-\": \(nn)\n")
                descr.append("count of ties: \(nt)\n")
                descr.append("n: \(n)\n")
            }
            return descr
        }
    }

}

/// Binomial test results
public struct SSBinomialTestResult<T, FPT: SSFloatingPoint>: CustomStringConvertible, Codable where T: Comparable, T: Hashable, T: Codable, FPT: Codable {
    /// number of trials
    public var nTrials: Int?
    /// number of successes
    public var nSuccess: Int?
    /// number of failures
    public var nFailure: Int?
    /// one sided p value (exact)
    public var pValueExact: FPT?
    /// probability for success
    public var probSuccess: FPT?
    /// probability for failure
    public var probFailure: FPT?
    /// test probability
    public var probTest: FPT?
    /// success id
    public var successCode: T?
    /// 1 - alpha confidence interval (Jeffreys)
    public var confIntJeffreys: SSConfIntv<FPT>?
    /// 1 - alpha confidence interval (Clopper/Pearson)
    public var confIntClopperPearson: SSConfIntv<FPT>?
    /// Returns a description
    public var description: String {
        get {
            var descr = String()
            if let nt = self.nTrials, let ns = self.nSuccess, let nf = self.nFailure, let pe = self.pValueExact, let ps = self.probSuccess, let pf = self.probFailure, let pt = self.probTest, let sc = self.successCode, let jeff = self.confIntJeffreys, let clopper = self.confIntClopperPearson {
                descr.append("BINOMIAL TEST\n")
                descr.append("*************\n")
                descr.append("p value exaxt: \(pe)\n")
                descr.append("count of trials: \(nt)\n")
                descr.append("count of successes: \(ns)\n")
                descr.append("count of failures: \(nf)\n")
                descr.append("prob. for success: \(ps)\n")
                descr.append("prob. for failure: \(pf)\n")
                descr.append("test prob.: \(pt)\n")
                descr.append("succes coded as: \(sc)\n")
                descr.append("(1-alpha) CI (Jeffreys): \(jeff)\n")
                descr.append("(1-alpha) CI (Clopper-Pearson): \(clopper)\n")
            }
            return descr
        }
    }
}

/// Results of the KS-2-Sample test
public struct SSKSTwoSampleTestResult<FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable {
    /// max pos diff
    var dMaxPos: FPT?
    /// max neg diff
    var dMaxNeg: FPT?
    /// max abs diff
    var dMaxAbs: FPT?
    /// z value
    var zStatistic: FPT?
    /// p valie
    var p2Value: FPT?
    /// size of sample 1
    var sampleSize1: Int?
    /// size of sample 2
    var sampleSize2: Int?
    /// Returns a description
    public var description: String {
        get {
            var descr = String()
            if let dmp = self.dMaxPos, let dmn = self.dMaxNeg, let dma = self.dMaxAbs, let z = self.zStatistic, let p2 = self.p2Value, let n1 = self.sampleSize1, let n2 = self.sampleSize2 {
                descr.append("KOLMOGOROV-SMIRNOV TWO SAMPLE TEST\n")
                descr.append("**********************************\n")
                descr.append("two sided p value: \(p2)\n")
                descr.append("z: \(z)\n")
                descr.append("n1: \(n1)\n")
                descr.append("n1: \(n2)\n")
                descr.append("D(-)max: \(dmn)\n")
                descr.append("D(+)max: \(dmp)\n")
                descr.append("|D|max: \(dma)\n")
            }
            return descr
        }
    }

}

/// Holds the results of the two sample runs test
public struct SSWaldWolfowitzTwoSampleTestResult<FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable {
    /// Number of runs
    public var nRuns: Int?
    /// z value
    public var zStat: FPT?
    // critical value
    //    public var criticalValue: FPT?
    /// p value
    public var pValueExact: FPT?
    /// p value asymptotic
    public var pValueAsymp: FPT?
    /// mean
    public var mean: FPT?
    /// variance
    public var variance: FPT?
     /// number of intergroup ties
    public var nTiesIntergroup: Int?
    /// number of inner group ties
    public var nTiedCases: Int?
    /// size of sample 1
    public var sampleSize1: Int?
    /// size of sample 2
    public var sampleSize2: Int?
    /// Returns a description
    public var description: String {
        get {
            var descr = String()
            if let nr = self.nRuns, let z = self.zStat, let pe = self.pValueExact, let pa = self.pValueAsymp, let m = self.mean, let v = self.variance, let n1 = self.sampleSize1, let n2 = self.sampleSize2, let nt = self.nTiesIntergroup, let tc = self.nTiedCases {
                descr.append("WALD-WOLFOWITZ TWO SAMPLE TEST\n")
                descr.append("******************************\n")
                descr.append("p value exact: \(pe)\n")
                descr.append("p value asymp: \(pa)\n")
                descr.append("z: \(z)\n")
                descr.append("n1: \(n1)\n")
                descr.append("n1: \(n2)\n")
                descr.append("mean: \(m)\n")
                descr.append("variance: \(v)\n")
                descr.append("count of intergroup ties: \(nt)\n")
                descr.append("count of tied cases: \(tc)\n")
                descr.append("count runs: \(nr)\n")
            }
            return descr
        }
    }
    
}
/// The results of the H test
public struct SSKruskalWallisHTestResult<FPT: SSFloatingPoint & Codable>: CustomStringConvertible, Codable {
    /// Chi
    public var H_value: FPT?
    /// Chi square corrected for ties
    public var H_value_corrected: FPT?
    /// one sided p value
    public var pValue: FPT?
    /// number of Groups
    public var nGroups: Int?
    /// Degrees of Freedom
    public var df: Int?
    /// number of observations
    public var nObservations: Int?
    /// array of mean ranks per group
    public var meanRanks: Array<FPT>?
    /// array of rank sums per group
    public var sumRanks: Array<FPT>?
    /// critical value at alpha
    public var cv: FPT?
    /// Number of ties
    public var nTies: Int?
    /// alpha
    public var alpha: FPT?
    /// Returns a description
    public var description: String {
        get {
            var descr = String()
            if let chi = self.H_value, let chic = self.H_value_corrected, let p = self.pValue, let ng = self.nGroups, let sdf = self.df, let no = self.nObservations, let mr = self.meanRanks, let sr = self.sumRanks, let scv = self.cv, let a = self.alpha, let nt = self.nTies {
                descr.append("KRUSKAL-WALLIS H TEST\n")
                descr.append("***************** ***\n")
                descr.append("p value: \(p)\n")
                descr.append("critical value: \(scv)\n")
                descr.append("Chi square: \(chi)\n")
                descr.append("Chi square corrected for ties: \(chic)\n")
                descr.append("count of groups: \(ng)\n")
                descr.append("degrees of freedom: \(sdf)\n")
                descr.append("count of observations: \(no)\n")
                descr.append("count of ties: \(nt)\n")
                descr.append("mean of ranks: \(mr)\n")
                descr.append("sum of ranks: \(sr)\n")
                descr.append("alpha: \(a)\n")
            }
            return descr
        }
    }
}

/// Statistics needed to create a boxplot
public struct SSBoxWhisker<T, FPT: SSFloatingPoint>: CustomStringConvertible, Codable where T: Comparable, T: Hashable, T: Codable, FPT: Codable {
    /// Median
    public var median: FPT?
    /// Lower "hinge"
    public var q25: FPT?
    /// Upper "hinge"
    public var q75: FPT?
    /// Interquartile range
    public var iqr: FPT?
    /// Lowest "normal" value >= (q25 - 1.5 * iqr)
    public var lWhiskerExtreme: T?
    /// Largest "normal" value <= (q75 + 1.5 * iqr)
    public var uWhiskerExtreme: T?
    /// Array containing all extreme values with (value < (q25 - 1.5 * iqr) && (value >  (q75 + 1.5 * iqr))) || (value > (q25 - 3 * iqr) && (value <  (q75 + 3.0 * iqr)))
    public var extremes: Array<T>?
    /// Array containing all extreme values with (value < (q25 - 3.0 * iqr)) || (value > (q75 + 3.0 * iqr))
    public var outliers: Array<T>?
    /// Upper notch
    public var uNotch: FPT?
    /// Lower notch
    public var lNotch: FPT?
    
    /// Returns a description
    public var description: String {
        get {
            var descr = String()
            if let m = self.median, let q25 = self.q25, let q75 = self.q75, let iqr = self.iqr, let e = self.extremes, let o = self.outliers, let lw = self.lWhiskerExtreme, let uw = self.uWhiskerExtreme, let ln = self.lNotch, let un = self.uNotch {
                descr.append("extreme of lower whisker: \(lw)\n")
                descr.append("q25: \(q25)\n")
                descr.append("lower notch: \(ln)\n")
                descr.append("median: \(m)\n")
                descr.append("upper notch: \(un)\n")
                descr.append("q75: \(q75)\n")
                descr.append("extreme of upper whisker: \(uw)\n")
                descr.append("iqr: \(iqr)\n")
                descr.append("extremes: \(e)\n")
                descr.append("outliers: \(o)\n")
            }
            return descr
        }
    }
}


/// Type of confidence interval
public enum SSCIType: String, Codable {
    /// To use in cases were the unbiased standard deviation is known
    case normal = "gaussian"
    /// To use in cases were the unbiased standard deviation is unknown
    case student = "student"
}


/// Defines the format of the Cumulative Frequency Table
public enum SSCumulativeFrequencyTableFormat: Int, Codable {
    /// Each item will be shown as many as found
    case eachUniqueItem = 1
    /// Each item will be shown once
    case eachItem = 2
}

/// Defines the level of measurement. In future versions this setting will be used to determine the available statistics.
public enum SSLevelOfMeasurement: String, Codable {
    /// nominal data (allowed operators: == and !=)
    case nominal = "nominal"
    /// ordinal data (allowed operators: ==, !=, <, >)
    case ordinal = "ordinal"
    /// interval data (allowed operators: ==, !=, <, >, +, -)
    case interval = "interval"
    /// ratio data (allowed operators: ==, !=, <, >, +, -, *, /)
    case ratio = "ratio"
}


/// Defines the sorting order of the elements.
public enum SSSortUniqeItems: Int, CustomStringConvertible, Codable {
    /// Ascending order
    case ascending = 1
    /// Descending order
    case descending = 2
    /// Undefined/not determined
    case none = 0xff
    
    public var description: String {
        switch self {
        case .ascending:
            return "ascending"
        case .descending:
            return "descending"
        case .none:
            return "none"
        }
    }
}

/// Defines the sort order of the Frequency Table
public enum SSFrequencyTableSortOrder: Int, Codable, CustomStringConvertible {
    /// Sorts by frequency ascending
    case frequencyAscending
    /// Sorts by frequency descending
    case frequencyDescending
    /// Sorts by value ascending
    case valueAscending
    /// Sorts by value descending
    case valueDescending
    /// Undefined
    case none
    public var description: String {
        switch self {
        case .frequencyAscending:
            return "ascending by frequency"
        case .frequencyDescending:
            return "descending by frequency"
        case .valueAscending:
            return "ascending by value"
        case .valueDescending:
            return "descending by value"
        case .none:
            return "none"
        }
    }

    
}
/// Defines the sort order of items when exported as an array
public enum SSDataArraySortOrder: Int, Codable, CustomStringConvertible {
    /// Ascending order
    case ascending
    /// Descending order
    case descending
    /// Original order
    case raw
    /// Undefined
    case none
    public var description: String {
        switch self {
        case .ascending:
            return "ascending"
        case .descending:
            return "descending"
        case .raw:
            return "raw"
        case .none:
            return "none"
        }
    }

}

/// Defines the type if the Levene test.
public enum SSLeveneTestType: String, Codable {
    /// Levene test using the median (Brown-Forsythe)
    case median
    /// Levene test using the mean
    case mean
    /// Levene test using the trimmed mean
    case trimmedMean
}


/// Defines the type of variance test
public enum SSVarTestType: CustomStringConvertible, Codable {
    /// Bartlett test
    case bartlett
    /// Variant of the Levene-Test
    case levene(SSLeveneTestType)
    
    public var description: String  {
        switch self {
        case .levene(.median):
            return "Levene/Brown-Forsythe (median)"
        case .levene(.mean):
            return "Levene (mean)"
        case .levene(.trimmedMean):
            return "Levene (trimmedMean)"
        case .bartlett:
            return "Bartlett-Test"
        }
    }
    
    private enum CodingKeys: CodingKey {
        case bartlett
        case levene
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .bartlett:
            try container.encode("Bartlett", forKey: .bartlett)
        case .levene(let value):
            try container.encode(value, forKey: .levene)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let _ = try container.decodeIfPresent(String.self, forKey: .bartlett) {
            self = .bartlett
        }
        else {
            let value = try container.decode(SSLeveneTestType.self, forKey: .levene)
            self = .levene(value)
        }
    }
}

 
/// Defines the cutting point used by the Runs test
public enum SSRunsTestCuttingPoint: String, Codable {
    /// use the median
    case median = "median"
    /// use mean
    case mean = "mean"
    /// use mode
    case mode = "mode"
    /// use user defined cutting point
    case userDefined = "undefined"
}

/// Defines the sort order of the Contingency Table
public enum SSContingencyTableSortOrder: Int, Codable, CustomStringConvertible {
    case ascending, descending, none
    public var description: String {
        switch self {
        case .ascending:
            return "ascending"
        case .descending:
            return "descending"
        case .none:
            return "none"
        }
    }
}

/// The 1D Chisquare-Hypothesis type
public enum SS1DChiSquareHypothesisType: Int, Codable, CustomStringConvertible {
    case uniform, irregular
    public var description: String {
        switch self {
        case .uniform:
            return "uniform"
        case .irregular:
            return "irregular"
        }
    }

}

/// Defines the type of the moment to compute
public enum SSMomentType: Int, Codable, CustomStringConvertible {
    /// Central moment
    case central
    /// Moment about the origin
    case origin
    /// Standardized moment
    case standardized
    public var description: String {
        switch self {
        case .central:
            return "central"
        case .origin:
            return "about the origin"
        case .standardized:
            return "standardized"
        }
    }
}

/// Defines the type of variance to compute
public enum SSVarianceType: Int, Codable, CustomStringConvertible {
    case biased = 0
    case unbiased = 1
    public var description: String {
        switch self {
        case .biased:
            return "biased"
        case .unbiased:
            return "unbiased"
        }
    }

}

/// Defines the type of sd to compute
public enum SSStandardDeviationType: Int, Codable, CustomStringConvertible  {
    case biased = 0
    case unbiased = 1
    public var description: String {
        switch self {
        case .biased:
            return "biased"
        case .unbiased:
            return "unbiased"
        }
    }
}

/// Defines type of kurtosis
public enum SSKurtosisType: String, Codable {
    /// kurtosisExecs < 0
    case platykurtic
    /// kurtosisExecs == 0
    case mesokurtic  // kurtosisExces == 0
    /// kurtosisExecs > 0
    case leptokurtic  // kurtosisExcess > 0
}

/// Skewness type
public enum SSSkewness: Int, Codable, CustomStringConvertible {
    /// skewness < 0
    case leftSkewed
    /// skewness > 0
    case rightSkewed
    /// skewness == 0
    case symmetric
    public var description: String {
        switch self {
        case .leftSkewed:
            return "left skewed"
        case .rightSkewed:
            return "right skewed"
        case .symmetric:
            return "symmetric"
        }
    }

}

/// Type of semi variance
public enum SSSemiVariance: Int, Codable, CustomStringConvertible {
    /// lower semi-variance
    case lower
    /// upper semi-variance
    case upper
    public var description: String {
        switch self {
        case .lower:
            return "lower"
        case .upper:
            return "upper"
        }
    }

}

/// Type of outlier test
public enum SSOutlierTest: Int, Codable, CustomStringConvertible {
    /// use Grubbs test
    case grubbs
    /// use ESD test
    case esd
    public var description: String {
        switch self {
        case .grubbs:
            return "Grubbs Test"
        case .esd:
            return "Rosner"
        }
    }

}



/// Type of the Rosner test for outliers (ESD test)
public enum SSESDTestType: Int, Codable, CustomStringConvertible {
    /// consider lower tail only
    case lowerTail
    /// consider upper tail only
    case upperTail
    /// consider both tails
    case bothTails
    public var description: String {
        switch self {
        case .lowerTail:
            return "lower tail"
        case .upperTail:
            return "upper tail"
        case .bothTails:
            return "both tails"
        }
    }
}




/// Enumarates the target distribution to use for GoF tests
public enum SSGoFTarget: Int, Codable, CustomStringConvertible {
    /// Normal distribution. Estimated parameters: mean and variance
    case gaussian
    /// Student's t distribution. Estimated parameter: degrees of freedom
    case studentT
    /// Laplace distribution. Estimated parameters: mean and beta (scale parameter)
    case laplace
    /// Exponential distribution. Estimated parameter: lambda
    case exponential
    /// Laplace distribution. Estimated parameters: upper and lower bound
    case uniform
    case none
    public var description: String {
        switch self {
        case .gaussian:
            return "Gaussian"
        case .studentT:
            return "Student"
        case .laplace:
            return "Laplace"
        case .exponential:
            return "Exponential"
        case .uniform:
            return "Uniform"
        case .none:
            return "none"
        }
    }
}


public enum SSAlternativeHypotheses: Int, Codable, CustomStringConvertible {
    case less, greater, twoSided
    public var description: String {
        switch self {
        case .less:
            return "less"
        case .greater:
            return "greater"
        case .twoSided:
            return "two sided"
        }
    }
}

public enum SSCDFTail: Int, Codable, CustomStringConvertible {
    case lower, upper
    public var description: String {
        switch self {
        case .lower:
            return "lower tail"
        case .upper:
            return "upper tail"
        }
    }

}

public enum SSPostHocTestType: Int, Codable, CustomStringConvertible {
    case tukeyKramer, scheffe
    public var description: String {
        switch self {
        case .tukeyKramer:
            return "Tukey/Kramer"
        case .scheffe:
            return "Scheffé"
        }
    }

}

public enum SSIncompleteGammaFunction: Int, Codable, CustomStringConvertible {
    case lower, upper
    public var description: String {
        switch self {
        case .lower:
            return "lower incomplete gamma function"
        case .upper:
            return "upper incomplete gamma function"
        }
    }
}

/// A tuple containing the results of one out of multiple comparisons.
public typealias SSPostHocTestResult<FPT: SSFloatingPoint & Codable> = (row: String, meanDiff: FPT, testStat: FPT, pValue: FPT, testType: SSPostHocTestType)















//
//  SSSwiftyStats-EnumsStructs.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 01.07.17.
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


/// Type of confidence interval
public enum SSCIType {
    /// To use in cases were the unbiased standard deviation is known
    case normal
    /// To use in cases were the unbiased standard deviation is unknown
    case student
}

/// Confidence interval struct
public struct SSConfIntv {
    /// Upper bound of the CI
    var upperBound: Double?
    /// Lower bound of the CI
    var lowerBound: Double?
    /// Range of the CI
    var intervalWidth: Double?
    
//    var type: SSCIType
}
/// Defines the format of the Cumulative Frequency Table
public enum SSCumulativeFrequencyTableFormat {
    /// Each item will be shown as many as found
    case eachUniqueItem
    /// Each item will be shown once
    case eachItem
}

/// Defines the level of measurement. In future versions this setting will be used to determine the available statistics.
public enum SSLevelOfMeasurement: Int {
    /// nominal data (allowed operators: == and !=)
    case nominal
    /// ordinal data (allowed operators: ==, !=, <, >)
    case ordinal
    /// interval data (allowed operators: ==, !=, <, >, +, -)
    case interval
    /// ratio data (allowed operators: ==, !=, <, >, +, -, *, /)
    case ratio
}


/// Defines the sorting order of the elements.
public enum SSSortUniqeItems {
    /// Ascending order
    case ascending
    /// Descending order
    case descending
    /// Undefined/not determined
    case none
}

/// Defines the sort order of the Frequency Table
public enum SSFrequencyTableSortOrder {
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
}
/// Defines the sort order of items when exported as an array
public enum SSDataArraySortOrder {
    /// Ascending order
    case ascending
    /// Descending order
    case descending
    /// Original order
    case original
    /// Undefined
    case none
}
/// Defines the
public enum SSLeveneTestType {
    /// Use the median (Brown-Forsythe-Test)
    case median
    /// Use the arithmetic mean
    case mean
    /// Use the trimmed mean
    case trimmedMean
}

/// Defines the cutting point used by the Runs test
public enum SSRunsTestCuttingPoint {
    case median, mean, mode, userDefined
}

/// Defines the sort order of the Contingency Table
public enum SSContingencyTableSortOrder {
    case ascending, descending, none
}

/// The 1D Chisquare-Hypothesis type
public enum SS1DChiSquareHypothesisType {
    case uniform, irregular
}


/// Quartile struct
public struct SSQuartile {
    /// 25% Quartile
    var q25: Double
    /// 50% Quartile
    var q50: Double
    /// 75% Quartile
    var q75: Double
    
    init(Q25: Double, Q50: Double, Q75: Double) {
        q25 = Q25
        q50 = Q50
        q75 = Q75
    }
    init() {
        q25 = 0
        q50 = 0
        q75 = 0
    }
}

/// Struct containing descriptive stats
public struct SSDescriptiveStats {
    /// arithmetic mean
    var mean: Double
    /// Variance
    var variance: Double
    /// Sample size
    var sampleSize: Double
    /// Standard deviation
    var standardDeviation: Double

    init(mean: Double, variance: Double, sampleSize: Double, standardDev: Double) {
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
}

/// Parameters of a continuous probability distribution
public struct SSContProbDistParams {
    /// Kurtosis
    var kurtosis: Double
    /// Mean
    var mean: Double
    /// Skewness
    var skewness: Double
    /// Variance
    var variance: Double
    
    init(mean: Double, variance: Double, kurtosis: Double, skewness: Double) {
        self.mean = mean
        self.variance = variance
        self.skewness = skewness
        self.kurtosis = kurtosis
    }
    init() {
        self.mean = Double.nan
        self.variance = Double.nan
        self.skewness = Double.nan
        self.kurtosis = Double.nan
    }
}

/// Defines the type of the moment to compute
public enum SSMomentType {
    /// Central moment
    case central
    /// Moment about the origin
    case origin
    /// Standardized moment
    case standardized
}

/// Defines the type of variance to compute
public enum SSVarianceType: Int {
    case biased = 0
    case unbiased = 1
}

/// Defines the type of sd to compute
public enum SSStandardDeviationType: Int {
    case biased = 0
    case unbiased = 1
}

/// Defines type of kurtosis
public enum SSKurtosisType {
    /// kurtosisExecs < 0
    case platykurtic
    /// kurtosisExecs == 0
    case mesokurtic  // kurtosisExces == 0
    /// kurtosisExecs > 0
    case leptokurtic  // kurtosisExcess > 0
}

/// Skewness type
public enum SSSkewness {
    /// skewness < 0
    case leftSkewed
    /// skewness > 0
    case rightSkewed
    /// skewness == 0
    case symmetric
}

/// Type of semi variance
public enum SSSemiVariance {
    /// lower semi-variance
    case lower
    /// upper semi-variance
    case upper
}

/// Type of outlier test
public enum SSOutlierTest {
    /// use Grubbs test
    case grubbs
    /// use ESD test
    case esd
}


public struct SSGrubbsTestResult {
    /// ciritcal value
    public var criticalValue: Double?
    /// largest value
    public var largest: Double?
    /// smalles value
    public var smallest: Double?
    /// sample size
    public var sampleSize: Int?
    /// max difference
    public var maxDiff: Double?
    /// arithmetic mean
    public var mean: Double?
    /// Grubbs G
    public var G: Double?
    /// sd
    public var stdDev: Double?
    /// true iff G > ciriticalValue
    public var hasOutliers: Bool?
}

/// Type of the Rosner test for outliers (ESD test)
public enum SSESDTestType {
    /// consider lower tail only
    case lowerTail
    /// consider upper tail only
    case upperTail
    /// consider both tails
    case bothTails
}


public struct SSESDTestResult {
    /// sd
    var stdDeviations: Array<Double>?
    /// number of items removed during procedure
    var itemsRemoved: Array<Double>?
    /// test statistic
    var testStatistics: Array<Double>?
    /// array of lamddas
    var lambdas: Array<Double>?
    /// count of outliers found
    var countOfOutliers: Int?
    /// array containing outliers found
    var outliers: Array<Double>?
    /// alpha
    var alpha: Double?
    /// max number of outliers to search for
    var maxOutliers: Int?
    /// test type
    var testType: SSESDTestType?
    /// array of the means
    var means: Array<Double>?
}


// GoF test structures/enums

/// Enumarates the target distribution to use for GoF tests
public enum SSGoFTarget {
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
}

/// Results of the KS one sample test. The fields actually used depend on the target distribution.
public struct SSKSTestResult {
    /// emprical mean
    var estimatedMean: Double?
    /// empirical sd
    var estimatedSd: Double?
    /// empirical variance
    var estimatedVar: Double?
    /// empirical lower bound
    var estimatedLowerBound: Double?
    /// empirical upper bound
    var estimatedUpperBound: Double?
    /// empirical degrees of freedom
    var estimatedDegreesOfFreedom: Double?
    /// empirical shape parameter
    var estimatedShapeParam: Double?
    /// empirical scale parameter
    var estimatedScaleParam: Double?
    /// target distribution
    var targetDistribution: SSGoFTarget?
    /// p value
    var pValue: Double?
    /// max absolute difference
    var maxAbsDifference: Double?
    /// max absolute positive difference
    var maxPosDifference: Double?
    /// max absolute negative difference
    var maxNegDifference: Double?
    /// z value
    var zStatistics: Double?
    /// sample size
    var sampleSize: Int?
    /// a string containing additional info (for certain distributions)
    var infoString: String?
}


/// Results of the Anderson Darling test
public struct SSADTestResult {
    /// p value (= (1 - alpha)-quantile of testStatistic
    var pValue: Double?
    /// Anderson Darling statistics
    var AD: Double?
    /// AD*
    var ADStar: Double?
    /// sample size
    var sampleSize: Int?
    /// standard deviation
    var stdDev: Double?
    /// variance
    var variance: Double?
    /// mean
    var mean: Double?
    /// true iff pValue >= alpha
    var isNormal: Bool?
}

/// Result of tests for equality of variances (Bartlett, Levene, Brown-Forsythe)
public struct SSVarianceEqualityTestResult {
    /// degrees of freedom
    var df: Double?
    /// critical value for alpha = 0.1
    var cv90Pct: Double?
    /// critical value for alpha = 0.05
    var cv95Pct: Double?
    /// critical value for alpha = 0.01
    var cv99Pct: Double?
    /// critical value for alpha as set by the call
    var cvAlpha: Double?
    /// p value (= (1 - alpha)-quantile of testStatistic
    var pValue: Double?
    /// test statistic value
    var testStatistic: Double?
    /// set to true iff pValue >= alpha
    var equality: Bool?
}
/// Results of the two sample t-Test
public struct SSTwoSampleTTestResult {
    /// one sided p value for equal variances
    var p1EQVAR: Double?
    /// one sided p value for unequal variances
    var p1UEQVAR: Double?
    /// two sided p value for equal variances
    var p2EQVAR: Double?
    /// two sided p value for unequal variances
    var p2UEQVAR: Double?
    /// mean of sample 1
    var mean1: Double?
    /// mean of sample 2
    var mean2: Double?
    /// n of sample 1
    var sampleSize1: Double?
    /// n of sample 2
    var sampleSize2: Double?
    /// sd of sample 1
    var stdDev1: Double?
    /// sd of sample 1
    var stdDev2: Double?
    /// pooled sd
    var pooledStdDev: Double?
    /// pooled variance
    var pooledVariance: Double?
    /// mean1 - mean2
    var differenceInMeans: Double?
    /// t Value assuming equal variances
    var tEQVAR: Double?
    /// t Value assuming unequal variances
    var tUEQVAR: Double?
    /// p Value of the Levene test
    var LeveneP: Double?
    /// degrees of freedom assuming equal variances
    var dfEQVAR: Double?
    /// degrees of freedom assuming unequal variances (Welch)
    var dfUEQVAR: Double?
    /// s(1) == s(2)
    var variancesAreEqual: Bool? = false
    /// mean1 >= mean2
    var mean1GTEmean2: Bool? = false
    /// mean1 <= mean2
    var mean1LTEmean2: Bool? = false
    /// mean1 == mean2
    var mean1EQmean2: Bool? = false
    /// mean1 != mean2
    var mean1UEQmean2: Bool? = false
    /// critical value assuming equal variances
    var CVEQVAR: Double?
    /// critical value assuming unequal variances
    var CVUEQVAR: Double?
    /// effect size assuming equal variances
    var rEQVAR: Double?
    /// effect size assuming unequal variances
    var rUEQVAR: Double?
    /// t value according to Welch
    var tWelch: Double?
    /// degrees of freedom according to Welch
    var dfWelch: Double?
    /// two sided p value according to Welch
    var p2Welch: Double?
    /// one sided p value according to Welch
    var p1Welch: Double?
}

/// Struct holding the results of the one sample t test
public struct SSOneSampleTTestResult {
    /// one sided p value
    var p1Value: Double?
    /// one sided p value
    var p2Value: Double?
    /// t Value
    var tStat: Double?
    /// critical value for alpha = 0.1
    var cv90Pct: Double?
    /// critical value for alpha = 0.05
    var cv95Pct: Double?
    /// critical value for alpha = 0.01
    var cv99Pct: Double?
    /// critical value for alpha as set by the call
    var cvAlpha: Double?
    /// mean
    var mean: Double?
    /// reference mean
    var mean0: Double?
    /// mean - mean0
    var difference: Double?
    /// n of sample
    var sampleSize: Double?
    /// sd
    var stdDev: Double?
    /// standard error
    var stdErr: Double?
    /// degrees of freedom
    var df: Double?
    /// mean1 >= mean0
    var meanGTEtestValue: Bool? = false
    /// mean <= mean0
    var meanLTEtestValue: Bool? = false
    /// mean == mean0
    var meanEQtestValue: Bool? = false
}

/// Encapsulates the results of a matched pairs t test
public struct SSMatchedPairsTTestResult {
    /// Cov
    var covariance: Double?
    /// standard error of the difference
    var stdEDiff: Double?
    /// correlatiopn
    var correlation: Double?
    /// p value of correlation
    var pValueCorr: Double?
    /// effect size
    var effectSizeR: Double?
    /// upper bound of the 95%-confidence interval
    var ci95upper: Double?
    /// lower bound of the 95%-confidence interval
    var ci95lower: Double?
    /// sd of the differences
    var stdDevDiff: Double?
    /// sample size
    var sampleSize: Double?
    /// p value for two sided test
    var p2Value: Double?
    /// degrees of freedom
    var df: Double?
    /// t statistics
    var tStat: Double?
}

/// Holds the results of the chi^2 variance test
public struct SSChiSquareVarianceTestResult {
    /// degrees of freedom
    var df: Double?
    /// variance ratio
    var ratio: Double?
    /// chi^2
    var testStatisticValue: Double?
    /// one sided p value
    var p1Value: Double?
    /// two sided p value
    var p2Value: Double?
    /// sample size
    var sampleSize: Double?
    /// true iff sample variance == s0
    var sigmaUEQs0: Bool?
    /// true iff sample variance <= s0
    var sigmaLTEs0: Bool?
    /// true iff sample variance >= s0
    var sigmaGTEs0: Bool?
    /// sample standard deviation
    var sd: Double?
}

/// Holds the results of the multiple means tes
public struct SSOneWayANOVATestResult {
    /// two sided p value
    var p2Value: Double?
    /// F ratio
    var FStatistic: Double?
    /// p value of the Bartlett test
    var pBartlett: Double?
    /// Alpha
    var alpha: Double?
    var meansEQUAL: Bool?
    /// critical value at alpha
    var cv: Double?
    /// p value of the Levene test
    var pLevene: Double?
}

/// Holds the results of the F test for equal variances
public struct SSFTestResult {
    /// size of sample 1
    var sampleSize1: Double?
    /// size of sample 2
    var sampleSize2: Double?
    /// denominator degrees of freedom
    var dfDenominator: Double?
    /// numerator degrees of freedom
    var dfNumerator: Double?
    /// variance of sample 1
    var variance1: Double?
    /// variance of sample 2
    var variance2: Double?
    /// F ratio
    var FRatio: Double?
    /// one sided p value
    var p1Value: Double?
    /// two sided p value
    var p2Value: Double?
    /// indicates if variances are equal
    var FRatioEQ1: Bool?
    /// indicates if var1 <= var2
    var FRatioLTE1: Bool?
    /// indicates if var1 >= var2
    var FRatioGTE1: Bool?
    /// confidence intervall for var1 == var2
    var ciRatioEQ1: SSConfIntv?
    /// confidence intervall for var1 <= var2
    var ciRatioLTE1: SSConfIntv?
    /// confidence intervall for var1 >= var2
    var ciRatioGTE1: SSConfIntv?
}


public struct SSBoxLjungResult {
    var errorDescription: String?
    var coefficients: Array<Double>
    var seBartlett: Array<Double>
    var seWN: Array<Double>
    var testStatistic: Array<Double>
    var pValues: Array<Double>
}


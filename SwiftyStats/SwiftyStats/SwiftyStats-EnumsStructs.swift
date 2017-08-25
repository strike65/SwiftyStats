//
//  SSSwiftyStats-EnumsStructs.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 01.07.17.
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
    /// Lower bound of the CI
    public var lowerBound: Double?
    /// Upper bound of the CI
    public var upperBound: Double?
    /// Range of the CI
    public var intervalWidth: Double?
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
    /// use the median
    case median
    /// use mean
    case mean
    /// use mode
    case mode
    /// use user defined cutting point
    case userDefined
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
    public var q25: Double
    /// 50% Quartile
    public var q50: Double
    /// 75% Quartile
    public var q75: Double
    
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
    public var mean: Double
    /// Variance
    public var variance: Double
    /// Sample size
    public var sampleSize: Double
    /// Standard deviation
    public var standardDeviation: Double

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
    public var kurtosis: Double
    /// Mean
    public var mean: Double
    /// Skewness
    public var skewness: Double
    /// Variance
    public var variance: Double
    
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
    public var stdDeviations: Array<Double>?
    /// number of items removed during procedure
    public var itemsRemoved: Array<Double>?
    /// test statistic
    public var testStatistics: Array<Double>?
    /// array of lamddas
    public var lambdas: Array<Double>?
    /// count of outliers found
    public var countOfOutliers: Int?
    /// array containing outliers found
    public var outliers: Array<Double>?
    /// alpha
    public var alpha: Double?
    /// max number of outliers to search for
    public var maxOutliers: Int?
    /// test type
    public var testType: SSESDTestType?
    /// array of the means
    public var means: Array<Double>?
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
    public var estimatedMean: Double?
    /// empirical sd
    public var estimatedSd: Double?
    /// empirical variance
    public var estimatedVar: Double?
    /// empirical lower bound
    public var estimatedLowerBound: Double?
    /// empirical upper bound
    public var estimatedUpperBound: Double?
    /// empirical degrees of freedom
    public var estimatedDegreesOfFreedom: Double?
    /// empirical shape parameter
    public var estimatedShapeParam: Double?
    /// empirical scale parameter
    public var estimatedScaleParam: Double?
    /// target distribution
    public var targetDistribution: SSGoFTarget?
    /// p value
    public var pValue: Double?
    /// max absolute difference
    public var maxAbsDifference: Double?
    /// max absolute positive difference
    public var maxPosDifference: Double?
    /// max absolute negative difference
    public var maxNegDifference: Double?
    /// z value
    public var zStatistics: Double?
    /// sample size
    public var sampleSize: Int?
    /// a string containing additional info (for certain distributions)
    public var infoString: String?
}


/// Results of the Anderson Darling test
public struct SSADTestResult {
    /// p value (= (1 - alpha)-quantile of testStatistic
    public var pValue: Double?
    /// Anderson Darling statistics
    public var AD: Double?
    /// AD*
    public var ADStar: Double?
    /// sample size
    public var sampleSize: Int?
    /// standard deviation
    public var stdDev: Double?
    /// variance
    public var variance: Double?
    /// mean
    public var mean: Double?
    /// true iff pValue >= alpha
    public var isNormal: Bool?
}

/// Result of tests for equality of variances (Bartlett, Levene, Brown-Forsythe)
public struct SSVarianceEqualityTestResult {
    /// degrees of freedom
    public var df: Double?
    /// critical value for alpha = 0.1
    public var cv90Pct: Double?
    /// critical value for alpha = 0.05
    public var cv95Pct: Double?
    /// critical value for alpha = 0.01
    public var cv99Pct: Double?
    /// critical value for alpha as set by the call
    public var cvAlpha: Double?
    /// p value (= (1 - alpha)-quantile of testStatistic
    public var pValue: Double?
    /// test statistic value
    public var testStatistic: Double?
    /// set to true iff pValue >= alpha
    public var equality: Bool?
}
/// Results of the two sample t-Test
public struct SSTwoSampleTTestResult {
    /// one sided p value for equal variances
    public var p1EQVAR: Double?
    /// one sided p value for unequal variances
    public var p1UEQVAR: Double?
    /// two sided p value for equal variances
    public var p2EQVAR: Double?
    /// two sided p value for unequal variances
    public var p2UEQVAR: Double?
    /// mean of sample 1
    public var mean1: Double?
    /// mean of sample 2
    public var mean2: Double?
    /// n of sample 1
    public var sampleSize1: Double?
    /// n of sample 2
    public var sampleSize2: Double?
    /// sd of sample 1
    public var stdDev1: Double?
    /// sd of sample 1
    public var stdDev2: Double?
    /// pooled sd
    public var pooledStdDev: Double?
    /// pooled variance
    public var pooledVariance: Double?
    /// mean1 - mean2
    public var differenceInMeans: Double?
    /// t Value assuming equal variances
    public var tEQVAR: Double?
    /// t Value assuming unequal variances
    public var tUEQVAR: Double?
    /// p Value of the Levene test
    public var LeveneP: Double?
    /// degrees of freedom assuming equal variances
    public var dfEQVAR: Double?
    /// degrees of freedom assuming unequal variances (Welch)
    public var dfUEQVAR: Double?
    /// s(1) == s(2)
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
    public var CVEQVAR: Double?
    /// critical value assuming unequal variances
    public var CVUEQVAR: Double?
    /// effect size assuming equal variances
    public var rEQVAR: Double?
    /// effect size assuming unequal variances
    public var rUEQVAR: Double?
    /// t value according to Welch
    public var tWelch: Double?
    /// degrees of freedom according to Welch
    public var dfWelch: Double?
    /// two sided p value according to Welch
    public var p2Welch: Double?
    /// one sided p value according to Welch
    public var p1Welch: Double?
}

/// Struct holding the results of the one sample t test
public struct SSOneSampleTTestResult {
    /// one sided p value
    public var p1Value: Double?
    /// one sided p value
    public var p2Value: Double?
    /// t Value
    public var tStat: Double?
    /// critical value for alpha = 0.1
    public var cv90Pct: Double?
    /// critical value for alpha = 0.05
    public var cv95Pct: Double?
    /// critical value for alpha = 0.01
    public var cv99Pct: Double?
    /// critical value for alpha as set by the call
    public var cvAlpha: Double?
    /// mean
    public var mean: Double?
    /// reference mean
    public var mean0: Double?
    /// mean - mean0
    public var difference: Double?
    /// n of sample
    public var sampleSize: Double?
    /// sd
    public var stdDev: Double?
    /// standard error
    public var stdErr: Double?
    /// degrees of freedom
    public var df: Double?
    /// mean1 >= mean0
    public var meanGTEtestValue: Bool? = false
    /// mean <= mean0
    public var meanLTEtestValue: Bool? = false
    /// mean == mean0
    public var meanEQtestValue: Bool? = false
}

/// Encapsulates the results of a matched pairs t test
public struct SSMatchedPairsTTestResult {
    /// Cov
    public var covariance: Double?
    /// standard error of the difference
    public var stdEDiff: Double?
    /// correlatiopn
    public var correlation: Double?
    /// p value of correlation
    public var pValueCorr: Double?
    /// effect size
    public var effectSizeR: Double?
    /// upper bound of the 95%-confidence interval
    public var ci95upper: Double?
    /// lower bound of the 95%-confidence interval
    public var ci95lower: Double?
    /// sd of the differences
    public var stdDevDiff: Double?
    /// sample size
    public var sampleSize: Double?
    /// p value for two sided test
    public var p2Value: Double?
    /// degrees of freedom
    public var df: Double?
    /// t statistics
    public var tStat: Double?
}

/// Holds the results of the chi^2 variance test
public struct SSChiSquareVarianceTestResult {
    /// degrees of freedom
    public var df: Double?
    /// variance ratio
    public var ratio: Double?
    /// chi^2
    public var testStatisticValue: Double?
    /// one sided p value
    public var p1Value: Double?
    /// two sided p value
    public var p2Value: Double?
    /// sample size
    public var sampleSize: Double?
    /// true iff sample variance == s0
    public var sigmaUEQs0: Bool?
    /// true iff sample variance <= s0
    public var sigmaLTEs0: Bool?
    /// true iff sample variance >= s0
    public var sigmaGTEs0: Bool?
    /// sample standard deviation
    public var sd: Double?
}

/// Holds the results of the multiple means tes
public struct SSOneWayANOVATestResult {
    /// two sided p value
    public var p2Value: Double?
    /// F ratio
    public var FStatistic: Double?
    /// p value of the Bartlett test
    public var pBartlett: Double?
    /// Alpha
    public var alpha: Double?
    public var meansEQUAL: Bool?
    /// critical value at alpha
    public var cv: Double?
    /// p value of the Levene test
    public var pLevene: Double?
}

/// Holds the results of the F test for equal variances
public struct SSFTestResult {
    /// size of sample 1
    public var sampleSize1: Double?
    /// size of sample 2
    public var sampleSize2: Double?
    /// denominator degrees of freedom
    public var dfDenominator: Double?
    /// numerator degrees of freedom
    public var dfNumerator: Double?
    /// variance of sample 1
    public var variance1: Double?
    /// variance of sample 2
    public var variance2: Double?
    /// F ratio
    public var FRatio: Double?
    /// one sided p value
    public var p1Value: Double?
    /// two sided p value
    public var p2Value: Double?
    /// indicates if variances are equal
    public var FRatioEQ1: Bool?
    /// indicates if var1 <= var2
    public var FRatioLTE1: Bool?
    /// indicates if var1 >= var2
    public var FRatioGTE1: Bool?
    /// confidence intervall for var1 == var2
    public var ciRatioEQ1: SSConfIntv?
    /// confidence intervall for var1 <= var2
    public var ciRatioLTE1: SSConfIntv?
    /// confidence intervall for var1 >= var2
    public var ciRatioGTE1: SSConfIntv?
}

/// Holds the results of Box Ljung Autocorrelation
public struct SSBoxLjungResult {
    /// coefficients as Dictionary<lag: String, coeff: Double>
    public var coefficients: Array<Double>?
    /// Bartlett standard error as Dictionary<lag: String, se: Double>
    public var seBartlett: Array<Double>?
    /// standard error for white noise as Dictionary<lag: String, se: Double>
    public var seWN: Array<Double>?
    /// test statistics as Dictionary<lag: String, stat: Double>
    public var testStatistic: Array<Double>?
    /// pavalues as  Dictionary<lag: String, pValue: Double>
    public var pValues: Array<Double>?
}

/// Holds the results of the runs test
public struct SSRunsTestResult {
    /// Number of items >= cutting point
    public var nGTEcp: Double?
    /// Number of items < cutting point
    public var nLTcp: Double?
    /// Number of runs
    public var nRuns: Double?
    /// z value
    public var ZStatistic: Double?
    /// critical value
    public var criticalValue: Double?
    /// p value
    public var pValueExact: Double?
    /// p value asymptotic
    public var pValueAsymp: Double?
    // cutting point used
    public var cp: Double?
    /// Array of differences
    public var diffs: Array<Double>?
    /// Randomness?
    public var randomness: Bool?
}

/// Holds the results of the Mann-Whitney U test
public struct SSMannWhitneyUTestResult {
    /// sum of ranks in set 1
    public var sumRanks1: Double?
    /// sum of ranks in set 2
    public var sumRanks2: Double?
    /// mean of ranks in set 1
    public var meanRank1: Double?
    /// mean of ranks in set 2
    public var meanRank2: Double?
    /// sum of tied ranks
    public var sumTiedRanks: Double?
    /// number of ties
    public var nTies: Int?
    /// U
    public var UMannWhitney: Double?
    /// Wilcoxon W
    public var WilcoxonW: Double?
    /// Z
    public var ZStatistic: Double?
    /// two sided approximated p value
    public var p2Approx: Double?
    /// two sided exact p value
    public var p2Exact: Double?
    /// one sided approximated p value
    public var p1Approx: Double?
    /// one sided exact p value
    public var p1Exact: Double?
    /// effect size
    public var effectSize: Double?
}


/// Holds the results of the Wilcoxon test for matched pairs
public struct SSWilcoxonMatchedPairsTestResult {
    /// two sided p value
    public var p2Value: Double?
    /// sample size
    public var sampleSize: Double?
    /// number of ranks > 0
    public var nPosRanks: Int?
    /// number of ranks < 0
    public var nNegRanks: Int?
    /// number of ties
    public var nTies: Int?
    /// number of zero valued differences
    public var nZeroDiff: Int?
    /// sum of negative ranks
    public var sumNegRanks: Double?
    /// sum of positive ranks
    public var sumPosRanks: Double?
    /// mean of negative ranks
    public var meanPosRanks: Double?
    /// mean of positive ranks
    public var meanNegRanks: Double?
    /// z statistic
    public var ZStatistic: Double?
    /// Cohen's d
    public var dCohen: Double?

}
/// Sign test results
public struct SSSignTestRestult {
    /// exact p value
    public var pValueExact: Double?
    /// asymptotic p value
    public var pValueApprox: Double?
    /// number of differences > 0
    public var nPosDiff: Int?
    /// number of differences < 0
    public var nNegDiff: Int?
    /// number of ties
    public var nTies: Int?
    /// sample size
    public var total: Int?
    /// z value
    public var ZStatistic: Double?
}

/// Binomial test results
public struct SSBinomialTestResult<T> where T: Comparable, T: Hashable {
    /// number of trials
    public var nTrials: Int?
    /// number of successes
    public var nSuccess: Int?
    /// number of failures
    public var nFailure: Int?
    /// one sided p value (exact)
    public var pValueExact: Double?
    /// probability for success
    public var probSuccess: Double?
    /// probability for failure
    public var probFailure: Double?
    /// test probability
    public var probTest: Double?
    /// success id
    public var successCode: T?
    /// 1 - alpha confidence interval (Jeffreys)
    public var confIntJeffreys: SSConfIntv?
    /// 1 - alpha confidence interval (Clopper/Pearson)
    public var confIntClopperPearson: SSConfIntv?
}


public enum SSAlternativeHypotheses {
    case less, greater, twoSided
}

public enum SSCDFTail {
    case lower, upper
}


/// Results of the KS-2-Sample test
public struct SSKSTwoSampleTestResult {
    /// max pos diff
    var dMaxPos: Double?
    /// max neg diff
    var dMaxNeg: Double?
    /// max abs diff
    var dMaxAbs: Double?
    /// z value
    var zStatistic: Double?
    /// p valie
    var p2Value: Double?
    /// size of sample 1
    var sampleSize1: Int?
    /// size of sample 2
    var sampleSize2: Int?

}

/// Holds the results of the two sample runs test
public struct SSWaldWolfowitzTwoSampleTestResult {
    /// Number of runs
    public var nRuns: Int?
    /// z value
    public var ZStatistic: Double?
// critical value
//    public var criticalValue: Double?
    /// p value
    public var pValueExact: Double?
    /// p value asymptotic
    public var pValueAsymp: Double?
    /// mean
    public var mean: Double?
    /// variance
    public var variance: Double?
    /// number of intergroup ties
    public var nTiesIntergroup: Int?
    /// number of inner group ties
    public var nTiedCases: Int?
    /// size of sample 1
    public var sampleSize1: Int?
    /// size of sample 2
    public var sampleSize2: Int?
}
/// The results of the H test
public struct SSKruskalWallisHTestResult {
    /// Chi
    public var Chi2: Double?
    /// Chi square corrected for ties
    public var Chi2corrected: Double?
    /// one sided p value
    public var pValue: Double?
    /// number of Groups
    public var nGroups: Int?
    /// Degrees of Freedom
    public var df: Int?
    /// number of observations
    public var nObservations: Int?
    /// array of mean ranks per group
    public var meanRanks: Array<Double>?
    /// array of rank sums per group
    public var sumRanks: Array<Double>?
    /// critical value at alpha
    public var cv: Double?
    /// alpha
    public var alpha: Double?
}


public struct SSBoxWhisker<T> where T: Comparable, T: Hashable {
    public var median: Double?
    public var q25: Double?
    public var q75: Double?
    public var iqr: Double?
    public var extremes: Array<T>?
}















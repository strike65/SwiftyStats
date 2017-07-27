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
    var upperBound: Double
    /// Lower bound of the CI
    var lowerBound: Double
    /// Range of the CI
    var intervalWidth: Double
    
    var type: SSCIType
    
    init(lower: Double, upper: Double, width: Double, type: SSCIType) {
        upperBound = upper
        lowerBound = lower
        intervalWidth = width
        self.type = type
    }
    
    init() {
        upperBound = 0
        lowerBound = 0
        intervalWidth = 0
        self.type = .normal
    }
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
    case nominal
    case ordinal
    case interval
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
    case frequencyAscending
    case frequencyDescending
    case valueAscending
    case valueDescending
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
    /// Undefined/not determined
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

/// Type of the Rosner test for outliers (ESD test)
public enum SSRosnerTestType {
    case lowerTail, upperTail, bothTails, none
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
    case platykurtic // kurtosisExecs < 0
    case mesokurtic  // kurtosisExces == 0
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

public enum SSOutlierTest {
    case grubbs
    case esd
}


public struct SSGrubbsTestResult {
    public var name: String!
    public var criticalValue: Double!
    public var largest: Double!
    public var smallest: Double!
    public var sampleSize: Int!
    public var maxDiff: Double!
    public var mean: Double!
    public var G: Double!
    public var stdDev: Double!
    public var hasOutliers: Bool!
    
    public init() {
        name = ""
        criticalValue = Double.nan
        largest = Double.nan
        smallest = Double.nan
        sampleSize = Int.max
        maxDiff = Double.nan
        mean = Double.nan
        G = Double.nan
        stdDev = Double.nan
        hasOutliers = false
    }
}

public enum SSESDTestType {
    case lowerTail
    case upperTail
    case bothTails
}


public struct SSESDTestResult {
    var name: String
    var stdDeviations: Array<Double>?
    var itemsRemoved: Array<Double>?
    var testStatistics: Array<Double>?
    var lambdas: Array<Double>?
    var countOfOutliers: Int?
    var outliers: Array<Double>?
    var alpha: Double?
    var maxOutliers: Int?
    var testType: SSESDTestType
    var means: Array<Double>?
    
    init() {
        name = ""
        stdDeviations = nil
        itemsRemoved = nil
        testStatistics = nil
        lambdas = nil
        countOfOutliers = nil
        outliers = nil
        alpha = nil
        maxOutliers = nil
        testType = .bothTails
        means = nil
    }
}


// GoF test structures/enums

/// Enumarates the target distribution to use for GoF tests
public enum SSGoFTarget {
    case gaussian
    case studentT
    case laplace
    case exponential
    case uniform
    case none
}

/// Results of the KS one sample test
public struct SSKSTestResult {
    var estimatedMean: Double?
    var estimatedSd: Double?
    var estimatedVar: Double?
    var estimatedLowerBound: Double?
    var estimatedUpperBound: Double?
    var estimatedDegreesOfFreedom: Double?
    var estimatedShapeParam: Double?
    var estimatedScaleParam: Double?
    var targetDistribution: SSGoFTarget
    var pValue: Double?
    var maxAbsDifference: Double?
    var maxPosDifference: Double?
    var maxNegDifference: Double?
    var zStatistics: Double?
    var sampleSize: Int?
    var infoString: String?
    
    public init() {
        estimatedSd = nil
        estimatedMean = nil
        estimatedDegreesOfFreedom = nil
        estimatedVar = nil
        estimatedLowerBound = nil
        estimatedUpperBound = nil
        estimatedShapeParam = nil
        estimatedScaleParam = nil
        targetDistribution = .none
        pValue = nil
        maxAbsDifference = nil
        maxPosDifference = nil
        maxNegDifference = nil
        zStatistics = nil
        sampleSize = nil
        infoString = nil
    }
}


/// Results of the Anderson Darling test
public struct SSADTestResult {
    var pValue: Double?
    var AD: Double?
    var ADStar: Double?
    var sampleSize: Int?
    var stdDev: Double?
    var variance: Double?
    var mean: Double?
    var isNormal: Bool?
}

/// Result of tests for equality of variances (Bartlett, Levene, Brown-Forsythe)
public struct SSVarianceEqualityTestResult {
    var df: Double?
    var cv90Pct: Double?
    var cv95Pct: Double?
    var cv99Pct: Double?
    var cvAlpha: Double?
    var pValue: Double?
    var testStatistic: Double?
    var equality: Bool?
}







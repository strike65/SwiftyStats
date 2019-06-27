![Language](https://img.shields.io/badge/Language-Swift_5-yellow.svg) ![Version](https://img.shields.io/badge/version-1.1.0-orange.svg) ![Unit Tests](https://img.shields.io/badge/Unit_Tests-passed-green.svg) ![macOS](https://img.shields.io/badge/macOS-built-green.svg) ![iOS](https://img.shields.io/badge/iOS-built-green.svg) ![Build Linux](https://img.shields.io/badge/Linux-under_development-red.svg) ![Documentation](https://img.shields.io/badge/Documentation-87%20%25-green.svg)

SwiftyStats
===========
(full documentation: [https://strike65.github.io/SwiftyStats/docs/](https://strike65.github.io/SwiftyStats/docs/))

SwiftyStats is a framework written entirely in Swift that makes heavy use of generic types. SwiftyStats contains frequently used statistical procedures. 
> It is a framework that is regularly developed and has been created out of passion rather than necessity.

By using version 1.1.0 some projects will be broken due to the introduction of namespaces. I have made great effort to make this update process as smooth as possible. However, this is work in progress and will particulary break some projects. *This will make a revision necessary for some projects, for which I ask for patience.*

The attached Xcode project contains four targets:
> * SwiftyStats (for macOS)
> * SwiftyStatsMobile (for iOS)
> * SwiftyStatsTests (Testsuite)
> * SwiftStatsCLTest (a command line demo)

*Each target must be built individually (i.e. no dependencies are defined)!*

In addition a Plaground is added to the Xcode project, so that you can "interactively" 
> * try out the framework and 
> * do prototyping

If you are on Linux, please use SPM.

# The Swift Type Checker problem
Due to the extensive support of generic types, the type checker runs hot and takes a long time to compile. Therefore the code doesn't look "nice" in some places, because "complex" expressions (like `z1 + z1 - w) / (z1 * w)`) had to be simplified.

# Overview

SwiftyStats is based on the class [`SSExamine`](docs/Classes/SSExamine.html). This class encapsulates the data to be processed and provides descriptive statistics. In principle, an `SSExamine` instance can contain data of any kind. The available statistical indicators depend of course on the type of data.

The following "namespaces"/classes are provided (among others):

* SSExamine (class)
* SSHypothesisTesting (enum)
* SSProbDist (enum)
* [`SSDataFrame`](docs/Classes/SSDataFrame.html) instances encapsulate datasets. You can imagine the structure of an `SSDataFrame` object as a table: The columns of the table correspond to the individual dataset and the rows correspond to the data of the dataset.
* [`SSCrossTab`](docs/Structures/SSCrossTab.html) contains a cross table with the usual structure (like a n x m matrix) and provides the statistics needed for frequency comparisons (Chi-square, Phi, residuals etc.).

There are several extensions to standard Swift types (`Array`, Floating point types, `String `).


# How to Install
## CocoaPods (recommended if your are on a Mac)
[CocoaPods](http://cocoapods.org) is the preferred way to add SwiftyStats to your project:

```bash
$> cd <YOUR_PROJECT_FOLDER>
$> vi Podfile
```
Your Podfile should looks like:  

```ruby
target 'YOURPROJECT' do
use_frameworks!
pod 'SwiftyStats'  
end
```
If you have to use a Swift version **earlier** than 4.2, replace the line `pod 'SwiftyStats'` by:

```ruby
...
pod 'SwiftyStats", '0.8.14'
...
```
Save your changes, run:

```bash
$ pod install
```
and wait.

## Swift Package Manager (recommended for Linux)
**The Linux package is still under development and is considered to be unstable.**

Edit your `Package.swift` file:

```swift
import PackageDescription
// for Swift 4.2 or 5
let version = "1.1.0"
// for earlier versions:
// let version = "0.8.14"
let package = Package(
name: "<YOUR_PACKAGE_NAME>",
dependencies: [
.package(url: "https://github.com/strike65/SwiftyStats", from: version)
]
)
```
Rebuild your project.  
For more information about the Swift Package Manager click [here](https://github.com/apple/swift-package-manager/tree/master/Documentation)

## Build Swift Module from command line

**Clone** the repo to a directory of your choice and change to the directory.  

> Swift must be present on your system!

* `make` or `make debug` builds the module in debug-configuration
* `make release` builds the module in release-configuration
* `make test` builds the module and performs some tests
* `make clean` resets the build-process

# Tests
The integrated test suite uses numerical data for comparison with the results calculated by SwiftyStats. The comparison data were generated using common computer algebra systems and numerical software. 

# How to use

```swift
   import SwiftyStats

   // example data
   let data: Array<Double> = [3.14,1.21,5.6]
   // because our data are double valued items, the parameter "characterSet" is ignored
   let test = SSExamine<Double, Double>.init(withObject: data,
                                     levelOfMeasurement: .interval,
                                           characterSet: nil)
   // prints out the arithmetic mean
   print("\(test.arithmeticMean)")
   // you can use the class to analyze strings too:
   let testString = "This string must be analyzed!"
   // in this case, only characters contained in CharacterSet.alphanumerics are added
   let stringAnalyze = VTExamine<String>(withObject: data, 
                                 levelOfMeasurement: .nominal, 
                                       characterSet: CharacterSet.alphanumerics)
   print("\(stringAnalyze.frequency("i")")
   // print out the 95% quantile of the Student T distribution
   do {
      let q = try SSProbDist.StudentT.quantile(p: 0.95, degreesOfFreedom: 21)
      print("\(q)")
   }
   catch {
      print(error.localizedDescription)
   }
```
Probability distributions in general are defined within relatively narrow conditions expressed in terms of certain parameters such as "degree of freedom", "shape" or "mean". For each distribution there are the following functions defined:

* cdf: Cumulative Distribution Function
* pdf: Probability Density Function
* quantile: Inverse CDF
* para: returns a `SSContProbDistParams` struct (`mean`, `variance`, `skewness`, `kurtosis`)

> **Please always check if `NaN` or `nil` is returned.** 

### Obtainable Statistics
(This list is not exhaustive.)

#### SSExamine
arithmeticMean
mode
commonest
scarcest
quantile(q:)
quartile
geometricMean
harmonicMean
contraHarmonicMean
poweredMean(order:)
trimmedMean(alpha:)
winsorizedMean(alpha:)
gastwirth
median
product
logProduct
maximum
minimum
range
quartileDeviation
relativeQuartileDistance
midRange
interquartileRange
interquantileRange(lowerQuantile:upperQuantile:)
variance(type:)
standardDeviation(type:)
standardError
entropy
relativeEntropy
herfindahlIndex
conc
gini
giniNorm
CR(_:)
normalCI(alpha:populationSD:)
studentTCI(alpha:)
meanCI
cv
coefficientOfVariation
meanDifference
medianAbsoluteDeviation(center:scaleFactor:)
meanAbsoluteDeviation(center:)
meanRelativeDifference
semiVariance(type:)
moment(r:type:)
autocorrelation(n:)
kurtosisExcess
kurtosis
kurtosisType
skewness
skewnessType
hasOutliers(testType:)
outliers(alpha:max:testType:)
isGaussian
testForDistribution(targetDistribution:)
boxWhisker
elementsAsString(withDelimiter:asRow:encloseElementsBy:)
elementsAsArray(sortOrder:)
uniqueElements(sortOrder:)
frequencyTable(sortOrder:)
cumulativeFrequencyTable(format:)
eCDF(_:)
smallestFrequency
largestFrequency 

#### SSCrossTab
rowCount
columnCount
firstRow
lastRow
firstColumn
lastColumn
rowNames
columnNames
columnLevelOfMeasurement
rowLevelOfMeasurement
isNumeric
encode(to:)
init(from:)
is2x2Table
isEmpty
isSquare
row(at:sorted:)
column(at:sorted:)
rowNamed(_:sorted:)
columnNamed(_:sorted:)
appendRow(_:name:)
appendColumn(_:name:)
removeRow(rowName:)
removeColumn(columnName:)
removeRow(at:)
removeColumn(at:)
setRow(at:newRow:)
setRow(name:newRow:)
setColumn(name:newColumn:)
setColumn(at:newColumn:)
insertRow(newRow:at:name:)
insertColumn(newColumn:at:name:)
replaceRow(newRow:at:name:)
replaceColumn(newColumn:at:name:)
setRowNames(rowNames:)
setColumnNames(columnNames:)
description
rowSums
columnSums
rowSum(row:)
rowSum(rowName:)
columnSum(column:)
columnSum(columnName:)
nameOfColumn(column:)
nameOfRow(row:)
firstIndexOfColumn(columnName:)
firstIndexOfRow(rowName:)
total
rowTotal()
colummTotal()
largestRowTotal()
largestCellCount(atColumn:)
largestCellCount(atRow:)
relativeTotalFrequency(row:column:)
relativeTotalFrequency(rowName:columnName:)
relativeRowFrequency(row:column:)
relativeColumnFrequency(row:column:)
relativeRowMarginFrequency(row:)
relativeColumnMarginFrequency(column:)
expectedFrequency(row:column:)
expectedFrequency(rowName:columnName:)
residual(row:column:)
standardizedResidual(row:column:)
adjustedResidual(row:column:)
degreesOfFreedom
chiSquare
chiSquareLikelihoodRatio
chiSquareYates
covariance
pearsonR
chiSquareMH
phi
ccont
coefficientOfContingency
cramerV
lambda_C_R()
lambda_R_C()
r0
r1 

#### Probability Functions (cdf, pdf, quantile, para - see above)

* Beta
* Binomial
* Cauchy
* Erlang
* Exponential
* Chi Square (central, non-central)
* F-RATIO (central, non central)
* Gamma
* GAUSSIAN
* Laplace
* Log Normal
* Logistic
* Pareto
* Binomial
* Poisson
* Rayleigh
* STUDENT's T
* NON-CENTRAL T-DISTRIBUTION
* TRIANGULAR
* TRIANGULAR with two params
* UNIFORM
* Wald / Inverse Normal
* Weibull
* CIRCULAR DISTRIBUTION

#### SSHypothesisTesting

Equality of means

twoSampleTTest(data1:data2:alpha:)
twoSampleTTest(sample1:sample2:alpha:)
oneSampleTTest(sample:mean:alpha:)
oneSampleTTEst(data:mean:alpha:)
matchedPairsTTest(set1:set2:alpha:)
matchedPairsTTest(data1:data2:alpha:)
oneWayANOVA(data:alpha:)
oneWayANOVA(data:alpha:)
oneWayANOVA(dataFrame:alpha:)
multipleMeansTest(dataFrame:alpha:)
multipleMeansTest(data:alpha:)
multipleMeansTest(data:alpha:)
tukeyKramerTest(dataFrame:alpha:)
tukeyKramerTest(data:alpha:)
scheffeTest(dataFrame:alpha:)
bonferroniTest(dataFrame:)

Autocorrelation

autocorrelationCoefficient(array:lag:)
autocorrelationCoefficient(data:lag:)
autocorrelation(array:)
autocorrelation(data:)

NPAR tests

kolmogorovSmirnovGoFTest(array:targetDistribution:)
ksGoFTest(array:targetDistribution:)
kolmogorovSmirnovGoFTest(data:targetDistribution:)
ksGoFTest(data:targetDistribution:)
adNormalityTest(data:alpha:)
adNormalityTest(array:alpha:)
mannWhitneyUTest(set1:set2:)
mannWhitneyUTest(set1:set2:)
wilcoxonMatchedPairs(set1:set2:)
wilcoxonMatchedPairs(set1:set2:)
signTest(set1:set2:)
signTest(set1:set2:)
binomialTest(numberOfSuccess:numberOfTrials:probability:alpha:alternative:)
binomialTest(data:characterSet:testProbability:successCodedAs:alpha:alternative:)
binomialTest(data:testProbability:successCodedAs:alpha:alternative:)
kolmogorovSmirnovTwoSampleTest(set1:set2:alpha:)
kolmogorovSmirnovTwoSampleTest(set1:set2:alpha:)
waldWolfowitzTwoSampleTest(set1:set2:)
kruskalWallisHTest(data:alpha:)

Outliers

grubbsTest(array:alpha:)
grubbsTest(data:alpha:)
esdOutlierTest(array:alpha:maxOutliers:testType:)
esdOutlierTest(data:alpha:maxOutliers:testType:)

Randomness

runsTest(array:alpha:useCuttingPoint:userDefinedCuttingPoint:alternative:)
runsTest(data:alpha:useCuttingPoint:userDefinedCuttingPoint:alternative:)

Equality of variances

bartlettTest(data:alpha:)
bartlettTest(array:alpha:)
leveneTest(data:testType:alpha:)
leveneTest(array:testType:alpha:)
chiSquareVarianceTest(array:nominalVariance:alpha:)
chiSquareVarianceTest(sample:nominalVariance:alpha:)
fTestVarianceEquality(data1:data2:alpha:)
fTestVarianceEquality(sample1:sample2:alpha:) 


# LICENSE
This framework is published under the [GNU GPL 3](http://www.gnu.org/licenses/)

Copyright 2017 - 2019 strike65


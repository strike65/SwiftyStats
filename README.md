![Language](https://img.shields.io/badge/Language-Swift_5-yellow.svg) ![Version](https://img.shields.io/badge/version-1.0.4-orange.svg) ![Unit Tests](https://img.shields.io/badge/Unit_Tests-passed-green.svg) ![macOS](https://img.shields.io/badge/macOS-built-green.svg) ![iOS](https://img.shields.io/badge/iOS-built-green.svg) ![Build Linux](https://img.shields.io/badge/Linux-under_development-red.svg) 

SwiftyStats
===========
SwiftyStats is a generic statistical framework completely written in Swift. The framework is basically a port from an existing Objective C framework I've written years ago. The framework includes often used statistical routines. This framework is far from being perfect and is "work in progress".
>Due to some external limitations (earning money) the code will be updated rather sporadically.

The integrated test suite uses numerical data for comparison with the results calculated by SwiftyStats. The comparison data were generated using common computer algebra systems. 

Important changes
=================
**This update contains a lot of new features. That is, your code have to be updated.**

Version 1.0.0 or newer requires at least Swift 4.2 or later. If you cannot use Swift 4.2 or later, you will need to customize the Podfile (see below). 

> Due to the heavy use of generics, the first build takes a long time. The same problem occurs if the contents of the `DerivedData` folder have been deleted. 

# Documentation
A jazzy-generated reference can be found here: [SwiftyStats Doc](http://www.vpedia.net/swiftystats).

**macOS only**:  
Locally you can always generate a docset using `SwiftyStats/make_doc.sh`script. To do this, [Jazzy](https://github.com/realm/jazzy) must be installed on your system:

```bash
$> cd <CLONE_DIRECTORY>/SwiftyStats
$> ./make_docs.sh
$> open docs/index.html
```

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
  use frameworks!
  pod 'SwiftyStats'  
end
```
If you have to use a Swift version **earlier** than 4.2, replace the line `pod 'SwiftyStats'` by:

```ruby
...
   pod 'SwiftyStats", '0.8.14'
...
```
Save your changes and run:

```bash
$ pod install
```

## Swift Package Manager (recommended for Linux)
**The Linux package is still under development and is considered to be unstable.**

Edit your `Package.swift` file:

```swift
import PackageDescription
// for Swift 4.2 or 5
let version = "1.0.4"
// for earlier versions:
// let version = "0.8.14"
let package = Package(
	name: "<YOUR_PACKAGE_NAME>",
	dependencies: [
		.package(url: "https://gitlab.com/strike65/SwiftyStats", from: version)
	]
)
```
Then rebuild your project.  
For more information about the Swift Package Manager click [here](https://github.com/apple/swift-package-manager/tree/master/Documentation)

## Manually
* Clone:  

```bash
$> cd <YOUR_FOLDER_FOR_CLONED_REPOS>
$> git clone https://github.com/strike65/SwiftyStats.git
```

Then drag the `SwiftyStats.xcodeproj` into your project and make sure the following build options are set:
### Targeting iOS
- add "SwiftyStats"/"SwiftyStatsMobile" to ```Targets->Build Phases->Target Dependencies```
- add "SwiftyStats"/"SwiftyStatsMobile" to ```Targets->Build Phases->Link Binary With Libraries```
- add "SwiftyStats"/"SwiftyStatsMobile" to ```Targets->Build Phases->Embed Frameworks```

### Targeting macOS
- add "SwiftyStats"/"SwiftyStats" to ```Targets->Build Phases->Target Dependencies```
- add "SwiftyStats"/"SwiftyStats" to ```Targets->Build Phases->Link Binary With Libraries```
- add "SwiftyStats"/"SwiftyStats" to ```Targets->Build Phases->Embed Frameworks```
for macOS targets.

### Targeting Linux
As there is no Xcode-Project, you have to use the Swift Package Manager. See above.

## Build Swift Module from command line

**Clone** the repo to a directory of your choice and change to the directory.  

* `make` or `make debug` builds the module in debug-configuration
* `make release` builds the module in release-configuration
* `make test` builds the module and performs some tests
* `make clean` resets the build-process

# How to Use
## Accuracy and Precision
Although the internal accuracy is much larger, only the **first four decimal places** should be used. For more information on this click [here](https://docs.oracle.com/cd/E19957-01/806-3568/ncg_goldberg.html).

> It is recommended to use this library with at least double accuracy.

## Descriptive stats
The central class of the framework is `SSExamine`
`SSExamine` objects encapsulate your data and delivers various statistics. To initialize a new instance follow the steps below.


```swift
import SwiftyStats

// example data
let data: Array<Double> = [3.14,1.21,5.6]
// because our data are double valued items, the parameter "characterSet" is ignored
let test = SSExamine<Double, Double>.init(withObject: data, levelOfMeasurement: .interval, characterSet: nil)
// prints out the arithmetic mean
print("\(test.arithmeticMean)")
// you can use the class to analyze strings too:
let testString = "This string must be analyzed!"
// in this case, only characters contained in CharacterSet.alphanumerics are added
let stringAnalyze = VTExamine<String>(withObject: data, levelOfMeasurement: .nominal, characterSet: CharacterSet.alphanumerics)
print("\(stringAnalyze.frequency("i")")
```
SSExamine objects can be stored and restored in various ways, e.g.:

```swift
do {
	try myExamineObject.archiveTo(filePath: "~/data/myexamine.ssexamine", overwrite: true)
}
catch {
    // error handling
}
...
do {
	newObject: SSExamine<Double, Double> = try SSExamine<Double, Double>.unarchiveFrom(filePath: "~/data/myexamine.ssexamine")
}
catch {
    // error handling
}
```

### Obtainable Statistics
(This list is not exhaustive.)

INITIALIZERS

    init()
    init(withObject:levelOfMeasurement:name:characterSet:)
    init(withArray:name:characterSet:)
    examine(fromFile:separator:stringEncoding:_:)
    examine(fromJSONFile:stringEncoding:)
    exportJSONString(fileName:atomically:overwrite:stringEncoding:)
    saveTo(fileName:atomically:overwrite:separator:asRow:stringEncoding:)
    examineWithString(_:name:characterSet:)

Codable protocol

    encode(to:)
    init(from:)

NSCopying

    copy(with:)

SSExamineContainer Protocol

    contains(_:)
    rFrequency(_:)
    frequency(_:)
    append(_:)
    append(repeating:element:)
    append(contentOf:)
    append(text:characterSet:)
    remove(_:allOccurences:)
    removeAll()

File Management

    archiveTo(filePath:overwrite:)
    unarchiveFrom(filePath:)
    Sn
    Qn
    squareTotal
    poweredTotal(power:)
    total
    inverseTotal
    tss(value:)

Location

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

Products

    product
    logProduct

Dispersion

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

Empirical Moments

    moment(r:type:)
    autocorrelation(n:)

Empirical distribution parameters

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

Elements

    elementsAsString(withDelimiter:asRow:)
    elementsAsArray(sortOrder:)
    uniqueElements(sortOrder:)

Frequencies

    frequencyTable(sortOrder:)
    cumulativeFrequencyTable(format:)
    eCDF(_:)
    smallestFrequency
    largestFrequency 


## SSHypothesisTesting
The framework implements the following tests so far:

- Kolmogorov Smirnov test (one/two sample))
- Anderson Darling test
- Bartlett test
- Levene test (with variants)
- Grubbs test
- ESD test (Rosner test)
- t test (matched, 2-sample)
- Mann Whitney U-test
- Wilcoxon matched pairs test
- sign test
- one factor ANOVA
- Tukey-Kramer post hoc test
- Scheffé-Test
- basic analysis of cross-tables
- ...


## Probability Distributions
This library provides some of the more common probability distributions. Functions are prefixed by `pdf`, `cdf`, `quantile` for "probability density function", "cumulative density function" and "inverse cumulative density" function respectively. The prefix `para` denotes functions returning a `SSContProbDistParams` struct (fields: `mean`, `variance`, `skewness`, `kurtosis`).  
Probability distributions in general are defined within relatively narrow conditions expressed in terms of certain parameters such as "degree of freedom", "shape" or "mean".  

>**Note:**  
Please always check if `NaN` or `nil` is returned.  

###List of supported distributions

- Normal Distribution
- F-Ratio Distribution
- Student's T Distribution
- Noncentral Student's T Distribution
- Chi^2 Distribution
- Noncentral Chi^2 Distribution
- Beta Distribution
- Gamma Distribution
- Log Normal Distribution
- Cauchy Distribution
- Laplace Distribution
- Pareto Distribution
- Wald Distribution
- Exponential Distribution
- Uniform Distribution
- Triangular Distribution
- Rayleigh distribution
- Extreme value distribution

# LICENSE
This framework is published under the [GNU GPL 3](http://www.gnu.org/licenses/)

Copyright 2017,2018 strike65


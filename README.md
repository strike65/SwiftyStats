![Version](https://img.shields.io/badge/version-0.7.0-orange.svg) ![Language](https://img.shields.io/badge/language-Swift_4-yellow.svg) ![DevelopmentPlatform](https://img.shields.io/badge/Development_Platform-macos-red.svg) ![SupportedOS](https://img.shields.io/badge/Supported_OS-macOS/iOS-blue.svg) ![Build](https://img.shields.io/badge/Build-passed-green.svg)
# SwiftyStats
SwiftyStats is a generic statistical framework completely written in Swift 4. The framework is basically a port from an existing Objective C framework I've written years ago. The original framework includes often used statistical routines. The project includes a macOS and iOS target.

# Installation
- clone the repo
- drag the SwiftyStats.xcodeproj into your project
- add "SwiftyStats"/"SwiftyStatsMobile" to ``` "Targets" -> "Build Phases" -> "Target Dependencies "```
- add "SwiftyStats"/"SwiftyStatsMobile" to ```"Targets" -> "Build Phases" -> "Link Binary With Libraries"```
- add "SwiftyStats"/"SwiftyStatsMobile" to ```"Targets" -> "Build Phases" -> "Embed Frameworks"```


# SSExamine
This is the central class. SSExamine objects encapsulate your data and delivers various statistics. To initialize a new instance follow the steps below.


```Swift
import SwiftyStats

// example data
let data: Array<Double> = [3.14,1.21,5.6]
// because our data are double valued items, the parameter "characterSet" is ignored
let test = SSExamine<Double>.init(withObject: data, levelOfMeasurement: .interval, characterSet: nil)
// prints out the arithmetic mean
print("\(test.arithmeticMean)")
// you can use the class to analyze strings too:
let testString = "This string must be analyzed!"
// in this case, only characters contained in CharacterSet.alphanumerics are added
let stringAnalyze = VTExamine<String>(withObject: data, levelOfMeasurement: .nominal, characterSet: CharacterSet.alphanumerics)
print("\(stringAnalyze.frequency("i")")
```
SSExamine objects can be stored and restored:

```Swift
do {
	try myExamineObject.archiveTo(filePath: "~/data/myexamine.ssexamine", overwrite: true)
}
catch {
    // error handling
}
...
do {
	newObject: SSExamine<Double> = try SSExamine<Double>.unarchiveFrom(filePath: "~/data/myexamine.ssexamine")
}
catch {
    // error handling
}
```

## Obtainable Statistics
(This list is not exhaustive.)

- sample size
- length (= number of unique elements)
- frequencies (absolute, relative, cumulative)
- empirical cdf
- means (arithmetic, geometric, harmonic, contraharmonic)
- empirical dispersion measures (variance, semi variance, standard deviation, standard error)
- empirical moments (central, about the origin, standardized)
- mode
- maximum, minimum
- quantiles
- ...

# SSHypothesisTesting
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
...


# SSProbabilityDistributions
The class provides the following functions/parameters for the probability distributions listed below:

- PDF
- CDF
- Quantile (= inverse CDF)
- Parameters (kurtosis, skewness, variance, mean)

List of supported distributions:

- Normal Distribution
- F-Ratio Distribution
- Student's T Distribution
- Chi^2 Distribution
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




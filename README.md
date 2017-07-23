![Version](https://img.shields.io/badge/version-0.0.1-green.svg) ![Language](https://img.shields.io/badge/language-Swift_3-blue.svg) ![DevelopmentPlatform](https://img.shields.io/badge/Development_Platform-macos-red.svg)
# SwiftyStats
SwiftyStats is a generic statistical framework completely written in Swift 3. The framework is basically a port from an existing Objective C framework I'written years ago. The original framework includes often used statistical routines such as
- Descriptive Statistics
- Frequency Tables
- Hypothesis Testing (t Test, GoF Tests, Bartlett test, Levene test, Equality of means, runs tests, Mann-Whitney, Wilcoxon, Wald-Wolfowitz ...)
- PDF, CDF and Quantile functions of most common probability distributions
# Installation
To include the framework in your project, just clone the repo an add SwiftyStats to your project. Don't forgett to aupdate your build phases (Target Dependencies) and link your target against SwiftyStats.
# Example
The basic class of the framework is called SSExamine. To instantiate a new object just call
```Swift
import SwiftyStats

let data: Array<Double> = [3.14,1.21,5.6]
let test = SSExamine<Double>.init(withObject: data, levelOfMeasurement: .interval, characterSet: nil)
// prints out the arithmetic mean
print("\(test.arithmeticMean)")
// you can use the class to analyze strings too:
let testString = "This string must be analyzed!"
let stringAnalyze = VTExamine<String>(withObject: data, levelOfMeasurement: .nominal, characterSet: CharacterSet.alphanumerics)
print("\(stringAnalyze.frequency("i")")
```


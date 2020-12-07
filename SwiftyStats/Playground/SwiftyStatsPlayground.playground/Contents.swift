import SwiftyStats

print(try SSProbDist.StudentT.pdf(t: 3.0, degreesOfFreedom: 10))
print(try SSProbDist.StudentT.cdf(t: -1.0, degreesOfFreedom: 1000))
print(try SSProbDist.FRatio.quantile(p: 0.9999, numeratorDF: 3, denominatorDF: 2))



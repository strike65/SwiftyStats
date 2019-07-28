import Cocoa
import SwiftyStats
print("Test SwiftyStats")
print(try! SwiftyStats.SSProbDist.Beta.pdf(x: 2, shapeA: 3.4, shapeB: 4.5))

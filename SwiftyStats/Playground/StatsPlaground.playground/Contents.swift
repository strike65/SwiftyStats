import Cocoa
@testable import SwiftyStats
print("Test SwiftyStats")
public func cdf<FPT: SSFloatingPoint & Codable>(t: FPT, degreesOfFreedom df: FPT) throws -> FPT {
    let half: FPT = FPT.half
    
    var correctedDoF: FPT
    var halfDoF: FPT
    var constant: FPT
    var result: FPT
    halfDoF = df / 2
    correctedDoF = df / ( df + ( t * t ) )
    constant = half
    let t1: FPT = SSSpecialFunctions.betaNormalized(x: 1, a: halfDoF, b: constant)
    let t2: FPT = SSSpecialFunctions.betaNormalized(x: correctedDoF, a: halfDoF, b: constant)
    result = half * (1 + (t1 - t2) * SSMath.sign1(t))
    return result
}

do {
    let x: Float = try cdf(t: -1.0, degreesOfFreedom: 1)
    print(x)
}
catch {
    print(error.localizedDescription)
}

import Testing
import Foundation
@testable import SwiftyStats

@inlinable
func ae(_ a: Double, _ b: Double, rel: Double, absTol: Double) -> Bool {
    if a.isNaN || b.isNaN { return false }
    let d = abs(a - b)
    return d <= max(absTol, rel * max(abs(a), abs(b)))
}

@Suite("Quantile invertibility")
struct QuantileInvertTests {

    @Test("StudentT: cdf(quantile(p)) ≈ p over grid")
    func studentTInvert() throws {
        let dfs: [Double] = [1.0, 5.0, 30.0, 120.0]
        let ps: [Double] = [1e-6, 1e-3, 0.1, 0.5, 0.9, 0.999, 1 - 1e-6]
        let rel = 1e-10, absTol = 1e-12
        for df in dfs {
            for p in ps {
                let q = try SSProbDist.StudentT.quantile(p: p, degreesOfFreedom: df)
                let pc = try SSProbDist.StudentT.cdf(t: q, degreesOfFreedom: df)
                #expect(ae(pc, p, rel: rel, absTol: absTol), "df=\(df) p=\(p) q=\(q) cdf=\(pc)")
            }
        }
    }

    @Test("von Mises: cdf(quantile(p)) ≈ p over grid")
    func vonMisesInvert() throws {
        let m = 0.3
        let kappas: [Double] = [0.5, 2.0, 5.0]
        // avoid exact 0/1 where boundaries are returned
        let ps: [Double] = [1e-4, 0.1, 0.25, 0.5, 0.75, 0.9, 1 - 1e-4]
        let rel = 5e-6, absTol = 1e-6
        for k in kappas {
            for p in ps {
                let q = try SSProbDist.VonMises.quantile(p: p, mean: m, concentration: k)
                let pc = try SSProbDist.VonMises.cdf(x: q, mean: m, concentration: k)
                #expect(ae(pc, p, rel: rel, absTol: absTol), "k=\(k) p=\(p) q=\(q) cdf=\(pc)")
            }
        }
    }

    @Test("Beta: cdf(quantile(p)) ≈ p over grid")
    func betaInvert() throws {
        let shapes: [(Double, Double)] = [(0.5, 0.5), (2.0, 2.0), (5.0, 1.5)]
        let ps: [Double] = [1e-6, 1e-3, 0.1, 0.5, 0.9, 0.999, 1 - 1e-6]
        let rel = 1e-9, absTol = 1e-10
        for (a, b) in shapes {
            for p in ps {
                let q = try SSProbDist.Beta.quantile(p: p, shapeA: a, shapeB: b)
                let pc = try SSProbDist.Beta.cdf(x: q, shapeA: a, shapeB: b)
                let absUse = (p < 1e-5 || (1 - p) < 1e-5) ? 2e-6 : absTol
                #expect(ae(pc, p, rel: rel, absTol: absUse), "a=\(a) b=\(b) p=\(p) q=\(q) cdf=\(pc)")
            }
        }
    }

    @Test("Gamma: cdf(quantile(p)) ≈ p over grid")
    func gammaInvert() throws {
        let shapes: [Double] = [0.5, 2.0, 5.0]
        let scales: [Double] = [0.5, 2.0]
        let ps: [Double] = [1e-8, 1e-3, 0.1, 0.5, 0.9, 0.999, 1 - 1e-8]
        let rel = 1e-9, absTol = 1e-10
        for a in shapes {
            for b in scales {
                for p in ps {
                    let q = try SSProbDist.Gamma.quantile(p: p, shape: a, scale: b)
                    let pc = try SSProbDist.Gamma.cdf(x: q, shape: a, scale: b)
                    let absUse = (p < 1e-5 || (1 - p) < 1e-5) ? 2e-6 : absTol
                    #expect(ae(pc, p, rel: rel, absTol: absUse), "a=\(a) b=\(b) p=\(p) q=\(q) cdf=\(pc)")
                }
            }
        }
    }

    @Test("ChiSquare: cdf(quantile(p)) ≈ p over grid")
    func chiSquareInvert() throws {
        let dfs: [Double] = [1.0, 5.0, 30.0, 120.0]
        let ps: [Double] = [1e-8, 1e-3, 0.1, 0.5, 0.9, 0.999, 1 - 1e-8]
        let rel = 1e-9, absTol = 1e-10
        for df in dfs {
            for p in ps {
                let q = try SSProbDist.ChiSquare.quantile(p: p, degreesOfFreedom: df)
                let pc = try SSProbDist.ChiSquare.cdf(chi: q, degreesOfFreedom: df)
                let absUse = (p < 1e-5 || (1 - p) < 1e-5) ? 2e-6 : absTol
                #expect(ae(pc, p, rel: rel, absTol: absUse), "df=\(df) p=\(p) q=\(q) cdf=\(pc)")
            }
        }
    }

    @Test("FRatio: cdf(quantile(p)) ≈ p over grid")
    func fRatioInvert() throws {
        let df1s: [Double] = [1.0, 5.0, 10.0]
        let df2s: [Double] = [5.0, 10.0, 30.0]
        let ps: [Double] = [1e-6, 1e-3, 0.1, 0.5, 0.9, 0.999, 1 - 1e-6]
        let rel = 2e-6, absTol = 2e-8
        for df1 in df1s {
            for df2 in df2s {
                for p in ps {
                    let q = try SSProbDist.FRatio.quantile(p: p, numeratorDF: df1, denominatorDF: df2)
                    let pc = try SSProbDist.FRatio.cdf(f: q, numeratorDF: df1, denominatorDF: df2)
                    let absUse = (p < 1e-5 || (1 - p) < 1e-5) ? 2e-6 : absTol
                    #expect(ae(pc, p, rel: rel, absTol: absUse), "df1=\(df1) df2=\(df2) p=\(p) q=\(q) cdf=\(pc)")
                }
            }
        }
    }
}

import Testing
import Foundation
@testable import SwiftyStats

extension Tag {
    @Tag static var numerics: Self
}

@inlinable
func pow10<F: SSFloatingPoint>(_ n: Int) -> F {
    var r: F = 1
    var k = n
    var b: F = 10
    while k > 0 {
        if (k & 1) != 0 { r *= b }
        k >>= 1
        if k > 0 { b *= b }
    }
    return r
}

@inlinable
func relTol<F: SSFloatingPoint>(_: F.Type) -> F {
    if F.self == Float.self { return F(1) / pow10(6) }
    return F(1) / pow10(12)
}

@inlinable
func absTol<F: SSFloatingPoint>(_: F.Type) -> F {
    if F.self == Float.self { return F(1) / pow10(6) }
    return F(1) / pow10(14)
}

@inlinable
func almostEqual<F: SSFloatingPoint>(_ a: F, _ b: F, rel: F, absTol: F) -> Bool {
    if a.isNaN || b.isNaN { return false }
    let diff = Swift.abs(a - b)
    let scale = max(Swift.abs(a), Swift.abs(b))
    return diff <= max(absTol, rel * scale)
}

@Suite("SSFloatingPoint constants", .tags(.numerics))
struct SSFloatingPointTests {

    @Test("pi identities (Double)")
    func piIdentitiesDouble() {
        typealias F = Double
        let rt = relTol(F.self), at = absTol(F.self)
        #expect(almostEqual(F.pihalf * 2, F.pi, rel: rt, absTol: at))
        #expect(almostEqual(F.pifourth * 2, F.pihalf, rel: rt, absTol: at))
        #expect(almostEqual(F.threepifourth, F.pifourth * 3, rel: rt, absTol: at))
        #expect(almostEqual(F.twopi, F.pi * 2, rel: rt, absTol: at))
        #expect(almostEqual(F.pisquared, F.pi * F.pi, rel: rt, absTol: at))
    }

    @Test("reciprocal identities (Double)")
    func reciprocalIdentitiesDouble() {
        typealias F = Double
        let rt = relTol(F.self), at = absTol(F.self)
        #expect(almostEqual(F.twoopi * F.pihalf, F.one, rel: rt, absTol: at))
        #expect(almostEqual(F.oopi * F.pi, F.one, rel: rt, absTol: at))
        #expect(almostEqual(F.oo2pi * F.twopi, F.one, rel: rt, absTol: at))
    }

    @Test("fractions (Double)")
    func fractionsDouble() {
        typealias F = Double
        let rt = relTol(F.self), at = absTol(F.self)
        #expect(almostEqual(F.half + F.half, F.one, rel: rt, absTol: at))
        #expect(almostEqual(F.third * 3, F.one, rel: rt, absTol: at))
        #expect(almostEqual(F.twoo3, F.twothirds, rel: rt, absTol: at))
        #expect(almostEqual(F.oo3 + F.oo6, F.half, rel: rt, absTol: at))
    }

    @Test("pi combinations (Double)")
    func piCombosDouble() {
        typealias F = Double
        let rt = relTol(F.self), at = absTol(F.self)
        #expect(almostEqual(F.pihalf + F.pifourth, F.threepifourth, rel: rt, absTol: at))
        #expect(almostEqual(F.pifourth * 4, F.pi, rel: rt, absTol: at))
        #expect(almostEqual(F.pithirds * 2, F.twopithird, rel: rt, absTol: at))
        #expect(almostEqual(F.threepiate * (F(8) / F(3)), F.pi, rel: rt, absTol: at))
    }

    @Test("sqrt identities (Double)")
    func sqrtIdentitiesDouble() {
        typealias F = Double
        let rt = relTol(F.self), at = absTol(F.self)
        #expect(almostEqual(F.sqrt2 * F.sqrt2, F(2), rel: rt, absTol: at))
        #expect(almostEqual(F.sqrt3 * F.sqrt3, F(3), rel: rt, absTol: at))
        #expect(almostEqual(F.sqrt6 * F.sqrt6, F(6), rel: rt, absTol: at))
        #expect(almostEqual(F.sqrtpi * F.sqrtpi, F.pi, rel: rt, absTol: at))
        #expect(almostEqual(F.sqrt2pi * F.sqrt2pi, F.twopi, rel: rt, absTol: at))
        #expect(almostEqual(F.sqrtpihalf * F.sqrtpihalf, F.pihalf, rel: rt, absTol: at))
    }

    @Test("log identities (Double)")
    func logIdentitiesDouble() {
        typealias F = Double
        let rt = relTol(F.self), at = absTol(F.self)
        #expect(almostEqual(F.lnsqrt2, F.half * F.ln2, rel: rt, absTol: at))
        #expect(almostEqual(F.lnsqrtpi, F.half * F.lnpi, rel: rt, absTol: at))
        #expect(almostEqual(F.lnsqrt2pi, F.half * (F.ln2 + F.lnpi), rel: rt, absTol: at))
    }

    @Test("sqrt reciprocal identities (Double)")
    func sqrtReciprocalDouble() {
        typealias F = Double
        let rt = relTol(F.self), at = absTol(F.self)
        #expect(almostEqual(F.sqrt2Opi * F.sqrt2Opi, F.twoopi, rel: rt, absTol: at))
        #expect(almostEqual(F.sqrt2piinv * F.sqrt2piinv, F.oo2pi, rel: rt, absTol: at))
        #expect(almostEqual(F.oosqrtpi * F.oosqrtpi, F.oopi, rel: rt, absTol: at))
    }

    @Test("2^(1/4) identities (Double)")
    func twoexpfourthDouble() {
        typealias F = Double
        let rt = relTol(F.self), at = absTol(F.self)
        let sq = F.twoexpfourth * F.twoexpfourth
        let fourth = sq * sq
        #expect(almostEqual(sq, F.sqrt2, rel: rt, absTol: at))
        #expect(almostEqual(fourth, F(2), rel: rt, absTol: at))
    }

    @Test("pi identities (Float)")
    func piIdentitiesFloat() {
        typealias F = Float
        let rt = relTol(F.self), at = absTol(F.self)
        #expect(almostEqual(F.pihalf * 2, F.pi, rel: rt, absTol: at))
        #expect(almostEqual(F.pifourth * 2, F.pihalf, rel: rt, absTol: at))
        #expect(almostEqual(F.threepifourth, F.pifourth * 3, rel: rt, absTol: at))
        #expect(almostEqual(F.twopi, F.pi * 2, rel: rt, absTol: at))
        #expect(almostEqual(F.pisquared, F.pi * F.pi, rel: rt, absTol: at))
    }

    @Test("reciprocal identities (Float)")
    func reciprocalIdentitiesFloat() {
        typealias F = Float
        let rt = relTol(F.self), at = absTol(F.self)
        #expect(almostEqual(F.twoopi * F.pihalf, F.one, rel: rt, absTol: at))
        #expect(almostEqual(F.oopi * F.pi, F.one, rel: rt, absTol: at))
        #expect(almostEqual(F.oo2pi * F.twopi, F.one, rel: rt, absTol: at))
    }

    @Test("fractions (Float)")
    func fractionsFloat() {
        typealias F = Float
        let rt = relTol(F.self), at = absTol(F.self)
        #expect(almostEqual(F.half + F.half, F.one, rel: rt, absTol: at))
        #expect(almostEqual(F.third * 3, F.one, rel: rt, absTol: at))
        #expect(almostEqual(F.twoo3, F.twothirds, rel: rt, absTol: at))
        #expect(almostEqual(F.oo3 + F.oo6, F.half, rel: rt, absTol: at))
    }

    @Test("pi combinations (Float)")
    func piCombosFloat() {
        typealias F = Float
        let rt = relTol(F.self), at = absTol(F.self)
        #expect(almostEqual(F.pihalf + F.pifourth, F.threepifourth, rel: rt, absTol: at))
        #expect(almostEqual(F.pifourth * 4, F.pi, rel: rt, absTol: at))
        #expect(almostEqual(F.pithirds * 2, F.twopithird, rel: rt, absTol: at))
        #expect(almostEqual(F.threepiate * (F(8) / F(3)), F.pi, rel: rt, absTol: at))
    }

    @Test("sqrt identities (Float)")
    func sqrtIdentitiesFloat() {
        typealias F = Float
        let rt = relTol(F.self), at = absTol(F.self)
        #expect(almostEqual(F.sqrt2 * F.sqrt2, F(2), rel: rt, absTol: at))
        #expect(almostEqual(F.sqrt3 * F.sqrt3, F(3), rel: rt, absTol: at))
        #expect(almostEqual(F.sqrt6 * F.sqrt6, F(6), rel: rt, absTol: at))
        #expect(almostEqual(F.sqrtpi * F.sqrtpi, F.pi, rel: rt, absTol: at))
        #expect(almostEqual(F.sqrt2pi * F.sqrt2pi, F.twopi, rel: rt, absTol: at))
        #expect(almostEqual(F.sqrtpihalf * F.sqrtpihalf, F.pihalf, rel: rt, absTol: at))
    }

    @Test("log identities (Float)")
    func logIdentitiesFloat() {
        typealias F = Float
        let rt = relTol(F.self), at = absTol(F.self)
        #expect(almostEqual(F.lnsqrt2, F.half * F.ln2, rel: rt, absTol: at))
        #expect(almostEqual(F.lnsqrtpi, F.half * F.lnpi, rel: rt, absTol: at))
        #expect(almostEqual(F.lnsqrt2pi, F.half * (F.ln2 + F.lnpi), rel: rt, absTol: at))
    }

    @Test("sqrt reciprocal identities (Float)")
    func sqrtReciprocalFloat() {
        typealias F = Float
        let rt = relTol(F.self), at = absTol(F.self)
        #expect(almostEqual(F.sqrt2Opi * F.sqrt2Opi, F.twoopi, rel: rt, absTol: at))
        #expect(almostEqual(F.sqrt2piinv * F.sqrt2piinv, F.oo2pi, rel: rt, absTol: at))
        #expect(almostEqual(F.oosqrtpi * F.oosqrtpi, F.oopi, rel: rt, absTol: at))
    }

    @Test("2^(1/4) identities (Float)")
    func twoexpfourthFloat() {
        typealias F = Float
        let rt = relTol(F.self), at = absTol(F.self)
        let sq = F.twoexpfourth * F.twoexpfourth
        let fourth = sq * sq
        #expect(almostEqual(sq, F.sqrt2, rel: rt, absTol: at))
        #expect(almostEqual(fourth, F(2), rel: rt, absTol: at))
    }

    #if arch(i386) || arch(x86_64)
    @Test("pi identities (Float80)")
    func piIdentitiesFloat80() {
        typealias F = Float80
        let rt = relTol(F.self), at = absTol(F.self)
        #expect(almostEqual(F.pihalf * 2, F.pi, rel: rt, absTol: at))
        #expect(almostEqual(F.pifourth * 2, F.pihalf, rel: rt, absTol: at))
        #expect(almostEqual(F.threepifourth, F.pifourth * 3, rel: rt, absTol: at))
        #expect(almostEqual(F.twopi, F.pi * 2, rel: rt, absTol: at))
        #expect(almostEqual(F.pisquared, F.pi * F.pi, rel: rt, absTol: at))
    }

    @Test("reciprocal identities (Float80)")
    func reciprocalIdentitiesFloat80() {
        typealias F = Float80
        let rt = relTol(F.self), at = absTol(F.self)
        #expect(almostEqual(F.twoopi * F.pihalf, F.one, rel: rt, absTol: at))
        #expect(almostEqual(F.oopi * F.pi, F.one, rel: rt, absTol: at))
        #expect(almostEqual(F.oo2pi * F.twopi, F.one, rel: rt, absTol: at))
    }

    @Test("fractions (Float80)")
    func fractionsFloat80() {
        typealias F = Float80
        let rt = relTol(F.self), at = absTol(F.self)
        #expect(almostEqual(F.half + F.half, F.one, rel: rt, absTol: at))
        #expect(almostEqual(F.third * 3, F.one, rel: rt, absTol: at))
        #expect(almostEqual(F.twoo3, F.twothirds, rel: rt, absTol: at))
        #expect(almostEqual(F.oo3 + F.oo6, F.half, rel: rt, absTol: at))
    }

    @Test("pi combinations (Float80)")
    func piCombosFloat80() {
        typealias F = Float80
        let rt = relTol(F.self), at = absTol(F.self)
        #expect(almostEqual(F.pihalf + F.pifourth, F.threepifourth, rel: rt, absTol: at))
        #expect(almostEqual(F.pifourth * 4, F.pi, rel: rt, absTol: at))
        #expect(almostEqual(F.pithirds * 2, F.twopithird, rel: rt, absTol: at))
        #expect(almostEqual(F.threepiate * (F(8) / F(3)), F.pi, rel: rt, absTol: at))
    }

    @Test("sqrt identities (Float80)")
    func sqrtIdentitiesFloat80() {
        typealias F = Float80
        let rt = relTol(F.self), at = absTol(F.self)
        #expect(almostEqual(F.sqrt2 * F.sqrt2, F(2), rel: rt, absTol: at))
        #expect(almostEqual(F.sqrt3 * F.sqrt3, F(3), rel: rt, absTol: at))
        #expect(almostEqual(F.sqrt6 * F.sqrt6, F(6), rel: rt, absTol: at))
        #expect(almostEqual(F.sqrtpi * F.sqrtpi, F.pi, rel: rt, absTol: at))
        #expect(almostEqual(F.sqrt2pi * F.sqrt2pi, F.twopi, rel: rt, absTol: at))
        #expect(almostEqual(F.sqrtpihalf * F.sqrtpihalf, F.pihalf, rel: rt, absTol: at))
    }

    @Test("log identities (Float80)")
    func logIdentitiesFloat80() {
        typealias F = Float80
        let rt = relTol(F.self), at = absTol(F.self)
        #expect(almostEqual(F.lnsqrt2, F.half * F.ln2, rel: rt, absTol: at))
        #expect(almostEqual(F.lnsqrtpi, F.half * F.lnpi, rel: rt, absTol: at))
        #expect(almostEqual(F.lnsqrt2pi, F.half * (F.ln2 + F.lnpi), rel: rt, absTol: at))
    }

    @Test("sqrt reciprocal identities (Float80)")
    func sqrtReciprocalFloat80() {
        typealias F = Float80
        let rt = relTol(F.self), at = absTol(F.self)
        #expect(almostEqual(F.sqrt2Opi * F.sqrt2Opi, F.twoopi, rel: rt, absTol: at))
        #expect(almostEqual(F.sqrt2piinv * F.sqrt2piinv, F.oo2pi, rel: rt, absTol: at))
        #expect(almostEqual(F.oosqrtpi * F.oosqrtpi, F.oopi, rel: rt, absTol: at))
    }

    @Test("2^(1/4) identities (Float80)")
    func twoexpfourthFloat80() {
        typealias F = Float80
        let rt = relTol(F.self), at = absTol(F.self)
        let sq = F.twoexpfourth * F.twoexpfourth
        let fourth = sq * sq
        #expect(almostEqual(sq, F.sqrt2, rel: rt, absTol: at))
        #expect(almostEqual(fourth, F(2), rel: rt, absTol: at))
    }
    #endif
}

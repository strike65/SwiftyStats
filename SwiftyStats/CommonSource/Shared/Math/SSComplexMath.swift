//
//  Created by VT on 12.10.18.
//  Copyright © 2018 strike65. All rights reserved.
/*
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


internal func round<T: SSComplexFloatElement>(_ z: Complex<T>) -> Complex<T> {
    return Complex<T>.init(re: round(z.re), im: round(z.im))
}

internal func exp<T: SSComplexFloatElement>(_ z: Complex<T>) -> Complex<T> {
    let r = exp1(z.re)
    let a = z.im
    return Complex<T>.init(re: r * cos1(a), im: r * sin1(a))
}

internal func exp<T: SSComplexFloatElement>(_ x: T) -> Complex<T> {
    return  Complex<T>.init(exp1(x))
}

/// e ** z - 1.0 in Complex
internal  func expm1<T: SSComplexFloatElement>(_ z: Complex<T>) -> Complex<T> {
    // cf. https://lists.gnu.org/archive/html/octave-maintainers/2008-03/msg00174.html
    return &---exp(z &% 2) &** 2 &** sin(z.i &% 2).i
}

internal func expm1<T: SSComplexFloatElement>(_ x: T) -> Complex<T> {
    return Complex<T>.init(expm11(x))
}

/// natural log of z in Complex
internal  func log<T: SSComplexFloatElement>(_ z:Complex<T>) -> Complex<T> {
    return Complex<T>(log1(z.abs), z.arg)
}

internal  func log<T: SSComplexFloatElement>(_ x: T) -> Complex<T> {
    return log(Complex<T>(x))
}

internal  func log1p<T: SSComplexFloatElement>(_ z: Complex<T>) -> Complex<T> {
    return 2 &** atanh(z &% (z &++ 2))
}

internal  func log1p<T: SSComplexFloatElement>(_ x: T) -> Complex<T> {
    return Complex<T>(log1p1(x))
}

/// base 2 log of z in Complex
internal  func log2<T: SSComplexFloatElement>(_ z: Complex<T>) -> Complex<T> {
    return log(z) &% log1(2)
}

internal  func log2<T: SSComplexFloatElement>(_ x: T) -> Complex<T> {
    return log2(Complex<T>(x))
}

/// base 10 log of z in Complex
internal  func log10<T: SSComplexFloatElement>(_ z: Complex<T>) -> Complex<T> {
    return log(z) &% log1(10)
}

internal  func log10<T: SSComplexFloatElement>(_ x: T) -> Complex<T> {
    return log10(Complex<T>(x))
}

/// lhs ** rhs in Complex
internal  func pow<T: SSComplexFloatElement>(_ lhs: Complex<T>, _ rhs: Complex<T>) -> Complex<T> {
    return exp(log(lhs) &** rhs)
}

internal  func sqrt<T: SSComplexFloatElement>(_ c: Complex<T>) -> Complex<T> {
    let a = c.abs
    let r = ((a + c.re) / 2).squareRoot()
    let i = ((a - c.re) / 2).squareRoot()
    return Complex<T>(r, c.im.sign == .minus ? -i : i)
}

internal  func sqrt<T: SSComplexFloatElement>(_ r: T) -> Complex<T> {
    return sqrt(Complex<T>(r))
}

internal  func pow<T: SSComplexFloatElement>(_ lhs: Complex<T>, _ rhs: T) -> Complex<T> {
    return pow(lhs, Complex<T>(rhs))
}
internal  func pow<T: SSComplexFloatElement>(_ lhs: T, _ rhs: Complex<T>) -> Complex<T> {
    return pow(Complex<T>(lhs), rhs)
}
internal  func pow<T: SSComplexFloatElement>(_ lhs: T, _ rhs: T) -> Complex<T> {
    return Complex<T>(pow1(lhs, rhs))
    
}
/// cosine of z in Complex
internal  func cos<T: SSComplexFloatElement>(_ z:Complex<T>) -> Complex<T> {
    return Complex<T>(+cos1(z.re) * cosh1(z.im), -sin1(z.re) * sinh1(z.im))
}

internal  func cos<T: SSComplexFloatElement>(_ x: T) -> Complex<T> {
    return cos(Complex<T>(x))
}

/// sine of z in Complex
internal  func sin<T: SSComplexFloatElement>(_ z:Complex<T>) -> Complex<T> {
    return Complex<T>(+sin1(z.re) * cosh1(z.im), +cos1(z.re) * sinh1(z.im))
}

internal  func sin<T: SSComplexFloatElement>(_ x: T) -> Complex<T> {
    return sin(Complex<T>(x))
}

/// tangent of z in Complex
internal  func tan<T: SSComplexFloatElement>(_ z:Complex<T>) -> Complex<T> {
    return sin(z) &% cos(z)
}
internal  func tan<T: SSComplexFloatElement>(_ x: T) -> Complex<T> {
    return tan(Complex<T>(x))
}

/// arc cosine of z in Complex
internal  func acos<T: SSComplexFloatElement>(_ z:Complex<T>) -> Complex<T> {
    return log(z &-- sqrt(1 &-- z &** z).i).i
}

internal  func acos<T: SSComplexFloatElement>(_ x:T) -> Complex<T> {
    return acos(Complex<T>(x))
}

/// arc sine of z in Complex
internal  func asin<T: SSComplexFloatElement>(_ z: Complex<T>) -> Complex<T> {
    return &---log(z.i &++ sqrt(1 &-- z &** z)).i
}

internal  func asin<T: SSComplexFloatElement>(_ x:T) -> Complex<T> {
    return asin(Complex<T>(x))
}

/// arc tangent of z in Complex
internal  func atan<T: SSComplexFloatElement>(_ z: Complex<T>) -> Complex<T> {
    let lp = log(1 &-- z.i)
    let lm = log(1 &++ z.i)
    return (lp &-- lm).i &% 2
}

internal  func atan<T: SSComplexFloatElement>(_ x: T) -> Complex<T> {
    return atan(Complex<T>(x))
}

/// hyperbolic cosine of z in Complex
internal  func cosh<T: SSComplexFloatElement>(_ z: Complex<T>) -> Complex<T> {
    // return (exp(z) + exp(-z)) / T(2)
    return cos(z.i)
}

internal  func cosh<T: SSComplexFloatElement>(_ x: T) -> Complex<T> {
    return cosh(Complex<T>(x))
}

/// hyperbolic sine of z in Complex
internal  func sinh<T: SSComplexFloatElement>(_ z: Complex<T>) -> Complex<T> {
    // return (exp(z) - exp(-z)) / T(2)
    return &---sin(z.i).i
}

internal  func sinh<T: SSComplexFloatElement>(_ x: T) -> Complex<T> {
    return sinh(Complex<T>(x))
}

/// hyperbolic tangent of z in Complex
internal  func tanh<T: SSComplexFloatElement>(_ z: Complex<T>) -> Complex<T> {
    // let ez = exp(z), e_z = exp(-z)
    // return (ez - e_z) / (ez + e_z)
    return sinh(z) &% cosh(z)
}

internal  func tanh<T: SSComplexFloatElement>(_ x: T) -> Complex<T> {
    return tanh(Complex<T>(x))
}

/// inverse hyperbolic cosine of z in Complex
internal  func acosh<T: SSComplexFloatElement>(_ z: Complex<T>) -> Complex<T> {
    return log(z &++ sqrt(z &++ 1) &** sqrt(z &-- 1))
}

internal  func acosh<T: SSComplexFloatElement>(_ x: T) -> Complex<T> {
    return acosh(Complex<T>(x))
}

/// inverse hyperbolic cosine of z in Complex
internal  func asinh<T: SSComplexFloatElement>(_ z: Complex<T>) -> Complex<T> {
    return log(z &++ sqrt(z &** z &++ 1))
}

internal  func asinh<T: SSComplexFloatElement>(_ x: T) -> Complex<T> {
    return asinh(Complex<T>(x))
}

/// inverse hyperbolic tangent of z in Complex
internal  func atanh<T: SSComplexFloatElement>(_ z: Complex<T>) -> Complex<T> {
    return (log(1 &++ z) &-- log(1 &-- z)) &% 2
}

internal  func atanh<T: SSComplexFloatElement>(_ x: T) -> Complex<T> {
    return atanh(Complex<T>(x))
}

/// hypotenuse. defined as √(lhs**2 + rhs**2) though its need for Complex is moot.
internal  func hypot<T: SSComplexFloatElement>(_ lhs: Complex<T>, _ rhs: Complex<T>) -> Complex<T> {
    return sqrt(lhs &** lhs &++ rhs &** rhs)
}

internal  func hypot<T: SSComplexFloatElement>(_ lhs: Complex<T>, _ rhs: T) -> Complex<T> {
    return hypot(lhs, Complex<T>(rhs))
}

internal  func hypot<T: SSComplexFloatElement>(_ lhs: T, _ rhs: Complex<T>) -> Complex<T> {
    return hypot(Complex<T>(lhs), rhs)
}

internal  func hypot<T: SSComplexFloatElement>(_ lhs: T, _ rhs: T) -> Complex<T> {
    return Complex<T>(hypot1(lhs, rhs))
}

/// atan2 = atan(lhs/rhs)
internal  func atan2<T: SSComplexFloatElement>(_ lhs:Complex<T>, _ rhs:Complex<T>) -> Complex<T> {
    return atan(lhs &% rhs)
}

internal  func atan2<T: SSComplexFloatElement>(_ lhs: Complex<T>, _ rhs: T) -> Complex<T> {
    return atan2(lhs, Complex<T>(rhs, 0))
}

internal  func atan2<T: SSComplexFloatElement>(_ lhs: T, _ rhs: Complex<T>) -> Complex<T> {
    return atan2(Complex<T>(lhs, 0), rhs)
}

internal  func atan2<T: SSComplexFloatElement>(_ lhs:T, _ rhs:T)->Complex<T> {
    return Complex<T>(atan21(lhs, rhs))
}


internal  func logabs<T: SSComplexFloatElement>(_ c: Complex<T>) -> T {
    let reabs: T = Swift.abs(c.re)
    let imabs: T = Swift.abs(c.im)
    var max, h: T
    if reabs >= imabs {
        max = reabs
        h = imabs / reabs
    }
    else {
        max = imabs
        h = reabs / imabs
    }
    return log1(max) + T.half * log1p1(h * h)
}



fileprivate func gammaCoeff<T: SSComplexFloatElement>() -> Array<T> {
    #if arch(i386) || arch(x86_64)
    let datal: [Float80] = [
        0.1000000000000000000013768214097151627711413659073030931107540587360526314905699014e1,
        0.2351807047072064805366767146731463836069880733065236665991252488484423785585092858e3,
        -0.3542708755572983921567732036527254396822187603081207668629633958206172739732032e3,
        0.15791682745906650643332291853118534158020488387598024901095303079611642055541e3,
        -0.21229298280205474185353277692020446914642204756261359285049135725069492845e2,
        0.50952226823851176885713153598862529954680557674843445328673450073786509e0,
        -0.161760842437384776421242002609181226025660323058491600526558122651e-3,
        0.4394425480863429484202647578257403135154683983381207471104942e-7,
        -0.180924193553203617741789330094117631902148396316124802358061513e-4,
        0.128599423895557275172092037667673107724778241863514030782660245e-3,
        -0.68206804036338611835342193175292998594233647696129700002133148e-3,
        0.30298486938174119382852640309118101621362264534183841202665698e-2,
        -0.113215100533463020011725896519583937719486091526123781705321042e-1,
        0.35446331506925872007254091117907986774318121786306356922479217e-1,
        -0.92727305386478663738576044121519977020675701775643144218474770e-1,
        0.20226694238653121977590575805609701137513442940840051797174845e0,
        -0.36703279591487589359329223696286247184236412560774596763092973e0,
        0.55212714985610195385362240581127475603041437388361889781445947e0,
        -0.6848935133000867504833823357311510516734685883803712854489425e0,
        0.6950675654611116168400180868549510244309079721806171835520219e0,
        -0.5705014612242759882004523679826028138440682017304797707118032e0,
        0.37245615812444887953908505590803792261179337236433383384263266e0,
        -0.18872957915552882649640154246402956365301077316097721494006572e0,
        0.7149826465834367531402941785372442505453587416664742448587721e-1,
        -0.19044750082718839027178234580720266135208128478616131660443202e-1,
        0.31797071797496019457837676417945274980464629413130587862184304e-2,
        -0.25024162326429555428404854886068277259918693702136911227576026e-3

    ]
    #endif
    let datad: [Double] = [
        0.1000000000000000000013768214097151627711413659073030931107540587360526314905699014e1,
        0.2351807047072064805366767146731463836069880733065236665991252488484423785585092858e3,
        -0.3542708755572983921567732036527254396822187603081207668629633958206172739732032e3,
        0.15791682745906650643332291853118534158020488387598024901095303079611642055541e3,
        -0.21229298280205474185353277692020446914642204756261359285049135725069492845e2,
        0.50952226823851176885713153598862529954680557674843445328673450073786509e0,
        -0.161760842437384776421242002609181226025660323058491600526558122651e-3,
        0.4394425480863429484202647578257403135154683983381207471104942e-7,
        -0.180924193553203617741789330094117631902148396316124802358061513e-4,
        0.128599423895557275172092037667673107724778241863514030782660245e-3,
        -0.68206804036338611835342193175292998594233647696129700002133148e-3,
        0.30298486938174119382852640309118101621362264534183841202665698e-2,
        -0.113215100533463020011725896519583937719486091526123781705321042e-1,
        0.35446331506925872007254091117907986774318121786306356922479217e-1,
        -0.92727305386478663738576044121519977020675701775643144218474770e-1,
        0.20226694238653121977590575805609701137513442940840051797174845e0,
        -0.36703279591487589359329223696286247184236412560774596763092973e0,
        0.55212714985610195385362240581127475603041437388361889781445947e0,
        -0.6848935133000867504833823357311510516734685883803712854489425e0,
        0.6950675654611116168400180868549510244309079721806171835520219e0,
        -0.5705014612242759882004523679826028138440682017304797707118032e0,
        0.37245615812444887953908505590803792261179337236433383384263266e0,
        -0.18872957915552882649640154246402956365301077316097721494006572e0,
        0.7149826465834367531402941785372442505453587416664742448587721e-1,
        -0.19044750082718839027178234580720266135208128478616131660443202e-1,
        0.31797071797496019457837676417945274980464629413130587862184304e-2,
        -0.25024162326429555428404854886068277259918693702136911227576026e-3
    ]
    let dataf: [Float] = [
        0.1000000000000000000013768214097151627711413659073030931107540587360526314905699014e1,
        0.2351807047072064805366767146731463836069880733065236665991252488484423785585092858e3,
        -0.3542708755572983921567732036527254396822187603081207668629633958206172739732032e3,
        0.15791682745906650643332291853118534158020488387598024901095303079611642055541e3,
        -0.21229298280205474185353277692020446914642204756261359285049135725069492845e2,
        0.50952226823851176885713153598862529954680557674843445328673450073786509e0,
        -0.161760842437384776421242002609181226025660323058491600526558122651e-3,
        0.4394425480863429484202647578257403135154683983381207471104942e-7,
        -0.180924193553203617741789330094117631902148396316124802358061513e-4,
        0.128599423895557275172092037667673107724778241863514030782660245e-3,
        -0.68206804036338611835342193175292998594233647696129700002133148e-3,
        0.30298486938174119382852640309118101621362264534183841202665698e-2,
        -0.113215100533463020011725896519583937719486091526123781705321042e-1,
        0.35446331506925872007254091117907986774318121786306356922479217e-1,
        -0.92727305386478663738576044121519977020675701775643144218474770e-1,
        0.20226694238653121977590575805609701137513442940840051797174845e0,
        -0.36703279591487589359329223696286247184236412560774596763092973e0,
        0.55212714985610195385362240581127475603041437388361889781445947e0,
        -0.6848935133000867504833823357311510516734685883803712854489425e0,
        0.6950675654611116168400180868549510244309079721806171835520219e0,
        -0.5705014612242759882004523679826028138440682017304797707118032e0,
        0.37245615812444887953908505590803792261179337236433383384263266e0,
        -0.18872957915552882649640154246402956365301077316097721494006572e0,
        0.7149826465834367531402941785372442505453587416664742448587721e-1,
        -0.19044750082718839027178234580720266135208128478616131660443202e-1,
        0.31797071797496019457837676417945274980464629413130587862184304e-2,
        -0.25024162326429555428404854886068277259918693702136911227576026e-3
    ]

    switch T.self {
    case is Float.Type:
        let result = dataf as Array<Float>
        return result as! Array<T>
    case is Double.Type:
        let result = datad as Array<Double>
        return result as! Array<T>
        //        return BI0Double as! Array<FPT>
        #if arch(i386) || arch(x86_64)
    case is Float80.Type:
        let result = datal as Array<Float80>
        return result as! Array<T>
        //        return BI0Float80 as! Array<FPT>
        #endif
    default:
        return datad as! Array<T>
    }

}

#if arch(i386) || arch(x86_64)
/// Returns the gamma function for complex arguments. To maintain the accuracy, all computations are performed using Float80. The result is donwcasted afterwards. This function is not available in SwiftyStatsMobile.
/// This function uses a 27-term-Lanczos-Approximation with g=6.024680040776729583740234375 (stolen from the gsl library)
/// For z = x + yi with -200 <= x <= 200, -200<=y<=200 the relative error (in units of Double.ulpOfOne) is +/- 0.5 f x < 0 and +/-0.0625 for x >= 0
func tgamma1<T: SSComplexFloatElement>(z: Complex<T>) -> Complex<T> {
    let g: Float80 = 6.024680040776729583740234375
    let zrl: Float80 = makeFP(z.re)
    let zil: Float80 = makeFP(z.im)
    let zl: Complex<Float80> = Complex<Float80>.init(re: zrl, im: zil)
    var app: Complex<Float80>
    let coeff: Array<Float80> = gammaCoeff()
    let isNegReal: Bool = z.re < T.zero
    var zz: Complex<Float80> = zl
    if isInteger(zl.re) && zl.im.isZero && zl.re <= Float80.zero {
        
        app = Complex<Float80>.nan
    }
    if isNegReal {
        zz = &---zl
    }
    zz = zz &-- 1
    let zh: Complex<Float80> = zz &++ Float80.half
    let zgh: Complex<Float80> = zh &++ g
    let zp: Complex<Float80> = pow(zgh, zh &** Float80.half);
    var sum: Complex<Float80>
    var temp: Complex<Float80>
    // Kahan sum
    var c: Complex<Float80> = Complex<Float80>.zero
    var y: Complex<Float80> = Complex<Float80>.zero
    var t: Complex<Float80> = Complex<Float80>.zero
    sum = Complex<Float80>.init(re: coeff.last!, im: 0) &% (zz &++ Complex<Float80>.init(re: makeFP(coeff.count - 1), im: Float80.zero))
    for i in stride(from: coeff.count - 2, through: 1, by: -1) {
        temp = Complex<Float80>.init(re: coeff[i], im: 0) &% (zz &++ Complex<Float80>.init(re: makeFP(i), im: Float80.zero))
        y = temp &-- c
        t = sum &++ y
        c = (t &-- sum) &-- y
        sum = t
    }
    app = (Float80.sqrt2pi &** (coeff[0] &++ sum)) &** zp &** exp(&---zgh) &** zp
//    app = exp(temp)
//    app = (Float80.sqrt2pi &** (coeff[0] &++ sum)) &** (zp &** exp(&---zgh) &** zp)
//    if zl.isZero || (zl.re == Float80.one && zl.im.isZero) {
//        app = Complex<Float80>.init(re: 1, im: 0)
//    }
    if isNegReal {
        temp = zl &** app &** sin(Float80.pi &** zl)
        app = Complex<Float80>.init(re: -Float80.pi, im: 0) &% temp
//        app = exp(app)
    }
    let ans: Complex<T> = Complex<T>.init(re: makeFP(app.re), im: makeFP(app.im))
    return ans
}
#endif

#if arch(i386) || arch(x86_64)
/// Returns the gamma function for complex arguments. To maintain the accuracy, all computations are performed using Float80. The result is donwcasted afterwards. This function is not available in SwiftyStatsMobile.
/// This function uses a 27-term-Lanczos-Approximation with g=6.024680040776729583740234375 (stolen from the gsl library)
/// For z = x + yi with -200 <= x <= 200, -200<=y<=200 the relative error (in units of Double.ulpOfOne) is +/- 0.5 f x < 0 and +/-0.0625 for x >= 0
func lgamma1<T: SSComplexFloatElement>(z: Complex<T>) -> Complex<T> {
    let logMinusPi: Complex<Float80> = Complex<Float80>.init(re: 1.144729885849400174143, im: 3.141592653589793238463)
    let g: Float80 = 6.024680040776729583740234375
    let zrl: Float80 = makeFP(z.re)
    let zil: Float80 = makeFP(z.im)
    let zl: Complex<Float80> = Complex<Float80>.init(re: zrl, im: zil)
    var approx: Complex<Float80>
    let coeff: Array<Float80> = gammaCoeff()
    var zz: Complex<Float80>
//    var isNegRe: Bool = false
    var sum: Complex<Float80>
    var temp: Complex<Float80>
    // Kahan sum
    var c: Complex<Float80> = Complex<Float80>.zero
    var y: Complex<Float80> = Complex<Float80>.zero
    var t: Complex<Float80> = Complex<Float80>.zero
    /// no imaginary part
    if zl.im.isZero {
        if isInteger(zl.re) && zl.re <= Float80.zero {
            approx = Complex<Float80>.nan
            let ans: Complex<T> = Complex<T>.init(re: makeFP(approx.re), im: makeFP(approx.im))
            return ans
        }
        if zl.re < Float80.zero {
            zz = &---zl;
//            isNegRe = true
        }
        else {
            // z >= 0 --> use system lgammma
            let ans: Complex<T> = Complex<T>.init(re: makeFP(lgammal(zl.re)), im: 0)
            return ans
//            zz = zl
//            isNegRe = false
        }
        sum = Complex<Float80>.zero
        for i in stride(from: coeff.count - 1, through: 1, by: -1) {
            temp = Complex<Float80>.init(re: coeff[i], im: 0) &% (zz &++ Complex<Float80>.init(re: makeFP(i - 1), im: Float80.zero))
            y = temp &-- c
            t = sum &++ y
            c = (t &-- sum) &-- y
            sum = t
        }
        let zg: Complex<Float80> = zz &++ g &-- Float80.half
        temp = (Float80.lnsqrt2pi &++ log(coeff[0] &++ sum)) &-- zg &++ ((zz &-- Float80.half) &** log(zg))
//        if isNegRe {
            approx = logMinusPi &-- log(zl) &-- temp &-- log(sin(Float80.pi &** zl))
            approx = approx &++ (2 * Float80.pi * ceil(zl.re / 2 - Float80.one)) &** Complex<Float80>.init(re: 0 , im: 1)
//        }
        let ans: Complex<T> = Complex<T>.init(re: makeFP(approx.re), im: makeFP(approx.im))
        return ans
    }
    else {
        return Complex<T>.nan
    }
}
#endif

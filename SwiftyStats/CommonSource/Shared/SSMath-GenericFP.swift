//
//  Created by VT on 04.08.18.
//  Copyright © 2018 Volker Thieme. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  

import Foundation
import Darwin

internal func tgamma1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return tgamma(d) as Double as! T
    case let f as Float:
        return tgammaf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return tgammal(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func lgamma1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return lgamma(d) as Double as! T
    case let f as Float:
        return lgammaf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return lgammal(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func exp1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return exp(d) as Double as! T
    case let f as Float:
        return expf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return expl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func log1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return log(d) as Double as! T
    case let f as Float:
        return logf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return logl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func log21<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return log2(d) as Double as! T
    case let f as Float:
        return log2f(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return log2l(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}



internal func log1p1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return log1p(d) as Double as! T
    case let f as Float:
        return log1pf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return log1pl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func expm11<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return expm1(d) as Double as! T
    case let f as Float:
        return expm1(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return expm1(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func pow1<T: SSFloatingPoint>(_ x: T, _ e: T) -> T {
    switch x {
    case let d as Double:
        return pow(d, e as! Double) as Double as! T
    case let f as Float:
        return powf(f, e as! Float) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return powl(f80, e as! Float80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func erfc1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return erfc(d) as Double as! T
    case let f as Float:
        return erfcf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return erfcl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func erf1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return erf(d) as Double as! T
    case let f as Float:
        return erff(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return erfl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}


internal func sign1<T: SSFloatingPoint>(_ x: T) -> T {
    return x < 0 ? -1 : 1
}

internal func sin1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return sin(d) as Double as! T
    case let f as Float:
        return sinf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return sinl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}
internal func cos1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return cos(d) as Double as! T
    case let f as Float:
        return cosf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return cosl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func tan1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return tan(d) as Double as! T
    case let f as Float:
        return tanf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return tanl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}
internal func tanh1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return tanh(d) as Double as! T
    case let f as Float:
        return tanhf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return tanhl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}
internal func cot1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return 1.0 / tan(d) as Double as! T
    case let f as Float:
        return 1.0 / tanf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return 1.0 / tanl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func atan1<T: SSFloatingPoint>(_ x: T) -> T {
    switch x {
    case let d as Double:
        return atan(d) as Double as! T
    case let f as Float:
        return atanf(f) as Float as! T
        #if arch(x86_64)
    case let f80 as Float80:
        return atanl(f80) as Float80 as! T
        #endif
    default:
        return T.nan
    }
}

internal func atan21<T: SSFloatingPoint>(_ x: T, _ y: T) -> T {
    switch x {
    case let d as Double:
        switch y {
        case let yd as Double:
            return atan2(d, yd) as Double as! T
        default:
            return T.nan
        }
    case let f as Float:
        switch y {
        case let yf as Float:
            return atan2f(f, yf) as Float as! T
        default:
            return T.nan
        }
        #if arch(x86_64)
    case let f80 as Float80:
        switch y {
        case let yf80 as Float80:
            return atan2l(f80, yf80) as Float80 as! T
        default:
            return T.nan
        }
        #endif
    default:
        return T.nan
    }
}

internal func sign<T: SSFloatingPoint>(_ x: T) -> T {
    if x.sign == .minus {
        return -1.0 as! T
    }
    else {
        return 1.0 as! T
    }
}


internal func fmin1<T: SSFloatingPoint>(_ x: T, _ y: T) -> T {
    switch x {
    case let d as Double:
        switch y {
        case let yd as Double:
            return fmin(d, yd) as Double as! T
        default:
            return T.nan
        }
    case let f as Float:
        switch y {
        case let yf as Float:
            return fminf(f, yf) as Float as! T
        default:
            return T.nan
        }
        #if arch(x86_64)
    case let f80 as Float80:
        switch y {
        case let yf80 as Float80:
            return fminl(f80, yf80) as Float80 as! T
        default:
            return T.nan
        }
        #endif
    default:
        return T.nan
    }
}

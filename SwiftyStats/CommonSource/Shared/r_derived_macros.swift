//
//  Created by VT on 20.07.18.
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

/*************************************************************/
/* The R macros as free swift functions                      */
/*************************************************************/


/*
 * Compute the log of a sum from logs of terms, i.e.,
 *
 *     log (exp (logx) + exp (logy))
 *
 * without causing overflows and without throwing away large handfuls
 * of accuracy.
 */
internal func logspace_add<T: SSFloatingPoint>(_ logx: T, _ logy: T) -> T {
    return max(logx, logy) + log1p1(exp1(-abs(logx - logy)))
}


/*
 * Compute the log of a difference from logs of terms, i.e.,
 *
 *     log (exp (logx) - exp (logy))
 *
 * without causing overflows and without throwing away large handfuls
 * of accuracy.
 */
internal func logspace_sub<T: SSFloatingPoint>(_ logx: T, _ logy: T, _ log_p: Bool) -> T {
    return logx + r_log1_exp(x: logy - logx, log_p: log_p)
}


internal func r_d__1<T: SSFloatingPoint>(log_p: Bool) -> T {
    if log_p {
        return T.zero
    }
    else {
        return T.one
    }
}
internal func r_d__0<T: SSFloatingPoint>(log_p: Bool) -> T {
    if log_p {
        return -T.infinity
    }
    else {
        return T.zero
    }
}


internal func r_log1_exp<T: SSFloatingPoint>(x: T, log_p: Bool) -> T {
    if x > -T.ln2 {
        return log1(-expm11(x))
    }
    else {
        return log1p1(-exp1(x))
    }
}

internal func rd_exp<T: SSFloatingPoint>(x: T, log_p: Bool) -> T {
    if log_p {
        return x
    }
    else {
        return exp1(x)
    }
}


internal func r_dt_0<T: SSFloatingPoint>(tail: SSCDFTail, log_p: Bool) -> T {
    if tail == .lower {
        return r_d__0(log_p: log_p)
    }
    else {
        return r_d__1(log_p: log_p)
    }
}

internal func r_dt_1<T: SSFloatingPoint>(tail: SSCDFTail, log_p: Bool) -> T {
    if tail == .lower {
        return r_d__1(log_p: log_p)
    }
    else {
        return r_d__0(log_p: log_p)
    }
}


internal func r_d_val<T: SSFloatingPoint>(_ x: T, log_p: Bool) -> T {
    if log_p {
        return log1(x)
    }
    else {
        return x
    }
}

internal func r_d_Clog<T: SSFloatingPoint>(x: T, log_p: Bool) -> T {
    if log_p {
        return log1p1(-x)
    }
    else {
        return (T.half - x + T.half)
    }
}

internal func r_dt_val<T: SSFloatingPoint>(x: T, tail: SSCDFTail, log_p: Bool) -> T {
    if tail == .lower {
        return r_d_val(x, log_p: log_p)
    }
    else {
        return r_d_Clog(x: x, log_p: log_p)
    }
}

internal func r_d_Lval<T: SSFloatingPoint>(x: T, tail: SSCDFTail) -> T {
    if tail == .lower {
        return x
    }
    else {
        return T.half - x + T.half
    }
}


internal func r_dt_qIv<T: SSFloatingPoint>(x: T, tail: SSCDFTail, log_p: Bool) -> T {
    if log_p {
        return tail == .lower ? exp1(x) : -expm11(x)
    }
    else {
        return r_d_Lval(x: x, tail: tail)
    }
}

internal func r_q_p01_boundaries<T: SSFloatingPoint>(p: T, left: T, right: T, tail: SSCDFTail! = .lower,  _ log_p: Bool! = false) -> T? {
    if log_p {
        if p > 0 {
            return T.nan
        }
        else  if p.isZero {
            return tail == .lower ? right : left
        }
        else if p == -T.infinity {
            return tail == .lower ? left : right
        }
    }
    else {
        if p < 0 || p > 1 {
            return T.nan
        }
        else if p.isZero {
            return tail == .lower ? left : right
        }
        else if p == 1 {
            return tail == .lower ? right : left
        }
    }
    return nil
}


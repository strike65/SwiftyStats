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

internal func r_dt_0(tail: SSCDFTail, log_p: Bool) -> Double {
    if tail == .lower {
        if log_p {
            return -Double.infinity
        }
        else {
            return 0.0
        }
    }
    else {
        if log_p {
            return 0.0
        }
        else {
            return 1.0
        }
    }
}

internal func r_dt_1(tail: SSCDFTail, log_p: Bool) -> Double {
    if tail == .lower {
        if log_p {
            return 0.0
        }
        else {
            return 1.0
        }
    }
    else {
        if log_p {
            return -Double.infinity
        }
        else {
            return 0.0
        }
    }
}


internal func r_d_val(_ x: Double, log_p: Bool) -> Double {
    if log_p {
        return log(x)
    }
    else {
        return x
    }
}

internal func r_d_clog(x: Double, log_p: Bool) -> Double {
    if log_p {
        return log1p(-x)
    }
    else {
        return (0.5 - x + 0.5)
    }
}

internal func r_dt_val(x: Double, tail: SSCDFTail, log_p: Bool) -> Double {
    if tail == .lower {
        return r_d_val(x, log_p: log_p)
    }
    else {
        return r_d_clog(x: x, log_p: log_p)
    }
}

internal func r_d_lval(x: Double, tail: SSCDFTail) -> Double {
    return (tail == .lower) ? x : (0.5 - x + 0.5)
}


internal func r_dt_qIv(x: Double, tail: SSCDFTail, log_p: Bool) -> Double {
    if log_p {
        return tail == .lower ? exp(x) : -expm1(x)
    }
    else {
        return r_d_lval(x: x, tail: tail)
    }
}

internal func r_q_p01_boundaries(p: Double!, left: Double!, right: Double!, tail: SSCDFTail! = .lower,  _ log_p: Bool! = false) -> Double? {
    if log_p {
        if p > 0.0 {
            return Double.nan
        }
        else  if p.isZero {
            return tail == .lower ? right : left
        }
        else if p == -Double.infinity {
            return tail == .lower ? left : right
        }
    }
    else {
        if p < 0.0 || p > 1.0 {
            return Double.nan
        }
        else if p.isZero {
            return tail == .lower ? left : right
        }
        else if p == 1.0 {
            return tail == .lower ? right : left
        }
    }
    return nil
}


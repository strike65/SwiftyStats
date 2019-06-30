//
//  Created by VT on 20.07.18.
//  Copyright © 2018 strike65. All rights reserved.
//
/*
 Copyright (2017-2019) strike65
 
 GNU GPL 3+
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, version 3 of the License.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 */

import Foundation

/*************************************************************/
/* The R macros as free swift functions                      */
/*************************************************************/


extension Helpers {
    
    /*
     * Compute the log of a sum from logs of terms, i.e.,
     *
     *     log (exp (logx) + exp (logy))
     *
     * without causing overflows and without throwing away large handfuls
     * of accuracy.
     */
    internal static func logspace_add<T: SSFloatingPoint>(_ logx: T, _ logy: T) -> T {
        return max(logx, logy) + SSMath.log1p1(SSMath.exp1(-abs(logx - logy)))
    }
    
    
    /*
     * Compute the log of a difference from logs of terms, i.e.,
     *
     *     log (exp (logx) - exp (logy))
     *
     * without causing overflows and without throwing away large handfuls
     * of accuracy.
     */
    internal static func logspace_sub<T: SSFloatingPoint>(_ logx: T, _ logy: T, _ log_p: Bool) -> T {
        return logx + r_log1_exp(x: logy - logx, log_p: log_p)
    }
    
    
    internal static func r_d__1<T: SSFloatingPoint>(log_p: Bool) -> T {
        if log_p {
            return T.zero
        }
        else {
            return T.one
        }
    }
    internal static func r_d__0<T: SSFloatingPoint>(log_p: Bool) -> T {
        if log_p {
            return -T.infinity
        }
        else {
            return T.zero
        }
    }
    
    
    internal static func r_log1_exp<T: SSFloatingPoint>(x: T, log_p: Bool) -> T {
        if x > -T.ln2 {
            return SSMath.log1(-SSMath.expm11(x))
        }
        else {
            return SSMath.log1p1(-SSMath.exp1(x))
        }
    }
    
    internal static func rd_exp<T: SSFloatingPoint>(x: T, log_p: Bool) -> T {
        if log_p {
            return x
        }
        else {
            return SSMath.exp1(x)
        }
    }
    
    
    internal static func r_dt_0<T: SSFloatingPoint>(tail: SSCDFTail, log_p: Bool) -> T {
        if tail == .lower {
            return r_d__0(log_p: log_p)
        }
        else {
            return r_d__1(log_p: log_p)
        }
    }
    
    internal static func r_dt_1<T: SSFloatingPoint>(tail: SSCDFTail, log_p: Bool) -> T {
        if tail == .lower {
            return r_d__1(log_p: log_p)
        }
        else {
            return r_d__0(log_p: log_p)
        }
    }
    
    
    internal static func r_d_val<T: SSFloatingPoint>(_ x: T, log_p: Bool) -> T {
        if log_p {
            return SSMath.log1(x)
        }
        else {
            return x
        }
    }
    
    internal static func r_d_Clog<T: SSFloatingPoint>(x: T, log_p: Bool) -> T {
        if log_p {
            return SSMath.log1p1(-x)
        }
        else {
            return (T.half - x + T.half)
        }
    }
    
    internal static func r_dt_val<T: SSFloatingPoint>(x: T, tail: SSCDFTail, log_p: Bool) -> T {
        if tail == .lower {
            return r_d_val(x, log_p: log_p)
        }
        else {
            return r_d_Clog(x: x, log_p: log_p)
        }
    }
    
    internal static func r_d_Lval<T: SSFloatingPoint>(x: T, tail: SSCDFTail) -> T {
        if tail == .lower {
            return x
        }
        else {
            return T.half - x + T.half
        }
    }
    
    
    internal static func r_dt_qIv<T: SSFloatingPoint>(x: T, tail: SSCDFTail, log_p: Bool) -> T {
        if log_p {
            return tail == .lower ? SSMath.exp1(x) : -SSMath.expm11(x)
        }
        else {
            return r_d_Lval(x: x, tail: tail)
        }
    }
    
    internal static func r_q_p01_boundaries<T: SSFloatingPoint>(p: T, left: T, right: T, tail: SSCDFTail! = .lower,  _ log_p: Bool! = false) -> T? {
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
    
}

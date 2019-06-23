/*
 Copyright (c) 2018 strike65
 
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

/*                            chbevl.c
 *
 *    Evaluate Chebyshev series
 *
 *
 *
 * SYNOPSIS:
 *
 * int N;
 * double x, y, coef[N], chebevl();
 *
 * y = chbevl( x, coef, N );
 *
 *
 *
 * DESCRIPTION:
 *
 * Evaluates the series
 *
 *        N-1
 *         - '
 *  y  =   >   coef[i] T (x/2)
 *         -            i
 *        i=0
 *
 * of Chebyshev polynomials Ti at argument x/2.
 *
 * Coefficients are stored in reverse order, i.e. the zero
 * order term is last in the array.  Note N is the number of
 * coefficients, not the order.
 *
 * If coefficients are for the interval a to b, x must
 * have been transformed to x -> 2(2x - b - a)/(b-a) before
 * entering the routine.  This maps x from (a, b) to (-1, 1),
 * over which the Chebyshev polynomials are defined.
 *
 * If the coefficients are for the inverted interval, in
 * which (a, b) is mapped to (1/b, 1/a), the transformation
 * required is x -> 2(2ab/x - b - a)/(b-a).  If b is infinity,
 * this becomes x -> 4a/x - 1.
 *
 *
 *
 * SPEED:
 *
 * Taking advantage of the recurrence properties of the
 * Chebyshev polynomials, the routine requires one more
 * addition per loop than evaluating a nested polynomial of
 * the same degree.
 *
 */
/*                            chbevl.c    */

/*
 with kind permission
 Copyright 1985, 1987 by Stephen L. Moshier
 Copyright 2018 strike65
 */

/*
 Cehbyshev.swift
 */

extension SSSpecialFunctions.Helper {
    internal static func chebyshevEval<FPT: SSFloatingPoint & Codable>(x: FPT, array: [FPT], n: Int) -> FPT {
        var b0, b1, b2: FPT
        var i: Int = n - 1
        var k: Int = 0
        b0 = array[k]
        k += 1
        b1 = 0
        
        repeat {
            b2 = b1;
            b1 = b0;
            b0 = x * b1  -  b2  + array[k]
            k += 1
            i -= 1
        } while( i > 0);
        
        return( FPT.half * (b0 - b2) )
    }
}

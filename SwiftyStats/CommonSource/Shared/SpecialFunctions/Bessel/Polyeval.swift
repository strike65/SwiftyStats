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

/*                            polevl.c
 *                            p1evl.c
 *
 *    Evaluate polynomial
 *
 *
 *
 * SYNOPSIS:
 *
 * int N;
 * double x, y, coef[N+1], polevl[];
 *
 * y = polevl( x, coef, N );
 *
 *
 *
 * DESCRIPTION:
 *
 * Evaluates polynomial of degree N:
 *
 *                     2          N
 * y  =  C  + C x + C x  +...+ C x
 *        0    1     2          N
 *
 * Coefficients are stored in reverse order:
 *
 * coef[0] = C  , ..., coef[N] = C  .
 *            N                   0
 *
 *  The function p1evl() assumes that coef[N] = 1.0 and is
 * omitted from the array.  Its calling arguments are
 * otherwise the same as polevl().
 *
 *
 * SPEED:
 *
 * In the interest of speed, there are no checks for out
 * of bounds arithmetic.  This routine is used by most of
 * the functions in the library.  Depending on available
 * equipment features, the user may wish to rewrite the
 * program in microcode or assembly language.
 *
 */


/*
 Cephes Math Library Release 2.1:  December, 1988
 Copyright 1984, 1987, 1988 by Stephen L. Moshier
 Direct inquiries to 30 Frost Street, Cambridge, MA 02140
 */

extension SSSpecialFunctions.Helper {
    
    internal static func polyeval<FPT: SSFloatingPoint>( x: FPT, coef: [FPT], n: Int ) -> FPT {
        var ans: FPT
        var i: Int
        
        var k: Int = 0
        ans = coef[k]
        k += 1
        i = n
        
        repeat {
            ans = ans * x  +  coef[k]
            k += 1
            i -= 1
        } while( i > 0 )
        
        return ans
    }
    
    /*                            p1evl()    */
    /*                                          N
     * Evaluate polynomial when coefficient of x  is 1.0.
     * Otherwise same as polevl.
     */
    
    internal static func poly1eval<FPT: SSFloatingPoint>( x: FPT, coef: [FPT], n: Int! ) -> FPT {
        var ans: FPT
        var i: Int
        
        var k: Int = 0
        ans = x + coef[k]
        k += 1
        i = n - 1
        
        repeat {
            ans = ans * x  + coef[k]
            k += 1
            i -= 1
        } while ( i > 0 )
        
        return ans
    }
}

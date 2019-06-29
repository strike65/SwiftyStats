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

extension SSSpecialFunctions {
    
    /// Returns the real AiryAi and AiryAi'
    /// - Parameter x: x
    /// - Note:
    /// -- Algorithm 838: Airy Functions. ACM Transactions on Mathematical Software, Vol. 30, No. 4, December 2004.
    ///
    /// -- FABIJONAS, LOZIER, OLVER: Computation of Complex Airy Functions and Their Zeros Using Asymptotics and the Differential EquationACM Transactions on Mathematical Software, Vol. 30, No. 4, December 2004, Pages 471–490
    /// - Remark:
    /// Errors (Double)
    ///
    /// for -200 <= x <= 200, step 0.5
    ///
    /// -- min. abs. Error: 0.0, max. abs. Error: 6.153844794853924e-14
    ///
    /// -- min. rel. Error: 0.0, max. rel. Error: 2.6386806271584575e-11
    ///
    /// for Ai': -200 <= x <= 200:
    ///
    /// -- min. abs. Error: 0.0, max. abs. Error: 7.327471962526033e-13
    ///
    /// -- min. rel. Error: 0.0, max. rel. Error: 3.0119944005469907e-10
    internal static func airyAi<T:SSFloatingPoint>(x: T) -> (ai: T, dai: T, error: Int) {
        var ans: (ai: T, dai: T, error: Int)
        let airy: Airy<T> = Airy<T>.init()
        ans = airy.airy_air(x: x)
        return ans
    }
    
    /// Returns the real AiryBi and AiryBi'
    /// - Parameter x: x
    /// - Note:
    /// -- Algorithm 838: Airy Functions. ACM Transactions on Mathematical Software, Vol. 30, No. 4, December 2004.
    ///
    /// -- FABIJONAS, LOZIER, OLVER: Computation of Complex Airy Functions and Their Zeros Using Asymptotics and the Differential EquationACM Transactions on Mathematical Software, Vol. 30, No. 4, December 2004, Pages 471–490
    /// - Remark:
    /// Errors (Double)
    ///
    /// for -200 <= x <= 2, step: 0.5:
    ///
    /// -- min. abs. Error: 0.0, max. abs. Error: 5.259681579161679e-14
    ///
    /// -- rel. Error: 0.0, max. rel. Error: 6.261649779273941e-12
    ///
    /// for Ai': -200 <= x <= 2:
    ///
    /// -- min. abs. Error: 0.0, max. abs. Error: 8.637326964766601e-13
    ///
    /// -- min. rel. Error: 0.0, max. rel. Error: 2.658098530832e-11
    internal static func airyBi<T:SSFloatingPoint>(x: T) -> (bi: T, dbi: T, error: Int) {
        var ans: (bi: T, dbi: T, error: Int)
        let airy: Airy<T> = Airy<T>.init()
        ans = airy.airy_bir(x: x)
        return ans
    }
    
}

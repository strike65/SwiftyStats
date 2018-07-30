//
//  SSConstants.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 03.07.17.
//
/*
 Copyright (c) 2017 Volker Thieme
 
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

 /*
 Some numerical constants computed by Mathematica (R). Originaly defined for ObjC version of the framework
 */

/// The extension for archives
internal let SSExamineFileExtension = "SSexamine"

/// The current file version for archiving
internal let SSStatisticsFileVersionString: String = "1.0.0"

/// Returns 2 / pi
internal let  TWOOPI : Double = 0.636619772367581343075535053490057448139
/// Returns pi / 4
internal let  PIQUART : Double =			0.785398163397448309615660845819875721049
/// Returns 3 Pi / 4
internal let  THREEPIQUART : Double = 2.356194490192344928846982537459627163148
/// Returns Euler's gamma
internal let  EULERGAMMA : Double = 0.577215664901532860606512090082402431042
/// Returns sqrt(pi)
internal let  SQRTPI : Double = 1.772453850905516027298167483341145182798
#if arch(arm) || arch(arm64)
/// Returns pi
internal let  PIL : Double = 3.141592653589793238462643383279502884197
#else
/// Returns pi
internal let  PIL : Float80 = 3.141592653589793238462643383279502884197
#endif
/// Returns sqrt(2)
internal let  SQRTTWO : Double = 1.414213562373095048801688724209698078570
/// Returns sqrt(1/(2 * pi))
internal let  SQRT2PIINV : Double = 0.398942280401432677939946059934381868476
/// Returns sqrt(2 / pi)
internal let SQRT2DIVPI: Double = 0.797884560802865355879892119868763736952
#if arch(arm) || arch(arm64)
internal let SQRT2DIVPIL: Double = 0.7978845608028653558798921198687637369517172623298693153318516593
#else
internal let SQRT2DIVPIL: Float80 = 0.7978845608028653558798921198687637369517172623298693153318516593
#endif
// Returns ln(sqrt(pi))
internal let LNSQRTPI: Double = 0.5723649429247000870717136756765293558236474064576557857568115357
/// Returns sqrt(2*pi)
internal let  SQRT2PI : Double = 2.506628274631000502415765284811045253010
/// Returns log(sqrt(2*pi))
internal let  LOGSQRT2PI : Double = 0.918938533204672741780329736405617639861
/// Returns pi /2
internal let  PIHALF : Double = 1.570796326794896619231321691639751442099
/// Returns sqrt(pi/2)
internal let  SQRTPIHALF : Double =	0.886226925452758013649083741670572591399
/// Returns log(2)
internal let  LOG2 : Double = 0.693147180559945309417232121458176568076
/// Returns 1/12 (one over twelve)
internal let  OOTW : Double = 0.083333333333333333333333333333333333333
/// Returns 1/18 (one over eighteen)
internal let  OOEI : Double = 0.055555555555555555555555555555555555556
/// Returns 1/24 (one over twentyfour)
internal let  OOTWF : Double = 0.041666666666666666666666666666666666667
/// Returns 2 * pi
internal let  TWOPI : Double = 6.283185307179586476925286766559005768394
/// Returns pi * pi
internal let  PISQUARED : Double = 9.869604401089358618834490999876151135314
/// Returns 1 / (2 pi)
internal let  OO2PI : Double = 0.159154943091895335768883763372514362035
/// Returns log(pi)
internal let  LOGPI : Double = 1.144729885849400174143427351353058711647
/// Returns 1/ pi
internal let  OOPI : Double = 0.318309886183790671537767526745028724069
/// Returns sqrt(3)
internal let  SQRT3 : Double = 1.732050807568877293527446341505872366943
/// Returns 1 / sqrt(pi)
internal let  OOSQRTPI : Double = 0.564189583547756286948079451560772585844
/// Returns 1 / 3
internal let  OO3 : Double =	0.333333333333333333333333333333333333333
/// Returns 1/ 6
internal let  OO6 : Double = 0.166666666666666666666666666666666666667
/// Returns 2/3
internal let  TWOO3 : Double = 0.666666666666666666666666666666666666666
/// Returns 2^(1/4)
internal let  TWOEXPQUART : Double =	1.189207115002721066717499970560475915293

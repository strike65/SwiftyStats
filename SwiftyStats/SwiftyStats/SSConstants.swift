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
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.

 */

import Foundation

 /*
 Some numerical constants computed by Mathematica (R). Originaly defined for ObjC version of the framework
 */

// TODO:
// make constants availablr as Float80 (make it sense?)


/// The extension for archives
public let SSExamineFileExtension = "SSexamine"

/// The current file version for archiving
public let SSStatisticsFileVersionString: String = "1.0.0"

/// 2 / pi
public let  TWOOPI : Double = 0.636619772367581343075535053490057448139;
/// pi / 4
public let  PIQUART : Double =			0.785398163397448309615660845819875721049;
/// 3 Pi / 4
public let  THREEPIQUART : Double = 2.356194490192344928846982537459627163148;
/// Euler's gamma
public let  EULERGAMMA : Double = 0.577215664901532860606512090082402431042;
/// sqrt(pi)
public let  SQRTPI : Double = 1.772453850905516027298167483341145182798;
/// pi
public let  PIL : Float80 = 3.141592653589793238462643383279502884197;
/// sqrt(2)
public let  SQRTTWO : Double = 1.414213562373095048801688724209698078570;
/// sqrt(1/(2 * pi))
public let  SQRT2PIINV : Double = 0.398942280401432677939946059934381868476;
/// sqrt(2*pi)
public let  SQRT2PI : Double = 2.506628274631000502415765284811045253010;
/// log(sqrt(2*pi))
public let  LOGSQRT2PI : Double = 0.918938533204672741780329736405617639861;
/// pi /2
public let  PIHALF : Double = 1.570796326794896619231321691639751442099;
/// sqrt(pi/2)
public let  SQRTPIHALF : Double =	0.886226925452758013649083741670572591399;
/// log(2)
public let  LOG2 : Double = 0.693147180559945309417232121458176568076;
/// 1/12 (one over twelve)
public let  OOTW : Double = 0.083333333333333333333333333333333333333;
/// 1/18 (one over eighteen)
public let  OOEI : Double = 0.055555555555555555555555555555555555556;
/// 1/24 (one over twentyfour)
public let  OOTWF : Double = 0.041666666666666666666666666666666666667;
/// 2 * pi
public let  TWOPI : Double = 6.283185307179586476925286766559005768394;
/// pi * pi
public let  PISQUARED : Double = 9.869604401089358618834490999876151135314;
/// 1 / (2 pi)
public let  OO2PI : Double =		0.159154943091895335768883763372514362035;
/// log(pi)
public let  LOGPI : Double = 1.144729885849400174143427351353058711647;
/// 1/ pi
public let  OOPI : Double = 0.318309886183790671537767526745028724069;
/// sqrt(3)
public let  SQRT3 : Double = 1.732050807568877293527446341505872366943;
/// 1 / sqrt(pi)
public let  OOSQRTPI : Double = 0.564189583547756286948079451560772585844;
/// 1 / 3
public let  OO3 : Double =	0.333333333333333333333333333333333333333;
/// 1/ 6
public let  OO6 : Double = 0.166666666666666666666666666666666666667;
/// 2/3
public let  TWOO3 : Double = 0.666666666666666666666666666666666666666;
/// 2^(1/4)
public let  TWOEXPQUART : Double =	1.189207115002721066717499970560475915293;

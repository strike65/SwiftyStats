//
//  SSProbabilityDistributions.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 18.07.17.
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
import os.log

/// Provides some of the commonest probability distributions. In general, functions are prefixed by "pdf", "cdf", "quantile" for "probability density function", "cumulative density function" and "inverse cumulative density" function respectively. Probablity distributions in general are defined in relatively narrow conditions expressed in terms of certain parameters such as "degree of freedom", "shape" or "mean". Sometimes it is possible, that a particular distribution isn't defined for a parameter provided.
/// <img src="../img/pdf_cdf_def.png" alt="">
/// ### Important ###
/// This class throws an error object in such circumstances. Therefore the user must embed any call of such functions in a "do-catch" statement.

public class SSProbabilityDistributions {

// MARK: GAUSSIAN
    
    /// Returns the CDF of a Gaussian distribution
    /// <img src="../img/Gaussian_def.png" alt="">
    /// - Parameter x: x
    /// - Parameter m: Mean
    /// - Parameter sd: Standard deviation
    /// - Throws: SSSwiftyStatsError if sd <= 0.0
    public class func cdfNormalDist(x: Double!, mean m: Double!, standardDeviation sd: Double!) throws -> Double {
        if sd <= 0.0 {
            os_log("sd is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        let u = (x - m) / sd
        return SSProbabilityDistributions.cdfStandardNormalDist(u: u)
    }

    /// Returns the CDF of a Gaussian distribution
    /// - Parameter x: x
    /// - Parameter m: Mean
    /// - Parameter v: Variance
    /// - Throws: SSSwiftyStatsError if v <= 0.0
    public class func cdfNormalDist(x: Double!, mean m: Double!, variance v: Double!) throws -> Double {
        if v <= 0.0 {
            os_log("v is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        let u = (x - m) / sqrt(v)
        return SSProbabilityDistributions.cdfStandardNormalDist(u: u)
    }
    
    /// Returns the CDF of the standard Gaussian distribution (mean = 0.0, standard deviation = 1.0)
    /// - Parameter u: Standardized variate (u = (x - mean)/sd)
    public class func cdfStandardNormalDist(u: Double!) -> Double {
        return 0.5 * (1.0 + erf(u / SQRTTWO))
    }
    
    /// Returns the PDF of a Gaussian distribution
    /// - Parameter m: Mean
    /// - Parameter sd: Standard deviation
    /// - Throws: SSSwiftyStatsError if sd <= 0.0
    public class func pdfNormalDist(x: Double!, mean m: Double!, standardDeviation sd: Double!) throws -> Double {
        if sd <= 0.0 {
            os_log("sd is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        return 1.0 / (sd * SQRT2PI) * exp(-1.0 * pow(x - m, 2.0) / (2.0 * sd * sd))
    }
    
    /// Returns the PDF of a Gaussian distribution
    /// - Parameter x: x
    /// - Parameter m: Mean
    /// - Parameter v: Variance
    /// - Throws: SSSwiftyStatsError if v <= 0.0
    public class func pdfNormalDist(x: Double!, mean m: Double!, variance v: Double!) throws -> Double {
        if v <= 0.0 {
            os_log("v is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        return 1.0 / (sqrt(v) * SQRT2PI) * exp(-1.0 * pow(x - m, 2.0) / (2.0 * v))
    }
    
    /// Returns the PDF of the standard Gaussian distribution (mean = 0.0, standard deviation = 1.0)
    /// - Parameter u: Standardized variate (u = (x - mean)/sd)
    public class func pdfStandardNormalDist(u: Double!) -> Double {
        return SQRT2PIINV * exp(-1.0 * u * u / 2.0)
    }
    
    /*
     REAL FUNCTION PPND7 (P, IFAULT)
     C
     C	ALGORITHM AS241  APPL. STATIST. (1988) VOL. 37, NO. 3, 477-
     C	484.
     C
     C	Produces the normal deviate Z corresponding to a given lower
     C	tail area of P; Z is accurate to about 1 part in 10**7.
     C
     C	The hash sums below are the sums of the mantissas of the
     C	coefficients.   They are included for use in checking
     C	transcription.
     C
     REAL ZERO, ONE, HALF, SPLIT1, SPLIT2, CONST1, CONST2, A0, A1,
     *		A2, A3, B1, B2, B3, C0, C1, C2, C3, D1, D2, E0, E1, E2,
     *		E3, F1, F2, P, Q, R
     PARAMETER (ZERO = 0.0, ONE = 1.0, HALF = 0.5,
     *		SPLIT1 = 0.425, SPLIT2 = 5.0,
     *		CONST1 = 0.180625, CONST2 = 1.6)
     C
     C	Coefficients for P close to 0.5
     C
     PARAMETER (A0 = 3.38713 27179E+00, A1 = 5.04342 71938E+01,
     *		   A2 = 1.59291 13202E+02, A3 = 5.91093 74720E+01,
     *		   B1 = 1.78951 69469E+01, B2 = 7.87577 57664E+01,
     *		   B3 = 6.71875 63600E+01)
     C	HASH SUM AB    32.31845 77772
     C
     C	Coefficients for P not close to 0, 0.5 or 1.
     C
     PARAMETER (C0 = 1.42343 72777E+00, C1 = 2.75681 53900E+00,
     *		   C2 = 1.30672 84816E+00, C3 = 1.70238 21103E-01,
     *		   D1 = 7.37001 64250E-01, D2 = 1.20211 32975E-01)
     C	HASH SUM CD    15.76149 29821
     C
     C	Coefficients for P near 0 or 1.
     C
     PARAMETER (E0 = 6.65790 51150E+00, E1 = 3.08122 63860E+00,
     *		   E2 = 4.28682 94337E-01, E3 = 1.73372 03997E-02,
     *		   F1 = 2.41978 94225E-01, F2 = 1.22582 02635E-02)
     C	HASH SUM EF    19.40529 10204
     C
     IFAULT = 0
     Q = P - HALF
     IF (ABS(Q) .LE. SPLIT1) THEN
     R = CONST1 - Q * Q
     PPND7 = Q * (((A3 * R + A2) * R + A1) * R + A0) /
     *		      (((B3 * R + B2) * R + B1) * R + ONE)
     RETURN
     ELSE
     IF (Q .LT. ZERO) THEN
	    R = P
     ELSE
	    R = ONE - P
     END IF
     IF (R .LE. ZERO) THEN
	    IFAULT = 1
	    PPND7 = ZERO
	    RETURN
     END IF
     R = SQRT(-LOG(R))
     IF (R .LE. SPLIT2) THEN
	    R = R - CONST2
	    PPND7 = (((C3 * R + C2) * R + C1) * R + C0) /
     *		     ((D2 * R + D1) * R + ONE)
     ELSE
	    R = R - SPLIT2
	    PPND7 = (((E3 * R + E2) * R + E1) * R + E0) /
     *		     ((F2 * R + F1) * R + ONE)
     END IF
     IF (Q .LT. ZERO) PPND7 = - PPND7
     RETURN
     END IF
     END
     C
     C
     DOUBLE PRECISION FUNCTION PPND16 (P, IFAULT)
     C
     C	ALGORITHM AS241  APPL. STATIST. (1988) VOL. 37, NO. 3
     C
     C	Produces the normal deviate Z corresponding to a given lower
     C	tail area of P; Z is accurate to about 1 part in 10**16.
     C
     C	The hash sums below are the sums of the mantissas of the
     C	coefficients.   They are included for use in checking
     C	transcription.
     C
     DOUBLE PRECISION ZERO, ONE, HALF, SPLIT1, SPLIT2, CONST1,
     *		CONST2, A0, A1,	A2, A3, A4, A5, A6, A7, B1, B2, B3,
     *          B4, B5, B6, B7,
     *		C0, C1, C2, C3, C4, C5, C6, C7,	D1, D2, D3, D4, D5,
     *		D6, D7, E0, E1, E2, E3, E4, E5, E6, E7, F1, F2, F3,
     *		F4, F5, F6, F7, P, Q, R
     PARAMETER (ZERO = 0.D0, ONE = 1.D0, HALF = 0.5D0,
     *		SPLIT1 = 0.425D0, SPLIT2 = 5.D0,
     *		CONST1 = 0.180625D0, CONST2 = 1.6D0)
     C
     C	Coefficients for P close to 0.5
     C
     PARAMETER (A0 = 3.38713 28727 96366 6080D0,
     *		   A1 = 1.33141 66789 17843 7745D+2,
     *		   A2 = 1.97159 09503 06551 4427D+3,
     *		   A3 = 1.37316 93765 50946 1125D+4,
     *		   A4 = 4.59219 53931 54987 1457D+4,
     *		   A5 = 6.72657 70927 00870 0853D+4,
     *		   A6 = 3.34305 75583 58812 8105D+4,
     *		   A7 = 2.50908 09287 30122 6727D+3,
     *		   B1 = 4.23133 30701 60091 1252D+1,
     *		   B2 = 6.87187 00749 20579 0830D+2,
     *		   B3 = 5.39419 60214 24751 1077D+3,
     *		   B4 = 2.12137 94301 58659 5867D+4,
     *		   B5 = 3.93078 95800 09271 0610D+4,
     *		   B6 = 2.87290 85735 72194 2674D+4,
     *		   B7 = 5.22649 52788 52854 5610D+3)
     C	HASH SUM AB    55.88319 28806 14901 4439
     C
     C	Coefficients for P not close to 0, 0.5 or 1.
     C
     PARAMETER (C0 = 1.42343 71107 49683 57734D0,
     *		   C1 = 4.63033 78461 56545 29590D0,
     *		   C2 = 5.76949 72214 60691 40550D0,
     *		   C3 = 3.64784 83247 63204 60504D0,
     *		   C4 = 1.27045 82524 52368 38258D0,
     *		   C5 = 2.41780 72517 74506 11770D-1,
     *             C6 = 2.27238 44989 26918 45833D-2,
     *		   C7 = 7.74545 01427 83414 07640D-4,
     *		   D1 = 2.05319 16266 37758 82187D0,
     *		   D2 = 1.67638 48301 83803 84940D0,
     *		   D3 = 6.89767 33498 51000 04550D-1,
     *		   D4 = 1.48103 97642 74800 74590D-1,
     *		   D5 = 1.51986 66563 61645 71966D-2,
     *		   D6 = 5.47593 80849 95344 94600D-4,
     *		   D7 = 1.05075 00716 44416 84324D-9)
     C	HASH SUM CD    49.33206 50330 16102 89036
     C
     C	Coefficients for P near 0 or 1.
     C
     PARAMETER (E0 = 6.65790 46435 01103 77720D0,
     *		   E1 = 5.46378 49111 64114 36990D0,
     *		   E2 = 1.78482 65399 17291 33580D0,
     *		   E3 = 2.96560 57182 85048 91230D-1,
     *		   E4 = 2.65321 89526 57612 30930D-2,
     *		   E5 = 1.24266 09473 88078 43860D-3,
     *		   E6 = 2.71155 55687 43487 57815D-5,
     *		   E7 = 2.01033 43992 92288 13265D-7,
     *		   F1 = 5.99832 20655 58879 37690D-1,
     *		   F2 = 1.36929 88092 27358 05310D-1,
     *		   F3 = 1.48753 61290 85061 48525D-2,
     *		   F4 = 7.86869 13114 56132 59100D-4,
     *		   F5 = 1.84631 83175 10054 68180D-5,
     *		   F6 = 1.42151 17583 16445 88870D-7,
     *		   F7 = 2.04426 31033 89939 78564D-15)
     C	HASH SUM EF    47.52583 31754 92896 71629
     C
     IFAULT = 0
     Q = P - HALF
     IF (ABS(Q) .LE. SPLIT1) THEN
     R = CONST1 - Q * Q
     PPND16 = Q * (((((((A7 * R + A6) * R + A5) * R + A4) * R + A3)
     *			* R + A2) * R + A1) * R + A0) /
     *		      (((((((B7 * R + B6) * R + B5) * R + B4) * R + B3)
     *			* R + B2) * R + B1) * R + ONE)
     RETURN
     ELSE
     IF (Q .LT. ZERO) THEN
	    R = P
     ELSE
	    R = ONE - P
     END IF
     IF (R .LE. ZERO) THEN
	    IFAULT = 1
	    PPND16 = ZERO
	    RETURN
     END IF
     R = SQRT(-LOG(R))
     IF (R .LE. SPLIT2) THEN
	    R = R - CONST2
	    PPND16 = (((((((C7 * R + C6) * R + C5) * R + C4) * R + C3)
     *			* R + C2) * R + C1) * R + C0) /
     *		     (((((((D7 * R + D6) * R + D5) * R + D4) * R + D3)
     *			* R + D2) * R + D1) * R + ONE)
     ELSE
	    R = R - SPLIT2
	    PPND16 = (((((((E7 * R + E6) * R + E5) * R + E4) * R + E3)
     *			* R + E2) * R + E1) * R + E0) /
     *		     (((((((F7 * R + F6) * R + F5) * R + F4) * R + F3)
     *			* R + F2) * R + F1) * R + ONE)
     END IF
     IF (Q .LT. ZERO) PPND16 = - PPND16
     RETURN
     END IF
     END
    */
    
    /// Returns the quantile function of the standard Gaussian distribution. Uses algorithm AS241 at
    /// http://lib.stat.cmu.edu/apstat/241 (ALGORITHM AS241  APPL. STATIST. (1988) VOL. 37, NO. 3, 477-484.)
    /// - Parameter p: P
    /// - Throws: SSSwiftyStatsError if p < 0.0 or p > 1
    public class func quantileStandardNormalDist(p: Double!) throws -> Double {
        if (p == 0.0) {
            return -Double.infinity
        }
        if p == 1.0 {
            return Double.infinity
        }
        if ((p < 0) || (p > 1.0)) {
            os_log("p is expected to be > 0.0 and < 1.0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        var R: Double
        let ZERO = 0.0
        let ONE = 1.0
        let HALF = 0.5
        let SPLIT1 = 0.425
        let SPLIT2 = 5.0
        let CONST1 = 0.180625
        let CONST2 = 1.6
        let A0 = 3.3871328727963666080
        let A1 = 1.3314166789178437745E02
        let A2 = 1.9715909503065514427E03
        let A3 = 1.3731693765509461125E04
        let A4 = 4.5921953931549871457E04
        let A5 = 6.7265770927008700853E04
        let A6 = 3.3430575583588128105E04
        let A7 = 2.5090809287301226727E03
        let B1 = 4.2313330701600911252E01
        let B2 = 6.8718700749205790830E02
        let B3 = 5.3941960214247511077E03
        let B4 = 2.1213794301586595867E04
        let B5 = 3.9307895800092710610E04
        let B6 = 2.8729085735721942674E04
        let B7 = 5.2264952788528545610E03
        let C0 = 1.42343711074968357734
        let C1 = 4.63033784615654529590
        let C2 = 5.76949722146069140550
        let C3 = 3.64784832476320460504
        let C4 = 1.27045825245236838258
        let C5 = 2.41780725177450611770E-01
        let C6 = 2.27238449892691845833E-02
        let C7 = 7.74545014278341407640E-04
        let D1 = 2.05319162663775882187
        let D2 = 1.67638483018380384940
        let D3 = 6.89767334985100004550E-01
        let D4 = 1.48103976427480074590E-01
        let D5 = 1.51986665636164571966E-02
        let D6 = 5.47593808499534494600E-04
        let D7 = 1.05075007164441684324E-09
        let E0 = 6.65790464350110377720
        let E1 = 5.46378491116411436990
        let E2 = 1.78482653991729133580
        let E3 = 2.96560571828504891230E-01
        let E4 = 2.65321895265761230930E-02
        let E5 = 1.24266094738807843860E-03
        let E6 = 2.71155556874348757815E-05
        let E7 = 2.01033439929228813265E-07
        let F1 = 5.99832206555887937690E-01
        let F2 = 1.36929880922735805310E-01
        let F3 = 1.48753612908506148525E-02
        let F4 = 7.86869131145613259100E-04
        let F5 = 1.84631831751005468180E-05
        let F6 = 1.42151175831644588870E-07
        let F7 = 2.04426310338993978564E-15
        let Q = p - HALF
        var _res: Double
        if(fabs(Q) <= SPLIT1)
        {
            R = CONST1 - Q * Q
            _res = Q * (((((((A7 * R + A6) * R + A5) * R + A4) * R + A3) * R + A2) * R + A1) * R + A0) / (((((((B7 * R + B6) * R + B5) * R + B4) * R + B3) * R + B2) * R + B1) * R + ONE)
            return _res
        }
        else
        {
            if(Q < ZERO) {
                R = p
            }
            else {
                R = ONE - p
            }
            if(R <= ZERO) {
                _res = Double.nan
                return _res
            }
            R = sqrt(-log(R))
            if (R <= SPLIT2)
            {
                R = R - CONST2
                _res = (((((((C7 * R + C6) * R + C5) * R + C4) * R + C3) * R + C2) * R + C1) * R + C0) / (((((((D7 * R + D6) * R + D5) * R + D4) * R + D3) * R + D2) * R + D1) * R + ONE)
            }
            else
            {
                R = R - SPLIT2
                _res = (((((((E7 * R + E6) * R + E5) * R + E4) * R + E3) * R + E2) * R + E1) * R + E0) / (((((((F7 * R + F6) * R + F5) * R + F4) * R + F3) * R + F2) * R + F1) * R + ONE)
            }
            if(Q < ZERO) {
                _res = -_res
            }
            return _res
        }

    }
    
    /// Returns the quantile function of a Gaussian distribution
    /// - Parameter p: p
    /// - Parameter m: Mean
    /// - Parameter sd: Standard deviation
    /// - Throws: SSSwiftyStatsError if sd <= 0.0
    public class func quantileNormalDist(p: Double!, mean m: Double!, standardDeviation sd: Double!) throws -> Double {
        if sd <= 0.0 {
            os_log("sd is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p < 0.0 {
            return -Double.infinity
        }
        if p > 1.0 {
            return Double.infinity
        }
        do {
            return try m + SQRTTWO * sd * SSProbabilityDistributions.inverf(z: -1.0 + 2.0 * p)
        }
        catch {
            return Double.nan
        }
    }

    /// Returns the quantile function of a Gaussian distribution
    /// - Parameter p: p
    /// - Parameter m: Mean
    /// - Parameter v: Variance
    /// - Throws: SSSwiftyStatsError if v <= 0.0
    public class func quantileNormalDist(p: Double!, mean m: Double!, variance v: Double!) throws -> Double {
        if v <= 0.0 {
            os_log("v is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p < 0.0 {
            return -Double.infinity
        }
        if p > 1.0 {
            return Double.infinity
        }
        do {
            return try SSProbabilityDistributions.quantileNormalDist(p:p, mean:m, standardDeviation: sqrt(v))
        }
        catch {
            return Double.nan
        }
    }
    
    /// Inverse error function using the identity inverf(x) = InverseCDFStdNormal( ( x + 1 ) / 2) / sqrt(2)
    /// - Parameter z: Z
    /// - Throws: SSSwiftyStatsError if z < -1.0 or z > 1.0
    fileprivate class func inverf(z: Double!) throws -> Double {
        if (z == -1.0) {
            return -Double.infinity
        }
        if z == 1.0 {
            return Double.infinity
        }
        if ((z < -1.0) || (z > 1.0)) {
            os_log("z is expected to be > -1.0 and < 1.0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        let x = (z + 1.0) / 2.0
        do {
            let invCDF = try SSProbabilityDistributions.quantileStandardNormalDist(p: x)
            let result = invCDF / SQRTTWO
            return result
        }
        catch {
            return Double.nan
        }
    }
    
    
    // MARK: STUDENT's T

    /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Student's T distribution.
    /// - Parameter df: Degrees of freedom
    /// - Throws: SSSwiftyStatsError if df <= 0
    public class func paraStudentT(degreesOfFreedom df: Double!) throws -> SSContProbDistParams {
        var result = SSContProbDistParams()
        if df < 0.0 {
            os_log("Degrees of freedom are expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        result.mean = 0.0
        if df > 2 {
            result.variance = df / (df - 2.0)
        }
        else {
            result.variance = 0.0
        }
        result.skewness = 0.0
        if df > 4 {
            result.kurtosis = 3.0 + 6.0 / (df - 4.0)
        }
        else {
            result.kurtosis = Double.nan
        }
        return result
    }

    /// Returns the pdf of Student's t-distribution
    /// - Parameter t: t
    /// - Paremeter df: Degrees of freedom
    /// - Throws: SSSwiftyStatsError if df <= 0
    public class func pdfStudentTDist(t: Double!, degreesOfFreedom df: Double!) throws -> Double {
        if df < 0.0 {
            os_log("Degrees of freedom are expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        return exp( lgamma( 0.5 * ( df + 1.0 ) ) - 0.5 * log( df * Double.pi ) - lgamma( 0.5 * df ) - ( ( df + 1.0 ) / 2.0 * log( 1.0 + t * t / df ) ) )
    }

    /// Returns the cdf of Student's t-distribution
    /// - Parameter t: t
    /// - Paremeter df: Degrees of freedom
    /// - Throws: SSSwiftyStatsError if df <= 0
    public class func cdfStudentTDist(t: Double!, degreesOfFreedom df: Double!) throws -> Double {
        if df < 0.0 {
            os_log("Degrees of freedom are expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        var correctedDoF: Double
        var halfDoF: Double
        var constant: Double
        var result: Double
        halfDoF = df / 2.0
        correctedDoF = df / ( df + ( t * t ) )
        constant = 0.5
        let t1 = betaNormalized(x: 1.0, a: halfDoF, b: constant)
        let t2 = betaNormalized(x: correctedDoF, a: halfDoF, b: constant)
        result = 0.5 * (1.0 + (t1 - t2) * t.sgn)
        return result
    }
    
    /// Returns the quantile function of Student's t-distribution
    ///  adapted from: http://rapidq.phatcode.net/examples/Math
    /// - Parameter p: p
    /// - Paremeter df: Degrees of freedom
    /// - Throws: SSSwiftyStatsError if df <= 0 or/and p < 0 or p > 1.0
    /// ### Note ###
    /// Bisection
    public class func quantileStudentTDist(p: Double!, degreesOfFreedom df: Double!) throws -> Double {
        if df < 0.0 {
            os_log("Degrees of freedom are expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p < 0.0 || p > 1.0 {
            os_log("p is expected to be >= 0.0 and <= 1.0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        /* adapted from: http://rapidq.phatcode.net/examples/Math/ProbDists.rqb
         * coded in C by Gary Perlman
         * coded in Basic by Michaek Zito 2003
         * coded in C# by Volker Thieme 2005
         */
        let eps: Double = 1E-15
        if fabs( p - 1.0 ) <= 1E-5  {
            return Double.infinity
        }
        if fabs(p) <= 1E-5 {
            return -Double.infinity
        }
        if fabs(p - 0.5) <= eps {
            return 0.0
        }
        var minT: Double
        var maxT: Double
        var result: Double
        var tVal: Double
        var b1: Bool = false
        var pp: Double
        var _p: Double
        if p < 0.5 {
            _p = 1.0 - p
            b1 = true
        }
        else {
            _p = p
        }
        minT = 0.0
//        maxT = sqrt(params.variance) * 20
        maxT = 100000.0
        tVal = (maxT + minT) / 2.0
        while (maxT - minT > (4.0 * eps)) {
            do {
                pp = try SSProbabilityDistributions.cdfStudentTDist(t: tVal, degreesOfFreedom: df)
            }
            catch {
                return Double.nan
            }
            if pp > _p {
                maxT = tVal
            }
            else {
                minT = tVal
            }
            tVal = (maxT + minT) * 0.5
        }
        result = tVal
        if b1 {
            result = result * -1.0
        }
        return result
    }
    
    // MARK: Chi Square
    
    /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Chi^2 distribution.
    /// - Parameter df: Degrees of freedom
    /// - Throws: SSSwiftyStatsError if df <= 0
    public class func paraChiSquareDist(degreesOfFreedom df: Double!) throws -> SSContProbDistParams {
        var result = SSContProbDistParams()
        if df <= 0 {
            os_log("degrees of freedom are expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        result.mean = df
        result.variance = 2.0 * df
        result.skewness = sqrt(8.0 / df)
        result.kurtosis = 3.0 + 12.0 / df
        return result
    }

    
    /// Returns the pdf of the Chi^2 distribution.
    /// - Parameter chi: Chi
    /// - Parameter df: Degrees of freedom
    /// - Throws: SSSwiftyStatsError if df <= 0
    public class func pdfChiSquareDist(chi: Double!, degreesOfFreedom df: Double!) throws -> Double {
        if df <= 0 {
            os_log("degrees of freedom are expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        var result: Double = 0.0
        if chi >= 0.0 {
            let a: Double
            let b: Double
            let c: Double
            let d: Double
            a = -df / 2.0 * LOG2
            b = -chi / 2.0
            c = (-1.0 + df / 2.0) * log(chi)
            d = lgamma(df / 2.0)
            result = exp(a + b + c - d)
        }
        else {
            result = 0.0
        }
        return result
    }

    /// Returns the cdf of the Chi^2 distribution.
    /// - Parameter chi: Chi
    /// - Parameter df: Degrees of freedom
    /// - Throws: SSSwiftyStatsError if df <= 0
    public class func cdfChiSquareDist(chi: Double!, degreesOfFreedom df: Double!) throws -> Double {
        if df <= 0 {
            os_log("degrees of freedom are expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if chi <= 0 {
            return 0.0
        }
        var conv: Bool = false
        let cdf1: Double = gammaNormalizedP(x: 0.5 * chi, a: 0.5 * df, converged: &conv)
        if cdf1 < 0.0 {
            return 0.0
        }
        else if ((cdf1 > 1.0) || cdf1.isNaN) {
            return 1.0
        }
        else {
            return cdf1
        }
    }
    
    
    /// Returns the p-quantile of the Chi^2 distribution.
    /// - Parameter p: p
    /// - Parameter df: Degrees of freedom
    /// - Throws: SSSwiftyStatsError if df <= 0
    public class func quantileChiSquareDist(p: Double!, degreesOfFreedom df: Double!) throws -> Double {
        if df <= 0 {
            os_log("degrees of freedom are expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p < 0.0 || p > 1.0 {
            os_log("p is expected to be >= 0.0 and <= 1.0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        let eps = 1.0E-12
        var minChi: Double = 0.0
        var maxChi: Double = 9999.0
        var result: Double = 0.0
        var chiVal: Double = df / sqrt(p)
        var test: Double
        while (maxChi - minChi) > eps {
            do {
                test = try SSProbabilityDistributions.cdfChiSquareDist(chi: chiVal, degreesOfFreedom: df)
            }
            catch {
                return Double.nan
            }
            if test > p {
                maxChi = chiVal
            }
            else {
                minChi = chiVal
            }
            chiVal = (maxChi + minChi) / 2.0
        }
        result = chiVal
        return result
    }
    
    // MARK: F-RATIO
    
    /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the F ratio distribution.
    /// - Parameter df1: numerator degrees of freedom
    /// - Parameter df2: denominator degrees of freedom
    /// - Throws: SSSwiftyStatsError if df1 <= 0 and/or df2 <= 0
    public class func paraFRatioDist(numeratorDF df1: Double!, denominatorDF df2: Double!) throws -> SSContProbDistParams {
        var result = SSContProbDistParams()
        if df1 <= 0 {
            os_log("numerator degrees of freedom are expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if df2 <= 0 {
            os_log("denominator degrees of freedom expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (df2 > 2.0) {
            result.mean = df2 / (df2 - 2)
        }
        else {
            result.mean = Double.nan
        }
        if (df2 > 4.0) {
            result.variance = (2 * pow(df2, 2.0) * (df1 + df2 - 2.0)) / (df1 * pow(df2 - 2.0,2.0) * (df2 - 4))
        }
        else {
            result.variance = Double.nan
        }
        if (df2 > 6.0) {
            let d1 = (2 * df1 + df2 - 2)
            let d2 = (df2 - 6)
            let s1 = (8 * (df2 - 4))
            let s2 = (df1 * (df1 + df2 - 2))
            result.skewness = (d1 / d2) * sqrt(s1 / s2)
        }
        else {
            result.skewness = Double.nan
        }
        if (df2 > 8.0) {
            let s1 = pow(df2 - 2,2.0)
            let s2 = df2 - 4
            let s3 = df1 + df2 - 2.0
            let s4 = 5.0 * df2 - 22
            let s5 = df2 - 6
            let s6 = df2 - 8
            let s7 = df1 + df2 - 2
            let ss1 = (s1 * (s2) + df1 * (s3) * (s4))
            let ss2 = df1 * (s5) * (s6) * (s7)
            result.kurtosis = 3.0 + (12 * ss1) / (ss2)
//            result.kurtosis = 3.0 + (12 * (pow(df2 - 2,2.0) * (df2 - 4) + df1 * (df1 + df2 - 2.0) * (5.0 * df2 - 22))) / (df1 * (df2 - 6) * (df2 - 8) * (df1 + df2 - 2))
             //                                      s1            s2                 s3                   s4                        s5          s6            s7
        }
        else {
            result.kurtosis = Double.nan
        }
        return result
    }
    
    /// Returns the pdf of the F-ratio distribution.
    /// - Parameter f: f-value
    /// - Parameter df1: numerator degrees of freedom
    /// - Parameter df2: denominator degrees of freedom
    /// - Throws: SSSwiftyStatsError if df1 <= 0 and/or df2 <= 0
    public class func pdfFRatioDist(f: Double!, numeratorDF df1: Double!, denominatorDF df2: Double!) throws -> Double {
        if df1 <= 0 {
            os_log("numerator degrees of freedom are expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if df2 <= 0 {
            os_log("denominator degrees of freedom are expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        var result: Double
        var f1: Double
        var f2: Double
        var f3: Double
        var f4: Double
        var f5: Double
        var f6: Double
        var f7: Double
        var f8: Double
        var f9: Double
        var lg1: Double
        var lg2: Double
        var lg3: Double
        if f >= 0.0 {
            f1 = (df1 + df2) / 2.0
            f2 = df1 / 2.0
            f3 = df2 / 2.0
            lg1 = lgamma(f1)
            lg2 = lgamma(f2)
            lg3 = lgamma(f3)
            f4 = (df1 / 2.0) * log(df1 / df2)
            f5 = (df1 / 2.0 - 1.0) * log(f)
            f6 = ((df1 + df2)/2.0) * log(1.0 + df1 * f / df2)
            f7 = lg1 - (lg2 + lg3) + f4
            f8 = f5 - f6
            f9 = f7 + f8
            result = exp(f9)
        }
        else {
            result = 0.0
        }
        return result
    }
    
    /// Returns the cdf of the F-ratio distribution. (http://mathworld.wolfram.com/F-Distribution.html)
    /// - Parameter f: f-value
    /// - Parameter df1: numerator degrees of freedom
    /// - Parameter df2: denominator degrees of freedom
    /// - Throws: SSSwiftyStatsError if df1 <= 0 and/or df2 <= 0
    public class func cdfFRatio(f: Double!, numeratorDF df1: Double!, denominatorDF df2: Double!) throws -> Double {
        if f <= 0.0 {
            return 0.0
        }
        if df1 <= 0 {
            os_log("numerator degrees of freedom are expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if df2 <= 0 {
            os_log("denominator degrees of freedom are expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        let result = betaNormalized(x: (f * df1) / (df2 + df1 * f), a: df1 / 2.0, b: df2 / 2.0)
        return result
    }
    
    /// Returns the quantile function of the F-ratio distribution.
    /// - Parameter p: p
    /// - Parameter df1: numerator degrees of freedom
    /// - Parameter df2: denominator degrees of freedom
    /// - Throws: SSSwiftyStatsError if df1 <= 0 and/or df2 <= 0 and/or p < 0 and/or p > 1
    public class func quantileFRatioDist(p: Double!,numeratorDF df1: Double!, denominatorDF df2: Double!) throws -> Double {
        if df1 <= 0 {
            os_log("numerator degrees of freedom are expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if df2 <= 0 {
            os_log("denominator degrees of freedom expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p < 0.0 || p > 1.0 {
            os_log("p is expected to be >= 0.0 and <= 1.0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        let eps: Double = 1E-15
        if fabs( p - 1.0 ) <= eps  {
            return Double.infinity
        }
        if fabs(p) <= eps {
            return 0.0
        }
        var fVal: Double
        var maxF: Double
        var minF: Double
        maxF = 9999.0
        minF = 0.0
        fVal = 1.0 / p
        var it: Int = 0
        var temp_p: Double
        while((maxF - minF) > 1.0E-12)
        {
            if it == 1000 {
                break
            }
            do {
                temp_p = try SSProbabilityDistributions.cdfFRatio(f: fVal, numeratorDF: df1, denominatorDF: df2)
            }
            catch {
                return Double.nan
            }
            if temp_p > p {
                maxF = fVal
            }
            else {
                minF = fVal
            }
            fVal = (maxF + minF) * 0.5
            it = it + 1
        }
        return fVal
    }
    
    // MARK: Log Normal
    
    /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Log Normal distribution.
    /// - Parameter mean: mean
    /// - Parameter variance: variance
    /// - Throws: SSSwiftyStatsError if v <= 0
    public class func paraLogNormalDist(mean: Double!, variance v: Double!) throws -> SSContProbDistParams {
        var result = SSContProbDistParams()
        if v <= 0 {
            os_log("variance is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        let delta: Double = exp(v)
        result.mean = exp(mean + v / 2.0)
        result.variance = exp(2.0 * mean) * delta * (delta - 1.0)
        result.skewness = (delta + 2.0) * sqrt(delta - 1.0)
        result.kurtosis = pow(delta, 4.0) + 2.0 * pow(delta, 3.0) + 3.0 * pow(delta, 2.0) - 3.0
        return result
    }
    
    /// Returns the cdf of the Logarithmic Normal distribution
    /// - Parameter x: x
    /// - Parameter mean: mean
    /// - Parameter variance: variance
    /// - Throws: SSSwiftyStatsError if v <= 0
    public class func pdfLogNormalDist(x: Double!, mean: Double!, variance v: Double!) throws -> Double {
        if v <= 0 {
            os_log("variance is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if x <= 0 {
            return 0.0
        }
        else {
            let r = 1.0 / (sqrt(v) * x * sqrt(2.0 * Double.pi)) * exp(-1.0 * pow(log(x) - mean, 2.0) / (2.0 * v))
            return r
        }
    }

    /// Returns the pdf of the Logarithmic Normal distribution
    /// - Parameter x: x
    /// - Parameter mean: mean
    /// - Parameter variance: variance
    /// - Throws: SSSwiftyStatsError if v <= 0
    public class func cdfLogNormal(x: Double!, mean: Double!, variance v: Double!) throws -> Double {
        if v <= 0 {
            os_log("variance is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if x <= 0 {
            return 0.0
        }
        let r = SSProbabilityDistributions.cdfStandardNormalDist(u: (log(x) - mean) / sqrt(v))
        return r
    }
    
    
    /// Returns the pdf of the Logarithmic Normal distribution
    /// - Parameter p: p
    /// - Parameter mean: mean
    /// - Parameter variance: variance
    /// - Throws: SSSwiftyStatsError if v <= 0 and/or p < 0 and/or p > 1
    public class func quantileLogNormal(p: Double, mean: Double!, variance v: Double!) throws -> Double {
        if v <= 0 {
            os_log("variance is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p < 0 || p > 1.0 {
            os_log("p is expected to be >= 0 and <= 1.0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if fabs(p - 1.0) <= 1e-16 {
            return Double.infinity
        }
        else if p.isZero {
            return 0.0
        }
        do {
            let u = try SSProbabilityDistributions.quantileStandardNormalDist(p: p)
            return exp( mean + u * sqrt(v))
        }
        catch {
            return Double.nan
        }
    }
    
    // MARK: Beta
    
    /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Beta distribution.
    /// - Parameter a: Shape parameter a
    /// - Parameter b: Shape parameter b
    /// - Throws: SSSwiftyStatsError if a and/or b <= 0
    public class func paraBetaDist(shapeA a:Double!, shapeB b: Double!) throws -> SSContProbDistParams {
        var result = SSContProbDistParams()
        if (a <= 0.0) {
            os_log("shape parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (b <= 0.0) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        result.mean = (a / (a + b))
        result.variance = (a * b) / (pow(a + b, 2.0) * (a + b + 1.0))
        let s1 = (2.0 * (b - a))
        let s2 = (a + b - 2.0)
        let s3 = (a + b + 1.0)
        let s4 = (a * b)
        result.skewness = ( s1 / s2) * sqrt( s3 / s4 )
        let k1 = (a + b + 1.0)
        let k2 = pow(a, 2.0) * (b + 2)
        let k3 = pow(b, 2.0) * (a + 2.0)
        let k4 = 2.0 * a * b
        let k5 = a + b + 2.0
        let k6 = (a + b + 3.0)
        let kk1 = (3.0 * k1 * ( k2 + k3 - k4 ))
        let kk2 = (a * b * k5 * k6)
        result.kurtosis = kk1 / kk2
        return result
    }
    
    
    /// Returns the pdf of the Beta distribution
    /// - Parameter x: x
    /// - Parameter a: Shape parameter a
    /// - Parameter b: Shape parameter b
    /// - Throws: SSSwiftyStatsError if a and/or b <= 0
    public class func pdfBetaDist(x: Double!, shapeA a: Double!, shapeB b: Double!) throws -> Double {
        if (a <= 0.0) {
            os_log("shape parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (b <= 0.0) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (x <= 0) {
            return 0.0
        }
        if(x >= 1.0) {
            return 0.0
        }
        let result = pow(x, a - 1.0) * pow(1.0 - x, b - 1.0) / betaFunction(a: a, b: b)
        return result
    }
    
    /// Returns the pdf of the Beta distribution
    /// - Parameter x: x
    /// - Parameter a: Shape parameter a
    /// - Parameter b: Shape parameter b
    /// - Throws: SSSwiftyStatsError if a and/or b <= 0
    public class func cdfBetaDist(x: Double!, shapeA a: Double!, shapeB b: Double!) throws -> Double {
        if (a <= 0.0) {
            os_log("shape parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (b <= 0.0) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (x <= 0) {
            return 0.0
        }
        else if (x >= 1.0) {
            return 1.0
        }
        else {
            let result = betaNormalized(x: x, a: a, b: b)
            return result
        }
    }
    
    /// Returns the quantile of the Beta distribution
    /// - Parameter p: p
    /// - Parameter a: Shape parameter a
    /// - Parameter b: Shape parameter b
    /// - Throws: SSSwiftyStatsError if a and/or b <= 0 and/or p < 0 and/or p > 1
    public class func quantileBetaDist(p: Double!, shapeA a: Double!, shapeB b: Double!) throws -> Double {
        if (a <= 0.0) {
            os_log("shape parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (b <= 0.0) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p < 0 || p > 1.0 {
            os_log("p is expected to be >= 0 and <= 1.0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if fabs(p - 1.0) < 1E-12 {
            return 1.0
        }
        else if p.isZero {
            return 0.0
        }
        var bVal: Double
        var maxB: Double
        var minB: Double
        var it: Int = 0
        maxB = 1.0
        minB = 0.0
        bVal = 0.5
        var pVal: Double
        while (maxB - minB) > 1E-12 {
            if it > 500 {
                break
            }
            do {
                pVal = try cdfBetaDist(x: bVal, shapeA: a, shapeB: b)
            }
            catch {
                return Double.nan
            }
            if  pVal > p {
                maxB = bVal
            }
            else {
                minB = bVal
            }
            bVal = (maxB + minB) / 2.0
            it = it + 1
        }
        return bVal
    }
    
    
    // MARK: Cauchy
    /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Cauchy distribution.
    /// - Parameter a: Location parameter a
    /// - Parameter b: Shape parameter b
    /// - Throws: SSSwiftyStatsError if b <= 0
    public class func paraCauchyDist(location a: Double!, shape b: Double!) throws -> SSContProbDistParams {
        if (b <= 0.0) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        return SSContProbDistParams()
    }
    
    /// Returns the pdf of the Cauchy distribution.
    /// - Parameter x: x
    /// - Parameter a: Location parameter a
    /// - Parameter b: Shape parameter b
    /// - Throws: SSSwiftyStatsError if b <= 0
    public class func pdfCauchyDist(x: Double!, location a: Double!, shape b: Double!) throws -> Double {
        if (b <= 0.0) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        let result = Double.pi * b * (1.0 * pow((x - a) / b, 2.0))
        return result
    }
    
    /// Returns the cdf of the Cauchy distribution.
    /// - Parameter x: x
    /// - Parameter a: Location parameter a
    /// - Parameter b: Shape parameter b
    /// - Throws: SSSwiftyStatsError if b <= 0
    public class func cdfCauchyDist(x: Double!, location a: Double!, shape b: Double!) throws -> Double {
        if (b <= 0.0) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        let result = 0.5 + 1.0 / Double.pi * atan((x - a) / b)
        return result
    }
    
    /// Returns the pdf of the Cauchy distribution.
    /// - Parameter x: x
    /// - Parameter a: Location parameter a
    /// - Parameter b: Shape parameter b
    /// - Throws: SSSwiftyStatsError if (b <= 0 || p < 0 || p > 1)
    public class func quantileCauchyDist(p: Double!, location a: Double!, shape b: Double!) throws -> Double {
        if (b <= 0.0) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p < 0.0 || p > 1.0 {
            os_log("p is expected to be >= 0 and <= 1.0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p.isZero {
            return -Double.infinity
        }
        if fabs(p - 1.0) > 1E-12 {
            return Double.infinity
        }
        let result = a + b * tan((-0.5 + p) * Double.pi)
        return result
    }
    
    // MARK: Laplace
    /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Laplace distribution.
    /// - Parameter mean: mean
    /// - Parameter b: Scale parameter b
    /// - Throws: SSSwiftyStatsError if b <= 0
    public class func paraLaplaceDist(mean: Double!, scale b: Double!) throws -> SSContProbDistParams {
        if (b <= 0.0) {
            os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        var result = SSContProbDistParams()
        result.mean = mean
        result.variance = 2.0 * pow(b, 2.0)
        result.kurtosis = 6.0
        result.skewness = 0.0
        return result
    }
    
    
    /// Returns the pdf of the Laplace distribution.
    /// - Parameter x: x
    /// - Parameter mean: mean
    /// - Parameter b: Scale parameter b
    /// - Throws: SSSwiftyStatsError if b <= 0
    public class func pdfLaplaceDist(x: Double!, mean: Double!, scale b: Double!) throws -> Double {
        if (b <= 0.0) {
            os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        let result = 1.0 / (2.0 * b) * exp(-fabs(x - mean) / b)
        return result
    }
    
    /// Returns the cdf of the Laplace distribution.
    /// - Parameter x: x
    /// - Parameter mean: mean
    /// - Parameter b: Scale parameter b
    /// - Throws: SSSwiftyStatsError if b <= 0
    public class func cdfLaplaceDist(x: Double!, mean: Double!, scale b: Double!) throws -> Double {
        if (b <= 0.0) {
            os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        let xm = x - mean
        let result = 0.5 * (1.0 + xm.sgn * (1.0 - exp(-fabs(xm) / b)))
        return result
    }

    /// Returns the quantile of the Laplace distribution.
    /// - Parameter p: p
    /// - Parameter mean: mean
    /// - Parameter b: Scale parameter b
    /// - Throws: SSSwiftyStatsError if b <= 0 || p < 0 || p > 1
    public class func quantileLaplaceDist(p: Double!, mean: Double!, scale b: Double!) throws -> Double {
        if (b <= 0.0) {
            os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p < 0.0 || p > 1.0 {
            os_log("p is expected to be >= 0 or <= 1.0 ", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        let result: Double
        if p.isZero {
            return -Double.infinity
        }
        else if fabs(p - 1.0) < 1E-15 {
            return Double.infinity
        }
        else if (p <= 0.5) {
            result = mean + b * log1p(2.0 * p - 1.0)
        }
        else {
            result = mean - b * log1p(2.0 * (1.0 - p) - 1.0)
        }
        return result
    }
    
    /// Returns the Logit for a given p
    /// - Parameter p: p
    /// - Throws: SSSwiftyStatsError if p <= 0 || p >= 1
    public class func logit(p: Double!) throws -> Double {
        if p <= 0.0 || p >= 1.0 {
            os_log("p is expected to be >= 0 or <= 1.0 ", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        return log1p(p / (1.0 - p))
    }

    /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Logistic distribution.
    /// - Parameter mean: mean
    /// - Parameter b: Scale parameter b
    /// - Throws: SSSwiftyStatsError if b <= 0
    public class func paraLogisticDist(mean: Double!, scale b: Double!) throws -> SSContProbDistParams {
        if b <= 0 {
            os_log("scale parameter b is expected to be > 0 ", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        var result = SSContProbDistParams()
        result.mean = mean
        result.variance = pow(b, 2.0) * pow(Double.pi, 2.0) / 3.0
        result.kurtosis = 4.2
        result.skewness = 0.0
        return result
    }

    /// Returns the pdf of the Logistic distribution.
    /// - Parameter x: x
    /// - Parameter mean: mean
    /// - Parameter b: Scale parameter b
    /// - Throws: SSSwiftyStatsError if b <= 0
    public class func pdfLogisticDist(x: Double!, mean: Double!, scale b: Double!) throws -> Double {
        if b <= 0 {
            os_log("scale parameter b is expected to be > 0 ", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        let result = exp(-(x - mean) / b) / (b * pow(1.0 + exp(-(x - mean) / b), 2.0))
        return result
    }

    /// Returns the cdf of the Logistic distribution.
    /// - Parameter x: x
    /// - Parameter mean: mean
    /// - Parameter b: Scale parameter b
    /// - Throws: SSSwiftyStatsError if b <= 0
    public class func cdfLogisticDist(x: Double!, mean: Double!, scale b: Double!) throws -> Double {
        if b <= 0 {
            os_log("scale parameter b is expected to be > 0 ", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        let result = 0.5 * (1.0 + tanh(0.5 * (x - mean) / b))
        return result
    }

    /// Returns the quantile of the Logistic distribution.
    /// - Parameter p: p
    /// - Parameter mean: mean
    /// - Parameter b: Scale parameter b
    /// - Throws: SSSwiftyStatsError if b <= 0 || p < 0 || p > 1
    public class func quantileLogisticDist(p: Double!, mean: Double!, scale b: Double!) throws -> Double {
        if b <= 0 {
            os_log("scale parameter b is expected to be > 0 ", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p < 0 || p > 1 {
            os_log("p is expected to be >= 0 and <= 1 ", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        let result: Double
        if p.isZero {
            return -Double.infinity
        }
        else if p == 1.0 {
            return Double.infinity
        }
        else {
            result = mean - b * log(-1.0 + 1.0 / p)
            return result
        }
    }

    // MARK: Pareto
    
    /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Pareto distribution.
    /// - Parameter a: minimum
    /// - Parameter b: Shape parameter b
    /// - Throws: SSSwiftyStatsError if b <= 0 || a <= 0
    public class func paraParetoDist(minimum a: Double!, shape b: Double!) throws -> SSContProbDistParams {
        if (a <= 0.0) {
            os_log("minimum parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (b <= 0.0) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        var result = SSContProbDistParams()
        if b > 1.0 {
            result.mean = (a * b) / (b - 1.0)
        }
        else {
            result.mean = Double.nan
        }
        if b > 2.0 {
            let v1 = (a * a * b )
            let v2 = (b - 2.0)
            let v3 = (b - 1.0)
            let v4 = (b - 1.0)
            result.variance = v1 / ( v2 * v3 * v4 )
        }
        else {
            result.variance = Double.nan
        }
        if b > 4.0 {
            let b2 = b * b
            let b3 = (-15.0 + 9.0 * b)
            let temp = (-12.0 + b2 * b3 ) / ((-4.0 + b) * (-3.0 + b) * b)
            result.kurtosis = temp
//            result.kurtosis = (3.0 * (b - 2.0) * (2.0 + b + 3.0 * b * b)) / ((b - 4.0) * (b - 3.0) * b)
        }
        else {
            result.kurtosis = Double.nan
        }
        if b > 3.0 {
            let s1 = sqrt((-2.0 + b) / b)
            let s2 = (1.0 + b)
            let s3 = (b - 3.0)
            result.skewness = (2.0 * s1 * s2) / s3
        }
        else {
            result.skewness = Double.nan
        }
        return result
    }

    /// Returns the pdf of the Pareto distribution.
    /// - Parameter x: x
    /// - Parameter a: minimum
    /// - Parameter b: Shape parameter b
    /// - Throws: SSSwiftyStatsError if b <= 0 || a <= 0
    public class func pdfParetoDist(x: Double!, minimum a: Double!, shape b: Double!) throws -> Double {
        if (a <= 0.0) {
            os_log("minimum parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (b <= 0.0) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        let a1 = pow(a, b)
        let a2 = a1 * b
        let result = a2 * pow(x, -1.0 - b)
        return result
    }

    /// Returns the cdf of the Pareto distribution.
    /// - Parameter x: x
    /// - Parameter a: minimum
    /// - Parameter b: Shape parameter b
    /// - Throws: SSSwiftyStatsError if b <= 0 || a <= 0
    public class func cdfParetoDist(x: Double!, minimum a: Double!, shape b: Double!) throws -> Double {
        if (a <= 0.0) {
            os_log("minimum parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (b <= 0.0) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if x <= a {
            return 0.0
        }
        else {
            return 1.0 - pow(a / x, b)
        }
    }

    
    /// Returns the quantile of the Pareto distribution.
    /// - Parameter p: p
    /// - Parameter a: minimum
    /// - Parameter b: Shape parameter b
    /// - Throws: SSSwiftyStatsError if b <= 0 || a <= 0
    public class func quantileParetoDist(p: Double!, minimum a: Double!, shape b: Double!) throws -> Double {
        if (a <= 0.0) {
            os_log("minimum parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (b <= 0.0) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p < 0 || p > 1 {
            os_log("p is expected to be >= 0 and <= 1 ", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p.isZero {
            return a
        }
        else if p == 1.0 {
            return Double.infinity
        }
        else {
            return a * pow(1.0 - p, -1.0 / b)
        }
    }

    // MARK: Exponential Dist
    
    /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Exponential distribution.
    /// - Parameter l: Lambda
    /// - Throws: SSSwiftyStatsError if l <= 0
    public class func paraExponentialDist(lambda l: Double!) throws -> SSContProbDistParams {
        if (l <= 0.0) {
            os_log("parameter lambda is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        var result = SSContProbDistParams()
        result.mean = 1.0 / l
        result.variance = 1.0 / (l * l)
        result.kurtosis = 9.0
        result.skewness = 2.0
        return result
    }

    /// Returns the pdf of the Exponential distribution.
    /// - Parameter x: x
    /// - Parameter l: Lambda
    /// - Throws: SSSwiftyStatsError if l <= 0
    public class func pdfExponentialDist(x: Double!, lambda l: Double!) throws -> Double {
        if (l <= 0.0) {
            os_log("parameter lambda is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if x < 0.0 {
            return 0.0
        }
        else if x == 1.0 {
            return l
        }
        else {
            return l * exp(-l * x)
        }
    }

    /// Returns the cdf of the Exponential distribution.
    /// - Parameter x: x
    /// - Parameter l: Lambda
    /// - Throws: SSSwiftyStatsError if l <= 0
    public class func cdfExponentialDist(x: Double!, lambda l: Double!) throws -> Double {
        if (l <= 0.0) {
            os_log("parameter lambda is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if x <= 0.0 {
            return 0.0
        }
        else {
            return 1.0 - exp(-l * x)
        }
    }

    /// Returns the quantile of the Exponential distribution.
    /// - Parameter p: p
    /// - Parameter l: Lambda
    /// - Throws: SSSwiftyStatsError if l <= 0 || p < 0 || p > 1
    public class func quantileExponentialDist(p: Double!, lambda l: Double!) throws -> Double {
        if (l <= 0.0) {
            os_log("parameter lambda is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p < 0 || p > 1 {
            os_log("p is expected to be >= 0 and <= 1 ", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p == 0.0 {
            return 0.0
        }
        else if p == 1.0 {
            return Double.infinity
        }
        else {
            return -log1p(1.0 - p - 1.0) / l
        }
    }

    // MARK: Wald / Inverse Normal
    
    /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Wald (inverse normal) distribution.
    /// - Parameter a: mean
    /// - Parameter b: Scale
    /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
    public class func paraWaldDist(mean a: Double!, scale b: Double) throws -> SSContProbDistParams {
        if (a <= 0.0) {
            os_log("parameter mean is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (b <= 0.0) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        var reault = SSContProbDistParams()
        reault.mean = a
        reault.variance = (a * a * a) / b
        reault.kurtosis = 3.0 + 15.0 * a / b
        reault.skewness = 3.0 * sqrt(a / b)
        return reault
    }

    /// Returns the pdf of the Wald (inverse normal) distribution.
    /// - Parameter x: x
    /// - Parameter a: mean
    /// - Parameter b: Scale
    /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
    public class func pdfWaldDist(x: Double!, mean a: Double!, scale b: Double) throws -> Double {
        if (a <= 0.0) {
            os_log("parameter mean is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (b <= 0.0) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if x <= 0.0 {
            return 0.0
        }
        else {
            return sqrt(b / ( 2.0 * Double.pi * x * x * x)) * exp(b / a - b / (x + x) - (b * x) / (2.0 * a * a))
        }
    }

    /// Returns the cdf of the Wald (inverse normal) distribution.
    /// - Parameter x: x
    /// - Parameter a: mean
    /// - Parameter b: Scale
    /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
    public class func cdfWaldDist(x: Double!, mean a: Double!, scale b: Double) throws -> Double {
        if (a <= 0.0) {
            os_log("parameter mean is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (b <= 0.0) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        let n1 = SSProbabilityDistributions.cdfStandardNormalDist(u: sqrt(b / x) * (x / a - 1.0))
        let n2 = SSProbabilityDistributions.cdfStandardNormalDist(u: -sqrt(b / x) * (x / a + 1.0))
        let result = n1 + exp(2.0 * b / a) * n2
        return result
    }

    /// Returns the quantile of the Wald (inverse normal) distribution.
    /// - Parameter p: p
    /// - Parameter a: mean
    /// - Parameter b: Scale
    /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0 || p < 0 || p > 0
    public class func quantileWaldDist(p: Double!, mean a: Double!, scale b: Double) throws -> Double {
        if (a <= 0.0) {
            os_log("parameter mean is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (b <= 0.0) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p < 0 || p > 1 {
            os_log("p is expected to be >= 0 and <= 1 ", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        
        if fabs(p - 1.0) <= 1e-12 {
            return Double.infinity
        }
        if (fabs(p) <= 1e-12) {
            return 0.0
        }
        var wVal: Double
        var MaxW: Double
        var MinW: Double
        MaxW = 99999
        MinW = 0.0
        wVal = p * a * b
        var pVal: Double
        var i: Int = 0
        while (MaxW - MinW) > 1.0E-16 {
            do {
                pVal = try SSProbabilityDistributions.cdfWaldDist(x: wVal, mean: a, scale: b)
            }
            catch {
                return Double.nan
            }
            if pVal > p {
                MaxW = wVal
            }
            else {
                MinW = wVal
            }
            wVal = (MaxW + MinW) * 0.5
            i = i + 1
            if  i >= 500 {
                break
            }
        }
        return wVal
    }

    /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Wald (inverse normal) distribution.
    /// - Parameter a: mean
    /// - Parameter b: Scale
    /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
    public class func paraInverseNormalDist(mean a: Double!, scale b: Double) throws -> SSContProbDistParams {
        if (a <= 0.0) {
            os_log("parameter mean is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (b <= 0.0) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        return try! SSProbabilityDistributions.paraWaldDist(mean:a, scale:b)
    }
    
    /// Returns the pdf of the Wald (inverse normal) distribution.
    /// - Parameter x: x
    /// - Parameter a: mean
    /// - Parameter b: Scale
    /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
    public class func pdfInverseNormalDist(x: Double!, mean a: Double!, scale b: Double) throws -> Double {
        if (a <= 0.0) {
            os_log("parameter mean is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (b <= 0.0) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        return try! SSProbabilityDistributions.pdfWaldDist(x:x, mean:a, scale:b)
    }
    
    /// Returns the cdf of the Wald (inverse normal) distribution.
    /// - Parameter x: x
    /// - Parameter a: mean
    /// - Parameter b: Scale
    /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
    public class func cdfInverseNormalDist(x: Double!, mean a: Double!, scale b: Double) throws -> Double {
        if (a <= 0.0) {
            os_log("parameter mean is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (b <= 0.0) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        return try! SSProbabilityDistributions.cdfWaldDist(x:x, mean:a, scale:b)
    }
    
    /// Returns the quantile of the Wald (inverse normal) distribution.
    /// - Parameter p: p
    /// - Parameter a: mean
    /// - Parameter b: Scale
    /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0 || p < 0 || p > 0
    public class func quantileInverseNormalDist(p: Double!, mean a: Double!, scale b: Double) throws -> Double {
        if (a <= 0.0) {
            os_log("parameter mean is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (b <= 0.0) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p < 0 || p > 1 {
            os_log("p is expected to be >= 0 and <= 1 ", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        return try! SSProbabilityDistributions.quantileWaldDist(p:p, mean:a, scale:b)
    }

    // MARK: Gamma
    
    /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Gamma distribution.
    /// - Parameter a: Shape parameter
    /// - Parameter b: Scale parameter
    /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
    public class func paraGammaDist(shape a: Double!, scale b: Double!) throws -> SSContProbDistParams {
        if (a <= 0.0) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (b <= 0.0) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        var result = SSContProbDistParams()
        result.mean = a * b
        result.variance = a * b * b
        result.kurtosis = 3.0 + 6.0 / b
        result.skewness = 2.0 / sqrt(a)
        return result
    }

    
    /// Returns the pdf of the Gamma distribution.
    /// - Parameter x: x
    /// - Parameter a: Shape parameter
    /// - Parameter b: Scale parameter
    /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
    public class func pdfGammaDist(x: Double!, shape a: Double!, scale b: Double!) throws -> Double {
        if (a <= 0.0) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (b <= 0.0) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if x <= 0.0 {
            return 0.0
        }
        else {
            let a1 = -a * log(b)
            let a2 = -x / b
            let a3 = -1.0 + a
            let a4 = a1 + a2 + a3 * log(x) - lgamma(a)
            let result = exp(a4)
            return result
//            return exp(-a * log(b) + (-x / b) + (-1.0 + a) * log(x) - lgamma(a))
        }
    }

    /// Returns the cdf of the Gamma distribution.
    /// - Parameter x: x
    /// - Parameter a: Shape parameter
    /// - Parameter b: Scale parameter
    /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
    public class func cdfGammaDist(x: Double!, shape a: Double!, scale b: Double!) throws -> Double {
        if (a <= 0.0) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (b <= 0.0) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if x < 0.0 {
            return 0.0
        }
        var cv: Bool = false
        let result = gammaNormalizedP(x: x / b, a: a, converged: &cv)
        if cv {
            return result
        }
        else {
            os_log("unable to retrieve a result", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .maxNumberOfIterationReached, file: #file, line: #line, function: #function)
        }
    }

    /// Returns the quantile of the Gamma distribution.
    /// - Parameter p: p
    /// - Parameter a: Shape parameter
    /// - Parameter b: Scale parameter
    /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0 || p < 0 || p > 1
    public class func quantileGammaDist(p: Double!, shape a: Double!, scale b: Double!) throws -> Double {
        if (a <= 0.0) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (b <= 0.0) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p < 0 || p > 1 {
            os_log("p is expected to be >= 0 and <= 1 ", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p == 0.0 {
            return 0.0
        }
        if p == 1.0 {
            return Double.infinity
        }
        var gVal: Double = 0.0
        var maxG: Double = 0.0
        var minG: Double = 0.0
        maxG = a * b + 4000.0
        minG = 0.0
        gVal = a * b
        var test: Double
        var i = 1
        while((maxG - minG) > 1.0E-14) {
            test = try! cdfGammaDist(x: gVal, shape: a, scale: b)
            if test > p {
                maxG = gVal
            }
            else {
                minG = gVal
            }
            gVal = (maxG + minG) * 0.5
            i = i + 1
            if i >= 7500 {
                break
            }
        }
        if((a * b) > 10000) {
            let t1: Double = gVal * 1E07
            let ri: UInt64 = UInt64(t1)
            let rd: Double = Double(ri) / 1E07
            return rd
        }
        else {
            return gVal
        }
    }

    // MARK: Erlang
    
    /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Erlang distribution.
    /// - Parameter a: Shape parameter
    /// - Parameter b: Scale parameter
    /// - Throws: SSSwiftyStatsError if a <= 0
    public class func paraErlangDist(shape a: Double!, scale b: UInt!) throws -> SSContProbDistParams {
        if (a <= 0.0) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        let result:SSContProbDistParams = try! paraGammaDist(shape: a, scale: Double(b))
        return result
    }
    
    
    /// Returns the pdf of the Erlang distribution.
    /// - Parameter x: x
    /// - Parameter a: Shape parameter
    /// - Parameter b: Scale parameter
    /// - Throws: SSSwiftyStatsError if a <= 0
    public class func pdfErlangDist(x: Double!, shape a: Double!, scale b: UInt!) throws -> Double {
        if (a <= 0.0) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        return try! pdfGammaDist(x: x, shape: a, scale: Double(b))
    }
    
    /// Returns the cdf of the Erlang distribution.
    /// - Parameter x: x
    /// - Parameter a: Shape parameter
    /// - Parameter b: Scale parameter
    /// - Throws: SSSwiftyStatsError if a <= 0
    public class func cdfErlangDist(x: Double!, shape a: Double!, scale b: UInt!) throws -> Double {
        if (a <= 0.0) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        let result: Double
        do {
            result = try cdfGammaDist(x: x, shape: a, scale: Double(b))
            return result
        }
        catch {
            throw error
        }
    }
    
    /// Returns the quantile of the Erlang distribution.
    /// - Parameter p: p
    /// - Parameter a: Shape parameter
    /// - Parameter b: Scale parameter
    /// - Throws: SSSwiftyStatsError if a <= 0 || p < 0 || p > 1
    public class func quantileErlangDist(p: Double!, shape a: Double!, scale b: UInt!) throws -> Double {
        if (a <= 0.0) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p < 0 || p > 1 {
            os_log("p is expected to be >= 0 and <= 1 ", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p == 0.0 {
            return 0.0
        }
        if p == 1.0 {
            return Double.infinity
        }
        return try! quantileGammaDist(p: p, shape: a, scale: Double(b))
    }

    
    // MARK: Weibull
    
    /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Weibull distribution.
    /// - Parameter a: Location parameter
    /// - Parameter b: Scale parameter
    /// - Parameter c: Shape parameter
    /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
    public class func paraWeibullDist(location a: Double!, scale b: Double!, shape c: Double!) throws -> SSContProbDistParams {
        if (b <= 0.0) {
            os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (c <= 0.0) {
            os_log("shape parameter c is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        var result = SSContProbDistParams()
        result.mean = a + b * tgamma(1.0 + (1.0 / c))
        result.variance = b * b * tgamma(1.0 + (2.0 / c)) - pow(tgamma(1.0 + (1.0 / c)), 2.0)
        result.kurtosis = Double.nan
        result.skewness = Double.nan
        return result
    }

    /// Returns the pdf of the Weibull distribution.
    /// - Parameter x: x
    /// - Parameter a: Location parameter
    /// - Parameter b: Scale parameter
    /// - Parameter c: Shape parameter
    /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
    public class func pdfWeibullDist(x: Double!, location a: Double!, scale b: Double!, shape c: Double!) throws -> Double {
        if (b <= 0.0) {
            os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (c <= 0.0) {
            os_log("shape parameter c is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if x < a {
            return 0.0
        }
        let result = c / b * pow((x - a) / b, c - 1.0) * exp(-pow((x - a) / b, c))
        return result
    }

    /// Returns the cdf of the Weibull distribution.
    /// - Parameter x: x
    /// - Parameter a: Location parameter
    /// - Parameter b: Scale parameter
    /// - Parameter c: Shape parameter
    /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
    public class func cdfWeibullDist(x: Double!, location a: Double!, scale b: Double!, shape c: Double!) throws -> Double {
        if (b <= 0.0) {
            os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (c <= 0.0) {
            os_log("shape parameter c is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if x < a {
            return 0.0
        }
        let result = 1.0 - exp(-pow((x - a) / b, c))
        return result
    }

    /// Returns the quantile of the Weibull distribution.
    /// - Parameter p: p
    /// - Parameter a: Location parameter
    /// - Parameter b: Scale parameter
    /// - Parameter c: Shape parameter
    /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0 || p < 0 || p > 1
    public class func quantileWeibullDist(p: Double!, location a: Double!, scale b: Double!, shape c: Double!) throws -> Double {
        if (b <= 0.0) {
            os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (c <= 0.0) {
            os_log("shape parameter c is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p < 0 || p > 1 {
            os_log("p is expected to be >= 0 and <= 1 ", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p == 0.0 {
            return 0.0
        }
        if p == 1.0 {
            return Double.infinity
        }
        let result = a + b * pow(-log1p((1.0 - p) - 1.0), 1.0 / c)
        return result
    }

    
    // MARK: UNIFORM
    
    /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Uniform distribution.
    /// - Parameter a: Lower bound
    /// - Parameter b: Upper bound
    /// - Throws: SSSwiftyStatsError if a >= b
    public class func paraUniformDist(lowerBound a: Double!, upperBound b: Double!) throws -> SSContProbDistParams {
        if (a >= b) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        var result = SSContProbDistParams()
        result.mean = (a + b) / 2.0
        result.variance = 1.0 / 12.0 * (b - a) * (b - a)
        result.kurtosis = 1.8
        result.skewness = 0.0
        return result
    }

    /// Returns the pdf of the Uniform distribution.
    /// - Parameter x: x
    /// - Parameter a: Lower bound
    /// - Parameter b: Upper bound
    /// - Throws: SSSwiftyStatsError if a >= b
    public class func pdfUniformDist(x: Double!, lowerBound a: Double!, upperBound b: Double!) throws -> Double {
        if (a >= b) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if x < a || x > b {
            return 0.0
        }
        else {
            return 1.0 / (b - a)
        }
    }

    /// Returns the cdf of the Uniform distribution.
    /// - Parameter x: x
    /// - Parameter a: Lower bound
    /// - Parameter b: Upper bound
    /// - Throws: SSSwiftyStatsError if a >= b
    public class func cdfUniformDist(x: Double!, lowerBound a: Double!, upperBound b: Double!) throws -> Double {
        if (a >= b) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if x < a {
            return 0.0
        }
        else if x > b {
            return 1.0
        }
        else {
            return (x - a) / (b - a)
        }
    }

    /// Returns the cdf of the Uniform distribution.
    /// - Parameter x: x
    /// - Parameter a: Lower bound
    /// - Parameter b: Upper bound
    /// - Throws: SSSwiftyStatsError if a >= b
    public class func quantileUniformDist(p: Double!, lowerBound a: Double!, upperBound b: Double!) throws -> Double {
        if (a >= b) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p < 0 || p > 1 {
            os_log("p is expected to be >= 0 and <= 1 ", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        return a + (b - a) * p
    }

    // MARK: TRIANGULAR
    
    /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Triangular distribution.
    /// - Parameter a: Lower bound
    /// - Parameter b: Upper bound
    /// - Parameter c: Mode
    /// - Throws: SSSwiftyStatsError if a >= b || c <= a || c >= b
    public class func paraTriangularDist(lowerBound a: Double!, upperBound b: Double!, mode c: Double!) throws -> SSContProbDistParams {
        if (a >= b) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (c <= a) {
            os_log("mode parameter c is expected to be greater than lower bound", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (c >= b) {
            os_log("mode parameter c is expected to be smaller than upper bound", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        var result = SSContProbDistParams()
        result.mean = (a + b + c) / 3.0
        result.kurtosis = 2.4
        let a2 = a * a
        let a3 = a2 * a
        let b2 = b * b
        let b3 = b2 * b
        let c2 = c * c
        let c3 = c2 * c
        let ab = a * b
        let ac = a * c
        let bc = b * c
        result.variance = 1.0 / 18.0 * ( a2 - ab + b2 - ac - bc + c2 )
//        result.variance = 1.0 / 18.0 * (a * a - a * b + b * b - a * c - b * c + c * c)
        let s1 = 2.0 * a3
        let s2 = 3.0 * a2 * b
        let s3 = 3.0 * a * b2
        let s4 = 2.0 * b3
        let s5 = 3.0 * a3 * c
        let s6 = 12.0 * ab * c
        let s7 = 3.0 * b2 * c
        let s8 = 3.0 * a * c2
        let s9 = 3.0 * b * c2
        let s10 = 2.0 * c3
        let s11 = a2 - ab + b2 - ac - bc + c2
        let ss1 = (s1 - s2 - s3 + s4 - s5 + s6 - s7 - s8 - s9 + s10)
        result.skewness = (SQRTTWO * ss1) / (5.0 * pow(s11, 1.5))
//        result.skewness = (SQRTTWO * ( 2.0 * a3 - 3.0 * a2 * b - 3.0 * a * b2 + 2.0 * b3 - 3.0 * a3 * c + 12.0 * a * b * c - 3.0 * b2 * c - 3.0 * a * c2 - 3.0 * b * c2 + 2.0 * c3)) / (5.0 * pow(a2 - a * b + b2 - a * c - b * c + c2, 1.5))
        return result
    }
    
    /// Returns the pdf of the Triangular distribution.
    /// - Parameter x: x
    /// - Parameter a: Lower bound
    /// - Parameter b: Upper bound
    /// - Parameter c: Mode
    /// - Throws: SSSwiftyStatsError if a >= b || c <= a || c >= b
    public class func pdfTriangularDist(x: Double!, lowerBound a: Double!, upperBound b: Double!, mode c: Double!) throws -> Double {
        if (a >= b) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (c <= a) {
            os_log("mode parameter c is expected to be greater than lower bound", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (c >= b) {
            os_log("mode parameter c is expected to be smaller than upper bound", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if ((x < a) || (x > b)) {
            return 0.0
        }
        else if ((x == a) || ((x > a) && (x <= c))) {
            let s1 = (2.0 * ( x - a))
            let s2 = (a - b - c)
            return s1 / (a * s2 + b * c)
        }
        else {
            let s1 = (2.0 * (b - x))
            let s2 = (-a + b - c)
            return s1 / (b * s2 + a * c)
        }
    }

    /// Returns the cdf of the Triangular distribution.
    /// - Parameter x: x
    /// - Parameter a: Lower bound
    /// - Parameter b: Upper bound
    /// - Parameter c: Mode
    /// - Throws: SSSwiftyStatsError if a >= b || c <= a || c >= b
    public class func cdfTriangularDist(x: Double!, lowerBound a: Double!, upperBound b: Double!, mode c: Double!) throws -> Double {
        if (a >= b) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (c <= a) {
            os_log("mode parameter c is expected to be greater than lower bound", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (c >= b) {
            os_log("mode parameter c is expected to be smaller than upper bound", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (x < a) {
            return 0.0
        }
        else if (x > b) {
            return 1.0
        }
        else if ((x == a) || ((x > a) && (x <= c))) {
            let s1 = (a - 2.0 * x)
            let s2 = (a - b - c)
            return (a * s1 + x * x) / (a * s2 + b * c)
        }
        else {
            let b2 = b * b
            let bx = b * x
            let x2 = x * x
            let result: Double = 1.0 + ((b2 - 2.0 * bx + x2) / ( a - b) * (b - c))
            return result
//            return 1.0 - ( ( b * ( b - 2.0 * x ) + x * x ) / ( b * ( b - a - c ) + a * c ) )
        }
    }

    /// Returns the quantile of the Triangular distribution.
    /// - Parameter p: p
    /// - Parameter a: Lower bound
    /// - Parameter b: Upper bound
    /// - Parameter c: Mode
    /// - Throws: SSSwiftyStatsError if a >= b || c <= a || c >= b || p < 0 || p > 0
    public class func quantileTriangularDist(p: Double!, lowerBound a: Double!, upperBound b: Double!, mode c: Double!) throws -> Double {
        if (a >= b) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (c <= a) {
            os_log("mode parameter c is expected to be greater than lower bound", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if (c >= b) {
            os_log("mode parameter c is expected to be smaller than upper bound", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p < 0 || p > 1 {
            os_log("p is expected to be >= 0 and <= 1 ", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p == 0.0 {
            return a
        }
        let t1 = (-a + c) / (-a + b)
        if p <= t1 {
            let s1 = (-a + b)
            let s2 = (-a + c)
            let s3 = sqrt(s1 * s2 * p)
            return a + s3
        }
        else {
            let s1 = (-a + b)
            let s2 = (b - c)
            let s3 = (1.0 - p)
            return b - sqrt(s1 * s2 * s3)
        }
    }

    // MARK: TRIANGULAR with two params
    
    /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Triangular distribution.
    /// - Parameter a: Lower bound
    /// - Parameter b: Upper bound
    /// - Throws: SSSwiftyStatsError if a >= b
    public class func paraTriangularDist(lowerBound a: Double!, upperBound b: Double!) throws -> SSContProbDistParams {
        if (a >= b) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        var result = SSContProbDistParams()
        result.mean = (a + b) / 2.0
        result.variance = 1.0 / 24.0 * (b - a) * (b - a)
        result.kurtosis = 2.4
        result.skewness = 0.0
        return result
    }
    
    /// Returns the pdf of the Triangular distribution.
    /// - Parameter x: x
    /// - Parameter a: Lower bound
    /// - Parameter b: Upper bound
    /// - Throws: SSSwiftyStatsError if a >= b
    public class func pdfTriangularDist(x: Double!, lowerBound a: Double!, upperBound b: Double!) throws -> Double {
        if (a >= b) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        return try! SSProbabilityDistributions.pdfTriangularDist(x: x, lowerBound: a, upperBound: b, mode: (a + b) / 2.0)
    }
    
    /// Returns the cdf of the Triangular distribution.
    /// - Parameter x: x
    /// - Parameter a: Lower bound
    /// - Parameter b: Upper bound
    /// - Throws: SSSwiftyStatsError if a >= b
    public class func cdfTriangularDist(x: Double!, lowerBound a: Double!, upperBound b: Double!) throws -> Double {
        if (a >= b) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        return try! SSProbabilityDistributions.cdfTriangularDist(x: x, lowerBound: a, upperBound: b, mode: (a + b) / 2.0)
    }
    
    /// Returns the quantile of the Triangular distribution.
    /// - Parameter p: p
    /// - Parameter a: Lower bound
    /// - Parameter b: Upper bound
    /// - Throws: SSSwiftyStatsError if a >= b || p < 0 || p > 0
    public class func quantileTriangularDist(p: Double!, lowerBound a: Double!, upperBound b: Double!) throws -> Double {
        if (a >= b) {
            os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        if p < 0 || p > 1 {
            os_log("p is expected to be >= 0 and <= 1 ", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
        }
        return try! SSProbabilityDistributions.quantileTriangularDist(p: p, lowerBound: a, upperBound: b, mode: (a + b) / 2.0)
    }
    
    // MARK: binomial
    
    /// Returns the cdf of the Binomial Distribution
    /// - Parameter k: number of successes
    /// - Parameter n: number of trials
    /// - Parameter p0: probability fpr success
    /// - Parameter tail: .lower, .upper
    public class func cdfBinomialDistribution(k: Int, n: Int, probability p0: Double!, tail: SSCDFTail) -> Double {
        var i = 0
        var lowerSum: Double = 0.0
        var upperSum: Double = 0.0
        while i <= k {
            lowerSum += binomial2(Double(n), Double(i)) * pow(p0, Double(i)) * pow(1.0 - p0, Double(n - i))
            i += 1
        }
        upperSum = 1.0 - lowerSum
        switch tail {
        case .lower:
            return lowerSum
        case .upper:
            return upperSum
        }
    }

    
    /// Returns the pdf of the Binomial Distribution
    /// - Parameter k: number of successes
    /// - Parameter n: number of trials
    /// - Parameter p0: probability fpr success
    public class func pdfBinomialDistribution(k: Int, n: Int, probability p0: Double!) -> Double {
        var result: Double
        result = binomial2(Double(n), Double(k)) * pow(p0, Double(k)) * pow(1.0 - p0, Double(n - k))
        return result
    }












}

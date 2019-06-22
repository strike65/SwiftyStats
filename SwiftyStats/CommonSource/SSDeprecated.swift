//
//  SwiftyStats.h
//  SwiftyStats
//
//  Created by strike65 on 18.07.17.
//
/*
 Copyright (2017-2019) strike65
 
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

/**********************************************************************
 
 DEPRECATIONS
 
 ***********************************************************************/

@available(*, deprecated, message: "Use SSProbDist.StudentT.para(_:) instead")
public func paraStudentTDist<FPT: SSFloatingPoint & Codable>(degreesOfFreedom df: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.StudentT.para(degreesOfFreedom: df)
}
@available(*, deprecated, message: "Use SSSProbDist.StudentT.pdf(_:,_:,_:,_:) instead")
public func pdfStudentTDist<FPT: SSFloatingPoint & Codable>(t: FPT, degreesOfFreedom df: FPT, rlog: Bool! = false) throws -> FPT {
    return try SSProbDist.StudentT.pdf(t: t, degreesOfFreedom: df, rlog: rlog)
}
@available(*, deprecated, message: "Use SSSProbDist.StudentT.cdf(_:,_:) instead")
public func cdfStudentTDist<FPT: SSFloatingPoint & Codable>(t: FPT, degreesOfFreedom df: FPT) throws -> FPT {
    return try SSProbDist.StudentT.cdf(t: t, degreesOfFreedom: df)
}
@available(*, deprecated, message: "Use SSSProbDist.StudentT.quantile(_:,_:) instead")
public func quantileStudentTDist<FPT: SSFloatingPoint & Codable>(p: FPT, degreesOfFreedom df: FPT) throws -> FPT {
    return try SSProbDist.StudentT.quantile(p: p, degreesOfFreedom: df)
}
#if arch(i386) || arch(x86_64)
@available(*, deprecated, message: "Use SSSProbDist.StudentT.NonCentral.para(_:,_:) instead")
public func paraStudentTDist<FPT: SSFloatingPoint & Codable>(degreesOfFreedom df: FPT, nonCentralityPara lambda: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.StudentT.NonCentral.para(degreesOfFreedom: df, nonCentralityPara: lambda)
}
@available(*, deprecated, message: "Use SSProbDist.StudentT.NonCentral.cdf(_:,_:,_:,_:) instead")
public func cdfStudentTDist<T: SSFloatingPoint & Codable>(t: T, degreesOfFreedom df: T, nonCentralityPara lambda: T, rlog: Bool! = false) throws -> T {
    return try SSProbDist.StudentT.NonCentral.cdf(t: t, degreesOfFreedom: df, nonCentralityPara: lambda, rlog: rlog)
}
@available(*, deprecated, message: "Use SSSProbDist.StudentT.NonCentral.pdf(_:,_:,_:,_:) instead")
public func pdfStudentTDist<FPT: SSFloatingPoint & Codable>(x: FPT, degreesOfFreedom df: FPT, nonCentralityPara lambda: FPT, rlog: Bool! = false) throws -> FPT {
    return try SSProbDist.StudentT.NonCentral.pdf(x: x, degreesOfFreedom: df, nonCentralityPara: lambda, rlog: rlog)
}
@available(*, deprecated, message: "Use SSSProbDist.StudentT.NonCentral.para(_:,_:,_:,_:) instead")
public func quantileStudentTDist<FPT: SSFloatingPoint & Codable>(p: FPT, degreesOfFreedom df: FPT, nonCentralityPara lambda: FPT, rlog: Bool! = false) throws -> FPT {
    return try SSProbDist.StudentT.NonCentral.quantile(p: p, degreesOfFreedom: df, nonCentralityPara: lambda, rlog: rlog)
}
#endif
@available(*, deprecated, message: "Use SSSProbDist.ChiSquare.para(_:) instead")
public func paraChiSquareDist<FPT: SSFloatingPoint & Codable>(degreesOfFreedom df: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.ChiSquare.para(degreesOfFreedom: df)
}
@available(*, deprecated, message: "Use SSSProbDist.ChiSquare.pdf(_:,_:) instead")
public func pdfChiSquareDist<FPT: SSFloatingPoint & Codable>(chi: FPT, degreesOfFreedom df: FPT) throws -> FPT {
    return try SSProbDist.ChiSquare.pdf(chi: chi, degreesOfFreedom: df)
}
@available(*, deprecated, message: "Use SSSProbDist.ChiSquare.cdf(_:,_:,_:,_:) instead")
public  func cdfChiSquareDist<FPT: SSFloatingPoint & Codable>(chi: FPT, degreesOfFreedom df: FPT, tail: SSCDFTail = .lower, rlog: Bool = false) throws -> FPT {
    return try SSProbDist.ChiSquare.cdf(chi: chi, degreesOfFreedom: df, tail: tail, rlog: rlog)
}
@available(*, deprecated, message: "Use SSSProbDist.ChiSquare.quantile(_:,_:) instead")
public func quantileChiSquareDist<FPT: SSFloatingPoint & Codable>(p: FPT, degreesOfFreedom df: FPT) throws -> FPT {
    return try SSProbDist.ChiSquare.quantile(p: p, degreesOfFreedom: df)
}
@available(*, deprecated, message: "Use SSSProbDist.ChiSquare.NonCentral.para(_:,_:) instead")
public  func paraChiSquareDist<FPT: SSFloatingPoint & Codable>(degreesOfFreedom df: FPT, lambda: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.ChiSquare.NonCentral.para(degreesOfFreedom: df, lambda: lambda)
}
@available(*, deprecated, message: "Use SSSProbDist.ChiSquare.NonCentral.pdf(_:,_:,_:) instead")
public  func pdfChiSquareDist<FPT: SSFloatingPoint & Codable>(chi: FPT, degreesOfFreedom df: FPT, lambda: FPT) throws -> FPT {
    return try SSProbDist.ChiSquare.NonCentral.pdf(chi: chi, degreesOfFreedom: df, lambda: lambda)
}
@available(*, deprecated, message: "Use SSSProbDist.ChiSquare.NonCentral.cdf(_:,_:,_:) instead")
public  func cdfChiSquareDist<FPT: SSFloatingPoint & Codable>(chi: FPT, degreesOfFreedom df: FPT, lambda: FPT) throws -> FPT {
    return try SSProbDist.ChiSquare.NonCentral.cdf(chi: chi, degreesOfFreedom: df, lambda: lambda)
}
@available(*, deprecated, message: "Use SSSProbDist.ChiSquare.NonCentral.quantile(_:,_:,_:) instead")
public  func quantileChiSquareDist<FPT: SSFloatingPoint & Codable>(p: FPT, degreesOfFreedom df: FPT, lambda: FPT) throws -> FPT {
    return try SSProbDist.ChiSquare.NonCentral.quantile(p: p, degreesOfFreedom: df, lambda: lambda)
}

@available(*, deprecated, message: "Use SSSProbDist.ChiSquare.NonCentral.quantile(_:,_:,_:) instead")
public func paraFRatioDist<FPT: SSFloatingPoint & Codable>(numeratorDF df1: FPT, denominatorDF df2: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.FRatio.para(numeratorDF: df1, denominatorDF: df1)
}

@available(*, deprecated, message: "Use SSSProbDist.FRatio.pdf(_:,_:,_:) instead")
public func pdfFRatioDist<FPT: SSFloatingPoint & Codable>(f: FPT, numeratorDF df1: FPT, denominatorDF df2: FPT) throws -> FPT {
    return try SSProbDist.FRatio.pdf(f: f, numeratorDF: df1, denominatorDF: df2)
}

@available(*, deprecated, message: "Use SSSProbDist.FRatio.cdf(_:,_:,_:) instead")
public func cdfFRatioDist<FPT: SSFloatingPoint & Codable>(f: FPT, numeratorDF df1: FPT, denominatorDF df2: FPT) throws -> FPT {
    return try SSProbDist.FRatio.cdf(f: f, numeratorDF: df1, denominatorDF: df2)
}

@available(*, deprecated, message: "Use SSSProbDist.FRatio.quantile(_:,_:,_:) instead")
public func quantileFRatioDist<FPT: SSFloatingPoint & Codable>(p: FPT,numeratorDF df1: FPT, denominatorDF df2: FPT) throws -> FPT {
    return try SSProbDist.FRatio.quantile(p: p, numeratorDF: df1, denominatorDF: df2)
}

/* noncentral */

@available(*, deprecated, message: "Use SSSProbDist.FRatio.NonCentral.para(_:,_:,_:) instead")
public func paraFRatioDist<FPT: SSFloatingPoint & Codable>(numeratorDF df1: FPT, denominatorDF df2: FPT, lambda: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.FRatio.NonCentral.para(numeratorDF: df1, denominatorDF: df2, lambda: lambda)
}

@available(*, deprecated, message: "Use SSSProbDist.FRatio.NonCentral.pdf(_:,_:,_:,_:) instead")
public func pdfFRatioDist<FPT: SSFloatingPoint & Codable>(f: FPT, numeratorDF df1: FPT, denominatorDF df2: FPT, lambda: FPT) throws -> FPT {
    return try SSProbDist.FRatio.NonCentral.pdf(f: f, numeratorDF: df1, denominatorDF: df2, lambda: lambda)
}

@available(*, deprecated, message: "Use SSSProbDist.FRatio.NonCentral.cdf(_:,_:,_:,_:) instead")
public func cdfFRatioDist<FPT: SSFloatingPoint & Codable>(f: FPT, numeratorDF df1: FPT, denominatorDF df2: FPT, lambda: FPT) throws -> FPT {
    return try SSProbDist.FRatio.NonCentral.cdf(f: f, numeratorDF: df1, denominatorDF: df2, lambda: lambda)
}
@available(*, deprecated, message: "Use SSSProbDist.LogNormal.para(_:,_:) instead")
public func paraLogNormalDist<FPT: SSFloatingPoint & Codable>(mean: FPT, variance v: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.LogNormal.para(mean: mean, variance: v)
}

@available(*, deprecated, message: "Use SSSProbDist.LogNormal.pdf(_:,_:,_:) instead")
public func pdfLogNormalDist<FPT: SSFloatingPoint & Codable>(x: FPT, mean: FPT, variance v: FPT) throws -> FPT {
    return try SSProbDist.LogNormal.pdf(x: x, mean: mean, variance: v)
}

@available(*, deprecated, message: "Use SSSProbDist.LogNormal.cdf(_:,_:) instead")
public func cdfLogNormal<FPT: SSFloatingPoint & Codable>(x: FPT, mean: FPT, variance v: FPT) throws -> FPT {
    return try SSProbDist.LogNormal.cdf(x: x, mean: mean, variance: v)
}


@available(*, deprecated, message: "Use SSSProbDist.LogNormal.quantile(_:,_:) instead")
public func quantileLogNormal<FPT: SSFloatingPoint & Codable>(p: FPT, mean: FPT, variance v: FPT) throws -> FPT {
    return try SSProbDist.LogNormal.quantile(p: p, mean: mean, variance: v)
}
@available(*, deprecated, message: "Use SSSProbDist.Beta.para(_:,_:) instead")
public func paraBetaDist<FPT: SSFloatingPoint & Codable>(shapeA a:FPT, shapeB b: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.Beta.para(shapeA: a, shapeB: b)
}
@available(*, deprecated, message: "Use SSSProbDist.Beta.pdf(_:,_:,_:) instead")
public func pdfBetaDist<FPT: SSFloatingPoint & Codable>(x: FPT, shapeA a: FPT, shapeB b: FPT) throws -> FPT {
    return try SSProbDist.Beta.pdf(x: x, shapeA: a, shapeB: b)
}
@available(*, deprecated, message: "Use SSSProbDist.Beta.cdf(_:,_:) instead")
public func cdfBetaDist<FPT: SSFloatingPoint & Codable>(x: FPT, shapeA a: FPT, shapeB b: FPT) throws -> FPT {
    return try SSProbDist.Beta.cdf(x: x, shapeA: a, shapeB: b)
}
@available(*, deprecated, message: "Use SSSProbDist.Beta.para(_:,_:) instead")
public func quantileBetaDist<FPT: SSFloatingPoint & Codable>(p: FPT, shapeA a: FPT, shapeB b: FPT) throws -> FPT {
    return try SSProbDist.Beta.quantile(p: p, shapeA: a, shapeB: b)
}
@available(*, deprecated, message: "Use SSSProbDist.Cauchy.para(_:,_:) instead")
public func paraCauchyDist<FPT: SSFloatingPoint & Codable>(location a: FPT, scale b: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.Cauchy.para(location: a, scale: b)
}
@available(*, deprecated, message: "Use SSSProbDist.Beta.pdf(_:,_:,_:) instead")
public func pdfCauchyDist<FPT: SSFloatingPoint & Codable>(x: FPT, location a: FPT, scale b: FPT) throws -> FPT {
    return try SSProbDist.Cauchy.pdf(x: x, location: a, scale: b)
}
@available(*, deprecated, message: "Use SSSProbDist.Beta.para(_:,_:,_:) instead")
public func cdfCauchyDist<FPT: SSFloatingPoint & Codable>(x: FPT, location a: FPT, scale b: FPT) throws -> FPT {
    return try SSProbDist.Cauchy.cdf(x: x, location: a, scale: b)
}
@available(*, deprecated, message: "Use SSSProbDist.Beta.quantile(_:,_:,_:) instead")
public func quantileCauchyDist<FPT: SSFloatingPoint & Codable>(p: FPT, location a: FPT, scale b: FPT) throws -> FPT {
    return try SSProbDist.Cauchy.quantile(p: p, location: a, scale: b)
}
@available(*, deprecated, message: "Use SSSProbDist.Laplace.para(_:,_:) instead")
public func paraLaplaceDist<FPT: SSFloatingPoint & Codable>(mean: FPT, scale b: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.Laplace.para(mean: mean, scale: b)
}
@available(*, deprecated, message: "Use SSSProbDist.Laplace.pdf(_:,_:,_:) instead")
public func pdfLaplaceDist<FPT: SSFloatingPoint & Codable>(x: FPT, mean: FPT, scale b: FPT) throws -> FPT {
    return try SSProbDist.Laplace.pdf(x: x, mean: mean, scale: b)
}
@available(*, deprecated, message: "Use SSSProbDist.Laplace.cdf(_:,_:,_:) instead")
public func cdfLaplaceDist<FPT: SSFloatingPoint & Codable>(x: FPT, mean: FPT, scale b: FPT) throws -> FPT {
    return try SSProbDist.Laplace.cdf(x: x, mean: mean, scale: b)
}

@available(*, deprecated, message: "Use SSSProbDist.Laplace.quantile(_:,_:,_:) instead")
public func quantileLaplaceDist<FPT: SSFloatingPoint & Codable>(p: FPT, mean: FPT, scale b: FPT) throws -> FPT {
    return try SSProbDist.Laplace.quantile(p: p, mean: mean, scale: b)
}

@available(*, deprecated, message: "Use SSProbDist.Logistic.quantile(_:,_:) instead")
public func paraLogisticDist<FPT: SSFloatingPoint & Codable>(mean: FPT, scale b: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.Logistic.para(mean: mean, scale: b)
}

@available(*, deprecated, message: "Use SSProbDist.Logistic.pdf(_:,_:,_:) instead")
public func pdfLogisticDist<FPT: SSFloatingPoint & Codable>(x: FPT, mean: FPT, scale b: FPT) throws -> FPT {
    return try SSProbDist.Logistic.pdf(x: x, mean: mean, scale: b)
}

@available(*, deprecated, message: "Use SSProbDist.Logistic.cdf(_:,_:,_:) instead")
public func cdfLogisticDist<FPT: SSFloatingPoint & Codable>(x: FPT, mean: FPT, scale b: FPT) throws -> FPT {
    return try SSProbDist.Logistic.cdf(x: x, mean: mean, scale: b)
}

@available(*, deprecated, message: "Use SSProbDist.Logistic.quantile(_:,_:,_:) instead")
public func quantileLogisticDist<FPT: SSFloatingPoint & Codable>(p: FPT, mean: FPT, scale b: FPT) throws -> FPT {
    return try SSProbDist.Logistic.quantile(p: p, mean: mean, scale: b)
}
@available(*, deprecated, message: "Use SSProbDist.Pareto.para(_:,_:) instead")
public func paraParetoDist<FPT: SSFloatingPoint & Codable>(minimum a: FPT, shape b: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.Pareto.para(minimum: a, shape: b)
}
@available(*, deprecated, message: "Use SSProbDist.Pareto.pdf(_:,_:,_:) instead")
public func pdfParetoDist<FPT: SSFloatingPoint & Codable>(x: FPT, minimum a: FPT, shape b: FPT) throws -> FPT {
    return try SSProbDist.Pareto.pdf(x: x, minimum: a, shape: b)
}
@available(*, deprecated, message: "Use SSProbDist.Pareto.cdf(_:,_:,_:) instead")
public func cdfParetoDist<FPT: SSFloatingPoint & Codable>(x: FPT, minimum a: FPT, shape b: FPT) throws -> FPT {
    return try SSProbDist.Pareto.cdf(x: x, minimum: a, shape: b)
}
@available(*, deprecated, message: "Use SSProbDist.Pareto.quantile(_:,_:,_:) instead")
public func quantileParetoDist<FPT: SSFloatingPoint & Codable>(p: FPT, minimum a: FPT, shape b: FPT) throws -> FPT {
    return try SSProbDist.Pareto.quantile(p: p, minimum: a, shape: b)
}
@available(*, deprecated, message: "Use SSProbDist.Exponential.para(_:) instead")
public func paraExponentialDist<FPT: SSFloatingPoint & Codable>(lambda l: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.Exponential.para(lambda: l)
}
@available(*, deprecated, message: "Use SSProbDist.Exponential.pdf(_:,_:) instead")
public func pdfExponentialDist<FPT: SSFloatingPoint & Codable>(x: FPT, lambda l: FPT) throws -> FPT {
    return try SSProbDist.Exponential.pdf(x: x, lambda: l)
}
@available(*, deprecated, message: "Use SSProbDist.Exponential.cdf(_:,_:) instead")
public func cdfExponentialDist<FPT: SSFloatingPoint & Codable>(x: FPT, lambda l: FPT) throws -> FPT {
    return try SSProbDist.Exponential.cdf(x: x, lambda: l)
}
@available(*, deprecated, message: "Use SSProbDist.Exponential.quantile(_:,_:) instead")
public func quantileExponentialDist<FPT: SSFloatingPoint & Codable>(p: FPT, lambda l: FPT) throws -> FPT {
    return try SSProbDist.Exponential.quantile(p: p, lambda: l)
}
@available(*, deprecated, message: "Use SSProbDist.InverseNormal.para(_:,_:) instead")
public func paraWaldDist<FPT: SSFloatingPoint & Codable>(mean a: FPT, lambda b: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.InverseNormal.para(mean: a, lambda: b)
}
@available(*, deprecated, message: "Use SSProbDist.InverseNormal.pdf(_:,_:,_:) instead")
public func pdfWaldDist<FPT: SSFloatingPoint & Codable>(x: FPT, mean a: FPT, lambda b: FPT) throws -> FPT {
    return try SSProbDist.InverseNormal.pdf(x: x, mean: a, lambda: b)
}
@available(*, deprecated, message: "Use SSProbDist.InverseNormal.cdf(_:,_:,_:) instead")
public func cdfWaldDist<FPT: SSFloatingPoint & Codable>(x: FPT, mean a: FPT, lambda b: FPT) throws -> FPT {
    return try SSProbDist.InverseNormal.cdf(x: x, mean: a, lambda: b)
}
@available(*, deprecated, message: "Use SSProbDist.InverseNormal.quantile(_:,_:,_:) instead")
public func quantileWaldDist<FPT: SSFloatingPoint & Codable>(p: FPT, mean a: FPT, lambda b: FPT) throws -> FPT {
    return try SSProbDist.InverseNormal.quantile(p: p, mean: a, lambda: b)
}
@available(*, deprecated, message: "Use SSProbDist.InverseNormal.para(_:,_:) instead")
public func paraInversNormal<FPT: SSFloatingPoint & Codable>(mean a: FPT, lambda b: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.InverseNormal.para(mean: a, lambda: b)
}
@available(*, deprecated, message: "Use SSProbDist.InverseNormal.pdf(_:,_:,_:) instead")
public func pdfInversNormal<FPT: SSFloatingPoint & Codable>(x: FPT, mean a: FPT, lambda b: FPT) throws -> FPT {
    return try SSProbDist.InverseNormal.pdf(x: x, mean: a, lambda: b)
}
@available(*, deprecated, message: "Use SSProbDist.InverseNormal.cdf(_:,_:,_:) instead")
public func cdfInversNormal<FPT: SSFloatingPoint & Codable>(x: FPT, mean a: FPT, lambda b: FPT) throws -> FPT {
    return try SSProbDist.InverseNormal.cdf(x: x, mean: a, lambda: b)
}
@available(*, deprecated, message: "Use SSProbDist.InverseNormal.quantile(_:,_:,_:) instead")
public func quantileInversNormal<FPT: SSFloatingPoint & Codable>(p: FPT, mean a: FPT, lambda b: FPT) throws -> FPT {
    return try SSProbDist.InverseNormal.quantile(p: p, mean: a, lambda: b)
}
@available(*, deprecated, message: "Use SSProbDist.Gamma.para(_:,_:) instead")
public func paraGammaDist<FPT: SSFloatingPoint & Codable>(shape a: FPT, scale b: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.Gamma.para(shape: a, scale: b)
}
@available(*, deprecated, message: "Use SSProbDist.Gamma.pdf(_:,_:,_:) instead")
public func pdfGammaDist<FPT: SSFloatingPoint & Codable>(x: FPT, shape a: FPT, scale b: FPT) throws -> FPT {
    return try SSProbDist.Gamma.pdf(x: x, shape: a, scale: b)
}
@available(*, deprecated, message: "Use SSProbDist.Gamma.cdf(_:,_:,_:) instead")
public func cdfGammaDist<FPT: SSFloatingPoint & Codable>(x: FPT, shape a: FPT, scale b: FPT) throws -> FPT {
    return try SSProbDist.Gamma.cdf(x: x, shape: a, scale: b)
}
@available(*, deprecated, message: "Use SSProbDist.Gamma.quantile(_:,_:,_:) instead")
public func quantileGammaDist<FPT: SSFloatingPoint & Codable>(p: FPT, shape a: FPT, scale b: FPT) throws -> FPT {
    return try SSProbDist.Gamma.quantile(p: p, shape: a, scale: b)
}
@available(*, deprecated, message: "Use SSProbDist.Erlang.para(_:,_:) instead")
public func paraErlangDist<FPT: SSFloatingPoint & Codable>(shape k: UInt, rate lambda: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.Erlang.para(shape: k, rate: lambda)
}
@available(*, deprecated, message: "Use SSProbDist.Erlang.pdf(_:,_:,_:) instead")
public func pdfErlangDist<FPT: SSFloatingPoint & Codable>(x: FPT, shape k: UInt, rate lambda: FPT) throws -> FPT {
    return try SSProbDist.Erlang.pdf(x: x, shape: k, rate: lambda)
}
@available(*, deprecated, message: "Use SSProbDist.Erlang.cdf(_:,_:,_:) instead")
public func cdfErlangDist<FPT: SSFloatingPoint & Codable>(x: FPT, shape k: UInt, rate lambda: FPT) throws -> FPT {
    return try SSProbDist.Erlang.cdf(x: x, shape: k, rate: lambda)
}
@available(*, deprecated, message: "Use SSProbDist.Erlang.quantile(_:,_:,_:) instead")
public func quantileErlangDist<FPT: SSFloatingPoint & Codable>(p: FPT, shape k: UInt!, rate lambda: FPT) throws -> FPT {
    return try SSProbDist.Erlang.quantile(p: p, shape: k, rate: lambda)
}
@available(*, deprecated, message: "Use SSProbDist.Weibull.para(_:,_:,_:) instead")
public func paraWeibullDist<FPT: SSFloatingPoint & Codable>(location loc: FPT, scale: FPT, shape: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.Weibull.para(location: loc, scale: scale, shape: shape)
}
@available(*, deprecated, message: "Use SSProbDist.Weibull.pdf(_:,_:,_:,_:) instead")
public func pdfWeibullDist<FPT: SSFloatingPoint & Codable>(x: FPT, location a: FPT, scale b: FPT, shape c: FPT) throws -> FPT {
    return try SSProbDist.Weibull.pdf(x: x, location: a, scale: b, shape: c)
}
@available(*, deprecated, message: "Use SSProbDist.Weibull.cdf(_:,_:,_:,_:) instead")
public func cdfWeibullDist<FPT: SSFloatingPoint & Codable>(x: FPT, location a: FPT, scale b: FPT, shape c: FPT) throws -> FPT {
    return try SSProbDist.Weibull.cdf(x: x, location: a, scale: b, shape: c)
}
@available(*, deprecated, message: "Use SSProbDist.Weibull.quantile(_:,_:,_:,_:) instead")
public func quantileWeibullDist<FPT: SSFloatingPoint & Codable>(p: FPT, location a: FPT, scale b: FPT, shape c: FPT) throws -> FPT {
    return try SSProbDist.Weibull.quantile(p: p, location: a, scale: b, shape: c)
}
@available(*, deprecated, message: "Use SSProbDist.Uniform.para(_:,_:) instead")
public func paraUniformDist<FPT: SSFloatingPoint & Codable>(lowerBound a: FPT, upperBound b: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.Uniform.para(lowerBound: a, upperBound: b)
}
@available(*, deprecated, message: "Use SSProbDist.Uniform.pdf(_:,_:,_:) instead")
public func pdfUniformDist<FPT: SSFloatingPoint & Codable>(x: FPT, lowerBound a: FPT, upperBound b: FPT) throws -> FPT {
    return try SSProbDist.Uniform.pdf(x: x, lowerBound: a, upperBound: b)
}
@available(*, deprecated, message: "Use SSProbDist.Uniform.cdf(_:,_:,_:) instead")
public func cdfUniformDist<FPT: SSFloatingPoint & Codable>(x: FPT, lowerBound a: FPT, upperBound b: FPT) throws -> FPT {
    return try SSProbDist.Uniform.cdf(x: x, lowerBound: a, upperBound: b)
}
@available(*, deprecated, message: "Use SSProbDist.Uniform.quantile(_:,_:,_:) instead")
public func quantileUniformDist<FPT: SSFloatingPoint & Codable>(p: FPT, lowerBound a: FPT, upperBound b: FPT) throws -> FPT {
    return try SSProbDist.Uniform.quantile(p: p, lowerBound: a, upperBound: b)
}
@available(*, deprecated, message: "Use SSProbDist.Triangular.para(_:,_:,_:) instead")
public func paraTriangularDist<FPT: SSFloatingPoint & Codable>(lowerBound a: FPT, upperBound b: FPT, mode c: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.Triangular.para(lowerBound: a, upperBound: b, mode: c)
}
@available(*, deprecated, message: "Use SSProbDist.Triangular.pdf(_:,_:,_:,_:) instead")
public func pdfTriangularDist<FPT: SSFloatingPoint & Codable>(x: FPT, lowerBound a: FPT, upperBound b: FPT, mode c: FPT) throws -> FPT {
    return try SSProbDist.Triangular.pdf(x: x, lowerBound: a, upperBound: b, mode: c)
}
@available(*, deprecated, message: "Use SSProbDist.Triangular.cdf(_:,_:,_:,_:) instead")
public func cdfTriangularDist<FPT: SSFloatingPoint & Codable>(x: FPT, lowerBound a: FPT, upperBound b: FPT, mode c: FPT) throws -> FPT {
    return try SSProbDist.Triangular.cdf(x: x, lowerBound: a, upperBound: b, mode: c)
}
@available(*, deprecated, message: "Use SSProbDist.Triangular.quantile(_:,_:,_:,_:) instead")
public func quantileTriangularDist<FPT: SSFloatingPoint & Codable>(p: FPT, lowerBound a: FPT, upperBound b: FPT, mode c: FPT) throws -> FPT {
    return try SSProbDist.Triangular.quantile(p: p, lowerBound: a, upperBound: b, mode: c)
}
@available(*, deprecated, message: "Use SSProbDist.Triangular.para(_:,_:) instead")
public func paraTriangularDist<FPT: SSFloatingPoint & Codable>(lowerBound a: FPT, upperBound b: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.Triangular.para(lowerBound: a, upperBound: b)
}
@available(*, deprecated, message: "Use SSProbDist.Triangular.pdf(_:,_:,_:) instead")
public func pdfTriangularDist<FPT: SSFloatingPoint & Codable>(x: FPT, lowerBound a: FPT, upperBound b: FPT) throws -> FPT {
    return try SSProbDist.Triangular.pdf(x: x, lowerBound: a, upperBound: b)
}
@available(*, deprecated, message: "Use SSProbDist.Triangular.cdf(_:,_:,_:) instead")
public func cdfTriangularDist<FPT: SSFloatingPoint & Codable>(x: FPT, lowerBound a: FPT, upperBound b: FPT) throws -> FPT {
    return try SSProbDist.Triangular.cdf(x: x, lowerBound: a, upperBound: b)
}
@available(*, deprecated, message: "Use SSProbDist.Triangular.quantile(_:,_:,_:) instead")
public func quantileTriangularDist<FPT: SSFloatingPoint & Codable>(p: FPT, lowerBound a: FPT, upperBound b: FPT) throws -> FPT {
    return try SSProbDist.Triangular.quantile(p: p, lowerBound: a, upperBound: b)
}
@available(*, deprecated, message: "Use SSProbDist.Gaussian.para(_:,_:) instead")
public func paraNormalDistribution<FPT: SSFloatingPoint & Codable>(mean m: FPT, standardDeviation s: FPT) -> SSContProbDistParams<FPT>? {
    return SSProbDist.Gaussian.para(mean: m, standardDeviation: s)
}
@available(*, deprecated, message: "Use SSProbDist.Gaussian.cdf(_:,_:,_:) instead")
public func cdfNormalDist<FPT: SSFloatingPoint & Codable>(x: FPT, mean m: FPT, standardDeviation sd: FPT) throws -> FPT {
    return try SSProbDist.Gaussian.cdf(x: x, mean: m, standardDeviation: sd)
}
@available(*, deprecated, message: "Use SSProbDist.Gaussian.para(_:,_:,_:) instead")
public func cdfNormalDist<FPT: SSFloatingPoint & Codable>(x: FPT, mean m: FPT, variance v: FPT) throws -> FPT {
    return try SSProbDist.Gaussian.cdf(x: x, mean: m, variance: v)
}
@available(*, deprecated, message: "Use SSProbDist.Gaussian.pdf(_:,_:,_:) instead")
public func pdfNormalDist<FPT: SSFloatingPoint & Codable>(x: FPT, mean m: FPT, standardDeviation sd: FPT) throws -> FPT  {
    return try SSProbDist.Gaussian.pdf(x: x, mean: m, standardDeviation: sd)
}
@available(*, deprecated, message: "Use SSProbDist.Gaussian.pdf(_:,_:,_:) instead")
public func pdfNormalDist<FPT: SSFloatingPoint & Codable>(x: FPT, mean m: FPT, variance v: FPT) throws -> FPT  {
    return try SSProbDist.Gaussian.pdf(x: x, mean: m, variance: v)
}
@available(*, deprecated, message: "Use SSProbDist.Gaussian.quantile(_:,_:,_:) instead")
public func quantileNormalDist<FPT: SSFloatingPoint & Codable>(p: FPT, mean m: FPT, standardDeviation sd: FPT) throws -> FPT {
    return try SSProbDist.Gaussian.quantile(p: p, mean: m, standardDeviation: sd)
}
@available(*, deprecated, message: "Use SSProbDist.Gaussian.quantile(_:,_:,_:) instead")
public func quantileNormalDist<FPT: SSFloatingPoint & Codable>(p: FPT, mean m: FPT, variance v: FPT) throws -> FPT {
    return try SSProbDist.Gaussian.quantile(p: p, mean: m, variance: v)
}
@available(*, deprecated, message: "Use SSProbDist.Gaussian.Standard.cdf(_:) instead")
public func cdfStandardNormalDist<FPT: SSFloatingPoint & Codable>(u: FPT) -> FPT {
    return SSProbDist.Gaussian.Standard.cdf(u: u)
}
@available(*, deprecated, message: "Use SSProbDist.Gaussian.Standard.pdf(_:) instead")
public func pdfStandardNormalDist<FPT: SSFloatingPoint & Codable>(u: FPT!) -> FPT {
    return SSProbDist.Gaussian.Standard.pdf(u: u)
}
@available(*, deprecated, message: "Use SSProbDist.Gaussian.Standard.quantile(_:) instead")
public func quantileStandardNormalDist<T: SSFloatingPoint & Codable>(p: T) throws -> T {
    return try SSProbDist.Gaussian.Standard.quantile(p: p)
}
@available(*, deprecated, message: "Use SSProbDist.Poisson.cdf(_:,_:,_:) instead")
public func cdfPoissonDist<FPT: SSFloatingPoint & Codable>(k: Int, rate lambda: FPT, tail: SSCDFTail) throws -> FPT {
    return try SSProbDist.Poisson.cdf(k: k, rate: lambda, tail: tail)
}
@available(*, deprecated, message: "Use SSProbDist.Poisson.pdf(_:,_:) instead")
public func pdfPoissonDist<FPT: SSFloatingPoint & Codable>(k: Int, rate lambda: FPT) throws -> FPT {
    return try SSProbDist.Poisson.pdf(k: k, rate: lambda)
}
@available(*, deprecated, message: "Use SSProbDist.Rayleigh.para(_:) instead")
public func paraRayleighDist<FPT: SSFloatingPoint & Codable>(scale s: FPT) throws -> SSContProbDistParams<FPT>  {
    return try SSProbDist.Rayleigh.para(scale: s)
}
@available(*, deprecated, message: "Use SSProbDist.Rayleigh.pdf(_:,_:) instead")
public func pdfRayleighDist<FPT: SSFloatingPoint & Codable>(x: FPT, scale s: FPT) throws -> FPT {
    return try SSProbDist.Rayleigh.pdf(x: x, scale: s)
}
@available(*, deprecated, message: "Use SSProbDist.Rayleigh.cdf(_:,_:) instead")
public func cdfRayleighDist<FPT: SSFloatingPoint & Codable>(x: FPT, scale s: FPT) throws -> FPT  {
    return try SSProbDist.Rayleigh.cdf(x: x, scale: s)
}
@available(*, deprecated, message: "Use SSProbDist.Rayleigh.quantile(_:,_:) instead")
public func quantileRayleighDist<FPT: SSFloatingPoint & Codable>(p: FPT, scale s: FPT) throws -> FPT {
    return try SSProbDist.Rayleigh.quantile(p: p, scale: s)
}
@available(*, deprecated, message: "Use SSProbDist.ExtremeValue.para(_:,_:) instead")
public func paraExtremValueDist<FPT: SSFloatingPoint & Codable>(location a: FPT, scale b: FPT) throws -> SSContProbDistParams<FPT> {
    return try SSProbDist.ExtremeValue.para(location: a, scale: b)
}
@available(*, deprecated, message: "Use SSProbDist.ExtremeValue.pdf(_:,_:,_:) instead")
public func pdfExtremValueDist<FPT: SSFloatingPoint & Codable>(x: FPT, location a: FPT, scale b: FPT) throws -> FPT {
    return try SSProbDist.ExtremeValue.pdf(x: x, location: a, scale: b)
}
@available(*, deprecated, message: "Use SSProbDist.ExtremeValue.cdf(_:,_:,_:) instead")
public func cdfExtremValueDist<FPT: SSFloatingPoint & Codable>(x: FPT, location a: FPT, scale b: FPT) throws -> FPT {
    return try SSProbDist.ExtremeValue.cdf(x: x, location: a, scale: b)
}
@available(*, deprecated, message: "Use SSProbDist.ExtremeValue.quantile(_:,_:,_:) instead")
public func quantileExtremValueDist<FPT: SSFloatingPoint & Codable>(p: FPT, location a: FPT, scale b: FPT) throws -> FPT {
    return try SSProbDist.ExtremeValue.quantile(p: p, location: a, scale: b)
}

//
//  Created by VT on 25.07.18.
//  Copyright © 2018 strike65. All rights reserved.
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

/// Extends the FloatingPoint Protocol by adding important constants
public protocol SSFloatingPoint: FloatingPoint {
    /// 0
    static var zero: Self { get }
    
    /// -1
    static var minusOne: Self { get }
    
    /// 1
    static var one: Self { get }
    /// 1 / 2
    static var half: Self { get }
    /// 1 / 4
    static var fourth: Self { get }
    /// 1 / 3
    static var third: Self { get }
    /// 2 / 3
    static var twothirds: Self { get }

    /// 2 / pi
    static var twoopi: Self { get }
    /// pi / 4
    static var pifourth :Self { get }

    /// pi / 3
    static var pithirds: Self { get }
    
    /// 2 pi / 3
    static var twopithird: Self { get }
    
    /// 3 pi / 4
    static var threepifourth :Self { get }

    /// Euler's gamma
    static var eulergamma:Self { get }

    /// sqrt(pi)
    static var sqrtpi: Self { get }

    /// 2 sqrt(pi)
    static var twosqrtpi: Self { get }
    /// 3 pi / 9
    static var threepiate: Self { get }

    
    /// ln(sqrt(2))
    static var lnsqrt2: Self { get }

    /// sqrt(2)
    static var sqrt2: Self { get }

    /// sqrt(1 / (2 pi))
    static var sqrt2piinv: Self { get }

    /// Returns sqrt(2 / pi)
    static var sqrt2Opi: Self { get }

    //( ln(sqrt(pi))
    static var lnsqrtpi: Self { get }

    /// sqrt(2 pi)
    static var sqrt2pi: Self { get }

    /// ln(sqrt(2 pi))
    static var lnsqrt2pi: Self { get }

    /// pi / 2
    static var pihalf: Self { get }

    /// sqrt(pi / 2)
    static var sqrtpihalf: Self { get }

    /// ln(2)
    static var ln2: Self { get }

    /// ln(10)
    static var ln10: Self { get }

    /// 1 / 12
    static var oo12: Self { get }

    /// 1 / 18
    static var oo18: Self { get }

    /// 1 / 24
    static var oo24: Self { get }

    /// 2 pi
    static var twopi: Self { get }

    /// pi * pi
    static var pisquared: Self { get }

    /// 1 / (2 pi)
    static var oo2pi: Self { get }

    /// ln(pi)
    static var lnpi: Self { get }

    /// 1 / pi
    static var oopi: Self { get }

    /// sqrt(3)
    static var sqrt3: Self { get }

    /// 1 / sqrt(pi)
    static var oosqrtpi: Self { get }

    /// 1 / 3
    static var oo3: Self { get }

    /// 1 / 6
    static var oo6: Self { get }

    /// 2 / 3
    static var twoo3: Self { get }

    /// pow(2, 1/4)
    static var twoexpfourth : Self { get }

    /// sqrt(6)
    static var sqrt6: Self { get }

    static var maxgamma: Self { get }

}

extension Double: SSFloatingPoint {
    
    
    public static var threepiate: Double {
        return 1.1780972450961724644234912687298135815739
    }
    
    public static var twosqrtpi: Double {
        return 3.5449077018110320545963349666822903655951
    }
    
    public static var twopithird: Double {
        return 2.0943951023931954923084289221863352561314
    }
    

    // 0
    public static var zero: Double {
        get {
            return 0
        }
    }
    // -1
    public static var minusOne: Double {
        get {
            return -1
        }
    }
    
    // 1
    public static var one: Double {
        get {
            return 1
        }
    }
    

    // 1 / 2
    public static var half: Double {
        get {
            return 5.0000000000000000000000000000000000000000e-01
        }
    }
    // 1 / 3
    public static var third: Double {
        get {
            return 3.3333333333333333333333333333333333333333e-01
        }
    }
    // 1 / 4
    public static var fourth: Double {
        get {
            return 0.2500000000000000000000000000000000000000
        }
    }

    // 2 / 3
    public static var twothirds: Double {
        get {
            return 0.6666666666666666666666666666666666666666
        }
    }

    /// 2 / pi
    public static var twoopi: Double {
        get {
            return 0.6366197723675813430755350534900574481378
        }
    }
    /// pi / 3
    public static var pithirds: Double {
        get {
            return 1.0471975511965977461542144610931676280657
        }
        
    }
    /// pi / 4
    public static var pifourth : Double {
        get {
            return 0.7853981633974483096156608458198757210493
        }
    }
    /// 3 pi / 4
    public static var threepifourth : Double {
        get {
            return 2.356194490192344928846982537459627163148
        }
    }
    /// Euler's gamma
    public static var eulergamma: Double {
        get {
            return 0.5772156649015328606065120900824024310422
        }
    }
    /// sqrt(pi)
    public static var sqrtpi: Double {
        get {
            return 1.772453850905516027298167483341145182798
        }
    }
    /// ln(sqrt(2))
    public static var lnsqrt2: Double {
        get {
            return 0.346573590279972654708616060729088284038
        }
    }
    /// sqrt(2)
    public static var sqrt2: Double {
        get {
            return 1.4142135623730950488016887242096980785696
        }
    }
    /// sqrt(1 / (2 pi))
    public static var sqrt2piinv: Double {
        get {
            return 0.3989422804014326779399460599343818684759
        }
    }
    /// Returns sqrt(2 / pi)
    public static var sqrt2Opi: Double {
        get {
            return 0.7978845608028653558798921198687637369517
        }
    }
    //( ln(sqrt(pi))
    public static var lnsqrtpi: Double {
        get {
            return 0.5723649429247000870717136756765293558236
        }
    }
    /// sqrt(2 pi)
    public static var sqrt2pi: Double {
        get {
            return 2.506628274631000502415765284811045253007
        }
    }
    /// ln(sqrt(2 pi))
    public static var lnsqrt2pi: Double {
        get {
            return 0.9189385332046727417803297364056176398614
        }
    }
    /// pi / 2
    public static var pihalf: Double {
        get {
            return 1.570796326794896619231321691639751442099
        }
    }
    /// sqrt(pi / 2)
    public static var sqrtpihalf: Double {
        get {
            return 1.253314137315500251207882642405522626503
        }
    }
    /// ln(2)
    public static var ln2: Double {
        get {
            return 0.6931471805599453094172321214581765680755
        }
    }
    /// ln(10)
    public static var ln10: Double {
        get {
            return 2.3025850929940456840179914546843642076011
        }
    }
    /// 1 / 12
    public static var oo12: Double {
        get {
            return 0.08333333333333333333333333333333333333333
        }
    }
    /// 1 / 18
    public static var oo18: Double {
        get {
            return 0.05555555555555555555555555555555555555556
        }
    }
    /// 1 / 24
    public static var oo24: Double {
        get {
            return 0.04166666666666666666666666666666666666667
        }
    }
    /// 2 pi
    public static var twopi: Double {
        get {
            return 6.283185307179586476925286766559005768394
        }
    }
    /// pi * pi
    public static var pisquared: Double {
        get {
            return 9.869604401089358618834490999876151135314
        }
    }
    /// 1 / (2 pi)
    public static var oo2pi: Double {
        get {
            return 0.1591549430918953357688837633725143620345
        }
    }
    /// ln(pi)
    public static var lnpi: Double {
        get {
            return 1.144729885849400174143427351353058711647
        }
    }
    /// 1 / pi
    public static var oopi: Double {
        get {
            return 0.3183098861837906715377675267450287240689
        }
    }
    /// sqrt(3)
    public static var sqrt3: Double {
        get {
            return 1.732050807568877293527446341505872366943
        }
    }
    /// 1 / sqrt(pi)
    public static var oosqrtpi: Double {
        get {
            return 0.5641895835477562869480794515607725858441
        }
    }
    /// 1 / 3
    public static var oo3: Double {
        get {
            return 0.3333333333333333333333333333333333333333
        }
    }
    /// 1 / 6
    public static var oo6: Double {
        get {
            return 0.1666666666666666666666666666666666666667
        }
    }
    /// 2 / 3
    public static var twoo3: Double {
        get {
            return 0.6666666666666666666666666666666666666667
        }
    }
    /// pow(2, 1/4)
    public static var twoexpfourth : Double {
        get {
            return 1.189207115002721066717499970560475915293
        }
    }
    /// sqrt(6)
    public static var sqrt6: Double {
        get {
            return 2.449489742783178098197284074705891391966
        }
    }
    
    public static var maxgamma: Double {
        get {
            return 171.624376956302
        }
    }
}

extension Float: SSFloatingPoint {
    public static var threepiate: Float {
        return 1.1780972450961724644234912687298135815739
    }
    
    public static var twosqrtpi: Float {
        return 3.5449077018110320545963349666822903655951
    }
    

    public static var twopithird: Float {
        return 2.0943951023931954923084289221863352561314
    }
    
    
    // 0
    public static var zero: Float {
        get {
            return 0
        }
    }
    
    // -1
    public static var minusOne: Float {
        get {
            return -1
        }
    }

    // 1
    public static var one: Float {
        get {
            return 1
        }
    }

    // 1 / 2
    public static var half: Float {
        get {
            return 5.0000000000000000000000000000000000000000e-01
        }
    }
    // 1 / 3
    public static var third: Float {
        get {
            return 3.3333333333333333333333333333333333333333e-01
        }
    }
    // 1 / 4
    public static var fourth: Float {
        get {
            return 0.2500000000000000000000000000000000000000
        }
    }
    // 2 / 3
    public static var twothirds: Float {
        get {
            return 0.6666666666666666666666666666666666666666
        }
    }

    /// 2 / pi
    public static var twoopi: Float {
        get {
            return 0.6366197723675813430755350534900574481378
        }
    }
    /// pi / 3
    public static var pithirds: Float {
        get {
            return 1.0471975511965977461542144610931676280657
        }
        
    }
    /// pi / 4
    public static var pifourth : Float {
        get {
            return 0.7853981633974483096156608458198757210493
        }
    }
    /// 3 pi / 4
    public static var threepifourth : Float {
        get {
            return 2.356194490192344928846982537459627163148
        }
    }
    /// Euler's gamma
    public static var eulergamma: Float {
        get {
            return 0.5772156649015328606065120900824024310422
        }
    }
    /// sqrt(pi)
    public static var sqrtpi: Float {
        get {
            return 1.772453850905516027298167483341145182798
        }
    }
    /// ln(sqrt(2))
    public static var lnsqrt2: Float {
        get {
            return 0.346573590279972654708616060729088284038
        }
    }
    /// sqrt(2)
    public static var sqrt2: Float {
        get {
            return 1.4142135623730950488016887242096980785696
        }
    }
    /// sqrt(1 / (2 pi))
    public static var sqrt2piinv: Float {
        get {
            return 0.3989422804014326779399460599343818684759
        }
    }
    /// Returns sqrt(2 / pi)
    public static var sqrt2Opi: Float {
        get {
            return 0.7978845608028653558798921198687637369517
        }
    }
    //( ln(sqrt(pi))
    public static var lnsqrtpi: Float {
        get {
            return 0.5723649429247000870717136756765293558236
        }
    }
    /// sqrt(2 pi)
    public static var sqrt2pi: Float {
        get {
            return 2.506628274631000502415765284811045253007
        }
    }
    /// ln(sqrt(2 pi))
    public static var lnsqrt2pi: Float {
        get {
            return 0.9189385332046727417803297364056176398614
        }
    }
    /// pi / 2
    public static var pihalf: Float {
        get {
            return 1.570796326794896619231321691639751442099
        }
    }
    /// sqrt(pi / 2)
    public static var sqrtpihalf: Float {
        get {
            return 1.253314137315500251207882642405522626503
        }
    }
    /// ln(2)
    public static var ln2: Float {
        get {
            return 0.6931471805599453094172321214581765680755
        }
    }
    /// ln(10)
    public static var ln10: Float {
        get {
            return 2.3025850929940456840179914546843642076011
        }
    }
    /// 1 / 12
    public static var oo12: Float {
        get {
            return 0.08333333333333333333333333333333333333333
        }
    }
    /// 1 / 18
    public static var oo18: Float {
        get {
            return 0.05555555555555555555555555555555555555556
        }
    }
    /// 1 / 24
    public static var oo24: Float {
        get {
            return 0.04166666666666666666666666666666666666667
        }
    }
    /// 2 pi
    public static var twopi: Float {
        get {
            return 6.283185307179586476925286766559005768394
        }
    }
    /// pi * pi
    public static var pisquared: Float {
        get {
            return 9.869604401089358618834490999876151135314
        }
    }
    /// 1 / (2 pi)
    public static var oo2pi: Float {
        get {
            return 0.1591549430918953357688837633725143620345
        }
    }
    /// ln(pi)
    public static var lnpi: Float {
        get {
            return 1.144729885849400174143427351353058711647
        }
    }
    /// 1 / pi
    public static var oopi: Float {
        get {
            return 0.3183098861837906715377675267450287240689
        }
    }
    /// sqrt(3)
    public static var sqrt3: Float {
        get {
            return 1.732050807568877293527446341505872366943
        }
    }
    /// 1 / sqrt(pi)
    public static var oosqrtpi: Float {
        get {
            return 0.5641895835477562869480794515607725858441
        }
    }
    /// 1 / 3
    public static var oo3: Float {
        get {
            return 0.3333333333333333333333333333333333333333
        }
    }
    /// 1 / 6
    public static var oo6: Float {
        get {
            return 0.1666666666666666666666666666666666666667
        }
    }
    /// 2 / 3
    public static var twoo3: Float {
        get {
            return 0.6666666666666666666666666666666666666667
        }
    }
    /// pow(2, 1/4)
    public static var twoexpfourth : Float {
        get {
            return 1.189207115002721066717499970560475915293
        }
    }
    /// sqrt(6)
    public static var sqrt6: Float {
        get {
            return 2.449489742783178098197284074705891391966
        }
    }
    
    public static var maxgamma: Float {
        get {
            return 35.0400981904
        }
    }
}

#if arch(i386) || arch(x86_64)
extension Float80: SSFloatingPoint {
    public static var threepiate: Float80 {
        return 1.1780972450961724644234912687298135815739
    }
    
    public static var twosqrtpi: Float80 {
        return 3.5449077018110320545963349666822903655951
    }
    

    public static var twopithird: Float80 {
        return 2.0943951023931954923084289221863352561314
    }
    

    // 0
    public static var zero: Float80 {
        get {
            return 0.0000000000000000000000000000000000000000
        }
    }
    // -1
    public static var minusOne: Float80 {
        get {
            return -1
        }
    }

    // 1
    public static var one: Float80 {
        get {
            return 1.0000000000000000000000000000000000000000
        }
    }

    // 1 / 2
    public static var half: Float80 {
        get {
            return 5.0000000000000000000000000000000000000000e-01
        }
    }
    // 1 / 3
    public static var third: Float80 {
        get {
            return 3.3333333333333333333333333333333333333333e-01
        }
    }
    // 1 / 4
    public static var fourth: Float80 {
        get {
            return 0.2500000000000000000000000000000000000000
        }
    }
    // 2 / 3
    public static var twothirds: Float80 {
        get {
            return 0.6666666666666666666666666666666666666666
        }
    }
    /// 2 / pi
    public static var twoopi: Float80 {
        get {
            return 0.6366197723675813430755350534900574481378
        }
    }
    /// pi / 3
    public static var pithirds: Float80 {
        get {
            return 1.0471975511965977461542144610931676280657
        }
        
    }
    /// pi / 4
    public static var pifourth : Float80 {
        get {
            return 0.7853981633974483096156608458198757210493
        }
    }
    /// 3 pi / 4
    public static var threepifourth : Float80 {
        get {
            return 2.356194490192344928846982537459627163148
        }
    }
    /// Euler's gamma
    public static var eulergamma: Float80 {
        get {
            return 0.5772156649015328606065120900824024310422
        }
    }
    /// sqrt(pi)
    public static var sqrtpi: Float80 {
        get {
            return 1.772453850905516027298167483341145182798
        }
    }
    /// ln(sqrt(2))
    public static var lnsqrt2: Float80 {
        get {
            return 0.346573590279972654708616060729088284038
        }
    }
    /// sqrt(2)
    public static var sqrt2: Float80 {
        get {
            return 1.4142135623730950488016887242096980785696
        }
    }
    /// sqrt(1 / (2 pi))
    public static var sqrt2piinv: Float80 {
        get {
            return 0.3989422804014326779399460599343818684759
        }
    }
    /// Returns sqrt(2 / pi)
    public static var sqrt2Opi: Float80 {
        get {
            return 0.7978845608028653558798921198687637369517
        }
    }
    //( ln(sqrt(pi))
    public static var lnsqrtpi: Float80 {
        get {
            return 0.5723649429247000870717136756765293558236
        }
    }
    /// sqrt(2 pi)
    public static var sqrt2pi: Float80 {
        get {
            return 2.506628274631000502415765284811045253007
        }
    }
    /// ln(sqrt(2 pi))
    public static var lnsqrt2pi: Float80 {
        get {
            return 0.9189385332046727417803297364056176398614
        }
    }
    /// pi / 2
    public static var pihalf: Float80 {
        get {
            return 1.570796326794896619231321691639751442099
        }
    }
    /// sqrt(pi / 2)
    public static var sqrtpihalf: Float80 {
        get {
            return 1.253314137315500251207882642405522626503
        }
    }
    /// ln(2)
    public static var ln2: Float80 {
        get {
            return 0.6931471805599453094172321214581765680755
        }
    }
    /// ln(10)
    public static var ln10: Float80 {
        get {
            return 2.3025850929940456840179914546843642076011
        }
    }
    /// 1 / 12
    public static var oo12: Float80 {
        get {
            return 0.08333333333333333333333333333333333333333
        }
    }
    /// 1 / 18
    public static var oo18: Float80 {
        get {
            return 0.05555555555555555555555555555555555555556
        }
    }
    /// 1 / 24
    public static var oo24: Float80 {
        get {
            return 0.04166666666666666666666666666666666666667
        }
    }
    /// 2 pi
    public static var twopi: Float80 {
        get {
            return 6.283185307179586476925286766559005768394
        }
    }
    /// pi * pi
    public static var pisquared: Float80 {
        get {
            return 9.869604401089358618834490999876151135314
        }
    }
    /// 1 / (2 pi)
    public static var oo2pi: Float80 {
        get {
            return 0.1591549430918953357688837633725143620345
        }
    }
    /// ln(pi)
    public static var lnpi: Float80 {
        get {
            return 1.144729885849400174143427351353058711647
        }
    }
    /// 1 / pi
    public static var oopi: Float80 {
        get {
            return 0.3183098861837906715377675267450287240689
        }
    }
    /// sqrt(3)
    public static var sqrt3: Float80 {
        get {
            return 1.732050807568877293527446341505872366943
        }
    }
    /// 1 / sqrt(pi)
    public static var oosqrtpi: Float80 {
        get {
            return 0.5641895835477562869480794515607725858441
        }
    }
    /// 1 / 3
    public static var oo3: Float80 {
        get {
            return 0.3333333333333333333333333333333333333333
        }
    }
    /// 1 / 6
    public static var oo6: Float80 {
        get {
            return 0.1666666666666666666666666666666666666667
        }
    }
    /// 2 / 3
    public static var twoo3: Float80 {
        get {
            return 0.6666666666666666666666666666666666666667
        }
    }
    /// pow(2, 1/4)
    public static var twoexpfourth : Float80 {
        get {
            return 1.189207115002721066717499970560475915293
        }
    }
    /// sqrt(6)
    public static var sqrt6: Float80 {
        get {
            return 2.449489742783178098197284074705891391966
        }
    }
    public static var maxgamma: Float80 {
        get {
            return 1755.548342904462916946872752532726735807955265045166015625
        }
    }
}

#endif

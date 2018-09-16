//
//  SwiftyStatsTests.swift
//  SwiftyStatsTests
//
//  Created by Volker Thieme on 17.07.17.
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

/*
 RosnerData.examine taken from http://www.itl.nist.gov/div898/handbook/eda/section3/eda35h3.r
 ZarrData.examine taken from http://www.itl.nist.gov/div898/handbook/eda/section4/eda4281.htm
 Normal1.examine --> normally distr. randoms mu = 0.0, sd = 1.0
 Normal2.examine --> normally distr. randoms mu = 0.0, sd = 6.0
 Normal3.examine --> normally distr. randoms mu = 2.0, sd = 1.5
 GearData.csv taken from http://www.itl.nist.gov/div898/handbook/eda/section3/eda354.htm
 */
import XCTest
@testable import SwiftyStats

class SwiftyStatsTests: XCTestCase {
    let intData: Array<Int> = [18,15,18,16,17,15,14,14,14,15,15,14,15,14,22,18,21,21,10,10,11,9,28,25,19,16,17,19,18,14,14,14,14,12,13,13,18,22,19,18,23,26,25,20,21,13,14,15,14,17,11,13,12,13,15,13,13,14,22,28,13,14,13,14,15,12,13,13,14,13,12,13,18,16,18,18,23,11,12,13,12,18,21,19,21,15,16,15,11,20,21,19,15,26,25,16,16,18,16,13,14,14,14,28,19,18,15,15,16,15,16,14,17,16,15,18,21,20,13,23,20,23,18,19,25,26,18,16,16,15,22,22,24,23,29,25,20,18,19,18,27,13,17,13,13,13,30,26,18,17,16,15,18,21,19,19,16,16,16,16,25,26,31,34,36,20,19,20,19,21,20,25,21,19,21,21,19,18,19,18,18,18,30,31,23,24,22,20,22,20,21,17,18,17,18,17,16,19,19,36,27,23,24,34,35,28,29,27,34,32,28,26,24,19,28,24,27,27,26,24,30,39,35,34,30,22,27,20,18,28,27,34,31,29,27,24,23,38,36,25,38,26,22,36,27,27,32,28]
    
    // normally distributed data mean = 0, sd = 1.0
    let normal1 = [-1.39472,0.572422,-0.807981,1.12284,0.582314,-2.02361,-1.07106,-1.07723,0.105198,-0.806512,-1.47555,0.117081,-0.40699,-0.554643,-0.0838551,-2.38265,-0.748096,1.13259,0.134903,-1.11957,-0.268167,-0.249893,-0.636138,0.411145,1.40698,0.868583,0.221741,-0.751367,-0.843731,-1.92446,-0.770097,1.34406,0.113856,0.442025,0.206676,0.448239,0.701375,-1.50239,0.118701,0.992643,0.119639,-0.0365253,0.205961,-0.37079,-0.224489,-0.428072,0.911177,-0.279192,0.560748,-0.24796,-1.05229,2.03458,-2.02889,-1.08878,-0.826172,0.381449,-0.134957,-0.07598,-1.03606,1.65422,-0.290542,0.221982,0.0674381,-0.32888,1.59649,0.418209,-0.899435,0.329175,-0.177973,1.62596,0.599629,-1.5299,-2.18709,0.297174,0.997437,1.55026,0.857938,0.177222,1.62641,-0.982871,0.307966,-0.518949,2.34573,-0.17761,2.3379,0.598934,-0.727655,0.320675,1.5864,0.0940648,0.350143,-0.617015,0.839371,0.224846,0.0201539,-1.49075,0.847894,-0.790432,1.80993,1.32279,0.141171,-1.14471,0.601558,0.678619,-0.45809,0.312201,1.3017,0.0407581,0.993514,0.931535,1.13858]
    // normally distributed data mean = 0, sd = 6.0
    let normal2 = [-1.97868,-0.427976,-2.66975,0.176478,2.25474,2.40507,-0.761118,-1.23613,0.176328,0.246937,-0.748346,0.225074,2.12719,1.86908,-1.21862,0.167204,-0.212893,0.378512,-0.924507,-1.95599,0.939617,0.0456999,0.113515,1.16326,-3.19567,-0.0980512,0.112013,-1.2179,-2.11017,0.248698,-0.696075,2.17557,1.56604,-0.379878,0.0226318,1.05484,0.355952,-1.84079,1.86957,0.340198,1.63338,-0.0842764,-0.4389,-0.0731516,-1.52269,0.410057,-1.09899,1.79384,0.834195,-1.54511,-1.10209,0.667836,0.289231,0.811264,0.63324,-0.270103,-0.434363,-0.475097,1.61421,3.88214,-1.75994,0.669145,-1.62642,-0.5134,2.11818,-0.210695,-0.415295,1.31951,2.10836,-1.7428,-0.392325,-0.826717,-0.504155,-2.68384,-0.307938,0.243413,0.596948,-3.6242,1.17498,-0.52255,1.3824,-1.19024,2.56617,1.68061,-1.18291,-0.535121,-1.88233,-0.554142,-0.870762,0.73745,-0.737186,1.13752,-1.35994,-0.560269,0.619597,-0.588878,-0.660138,0.17239,2.23929,-0.642425,-2.40169,-1.02126,0.607818,-0.503528,1.04194,-2.77603,-2.34118,-0.0410913,0.524286,0.602759,-1.17653]
    // normally distributed data mean = 2, sd = 1.5
    let normal3 = [1.36006,-0.246289,1.43112,0.811084,1.2796,1.25608,3.68661,1.86247,1.51717,1.77718,6.45058,0.831263,2.51442,2.79311,3.34225,1.64312,-1.3939,1.1648,3.28153,0.830627,2.94934,3.8969,0.762779,2.72686,6.35514,3.23959,1.94143,1.7125,5.14749,0.0266368,2.35417,1.40718,2.29764,0.873589,3.03813,3.28821,2.35882,2.62306,3.68845,3.98375,2.68762,3.4678,1.61238,1.36748,1.41429,0.858909,3.5106,1.63765,4.11641,-0.675375,1.8475,-0.595252,1.98112,0.358589,2.01333,3.26077,2.31679,5.3696,3.04103,-1.3282,4.05513,1.58629,1.77726,1.7793,-0.0743819,4.99872,2.4563,-0.0183636,3.86533,2.69593,0.459153,2.56991,2.81289,3.39954,1.66538,2.40858,-0.559767,1.64667,0.706113,1.82405,-0.510256,0.773982,2.13633,1.05356,5.27519,-0.628657,0.604019,0.404042,0.410413,1.23801,1.25667,2.04208,4.0242,4.03866,0.306506,2.19311,2.88265,2.42201,4.6352,3.31063,3.10571,1.16181,1.83808,0.309436,1.77448,3.02173,1.81139,1.68856,4.96991,0.307478,1.40293]
    // data generated by Mathematic RandomVariate
    let laplaceData = [-2.03679,0.518416,-1.72556,3.07248,1.58415,0.55357,1.13785,2.77352,0.692562,-0.246844,1.07308,0.676815,2.61719,0.839612,0.657608,1.60029,0.934251,1.64299,4.83994,-0.572193,0.590732,-2.30579,-3.46328,4.6823,2.65601,1.66736,0.0644071,0.561031,2.19092,1.10959,0.952764,4.28232,0.360738,3.43897,-0.122254,-3.22326,7.96229,-5.32675,1.4503,-2.94508,1.36242,1.0414,0.421444,3.61022,1.26506,-3.94449,-0.544188,2.88665,2.00745,-3.01688,1.0722,-0.327354,1.46366,1.52667,3.71474,1.24921,2.36462,2.111,-0.704057,6.7197,7.54793,2.76588,0.470362,0.467676,1.16809,2.11906,-3.79051,2.17474,4.64406,-1.69926,0.967686,-3.22085,1.72475,1.17087,1.03924,0.230923,1.4176,0.897564,-6.89486,-5.64721,1.07495,1.78927,8.24184,5.95395,0.793648,1.89169,1.25558,4.3064,-1.33544,5.67814,-6.36738,-0.372883,0.13142,0.786708,-0.0932199,-4.06743,4.07498,-0.482598,-1.49333,1.61442,-2.27068,1.55111,-2.59695,4.47164,-0.776884,0.884446,3.70967,0.858531,3.33213,-7.62385,0.0583429,-0.148588,-1.24765,8.67548,0.860613,1.36125,-9.48455,-0.831406,-1.86396,2.10917,4.551,1.064,1.97283,3.82057,2.29935,-1.74418,0.244115,-0.837016,2.53457,1.61,1.54181,-1.54528,-0.943004,-0.738644,-0.680302,0.358243,5.85945,0.920141,0.645741,0.675258,0.833122,0.0261111,0.593711,1.10065,0.956418,-0.194063,3.37702,-1.40828,0.853448,-1.26089]
    // data from http://www.itl.nist.gov/div898/handbook/eda/section4/eda425.htm
    let lewData = [-213.0, -564.0, -35.0, -15.0, 141.0, 115.0, -420.0, -360.0, 203.0, -338.0, -431.0, 194.0, -220.0, -513.0, 154.0, -125.0, -559.0, 92.0, -21.0, -579.0, -52.0, 99.0, -543.0, -175.0, 162.0, -457.0, -346.0, 204.0, -300.0, -474.0, 164.0, -107.0, -572.0, -8.0, 83.0, -541.0, -224.0, 180.0, -420.0, -374.0, 201.0, -236.0, -531.0, 83.0, 27.0, -564.0, -112.0, 131.0, -507.0, -254.0, 199.0, -311.0, -495.0, 143.0, -46.0, -579.0, -90.0, 136.0, -472.0, -338.0, 202.0, -287.0, -477.0, 169.0, -124.0, -568.0, 17.0, 48.0, -568.0, -135.0, 162.0, -430.0, -422.0, 172.0, -74.0, -577.0, -13.0, 92.0, -534.0, -243.0, 194.0, -355.0, -465.0, 156.0, -81.0, -578.0, -64.0, 139.0, -449.0, -384.0, 193.0, -198.0, -538.0, 110.0, -44.0, -577.0, -6.0, 66.0, -552.0, -164.0, 161.0, -460.0, -344.0, 205.0, -281.0, -504.0, 134.0, -28.0, -576.0, -118.0, 156.0, -437.0, -381.0, 200.0, -220.0, -540.0, 83.0, 11.0, -568.0, -160.0, 172.0, -414.0, -408.0, 188.0, -125.0, -572.0, -32.0, 139.0, -492.0, -321.0, 205.0, -262.0, -504.0, 142.0, -83.0, -574.0, 0.0, 48.0, -571.0, -106.0, 137.0, -501.0, -266.0, 190.0, -391.0, -406.0, 194.0, -186.0, -553.0, 83.0, -13.0, -577.0, -49.0, 103.0, -515.0, -280.0, 201.0, 300.0, -506.0, 131.0, -45.0, -578.0, -80.0, 138.0, -462.0, -361.0, 201.0, -211.0, -554.0, 32.0, 74.0, -533.0, -235.0, 187.0, -372.0, -442.0, 182.0, -147.0, -566.0, 25.0, 68.0, -535.0, -244.0, 194.0, -351.0, -463.0, 174.0, -125.0, -570.0, 15.0, 72.0, -550.0, -190.0, 172.0, -424.0, -385.0, 198.0, -218.0,-536.0, 96.0]
    // data from http://www.itl.nist.gov/div898/handbook/prc/section3/prc35.htm
    let wafer1 = [0.55,0.67,0.43,0.51,0.48,0.60,0.71,0.53,0.44,0.65,0.75]
    let wafer2 = [0.49,0.68,0.59,0.72,0.67,0.75,0.65,0.77,0.62,0.48,0.59]
    
    let s1:Array<Double> = [3,4,2,6,2,5]
    let s2:Array<Double> = [9,7,5,10,6,8]
    let s3 = [118,122.0,124,130,141]
    let s4 = [121,121.0,121,136,136]
    
    let sign1 = [1.0,1.0,1.0,1.0,1.0,1.0,1.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0]
    let sign2 = [1.0,1.0,1.0,1.0,1.0,1.0,1.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0]
    let sign3 = [443.0,421,436,376,458,408,422,431,459,369,360,431,403,436,376,370,443]
    let sign4 = [ 57.0,352,587,415,458,424,463,583,432,379,370,584,422,587,415,419,57]
    
    
    let platykurtic = [5.7728845, 7.5535649, 9.7071630, 1.1721005, 4.4890050, 4.6370910, 1.9418752, 5.3292573, 2.3551720, 0.0322585]
    let leptokurtic = [-0.99808161,  1.01298806, -2.40529552,  3.20590325, -0.30694220, -0.42411268, -0.91262052,  0.41535032,  0.02999767, -0.02770408]
    let leftskewed = [10,10,10,10,3,4,5]
    let rightskewed = [1,1,1,1,1,1,1,1,2,3,4,10]
    let symmetric = [1,2,2,3,3,3,4,4,4,4,5,5,5,6,6,7]
    let concentr1 = [0.2,0.2,0.2,0.2,0.2]
    let concentr2 = [0.5,0.2,0.1,0.1,0.1]
    let concentr3 = [1.0,0,0,0,0]
    
    
    var resPath: String! = nil
    var linuxBundle: Bundle! = nil
    
    func linuxResourcePath(resource: String!, type: String!) -> String? {
        if let s = linuxBundle.path(forResource: resource, ofType: type) {
            return s
        }
        else {
            return nil
        }
    }
    override func setUp() {
        super.setUp()
        #if os(macOS) || os(iOS)
            resPath = Bundle(for: type(of: self)).resourcePath
        #else
            linuxBundle = Bundle(path: (Bundle.main.resourcePath ?? ".") + "/Resources") ?? Bundle.main
        #endif
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    
    func testTukeyKramer() {

 // Data from http://www.itl.nist.gov/div898/handbook/prc/section4/prc436.htm#example1
        #if os(macOS) || os(iOS)
        let df: SSDataFrame<Double, Double> = try! SSDataFrame.dataFrame(fromFile: resPath + "/TukeyKramerData_01.csv", scanDouble)
        let df1: SSDataFrame<Double, Double> = try! SSDataFrame.dataFrame(fromFile: resPath + "/TukeyKramerData_02.csv", scanDouble)
        #else
        let df: SSDataFrame<Double, Double>  = try! SSDataFrame.dataFrame(fromString: TukeyKramerData_01String, parser: scanDouble)
        let df1: SSDataFrame<Double, Double>  = try! SSDataFrame.dataFrame(fromString: TukeyKramerData_02String, parser: scanDouble)
        print("TukeyKramerData01 read")
        #endif
/*
         var test = try! SSHypothesisTesting.tukeyKramerTest(dataFrame: df, alpha: 0.05)!
        XCTAssertEqual(test[0].testStat, 4.6133, accuracy: 1E-04)
        XCTAssertEqual(test[1].testStat, 6.2416, accuracy: 1E-04)
        XCTAssertEqual(test[2].testStat, 0.3101, accuracy: 1E-04)
        XCTAssertEqual(test[3].testStat, 1.6282, accuracy: 1E-04)
        XCTAssertEqual(test[4].testStat, 4.3032, accuracy: 1E-04)
        XCTAssertEqual(test[5].testStat, 5.9314, accuracy: 1E-04)
 */
        /*
         A <- c(27, 27, 25, 26, 25)       # multiple Vergleiche nach Tukey-Kramer
         > B <- c(26, 25, 26, 25, 24)
         > C <- c(21, 21, 20, 20, 22)
         > nA <- length(A); nB <- length(B); nC <- length(C)
         > f  <- nA + nB + nC - 3
         > mA <- mean(A);   mB <- mean(B);   mC <- mean(C)
         > s  <- sqrt((sum((A-mA)^2)+sum((B-mB)^2)+sum((C-mC)^2)) / f)
         > T.AB <- (mA - mB) / (s*sqrt(0.5*(1/nA + 1/nB))); T.AB
        */
        var test = try! SSHypothesisTesting.tukeyKramerTest(dataFrame: df1, alpha: 0.05)!
        XCTAssertEqual(test[0].testStat, 2.0, accuracy: 1E-01)
        XCTAssertEqual(test[1].testStat, 13.0, accuracy: 1E-01)
        XCTAssertEqual(test[2].testStat, 11.0, accuracy: 1E-01)
/*        test = try! SSHypothesisTesting.scheffeTest(dataFrame: df, alpha: 0.05)!
        XCTAssertEqual(test[0].testStat, 3.2621, accuracy: 1E-04)
        XCTAssertEqual(test[1].testStat, 4.4134, accuracy: 1E-04)
        XCTAssertEqual(test[2].testStat, 0.2193, accuracy: 1E-04)
        XCTAssertEqual(test[3].testStat, 1.1513, accuracy: 1E-04)
        XCTAssertEqual(test[4].testStat, 3.0428, accuracy: 1E-04)
        XCTAssertEqual(test[5].testStat, 4.1941, accuracy: 1E-04)
        test = try! SSHypothesisTesting.scheffeTest(dataFrame: df1, alpha: 0.05)!
        XCTAssertEqual(test[0].testStat, 1.4142, accuracy: 1E-04)
        XCTAssertEqual(test[1].testStat, 9.1924, accuracy: 1E-04)
        XCTAssertEqual(test[2].testStat, 7.7782, accuracy: 1E-04)
*/
        
    }
    
    func testExamine() {
        
        let examineLew = SSExamine<Double, Double>.init(withArray: lewData, name: nil, characterSet: nil)
        if let ac: Double = try! examineLew.autocorrelation() {
            XCTAssertEqual(ac, -0.307, accuracy: 1E-3)
        }

        
        var examineConc1: SSExamine<Double, Double>! = nil
        var examineConc2: SSExamine<Double, Double>! = nil
        var examineConc3: SSExamine<Double, Double>! = nil
        
        do {
            examineConc1 = try SSExamine<Double, Double>.init(withObject: concentr1, levelOfMeasurement: .ordinal, name: "market share 1", characterSet: nil)
        }
        catch is SSSwiftyStatsError {
            print("unable to get examineConc1: " + #file )
        }
        catch {
            print("other error")
        }
        XCTAssertNotNil(examineConc1)
        XCTAssertEqual(examineConc1.herfindahlIndex!, 0.2, accuracy: 1E-1)
        XCTAssertEqual(examineConc1.gini!, 0.0, accuracy: 1E-15)
        XCTAssertEqual(examineConc1.giniNorm!, 0.0, accuracy: 1E-15)
        XCTAssertEqual(examineConc1.CR(2)!, 0.4, accuracy: 1E-15)
        XCTAssertEqual(examineConc1.CR(3)!, 0.6, accuracy: 1E-15)
        do {
            examineConc2 = try SSExamine<Double, Double>.init(withObject: concentr2, levelOfMeasurement: .ordinal, name: "market share 1", characterSet: nil)
        }
        catch is SSSwiftyStatsError {
            print("unable to get examineConc2: " + #file )
        }
        catch {
            print("other error")
        }
        XCTAssertNotNil(examineConc2)
        XCTAssertEqual(examineConc2.herfindahlIndex!, 0.32, accuracy: 1E-2)
        XCTAssertEqual(examineConc2.gini!, 0.36, accuracy: 1E-2)
        XCTAssertEqual(examineConc2.giniNorm!, 0.45, accuracy: 1E-2)
        XCTAssertEqual(examineConc2.CR(2)!, 0.7, accuracy: 1E-15)
        XCTAssertEqual(examineConc2.CR(3)!, 0.8, accuracy: 1E-15)
        do {
            examineConc3 = try SSExamine<Double, Double>.init(withObject: concentr3, levelOfMeasurement: .ordinal, name: "market share 1", characterSet: nil)
        }
        catch is SSSwiftyStatsError {
            print("unable to get examineConc3: " + #file)
        }
        catch {
            print("other error")
        }
        XCTAssertNotNil(examineConc3)
        XCTAssertEqual(examineConc3.herfindahlIndex!, 1.0, accuracy: 1E-2)
        XCTAssertEqual(examineConc3.gini!, 0.8, accuracy: 1E-2)
        XCTAssertEqual(examineConc3.giniNorm!, 1.0, accuracy: 1E-2)
        XCTAssertEqual(examineConc3.CR(2)!, 1.0, accuracy: 1E-15)
        XCTAssertEqual(examineConc3.CR(3)!, 1.0, accuracy: 1E-15)
        var examineInt: SSExamine<Int, Double>! = nil
        var examineIntOutliers: SSExamine<Int, Double>! = nil
        #if os(macOS) || os(iOS)
        do {
            examineInt = try SSExamine<Int, Double>.examine(fromFile: resPath + "/IntData.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanInt)!
            examineIntOutliers = try SSExamine<Int, Double>.examine(fromFile: resPath + "/IntDataWithOutliers.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanInt)!
        }
        catch is SSSwiftyStatsError {
            print("unable to get examineInt/Outliers: " + #file)
        }
        catch {
            print("other error")
        }
        #else
        do {
            if let p = linuxResourcePath(resource: "IntData", type: "examine") {
                examineInt = try SSExamine<Int>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, scanInt)!
            }
            else {
                fatalError("No testfiles " + #file + "\(#line)")
            }
            if let p = linuxResourcePath(resource: "IntDataWithOutliers", type: "examine") {
                examineIntOutliers = try SSExamine<Int>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, scanInt)!
            }
            else {
                fatalError("No testfiles " + #file + "\(#line)")
            }
        }
        catch is SSSwiftyStatsError {
            print("unable to get examineInt/Outliers: " + #file)
        }
        catch {
            print("other error")
        }
        #endif
        XCTAssertNotNil(examineInt)
        XCTAssertNotNil(examineIntOutliers)
        let tempDir = NSTemporaryDirectory()
        //        let filename = NSUUID().uuidString
        let filename = "test.dat"
        var url = NSURL.fileURL(withPathComponents: [tempDir, filename])
        XCTAssertNotNil(url)
        do {
            if let p = url?.path {
                let s = try examineInt.saveTo(fileName: p, atomically: true, overwrite: true, separator: ",", stringEncoding: .utf8)
                XCTAssert(s)
            }
        }
        catch is SSSwiftyStatsError {
            print("unable to save examineInt")
        }
        catch {
            print("other error in save examine to file")
        }
        //        var testExamineInt: SSExamine<Int>! = nil
        do {
            if let p = url?.path {
                if let testExamineInt = try SSExamine<Int, Double>.examine(fromFile: p, separator: ",", stringEncoding: .utf8, scanInt) {
                    XCTAssert(testExamineInt.isEqual(examineInt))
                }
            }
            try FileManager.default.removeItem(at: url!)
        }
        catch is SSSwiftyStatsError {
            print("unable to load examineInt")
        }
        catch {
            print("other error in load examine from file")
        }
        do {
            XCTAssert(try examineInt.archiveTo(filePath: url?.path, overwrite: true))
            if let testExamineInt = try SSExamine<Int, Double>.unarchiveFrom(filePath: url?.path) {
                XCTAssert(testExamineInt.isEqual(examineInt))
            }
            try! FileManager.default.removeItem(at: url!)
        }
        catch is SSSwiftyStatsError {
            print("unable to archive/unarchive examineInt")
        }
        catch {
            print("other error in archive/unarchive examine")
        }
        XCTAssert(examineInt.contains(38))
        XCTAssert(!examineInt.contains(-1))
        XCTAssertEqual(examineInt.frequency(27), 10)
        XCTAssertEqual(examineInt.rFrequency(27), 10.0 / Double(examineInt.sampleSize))
        let intDataTestString = "18,15,18,16,17,15,14,14,14,15,15,14,15,14,22,18,21,21,10,10,11,9,28,25,19,16,17,19,18,14,14,14,14,12,13,13,18,22,19,18,23,26,25,20,21,13,14,15,14,17,11,13,12,13,15,13,13,14,22,28,13,14,13,14,15,12,13,13,14,13,12,13,18,16,18,18,23,11,12,13,12,18,21,19,21,15,16,15,11,20,21,19,15,26,25,16,16,18,16,13,14,14,14,28,19,18,15,15,16,15,16,14,17,16,15,18,21,20,13,23,20,23,18,19,25,26,18,16,16,15,22,22,24,23,29,25,20,18,19,18,27,13,17,13,13,13,30,26,18,17,16,15,18,21,19,19,16,16,16,16,25,26,31,34,36,20,19,20,19,21,20,25,21,19,21,21,19,18,19,18,18,18,30,31,23,24,22,20,22,20,21,17,18,17,18,17,16,19,19,36,27,23,24,34,35,28,29,27,34,32,28,26,24,19,28,24,27,27,26,24,30,39,35,34,30,22,27,20,18,28,27,34,31,29,27,24,23,38,36,25,38,26,22,36,27,27,32,28"
        
        XCTAssert(examineInt.elementsAsString(withDelimiter: ",")! == intDataTestString)
        XCTAssert(examineInt.elementsAsArray(sortOrder: .raw)! == intData)
        XCTAssert(examineInt.elementsAsArray(sortOrder: .ascending)! != intData)
        XCTAssert(examineInt.elementsAsArray(sortOrder: .descending)! != intData)
        var examineDouble: SSExamine<Double, Double>! = nil
        var examineString: SSExamine<String, Double>! = nil
        do {
            #if os(macOS) || os(iOS)
            examineDouble = try SSExamine<Double, Double>.examine(fromFile: resPath + "/DoubleData.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)
            #else
            if let p = linuxResourcePath(resource: "DoubleData", type: "examine") {
                examineDouble = try SSExamine<Double, Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)
            }
            #endif
            examineString = try SSExamine<String, Double>.init(withObject: intDataTestString, levelOfMeasurement: .nominal, name: "string data", characterSet: nil)
            XCTAssertNotNil(try SSExamine<String, Double>.init(withObject: intDataTestString, levelOfMeasurement: .nominal, name: "string data only numbers", characterSet: CharacterSet.init(charactersIn: "1234567890")))
        }
        catch is SSSwiftyStatsError {
            print("unable to load examineDouble")
        }
        catch {
            print("other error")
        }
        
        XCTAssertNotNil(SSExamine<String, Double>.examineWithString(intDataTestString, name: "string data only numbers", characterSet: CharacterSet.init(charactersIn: "1234567890")))
        let examineEmpty: SSExamine<String, Double> = examineString.copy() as! SSExamine<String, Double>
        var examineWithZero: SSExamine<Double, Double>! = nil
        var examineWithZeroMean: SSExamine<Int, Double>! = nil
        var examineSmall: SSExamine<Double, Double>! = nil
        do {
            examineWithZero = try SSExamine<Double, Double>.init(withObject: [1.0,1.0, 0.0, 1.2], levelOfMeasurement: .interval, name: "double with zero", characterSet: nil)
            examineWithZeroMean = try
                SSExamine<Int, Double>.init(withObject: [0,0,0,0,0], levelOfMeasurement: .interval, name: "all zero", characterSet: nil)
            examineSmall = try SSExamine<Double, Double>.init(withObject: [1.0], levelOfMeasurement: .interval, name: "double one element", characterSet: nil)
        }
        catch is SSSwiftyStatsError {
            print("unable examineWithZero, examineWithZeroMean, examineSmall")
        }
        catch {
            print("other error")
        }
        examineEmpty.removeAll()
        XCTAssert(examineEmpty.isEmpty)
        XCTAssertNil(examineEmpty.gini)
        XCTAssertNil(examineString.gini)
        let bw = examineDouble.boxWhisker!
        XCTAssert(bw.median! == 19)
        XCTAssert(bw.q25! == 15)
        XCTAssert(bw.q75! == 24)
        XCTAssert(bw.iqr! == 9)
        XCTAssert(bw.extremes! == [39.0, 38.0, 38.0])
        XCTAssert(bw.outliers! == [])
        XCTAssert(bw.lWhiskerExtreme! == 9)
        XCTAssert(bw.uWhiskerExtreme! == 36)
        XCTAssertEqual(bw.lNotch!,18.09703, accuracy: 1E-5)
        XCTAssertEqual(bw.uNotch!,19.90297, accuracy: 1E-5)
        let bwi = examineIntOutliers.boxWhisker!
        XCTAssert(bwi.median! == 19)
        XCTAssert(bwi.q25! == 15)
        XCTAssert(bwi.q75! == 25)
        XCTAssert(bwi.iqr! == 10)
        XCTAssert(bwi.extremes! == [])
        XCTAssert(bwi.outliers! == [300, 200, 200, 200, 101, 101, 101, 100, 100, 100, 100, 100, 100])
        XCTAssert(bwi.lWhiskerExtreme! == 1)
        XCTAssert(bwi.uWhiskerExtreme! == 39)
        XCTAssertEqual(bwi.lNotch!,18.02941, accuracy: 1E-5)
        XCTAssertEqual(bwi.uNotch!,19.97059, accuracy: 1E-5)
        XCTAssertEqual(examineDouble.elementsAsString(withDelimiter: "*"), "18.0*15.0*18.0*16.0*17.0*15.0*14.0*14.0*14.0*15.0*15.0*14.0*15.0*14.0*22.0*18.0*21.0*21.0*10.0*10.0*11.0*9.0*28.0*25.0*19.0*16.0*17.0*19.0*18.0*14.0*14.0*14.0*14.0*12.0*13.0*13.0*18.0*22.0*19.0*18.0*23.0*26.0*25.0*20.0*21.0*13.0*14.0*15.0*14.0*17.0*11.0*13.0*12.0*13.0*15.0*13.0*13.0*14.0*22.0*28.0*13.0*14.0*13.0*14.0*15.0*12.0*13.0*13.0*14.0*13.0*12.0*13.0*18.0*16.0*18.0*18.0*23.0*11.0*12.0*13.0*12.0*18.0*21.0*19.0*21.0*15.0*16.0*15.0*11.0*20.0*21.0*19.0*15.0*26.0*25.0*16.0*16.0*18.0*16.0*13.0*14.0*14.0*14.0*28.0*19.0*18.0*15.0*15.0*16.0*15.0*16.0*14.0*17.0*16.0*15.0*18.0*21.0*20.0*13.0*23.0*20.0*23.0*18.0*19.0*25.0*26.0*18.0*16.0*16.0*15.0*22.0*22.0*24.0*23.0*29.0*25.0*20.0*18.0*19.0*18.0*27.0*13.0*17.0*13.0*13.0*13.0*30.0*26.0*18.0*17.0*16.0*15.0*18.0*21.0*19.0*19.0*16.0*16.0*16.0*16.0*25.0*26.0*31.0*34.0*36.0*20.0*19.0*20.0*19.0*21.0*20.0*25.0*21.0*19.0*21.0*21.0*19.0*18.0*19.0*18.0*18.0*18.0*30.0*31.0*23.0*24.0*22.0*20.0*22.0*20.0*21.0*17.0*18.0*17.0*18.0*17.0*16.0*19.0*19.0*36.0*27.0*23.0*24.0*34.0*35.0*28.0*29.0*27.0*34.0*32.0*28.0*26.0*24.0*19.0*28.0*24.0*27.0*27.0*26.0*24.0*30.0*39.0*35.0*34.0*30.0*22.0*27.0*20.0*18.0*28.0*27.0*34.0*31.0*29.0*27.0*24.0*23.0*38.0*36.0*25.0*38.0*26.0*22.0*36.0*27.0*27.0*32.0*28.0")
        // Descriptives
        let platy:SSExamine<Double, Double> = try! SSExamine<Double, Double>.init(withObject: platykurtic, levelOfMeasurement: .interval, name: "platykurtic", characterSet: nil)
        let lepto:SSExamine<Double, Double> = try! SSExamine<Double, Double>.init(withObject: leptokurtic, levelOfMeasurement: .interval, name: "leptokurtic", characterSet: nil)
        XCTAssert(platy.kurtosisType == .platykurtic)
        XCTAssert(lepto.kurtosisType == .leptokurtic)
        let left:SSExamine<Int, Double> = try! SSExamine<Int, Double>.init(withObject: leftskewed, levelOfMeasurement: .interval, name: "leftskewed", characterSet: nil)
        let right:SSExamine<Int, Double> = try! SSExamine<Int, Double>.init(withObject: rightskewed, levelOfMeasurement: .interval, name: "rightskewed", characterSet: nil)
        let sym:SSExamine<Int, Double> = try! SSExamine<Int, Double>.init(withObject: symmetric, levelOfMeasurement: .interval, name: "rightskewed", characterSet: nil)
        XCTAssert(left.skewnessType == .leftSkewed)
        XCTAssert(right.skewnessType == .rightSkewed)
        XCTAssert(sym.skewnessType == .symmetric)
        XCTAssert(examineSmall.variance(type: .unbiased) == nil)
        XCTAssert(examineSmall.standardDeviation(type: .unbiased) == nil)

        XCTAssert(examineSmall.standardError == nil)
        XCTAssertTrue(examineWithZeroMean.contraHarmonicMean! == -Double.infinity)
        XCTAssert(examineString.total == nil)
        XCTAssert(examineString.poweredTotal(power: 2.0) == nil)
        XCTAssert(examineString.squareTotal.isNaN)
        XCTAssert(examineString.inverseTotal == nil)
        XCTAssert(examineString.arithmeticMean == nil)
        XCTAssert(examineString.harmonicMean == nil)
        XCTAssert(examineString.contraHarmonicMean == nil)
        XCTAssert(try! examineString.trimmedMean(alpha: 0.03) == nil)
        XCTAssert(try! examineString.winsorizedMean(alpha: 0.03) == nil)
        XCTAssert(examineString.product == nil)
        XCTAssertThrowsError(try examineString.quantile(q: 0.25))
        XCTAssert(examineString.quartile == nil)
        XCTAssert(examineString.moment(r: 1, type: .central) == nil)
        XCTAssert(examineString.moment(r: 1, type: .origin) == nil)
        XCTAssert(examineString.moment(r: 1, type: .standardized) == nil)
        XCTAssert(examineString.kurtosisExcess == nil)
        XCTAssert(examineString.kurtosis == nil)
        XCTAssert(examineString.hasOutliers(testType: .esd) == nil)
        XCTAssert(examineString.poweredMean(order: 1) == nil)
        XCTAssert(examineString.hasOutliers(testType: .grubbs) == nil)
        XCTAssert(examineString.mode![0] == ",")
        XCTAssert(examineString.range == nil)
        XCTAssert(examineString.interquartileRange == nil)
        XCTAssert(try! examineString.interquantileRange(lowerQuantile: 0.1, upperQuantile: 0.9)  == nil)
        XCTAssertEqual(examineString.entropy!, 2.84335939877734, accuracy: 1E-14)
        XCTAssertEqual(examineString.relativeEntropy!, 0.298193737094250, accuracy: 1E-14)
        XCTAssert(examineString.kurtosis == nil)
        XCTAssert(examineString.skewness == nil)
        XCTAssert(examineString.kurtosisExcess == nil)
        XCTAssert(examineString.kurtosisType == nil)
        XCTAssert(examineString.skewnessType == nil)
        XCTAssert(examineString.outliers(alpha: 0.55, max: 10, testType: .bothTails) == nil)
        XCTAssert(examineString.isGaussian == nil)
        
        let outliers = examineIntOutliers.outliers(alpha: 0.05, max: 10, testType: .bothTails)!
        let expectedOutliers: Array<Int> = [300,200,200,200,101,101,101,100,100,100]
        XCTAssertEqual(examineDouble.herfindahlIndex!, 0.004438149, accuracy: 1E-9)
        XCTAssertEqual(examineDouble.meanDifference!, 7.050566, accuracy: 1E-6)
        XCTAssertEqual(examineDouble.gini!, 0.1753802, accuracy: 1E-7)
        XCTAssert(outliers.count == expectedOutliers.count)
        XCTAssert(examineIntOutliers.outliers(alpha: 0.05, max: 10, testType: .bothTails) != nil)
        XCTAssertEqual(examineDouble.meanAbsoluteDeviation(center: examineDouble.arithmeticMean!)!, 5.14695, accuracy: 1E-5)
        XCTAssertEqual(examineDouble.medianAbsoluteDeviation(center: examineDouble.median!, scaleFactor: 1.0)!, 4.0, accuracy: 1E-4)
        XCTAssertEqual(examineDouble.medianAbsoluteDeviation(center: examineDouble.median!, scaleFactor: nil)!, 5.9304, accuracy: 1E-4)
        XCTAssert(examineDouble.isGaussian!)
        XCTAssertEqual(outliers, expectedOutliers)
        XCTAssert(examineWithZero.product!.isZero)
        XCTAssert(!examineDouble.hasOutliers(testType: .grubbs)!)
        XCTAssertEqual(examineDouble.inverseTotal!, 13.540959278542406, accuracy: 1.0E-14)
        XCTAssert(examineDouble.squareTotal == 110289)
        XCTAssertEqual(examineDouble.total, 4985)
        XCTAssert(examineDouble.mode![0] == 18.0)
        XCTAssertEqual(examineDouble!.commonest![0], 18.0, accuracy: 1e-1)
        XCTAssertEqual(examineDouble!.scarcest![0], 9.0, accuracy: 1e-1)
//        XCTAssert(examineDouble!.scarcest![0] == 9.0)
        XCTAssert(examineDouble!.scarcest![1] == 39.0)
        XCTAssertEqual(try! examineDouble.autocorrelation()!, 0.685, accuracy: 1E-3)
        XCTAssert(!examineDouble.hasOutliers(testType: .esd)!)
        XCTAssert(examineDouble.quartile!.q25 == 15)
        XCTAssert(examineDouble.quartile!.q50 == 19)
        XCTAssert(examineDouble.quartile!.q75 == 24)
        XCTAssertEqual(examineDouble.median, 19)
        XCTAssert(try! examineDouble.quantile(q: 0.1) == 13)
        XCTAssertThrowsError(try examineDouble.quantile(q: 1.5))
        XCTAssertEqual(examineDouble.arithmeticMean! , 20.100806451612904, accuracy: 1.0E-12)
        XCTAssertEqual(examineDouble.harmonicMean!, 18.314802880545665, accuracy: 1.0E-12)
        XCTAssert(examineDouble.gastwirth! == 19)
        XCTAssertEqual(examineDouble.geometricMean!, 19.168086630042282, accuracy: 1.0E-12)
        XCTAssertEqual(examineDouble.contraHarmonicMean!, 22.124172517552658, accuracy: 1E-14)
        XCTAssertEqual(examineDouble.poweredTotal(power: 6)!, 59385072309, accuracy: 1E-14)
        XCTAssertEqual(examineDouble.poweredMean(order: 6)!, 24.919401155182530, accuracy: 1E-10)
        XCTAssertEqual(try! examineDouble.trimmedMean(alpha: 0.05), 19.736607142857143)
        XCTAssertEqual(try! examineDouble.trimmedMean(alpha: 0.4), 18.72)
        XCTAssertEqual(try! examineDouble.winsorizedMean(alpha: 0.05)!, 20.052419354838708, accuracy: 1E-14)
        XCTAssertEqual(try! examineDouble.winsorizedMean(alpha: 0.45)!, 18.508064516129032, accuracy: 1E-14)
        XCTAssertThrowsError(try examineDouble.winsorizedMean(alpha: 0.6))
        XCTAssertThrowsError(try examineDouble.winsorizedMean(alpha: 0.0))
        XCTAssertEqual(examineDouble.poweredMean(order: 3), 22.095732180912705)
        XCTAssertEqual(examineDouble.product, Double.infinity)
        XCTAssertEqual(examineDouble.logProduct!, 732.40519187630610, accuracy: 1.0E-12)
        XCTAssertEqual(examineDouble.maximum, 39)
        XCTAssertEqual(examineDouble.minimum, 9)
        XCTAssertEqual(examineDouble.range, 30)
        XCTAssertEqual(examineDouble.midRange, 24)
        XCTAssertEqual(examineDouble.interquartileRange, 9)
        XCTAssertEqual(examineDouble.quartileDeviation, 4.5)
        XCTAssertEqual(try! examineDouble.interquantileRange(lowerQuantile: 0.1, upperQuantile: 0.9), 16)
        XCTAssertEqual(try! examineDouble.interquantileRange(lowerQuantile: 0.9, upperQuantile: 0.9), 0)
        XCTAssertEqual(examineDouble.relativeQuartileDistance!, 0.4736842, accuracy: 1E-7)
        XCTAssertEqual(examineDouble.cv!, 0.317912682758119939795, accuracy: 1E-15)
        XCTAssertEqual(examineDouble.semiVariance(type: .lower)!, 24.742644316247567, accuracy: 1E-12)
        XCTAssertEqual(examineDouble.semiVariance(type: .upper)!, 65.467428319137056, accuracy: 1E-12)
        XCTAssertEqual(examineDouble.eCDF(23), 0.72983870967741935, accuracy: 1E-14)
        XCTAssertEqual(examineDouble.eCDF(9), 0.0040322580645161290, accuracy: 1E-14)
        XCTAssertEqual(examineDouble.eCDF(39), 1.0, accuracy: 1E-14)
        XCTAssertEqual(examineDouble.eCDF(-39), 0.0)
        XCTAssertEqual(examineDouble.eCDF(2000), 1.0)
        XCTAssertEqual(examineDouble.moment(r: 0, type: .central)!, 1.0)
        XCTAssertEqual(examineDouble.moment(r: 1, type: .central)!, 0, accuracy: 1E-14)
        XCTAssertEqual(examineDouble.moment(r: 2, type: .central)!, 40.671289672216441, accuracy: 1E-12)
        XCTAssertEqual(examineDouble.moment(r: 3, type: .central)!, 213.45322268575241, accuracy: 1E-12)
        XCTAssertEqual(examineDouble.moment(r: 4, type: .central)!, 5113.3413825102367, accuracy: 1E-10)
        XCTAssertEqual(examineDouble.moment(r: 5, type: .central)!, 59456.550944779016, accuracy: 1E-10)
        XCTAssertEqual(examineDouble.moment(r: 3, type: .origin)!, 10787.608870967742, accuracy: 1E-10)
        XCTAssertEqual(examineDouble.moment(r: 5, type: .origin)!, 8020422.4798387097, accuracy: 1E-10)
        XCTAssertEqual(examineDouble.moment(r: 2, type: .standardized)!, 1.0, accuracy: 1E-4)
        XCTAssertEqual(examineDouble.moment(r: 0, type: .standardized)!, 1.0, accuracy: 1E-4)
        XCTAssertEqual(examineDouble.moment(r: 1, type: .standardized)!, 0.0, accuracy: 1E-4)
        XCTAssertEqual(examineDouble.standardDeviation(type: .unbiased)!, 6.3903013046339835, accuracy: 1E-14)
        XCTAssertEqual(examineDouble.Sn!, 5.963, accuracy: 1e-3)
        XCTAssertEqual(examineDouble.Qn!, 6.559982, accuracy: 1e-6)
        XCTAssertEqual(examineDouble.kurtosisExcess!, 0.0912127828607771, accuracy: 1E-14)
        XCTAssertEqual(examineDouble.kurtosis!, 3.0912127828607771, accuracy: 1E-14)
        XCTAssertEqual(examineDouble.skewness!, 0.82294497966005010, accuracy: 1E-14)
        XCTAssertEqual(examineDouble.skewness!, 0.822945, accuracy: 1E-6)
        XCTAssertEqual(examineDouble.kurtosis!, 3.091213, accuracy: 1E-6)
        XCTAssertEqual(examineDouble.kurtosisExcess!, 0.091213, accuracy: 1E-6)
        XCTAssertEqual(examineDouble.normalCI(alpha: 0.05, populationSD: 6.0)!.intervalWidth!, 2.0 * 0.746747, accuracy: 1e-6)
        XCTAssertEqual(examineDouble.meanCI!.intervalWidth!, 2.0 * 0.7992392, accuracy: 1e-7)
        XCTAssertEqual(examineDouble.studentTCI(alpha: 0.05)!.intervalWidth!, 2.0 * 0.7992392, accuracy: 1e-7)
        XCTAssertEqual(examineDouble.studentTCI(alpha: 0.01)!.intervalWidth!, 2.0 * 1.053368, accuracy: 1e-6)
        XCTAssertEqual(examineDouble.studentTCI(alpha: 0.1)!.intervalWidth!, 2.0 * 0.669969, accuracy: 1e-6)
        
        url = NSURL.fileURL(withPathComponents: [tempDir, "test.json"])
        XCTAssert(try! examineDouble.exportJSONString(fileName: url!.path, overwrite: true))
        let exFromJSON = try! SSExamine<Double, Double>.examine(fromJSONFile: url!.path)
        XCTAssertEqual(examineDouble, exFromJSON)
        try! FileManager.default.removeItem(at: url!)
        
        
        XCTAssert(examineEmpty.arithmeticMean == nil)
        XCTAssert(examineEmpty.harmonicMean == nil)
        XCTAssert(examineEmpty.contraHarmonicMean == nil)
        XCTAssert(examineEmpty.mode == nil)
        XCTAssert(examineEmpty.quartile == nil)
        XCTAssert(try! examineEmpty.quantile(q: 0.25) == nil)
        XCTAssert(examineEmpty.commonest == nil)
        XCTAssert(examineEmpty.scarcest == nil)
        XCTAssert(examineEmpty.total == nil)
        XCTAssert(examineEmpty.poweredTotal(power: 2.0) == nil)
        XCTAssert(examineEmpty.squareTotal.isNaN)
        XCTAssert(examineEmpty.inverseTotal == nil)
        XCTAssert(examineEmpty.arithmeticMean == nil)
        XCTAssert(examineEmpty.harmonicMean == nil)
        XCTAssert(examineEmpty.geometricMean == nil)
        XCTAssert(examineEmpty.contraHarmonicMean == nil)
        XCTAssert(examineEmpty.poweredMean(order: 2.0) == nil)
        XCTAssert(examineEmpty.moment(r: 2, type: .origin) == nil)
        XCTAssert(try! examineEmpty.winsorizedMean(alpha: 0.2) == nil)
        XCTAssert(try! examineEmpty.trimmedMean(alpha: 0.2) == nil)
        XCTAssert(examineEmpty.median == nil)
        XCTAssert(examineEmpty.moment(r: 1, type: .central) == nil)
        XCTAssert(examineEmpty.moment(r: 1, type: .origin) == nil)
        XCTAssert(examineEmpty.moment(r: 1, type: .standardized) == nil)
        XCTAssert(examineEmpty.kurtosisExcess == nil)
        XCTAssert(examineEmpty.kurtosis == nil)
        
        XCTAssert(examineIntOutliers.hasOutliers(testType: .grubbs)!)
        XCTAssert(examineIntOutliers.hasOutliers(testType: .esd)!)
        
        let examine2: SSExamine<Double, Double> = examineDouble.copy() as! SSExamine<Double, Double>
        print("\(examineDouble.hashValue)")
        print("\(examine2.hashValue)")
        XCTAssert(examineDouble.elementsAsArray(sortOrder: .raw) == examine2.elementsAsArray(sortOrder: .raw))
        XCTAssert(examineDouble == examine2)
    }
    
    //    func testClonidineData() {
    //        let verum_ADR_before = SSExamine.init(withArray: v_adrenaline_vnw, name: "Verum", characterSet: nil)
    //        verum_ADR_before.tag = "Verum"
    //        let placebo_ADR_before = SSExamine.init(withArray: p_adrenaline_vnw, name: "Placebo", characterSet: nil)
    //        verum_ADR_before.tag = "Placebo"
    //        print(verum_ADR_before.hasOutliers(testType: SSOutlierTest.grubbs)!)
    //        print(placebo_ADR_before.hasOutliers(testType: SSOutlierTest.grubbs)!)
    //        print(verum_ADR_before.hasOutliers(testType: SSOutlierTest.esd)!)
    //        print(placebo_ADR_before.hasOutliers(testType: SSOutlierTest.esd)!)
    //        var res: SSESDTestResult = SSHypothesisTesting.esdOutlierTest(data: verum_ADR_before, alpha: 0.05, maxOutliers: 5, testType: .bothTails)!
    //        res = SSHypothesisTesting.esdOutlierTest(data: placebo_ADR_before, alpha: 0.05, maxOutliers: 5, testType: .bothTails)!
    //        print(res)
    //    }
    
    func testDataFrame() {
        let set1 = SSExamine<Double, Double>.init(withArray: wafer1, name: "Wafer_A", characterSet: nil)
        let set2 = SSExamine<Double, Double>.init(withArray: wafer2, name: "Wafer_B", characterSet: nil)
        let set3 = SSExamine<Double, Double>.init(withArray: wafer2, name: "Wafer_C", characterSet: nil)
        
        var df = try! SSDataFrame<Double, Double>.init(examineArray: [set1, set2, set3])
        do {
            #if os(macOS) || os(iOS)
            let _ = try df.exportCSV(path: resPath + "test.csv", separator: ",", useQuotes: false, firstRowAsColumnName: true, overwrite: true, stringEncoding: String.Encoding.utf16, atomically: true)
            print(resPath)
            #else
            let _ = try df.exportCSV(path: "test.csv", separator: ",", useQuotes: false, firstRowAsColumnName: true, overwrite: true, stringEncoding: String.Encoding.utf8, atomically: true)
            #endif
        }
        catch {
            print("error in exportCSV")
        }
        var df2:SSDataFrame<Double, Double>! = nil
        do {
            #if os(macOS) || os(iOS)
            df2 = try SSDataFrame<Double, Double>.dataFrame(fromFile: resPath + "test.csv", separator: ",", firstRowContainsNames: true, stringEncoding: String.Encoding.utf16, scanDouble)
            #else
            df2 = try SSDataFrame<Double, Double>.dataFrame(fromFile: "test.csv", separator: ",", firstRowContainsNames: true, stringEncoding: String.Encoding.utf8, scanDouble)
            #endif
        }
        catch {
            print("error in import data test.csv")
        }
        XCTAssertEqual(df, df2)
        #if os(macOS) || os(iOS)
            let filename = "test.dat"
            let tempDir = NSTemporaryDirectory()
            let url = NSURL.fileURL(withPathComponents: [tempDir, filename])
            do {
                let s = try df2.archiveTo(filePath: url?.path, overwrite: true)
                XCTAssert(s)
            }
            catch {
                print("error in archiveTo")
            }
            do {
                if let testDataFrame = try SSDataFrame<Double, Double>.unarchiveFrom(filePath: url?.path) {
                    XCTAssert(testDataFrame.isEqual(df2))
                }
                try! FileManager.default.removeItem(at: url!)
            }
            catch {
                print("error in unarchive")
            }
        #endif
        var row = df2.row(at: 3)
        XCTAssertEqual(row[0], 0.51, accuracy: 1E-2)
        XCTAssertEqual(row[1], 0.72, accuracy: 1E-2)
        XCTAssertEqual(row[2], 0.72, accuracy: 1E-2)
        row = df2.row(at: 0)
        XCTAssertEqual(row[0], 0.55, accuracy: 1E-2)
        XCTAssertEqual(row[1], 0.49, accuracy: 1E-2)
        XCTAssertEqual(row[2], 0.49, accuracy: 1E-2)
        var exa1: SSExamine<Double, Double>! = nil
        var exa2: SSExamine<Double, Double>! = nil
        var exa3: SSExamine<Double, Double>! = nil
        #if os(macOS) || os(iOS)
            exa1 = try! SSExamine<Double, Double>.examine(fromFile: resPath + "/NormalData01.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        #else
        if let p = linuxResourcePath(resource: "NormalData01", type: "examine") {
            exa1 = try! SSExamine<Double, Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        }
        #endif
        print("==============!!!!!!!!!!!!!!!!!!!================")
        exa1.name = "Normal_01"
        #if os(macOS) || os(iOS)
        exa2 = try! SSExamine<Double, Double>.examine(fromFile: resPath + "/NormalData02.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        #else
        if let p = linuxResourcePath(resource: "NormalData02", type: "examine") {
            exa2 = try! SSExamine<Double, Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        }
        #endif
        exa2.name = "Normal_02"
        #if os(macOS) || os(iOS)
        exa3 = try! SSExamine<Double, Double>.examine(fromFile: resPath + "/NormalData03.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        #else
        if let p = linuxResourcePath(resource: "NormalData03", type: "examine") {
            exa3 = try! SSExamine<Double, Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        }
        #endif
        exa3.name = "Normal_03"
        #if os(macOS) || os(iOS)
        df = try! SSDataFrame<Double, Double>.init(examineArray: [exa1, exa2, exa3])
        let _ = try! df.exportCSV(path: resPath + "/normal.csv", separator: ",", useQuotes: true, firstRowAsColumnName: true, overwrite: true, stringEncoding: String.Encoding.utf8, atomically: true)
        #else
        df = try! SSDataFrame<Double, Double>.init(examineArray: [exa1, exa2, exa3])
        let _ = try! df.exportCSV(path: "normal.csv", separator: ",", useQuotes: true, firstRowAsColumnName: true, overwrite: true, stringEncoding: String.Encoding.utf8, atomically: true)
        #endif
        #if os(macOS) || os(iOS)
        df2 = try! SSDataFrame<Double, Double>.dataFrame(fromFile: resPath + "/normal.csv", separator: ",", firstRowContainsNames: true, stringEncoding: String.Encoding.utf8, scanDouble)
        #else
        df2 = try! SSDataFrame<Double, Double>.dataFrame(fromFile: "normal.csv", separator: ",", firstRowContainsNames: true, stringEncoding: String.Encoding.utf8, scanDouble)
        #endif
        XCTAssert(df.isEqual(df2))
        #if os(macOS) || os(iOS)
        let df3 = try! SSDataFrame<String, Double>.dataFrame(fromFile: resPath + "/normal.csv", separator: ",", firstRowContainsNames: true, stringEncoding: .utf8, scanString)
        #else
        let df3 = try! SSDataFrame<String>.dataFrame(fromFile: "normal.csv", separator: ",", firstRowContainsNames: true, stringEncoding: .utf8, scanString)
        #endif
        XCTAssert(df3[0].arithmeticMean == nil)
    }
    
    func testCrossTabs() {
        var c = try! SSCrosstab<Int, String, String, Double>.init(rows: 4, columns: 3, initialValue: 0, rowID: ["Heavy", "Never", "Occas", "Regul"], columnID: ["Freq", "None", "Some"] )
        print(c.description)
        /*
         R code:
         
         > library(MASS)
         > tbl = table(survey$Smoke, survey$Exer)
         > tbl
         
         Freq None Some
         Heavy    7    1    3
         Never   87   18   84
         Occas   12    3    4
         Regul    9    1    7
         > chisq.test(tbl)
         
         Pearson's Chi-squared test
         
         data:  tbl
         X-squared = 5.4885, df = 6, p-value = 0.4828
         */
        try! c.setColumn(name: "Freq", newColumn:[7, 87, 12, 9])
        try! c.setColumn(name: "None" , newColumn:[1, 18, 3, 1])
        try! c.setColumn(name: "Some" , newColumn:[3, 84, 4, 7])
        
        XCTAssertEqual(c.chiSquare, 5.4885, accuracy: 1e-4)
        print(c.chiSquareLikelihoodRatio)
        print(c.chiSquareYates)
        print(c.pearsonR)
        print(c.adjustedResidual(row: 1, column: 1))
        print(c.expectedFrequency(row: 1, column: 1))
        print(c[1,1])
        print(c["Heavy","Freq"])
        print(c.residual(row: 1, column: 1))
        print(c.phi)
        let rowIDS = Array<Int>.init([1,2])
        let columnIDS = Array<Int>.init([1,2])
        var c1: SSCrosstab<Int,Int,Int, Double> = try! SSCrosstab<Int,Int,Int, Double>.init(rows: 2, columns: 2, initialValue: 0, rowID: rowIDS, columnID: columnIDS)
        try! c1.setColumn(at: 0, newColumn:[4,3])
        try! c1.setColumn(name: 2, newColumn:[2,3])
        print(c1.chiSquareLikelihoodRatio)
        print(c1.chiSquareYates)
        print(c1.adjustedResidual(row: 1, column: 1))
        print(c1.expectedFrequency(row: 1, column: 1))
//        print(c1[1, 2])
        print(c1.residual(row: 1, column: 1))
        print(c1.pearsonR)
        print(c1.phi)
        print(c1.cramerV)
        print(c1)
        var c2: SSCrosstab<Int,Int,Int, Double> = try! SSCrosstab<Int,Int,Int, Double>.init(rows: 2, columns: 2, initialValue: 0, rowID: [1, 2], columnID: [1,2])
        try! c2.setColumn(at: 0, newColumn:[60,40])
        try! c2.setColumn(name: 2, newColumn:[30,70])
        print(c2.chiSquareLikelihoodRatio)
        print(c2.chiSquareYates)
        print(c2.adjustedResidual(row: 1, column: 1))
        print(c2.expectedFrequency(row: 1, column: 1))
//        print(c2[Int(1), Int(2)])
        print(c2.residual(row: 1, column: 1))
        print(c2.pearsonR)
        print(c2.phi)
        print(c2.cramerV)
        print(c2.r0)
        print(c2.r1)
        print(c2)
        //        TAU test
        var tauTable = try! SSCrosstab<Double,String,String,Double>.init(rows: 3, columns: 2, initialValue: 0.0, rowID: ["<= 20 a", "21 - 50 a", ">=51 a"], columnID: ["Raucher", "Nichtraucher"])
        try! tauTable.setColumn(name: "Raucher", newColumn: [0.4, 0.3, 0.30])
        try! tauTable.setColumn(name: "Nichtraucher", newColumn: [0.20, 0.30, 0.50])
        print(tauTable.rowLevelOfMeasurement)
        print(tauTable.columnLevelOfMeasurement)
        print(tauTable.lambda_C_R)
        print(tauTable.lambda_R_C)
        //        print(tauTable.tauCR)
    }
    
    
    func testKS2Sample() {
        let set1 = SSExamine<Double, Double>.init(withArray: wafer1, name: nil, characterSet: nil)
        let set2 = SSExamine<Double, Double>.init(withArray: wafer2, name: nil, characterSet: nil)
        var res: SSKSTwoSampleTestResult<Double>
        res = try! SSHypothesisTesting.kolmogorovSmirnovTwoSampleTest(set1: set1, set2: set2, alpha: 0.05)
        XCTAssertEqual(res.p2Value!, 0.4611, accuracy: 1E-4)
        let set3 = SSExamine<Double, Double>.init(withArray: normal3, name: nil, characterSet: nil)
        let set4 = SSExamine<Double, Double>.init(withArray: laplaceData, name: nil, characterSet: nil)
        res = try! SSHypothesisTesting.kolmogorovSmirnovTwoSampleTest(set1: set3, set2: set4, alpha: 0.05)
        XCTAssertEqual(res.p2Value!, 7.159e-07, accuracy: 1E-7)
    }
    
    func testBinomialTest() {
        var p: Double
        p = SSHypothesisTesting.binomialTest(numberOfSuccess: 9, numberOfTrials: 14, probability: 0.5, alpha: 0.05, alternative: .twoSided)
        XCTAssertEqual(p, 0.424, accuracy: 1E-3)
        p = SSHypothesisTesting.binomialTest(numberOfSuccess: 9, numberOfTrials: 14, probability: 0.5, alpha: 0.05, alternative: .less)
        XCTAssertEqual(p, 0.9102, accuracy: 1E-4)
        p = SSHypothesisTesting.binomialTest(numberOfSuccess: 9, numberOfTrials: 14, probability: 0.5, alpha: 0.05, alternative: .greater)
        XCTAssertEqual(p, 0.212, accuracy: 1E-3)
        p = SSHypothesisTesting.binomialTest(numberOfSuccess: 16, numberOfTrials: 100, probability: 0.3, alpha: 0.05, alternative: .twoSided)
        XCTAssertEqual(0.002055, p, accuracy: 1E-6)
        p = SSHypothesisTesting.binomialTest(numberOfSuccess: 35, numberOfTrials: 100, probability: 0.3, alpha: 0.05, alternative: .twoSided)
        XCTAssertEqual(p, 0.2764, accuracy: 1E-4)
        p = SSHypothesisTesting.binomialTest(numberOfSuccess: 16, numberOfTrials: 100, probability: 0.2, alpha: 0.05, alternative: .less)
        XCTAssertEqual(p, 0.1923, accuracy: 1E-4)
        p = SSHypothesisTesting.binomialTest(numberOfSuccess: 16, numberOfTrials: 100, probability: 0.2, alpha: 0.05, alternative: .greater)
        XCTAssertEqual(p, 0.8715, accuracy: 1E-4)
        p = SSHypothesisTesting.binomialTest(numberOfSuccess:15, numberOfTrials: 20, probability: 0.6, alpha: 0.05, alternative: .twoSided)
        XCTAssertEqual(p, 0.2531, accuracy: 1E-4)
        p = SSHypothesisTesting.binomialTest(numberOfSuccess: 15, numberOfTrials: 20, probability: 0.6, alpha: 0.05, alternative: .less)
        XCTAssertEqual(p, 0.949, accuracy: 1E-3)
        p = SSHypothesisTesting.binomialTest(numberOfSuccess: 15, numberOfTrials: 20, probability: 0.6, alpha: 0.05, alternative: .greater)
        XCTAssertEqual(p, 0.1256, accuracy: 1E-4)
        let Data:Array<String> = ["A","A","A","A","A","B","A","A","B","B","B","B","A","A"]
        var res = try! SSHypothesisTesting.binomialTest(data: SSExamine.init(withArray: Data, name: nil, characterSet: CharacterSet.alphanumerics), testProbability: 0.5, successCodedAs: "A", alpha: 0.05, alternative: .twoSided)
        XCTAssertEqual(res.pValueExact!, 0.424, accuracy: 1E-3)
        XCTAssertEqual(res.confIntJeffreys!.lowerBound!, 0.3513801, accuracy: 1E-7)
        XCTAssertEqual(res.confIntJeffreys!.upperBound!, 0.8724016, accuracy: 1E-7)
        res = try! SSHypothesisTesting.binomialTest(data: SSExamine.init(withArray: Data, name: nil, characterSet: CharacterSet.alphanumerics), testProbability: 0.2, successCodedAs: "A", alpha: 0.05, alternative: .greater)
        XCTAssertEqual(res.pValueExact!, 0.0003819, accuracy: 1E-7)
        XCTAssertEqual(res.confIntJeffreys!.lowerBound!, 0.3904149, accuracy: 1E-7)
        XCTAssertEqual(res.confIntJeffreys!.upperBound!, 1.0, accuracy: 1E-7)
        res = try! SSHypothesisTesting.binomialTest(data: Data, characterSet: CharacterSet.alphanumerics, testProbability: 0.2, successCodedAs: "A", alpha: 0.05, alternative: .greater)
        XCTAssertEqual(res.pValueExact!, 0.0003819, accuracy: 1E-7)
        XCTAssertEqual(res.confIntJeffreys!.lowerBound!, 0.3904149, accuracy: 1E-7)
        XCTAssertEqual(res.confIntJeffreys!.upperBound!, 1.0, accuracy: 1E-7)
        res = try! SSHypothesisTesting.binomialTest(data: SSExamine.init(withArray: Data, name: nil, characterSet: CharacterSet.alphanumerics), testProbability: 0.7, successCodedAs: "A", alpha: 0.05, alternative: .less)
        XCTAssertEqual(res.pValueExact!,  0.4158, accuracy: 1E-4)
    }
    
    func testSignTest() {
        let g1 = SSExamine<Double, Double>.init(withArray: sign1, name: nil, characterSet: nil)
        let g2 = SSExamine<Double, Double>.init(withArray: sign2, name: nil, characterSet: nil)
        var res = try! SSHypothesisTesting.signTest(set1: g1, set2: g2)
        XCTAssertEqual(res.pValueExact!, 0.0144084, accuracy: 1E-6)
        let g3 = SSExamine<Double, Double>.init(withArray: sign3, name: nil, characterSet: nil)
        let g4 = SSExamine<Double, Double>.init(withArray: sign4, name: nil, characterSet: nil)
        res = try! SSHypothesisTesting.signTest(set1: g3, set2: g4)
        XCTAssertEqual(res.pValueExact!, 0.0384064, accuracy: 1E-6)
        var g5: SSExamine<Double, Double>! = nil
        var g6: SSExamine<Double, Double>! = nil
        #if os(macOS) || os(iOS)
        g5 = try! SSExamine<Double, Double>.examine(fromFile: resPath + "/largeNormal_01.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        g6 = try! SSExamine<Double, Double>.examine(fromFile: resPath + "/largeNormal_02.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        #else
        if let p = linuxResourcePath(resource: "largeNormal_01", type: "examine") {
            g5 = try! SSExamine<Double, Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        }
        if let p = linuxResourcePath(resource: "largeNormal_02", type: "examine") {
            g6 = try! SSExamine<Double, Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        }
        #endif
        res = try! SSHypothesisTesting.signTest(set1: g5, set2: g6)
        XCTAssertEqual(res.zStat!, -2.7511815643464903, accuracy: 1E-7)
        XCTAssertEqual(res.pValueExact!, 0.00295538, accuracy: 1E-6)
    }
    
    func testWilcoxonMatchedPairs() {
        // tested using IBM SPSS 24
        let M1 = [0.47, 1.02, 0.33, 0.70, 0.94, 0.85, 0.39, 0.52, 0.47]
        let M2 = [0.41, 1.00, 0.46, 0.61, 0.84, 0.87, 0.36, 0.52, 0.51]
        let examine1 = SSExamine<Double, Double>.init(withArray: M1, name: nil, characterSet: nil)
        let examine2 = SSExamine<Double, Double>.init(withArray: M2, name: nil, characterSet: nil)
        /*
             > M1 <- c(0.47, 1.02, 0.33, 0.70, 0.94, 0.85, 0.39, 0.52, 0.47)
             > M2 <- c(0.41, 1.00, 0.46, 0.61, 0.84, 0.87, 0.36, 0.52, 0.51)
             > wilcox.test(x = M1, y = M2,paired = TRUE, alternative = "two.sided")
             
             Wilcoxon signed rank test with continuity correction
             
             data:  M1 and M2
             V = 22.5, p-value = 0.5749
             alternative hypothesis: true location shift is not equal to 0
        */
        var wilcox: SSWilcoxonMatchedPairsTestResult<Double> = try! SSHypothesisTesting.wilcoxonMatchedPairs(set1: examine1, set2: examine2)
        XCTAssertEqual(wilcox.p2Value!, 0.5749, accuracy: 1E-3)
        XCTAssertEqual(wilcox.zStat!, -0.5607, accuracy: 1E-3)
        XCTAssertEqual(wilcox.sumNegRanks!, 22.5, accuracy: 1E-1)
        XCTAssertEqual(wilcox.sumPosRanks!, 13.5, accuracy: 1E-1)
        // http://documentation.statsoft.com/STATISTICAHelp.aspx?path=Nonparametrics/NonparametricAnalysis/Examples/Example8WilcoxonMatchedPairsTest
        /*
         > M3 <- c(20.3,17,6.5,25,5.4,29.2,2.9,6.6,15.8,8.3,34.0,8)
         > M4 <- c(50.4,87,25.1,28.5,26.9,36.6,1.0,43.8,44.2,10.4,29.9,27.7)
         > wilcox.test(x = M3, y = M4,paired = TRUE, alternative = "two.sided", exact = FALSE)
         
         Wilcoxon signed rank test with continuity correction
         
         data:  M3 and M4
         V = 5, p-value = 0.00859
         alternative hypothesis: true location shift is not equal to 0
        */
        let M3 = [20.3,17,6.5,25,5.4,29.2,2.9,6.6,15.8,8.3,34.0,8]
        let M4 = [50.4,87,25.1,28.5,26.9,36.6,1.0,43.8,44.2,10.4,29.9,27.7]
        let examine3 = SSExamine<Double, Double>.init(withArray: M3, name: nil, characterSet: nil)
        let examine4 = SSExamine<Double, Double>.init(withArray: M4, name: nil, characterSet: nil)
        wilcox = try! SSHypothesisTesting.wilcoxonMatchedPairs(set1: examine3, set2: examine4)
        XCTAssertEqual(wilcox.p2Value!, 0.00859, accuracy: 1E-6)
        XCTAssertEqual(wilcox.zStat!, -2.6279562108516661, accuracy: 1E-6)
        XCTAssertEqual(wilcox.sumNegRanks!, 5, accuracy: 1E-1)
        XCTAssertEqual(wilcox.sumPosRanks!, 73.0, accuracy: 1E-1)
        // http://influentialpoints.com/Training/wilcoxon_matched_pairs_signed_rank_test.htm
        /*
         > M6 <- c(1.0, 2, 1, 1, 3, 3, 2, 4, 2)
         > wilcox.test(x = M5, y = M6,paired = TRUE, alternative = "two.sided", exact = FALSE)
         
         Wilcoxon signed rank test with continuity correction
         
         data:  M5 and M6
         V = 45, p-value = 0.009091
         alternative hypothesis: true location shift is not equal to 0
        */
        let M5 = [13.0, 11, 6, 14, 6, 15, 13, 14, 8]
        let M6 = [1.0, 2, 1, 1, 3, 3, 2, 4, 2]
        let examine5 = SSExamine<Double, Double>.init(withArray: M5, name: nil, characterSet: nil)
        let examine6 = SSExamine<Double, Double>.init(withArray: M6, name: nil, characterSet: nil)
        wilcox = try! SSHypothesisTesting.wilcoxonMatchedPairs(set1: examine5, set2: examine6)
        XCTAssertEqual(wilcox.p2Value!, 0.009091, accuracy: 1E-4)
        XCTAssertEqual(wilcox.zStat!, -2.60862, accuracy: 1E-4)

    }
    
    func testHTest() {
        // tested using IBM SPSS 24
        let A1: Array<Double> = [12.1 , 14.8 , 15.3 , 11.4 , 10.8]
        let B1: Array<Double> = [18.3 , 49.6 , 10.1 , 35.6 , 26.2 , 8.9]
        let A2: Array<Double> = [12.7 , 25.1 , 47.0 , 16.3 , 30.4]
        let B2: Array<Double> = [7.3 , 1.9 , 5.8 , 10.1 , 9.4]
        let setA1 = SSExamine<Double, Double>.init(withArray: A1, name: nil, characterSet: nil)
        let setB1 = SSExamine<Double, Double>.init(withArray: B1, name: nil, characterSet: nil)
        let setA2 = SSExamine<Double, Double>.init(withArray: A2, name: nil, characterSet: nil)
        let setB2 = SSExamine<Double, Double>.init(withArray: B2, name: nil, characterSet: nil)
        var array = Array<SSExamine<Double, Double>>()
        array.append(setA1)
        array.append(setB1)
        array.append(setA2)
        array.append(setB2)
        var htest: SSKruskalWallisHTestResult<Double>
        htest = try! SSHypothesisTesting.kruskalWallisHTest(data: array, alpha: 0.05)
        XCTAssertEqual(htest.pValue!, 0.009, accuracy: 1E-3)
        XCTAssertEqual(htest.Chi2!, 11.53, accuracy: 1E-2)
    }
    
    
    func testMannWhitney() {
        // tested using IBM SPSS 24
        let A1: Array<Int> = [5,5,8,9,13,13,13,15]
        let B1: Array<Int> = [3,3,4,5,5,8,10,16]
        let A2: Array<Int> = [7,14,22,36,40,48,49,52]
        let B2: Array<Int> = [3,5,6,10,17,18,20,39]
        let setA1 = SSExamine<Int, Double>.init(withArray: A1, name: nil, characterSet: nil)
        let setB1 = SSExamine<Int, Double>.init(withArray: B1, name: nil, characterSet: nil)
        let setA2 = SSExamine<Int, Double>.init(withArray: A2, name: nil, characterSet: nil)
        let setB2 = SSExamine<Int, Double>.init(withArray: B2, name: nil, characterSet: nil)
        var mw: SSMannWhitneyUTestResult<Double> = try! SSHypothesisTesting.mannWhitneyUTest(set1: setA1, set2: setB1)
        XCTAssertEqual(mw.p2Approx!, 0.099, accuracy: 1E-3)
        XCTAssertEqual(mw.UMannWhitney!, 16.5, accuracy: 1E-1)
        XCTAssert(mw.p1Exact!.isNaN)
        mw = try! SSHypothesisTesting.mannWhitneyUTest(set1: setA2, set2: setB2)
        XCTAssertEqual(mw.p2Approx!, 0.027, accuracy: 1E-3)
        XCTAssertEqual(mw.UMannWhitney!, 11.0, accuracy: 1E-1)
        XCTAssertEqual(mw.p2Exact!, 0.028, accuracy: 1E-3)
        /*
         > A <- c(65, 79, 90, 75, 61, 98, 80, 75); na <- length(A)
         > B <- c(90, 98, 73, 79, 84, 98, 90, 88); nb <- length(B)
         > T.o   <- sum(A)
         > library(coin)
         > x <- c(A, B)
         > g <- as.factor(c(rep("A", length(A)), rep("B", length(B))))
         > wilcox_test(x ~ g, distribution = "asymptotic", alternative="two.sided")
         
         Asymptotic Wilcoxon-Mann-Whitney Test
         
         data:  x by g (A, B)
         Z = -1.5341, p-value = 0.125
         alternative hypothesis: true mu is not equal to 0
        */
        let M7 = [65.0,79,90,75,61,98,80,75]
        let M8 = [90.0,98,73,79,84,98,90,88]
        let setM7 = SSExamine<Double, Double>.init(withArray: M7, name: nil, characterSet: nil)
        let setM8 = SSExamine<Double, Double>.init(withArray: M8, name: nil, characterSet: nil)
        mw = try! SSHypothesisTesting.mannWhitneyUTest(set1: setM7, set2: setM8)
        XCTAssertEqual(mw.p2Approx!, 0.125, accuracy: 1E-3)
        XCTAssertEqual(mw.zStat!, 1.5341, accuracy: 1E-3)
    }
    
    func testFrequencies() {
        let characters = ["A", "A", "A", "B", "B", "B","C","C","C"]
        let c:SSExamine<String, Double> = try! SSExamine<String, Double>.init(withObject: characters, levelOfMeasurement: .nominal, name: nil, characterSet: nil)
        XCTAssertEqual(1.0 / 3.0, c.rFrequency("A"))
        XCTAssertEqual(1.0 / 3.0, c.rFrequency("B"))
        XCTAssertEqual(1.0 / 3.0, c.rFrequency("C"))
        XCTAssertEqual(0, c.rFrequency("!"))
        XCTAssertEqual(1.0 / 3.0, c.eCDF("A"))
        XCTAssertEqual(2.0 / 3.0, c.eCDF("B"))
        XCTAssertEqual(3.0 / 3.0, c.eCDF("C"))
    }
    
    func testAutocorrelation() {
        let examine = SSExamine<Double, Double>.init(withArray: lewData, name: nil, characterSet: nil)
        let boxljung: SSBoxLjungResult<Double> = try! SSHypothesisTesting.autocorrelation(data: examine)
        if let a = boxljung.coefficients {
            XCTAssertEqual(a[1], -0.307, accuracy: 1E-3)
        }
        XCTAssertEqual(try! SSHypothesisTesting.autocorrelationCoefficient(data: examine, lag: 1), -0.31, accuracy: 1E-2)
        
        var runsTest: SSRunsTestResult<Double>
        runsTest = try! SSHypothesisTesting.runsTest(array: lewData, alpha: 0.05, useCuttingPoint: .median, userDefinedCuttingPoint: nil, alternative: .twoSided)
        XCTAssertEqual(runsTest.zStat!, 2.6938, accuracy: 1E-4)
        XCTAssertEqual(runsTest.pValueAsymp!, 0.007065, accuracy: 1E-6)
        XCTAssertEqual(runsTest.criticalValue!, 1.96, accuracy: 1E-2)
        runsTest = try! SSHypothesisTesting.runsTest(array: lewData, alpha: 0.05, useCuttingPoint: .median, userDefinedCuttingPoint: nil, alternative: .less)
        XCTAssertEqual(runsTest.zStat!, 2.6938, accuracy: 1E-4)
        XCTAssertEqual(runsTest.pValueAsymp!, 0.9965, accuracy: 1E-4)
        XCTAssertEqual(runsTest.criticalValue!, 1.96, accuracy: 1E-2)
        
        runsTest = try! SSHypothesisTesting.runsTest(array: lewData, alpha: 0.05, useCuttingPoint: .median, userDefinedCuttingPoint: nil, alternative: .greater)
        XCTAssertEqual(runsTest.zStat!, 2.6938, accuracy: 1E-4)
        XCTAssertEqual(runsTest.pValueAsymp!, 0.003532, accuracy: 1E-6)
        XCTAssertEqual(runsTest.criticalValue!, 1.96, accuracy: 1E-2)
        
        let data = [18.0,17,18,19,20,19,19,21,18,21,22]
        runsTest = try! SSHypothesisTesting.runsTest(array: data, alpha: 0.05, useCuttingPoint: .median, userDefinedCuttingPoint: nil, alternative: .twoSided)
        XCTAssertEqual(runsTest.zStat!, -1.4489, accuracy: 1E-4)
        XCTAssertEqual(runsTest.pValueAsymp!, 0.1474, accuracy: 1E-4)
        
        // http://www.reiter1.com/Glossar/Wald_Wolfowitz.htm
        let m = 3.0
        let w = 1.0
        let ww1: Array<Double> = [m, m, w, w, m, w, m, m, w, w, m, w, m, w, m, w, m, m, w, m, m, w, m, w, m]
        runsTest = try! SSHypothesisTesting.runsTest(array: ww1, alpha: 0.05, useCuttingPoint: .mean, userDefinedCuttingPoint: nil, alternative: .twoSided)
        XCTAssertEqual(runsTest.zStat!, 2.3563, accuracy: 1E-4)
        XCTAssertEqual(runsTest.pValueAsymp!, 0.01846, accuracy: 1E-5)
        
        
        let M1 = [0.47, 1.02, 0.33, 0.70, 0.94, 0.85, 0.39, 0.52, 0.47]
        runsTest = try! SSHypothesisTesting.runsTest(array: M1, alpha: 0.05, useCuttingPoint: .median, userDefinedCuttingPoint: nil, alternative: .twoSided)
        let M2 = [0.41, 1.00, 0.46, 0.61, 0.84, 0.87, 0.36, 0.52, 0.51]
        let set1 = SSExamine<Double, Double>.init(withArray: M1, name: nil, characterSet: nil)
        let set2 = SSExamine<Double, Double>.init(withArray: M2, name: nil, characterSet: nil)
        let ww: SSWaldWolfowitzTwoSampleTestResult = try! SSHypothesisTesting.waldWolfowitzTwoSampleTest(set1: set1, set2: set2)
        XCTAssertEqual(ww.pValueAsymp!, 0.01512, accuracy: 1E-5)
        XCTAssertEqual(ww.zStat!, 2.4296, accuracy: 1E-4)
    }
    
    func testTTest()  {
        var examine1: SSExamine<Double, Double>! = nil
        var examine2: SSExamine<Double, Double>! = nil
        var examine3: SSExamine<Double, Double>! = nil
        #if os(macOS) || os(iOS)
        examine1 = try! SSExamine<Double, Double>.examine(fromFile: resPath + "/NormalData01.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        examine1.name = "Normal_01"
        examine2 = try! SSExamine<Double, Double>.examine(fromFile: resPath + "/NormalData02.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        examine1.name = "Normal_02"
        examine3 = try! SSExamine<Double, Double>.examine(fromFile: resPath + "/NormalData03.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        examine1.name = "Normal_03"
        #else
        if let p = linuxResourcePath(resource: "NormalData01", type: "examine") {
            examine1 = try! SSExamine<Double, Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        }
        examine1.name = "Normal_01"
        if let p = linuxResourcePath(resource: "NormalData02", type: "examine") {
            examine2 = try! SSExamine<Double, Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        }
        examine1.name = "Normal_02"
        if let p = linuxResourcePath(resource: "NormalData03", type: "examine") {
            examine3 = try! SSExamine<Double, Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        }
        examine1.name = "Normal_03"
        #endif
        var ttestResult = try! SSHypothesisTesting.twoSampleTTest(sample1: examine1, sample2: examine2, alpha: 0.05)
        XCTAssertEqual(ttestResult.p2Welch!, 0.365728, accuracy: 1E-6)
        
        ttestResult = try! SSHypothesisTesting.twoSampleTTest(sample1:examine1 , sample2: examine3, alpha: 0.05)
        XCTAssertTrue(ttestResult.p2Welch!.isZero)
        
        ttestResult = try! SSHypothesisTesting.twoSampleTTest(sample1:examine2 , sample2: examine3, alpha: 0.05)
        XCTAssertTrue(ttestResult.p2Welch!.isZero)
        
        var oneSTTestResult = try! SSHypothesisTesting.oneSampleTTest(sample: examine1, mean: 0.0, alpha: 0.05)
        XCTAssertEqual(oneSTTestResult.p2Value!, 0.609082, accuracy: 1E-6)
        XCTAssertEqual(oneSTTestResult.tStat!, 0.512853, accuracy: 1E-6)
        
        oneSTTestResult = try! SSHypothesisTesting.oneSampleTTest(sample: examine1, mean: 1.0 / 3.0, alpha: 0.05)
        XCTAssertEqual(oneSTTestResult.p2Value!, 0.00314911, accuracy: 1E-6)
        XCTAssertEqual(oneSTTestResult.tStat!, -3.01937, accuracy: 1E-5)
        
        var matchedPairsTTestRest = try! SSHypothesisTesting.matchedPairsTTest(set1: examine1, set2: examine2, alpha: 0.05)
        XCTAssertEqual(matchedPairsTTestRest.p2Value!, 0.331154, accuracy: 1E-6)
        
        matchedPairsTTestRest = try! SSHypothesisTesting.matchedPairsTTest(set1: examine1, set2: examine3, alpha: 0.05)
        XCTAssertEqual(matchedPairsTTestRest.p2Value!, 1.63497E-20, accuracy: 1E-12)
        
        matchedPairsTTestRest = try! SSHypothesisTesting.matchedPairsTTest(set1: examine1, set2: examine1, alpha: 0.05)
        XCTAssertEqual(matchedPairsTTestRest.p2Value!, 1, accuracy: 1E-12)
        var ds1: SSDataFrame<Double, Double>! = nil
        #if os(macOS) || os(iOS)
        ds1 = try! SSDataFrame<Double, Double>.dataFrame(fromFile: resPath + "/geardata.csv", scanDouble)
        #else
        if let p = linuxResourcePath(resource: "geardata", type: "csv") {
            ds1 = try! SSDataFrame<Double, Double>.dataFrame(fromFile: p, scanDouble)
        }
        #endif
        var multipleMeansRes: SSOneWayANOVATestResult<Double> = try! SSHypothesisTesting.multipleMeansTest(dataFrame: ds1, alpha: 0.05)!
        XCTAssertEqual(multipleMeansRes.p2Value!, 0.0227, accuracy: 1E-4)
        XCTAssertEqual(multipleMeansRes.FStatistic!, 2.297, accuracy: 1E-3)
        
        // data from https://brownmath.com/stat/anova1.htm#ANOVAhow
        /*
         R code
         values <- c(64,72,68,77,56,95,78,91,97,82,85,77,75,93,78,71,63,76,55,66,49,64,70,68)
         groups <- c(rep(1,6),rep(2,6),rep(3,6),rep(4,6))
         data <- data.frame(groups = factor(groups), values)
         summary(aov(values ~ groups, data))
         
         -->
         Df Sum Sq Mean Sq F value  Pr(>F)
         groups       3   1636   545.5   5.406 0.00688 **
         Residuals   20   2018   100.9
         ---
         Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
         */
        let b1 = [64.0,72.0,68.0,77.0,56.0,95.0]
        let b2 = [78,91,97,82,85,77.0]
        let b3 = [75,93,78,71,63,76.0]
        let b4 = [55,66,49,64,70,68.0]
        multipleMeansRes = try! SSHypothesisTesting.multipleMeansTest(data: [b1,b2,b3,b4], alpha: 0.05)!
        XCTAssertEqual(multipleMeansRes.p2Value!, 0.00688, accuracy: 1E-5)
        XCTAssertEqual(multipleMeansRes.FStatistic!, 5.406, accuracy: 1E-3)
        /*
         R code
         > treatment <- c(4.0, 3.5,4.1,5.5,4.6,6.0,5.1,4.3)
         > no_treat <- c(3.0, 3.0,3.8,2.1,4.9,5.3,3.1,2.7)
         > t.test(treatment, no_treat, alternative = c("two.sided"), paired = TRUE)
         
         Paired t-test
         
         data:  treatment and no_treat
         t = 2.798, df = 7, p-value = 0.0266
         alternative hypothesis: true difference in means is not equal to 0
         95 percent confidence interval:
         0.1781177 2.1218823
         sample estimates:
         mean of the differences
         1.15
        */
        let x = [4.0, 3.5,4.1,5.5,4.6,6.0,5.1,4.3]
        let y = [3.0, 3.0,3.8,2.1,4.9,5.3,3.1,2.7]
        let xExamine = SSExamine<Double, Double>.init(withArray: x, name: "X", characterSet: nil)
        let yExamine = SSExamine<Double, Double>.init(withArray: y, name: "Y", characterSet: nil)
        matchedPairsTTestRest = try! SSHypothesisTesting.matchedPairsTTest(set1: xExamine, set2: yExamine, alpha: 0.05)
        print(matchedPairsTTestRest)
    }
    
    func testEqualityOfVariance() {
        // with two arrays
        var varianceTestResult = try! SSHypothesisTesting.bartlettTest(array: [normal1, normal2], alpha: 0.05)!
        XCTAssertEqual(varianceTestResult.pValue!, 0.00103845, accuracy: 1E-8)
        XCTAssertEqual(varianceTestResult.testStatistic!, 10.7577, accuracy: 1E-4)
        
        // with three arrays
        varianceTestResult = try! SSHypothesisTesting.bartlettTest(array: [normal1, normal2, normal3], alpha: 0.05)!
        XCTAssertEqual(varianceTestResult.pValue!, 0.0000156135, accuracy: 1E-10)
        XCTAssertEqual(varianceTestResult.testStatistic!, 22.1347, accuracy: 1E-4)
        XCTAssertThrowsError(try SSHypothesisTesting.bartlettTest(array: [normal1], alpha: 0.05))
        
        varianceTestResult = try! SSHypothesisTesting.leveneTest(array: [normal1, normal2, normal3], testType: .median, alpha: 0.05)!
        XCTAssertEqual(varianceTestResult.pValue!, 0.000490846, accuracy: 1E-9)
        
        varianceTestResult = try! SSHypothesisTesting.leveneTest(array: [normal1, normal2, normal3], testType: .mean, alpha: 0.05)!
        XCTAssertEqual(varianceTestResult.pValue!, 0.000261212, accuracy: 1E-9)
        
        varianceTestResult = try! SSHypothesisTesting.leveneTest(array: [normal1, normal2, normal3], testType: .trimmedMean, alpha: 0.05)!
        XCTAssertEqual(varianceTestResult.pValue!, 0.0003168469, accuracy: 1E-9)
        
        var chiResult: SSChiSquareVarianceTestResult<Double>
        chiResult = try! SSHypothesisTesting.chiSquareVarianceTest(array: normal3, nominalVariance: 9.0 / 4.0, alpha: 0.05)!
        XCTAssertEqual(chiResult.p1Value!, 0.242166, accuracy: 1E-6)
        
        chiResult = try! SSHypothesisTesting.chiSquareVarianceTest(array: normal3, nominalVariance: 8.0 / 5.0, alpha: 0.05)!
        XCTAssertEqual(chiResult.p1Value!, 0.000269792, accuracy: 1E-9)
        
        var ftestRes: SSFTestResult<Double>
        ftestRes = try! SSHypothesisTesting.fTestVarianceEquality(data1: normal1, data2: normal2, alpha: 0.05)
        XCTAssertEqual(ftestRes.p1Value!, 0.000519142, accuracy: 1E-9)
        
        ftestRes = try! SSHypothesisTesting.fTestVarianceEquality(data1: normal1, data2: normal3, alpha: 0.05)
        XCTAssertEqual(ftestRes.p1Value!, 1.43217E-6, accuracy: 1E-9)
        
        ftestRes = try! SSHypothesisTesting.fTestVarianceEquality(data1: normal2, data2: normal3, alpha: 0.05)
        XCTAssertEqual(ftestRes.p1Value!, 0.0736106, accuracy: 1E-7)
    }
    
    func testKStest() {
        let normal = try! SSExamine<Double, Double>.init(withObject: normal1, levelOfMeasurement: .interval, name: nil, characterSet: nil)
        normal.name = "Normal Distribution"
        
        let laplace = try! SSExamine<Double, Double>.init(withObject: laplaceData, levelOfMeasurement: .interval, name: nil, characterSet: nil)
        laplace.name = "Laplace Distribution"
        
        var res: SSKSTestResult<Double> = try! SSHypothesisTesting.ksGoFTest(array: normal.elementsAsArray(sortOrder: .raw)!, targetDistribution: .gaussian)!
        XCTAssertEqual(res.pValue!, 0.932551, accuracy: 1E-5)
        
        res = try! SSHypothesisTesting.ksGoFTest(array: normal.elementsAsArray(sortOrder: .raw)!, targetDistribution: .laplace)!
        XCTAssertEqual(res.pValue!, 0.231796, accuracy: 1E-5)
        
        res = try! SSHypothesisTesting.ksGoFTest(array: laplace.elementsAsArray(sortOrder: .raw)!, targetDistribution: .gaussian)!
        XCTAssertEqual(res.pValue!, 0.0948321, accuracy: 1E-5)
        
        res = try! SSHypothesisTesting.ksGoFTest(array: laplace.elementsAsArray(sortOrder: .raw)!, targetDistribution: .laplace)!
        XCTAssertEqual(res.pValue!, 0.0771619, accuracy: 1E-5)
        
        /*
         Mathematica:
         normal1 = {-1.39472, 0.572422, -0.807981, 1.12284, 0.582314, -2.02361, -1.07106, -1.07723, 0.105198, -0.806512, -1.47555, 0.117081, -0.40699, -0.554643, -0.0838551, -2.38265, -0.748096,1.13259, 0.134903, -1.11957, -0.268167, -0.249893, -0.636138, 0.411145, 1.40698, 0.868583,0.221741, -0.751367, -0.843731, -1.92446, -0.770097, 1.34406,0.113856, 0.442025, 0.206676, 0.448239, 0.701375, -1.50239,0.118701, 0.992643, 0.119639, -0.0365253,0.205961, -0.37079, -0.224489, -0.428072, 0.911177, -0.279192,0.560748, -0.24796, -1.05229,2.03458, -2.02889, -1.08878, -0.826172,0.381449, -0.134957, -0.07598, -1.03606, 1.65422, -0.290542,0.221982, 0.0674381, -0.32888, 1.59649, 0.418209, -0.899435,0.329175, -0.177973, 1.62596, 0.599629, -1.5299, -2.18709,0.297174, 0.997437, 1.55026, 0.857938, 0.177222,1.62641, -0.982871, 0.307966, -0.518949, 2.34573, -0.17761, 2.3379,0.598934, -0.727655, 0.320675, 1.5864, 0.0940648,0.350143, -0.617015, 0.839371, 0.224846, 0.0201539, -1.49075,0.847894, -0.790432, 1.80993, 1.32279, 0.141171, -1.14471,0.601558, 0.678619, -0.45809, 0.312201, 1.3017, 0.0407581,0.993514, 0.931535, 1.13858};
         Needs["HypothesisTesting`"];
         N[AndersonDarlingTest[normal1, NormalDistribution[Mean[normal1], StandardDeviation[normal1]]],21]
         
         ==> 0.987337
        */
        
        var adRes = try! SSHypothesisTesting.adNormalityTest(array: normal1, alpha: 0.05)!
        XCTAssertEqual(adRes.pValue!, 0.987, accuracy: 1E-3)
        
        /*
         laplace = {-2.03679,0.518416,-1.72556,3.07248,1.58415,0.55357,1.13785,2.77352,0.692562,-0.246844,1.07308,0.676815,2.61719,0.839612,0.657608,1.60029,0.934251,1.64299,4.83994,-0.572193,0.590732,-2.30579,-3.46328,4.6823,2.65601,1.66736,0.0644071,0.561031,2.19092,1.10959,0.952764,4.28232,0.360738,3.43897,-0.122254,-3.22326,7.96229,-5.32675,1.4503,-2.94508,1.36242,1.0414,0.421444,3.61022,1.26506,-3.94449,-0.544188,2.88665,2.00745,-3.01688,1.0722,-0.327354,1.46366,1.52667,3.71474,1.24921,2.36462,2.111,-0.704057,6.7197,7.54793,2.76588,0.470362,0.467676,1.16809,2.11906,-3.79051,2.17474,4.64406,-1.69926,0.967686,-3.22085,1.72475,1.17087,1.03924,0.230923,1.4176,0.897564,-6.89486,-5.64721,1.07495,1.78927,8.24184,5.95395,0.793648,1.89169,1.25558,4.3064,-1.33544,5.67814,-6.36738,-0.372883,0.13142,0.786708,-0.0932199,-4.06743,4.07498,-0.482598,-1.49333,1.61442,-2.27068,1.55111,-2.59695,4.47164,-0.776884,0.884446,3.70967,0.858531,3.33213,-7.62385,0.0583429,-0.148588,-1.24765,8.67548,0.860613,1.36125,-9.48455,-0.831406,-1.86396,2.10917,4.551,1.064,1.97283,3.82057,2.29935,-1.74418,0.244115,-0.837016,2.53457,1.61,1.54181,-1.54528,-0.943004,-0.738644,-0.680302,0.358243,5.85945,0.920141,0.645741,0.675258,0.833122,0.0261111,0.593711,1.10065,0.956418,-0.194063,3.37702,-1.40828,0.853448,-1.26089};
         N[AndersonDarlingTest[laplace, NormalDistribution[Mean[laplace], StandardDeviation[laplace]]], 21]

         ==> 0.0414159
        */
        
        adRes = try! SSHypothesisTesting.adNormalityTest(array: laplaceData, alpha: 0.05)!
        XCTAssertEqual(adRes.pValue!, 0.04, accuracy: 1E-2)
        
    }
    // This the original test provided by Gil/Segura/Temme
    func testMarcum() {
        let mys: Array<Double> = [1.0,3.0,4.0,6.0,8.0,10.0,20.0,22.0,25.0,27.0,30.0,32.0,40.0,50.0,200.0,350.0,570.0,1000.0]
        let y1: Array<Double> = [0.01,0.1,50.0,10.0,15.0,25.0,30.0,150.0,60.0,205.0,90.0,100.0,120.0,150.0,190.0,320.0,480.0,799.0]
        let x1: Array<Double> = [0.3,2.0,8.0,25.0,13.0,45.0,47.0,100.0,85.0,120.0,130.0,140.0,30.0,40.0,0.01,100.0,1.0,0.08]
        let p: Array<Double> = [0.7382308441994e-02,0.2199222796783e-04,0.9999999768807,0.1746869995977e-03,0.1483130042637,0.1748328323235e-03,0.1340769184710e-04,0.9646591215441,0.1783991673043e-04,0.9994542406431,0.1220231636641e-05,0.1757487653307e-05,0.9999894753719,0.9999968347378,0.2431297758708,0.3851423018735e-09,0.2984493152360e-04,0.4191472999694e-11]
        let q: Array<Double> = [0.9926176915580,0.9999780077720,
        0.2311934913546e-7,0.9998253130004,
        0.8516869957363,0.9998251671677,
        0.9999865923082,0.3534087845586e-01,
        0.9999821600833,0.5457593568564e-03,
        0.9999987797684,0.9999982425123,
        0.1052462813144e-04,0.3165262228904e-05,
        0.7568702241292,0.9999999996149,
        0.9999701550685,0.9999999999958]
        var marcumRes: (p: Double, q: Double, err: Int, underflow: Bool)
        var err1, err2: Double
        for i in stride(from: 1, to: 18, by: 1) {
            marcumRes = marcum(mys[i-1], x1[i-1], y1[i-1])
            XCTAssertEqual(marcumRes.p, p[i-1], accuracy: 1e-13)
            XCTAssertEqual(marcumRes.q, q[i-1], accuracy: 1e-13)
            err1 = abs(1.0 - marcumRes.p / p[i-1])
            err2 = abs(1.0 - marcumRes.q / q[i-1])
            print("\(mys[i-1])  \(x1[i-1])   \(y1[i-1])  \(err1)   \(err2)")
        }
        var d0: Double = -1
        var mu,y,x,p0,q0,pm1,qm1,p1,q1,p2,q2, delta: Double
        var ierr1,ierr2,ierr3,ierr4: Int
        ierr1 = 0
        ierr2 = 0
        ierr3 = 0
        ierr4 = 0
        p0 = 0.0
        q0 = 0.0
        p1 = 0.0
        q1 = 0.0
        p2 = 0.0
        q2 = 0.0
        pm1 = 0.0
        qm1 = 0.0
        for i in stride(from: 0, through: 10, by: 1.0) {
            mu = i * 50.0 + 10.0
            for j in stride(from: 1.0, through: 10.0, by: 1.0) {
                x = j * 50.18 + 5.0
                for k in stride(from: 0.0, through: 10.0, by: 1.0) {
                    y = k * 19.15 + 2.0
                    marcumRes = marcum(mu, x, y)
                    p0 = marcumRes.p
                    q0 = marcumRes.q
                    ierr1 = marcumRes.err
                    marcumRes = marcum(mu - 1.0, x, y)
                    pm1 = marcumRes.p
                    qm1 = marcumRes.q
                    ierr2 = marcumRes.err
                    marcumRes = marcum(mu + 1, x, y)
                    p1 = marcumRes.p
                    q1 = marcumRes.q
                    ierr1 = marcumRes.err
                    marcumRes = marcum(mu + 2, x, y)
                    p2 = marcumRes.p
                    q2 = marcumRes.q
                    ierr1 = marcumRes.err
                    if (((ierr1==0) && (ierr2==0)) && ((ierr3==0) && (ierr4==0))) {
                        if (y > x + mu) {
                            delta = abs(((x-mu) * q1 + (y + mu) * q0) / (x * q2 + y * qm1) - 1.0)
                        }
                        else {
                            delta = abs(((x - mu) * p1 + (y + mu) * p0) / (x * p2 + y * pm1) - 1.0)
                        }
                        if (delta > d0) {
                            d0 = delta
                        }
                    }
                }
            }
        }
        print("Maximum value of the recurrence check = \(d0)")
    }
    
    
    func testQuick() {
        var Q, P: Float80
        var conv: Bool = false
        var incg: (p: Float80, q: Float80, ierr: Int) = incgam(a: Float80(-1), x: Float80(0))
        Q = gammaNormalizedQ(x: Float80(0), a: Float80(-1), converged: &conv)
        P = gammaNormalizedP(x: 0, a: -1, converged: &conv)
//        for a: Double in stride(from: -10.0, to: 11.0, by: 1.0) {
//            for x: Double in stride(from: -10.0, through: 10.0, by: 1.0) {
//                incg = incgam(a: a, x: x)
//                Q = gammaNormalizedQ(x: x, a: a, converged: &conv)
//                P = gammaNormalizedP(x: x, a: a, converged: &conv)
//                incg = incgam(a: a, x: x)
//            }
//        }
    }
    
    func testDistributions() {
        var para: SSContProbDistParams<Double>?
        /*
         df = 21;
         td = StudentTDistribution[df];
         N[Kurtosis[td], 21]
         N[Mean[td], 21]
         N[Skewness[td], 21]
         N[Variance[td], 21]
         Out[21]= 3.35294117647058823529
         Out[22]= 0
         Out[23]= 0
         Out[24]= 1.10526315789473684211
        */
        para = try! paraStudentTDist(degreesOfFreedom: 21)
        XCTAssertEqual(para!.kurtosis, 3.35294117647058823529, accuracy: 1e-12)
        XCTAssertEqual(para!.mean, 0.0, accuracy: 1e-12)
        XCTAssertEqual(para!.skewness, 0, accuracy: 1e-12)
        XCTAssertEqual(para!.variance, 1.10526315789473684211, accuracy: 1e-12)
        /********************************************************/
        /* Student T                                            */
        /********************************************************/
        /* PDF
         R code:
         > dt(x = -10, df = 22)
         [1] 1.098245e-09
         > dt(x = 0, df = 22)
         [1] 0.394436
         > dt(x = 2.5, df = 22)
         [1] 0.02223951
         > dt(x = 10, df = 22)
         [1] 1.098245e-09
         > dt(x = 10, df = 2)
         [1] 0.0009707329
         */
        XCTAssertEqual(try! pdfStudentTDist(t: -10, degreesOfFreedom: 22), 1.098245e-09, accuracy: 1E-10)
        XCTAssertEqual(try! pdfStudentTDist(t: 0, degreesOfFreedom: 22), 0.394436, accuracy: 1E-5)
        XCTAssertEqual(try! pdfStudentTDist(t: 2.5, degreesOfFreedom: 22), 0.02223951, accuracy: 1E-5)
        XCTAssertEqual(try! pdfStudentTDist(t: 10, degreesOfFreedom: 2), 0.0009707329, accuracy: 1E-10)
        /* CDF
         R code:
         > pt(q = -10, df = 22)
         [1] 6.035806e-10
         > pt(q = 0, df = 22)
         [1] 0.5
         > pt(q = 2.5, df = 22)
         [1] 0.9898164
         > pt(q = 10, df = 2)
         [1] 0.9950738
        */
        XCTAssertEqual(try! cdfStudentTDist(t: -10, degreesOfFreedom: 22), 6.035806e-10, accuracy: 1E-15)
        XCTAssertEqual(try! cdfStudentTDist(t: 0, degreesOfFreedom: 22), 0.5)
        XCTAssertEqual(try! cdfStudentTDist(t: 2.5, degreesOfFreedom: 22), 0.9898164, accuracy: 1E-7)
        XCTAssertEqual(try! cdfStudentTDist(t: 10, degreesOfFreedom: 2), 0.9950738, accuracy: 1E-7)
        /*
         df = 21;
         td = StudentTDistribution[df];
         N[Kurtosis[td], 21]
         N[Mean[td], 21]
         N[Skewness[td], 21]
         N[Variance[td], 21]
         Out[21]= 3.35294117647058823529
         Out[22]= 0
         Out[23]= 0
         Out[24]= 1.10526315789473684211
         */
        para = try! paraStudentTDist(degreesOfFreedom: 21, nonCentralityPara: 3)
        XCTAssertEqual(para!.kurtosis, 3.61902917492752013195, accuracy: 1e-12)
        XCTAssertEqual(para!.mean, 3.11273629794486754698, accuracy: 1e-12)
        XCTAssertEqual(para!.skewness, 0.430814083288819887296, accuracy: 1e-12)
        XCTAssertEqual(para!.variance, 1.36350431840384919250, accuracy: 1e-12)

        /* noncentral PDF
         lambda = 3;
         df = 22;
         ntd = NoncentralStudentTDistribution[df, lambda];
         N[PDF[ntd, -10], 21]
         N[PDF[ntd, 0], 21]
         N[PDF[ntd, 25/10], 21]
         N[PDF[ntd, 10], 21]
         */
        XCTAssertEqual(try! pdfStudentTDist(x: -10,  degreesOfFreedom: 22, nonCentralityPara: 3), 1.61220211703878172128e-16, accuracy: 1E-18)
        XCTAssertEqual(try! pdfStudentTDist(x: 0, degreesOfFreedom: 22, nonCentralityPara: 3), 0.00438178866867118877565, accuracy: 1E-12)
        XCTAssertEqual(try! pdfStudentTDist(x: 2.5, degreesOfFreedom: 22, nonCentralityPara: 3), 0.334601573269501746166, accuracy: 1E-12)
        XCTAssertEqual(try! pdfStudentTDist(x: 10, degreesOfFreedom: 22, nonCentralityPara: 3), 0.0000354931204704236583089, accuracy: 1E-12)
        XCTAssertEqual(try! pdfStudentTDist(x: 1, degreesOfFreedom: 22, nonCentralityPara: 10), 2.86089002661815955619e-18, accuracy: 1E-18)
        XCTAssertEqual(try! pdfStudentTDist(x: 0, degreesOfFreedom: 22, nonCentralityPara: 10), 7.60768463597592483354e-23, accuracy: 1E-27)
        XCTAssertEqual(try! pdfStudentTDist(x: 2.5, degreesOfFreedom: 22, nonCentralityPara: 10), 1.21515039938564508949e-11, accuracy: 1E-12)
        XCTAssertEqual(try! pdfStudentTDist(x: 10, degreesOfFreedom: 22, nonCentralityPara: 10), 0.218713193594618197003, accuracy: 1E-12)
        /* noncentral CDF
         R code:
         > pt(q = 10, ncp = 10, df = 22)
         [1] 0.4691243
         > pt(q = -10, ncp = 10, df = 22)
         [1] 1.382228e-13
         > pt(q = -10, ncp = 3, df = 22)
         [1] 1.479927e-13
         > pt(q = 0, ncp = 3, df = 22)
         [1] 0.001349898
         > pt(q = 2.5, ncp = 3, df = 22)
         [1] 0.3101249
         > pt(q = 10, ncp = 3, df = 2)
         [1] 0.9065271
         > pt(q = -10, ncp = 10, df = 22)
         [1] 1.382228e-13
         > pt(q = 0, ncp = 10, df = 22)
         [1] 7.619853e-24
         > pt(q = 2.5, ncp = 10, df = 22)
         [1] 1.301945e-12
         > pt(q = 10, ncp = 10, df = 2)
         [1] 0.3714677
         > pt(q = 10, ncp = 10, df = 223322)
         [1] 0.4999955
        */
        XCTAssertEqual(try! cdfStudentTDist(t: -10, degreesOfFreedom: 22, nonCentralityPara: 3), 8.14079530286125822663e-17, accuracy: 1E-19)
        XCTAssertEqual(try! cdfStudentTDist(t: 0, degreesOfFreedom: 22, nonCentralityPara: 3), 0.00134989803163009452665, accuracy: 1E-9)
        XCTAssertEqual(try! cdfStudentTDist(t: 2.5, degreesOfFreedom: 22, nonCentralityPara: 3), 0.310124866777693411844, accuracy: 1E-7)
        XCTAssertEqual(try! cdfStudentTDist(t: 10, degreesOfFreedom: 22, nonCentralityPara: 3), 0.999976994489342241050, accuracy: 1E-7)
        XCTAssertEqual(try! cdfStudentTDist(t: -10, degreesOfFreedom: 22, nonCentralityPara: 10), 4.39172441491830770359e-44, accuracy: 1E-48)
        XCTAssertEqual(try! cdfStudentTDist(t: 0, degreesOfFreedom: 22, nonCentralityPara: 10), 7.61985302416052606597e-24, accuracy: 1E-27)
        XCTAssertEqual(try! cdfStudentTDist(t: 2, degreesOfFreedom: 22, nonCentralityPara: 10), 1.00316897649437185093e-14, accuracy: 1E-23)
        XCTAssertEqual(try! cdfStudentTDist(t: 2.5, degreesOfFreedom: 22, nonCentralityPara: 10), 1.30289935752455767687e-12, accuracy: 1E-16)
        XCTAssertEqual(try! cdfStudentTDist(t: 10, degreesOfFreedom: 22, nonCentralityPara: 10), 0.469124289769452233227, accuracy: 1E-14)
//        XCTAssertEqual(try! cdfNoncentralTBenton(t: -10, df: 22, delta: 3, errtol: Double.ulpOfOne, maxitr: 1000), 8.14079530286125822663e-17, accuracy: 1E-19)
//        XCTAssertEqual(try! cdfNoncentralTBenton(t: 0, df: 22, delta: 3, errtol: Double.ulpOfOne, maxitr: 1000), 0.00134989803163009452665, accuracy: 1E-9)
//        XCTAssertEqual(try! cdfNoncentralTBenton(t: 2.5, df: 22, delta: 3, errtol: Double.ulpOfOne, maxitr: 1000), 0.310124866777693411844, accuracy: 1E-7)
//        XCTAssertEqual(try! cdfNoncentralTBenton(t: 10, df: 22, delta: 3, errtol: Double.ulpOfOne, maxitr: 1000), 0.999976994489342241050, accuracy: 1E-7)
//        XCTAssertEqual(try! cdfNoncentralTBenton(t: -10, df: 22, delta: 10, errtol: Double.ulpOfOne, maxitr: 1000), 4.39172441491830770359e-44, accuracy: 1E-48)
//        XCTAssertEqual(try! cdfNoncentralTBenton(t: 0, df: 22, delta: 10, errtol: Double.ulpOfOne, maxitr: 1000), 7.61985302416052606597e-24, accuracy: 1E-27)
//        XCTAssertEqual(try! cdfNoncentralTBenton(t: 2, df: 22, delta: 10, errtol: Double.ulpOfOne, maxitr: 1000), 1.00316897649437185093e-14, accuracy: 1E-23)
//        XCTAssertEqual(try! cdfNoncentralTBenton(t: 2.5, df: 22, delta: 10, errtol: Double.ulpOfOne, maxitr: 1000), 1.30289935752455767687e-12, accuracy: 1E-16)
//        XCTAssertEqual(try! cdfNoncentralTBenton(t: 10, df: 22, delta: 10, errtol: Double.ulpOfOne, maxitr: 1000), 0.469124289769452233227, accuracy: 1E-16)
        /*
         R code:
         > qt(p = 0,df = 21,ncp = 3)
         [1] -Inf
         > qt(p = 0.25,df = 21,ncp = 3)
         [1] 2.312281
         > qt(p = 0.5,df = 21,ncp = 3)
         [1] 3.038146
         > qt(p = 0.75,df = 21,ncp = 3)
         [1] 3.82973
         > qt(p = 0.99,df = 21,ncp = 3)
         [1] 6.238628
         > qt(p = 1,df = 21,ncp = 3)
         [1] Inf
        */
        XCTAssertEqual(try! quantileStudentTDist(p: 0, degreesOfFreedom: 21, nonCentralityPara: 3), -Double.infinity)
        XCTAssertEqual(try! quantileStudentTDist(p: 0.25, degreesOfFreedom: 21, nonCentralityPara: 3), 2.312281, accuracy: 1e-6)
        XCTAssertEqual(try! quantileStudentTDist(p: 0.5, degreesOfFreedom: 21, nonCentralityPara: 3), 3.038146, accuracy: 1e-6)
        XCTAssertEqual(try! quantileStudentTDist(p: 0.75, degreesOfFreedom: 21, nonCentralityPara: 3), 3.82973, accuracy: 1e-6)
        XCTAssertEqual(try! quantileStudentTDist(p: 0.99, degreesOfFreedom: 21, nonCentralityPara: 3), 6.238628, accuracy: 1e-6)
        XCTAssertEqual(try! quantileStudentTDist(p: 1, degreesOfFreedom: 21, nonCentralityPara: 3), Double.infinity)
        /*
         nd = NormalDistribution[3, 1/2];
         N[Kurtosis[nd], 21]
         N[Mean[nd], 21]
         N[Skewness[nd], 21]
         N[Variance[nd], 21]
         */
        para = paraNormalDistribution(mean: 2, standardDeviation: 0.5)
        XCTAssertEqual(para!.kurtosis, 3.0, accuracy: 1e-12)
        XCTAssertEqual(para!.mean, 2.0, accuracy: 1e-12)
        XCTAssertEqual(para!.skewness, 0.0, accuracy: 1e-12)
        XCTAssertEqual(para!.variance, 0.25, accuracy: 1e-12)

        /*
         R code:
         > pnorm(q = 2,mean = 0,sd = 1)
         [1] 0.9772499
         > pnorm(q = -2,mean = 0,sd = 1)
         [1] 0.02275013
         > pnorm(q = 3,mean = 22,sd = 3)
         [1] 1.199602e-10
         > pnorm(q = -3,mean = 22,sd = 3)
         [1] 3.929873e-17
         > pnorm(q = -3,mean = -3.5,sd = 0.5)
         [1] 0.8413447
        */
        XCTAssertEqual(try! cdfNormalDist(x: 2, mean: 0, variance: 1), 0.977249868, accuracy: 1E-8)
        XCTAssertEqual(cdfStandardNormalDist(u: 2), 0.977249868, accuracy: 1E-8)
        XCTAssertEqual(cdfStandardNormalDist(u: -2), 0.0227501319, accuracy: 1E-8)
        XCTAssertEqual(try! cdfNormalDist(x: 3, mean: 22, standardDeviation: 3), 1.19960226E-10, accuracy: 1E-18)
        XCTAssertEqual(try! cdfNormalDist(x: -3, mean: 22, standardDeviation: 3), 3.92987343E-17, accuracy: 1E-25)
        XCTAssertEqual(try! cdfNormalDist(x: -3, mean: -3.5, standardDeviation: 0.5), 0.841344746, accuracy: 1E-9)
        /*
         R code:
         > dnorm(x = 2,mean = 0, sd = 1)
         [1] 0.05399097
         > dnorm(x = -2,mean = 0, sd = 1)
         [1] 0.05399097
         > dnorm(x = 3,mean = 22, sd = 3)
         [1] 2.592816e-10
         > dnorm(x = -3,mean = 22, sd = 3)
         [1] 1.106928e-16
         > dnorm(x = -3,mean = -3.5, sd = 0.5)
         [1] 0.4839414
         >
        */
        XCTAssertEqual(try! pdfNormalDist(x: 2, mean: 0, variance: 1), 0.0539909665, accuracy: 1E-8)
        XCTAssertEqual(pdfStandardNormalDist(u: 2), 0.0539909665, accuracy: 1E-8)
        XCTAssertEqual(pdfStandardNormalDist(u: -2), 0.0539909665, accuracy: 1E-8)
        XCTAssertEqual(try! pdfNormalDist(x: 3, mean: 22, standardDeviation: 3), 2.59281602E-10, accuracy: 1E-18)
        XCTAssertEqual(try! pdfNormalDist(x: -3, mean: 22, standardDeviation: 3), 1.10692781E-16, accuracy: 1E-23)
        XCTAssertEqual(try! pdfNormalDist(x: -3, mean: -3.5, standardDeviation: 0.5), 0.483941449, accuracy: 1E-9)

        /*
         R code:
         > qnorm(p = 1/3, mean = 0, sd = 1)
         [1] -0.4307273
         > qnorm(p = 5/100, mean = 0, sd = 1)
         [1] -1.644854
         > qnorm(p = 5/10, mean = 0, sd = 1)
         [1] 0
         > qnorm(p = 1/3, mean = 2, sd = 0.5)
         [1] 1.784636
         > qnorm(p = 5/100, mean = 2, sd = 0.5)
         [1] 1.177573
         > qnorm(p = 5/10, mean = 2, sd = 0.5)
         [1] 2
        */
        XCTAssertEqual(try! quantileStandardNormalDist(p: 1.0/3.0), -0.430727, accuracy: 1E-6)
        XCTAssertEqual(try! quantileStandardNormalDist(p: 5.0/100.0), -1.64485, accuracy: 1E-5)
        XCTAssertEqual(try! quantileStandardNormalDist(p: 5.0/10.0), 0, accuracy: 1E-6)
        XCTAssertEqual(try! quantileNormalDist(p: 1.0/3.0, mean: 2, standardDeviation: 0.5), 1.78464, accuracy: 1E-4)
        XCTAssertEqual(try! quantileNormalDist(p: 5/100.0, mean: 2, standardDeviation: 0.5), 1.17757, accuracy: 1E-4)
        XCTAssertEqual(try! quantileNormalDist(p: 5/10.0, mean: 2, standardDeviation: 0.5), 2, accuracy: 1E-6)
        /*
         df = 11;
         chd = ChiSquareDistribution[df];
         N[Mean[chd], 21]
         N[Variance[chd], 21]
         N[Skewness[chd], 21]
         N[Kurtosis[chd], 21]
         */
        para = try! paraChiSquareDist(degreesOfFreedom: 11)
        XCTAssertEqual(para!.kurtosis, 4.09090909090909090909, accuracy: 1e-12)
        XCTAssertEqual(para!.mean, 11, accuracy: 1e-12)
        XCTAssertEqual(para!.skewness, 0.852802865422441737194, accuracy: 1e-12)
        XCTAssertEqual(para!.variance, 22, accuracy: 1e-12)

        /*
         R code:
        > pchisq(q = 1,df = 10,ncp = 0)
        [1] 0.0001721156
        > pchisq(q = 1,df = 16,ncp = 0)
        [1] 6.219691e-08
        > pchisq(q = -1,df = 16,ncp = 0)
        [1] 0
        > pchisq(q = 16,df = 16,ncp = 0)
        [1] 0.5470392
        > pchisq(q = -16,df = 16,ncp = 0)
        [1] 0
        */
        XCTAssertEqual(try! cdfChiSquareDist(chi: 1, degreesOfFreedom: 16), 6.219691E-08, accuracy: 1E-14)
        XCTAssertEqual(try! cdfChiSquareDist(chi: -1, degreesOfFreedom: 16), 0, accuracy: 1E-14)
        XCTAssertEqual(try! cdfChiSquareDist(chi: 16, degreesOfFreedom: 16), 0.5470392, accuracy: 1E-7)
        XCTAssertEqual(try! cdfChiSquareDist(chi: -16, degreesOfFreedom: 16), 0, accuracy: 1E-7)
        /*
         R code:
         > dchisq(x = 1,df = 16,ncp = 0)
         [1] 4.700913e-07
         > dchisq(x = -1,df = 16,ncp = 0)
         [1] 0
         > dchisq(x = 16,df = 16,ncp = 0)
         [1] 0.06979327
         > dchisq(x = -16,df = 16,ncp = 0)
         [1] 0
        */
        
        XCTAssertEqual(try! pdfChiSquareDist(chi: 1, degreesOfFreedom: 16), 4.700913e-07, accuracy: 1E-13)
        XCTAssertEqual(try! pdfChiSquareDist(chi: -1, degreesOfFreedom: 16), 0, accuracy: 1E-14)
        XCTAssertEqual(try! pdfChiSquareDist(chi: 16, degreesOfFreedom: 16), 0.06979327, accuracy: 1E-7)
        XCTAssertEqual(try! pdfChiSquareDist(chi: -16, degreesOfFreedom: 16), 0, accuracy: 1E-7)
        /*
         R code:
         > qchisq(p = 0, df = 16)
         [1] 0
         > qchisq(p = 0.25, df = 16)
         [1] 11.91222
         > qchisq(p = 0.5, df = 16)
         [1] 15.3385
         > qchisq(p = 0.75, df = 16)
         [1] 19.36886
         > qchisq(p = 0.99, df = 16)
         [1] 31.99993
         > qchisq(p = 1, df = 16)
         [1] Inf
        */
        XCTAssertEqual(try! quantileChiSquareDist(p: 0, degreesOfFreedom: 16), 0, accuracy: 1E-13)
        XCTAssertEqual(try! quantileChiSquareDist(p: 0.25, degreesOfFreedom: 16), 11.91222, accuracy: 1E-5)
        XCTAssertEqual(try! quantileChiSquareDist(p: 0.5, degreesOfFreedom: 16), 15.3385, accuracy: 1E-4)
        XCTAssertEqual(try! quantileChiSquareDist(p: 0.75, degreesOfFreedom: 16), 19.36886, accuracy: 1E-5)
        XCTAssertEqual(try! quantileChiSquareDist(p: 0.99, degreesOfFreedom: 16), 31.99993, accuracy: 1E-5)
        XCTAssert(try! quantileChiSquareDist(p: 1.0, degreesOfFreedom: 16).isInfinite)

        
        /*
         df1 = 4;
         df2 = 9;
         fd = FRatioDistribution[df1, df2];
         N[Mean[fd], 21]
         N[Variance[fd], 21]
         N[Skewness[fd], 21]
         N[Kurtosis[fd], 21]
         */
        para = try! paraFRatioDist(numeratorDF: 4, denominatorDF: 9)
        XCTAssertEqual(para!.kurtosis, 117.272727272727272727, accuracy: 1e-12)
        XCTAssertEqual(para!.mean, 1.28571428571428571429, accuracy: 1e-12)
        XCTAssertEqual(para!.skewness, 4.76731294622796157723, accuracy: 1e-12)
        XCTAssertEqual(para!.variance, 1.81836734693877551020, accuracy: 1e-12)

        /*
         R code:
         > pf(q = 2,df1 = 2,df2 = 3)
         [1] 0.7194341
         > pf(q = 2,df1 = 22,df2 = 3)
         [1] 0.6861387
         > pf(q = 2,df1 = 3,df2 = 22)
         [1] 0.8565898
         > pf(q = -2,df1 = 3,df2 = 22)
         [1] 0
         > pf(q = -2/100000,df1 = 3,df2 = 22)
         [1] 0
         > pf(q = 0,df1 = 3,df2 = 22)
         [1] 0
         > pf(q = 33,df1 = 3,df2 = 22)
         [1] 1
         > pf(q = 3,df1 = 3,df2 = 22)
         [1] 0.9475565
        */
        XCTAssertEqual(try! cdfFRatio(f: 2, numeratorDF: 2, denominatorDF: 3), 0.7194341, accuracy: 1E-7)
        XCTAssertEqual(try! cdfFRatio(f: 2, numeratorDF: 22, denominatorDF: 3), 0.6861387, accuracy: 1E-7)
        XCTAssertEqual(try! cdfFRatio(f: 2, numeratorDF: 3, denominatorDF: 22), 0.8565898, accuracy: 1E-7)
        XCTAssertEqual(try! cdfFRatio(f: -2, numeratorDF: 3, denominatorDF: 22), 0, accuracy: 1E-7)
        XCTAssertEqual(try! cdfFRatio(f: 0, numeratorDF: 3, denominatorDF: 22), 0, accuracy: 1E-7)
        XCTAssertEqual(try! cdfFRatio(f: 33, numeratorDF: 3, denominatorDF: 22), 1, accuracy: 1E-7)
        XCTAssertEqual(try! cdfFRatio(f: 3, numeratorDF: 3, denominatorDF: 22), 0.9475565, accuracy: 1E-7)
        /*
         R code
         > df(x = 2,df1 = 2,df2 = 3)
         [1] 0.1202425
         > df(x = 2,df1 = 22,df2 = 3)
         [1] 0.1660825
         > df(x = 2,df1 = 3,df2 = 22)
         [1] 0.1486917
         > df(x = -2,df1 = 3,df2 = 22)
         [1] 0
         > df(x = 0,df1 = 3,df2 = 22)
         [1] 0
         > df(x = 33,df1 = 3,df2 = 22)
         [1] 6.849943e-09
         > df(x = 3,df1 = 3,df2 = 22)
         [1] 0.05102542
        */
        XCTAssertEqual(try! pdfFRatioDist(f: 2, numeratorDF: 2, denominatorDF: 3), 0.1202425, accuracy: 1E-7)
        XCTAssertEqual(try! pdfFRatioDist(f: 2, numeratorDF: 22, denominatorDF: 3), 0.1660825, accuracy: 1E-7)
        XCTAssertEqual(try! pdfFRatioDist(f: 2, numeratorDF: 3, denominatorDF: 22), 0.1486917, accuracy: 1E-7)
        XCTAssertEqual(try! pdfFRatioDist(f: -2, numeratorDF: 3, denominatorDF: 22), 0, accuracy: 1E-7)
        XCTAssertEqual(try! pdfFRatioDist(f: 0, numeratorDF: 3, denominatorDF: 22), 0, accuracy: 1E-7)
        XCTAssertEqual(try! pdfFRatioDist(f: 33, numeratorDF: 3, denominatorDF: 22), 6.849943e-09, accuracy: 1E-15)
        XCTAssertEqual(try! pdfFRatioDist(f: 3, numeratorDF: 3, denominatorDF: 22), 0.05102542, accuracy: 1E-7)
        /*
         R code:
         > qf(p = 0,df1 = 2,df2 = 3)
         [1] 0
         > qf(p = 0.25,df1 = 2,df2 = 3)
         [1] 0.3171206
         > qf(p = 0.5,df1 = 2,df2 = 3)
         [1] 0.8811016
         > qf(p = 0.75,df1 = 2,df2 = 3)
         [1] 2.279763
         > qf(p = 0.99,df1 = 2,df2 = 3)
         [1] 30.81652
         > qf(p = 0.25,df1 = 22,df2 = 3)
         [1] 0.6801509
         > qf(p = 0.5,df1 = 22,df2 = 3)
         [1] 1.229022
         > qf(p = 0.75,df1 = 22,df2 = 3)
         [1] 2.461528
         > qf(p = 0.99,df1 = 22,df2 = 3)
         [1] 26.63955
         > qf(p = 1,df1 = 22,df2 = 3)
         [1] Inf
        */
        XCTAssertEqual(try! quantileFRatioDist(p: 0, numeratorDF: 2, denominatorDF: 3), 0, accuracy: 0)
        XCTAssertEqual(try! quantileFRatioDist(p: 0.25, numeratorDF: 2, denominatorDF: 3), 0.3171206, accuracy: 1E-7)
        XCTAssertEqual(try! quantileFRatioDist(p: 0.5, numeratorDF: 2, denominatorDF: 3), 0.8811016, accuracy: 1E-7)
        XCTAssertEqual(try! quantileFRatioDist(p: 0.75, numeratorDF: 2, denominatorDF: 3), 2.279763, accuracy: 1E-6)
        XCTAssertEqual(try! quantileFRatioDist(p: 0.99, numeratorDF: 2, denominatorDF: 3), 30.81652, accuracy: 1E-5)
        XCTAssertEqual(try! quantileFRatioDist(p: 0.25, numeratorDF: 22, denominatorDF: 3), 0.6801509, accuracy: 1E-6)
        XCTAssertEqual(try! quantileFRatioDist(p: 0.5, numeratorDF: 22, denominatorDF: 3), 1.229022, accuracy: 1E-6)
        XCTAssertEqual(try! quantileFRatioDist(p: 0.75, numeratorDF: 22, denominatorDF: 3), 2.461528, accuracy: 1E-6)
        XCTAssertEqual(try! quantileFRatioDist(p: 0.99, numeratorDF: 22, denominatorDF: 3), 26.63955, accuracy: 1E-5)
        XCTAssert(try! quantileFRatioDist(p: 1.0, numeratorDF: 22, denominatorDF: 3).isInfinite)
        /*
         df1 = 4;
         df2 = 9;
         fd = FRatioDistribution[df1, df2];
         N[Mean[fd], 21]
         N[Variance[fd], 21]
         N[Skewness[fd], 21]
         N[Kurtosis[fd], 21]
         */
        para = try! paraLogNormalDist(mean: 3, variance: 0.25)
        XCTAssertEqual(para!.kurtosis, 8.89844567378477901300, accuracy: 1e-12)
        XCTAssertEqual(para!.mean, 22.7598950935267279834, accuracy: 1e-12)
        XCTAssertEqual(para!.skewness, 1.75018965506971818265, accuracy: 1e-12)
        XCTAssertEqual(para!.variance, 147.128808376019814754, accuracy: 1e-12)

        /*
         R code
         > plnorm(1,meanlog = 0,sdlog = 1)
         [1] 0.5
         > plnorm(1,meanlog = 0,sdlog = 0.5)
         [1] 0.5
         > plnorm(2,meanlog = 0,sdlog = 0.5)
         [1] 0.9171715
         > plnorm(2,meanlog = 3,sdlog = 0.5)
         [1] 1.977763e-06
        */
        XCTAssertEqual(try! cdfLogNormal(x: 1, mean: 0, variance: 1), 0.5, accuracy: 1E-1)
        XCTAssertEqual(try! cdfLogNormal(x: 1, mean: 0, variance: 0.25), 0.5, accuracy: 1E-1)
        XCTAssertEqual(try! cdfLogNormal(x: 2, mean: 0, variance: 0.25), 0.9171715, accuracy: 1E-7)
        XCTAssertEqual(try! cdfLogNormal(x: 2, mean: 3, variance: 0.25), 1.977763E-06, accuracy: 1E-12)
        /*
         R code
         > dlnorm(2,meanlog = 0,sdlog = 1)
         [1] 0.156874
         > dlnorm(1,meanlog = 0,sdlog = 1)
         [1] 0.3989423
         > dlnorm(1,meanlog = 0,sdlog = 0.5)
         [1] 0.7978846
         > dlnorm(2,meanlog = 0,sdlog = 0.5)
         [1] 0.1526138
         > dlnorm(2,meanlog = 3,sdlog = 0.5)
         [1] 9.520355e-06
        */
        XCTAssertEqual(try! pdfLogNormalDist(x: 1, mean: 0, variance: 1), 0.3989423, accuracy: 1E-6)
        XCTAssertEqual(try! pdfLogNormalDist(x: 1, mean: 0, variance: 0.25), 0.7978846, accuracy: 1E-6)
        XCTAssertEqual(try! pdfLogNormalDist(x: 2, mean: 0, variance: 0.25), 0.1526138, accuracy: 1E-6)
        XCTAssertEqual(try! pdfLogNormalDist(x: 2, mean: 3, variance: 0.25), 9.520355e-06, accuracy: 1E-12)
        /*
         > qlnorm(0,meanlog = 0,sdlog = 1)
         [1] 0
         > qlnorm(0.25,meanlog = 0,sdlog = 1)
         [1] 0.5094163
         > qlnorm(0.5,meanlog = 0,sdlog = 1)
         [1] 1
         > qlnorm(0.75,meanlog = 0,sdlog = 1)
         [1] 1.963031
         > qlnorm(0.99,meanlog = 0,sdlog = 1)
         [1] 10.24047
         > qlnorm(1,meanlog = 0,sdlog = 1)
         [1] Inf
        */
        XCTAssertEqual(try! quantileLogNormal(p: 0, mean: 0, variance: 1), 0, accuracy: 0)
        XCTAssertEqual(try! quantileLogNormal(p: 0.25, mean: 0, variance: 1), 0.5094163, accuracy: 1E-6)
        XCTAssertEqual(try! quantileLogNormal(p: 0.5, mean: 0, variance: 1), 1, accuracy: 0)
        XCTAssertEqual(try! quantileLogNormal(p: 0.75, mean: 0, variance: 1), 1.963031, accuracy: 1E-6)
        XCTAssert(try! quantileLogNormal(p: 1.0, mean: 0, variance: 1).isInfinite)

        /*
         shapeA = 2;
         shapeB = 25/10;
         bd = BetaDistribution[shapeA, shapeB];
         N[Mean[bd], 21]
         N[Variance[bd], 21]
         N[Skewness[bd], 21]
         N[Kurtosis[bd], 21]
         */
        para = try! paraBetaDist(shapeA: 2, shapeB: 2.5)
        XCTAssertEqual(para!.mean, 0.444444444444444444444, accuracy: 1e-12)
        XCTAssertEqual(para!.variance, 0.0448933782267115600449, accuracy: 1e-12)
        XCTAssertEqual(para!.skewness, 0.161355207410792545691, accuracy: 1e-12)
        XCTAssertEqual(para!.kurtosis, 2.23384615384615384615, accuracy: 1e-12)
        /*
         R code:
         > pbeta(q = 0.2,shape1 = 1,shape2 = 2)
         [1] 0.36
         > pbeta(q = 0.6,shape1 = 1,shape2 = 2)
         [1] 0.84
         > pbeta(q = 0.9,shape1 = 1,shape2 = 2)
         [1] 0.99
         > pbeta(q = 0.2,shape1 = 3,shape2 = 2)
         [1] 0.0272
         > pbeta(q = 0.6,shape1 = 3,shape2 = 2.5)
         [1] 0.587639
         > pbeta(q = 0.6,shape1 = 0.5,shape2 = 2.5)
         [1] 0.9591406
         > pbeta(q = 0.6,shape1 = 0.5,shape2 = 0.5)
         [1] 0.5640942
         > pbeta(q = 0.6,shape1 = 0.99,shape2 = 0)
         [1] 0
        */
        XCTAssertEqual(try! cdfBetaDist(x: 0.2, shapeA: 1, shapeB: 2), 0.36, accuracy: 1e-2)
        XCTAssertEqual(try! cdfBetaDist(x: 0.6, shapeA: 1, shapeB: 2), 0.84, accuracy: 1e-2)
        XCTAssertEqual(try! cdfBetaDist(x: 0.9, shapeA: 1, shapeB: 2), 0.99, accuracy: 1e-2)
        XCTAssertEqual(try! cdfBetaDist(x: 0.2, shapeA: 3, shapeB: 2), 0.0272, accuracy: 1e-4)
        XCTAssertEqual(try! cdfBetaDist(x: 0.6, shapeA: 3, shapeB: 2.5), 0.587639, accuracy: 1e-6)
        XCTAssertEqual(try! cdfBetaDist(x: 0.6, shapeA: 0.5, shapeB: 2.5), 0.9591406, accuracy: 1e-6)
        XCTAssertEqual(try! cdfBetaDist(x: 0.6, shapeA: 0.5, shapeB: 0.5), 0.5640942, accuracy: 1e-6)
        XCTAssertThrowsError(try cdfBetaDist(x: 0.6, shapeA: 0.99, shapeB: 0))
        /*
         dbeta(x = 0.2,shape1 = 1,shape2 = 2)
         [1] 1.6
         > dbeta(x = 0,shape1 = 1,shape2 = 2)
         [1] 2
         > dbeta(x = 0.9,shape1 = 1,shape2 = 2)
         [1] 0.2
         > dbeta(x = 0.2,shape1 = 3,shape2 = 2)
         [1] 0.384
         > dbeta(x = 0.6,shape1 = 3,shape2 = 2.5)
         [1] 1.793011
         > dbeta(x = 0.6,shape1 = 0.5,shape2 = 2.5)
         [1] 0.2772255
         > dbeta(x = 0.6,shape1 = 0.5,shape2 = 0.5)
         [1] 0.6497473
         */
        XCTAssertEqual(try! pdfBetaDist(x: 0.2, shapeA: 1, shapeB: 2), 1.6, accuracy: 1e-1)
        XCTAssertEqual(try! pdfBetaDist(x: 0, shapeA: 1, shapeB: 2), 2.0, accuracy: 1e-1)
        XCTAssertEqual(try! pdfBetaDist(x: 0.9, shapeA: 1, shapeB: 2), 0.2, accuracy: 1e-1)
        XCTAssertEqual(try! pdfBetaDist(x: 0.2, shapeA: 3, shapeB: 2), 0.384, accuracy: 1e-3)
        XCTAssertEqual(try! pdfBetaDist(x: 0.6, shapeA: 3, shapeB: 2.5), 1.793011, accuracy: 1e-6)
        XCTAssertEqual(try! pdfBetaDist(x: 0.6, shapeA: 0.5, shapeB: 2.5), 0.2772255, accuracy: 1e-7)
        XCTAssertEqual(try! pdfBetaDist(x: 0.6, shapeA: 0.5, shapeB: 0.5), 0.6497473, accuracy: 1e-7)
        /*
         > qbeta(p = 0,shape1 = 1,shape2 = 2)
         [1] 0
         > qbeta(p = 0.25,shape1 = 1,shape2 = 2)
         [1] 0.1339746
         > qbeta(p = 0.5,shape1 = 1,shape2 = 2)
         [1] 0.2928932
         > qbeta(p = 0.75,shape1 = 1,shape2 = 2)
         [1] 0.5
         > qbeta(p = 0.99,shape1 = 1,shape2 = 2)
         [1] 0.9
         > qbeta(p = 1,shape1 = 1,shape2 = 2)
         [1] 1
         */
        XCTAssertEqual(try! quantileBetaDist(p: 0, shapeA: 1, shapeB: 2), 0, accuracy: 1e-1)
        XCTAssertEqual(try! quantileBetaDist(p: 0.25, shapeA: 1, shapeB: 2), 0.1339746, accuracy: 1e-7)
        XCTAssertEqual(try! quantileBetaDist(p: 0.5, shapeA: 1, shapeB: 2), 0.2928932, accuracy: 1e-7)
        XCTAssertEqual(try! quantileBetaDist(p: 0.75, shapeA: 1, shapeB: 2), 0.5, accuracy: 1e-1)
        XCTAssertEqual(try! quantileBetaDist(p: 0.99, shapeA: 1, shapeB: 2), 0.9, accuracy: 1e-1)
        XCTAssertEqual(try! quantileBetaDist(p: 1.0, shapeA: 1, shapeB: 2), 1.0, accuracy: 1e-1)
        /*
         loc = 99;
         scale = 25/100;
         cd = CauchyDistribution[loc, scale];
         N[Mean[cd], 21]
         N[Variance[cd], 21]
         N[Skewness[cd], 21]
         N[Kurtosis[cd], 21]
         */
        para = try! paraCauchyDist(location: 99, scale: 0.25)
        XCTAssert(para!.mean.isNaN)
        XCTAssert(para!.variance.isNaN)
        XCTAssert(para!.skewness.isNaN)
        XCTAssert(para!.kurtosis.isNaN)
        /*
         R code:
         > pcauchy(q = 1,location = 1,scale = 1/2)
         [1] 0.5
         > pcauchy(q = -10,location = -2,scale = 3)
         [1] 0.1142003
         > pcauchy(q = 10,location = -2,scale = 3)
         [1] 0.9220209
         > pcauchy(q = 0,location = 99,scale = 3)
         [1] 0.009642803
         > pcauchy(q = 2,location = 3,scale = 0.25)
         [1] 0.07797913
        */
        XCTAssertEqual(try! cdfCauchyDist(x: 1, location: 1, scale: 0.5), 0.5, accuracy: 1E-1)
        XCTAssertEqual(try! cdfCauchyDist(x: -10, location: -2, scale: 3), 0.1142003, accuracy: 1E-7)
        XCTAssertEqual(try! cdfCauchyDist(x: 10, location: -2, scale: 3), 0.9220209, accuracy: 1E-7)
        XCTAssertEqual(try! cdfCauchyDist(x: 0, location: 99, scale: 3), 0.009642803, accuracy: 1E-7)
        XCTAssertEqual(try! cdfCauchyDist(x: 2, location: 3, scale: 0.25), 0.07797913, accuracy: 1E-7)
        
        /*
         R code:
         > dcauchy(x = 1,location = 1,scale = 0.5)
         [1] 0.6366198
         > dcauchy(x = -10,location = -2,scale = 3)
         [1] 0.01308123
         > dcauchy(x = 10,location = -2,scale = 3)
         [1] 0.00624137
         > dcauchy(x = 0,location = 99,scale = 3)
         [1] 9.734247e-05
         > dcauchy(x = 2,location = 3,scale = 0.25)
         [1] 0.07489644
         */
        XCTAssertEqual(try! pdfCauchyDist(x: 1, location: 1, scale: 0.5), 0.6366198, accuracy: 1E-7)
        XCTAssertEqual(try! pdfCauchyDist(x: -10, location: -2, scale: 3), 0.01308123, accuracy: 1E-7)
        XCTAssertEqual(try! pdfCauchyDist(x: 10, location: -2, scale: 3), 0.00624137, accuracy: 1E-7)
        XCTAssertEqual(try! pdfCauchyDist(x: 0, location: 99, scale: 3), 9.734247e-05, accuracy: 1E-11)
        XCTAssertEqual(try! pdfCauchyDist(x: 2, location: 3, scale: 0.25), 0.07489644, accuracy: 1E-7)

        /*
         R code:
         > qcauchy(p = 0,location = 1, scale = 0.5)
         [1] -Inf
         > qcauchy(p = 0.25,location = -2, scale = 3)
         [1] -5
         > qcauchy(p = 0.5,location = -2, scale = 3)
         [1] -2
         > qcauchy(p = 0.75,location = 99, scale = 3)
         [1] 102
         > qcauchy(p = 0.99,location = 3, scale = 0.25)
         [1] 10.95513
         > qcauchy(p = 1,location = 3, scale = 0.25)
         [1] Inf
         */
        XCTAssertEqual(try! quantileCauchyDist(p: 0, location: 1, scale: 0.5), -Double.infinity)
        XCTAssertEqual(try! quantileCauchyDist(p: 0.25, location: -2, scale: 3), -5.0, accuracy: 1E-1)
        XCTAssertEqual(try! quantileCauchyDist(p: 0.5, location: -2, scale: 3), -2.0, accuracy: 1E-1)
        XCTAssertEqual(try! quantileCauchyDist(p: 0.75, location: 99, scale: 3), 102.0, accuracy: 1E-1)
        XCTAssertEqual(try! quantileCauchyDist(p: 0.99, location: 3, scale: 0.25), 10.95513, accuracy: 1E-5)
        XCTAssertEqual(try! quantileCauchyDist(p: 1, location: 3, scale: 0.25), Double.infinity)
        /*
         loc = 0;
         scale = 1;
         cd = LaplaceDistribution[loc, scale];
         N[Mean[cd], 21]
         N[Variance[cd], 21]
         N[Skewness[cd], 21]
         N[Kurtosis[cd], 21]
         */
        para = try! paraLaplaceDist(mean: 0, scale: 1)
        XCTAssertEqual(para!.mean, 0.0, accuracy: 1e-12)
        XCTAssertEqual(para!.variance, 2.0, accuracy: 1e-12)
        XCTAssertEqual(para!.skewness, 0.0, accuracy: 1e-12)
        XCTAssertEqual(para!.kurtosis, 6.0, accuracy: 1e-12)

        /*
         Mathematica
         loc = 0;
         scale = 1;
         cd = LaplaceDistribution[loc, scale];
         N[CDF[cd, 1], 7]
         N[CDF[cd, -8], 7]
         N[CDF[cd, 19], 7]
         N[CDF[cd, 1/2], 7]
         */
        XCTAssertEqual(try! cdfLaplaceDist(x: 1, mean: 0, scale: 1), 0.8160603, accuracy: 1e-7)
        XCTAssertEqual(try! cdfLaplaceDist(x: -8, mean: 0, scale: 1), 0.0001677313, accuracy: 1e-9)
        XCTAssertEqual(try! cdfLaplaceDist(x: 19, mean: 0, scale: 1), 1.0, accuracy: 1e-1)
        XCTAssertEqual(try! cdfLaplaceDist(x: 0.5, mean: 0, scale: 1), 0.6967347, accuracy: 1e-7)
        /*
         Mathematica
         loc = 0;
         scale = 1;
         cd = LaplaceDistribution[loc, scale];
         N[PDF[cd, 1], 7]
         N[PDF[cd, -8], 7]
         N[PDF[cd, 19], 7]
         N[PDF[cd, 1/2], 7]
         */
        XCTAssertEqual(try! pdfLaplaceDist(x: 1, mean: 0, scale: 1), 0.1839397, accuracy: 1e-7)
        XCTAssertEqual(try! pdfLaplaceDist(x: -8, mean: 0, scale: 1), 0.0001677313, accuracy: 1e-9)
        XCTAssertEqual(try! pdfLaplaceDist(x: 19, mean: 0, scale: 1), 2.801398E-9, accuracy: 1e-15)
        XCTAssertEqual(try! pdfLaplaceDist(x: 0.5, mean: 0, scale: 1), 0.3032653, accuracy: 1e-7)
        /*
         Mathematica
         loc = 0;
         scale = 1;
         cd = LaplaceDistribution[loc, scale];
         N[InverseCDF[cd, 1], 7]
         N[InverseCDF[cd, 1/2], 7]
         N[InverseCDF[cd, 75/100], 7]
         N[InverseCDF[cd, 99/100], 7]
         N[InverseCDF[cd, 0], 7]
         */
        XCTAssertEqual(try! quantileLaplaceDist(p: 1, mean: 0, scale: 1), Double.infinity)
        XCTAssertEqual(try! quantileLaplaceDist(p: 0.5, mean: 0, scale: 1), 0)
        XCTAssertEqual(try! quantileLaplaceDist(p: 0.75, mean: 0, scale: 1), 0.6931472, accuracy: 1e-7)
        XCTAssertEqual(try! quantileLaplaceDist(p: 0.99, mean: 0, scale: 1), 3.912023, accuracy: 1e-7)
        XCTAssertEqual(try! quantileLaplaceDist(p: 0, mean: 0, scale: 1), -Double.infinity)

        /*
         loc = 3;
         scale = 2;
         d = LogisticDistribution[loc, scale];
         N[Mean[d], 21]
         N[Variance[d], 21]
         N[Skewness[d], 21]
         N[Kurtosis[d], 21]
         */
        para = try! paraLogisticDist(mean: 3, scale: 2)
        XCTAssertEqual(para!.mean, 3.0, accuracy: 1e-12)
        XCTAssertEqual(para!.variance, 13.1594725347858114918, accuracy: 1e-12)
        XCTAssertEqual(para!.skewness, 0.0, accuracy: 1e-12)
        XCTAssertEqual(para!.kurtosis, 4.20000000000000000000, accuracy: 1e-12)

        /*
         R code
         > plogis(q = 1,location = 3,scale = 2)
         [1] 0.2689414
         > plogis(q = 55,location = 3,scale = 2)
         [1] 1
         > plogis(q = 3,location = -2,scale = 22)
         [1] 0.5592442
        */
        XCTAssertEqual(try! cdfLogisticDist(x: 1, mean: 3, scale: 2), 0.2689414, accuracy: 1e-7)
        XCTAssertEqual(try! cdfLogisticDist(x: 55, mean: 3, scale: 2), 1.0, accuracy: 1e-1)
        XCTAssertEqual(try! cdfLogisticDist(x: 3, mean: -2, scale: 22), 0.5565749, accuracy: 1e-7)
        XCTAssertThrowsError(try cdfLogisticDist(x: -3, mean: 3, scale: 0))
        
        /*
         R code
         > plogis(q = 1,location = 3,scale = 2)
         [1] 0.2689414
         > plogis(q = 55,location = 3,scale = 2)
         [1] 1
         > plogis(q = 3,location = -2,scale = 22)
         [1] 0.5592442
         */
        XCTAssertEqual(try! cdfLogisticDist(x: 1, mean: 3, scale: 2), 0.2689414, accuracy: 1e-7)
        XCTAssertEqual(try! cdfLogisticDist(x: 55, mean: 3, scale: 2), 1.0, accuracy: 1e-1)
        XCTAssertEqual(try! cdfLogisticDist(x: 3, mean: -2, scale: 22), 0.5565749, accuracy: 1e-7)
        XCTAssertThrowsError(try cdfLogisticDist(x: -3, mean: 3, scale: 0))
        /*
         > dlogis(x = 1,location = 3,scale = 2)
         [1] 0.09830597
         > dlogis(x = 55,location = 3,scale = 2)
         [1] 2.554545e-12
         > dlogis(x = 3,location = -2,scale = 22)
         [1] 0.01121815
         */
        XCTAssertEqual(try! pdfLogisticDist(x: 1, mean: 3, scale: 2), 0.09830597, accuracy: 1e-7)
        XCTAssertEqual(try! pdfLogisticDist(x: 55, mean: 3, scale: 2), 2.554545e-12, accuracy: 1e-18)
        XCTAssertEqual(try! pdfLogisticDist(x: 3, mean: -2, scale: 22), 0.01121815, accuracy: 1e-7)
        XCTAssertThrowsError(try pdfLogisticDist(x: -3, mean: 3, scale: 0))
        /*
         > qlogis(p = 0, location = 3,scale = 22)
         [1] -Inf
         > qlogis(p = 0.25, location = 3,scale = 22)
         [1] -21.16947
         > qlogis(p = 0.5, location = 3,scale = 22)
         [1] 3
         > qlogis(p = 0.75, location = 3,scale = 22)
         [1] 27.16947
         > qlogis(p = 0.99, location = 3,scale = 22)
         [1] 104.0926
         > qlogis(p = 1, location = 3,scale = 22)
         [1] Inf
        */
        XCTAssertEqual(try! quantileLogisticDist(p: 0, mean: 3, scale: 22), -Double.infinity)
        XCTAssertEqual(try! quantileLogisticDist(p: 0.25, mean: 3, scale: 22), -21.16947, accuracy: 1E-5)
        XCTAssertEqual(try! quantileLogisticDist(p: 0.5, mean: 3, scale: 22), 3.0, accuracy: 1E-1)
        XCTAssertEqual(try! quantileLogisticDist(p: 0.75, mean: 3, scale: 22), 27.16947, accuracy: 1E-5)
        XCTAssertEqual(try! quantileLogisticDist(p: 0.99, mean: 3, scale: 22), 104.0926, accuracy: 1E-4)
        XCTAssertEqual(try! quantileLogisticDist(p: 1.0, mean: 3, scale: 22), Double.infinity)
        /*
         min = 1;
         shape = 22;
         d = ParetoDistribution[min, shape];
         N[Mean[d], 21]
         N[Variance[d], 21]
         N[Skewness[d], 21]
         N[Kurtosis[d], 21]
         */
        para = try! paraParetoDist(minimum: 1, shape: 22)
        XCTAssertEqual(para!.mean, 1.04761904761904761905, accuracy: 1e-12)
        XCTAssertEqual(para!.variance, 0.00249433106575963718821, accuracy: 1e-12)
        XCTAssertEqual(para!.skewness, 2.30838311080511823740, accuracy: 1e-12)
        XCTAssertEqual(para!.kurtosis, 11.7703349282296650718, accuracy: 1e-12)

        /*
         Mathematica:
         
         min = 1;
         shape = 22;
         pd = ParetoDistribution[min, shape];
         N[CDF[pd, 0], 21]
         N[CDF[pd, 1], 21]
         N[CDF[pd, 1001/1000], 21]
         N[CDF[pd, 1050/1000], 21]
         N[CDF[pd, 1850/1000], 21]
         N[CDF[pd, 2], 21]
         N[CDF[pd, 25/10], 21]
         Out[154]= 0
         Out[155]= 0
         Out[156]= 0.0217490114154851697621
         Out[157]= 0.658150128913378047621
         Out[158]= 0.999998674981398802671
         Out[159]= 0.999999761581420898438
         Out[160]= 0.999999998240781395558
        */
        XCTAssertThrowsError(try cdfParetoDist(x: 0, minimum: 0, shape: 2))
        XCTAssertThrowsError(try cdfParetoDist(x: 0, minimum: -2, shape: 1))
        XCTAssertEqual(try! cdfParetoDist(x: 0, minimum: 1, shape: 22), 0)
        XCTAssertEqual(try! cdfParetoDist(x: 1.0, minimum: 1, shape: 22), 0)
        XCTAssertEqual(try! cdfParetoDist(x: 1.001, minimum: 1, shape: 22), 0.02174901, accuracy: 1e-7)
        XCTAssertEqual(try! cdfParetoDist(x: 1.05, minimum: 1, shape: 22), 0.6581501, accuracy: 1e-7)
        XCTAssertEqual(try! cdfParetoDist(x: 1.85, minimum: 1, shape: 22), 0.9999987, accuracy: 1e-7)
        XCTAssertEqual(try! cdfParetoDist(x: 2, minimum: 1, shape: 22), 0.9999998, accuracy: 1e-7)
        XCTAssertEqual(try! cdfParetoDist(x: 2.5, minimum: 1, shape: 22), 0.999999998240781395558, accuracy: 1e-12)

        
        /*
         Mathematica:
         
         min = 1;
         shape = 22;
         pd = ParetoDistribution[min, shape];
         N[PDF[pd, 0], 21]
         N[PDF[pd, 1], 21]
         N[PDF[pd, 1001/1000], 21]
         N[PDF[pd, 1050/1000], 21]
         N[PDF[pd, 1850/1000], 21]
         N[PDF[pd, 2], 21]
         N[PDF[pd, 25/10], 21]
         Out[176]= 0
         Out[177]= 22.0000000000000000000
         Out[178]= 21.5000217271321940712
         Out[179]= 7.16256872752922185937
         Out[180]= 0.0000157569779601844505236
         Out[181]= 2.62260437011718750000*10^-6
         Out[182]= 1.54811237190860800000*10^-8
        */
        XCTAssertThrowsError(try pdfParetoDist(x: 0, minimum: 0, shape: 2))
        XCTAssertThrowsError(try pdfParetoDist(x: 0, minimum: -2, shape: 1))
        XCTAssertEqual(try! pdfParetoDist(x: 0, minimum: 1, shape: 22), 0)
        XCTAssertEqual(try! pdfParetoDist(x: 1.0, minimum: 1, shape: 22), 22)
        XCTAssertEqual(try! pdfParetoDist(x: 1.001, minimum: 1, shape: 22), 21.5000217271321940712, accuracy: 1e-12)
        XCTAssertEqual(try! pdfParetoDist(x: 1.05, minimum: 1, shape: 22), 7.16256872752922185937, accuracy: 1e-12)
        XCTAssertEqual(try! pdfParetoDist(x: 1.85, minimum: 1, shape: 22), 0.0000157569779601844505236, accuracy: 1e-12)
        XCTAssertEqual(try! pdfParetoDist(x: 2, minimum: 1, shape: 22),   2.622604e-6, accuracy: 1e-12)
        XCTAssertEqual(try! pdfParetoDist(x: 2.5, minimum: 1, shape: 22), 1.548112e-8, accuracy: 1e-14)

        /*
         Mathematica:
         
         min = 1;
         shape = 22;
         pd = ParetoDistribution[min, shape];
         N[InverseCDF[pd, 0], 21]
         N[InverseCDF[pd, 25/100], 21]
         N[InverseCDF[pd, 5/10], 21]
         N[InverseCDF[pd, 75/100], 21]
         N[InverseCDF[pd, 99/100], 21]
         N[InverseCDF[pd, 1], 21]
         Out[215]= 1.00000000000000000000
         Out[216]= 1.01316232860042649240
         Out[217]= 1.03200827973420963159
         Out[218]= 1.06504108943996267819
         Out[219]= 1.23284673944206613905
         Out[220]= \[Infinity]         */
        XCTAssertThrowsError(try quantileParetoDist(p: 0, minimum: 0, shape: 2))
        XCTAssertThrowsError(try quantileParetoDist(p: 0, minimum: -2, shape: 2))
        XCTAssertThrowsError(try quantileParetoDist(p: -1, minimum: 1, shape: 22))
        XCTAssertEqual(try! quantileParetoDist(p: 0, minimum: 1, shape: 22), 1.0)
        XCTAssertEqual(try! quantileParetoDist(p: 0.25, minimum: 1, shape: 22), 1.01316232860042649240, accuracy: 1e-14)
        XCTAssertEqual(try! quantileParetoDist(p: 0.5, minimum: 1, shape: 22), 1.03200827973420963159, accuracy: 1e-14)
        XCTAssertEqual(try! quantileParetoDist(p: 0.75, minimum: 1, shape: 22), 1.06504108943996267819, accuracy: 1e-14)
        XCTAssertEqual(try! quantileParetoDist(p: 0.99, minimum: 1, shape: 22), 1.23284673944206613905, accuracy: 1e-14)
        XCTAssertEqual(try! quantileParetoDist(p: 1.0, minimum: 1, shape: 22), Double.infinity)
        XCTAssertThrowsError(try quantileParetoDist(p: 1.1, minimum: 1, shape: 22))
        
        /*
         lambda = 1/4;
         d = ExponentialDistribution[lambda];
         N[Mean[d], 21]
         N[Variance[d], 21]
         N[Skewness[d], 21]
         N[Kurtosis[d], 21]
         */
        para = try! paraExponentialDist(lambda: 0.25)
        XCTAssertEqual(para!.mean, 4, accuracy: 1e-12)
        XCTAssertEqual(para!.variance, 16, accuracy: 1e-12)
        XCTAssertEqual(para!.skewness, 2, accuracy: 1e-12)
        XCTAssertEqual(para!.kurtosis, 9, accuracy: 1e-12)

        /*
         Mathematica:
         N[CDF[ed, -2], 21]
         N[CDF[ed, 0], 21]
         N[CDF[ed, 1/2], 21]
         N[CDF[ed, 3], 21]
         N[CDF[ed, 5], 21]
         N[CDF[ed, 22], 21]
         N[CDF[ed, 50], 21]
         Out[242]= 0
         Out[243]= 0
         Out[244]= 0.117503097415404597135
         Out[245]= 0.527633447258985292862
         Out[246]= 0.713495203139809899675
         Out[247]= 0.995913228561535933007
         Out[248]= 0.999996273346827921329
         */
        XCTAssertThrowsError(try cdfExponentialDist(x: 1, lambda: 0))
        XCTAssertThrowsError(try cdfExponentialDist(x: 1, lambda: -1))
        XCTAssertEqual(try! cdfExponentialDist(x: -2, lambda: 0.25), 0)
        XCTAssertEqual(try! cdfExponentialDist(x: 0, lambda: 0.25), 0)
        XCTAssertEqual(try! cdfExponentialDist(x: 0.5, lambda: 0.25), 0.117503097415404597135, accuracy: 1e-14)
        XCTAssertEqual(try! cdfExponentialDist(x: 3, lambda: 0.25), 0.527633447258985292862, accuracy: 1e-14)
        XCTAssertEqual(try! cdfExponentialDist(x: 5, lambda: 0.25), 0.713495203139809899675, accuracy: 1e-14)
        XCTAssertEqual(try! cdfExponentialDist(x: 22, lambda: 0.25), 0.995913228561535933007, accuracy: 1e-14)
        XCTAssertEqual(try! cdfExponentialDist(x: 50, lambda: 0.25), 0.999996273346827921329, accuracy: 1e-14)
        /*
         N[PDF[ed, -2], 21]
         N[PDF[ed, 0], 21]
         N[PDF[ed, 1/2], 21]
         N[PDF[ed, 3], 21]
         N[PDF[ed, 5], 21]
         N[PDF[ed, 22], 21]
         N[PDF[ed, 50], 21]
         Out[249]= 0
         Out[250]= 0.250000000000000000000
         Out[251]= 0.220624225646148850716
         Out[252]= 0.118091638185253676785
         Out[253]= 0.0716261992150475250812
         Out[254]= 0.00102169285961601674837
         Out[255]= 9.31663293019667748231*10^-7
        */
        XCTAssertThrowsError(try pdfExponentialDist(x: 1, lambda: 0))
        XCTAssertThrowsError(try pdfExponentialDist(x: 1, lambda: -1))
        XCTAssertEqual(try! pdfExponentialDist(x: -2, lambda: 0.25), 0)
        XCTAssertEqual(try! pdfExponentialDist(x: 0, lambda: 0.25), 0.25)
        XCTAssertEqual(try! pdfExponentialDist(x: 0.5, lambda: 0.25), 0.220624225646148850716, accuracy: 1e-14)
        XCTAssertEqual(try! pdfExponentialDist(x: 3, lambda: 0.25), 0.118091638185253676785, accuracy: 1e-14)
        XCTAssertEqual(try! pdfExponentialDist(x: 5, lambda: 0.25), 0.0716261992150475250812, accuracy: 1e-14)
        XCTAssertEqual(try! pdfExponentialDist(x: 22, lambda: 0.25), 0.00102169285961601674837, accuracy: 1e-14)
        XCTAssertEqual(try! pdfExponentialDist(x: 50, lambda: 0.25), 9.31663293019667748231e-7, accuracy: 1e-14)
        /*
         N[InverseCDF[ed, 0], 21]
         N[InverseCDF[ed, 25/100], 21]
         N[InverseCDF[ed, 5/10], 21]
         N[InverseCDF[ed, 75/100], 21]
         N[InverseCDF[ed, 99/100], 21]
         N[InverseCDF[ed, 1], 21]
         */
        XCTAssertThrowsError(try quantileExponentialDist(p: 1, lambda: 0))
        XCTAssertThrowsError(try quantileExponentialDist(p: 1, lambda: -1))
        XCTAssertEqual(try! quantileExponentialDist(p: 0, lambda: 0.25), 0)
        XCTAssertEqual(try! quantileExponentialDist(p: 0.25, lambda: 0.25), 1.15072828980712370976, accuracy: 1e-14)
        XCTAssertEqual(try! quantileExponentialDist(p: 0.5, lambda: 0.25), 2.77258872223978123767, accuracy: 1e-14)
        XCTAssertEqual(try! quantileExponentialDist(p: 0.75, lambda: 0.25), 5.54517744447956247534, accuracy: 1e-14)
        XCTAssertEqual(try! quantileExponentialDist(p: 0.99, lambda: 0.25), 18.4206807439523654721, accuracy: 1e-14)
        XCTAssert(try! quantileExponentialDist(p: 1, lambda: 0.25).isInfinite)

        /*
         mu = 6;
         lambda = 9;
         wd = InverseGaussianDistribution[mu, lambda];
         N[CDF[wd, 0], 21]
         N[CDF[wd, 1], 21]
         N[CDF[wd, 2], 21]
         N[CDF[wd, 3], 21]
         N[CDF[wd, 10], 21]
         N[CDF[wd, 33], 21]
         N[CDF[wd, 145], 21]
         Out[311]= 0
         Out[312]= 0.0108821452821513154870
         Out[313]= 0.125627012864498276906
         Out[314]= 0.287386744404773626164
         Out[315]= 0.851063810667129652088
         Out[316]= 0.997518962516710678217
         Out[317]= 0.999999999702767058076         */
        XCTAssertThrowsError(try cdfWaldDist(x: 0, mean: 0, lambda: 2))
        XCTAssertThrowsError(try cdfWaldDist(x: 0, mean: 2, lambda: 0))
        XCTAssertEqual(try! cdfWaldDist(x: 0, mean: 6, lambda: 9), 0)
        XCTAssertEqual(try! cdfWaldDist(x: 1, mean: 6, lambda: 9), 0.0108821452821513154870, accuracy: 1e-14)
        XCTAssertEqual(try! cdfWaldDist(x: 2, mean: 6, lambda: 9), 0.125627012864498276906, accuracy: 1e-14)
        XCTAssertEqual(try! cdfWaldDist(x: 3, mean: 6, lambda: 9), 0.287386744404773626164, accuracy: 1e-14)
        XCTAssertEqual(try! cdfWaldDist(x: 10, mean: 6, lambda: 9), 0.851063810667129652088, accuracy: 1e-14)
        XCTAssertEqual(try! cdfWaldDist(x: 33, mean: 6, lambda: 9), 0.997518962516710678217, accuracy: 1e-14)
        XCTAssertEqual(try! cdfWaldDist(x: 145, mean: 6, lambda: 9), 0.999999999702767058076, accuracy: 1e-14)

        /*
         mu = 6;
         lambda = 9;
         wd = InverseGaussianDistribution[mu, lambda];
         N[CDF[wd, 0], 21]
         N[CDF[wd, 1], 21]
         N[CDF[wd, 2], 21]
         N[CDF[wd, 3], 21]
         N[CDF[wd, 10], 21]
         N[CDF[wd, 33], 21]
         N[CDF[wd, 145], 21]
         Out[311]= 0
         Out[312]= 0.0108821452821513154870
         Out[313]= 0.125627012864498276906
         Out[314]= 0.287386744404773626164
         Out[315]= 0.851063810667129652088
         Out[316]= 0.997518962516710678217
         Out[317]= 0.999999999702767058076
        */
        XCTAssertThrowsError(try pdfWaldDist(x: 0, mean: 0, lambda: 2))
        XCTAssertThrowsError(try pdfWaldDist(x: 0, mean: 2, lambda: 0))
        XCTAssertEqual(try! pdfWaldDist(x: 0, mean: 6, lambda: 9), 0)
        XCTAssertEqual(try! pdfWaldDist(x: 1, mean: 6, lambda: 9), 0.0525849014807056120865, accuracy: 1e-14)
        XCTAssertEqual(try! pdfWaldDist(x: 2, mean: 6, lambda: 9), 0.155665311532723013753, accuracy: 1e-14)
        XCTAssertEqual(try! pdfWaldDist(x: 3, mean: 6, lambda: 9), 0.158302949877769673488, accuracy: 1e-14)
        XCTAssertEqual(try! pdfWaldDist(x: 10, mean: 6, lambda: 9), 0.0309864928480366992183, accuracy: 1e-14)
        XCTAssertEqual(try! pdfWaldDist(x: 33, mean: 6, lambda: 9), 0.000399039071184676275858, accuracy: 1e-14)
        XCTAssertEqual(try! pdfWaldDist(x: 145, mean: 6, lambda: 9), 4.00272220943724302952e-11, accuracy: 1e-23)
        
        /*
         mu = 6;
         lambda = 9;
         wd = InverseGaussianDistribution[mu, lambda];
         N[InverseCDF[wd, 0], 21]
         N[InverseCDF[wd, 25/100], 21]
         N[InverseCDF[wd, 5/10], 21]
         N[InverseCDF[wd, 75/100], 21]
         N[InverseCDF[wd, 99/100], 21]
         N[InverseCDF[wd, 999/1000], 21]
         N[InverseCDF[wd, 1], 21]
         Out[332]= 0
         Out[333]= 2.76686873332207861117
         Out[334]= 4.53675199081610130561
         Out[335]= 7.57917596871024542035
         Out[336]= 24.5614684372629823155
         Out[337]= 38.7320805901883006582
         Out[338]= \[Infinity]
        */
        XCTAssertThrowsError(try quantileWaldDist(p: 0, mean: 0, lambda: 2))
        XCTAssertThrowsError(try quantileWaldDist(p: 0, mean: 2, lambda: 0))
        XCTAssertEqual(try! quantileWaldDist(p: 0, mean: 6, lambda: 9), 0)
        XCTAssertEqual(try! quantileWaldDist(p: 0.25, mean: 6, lambda: 9), 2.76686873332207861117, accuracy: 1e-14)
        XCTAssertEqual(try! quantileWaldDist(p: 0.5, mean: 6, lambda: 9), 4.53675199081610130561, accuracy: 1e-14)
        XCTAssertEqual(try! quantileWaldDist(p: 0.75, mean: 6, lambda: 9), 7.57917596871024542035, accuracy: 1e-14)
        XCTAssertEqual(try! quantileWaldDist(p: 0.99, mean: 6, lambda: 9), 24.5614684372629823155, accuracy: 1e-12)
        XCTAssertEqual(try! quantileWaldDist(p: 0.999, mean: 6, lambda: 9), 38.7320805901883006582, accuracy: 1e-12)
        XCTAssertEqual(try! quantileWaldDist(p: 1, mean: 6, lambda: 9), Double.infinity)
        /*
         mu = 6;
         lambda = 9;
         wd = InverseGaussianDistribution[mu, lambda];
         N[Mean[d], 21]
         N[Variance[d], 21]
         N[Skewness[d], 21]
         N[Kurtosis[d], 21]
         */
        para = try! paraWaldDist(mean: 6, lambda: 9)
        XCTAssertEqual(para!.mean, 6, accuracy: 1e-12)
        XCTAssertEqual(para!.variance, 24, accuracy: 1e-12)
        XCTAssertEqual(para!.skewness, 2.44948974278317809820, accuracy: 1e-12)
        XCTAssertEqual(para!.kurtosis, 13, accuracy: 1e-12)

        /*
         shape = 2;
         scale = 3;
         d = InverseGaussianDistribution[shape, scale];
         N[CDF[d, 0], 21]
         N[CDF[d, 1], 21]
         N[CDF[d, 2], 21]
         N[CDF[d, 3], 21]
         N[CDF[d, 10], 21]
         N[CDF[d, 33], 21]
         N[CDF[d, 145], 21]
        */
        XCTAssertThrowsError(try cdfGammaDist(x: 0, shape: -1, scale: 1))
        XCTAssertThrowsError(try cdfGammaDist(x: 0, shape: 1, scale: 0))
        XCTAssertEqual(try! cdfGammaDist(x: 0, shape: 2, scale: 3), 0, accuracy: 1e-12)
        XCTAssertEqual(try! cdfGammaDist(x: 1, shape: 2, scale: 3), 0.0446249192349476660992, accuracy: 1e-12)
        XCTAssertEqual(try! cdfGammaDist(x: 2, shape: 2, scale: 3), 0.144304801612346621880, accuracy: 1e-12)
        XCTAssertEqual(try! cdfGammaDist(x: 3, shape: 2, scale: 3), 0.264241117657115356809, accuracy: 1e-12)
        XCTAssertEqual(try! cdfGammaDist(x: 10, shape: 2, scale: 3), 0.845412695495239610381, accuracy: 1e-12)
        XCTAssertEqual(try! cdfGammaDist(x: 33, shape: 2, scale: 3), 0.999799579590517052088, accuracy: 1e-12)
        XCTAssertEqual(try! cdfGammaDist(x: 145, shape: 2, scale: 3), 0.999999999999999999950, accuracy: 1e-12)

        /*
         shape = 2;
         scale = 3;
         d = InverseGaussianDistribution[shape, scale];
         N[PDF[d, 0], 21]
         N[PDF[d, 1], 21]
         N[PDF[d, 2], 21]
         N[PDF[d, 3], 21]
         N[PDF[d, 10], 21]
         N[PDF[d, 33], 21]
         N[PDF[d, 145], 21]
         */
        XCTAssertThrowsError(try pdfGammaDist(x: 0, shape: -1, scale: 1))
        XCTAssertThrowsError(try pdfGammaDist(x: 0, shape: 1, scale: 0))
        XCTAssertEqual(try! pdfGammaDist(x: 0, shape: 2, scale: 3), 0, accuracy: 1e-12)
        XCTAssertEqual(try! pdfGammaDist(x: 1, shape: 2, scale: 3), 0.0796145900637543611584, accuracy: 1e-12)
        XCTAssertEqual(try! pdfGammaDist(x: 2, shape: 2, scale: 3), 0.114092693118353783749, accuracy: 1e-12)
        XCTAssertEqual(try! pdfGammaDist(x: 3, shape: 2, scale: 3), 0.122626480390480773865, accuracy: 1e-12)
        XCTAssertEqual(try! pdfGammaDist(x: 10, shape: 2, scale: 3), 0.0396377703858359973383, accuracy: 1e-12)
        XCTAssertEqual(try! pdfGammaDist(x: 33, shape: 2, scale: 3), 0.0000612395695642340841463, accuracy: 1e-12)
        XCTAssertEqual(try! pdfGammaDist(x: 145, shape: 2, scale: 3), 1.64522588620458773000e-20, accuracy: 1e-27)

        /*
         shape = 2;
         scale = 3;
         d = InverseGaussianDistribution[shape, scale];
         N[InverseCDF[d, 0], 21]
         N[InverseCDF[d, 25/100], 21]
         N[InverseCDF[d, 5/10], 21]
         N[InverseCDF[d, 75/100], 21]
         N[InverseCDF[d, 99/100], 21]
         N[InverseCDF[d, 999/1000], 21]
         N[InverseCDF[d, 1], 21]
         */
        XCTAssertThrowsError(try quantileGammaDist(p: 0, shape: -1, scale: 1))
        XCTAssertThrowsError(try quantileGammaDist(p: 0, shape: 1, scale: 0))
        XCTAssertEqual(try! quantileGammaDist(p: 0, shape: 2, scale: 3), 0, accuracy: 1e-12)
        XCTAssertEqual(try! quantileGammaDist(p: 0.25, shape: 2, scale: 3), 2.88383628934433128754, accuracy: 1e-12)
        XCTAssertEqual(try! quantileGammaDist(p: 0.5, shape: 2, scale: 3), 5.03504097004998196024, accuracy: 1e-12)
        XCTAssertEqual(try! quantileGammaDist(p: 0.75, shape: 2, scale: 3), 8.07790358666908731226, accuracy: 1e-12)
        XCTAssertEqual(try! quantileGammaDist(p: 0.99, shape: 2, scale: 3), 19.9150562039814368081, accuracy: 1e-12)
        XCTAssertEqual(try! quantileGammaDist(p: 0.999, shape: 2, scale: 3), 27.7002404293547571913, accuracy: 1e-12)
        XCTAssert(try! quantileGammaDist(p: 1, shape: 2, scale: 3).isInfinite)
        /*
         shape = 2;
         scale = 3;
         d = InverseGaussianDistribution[shape, scale];
         N[Mean[d], 21]
         N[Variance[d], 21]
         N[Skewness[d], 21]
         N[Kurtosis[d], 21]
         */
        para = try! paraGammaDist(shape: 2, scale: 3)
        XCTAssertEqual(para!.mean, 6, accuracy: 1e-12)
        XCTAssertEqual(para!.variance, 18, accuracy: 1e-12)
        XCTAssertEqual(para!.skewness, 1.41421356237309504880, accuracy: 1e-12)
        XCTAssertEqual(para!.kurtosis, 6, accuracy: 1e-12)

        // MARK: ERLANG
        /*
         shape = 8;
         scale = 19/10;
         d = ErlangDistribution[shape, scale];
         N[CDF[d, -1], 21]
         N[CDF[d, 1], 21]
         N[CDF[d, 2], 21]
         N[CDF[d, 22/10], 21]
         N[CDF[d, 45/10], 21]
         N[CDF[d, 7], 21]
         N[CDF[d, 10], 21]
         */
        XCTAssertThrowsError(try cdfErlangDist(x: 0, shape: 0, rate: 1))
        XCTAssertEqual(try! cdfErlangDist(x: -1, shape: 8, rate: 1.9), 0, accuracy: 1e-12)
        XCTAssertEqual(try! cdfErlangDist(x: 1, shape: 8, rate: 1.9), 0.000793457613267557042372, accuracy: 1e-12)
        XCTAssertEqual(try! cdfErlangDist(x: 2, shape: 8, rate: 1.9), 0.0401073776861547292702, accuracy: 1e-12)
        XCTAssertEqual(try! cdfErlangDist(x: 2.2, shape: 8, rate: 1.9), 0.0625806276334696425021, accuracy: 1e-12)
        XCTAssertEqual(try! cdfErlangDist(x: 4.5, shape: 8, rate: 1.9), 0.620845136890394243952, accuracy: 1e-12)
        XCTAssertEqual(try! cdfErlangDist(x: 7, shape: 8, rate: 1.9), 0.953851071263071931215, accuracy: 1e-12)
        XCTAssertEqual(try! cdfErlangDist(x: 10, shape: 8, rate: 1.9), 0.998486657386375206401, accuracy: 1e-12)
        
        /*
         shape = 8;
         scale = 19/10;
         d = ErlangDistribution[shape, scale];
         N[PDF[d, -1], 21]
         N[PDF[d, 1], 21]
         N[PDF[d, 2], 21]
         N[PDF[d, 22/10], 21]
         N[PDF[d, 45/10], 21]
         N[PDF[d, 7], 21]
         N[PDF[d, 10], 21]
         */
        XCTAssertThrowsError(try pdfErlangDist(x: 0, shape: 0, rate: 1))
        XCTAssertEqual(try! pdfErlangDist(x: -1, shape: 8, rate: 1.9), 0, accuracy: 1e-12)
        XCTAssertEqual(try! pdfErlangDist(x: 1, shape: 8, rate: 1.9), 0.00504009538397410085449, accuracy: 1e-12)
        XCTAssertEqual(try! pdfErlangDist(x: 2, shape: 8, rate: 1.9), 0.0964915337384170109056, accuracy: 1e-12)
        XCTAssertEqual(try! pdfErlangDist(x: 2.2, shape: 8, rate: 1.9), 0.128589676154648556029, accuracy: 1e-12)
        XCTAssertEqual(try! pdfErlangDist(x: 4.5, shape: 8, rate: 1.9), 0.243707024534075753055, accuracy: 1e-12)
        XCTAssertEqual(try! pdfErlangDist(x: 7, shape: 8, rate: 1.9), 0.0464694938322868155464, accuracy: 1e-12)
        XCTAssertEqual(try! pdfErlangDist(x: 10, shape: 8, rate: 1.9), 0.00188800489092865877089, accuracy: 1e-12)
        
        /*
         shape = 8;
         scale = 19/10;
         d = ErlangDistribution[shape, scale];
         N[InverseCDF[d, 0], 21]
         N[InverseCDF[d, 25/100], 21]
         N[InverseCDF[d, 5/10], 21]
         N[InverseCDF[d, 75/100], 21]
         N[InverseCDF[d, 99/100], 21]
         N[InverseCDF[d, 999/1000], 21]
         N[InverseCDF[d, 1], 21]
         */
        XCTAssertThrowsError(try quantileErlangDist(p: 0, shape: 0, rate: 1))
        XCTAssertEqual(try! quantileErlangDist(p: 0, shape: 8, rate: 1.9), 0, accuracy: 1e-12)
        XCTAssertEqual(try! quantileErlangDist(p: 0.25, shape: 8, rate: 1.9), 3.13479465721473572797, accuracy: 1e-12)
        XCTAssertEqual(try! quantileErlangDist(p: 0.5, shape: 8, rate: 1.9), 4.03644707500042310756, accuracy: 1e-12)
        XCTAssertEqual(try! quantileErlangDist(p: 0.75, shape: 8, rate: 1.9), 5.09706847910118785655, accuracy: 1e-12)
        XCTAssertEqual(try! quantileErlangDist(p: 0.99, shape: 8, rate: 1.9), 8.42103339705662662358, accuracy: 1e-12)
        XCTAssertEqual(try! quantileErlangDist(p: 0.999, shape: 8, rate: 1.9), 10.3295670502022305302, accuracy: 1e-12)
        XCTAssert(try! quantileErlangDist(p: 1, shape: 8, rate: 1.9).isInfinite)
        /*
         shape = 8;
         scale = 19/10;
         d = ErlangDistribution[shape, scale];
         N[Mean[d], 21]
         N[Variance[d], 21]
         N[Skewness[d], 21]
         N[Kurtosis[d], 21]
         */
        para = try! paraErlangDist(shape: 8, rate: 1.9)
        XCTAssertEqual(para!.mean, 4.21052631578947368421, accuracy: 1e-12)
        XCTAssertEqual(para!.variance, 2.21606648199445983380, accuracy: 1e-12)
        XCTAssertEqual(para!.skewness, 0.707106781186547524401, accuracy: 1e-12)
        XCTAssertEqual(para!.kurtosis, 3.75000000000000000000, accuracy: 1e-12)

        // MARK: Weibull
        /*
         shape = 3;
         scale = 4;
         loc = 2
         d = WeibullDistribution[shape, scale, loc];
         N[CDF[d, -1], 21]
         N[CDF[d, 1], 21]
         N[CDF[d, 2], 21]
         N[CDF[d, 22/10], 21]
         N[CDF[d, 45/10], 21]
         N[CDF[d, 7], 21]
         N[CDF[d, 10], 21]
         */
        XCTAssertThrowsError(try cdfWeibullDist(x: 0, location: 2, scale: 0, shape: 3))
        XCTAssertThrowsError(try cdfWeibullDist(x: 0, location: 2, scale: 4, shape: 0))
        XCTAssertThrowsError(try cdfWeibullDist(x: 0, location: 2, scale: 4, shape: -1))
        XCTAssertThrowsError(try cdfWeibullDist(x: 0, location: 2, scale: -24, shape: -1))
        XCTAssertEqual(try! cdfWeibullDist(x: -1,  location: 2, scale: 4, shape: 3), 0, accuracy: 1e-12)
        XCTAssertEqual(try! cdfWeibullDist(x: 2.9, location: 2, scale: 4, shape: 3), 0.0113259974465415820934, accuracy: 1e-12)
        XCTAssertEqual(try! cdfWeibullDist(x: 3,   location: 2, scale: 4, shape: 3), 0.0155035629945915940130, accuracy: 1e-12)
        XCTAssertEqual(try! cdfWeibullDist(x: 3.1, location: 2, scale: 4, shape: 3), 0.0205821113758218963048, accuracy: 1e-12)
        XCTAssertEqual(try! cdfWeibullDist(x: 4.5, location: 2, scale: 4, shape: 3), 0.216622535939181796504, accuracy: 1e-12)
        XCTAssertEqual(try! cdfWeibullDist(x: 7,   location: 2, scale: 4, shape: 3), 0.858169840912657470462, accuracy: 1e-12)
        XCTAssertEqual(try! cdfWeibullDist(x: 22,  location: 2, scale: 4, shape: 3), 1.00000000000000000000, accuracy: 1e-12)

        /*
         shape = 3;
         scale = 4;
         loc = 2
         d = WeibullDistribution[shape, scale, loc];
         N[PDF[d, -1], 21]
         N[PDF[d, 1], 21]
         N[PDF[d, 2], 21]
         N[PDF[d, 22/10], 21]
         N[PDF[d, 45/10], 21]
         N[PDF[d, 7], 21]
         N[PDF[d, 10], 21]
         */
        XCTAssertThrowsError(try pdfWeibullDist(x: 0, location: 2, scale: 0, shape: 3))
        XCTAssertThrowsError(try pdfWeibullDist(x: 0, location: 2, scale: 4, shape: 0))
        XCTAssertThrowsError(try pdfWeibullDist(x: 0, location: 2, scale: 4, shape: -2))
        XCTAssertThrowsError(try pdfWeibullDist(x: 0, location: 2, scale: -4, shape: 3))
        XCTAssertEqual(try! pdfWeibullDist(x: -1,  location: 2, scale: 4, shape: 3), 0, accuracy: 1e-12)
        XCTAssertEqual(try! pdfWeibullDist(x: 2.9, location: 2, scale: 4, shape: 3), 0.0375387160344516243049, accuracy: 1e-12)
        XCTAssertEqual(try! pdfWeibullDist(x: 3,   location: 2, scale: 4, shape: 3), 0.0461482704846285190306, accuracy: 1e-12)
        XCTAssertEqual(try! pdfWeibullDist(x: 3.1, location: 2, scale: 4, shape: 3), 0.0555513583704026018190, accuracy: 1e-12)
        XCTAssertEqual(try! pdfWeibullDist(x: 4.5, location: 2, scale: 4, shape: 3), 0.229505116424067833055, accuracy: 1e-12)
        XCTAssertEqual(try! pdfWeibullDist(x: 7,   location: 2, scale: 4, shape: 3), 0.166207217680479526802, accuracy: 1e-12)
        XCTAssertEqual(try! pdfWeibullDist(x: 22,  location: 2, scale: 4, shape: 3), 9.68703868657098933797e-54, accuracy: 1e-60)

        /*
         shape = 3;
         scale = 4;
         loc = 2
         d = WeibullDistribution[shape, scale, loc];
         N[InverseCDF[d, 0], 21]
         N[InverseCDF[d, 25/100], 21]
         N[InverseCDF[d, 5/10], 21]
         N[InverseCDF[d, 75/100], 21]
         N[InverseCDF[d, 99/100], 21]
         N[InverseCDF[d, 999/1000], 21]
         N[InverseCDF[d, 1], 21]
         */
        XCTAssertThrowsError(try quantileWeibullDist(p: 0, location: 2, scale: 0, shape: 3))
        XCTAssertThrowsError(try quantileWeibullDist(p: 0, location: 2, scale: 4, shape: 0))
        XCTAssertThrowsError(try quantileWeibullDist(p: 0, location: 2, scale: 0, shape: 0))
        XCTAssertThrowsError(try quantileWeibullDist(p: 0, location: 2, scale: -4, shape: 3))
        XCTAssertThrowsError(try quantileWeibullDist(p: 0, location: 2, scale: 4, shape: -3))
        XCTAssertThrowsError(try quantileWeibullDist(p: 0, location: 2, scale: -4, shape: -3))
        XCTAssertEqual(try! quantileWeibullDist(p: 0, location: 2, scale: 4, shape: 3), 2, accuracy: 1e-12)
        XCTAssertEqual(try! quantileWeibullDist(p: 0.25, location: 2, scale: 4, shape: 3), 4.64056942859838095934, accuracy: 1e-12)
        XCTAssertEqual(try! quantileWeibullDist(p: 0.5, location: 2, scale: 4, shape: 3), 5.53998817800207087498, accuracy: 1e-12)
        XCTAssertEqual(try! quantileWeibullDist(p: 0.75, location: 2, scale: 4, shape: 3), 6.46010562184380828507, accuracy: 1e-12)
        XCTAssertEqual(try! quantileWeibullDist(p: 0.99, location: 2, scale: 4, shape: 3), 8.65490539680019769957, accuracy: 1e-12)
        XCTAssertEqual(try! quantileWeibullDist(p: 0.999, location: 2, scale: 4, shape: 3), 9.61796499056221876841, accuracy: 1e-12)
        XCTAssert(try! quantileWeibullDist(p: 1, location: 2, scale: 4, shape: 3).isInfinite)
        /*
         shape = 3;
         scale = 4;
         loc = 2
         d = WeibullDistribution[shape, scale, loc];
         N[Mean[d], 21]
         N[Variance[d], 21]
         N[Skewness[d], 21]
         N[Kurtosis[d], 21]
         */
        para = try! paraWeibullDist(location: 2, scale: 4, shape: 3)
        XCTAssertEqual(para!.mean, 5.57191804627699684487, accuracy: 1e-12)
        XCTAssertEqual(para!.variance, 1.68532615789565960689, accuracy: 1e-12)
        XCTAssertEqual(para!.skewness, 0.168102842229401082430, accuracy: 1e-12)
        XCTAssertEqual(para!.kurtosis, 2.72946363309612067010, accuracy: 1e-12)

        // MARK: Uniform
        /*
         min = 1;
         max = 10;
         d = UniformDistribution[{min, max}];
         N[CDF[d, 0], 21]
         N[CDF[d, 29/10], 21]
         N[CDF[d, 3], 21]
         N[CDF[d, 31/10], 21]
         N[CDF[d, 45/10], 21]
         N[CDF[d, 7], 21]
         N[CDF[d, 22], 21]
         */
        XCTAssertThrowsError(try cdfUniformDist(x: 0, lowerBound: 10, upperBound: 1))
        XCTAssertThrowsError(try cdfUniformDist(x: 0, lowerBound: 10, upperBound: 10))
        XCTAssertEqual(try! cdfUniformDist(x: 0,   lowerBound: 1, upperBound: 10), 0, accuracy: 1e-12)
        XCTAssertEqual(try! cdfUniformDist(x: 2.9, lowerBound: 1, upperBound: 10), 0.211111111111111111111, accuracy: 1e-12)
        XCTAssertEqual(try! cdfUniformDist(x: 3,   lowerBound: 1, upperBound: 10), 0.222222222222222222222, accuracy: 1e-12)
        XCTAssertEqual(try! cdfUniformDist(x: 3.1, lowerBound: 1, upperBound: 10), 0.233333333333333333333, accuracy: 1e-12)
        XCTAssertEqual(try! cdfUniformDist(x: 4.5, lowerBound: 1, upperBound: 10), 0.388888888888888888889, accuracy: 1e-12)
        XCTAssertEqual(try! cdfUniformDist(x: 7,   lowerBound: 1, upperBound: 10), 0.666666666666666666667, accuracy: 1e-12)
        XCTAssertEqual(try! cdfUniformDist(x: 22,  lowerBound: 1, upperBound: 10), 1.0, accuracy: 1e-12)

        /*
         min = 1;
         max = 10;
         d = UniformDistribution[{min, max}];
         N[PDF[d, 0], 21]
         N[PDF[d, 29/10], 21]
         N[PDF[d, 3], 21]
         N[PDF[d, 31/10], 21]
         N[PDF[d, 45/10], 21]
         N[PDF[d, 7], 21]
         N[PDF[d, 22], 21]
         */
        XCTAssertThrowsError(try pdfUniformDist(x: 0, lowerBound: 10, upperBound: 1))
        XCTAssertThrowsError(try pdfUniformDist(x: 0, lowerBound: 10, upperBound: 10))
        XCTAssertThrowsError(try pdfUniformDist(x: 0, lowerBound: 10, upperBound: 10))
        XCTAssertEqual(try! pdfUniformDist(x: 0,     lowerBound: 1, upperBound: 10), 0, accuracy: 1e-12)
        XCTAssertEqual(try! pdfUniformDist(x: 2.9,   lowerBound: 1, upperBound: 10), 0.111111111111111111111, accuracy: 1e-12)
        XCTAssertEqual(try! pdfUniformDist(x: 3,     lowerBound: 1, upperBound: 10), 0.111111111111111111111, accuracy: 1e-12)
        XCTAssertEqual(try! pdfUniformDist(x: 3.1,   lowerBound: 1, upperBound: 10), 0.111111111111111111111, accuracy: 1e-12)
        XCTAssertEqual(try! pdfUniformDist(x: 4.5,   lowerBound: 1, upperBound: 10), 0.111111111111111111111, accuracy: 1e-12)
        XCTAssertEqual(try! pdfUniformDist(x: 7,     lowerBound: 1, upperBound: 10), 0.111111111111111111111, accuracy: 1e-12)
        XCTAssertEqual(try! pdfUniformDist(x: 22,    lowerBound: 1, upperBound: 10), 0, accuracy: 1e-12)

        /*
         min = 1;
         max = 10;
         d = UniformDistribution[{min, max}];
         N[InverseCDF[d, 0], 21]
         N[InverseCDF[d, 25/100], 21]
         N[InverseCDF[d, 5/10], 21]
         N[InverseCDF[d, 75/100], 21]
         N[InverseCDF[d, 99/100], 21]
         N[InverseCDF[d, 999/1000], 21]
         N[InverseCDF[d, 1], 21]
         */
        XCTAssertThrowsError(try quantileUniformDist(p: 0, lowerBound: 10, upperBound: 1))
        XCTAssertThrowsError(try quantileUniformDist(p: 0, lowerBound: 10, upperBound: 10))
        XCTAssertThrowsError(try quantileUniformDist(p: 0, lowerBound: 10, upperBound: 10))
        XCTAssertThrowsError(try quantileUniformDist(p: -1, lowerBound: 1, upperBound: 10))
        XCTAssertThrowsError(try quantileUniformDist(p: 2, lowerBound: 1, upperBound: 10))
        XCTAssertEqual(try! quantileUniformDist(p: 0, lowerBound: 1, upperBound: 10), 1, accuracy: 1e-12)
        XCTAssertEqual(try! quantileUniformDist(p: 0.25, lowerBound: 1, upperBound: 10), 3.25, accuracy: 1e-12)
        XCTAssertEqual(try! quantileUniformDist(p: 0.5, lowerBound: 1, upperBound: 10), 5.5, accuracy: 1e-12)
        XCTAssertEqual(try! quantileUniformDist(p: 0.75, lowerBound: 1, upperBound: 10), 7.75, accuracy: 1e-12)
        XCTAssertEqual(try! quantileUniformDist(p: 0.99, lowerBound: 1, upperBound: 10), 9.91, accuracy: 1e-12)
        XCTAssertEqual(try! quantileUniformDist(p: 0.999, lowerBound: 1, upperBound: 10), 9.991, accuracy: 1e-12)
        XCTAssertEqual(try! quantileUniformDist(p: 1, lowerBound: 1, upperBound: 10), 10.0, accuracy: 1e-12)
        /*
         min = 1;
         max = 10;
         d = UniformDistribution[{min, max}];
         N[Mean[d], 21]
         N[Variance[d], 21]
         N[Skewness[d], 21]
         N[Kurtosis[d], 21]
         */
        para = try! paraUniformDist(lowerBound: 1, upperBound: 10)
        XCTAssertEqual(para!.mean, 5.5, accuracy: 1e-12)
        XCTAssertEqual(para!.variance, 6.75, accuracy: 1e-12)
        XCTAssertEqual(para!.skewness, 0, accuracy: 1e-12)
        XCTAssertEqual(para!.kurtosis, 1.8, accuracy: 1e-12)

        // MARK: Triangular - 3 Param
        
        /*
         min = 1;
         max = 10;
         mode = 3;
         d = TriangularDistribution[{min, max}, mode];
         N[CDF[d, 0], 21]
         N[CDF[d, 29/10], 21]
         N[CDF[d, 3], 21]
         N[CDF[d, 31/10], 21]
         N[CDF[d, 45/10], 21]
         N[CDF[d, 7], 21]
         N[CDF[d, 22], 21]
         */
        XCTAssertThrowsError(try cdfTriangularDist(x: 0, lowerBound: 10, upperBound: 0, mode: 3))
        XCTAssertThrowsError(try cdfTriangularDist(x: 0, lowerBound: 0, upperBound: 0, mode: 3))
        XCTAssertThrowsError(try cdfTriangularDist(x: 0, lowerBound: 0, upperBound: 10, mode: 333))
        XCTAssertEqual(try! cdfTriangularDist(x: 0,   lowerBound: 1, upperBound: 10, mode: 3), 0, accuracy: 1e-12)
        XCTAssertEqual(try! cdfTriangularDist(x: 2.9, lowerBound: 1, upperBound: 10, mode: 3), 0.200555555555555555556, accuracy: 1e-12)
        XCTAssertEqual(try! cdfTriangularDist(x: 3,   lowerBound: 1, upperBound: 10, mode: 3), 0.222222222222222222222, accuracy: 1e-12)
        XCTAssertEqual(try! cdfTriangularDist(x: 3.1, lowerBound: 1, upperBound: 10, mode: 3), 0.244285714285714285714, accuracy: 1e-12)
        XCTAssertEqual(try! cdfTriangularDist(x: 4.5, lowerBound: 1, upperBound: 10, mode: 3), 0.519841269841269841270, accuracy: 1e-12)
        XCTAssertEqual(try! cdfTriangularDist(x: 7,   lowerBound: 1, upperBound: 10, mode: 3), 0.857142857142857142857, accuracy: 1e-12)
        XCTAssertEqual(try! cdfTriangularDist(x: 22,  lowerBound: 1, upperBound: 10, mode: 3), 1.0, accuracy: 1e-12)
        
        /*
         min = 1;
         max = 10;
         mode = 3;
         d = TriangularDistribution[{min, max}, mode];
         N[PDF[d, 0], 21]
         N[PDF[d, 29/10], 21]
         N[PDF[d, 3], 21]
         N[PDF[d, 31/10], 21]
         N[PDF[d, 45/10], 21]
         N[PDF[d, 7], 21]
         N[PDF[d, 22], 21]
         */
        XCTAssertThrowsError(try pdfTriangularDist(x: 0, lowerBound: 10, upperBound: 0, mode: 3))
        XCTAssertThrowsError(try pdfTriangularDist(x: 0, lowerBound: 0, upperBound: 0, mode: 3))
        XCTAssertThrowsError(try pdfTriangularDist(x: 0, lowerBound: 0, upperBound: 10, mode: 333))
        XCTAssertEqual(try! pdfTriangularDist(x: 0,     lowerBound: 1, upperBound: 10, mode: 3), 0, accuracy: 1e-12)
        XCTAssertEqual(try! pdfTriangularDist(x: 2.9,   lowerBound: 1, upperBound: 10, mode: 3), 0.211111111111111111111, accuracy: 1e-12)
        XCTAssertEqual(try! pdfTriangularDist(x: 3,     lowerBound: 1, upperBound: 10, mode: 3), 0.222222222222222222222, accuracy: 1e-12)
        XCTAssertEqual(try! pdfTriangularDist(x: 3.1,   lowerBound: 1, upperBound: 10, mode: 3), 0.219047619047619047619, accuracy: 1e-12)
        XCTAssertEqual(try! pdfTriangularDist(x: 4.5,   lowerBound: 1, upperBound: 10, mode: 3), 0.174603174603174603175, accuracy: 1e-12)
        XCTAssertEqual(try! pdfTriangularDist(x: 7,     lowerBound: 1, upperBound: 10, mode: 3), 0.0952380952380952380952, accuracy: 1e-12)
        XCTAssertEqual(try! pdfTriangularDist(x: 22,    lowerBound: 1, upperBound: 10, mode: 3), 0, accuracy: 1e-12)
        
        /*
         min = 1;
         max = 10;
         mode = 3;
         d = TriangularDistribution[{min, max}, mode];
         N[InverseCDF[d, 0], 21]
         N[InverseCDF[d, 25/100], 21]
         N[InverseCDF[d, 5/10], 21]
         N[InverseCDF[d, 75/100], 21]
         N[InverseCDF[d, 99/100], 21]
         N[InverseCDF[d, 999/1000], 21]
         N[InverseCDF[d, 1], 21]
         */
        XCTAssertThrowsError(try quantileTriangularDist(p: 0, lowerBound: 10, upperBound: 0, mode: 3))
        XCTAssertThrowsError(try quantileTriangularDist(p: 0, lowerBound: 0, upperBound: 0, mode: 3))
        XCTAssertThrowsError(try quantileTriangularDist(p: 0, lowerBound: 0, upperBound: 10, mode: 333))
        XCTAssertEqual(try! quantileTriangularDist(p: 0,    lowerBound: 1, upperBound: 10, mode: 3), 1, accuracy: 1e-12)
        XCTAssertEqual(try! quantileTriangularDist(p: 0.25, lowerBound: 1, upperBound: 10, mode: 3), 3.12613645756623999012, accuracy: 1e-12)
        XCTAssertEqual(try! quantileTriangularDist(p: 0.5,  lowerBound: 1, upperBound: 10, mode: 3), 4.38751391983908792162, accuracy: 1e-12)
        XCTAssertEqual(try! quantileTriangularDist(p: 0.75, lowerBound: 1, upperBound: 10, mode: 3), 6.03137303340311411425, accuracy: 1e-12)
        XCTAssertEqual(try! quantileTriangularDist(p: 0.99, lowerBound: 1, upperBound: 10, mode: 3), 9.20627460668062282285, accuracy: 1e-12)
        XCTAssertEqual(try! quantileTriangularDist(p: 0.999,lowerBound: 1, upperBound: 10, mode: 3), 9.74900199203977733561, accuracy: 1e-12)
        XCTAssertEqual(try! quantileTriangularDist(p: 1,    lowerBound: 1, upperBound: 10, mode: 3), 10.0, accuracy: 1e-12)
        /*
         min = 1;
         max = 10;
         mode = 3;
         d = TriangularDistribution[{min, max}, mode];
         N[Mean[d], 21]
         N[Variance[d], 21]
         N[Skewness[d], 21]
         N[Kurtosis[d], 21]
         */
        para = try! paraTriangularDist(lowerBound: 1, upperBound: 10, mode: 3)
        XCTAssertEqual(para!.mean, 4.66666666666666666667, accuracy: 1e-12)
        XCTAssertEqual(para!.variance, 3.72222222222222222222, accuracy: 1e-12)
        XCTAssertEqual(para!.skewness, 0.453853262394983221953, accuracy: 1e-12)
        XCTAssertEqual(para!.kurtosis, 2.40000000000000000000, accuracy: 1e-12)

        // MARK: Triangular - 2 Param
        
        /*
         min = 1;
         max = 10;
         d = TriangularDistribution[{min, max}, mode];
         N[CDF[d, 0], 21]
         N[CDF[d, 29/10], 21]
         N[CDF[d, 3], 21]
         N[CDF[d, 31/10], 21]
         N[CDF[d, 45/10], 21]
         N[CDF[d, 7], 21]
         N[CDF[d, 22], 21]
         */
        XCTAssertThrowsError(try cdfTriangularDist(x: 0, lowerBound: 10, upperBound: 0))
        XCTAssertThrowsError(try cdfTriangularDist(x: 0, lowerBound: 0, upperBound: 0))
        XCTAssertEqual(try! cdfTriangularDist(x: 0,   lowerBound: 1, upperBound: 10), 0, accuracy: 1e-12)
        XCTAssertEqual(try! cdfTriangularDist(x: 2.9, lowerBound: 1, upperBound: 10), 0.0891358024691358024691, accuracy: 1e-12)
        XCTAssertEqual(try! cdfTriangularDist(x: 3,   lowerBound: 1, upperBound: 10), 0.0987654320987654320988, accuracy: 1e-12)
        XCTAssertEqual(try! cdfTriangularDist(x: 3.1, lowerBound: 1, upperBound: 10), 0.108888888888888888889, accuracy: 1e-12)
        XCTAssertEqual(try! cdfTriangularDist(x: 4.5, lowerBound: 1, upperBound: 10), 0.302469135802469135802, accuracy: 1e-12)
        XCTAssertEqual(try! cdfTriangularDist(x: 7,   lowerBound: 1, upperBound: 10), 0.777777777777777777778, accuracy: 1e-12)
        XCTAssertEqual(try! cdfTriangularDist(x: 22,  lowerBound: 1, upperBound: 10), 1.0, accuracy: 1e-12)
        
        /*
         min = 1;
         max = 10;
         mode = 3;
         d = TriangularDistribution[{min, max}, mode];
         N[PDF[d, 0], 21]
         N[PDF[d, 29/10], 21]
         N[PDF[d, 3], 21]
         N[PDF[d, 31/10], 21]
         N[PDF[d, 45/10], 21]
         N[PDF[d, 7], 21]
         N[PDF[d, 22], 21]
         */
        XCTAssertThrowsError(try pdfTriangularDist(x: 0, lowerBound: 10, upperBound: 0))
        XCTAssertThrowsError(try pdfTriangularDist(x: 0, lowerBound: 0, upperBound: 0))
        XCTAssertEqual(try! pdfTriangularDist(x: 0,     lowerBound: 1, upperBound: 10), 0, accuracy: 1e-12)
        XCTAssertEqual(try! pdfTriangularDist(x: 2.9,   lowerBound: 1, upperBound: 10), 0.0938271604938271604938, accuracy: 1e-12)
        XCTAssertEqual(try! pdfTriangularDist(x: 3,     lowerBound: 1, upperBound: 10), 0.0987654320987654320988, accuracy: 1e-12)
        XCTAssertEqual(try! pdfTriangularDist(x: 3.1,   lowerBound: 1, upperBound: 10), 0.103703703703703703704, accuracy: 1e-12)
        XCTAssertEqual(try! pdfTriangularDist(x: 4.5,   lowerBound: 1, upperBound: 10), 0.172839506172839506173, accuracy: 1e-12)
        XCTAssertEqual(try! pdfTriangularDist(x: 7,     lowerBound: 1, upperBound: 10), 0.148148148148148148148, accuracy: 1e-12)
        XCTAssertEqual(try! pdfTriangularDist(x: 22,    lowerBound: 1, upperBound: 10), 0, accuracy: 1e-12)
        
        /*
         min = 1;
         max = 10;
         mode = 3;
         d = TriangularDistribution[{min, max}, mode];
         N[InverseCDF[d, 0], 21]
         N[InverseCDF[d, 25/100], 21]
         N[InverseCDF[d, 5/10], 21]
         N[InverseCDF[d, 75/100], 21]
         N[InverseCDF[d, 99/100], 21]
         N[InverseCDF[d, 999/1000], 21]
         N[InverseCDF[d, 1], 21]
         */
        XCTAssertThrowsError(try quantileTriangularDist(p: 0, lowerBound: 10, upperBound: 0))
        XCTAssertThrowsError(try quantileTriangularDist(p: 0, lowerBound: 0, upperBound: 0))
        XCTAssertEqual(try! quantileTriangularDist(p: 0,    lowerBound: 1, upperBound: 10), 1, accuracy: 1e-12)
        XCTAssertEqual(try! quantileTriangularDist(p: 0.25, lowerBound: 1, upperBound: 10), 4.18198051533946385980, accuracy: 1e-12)
        XCTAssertEqual(try! quantileTriangularDist(p: 0.5,  lowerBound: 1, upperBound: 10), 5.50000000000000000000, accuracy: 1e-12)
        XCTAssertEqual(try! quantileTriangularDist(p: 0.75, lowerBound: 1, upperBound: 10), 6.81801948466053614020, accuracy: 1e-12)
        XCTAssertEqual(try! quantileTriangularDist(p: 0.99, lowerBound: 1, upperBound: 10), 9.36360389693210722804, accuracy: 1e-12)
        XCTAssertEqual(try! quantileTriangularDist(p: 0.999,lowerBound: 1, upperBound: 10), 9.79875388202501892732, accuracy: 1e-12)
        XCTAssertEqual(try! quantileTriangularDist(p: 1,    lowerBound: 1, upperBound: 10), 10.0, accuracy: 1e-12)
        /*
         min = 1;
         max = 10;
         mode = 3;
         d = TriangularDistribution[{min, max}, mode];
         N[Mean[d], 21]
         N[Variance[d], 21]
         N[Skewness[d], 21]
         N[Kurtosis[d], 21]
         */
        para = try! paraTriangularDist(lowerBound: 1, upperBound: 10)
        XCTAssertEqual(para!.mean, 5.5, accuracy: 1e-12)
        XCTAssertEqual(para!.variance, 3.375, accuracy: 1e-12)
        XCTAssertEqual(para!.skewness, 0, accuracy: 1e-12)
        XCTAssertEqual(para!.kurtosis, 2.4, accuracy: 1e-12)
        
        /*
         lambda = 1/2;
         d = PoissonDistribution[lambda];
         N[PDF[d, 0], 21]
         N[PDF[d, 1], 21]
         N[PDF[d, 2], 21]
         N[PDF[d, 3], 21]
         N[PDF[d, 4], 21]
         N[PDF[d, 5], 21]
         N[PDF[d, 6], 21]
         N[PDF[d, 7], 21]
        */
        XCTAssertThrowsError(try pdfPoissonDist(k: -1, rate: 1))
        XCTAssertThrowsError(try pdfPoissonDist(k: 1, rate: 0))
        XCTAssertEqual(try! pdfPoissonDist(k: 0, rate: 0.5), 0.606530659712633423604, accuracy: 1e-12)
        XCTAssertEqual(try! pdfPoissonDist(k: 1, rate: 0.5), 0.303265329856316711802, accuracy: 1e-12)
        XCTAssertEqual(try! pdfPoissonDist(k: 2, rate: 0.5), 0.0758163324640791779505, accuracy: 1e-12)
        XCTAssertEqual(try! pdfPoissonDist(k: 3, rate: 0.5), 0.0126360554106798629917, accuracy: 1e-12)
        XCTAssertEqual(try! pdfPoissonDist(k: 4, rate: 0.5), 0.00157950692633498287397, accuracy: 1e-12)
        XCTAssertEqual(try! pdfPoissonDist(k: 5, rate: 0.5), 0.000157950692633498287397, accuracy: 1e-12)
        XCTAssertEqual(try! pdfPoissonDist(k: 6, rate: 0.5), 0.0000131625577194581906164, accuracy: 1e-12)
        XCTAssertEqual(try! pdfPoissonDist(k: 7, rate: 0.5), 9.40182694247013615457e-7, accuracy: 1e-15)

        /*
         lambda = 1/2;
         d = PoissonDistribution[lambda];
        N[CDF[d, 0], 21]
        N[CDF[d, 1], 21]
        N[CDF[d, 2], 21]
        N[CDF[d, 3], 21]
        N[CDF[d, 4], 21]
        N[CDF[d, 5], 21]
        N[CDF[d, 6], 21]
        N[CDF[d, 7], 21]
        */
        XCTAssertThrowsError(try cdfPoissonDist(k: -1, rate: 1, tail: .lower))
        XCTAssertThrowsError(try cdfPoissonDist(k: 1, rate: 0, tail: .lower))
        XCTAssertEqual(try! cdfPoissonDist(k: 0, rate: 0.5, tail: .lower), 0.606530659712633423604, accuracy: 1e-12)
        XCTAssertEqual(try! cdfPoissonDist(k: 1, rate: 0.5, tail: .lower), 0.909795989568950135406, accuracy: 1e-12)
        XCTAssertEqual(try! cdfPoissonDist(k: 2, rate: 0.5, tail: .lower), 0.985612322033029313356, accuracy: 1e-12)
        XCTAssertEqual(try! cdfPoissonDist(k: 3, rate: 0.5, tail: .lower), 0.998248377443709176348, accuracy: 1e-12)
        XCTAssertEqual(try! cdfPoissonDist(k: 4, rate: 0.5, tail: .lower), 0.999827884370044159222, accuracy: 1e-12)
        XCTAssertEqual(try! cdfPoissonDist(k: 5, rate: 0.5, tail: .lower), 0.999985835062677657509, accuracy: 1e-12)
        XCTAssertEqual(try! cdfPoissonDist(k: 6, rate: 0.5, tail: .lower), 0.999998997620397115700, accuracy: 1e-12)
        XCTAssertEqual(try! cdfPoissonDist(k: 7, rate: 0.5, tail: .lower), 0.999999937803091362714, accuracy: 1e-12)

        /*
         a = -3;
         b = 4;
         d = VonMisesDistribution[a, b];
         N[CDF[d, a - Pi - 1], 21]
         N[CDF[d, -Pi - 1], 21]
         N[CDF[d, -25/10], 21]
         N[CDF[d, -20/100], 21]
         N[CDF[d, -44/10], 21]
         N[CDF[d, 0 - Pi/2], 21]
         N[CDF[d, 0], 21]
         N[CDF[d, a + Pi + 1], 21]
        */
        XCTAssertThrowsError(try cdfVonMisesDist(x: 2, mean: -3, concentration: 0))
        XCTAssertThrowsError(try cdfVonMisesDist(x: 2, mean: -3, concentration: -1))
        XCTAssertEqual(try! cdfVonMisesDist(x: -3 - Double.pi - 1.0, mean: -3, concentration: 4, useExpIntegration: true),0 ,accuracy: 1E-5)
        XCTAssertEqual(try! cdfVonMisesDist(x: -Double.pi - 1.0, mean: -3, concentration: 4, useExpIntegration: true),0.0195387021367985546020 ,accuracy: 1E-12)
        XCTAssertEqual(try! cdfVonMisesDist(x: -2.5, mean: -3, concentration: 4, useExpIntegration: true),0.829488464005985508796 ,accuracy: 1E-12)
        XCTAssertEqual(try! cdfVonMisesDist(x: -0.2, mean: -3, concentration: 4, useExpIntegration: true),0.999904581125379364584 ,accuracy: 1E-12)
        XCTAssertEqual(try! cdfVonMisesDist(x: -4.4, mean: -3, concentration: 4, useExpIntegration: true),0.00722697637072942637724 ,accuracy: 1E-12)
        XCTAssertEqual(try! cdfVonMisesDist(x: -Double.pi / 2.0, mean: -3, concentration: 4, useExpIntegration: true),0.993539629762563788614 ,accuracy: 1E-12)
        XCTAssertEqual(try! cdfVonMisesDist(x: 0, mean: -3, concentration: 4, useExpIntegration: true),0.999962986474166847826 ,accuracy: 1E-12)
        XCTAssertEqual(try! cdfVonMisesDist(x: -3 + Double.pi + 1.0, mean: -3, concentration: 4, useExpIntegration: true),1.0 ,accuracy: 1E-7)
        /*
         a = -3;
         b = 4;
         d = VonMisesDistribution[a, b];
         N[PDF[d, a - Pi - 1], 21]
         N[PDF[d, -Pi - 1], 21]
         N[PDF[d, -25/10], 21]
         N[PDF[d, -20/100], 21]
         N[PDF[d, -44/10], 21]
         N[PDF[d, 0 - Pi/2], 21]
         N[PDF[d, 0], 21]
         N[PDF[d, a + Pi + 1], 21]
         */
        XCTAssertThrowsError(try pdfVonMisesDist(x: 2, mean: -3, concentration: 0))
        XCTAssertThrowsError(try pdfVonMisesDist(x: 2, mean: -3, concentration: -1))
        XCTAssertEqual(try! pdfVonMisesDist(x: -3 - Double.pi - 1.0, mean: -3, concentration: 4),0 ,accuracy: 1E-5)
        XCTAssertEqual(try! pdfVonMisesDist(x: -Double.pi - 1.0, mean: -3, concentration: 4),0.0744027395631070328565 ,accuracy: 1E-12)
        XCTAssertEqual(try! pdfVonMisesDist(x: -2.5, mean: -3, concentration: 4),0.471177869330735027666 ,accuracy: 1E-12)
        XCTAssertEqual(try! pdfVonMisesDist(x: -0.2, mean: -3, concentration: 4),0.000324982499557601827956 ,accuracy: 1E-12)
        XCTAssertEqual(try! pdfVonMisesDist(x: -4.4, mean: -3, concentration: 4),0.0277927164636370027697 ,accuracy: 1E-12)
        XCTAssertEqual(try! pdfVonMisesDist(x: -Double.pi / 2.0, mean: -3, concentration: 4),0.0247638628979559132417 ,accuracy: 1E-12)
        XCTAssertEqual(try! pdfVonMisesDist(x: 0, mean: -3, concentration: 4),0.000268456988587833058582 ,accuracy: 1E-12)
        XCTAssertEqual(try! pdfVonMisesDist(x: -3 + Double.pi + 1.0, mean: -3, concentration: 4),0 ,accuracy: 1E-7)
        /*
         a = -3;
         b = 4;
         d = VonMisesDistribution[a, b];
         N[InverseCDF[d, 0], 21]
         N[InverseCDF[d, 25/100], 21]
         N[InverseCDF[d, 5/10], 21]
         N[InverseCDF[d, 75/100], 21]
         N[InverseCDF[d, 99/100], 21]
         N[InverseCDF[d, 999/1000], 21]
         N[InverseCDF[d, 1], 21]
         */
        XCTAssertThrowsError(try quantileVonMisesDist(p: -1, mean: -3, concentration: 4))
        XCTAssertThrowsError(try quantileVonMisesDist(p: 2, mean: -3, concentration: 4))
        XCTAssertEqual(try! quantileVonMisesDist(p: 0, mean: -3, concentration: 4),-6.14159265358979323846 ,accuracy: 1E-5)
        XCTAssertEqual(try! quantileVonMisesDist(p: 0.25, mean: -3, concentration: 4),-3.35205527357190904480 ,accuracy: 1E-5)
        XCTAssertEqual(try! quantileVonMisesDist(p: 0.5, mean: -3, concentration: 4),-3.00000000000000000000 ,accuracy: 1E-5)
        XCTAssertEqual(try! quantileVonMisesDist(p: 0.75, mean: -3, concentration: 4),-2.64794472642809095508 ,accuracy: 1E-5)
        XCTAssertEqual(try! quantileVonMisesDist(p: 0.99, mean: -3, concentration: 4),-1.68421199711729556367 ,accuracy: 1E-5)
        XCTAssertEqual(try! quantileVonMisesDist(p: 0.999, mean: -3, concentration: 4),-1.04475697892580395363 ,accuracy: 1E-5)
        XCTAssertEqual(try! quantileVonMisesDist(p: 1, mean: -3, concentration: 4),0.141592653589793238463 ,accuracy: 1E-5)
        /*
         a = -3;
         b = 4;
         d = VonMisesDistribution[a, b];
         [Mean[d], 21]
         V = 1 - BesselI[1, b]/BesselI[0, b]
         N[%,21]
         */
        XCTAssertThrowsError(try paraVonMisesDist(mean: -3, concentration: 0))
        XCTAssertThrowsError(try paraVonMisesDist(mean: -3, concentration: -1))
        para = try! paraVonMisesDist(mean: -3, concentration: 4)
        XCTAssertEqual(para!.mean, -3, accuracy: 1e-12)
        XCTAssertEqual(para!.variance, 0.136477388975449417145, accuracy: 1e-12)
        XCTAssert(para!.skewness.isNaN)
        XCTAssert(para!.kurtosis.isNaN)
        /*
         ClearAll["Global`*"];
         s = 3/2;
         d = RayleighDistribution[s];
         N[PDF[d, -1], 21]
         N[PDF[d, 0], 21]
         N[PDF[d, 1/100], 21]
         N[PDF[d, 1], 21]
         N[PDF[d, 11/10], 21]
         N[PDF[d, 3], 21]
         N[PDF[d, 10], 21]
         */
        XCTAssertThrowsError(try pdfRayleighDist(x: 1, scale: 0))
        XCTAssertThrowsError(try pdfRayleighDist(x: 1, scale: -1))
        XCTAssertEqual(try! pdfRayleighDist(x: -1, scale: 1.5),0 ,accuracy: 1E-14)
        XCTAssertEqual(try! pdfRayleighDist(x: 0, scale: 1.5),0 ,accuracy: 1E-14)
        XCTAssertEqual(try! pdfRayleighDist(x: 0.01, scale: 1.5),0.00444434568010973124020 ,accuracy: 1E-14)
        XCTAssertEqual(try! pdfRayleighDist(x: 1, scale: 1.5),0.355883290185248018124 ,accuracy: 1E-14)
        XCTAssertEqual(try! pdfRayleighDist(x: 1.1, scale: 1.5),0.373622658528284221473 ,accuracy: 1E-14)
        XCTAssertEqual(try! pdfRayleighDist(x: 3, scale: 1.5),0.180447044315483589192 ,accuracy: 1E-14)
        XCTAssertEqual(try! pdfRayleighDist(x: 10, scale: 1.5),9.92725082756961935157e-10 ,accuracy: 1E-20)
        /*
         ClearAll["Global`*"];
         s = 3/2;
         d = RayleighDistribution[s];
         N[CDF[d, -1], 21]
         N[CDF[d, 0], 21]
         N[CDF[d, 1/100], 21]
         N[CDF[d, 1], 21]
         N[CDF[d, 11/10], 21]
         N[CDF[d, 3], 21]
         N[CDF[d, 10], 21]
         */
        XCTAssertThrowsError(try cdfRayleighDist(x: 1, scale: 0))
        XCTAssertThrowsError(try cdfRayleighDist(x: 1, scale: -1))
        XCTAssertEqual(try! cdfRayleighDist(x: -1, scale: 1.5),0 ,accuracy: 1E-14)
        XCTAssertEqual(try! cdfRayleighDist(x: 0, scale: 1.5),0 ,accuracy: 1E-14)
        XCTAssertEqual(try! cdfRayleighDist(x: 0.01, scale: 1.5),0.0000222219753104709546309 ,accuracy: 1E-14)
        XCTAssertEqual(try! cdfRayleighDist(x: 1, scale: 1.5),0.199262597083191959222 ,accuracy: 1E-14)
        XCTAssertEqual(try! cdfRayleighDist(x: 1.1, scale: 1.5),0.235771834828509546987 ,accuracy: 1E-14)
        XCTAssertEqual(try! cdfRayleighDist(x: 3, scale: 1.5),0.864664716763387308106 ,accuracy: 1E-14)
        XCTAssertEqual(try! cdfRayleighDist(x: 10, scale: 1.5),0.999999999776636856380 ,accuracy: 1E-14)

        /*
         ClearAll["Global`*"];
         s = 3/2;
         d = RayleighDistribution[s];
         N[InverseCDF[d, 25/100], 21]
         N[InverseCDF[d, 5/10], 21]
         N[InverseCDF[d, 75/100], 21]
         N[InverseCDF[d, 99/100], 21]
         N[InverseCDF[d, 999/1000], 21]
         N[InverseCDF[d, 1], 21]
         */
        XCTAssertThrowsError(try quantileRayleighDist(p: -1, scale: 1.5))
        XCTAssertThrowsError(try quantileRayleighDist(p: 2, scale: 1.5))
        XCTAssertEqual(try! quantileRayleighDist(p: 0, scale: 1.5),0 ,accuracy: 1E-15)
        XCTAssertEqual(try! quantileRayleighDist(p: 0.25, scale: 1.5),1.13779142466139819887 ,accuracy: 1E-15)
        XCTAssertEqual(try! quantileRayleighDist(p: 0.5, scale: 1.5),1.76611503377321203652 ,accuracy: 1E-15)
        XCTAssertEqual(try! quantileRayleighDist(p: 0.75, scale: 1.5),2.49766383347309326906 ,accuracy: 1E-15)
        XCTAssertEqual(try! quantileRayleighDist(p: 0.99, scale: 1.5),4.55228138815543905259 ,accuracy: 1E-15)
        XCTAssertEqual(try! quantileRayleighDist(p: 0.999, scale: 1.5),5.57538328327475767043 ,accuracy: 1E-15)
        XCTAssert(try! quantileRayleighDist(p: 1, scale: 1.5).isInfinite)

        /*
         ClearAll["Global`*"];
         a = -2;
         b = 1;
         d = ExtremeValueDistribution[a, b];
         N[PDF[d, -1], 21]
         N[PDF[d, 0], 21]
         N[PDF[d, 1/100], 21]
         N[PDF[d, 1], 21]
         N[PDF[d, 11/10], 21]
         N[PDF[d, 3], 21]
         N[PDF[d, 10], 21]
         */
        XCTAssertThrowsError(try pdfExtremValueDist(x: 1, location: -2, scale: -11))
        XCTAssertThrowsError(try pdfExtremValueDist(x: 1, location: -2, scale: 0))
        XCTAssertEqual(try! pdfExtremValueDist(x: -6, location: -2, scale: 1),  1.06048039970427672992e-22 ,accuracy: 1E-30)
        XCTAssertEqual(try! pdfExtremValueDist(x: -5, location: -2, scale: 1),3.80054250404435771071e-8 ,accuracy: 1E-14)
        XCTAssertEqual(try! pdfExtremValueDist(x: -0.04, location: -2, scale: 1),0.122351354198388769973 ,accuracy: 1E-14)
        XCTAssertEqual(try! pdfExtremValueDist(x: -2, location: -2, scale: 1),0.367879441171442321596 ,accuracy: 1E-14)
        XCTAssertEqual(try! pdfExtremValueDist(x: -0.11, location: -2, scale: 1),0.129889419617261299978 ,accuracy: 1E-14)
        XCTAssertEqual(try! pdfExtremValueDist(x: 0, location: -2, scale: 1),0.118204951593143145999 ,accuracy: 1E-14)
        XCTAssertEqual(try! pdfExtremValueDist(x: 2, location: -2, scale: 1),0.0179832296967136435659 ,accuracy: 1E-14)
        XCTAssertEqual(try! pdfExtremValueDist(x: 5, location: -2, scale: 1),0.000911050815848220300461 ,accuracy: 1E-14)
        /*
         ClearAll["Global`*"];
         a = -2;
         b = 1;
         d = ExtremeValueDistribution[a, b];
         N[PDF[d, -1], 21]
         N[PDF[d, 0], 21]
         N[PDF[d, 1/100], 21]
         N[PDF[d, 1], 21]
         N[PDF[d, 11/10], 21]
         N[PDF[d, 3], 21]
         N[PDF[d, 10], 21]
         */
        XCTAssertThrowsError(try cdfExtremValueDist(x: 1, location: -2, scale: -11))
        XCTAssertThrowsError(try cdfExtremValueDist(x: 1, location: -2, scale: 0))
        XCTAssertEqual(try! cdfExtremValueDist(x: -6, location: -2, scale: 1),  1.94233760495640183858e-24 ,accuracy: 1E-30)
        XCTAssertEqual(try! cdfExtremValueDist(x: -5, location: -2, scale: 1),1.89217869483829263358e-9 ,accuracy: 1E-14)
        XCTAssertEqual(try! cdfExtremValueDist(x: -0.04, location: -2, scale: 1),0.868612280319186993522 ,accuracy: 1E-14)
        XCTAssertEqual(try! cdfExtremValueDist(x: -2, location: -2, scale: 1),0.367879441171442321596 ,accuracy: 1E-14)
        XCTAssertEqual(try! cdfExtremValueDist(x: -0.11, location: -2, scale: 1),0.859785956213361748121 ,accuracy: 1E-14)
        XCTAssertEqual(try! cdfExtremValueDist(x: 0, location: -2, scale: 1),0.873423018493116642989 ,accuracy: 1E-14)
        XCTAssertEqual(try! cdfExtremValueDist(x: 2, location: -2, scale: 1),0.981851073061666482920 ,accuracy: 1E-14)
        XCTAssertEqual(try! cdfExtremValueDist(x: 5, location: -2, scale: 1),0.999088533672457833191 ,accuracy: 1E-14)

        
        /*
         ClearAll["Global`*"];
         a = -2;
         b = 1;
         d = ExtremeValueDistribution[a, b];
         N[InverseCDF[d, 25/100], 21]
         N[InverseCDF[d, 5/10], 21]
         N[InverseCDF[d, 75/100], 21]
         N[InverseCDF[d, 99/100], 21]
         N[InverseCDF[d, 999/1000], 21]
         N[InverseCDF[d, 1], 21]
         */
        XCTAssertThrowsError(try quantileExtremValueDist(p: -1,location: -2, scale: 1))
        XCTAssertThrowsError(try quantileExtremValueDist(p: 2,location: -2, scale: 1))
        XCTAssert(try! quantileExtremValueDist(p: 0,location: -2, scale: 1) == -Double.infinity)
        XCTAssertEqual(try! quantileExtremValueDist(p: 0.25,location: -2, scale: 1),-2.32663425997828098240 ,accuracy: 1E-14)
        XCTAssertEqual(try! quantileExtremValueDist(p: 0.5,location: -2, scale: 1),-1.63348707941833567299 ,accuracy: 1E-14)
        XCTAssertEqual(try! quantileExtremValueDist(p: 0.75,location: -2, scale: 1),-0.754100676292761801619 ,accuracy: 1E-14)
        XCTAssertEqual(try! quantileExtremValueDist(p: 0.99,location: -2, scale: 1),2.60014922677657999772 ,accuracy: 1E-14)
        XCTAssertEqual(try! quantileExtremValueDist(p: 0.999,location: -2, scale: 1),4.90725507052371649992 ,accuracy: 1E-14)
        XCTAssert(try! quantileExtremValueDist(p: 1,location: -2, scale: 1).isInfinite)
        /*
         lambda = 2;
         df = 10;
         d = NoncentralChiSquareDistribution[df, lambda];
         N[PDF[d, 0], 21]
         N[PDF[d, 1], 21]
         N[PDF[d, 35/10], 21]
         N[PDF[d, 4], 21]
         N[PDF[d, 20], 21]
         N[PDF[d, 120], 21]
        */
        XCTAssertThrowsError(try pdfChiSquareDist(chi: 0, degreesOfFreedom: 10, lambda: -1))
        XCTAssertThrowsError(try pdfChiSquareDist(chi: 0, degreesOfFreedom: -10, lambda: 0))
        XCTAssertEqual(try! pdfChiSquareDist(chi: 0, degreesOfFreedom: 10, lambda: 2), 0, accuracy: 1E-12)
        XCTAssertEqual(try! pdfChiSquareDist(chi: 1, degreesOfFreedom: 10, lambda: 2), 0.000320827305783384301367, accuracy: 1E-12)
        XCTAssertEqual(try! pdfChiSquareDist(chi: 3.5, degreesOfFreedom: 10, lambda: 2), 0.0175567221203895712845, accuracy: 1E-12)
        XCTAssertEqual(try! pdfChiSquareDist(chi: 4, degreesOfFreedom: 10, lambda: 2), 0.0244526022914690298218, accuracy: 1E-12)
        XCTAssertEqual(try! pdfChiSquareDist(chi: 20, degreesOfFreedom: 10, lambda: 2), 0.0200906234018482020788, accuracy: 1E-12)
        XCTAssertEqual(try! pdfChiSquareDist(chi: 120, degreesOfFreedom: 10, lambda: 2), 1.86330190212638377398e-18, accuracy: 1E-25)
        /*
         lambda = 2;
         df = 10;
         d = NoncentralChiSquareDistribution[df, lambda];
         N[CDF[d, 0], 21]
         N[CDF[d, 1], 21]
         N[CDF[d, 35/10], 21]
         N[CDF[d, 4], 21]
         N[CDF[d, 20], 21]
         N[CDF[d, 120], 21]
         */
        XCTAssertThrowsError(try cdfChiSquareDist(chi: 0, degreesOfFreedom: 10, lambda: -1))
        XCTAssertThrowsError(try cdfChiSquareDist(chi: 0, degreesOfFreedom: -10, lambda: 0))
        XCTAssertEqual(try! cdfChiSquareDist(chi: 0, degreesOfFreedom: 10, lambda: 2), 0, accuracy: 1E-12)
        XCTAssertEqual(try! cdfChiSquareDist(chi: 1, degreesOfFreedom: 10, lambda: 2), 0.0000687170350978367993954, accuracy: 1E-12)
        XCTAssertEqual(try! cdfChiSquareDist(chi: 3.5, degreesOfFreedom: 10, lambda: 2), 0.0158988857488017761417, accuracy: 1E-12)
        XCTAssertEqual(try! cdfChiSquareDist(chi: 4, degreesOfFreedom: 10, lambda: 2), 0.0263683505034293909215, accuracy: 1E-12)
        XCTAssertEqual(try! cdfChiSquareDist(chi: 20, degreesOfFreedom: 10, lambda: 2), 0.920255991428431897124, accuracy: 1E-12)
        XCTAssertEqual(try! cdfChiSquareDist(chi: 120, degreesOfFreedom: 10, lambda: 2), 0.999999999999999995559, accuracy: 1E-12)
        /*
         lambda = 2;
         df = 10;
         d = NoncentralChiSquareDistribution[df, lambda];
         N[CDF[d, 0], 21]
         N[CDF[d, 1], 21]
         N[CDF[d, 35/10], 21]
         N[CDF[d, 4], 21]
         N[CDF[d, 20], 21]
         N[CDF[d, 120], 21]
         */
        XCTAssertThrowsError(try quantileChiSquareDist(p: -1, degreesOfFreedom: 10, lambda: 2))
        XCTAssertThrowsError(try quantileChiSquareDist(p: -1, degreesOfFreedom: 10, lambda: 2))
        XCTAssert(try! quantileChiSquareDist(p: 0, degreesOfFreedom: 10, lambda: 2) == 0)
        XCTAssertEqual(try! quantileChiSquareDist(p: 0.25, degreesOfFreedom: 10, lambda: 2),8.13756055748165583031 ,accuracy: 1E-12)
        XCTAssertEqual(try! quantileChiSquareDist(p: 0.5, degreesOfFreedom: 10, lambda: 2),11.2430133568251407182 ,accuracy: 1E-12)
        XCTAssertEqual(try! quantileChiSquareDist(p: 0.75, degreesOfFreedom: 10, lambda: 2),15.0420244933699346629 ,accuracy: 1E-12)
        XCTAssertEqual(try! quantileChiSquareDist(p: 0.99, degreesOfFreedom: 10, lambda: 2),27.5151340899272570682 ,accuracy: 1E-12)
        XCTAssertEqual(try! quantileChiSquareDist(p: 0.999, degreesOfFreedom: 10, lambda: 2),34.8900723430922940474 ,accuracy: 1E-12)
        XCTAssert(try! quantileChiSquareDist(p: 1, degreesOfFreedom: 10, lambda: 2).isInfinite)
    }
    
//
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//        }
//    }
    
}

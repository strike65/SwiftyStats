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
        let df = try! SSDataFrame.dataFrame(fromFile: resPath + "/TukeyKramerData_01.csv", scanDouble)
        let df1 = try! SSDataFrame.dataFrame(fromFile: resPath + "/TukeyKramerData_02.csv", scanDouble)
        #else
        let df = try! SSDataFrame.dataFrame(fromString: TukeyKramerData_01String, parser: scanDouble)
        let df1 = try! SSDataFrame.dataFrame(fromString: TukeyKramerData_02String, parser: scanDouble)
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
        var examineConc1: SSExamine<Double>! = nil
        var examineConc2: SSExamine<Double>! = nil
        var examineConc3: SSExamine<Double>! = nil
        
        do {
            examineConc1 = try SSExamine<Double>.init(withObject: concentr1, levelOfMeasurement: .ordinal, name: "market share 1", characterSet: nil)
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
            examineConc2 = try SSExamine<Double>.init(withObject: concentr2, levelOfMeasurement: .ordinal, name: "market share 1", characterSet: nil)
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
            examineConc3 = try SSExamine<Double>.init(withObject: concentr3, levelOfMeasurement: .ordinal, name: "market share 1", characterSet: nil)
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
        var examineInt: SSExamine<Int>! = nil
        var examineIntOutliers: SSExamine<Int>! = nil
        #if os(macOS) || os(iOS)
        do {
            examineInt = try SSExamine<Int>.examine(fromFile: resPath + "/IntData.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanInt)!
            examineIntOutliers = try SSExamine<Int>.examine(fromFile: resPath + "/IntDataWithOutliers.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanInt)!
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
            let s = try examineInt.saveTo(fileName: url?.path, atomically: true, overwrite: true, separator: ",", stringEncoding: .utf8)
            XCTAssert(s)
        }
        catch is SSSwiftyStatsError {
            print("unable to save examineInt")
        }
        catch {
            print("other error in save examine to file")
        }
        //        var testExamineInt: SSExamine<Int>! = nil
        do {
            if let testExamineInt = try SSExamine<Int>.examine(fromFile: url?.path, separator: ",", stringEncoding: .utf8, scanInt) {
                XCTAssert(testExamineInt.isEqual(examineInt))
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
            if let testExamineInt = try SSExamine<Int>.unarchiveFrom(filePath: url?.path) {
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
        var examineDouble: SSExamine<Double>! = nil
        var examineString: SSExamine<String>! = nil
        do {
            #if os(macOS) || os(iOS)
            examineDouble = try SSExamine<Double>.examine(fromFile: resPath + "/DoubleData.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)
            #else
            if let p = linuxResourcePath(resource: "DoubleData", type: "examine") {
                examineDouble = try SSExamine<Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)
            }
            #endif
            examineString = try SSExamine<String>.init(withObject: intDataTestString, levelOfMeasurement: .nominal, name: "string data", characterSet: nil)
            XCTAssertNotNil(try SSExamine<String>.init(withObject: intDataTestString, levelOfMeasurement: .nominal, name: "string data only numbers", characterSet: CharacterSet.init(charactersIn: "1234567890")))
        }
        catch is SSSwiftyStatsError {
            print("unable to load examineDouble")
        }
        catch {
            print("other error")
        }
        
        XCTAssertNotNil(SSExamine<String>.examineWithString(intDataTestString, name: "string data only numbers", characterSet: CharacterSet.init(charactersIn: "1234567890")))
        let examineEmpty: SSExamine<String> = examineString.copy() as! SSExamine<String>
        var examineWithZero: SSExamine<Double>! = nil
        var examineWithZeroMean: SSExamine<Int>! = nil
        var examineSmall: SSExamine<Double>! = nil
        do {
            examineWithZero = try SSExamine.init(withObject: [1.0,1.0, 0.0, 1.2], levelOfMeasurement: .interval, name: "double with zero", characterSet: nil)
            examineWithZeroMean = try
                SSExamine<Int>.init(withObject: [0,0,0,0,0], levelOfMeasurement: .interval, name: "all zero", characterSet: nil)
            examineSmall = try SSExamine.init(withObject: [1.0], levelOfMeasurement: .interval, name: "double one element", characterSet: nil)
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
        let platy:SSExamine<Double> = try! SSExamine<Double>.init(withObject: platykurtic, levelOfMeasurement: .interval, name: "platykurtic", characterSet: nil)
        let lepto:SSExamine<Double> = try! SSExamine<Double>.init(withObject: leptokurtic, levelOfMeasurement: .interval, name: "leptokurtic", characterSet: nil)
        XCTAssert(platy.kurtosisType == .platykurtic)
        XCTAssert(lepto.kurtosisType == .leptokurtic)
        let left:SSExamine<Int> = try! SSExamine<Int>.init(withObject: leftskewed, levelOfMeasurement: .interval, name: "leftskewed", characterSet: nil)
        let right:SSExamine<Int> = try! SSExamine<Int>.init(withObject: rightskewed, levelOfMeasurement: .interval, name: "rightskewed", characterSet: nil)
        let sym:SSExamine<Int> = try! SSExamine<Int>.init(withObject: symmetric, levelOfMeasurement: .interval, name: "rightskewed", characterSet: nil)
        XCTAssert(left.skewnessType == .leftSkewed)
        XCTAssert(right.skewnessType == .rightSkewed)
        XCTAssert(sym.skewnessType == .symmetric)
        XCTAssert(examineSmall.variance(type: .unbiased) == nil)
        XCTAssert(examineSmall.standardDeviation(type: .unbiased) == nil)
        XCTAssert(examineSmall.standardError == nil)
        XCTAssertTrue(examineWithZeroMean.contraHarmonicMean! == -Double.infinity)
        XCTAssert(examineString.total == nil)
        XCTAssert(examineString.poweredTotal(power: 2.0) == nil)
        XCTAssert(examineString.squareTotal == nil)
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
        XCTAssert(examineString.outliers(alpha: 0.00005, max: 10, testType: .bothTails) == nil)
        XCTAssert(examineString.isGaussian == nil)
        
        let outliers = examineIntOutliers.outliers(alpha: 0.05, max: 10, testType: .bothTails)!
        let expectedOutliers: Array<Double> = [300,200,200,200,101,101,101,100,100,100]
        XCTAssertEqual(examineDouble.herfindahlIndex!, 0.004438149, accuracy: 1E-9)
        XCTAssertEqual(examineDouble.meanDifference!, 7.050566, accuracy: 1E-6)
        XCTAssertEqual(examineDouble.gini!, 0.1753802, accuracy: 1E-7)
        XCTAssert(outliers.count == expectedOutliers.count)
        XCTAssert(examineIntOutliers.outliers(alpha: 0.00005, max: 10, testType: .bothTails) == nil)
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
        XCTAssert(examineDouble.commonest![0] == 18.0)
        XCTAssert(examineDouble.scarcest![0] == 9.0)
        XCTAssert(examineDouble.scarcest![1] == 39.0)
        XCTAssert(!examineDouble.hasOutliers(testType: .esd)!)
        XCTAssert(examineDouble.quartile!.q25 == 15)
        XCTAssert(examineDouble.quartile!.q50 == 19)
        XCTAssert(examineDouble.quartile!.q75 == 24)
        XCTAssertEqual(examineDouble.median, 19)
        XCTAssert(try! examineDouble.quantile(q: 0.1) == 13)
        XCTAssertThrowsError(try examineDouble.quantile(q: 1.5))
        XCTAssert(examineDouble.arithmeticMean! == 20.100806451612904)
        XCTAssert(examineDouble.harmonicMean! == 18.314802880545665)
        XCTAssertEqual(examineDouble.geometricMean!, 19.168086630042282)
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
        XCTAssertEqual(examineDouble.logProduct, 732.40519187630610)
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
        XCTAssertEqual(examineDouble.moment(r: 2, type: .central)!, 40.671289672216441, accuracy: 1E-14)
        XCTAssertEqual(examineDouble.moment(r: 3, type: .central)!, 213.45322268575241, accuracy: 1E-12)
        XCTAssertEqual(examineDouble.moment(r: 4, type: .central)!, 5113.3413825102367, accuracy: 1E-12)
        XCTAssertEqual(examineDouble.moment(r: 5, type: .central)!, 59456.550944779016, accuracy: 1E-10)
        XCTAssertEqual(examineDouble.moment(r: 3, type: .origin)!, 10787.608870967742, accuracy: 1E-10)
        XCTAssertEqual(examineDouble.moment(r: 5, type: .origin)!, 8020422.4798387097, accuracy: 1E-10)
        XCTAssertEqual(examineDouble.moment(r: 2, type: .standardized)!, 1.0, accuracy: 1E-4)
        XCTAssertEqual(examineDouble.moment(r: 0, type: .standardized)!, 1.0, accuracy: 1E-4)
        XCTAssertEqual(examineDouble.moment(r: 1, type: .standardized)!, 0.0, accuracy: 1E-4)
        XCTAssertEqual(examineDouble.standardDeviation(type: .unbiased)!, 6.3903013046339835, accuracy: 1E-14)
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
        let exFromJSON = try! SSExamine<Double>.examine(fromJSONFile: url!.path)
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
        XCTAssert(examineEmpty.squareTotal == nil)
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
        
        let examine2: SSExamine<Double> = examineDouble.copy() as! SSExamine<Double>
        XCTAssert(examineDouble.hashValue == examine2.hashValue)
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
        let set1 = SSExamine<Double>.init(withArray: wafer1, name: "Wafer_A", characterSet: nil)
        let set2 = SSExamine<Double>.init(withArray: wafer2, name: "Wafer_B", characterSet: nil)
        let set3 = SSExamine<Double>.init(withArray: wafer2, name: "Wafer_C", characterSet: nil)
        
        var df = try! SSDataFrame<Double>.init(examineArray: [set1, set2, set3])
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
        var df2:SSDataFrame<Double>! = nil
        do {
            #if os(macOS) || os(iOS)
            df2 = try SSDataFrame<Double>.dataFrame(fromFile: resPath + "test.csv", separator: ",", firstRowContainsNames: true, stringEncoding: String.Encoding.utf16, scanDouble)
            #else
            df2 = try SSDataFrame<Double>.dataFrame(fromFile: "test.csv", separator: ",", firstRowContainsNames: true, stringEncoding: String.Encoding.utf8, scanDouble)
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
                if let testDataFrame = try SSDataFrame<Double>.unarchiveFrom(filePath: url?.path) {
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
        var exa1: SSExamine<Double>! = nil
        var exa2: SSExamine<Double>! = nil
        var exa3: SSExamine<Double>! = nil
        #if os(macOS) || os(iOS)
            exa1 = try! SSExamine<Double>.examine(fromFile: resPath + "/NormalData01.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        #else
        if let p = linuxResourcePath(resource: "NormalData01", type: "examine") {
            exa1 = try! SSExamine<Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        }
        #endif
        print("==============!!!!!!!!!!!!!!!!!!!================")
        exa1.name = "Normal_01"
        #if os(macOS) || os(iOS)
        exa2 = try! SSExamine<Double>.examine(fromFile: resPath + "/NormalData02.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        #else
        if let p = linuxResourcePath(resource: "NormalData02", type: "examine") {
            exa2 = try! SSExamine<Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        }
        #endif
        exa2.name = "Normal_02"
        #if os(macOS) || os(iOS)
        exa3 = try! SSExamine<Double>.examine(fromFile: resPath + "/NormalData03.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        #else
        if let p = linuxResourcePath(resource: "NormalData03", type: "examine") {
            exa3 = try! SSExamine<Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        }
        #endif
        exa3.name = "Normal_03"
        #if os(macOS) || os(iOS)
        df = try! SSDataFrame<Double>.init(examineArray: [exa1, exa2, exa3])
        let _ = try! df.exportCSV(path: resPath + "/normal.csv", separator: ",", useQuotes: true, firstRowAsColumnName: true, overwrite: true, stringEncoding: String.Encoding.utf8, atomically: true)
        #else
        df = try! SSDataFrame<Double>.init(examineArray: [exa1, exa2, exa3])
        let _ = try! df.exportCSV(path: "normal.csv", separator: ",", useQuotes: true, firstRowAsColumnName: true, overwrite: true, stringEncoding: String.Encoding.utf8, atomically: true)
        #endif
        #if os(macOS) || os(iOS)
        df2 = try! SSDataFrame<Double>.dataFrame(fromFile: resPath + "/normal.csv", separator: ",", firstRowContainsNames: true, stringEncoding: String.Encoding.utf8, scanDouble)
        #else
        df2 = try! SSDataFrame<Double>.dataFrame(fromFile: "normal.csv", separator: ",", firstRowContainsNames: true, stringEncoding: String.Encoding.utf8, scanDouble)
        #endif
        XCTAssert(df.isEqual(df2))
        #if os(macOS) || os(iOS)
        let df3 = try! SSDataFrame<String>.dataFrame(fromFile: resPath + "/normal.csv", separator: ",", firstRowContainsNames: true, stringEncoding: .utf8, scanString)
        #else
        let df3 = try! SSDataFrame<String>.dataFrame(fromFile: "normal.csv", separator: ",", firstRowContainsNames: true, stringEncoding: .utf8, scanString)
        #endif
        XCTAssert(df3[0].arithmeticMean == nil)
    }
    
    func testCrossTabs() {
        var c = try! SSCrosstab.init(rows: 4, columns: 3, initialValue: 0, rowID: ["Heavy", "Never", "Occas", "Regul"], columnID: ["Freq", "None", "Some"] )
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
        print(c.residual(row: 1, column: 1))
        print(c.phi)
        var c1 = try! SSCrosstab.init(rows: 2, columns: 2, initialValue: 0, rowID: [1, 2], columnID: [1,2])
        try! c1.setColumn(at: 0, newColumn:[4,3])
        try! c1.setColumn(name: 2, newColumn:[2,3])
        print(c1.chiSquareLikelihoodRatio)
        print(c1.chiSquareYates)
        print(c1.adjustedResidual(row: 1, column: 1))
        print(c1.expectedFrequency(row: 1, column: 1))
        print(c1[1,1])
        print(c1.residual(row: 1, column: 1))
        print(c1.pearsonR)
        print(c1.phi)
        print(c1.cramerV)
        print(c1)
        var c2 = try! SSCrosstab.init(rows: 2, columns: 2, initialValue: 0, rowID: [1, 2], columnID: [1,2])
        try! c2.setColumn(at: 0, newColumn:[60,40])
        try! c2.setColumn(name: 2, newColumn:[30,70])
        print(c2.chiSquareLikelihoodRatio)
        print(c2.chiSquareYates)
        print(c2.adjustedResidual(row: 1, column: 1))
        print(c2.expectedFrequency(row: 1, column: 1))
        print(c2[1,1])
        print(c2.residual(row: 1, column: 1))
        print(c2.pearsonR)
        print(c2.phi)
        print(c2.cramerV)
        print(c2.r0)
        print(c2.r1)
        print(c2)
        //        TAU test
        var tauTable = try! SSCrosstab.init(rows: 3, columns: 2, initialValue: 0.0, rowID: ["<= 20 a", "21 - 50 a", ">=51 a"], columnID: ["Raucher", "Nichtraucher"])
        try! tauTable.setColumn(name: "Raucher", newColumn: [0.4, 0.3, 0.30])
        try! tauTable.setColumn(name: "Nichtraucher", newColumn: [0.20, 0.30, 0.50])
        print(tauTable.rowLevelOfMeasurement)
        print(tauTable.columnLevelOfMeasurement)
        print(tauTable.lambda_C_R)
        print(tauTable.lambda_R_C)
        //        print(tauTable.tauCR)
    }
    
    
    func testKS2Sample() {
        let set1 = SSExamine<Double>.init(withArray: wafer1, name: nil, characterSet: nil)
        let set2 = SSExamine<Double>.init(withArray: wafer2, name: nil, characterSet: nil)
        var res: SSKSTwoSampleTestResult
        res = try! SSHypothesisTesting.kolmogorovSmirnovTwoSampleTest(set1: set1, set2: set2, alpha: 0.05)
        XCTAssertEqual(res.p2Value!, 0.4611, accuracy: 1E-4)
        let set3 = SSExamine<Double>.init(withArray: normal3, name: nil, characterSet: nil)
        let set4 = SSExamine<Double>.init(withArray: laplaceData, name: nil, characterSet: nil)
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
        let g1 = SSExamine<Double>.init(withArray: sign1, name: nil, characterSet: nil)
        let g2 = SSExamine<Double>.init(withArray: sign2, name: nil, characterSet: nil)
        var res = try! SSHypothesisTesting.signTest(set1: g1, set2: g2)
        XCTAssertEqual(res.pValueExact!, 0.0144084, accuracy: 1E-6)
        let g3 = SSExamine<Double>.init(withArray: sign3, name: nil, characterSet: nil)
        let g4 = SSExamine<Double>.init(withArray: sign4, name: nil, characterSet: nil)
        res = try! SSHypothesisTesting.signTest(set1: g3, set2: g4)
        XCTAssertEqual(res.pValueExact!, 0.0384064, accuracy: 1E-6)
        var g5: SSExamine<Double>! = nil
        var g6: SSExamine<Double>! = nil
        #if os(macOS) || os(iOS)
        g5 = try! SSExamine<Double>.examine(fromFile: resPath + "/largeNormal_01.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        g6 = try! SSExamine<Double>.examine(fromFile: resPath + "/largeNormal_02.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        #else
        if let p = linuxResourcePath(resource: "largeNormal_01", type: "examine") {
            g5 = try! SSExamine<Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        }
        if let p = linuxResourcePath(resource: "largeNormal_02", type: "examine") {
            g6 = try! SSExamine<Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
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
        let examine1 = SSExamine.init(withArray: M1, name: nil, characterSet: nil)
        let examine2 = SSExamine.init(withArray: M2, name: nil, characterSet: nil)
        /*
             > M1 <- c(0.47, 1.02, 0.33, 0.70, 0.94, 0.85, 0.39, 0.52, 0.47)
             > M2 <- c(0.41, 1.00, 0.46, 0.61, 0.84, 0.87, 0.36, 0.52, 0.51)
             > wilcox.test(x = M1, y = M2,paired = TRUE, alternative = "two.sided")
             
             Wilcoxon signed rank test with continuity correction
             
             data:  M1 and M2
             V = 22.5, p-value = 0.5749
             alternative hypothesis: true location shift is not equal to 0
        */
        var wilcox = try! SSHypothesisTesting.wilcoxonMatchedPairs(set1: examine1, set2: examine2)
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
        let examine3 = SSExamine.init(withArray: M3, name: nil, characterSet: nil)
        let examine4 = SSExamine.init(withArray: M4, name: nil, characterSet: nil)
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
        let examine5 = SSExamine.init(withArray: M5, name: nil, characterSet: nil)
        let examine6 = SSExamine.init(withArray: M6, name: nil, characterSet: nil)
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
        let setA1 = SSExamine.init(withArray: A1, name: nil, characterSet: nil)
        let setB1 = SSExamine.init(withArray: B1, name: nil, characterSet: nil)
        let setA2 = SSExamine.init(withArray: A2, name: nil, characterSet: nil)
        let setB2 = SSExamine.init(withArray: B2, name: nil, characterSet: nil)
        var array = Array<SSExamine<Double>>()
        array.append(setA1)
        array.append(setB1)
        array.append(setA2)
        array.append(setB2)
        var htest: SSKruskalWallisHTestResult;
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
        let setA1 = SSExamine.init(withArray: A1, name: nil, characterSet: nil)
        let setB1 = SSExamine.init(withArray: B1, name: nil, characterSet: nil)
        let setA2 = SSExamine.init(withArray: A2, name: nil, characterSet: nil)
        let setB2 = SSExamine.init(withArray: B2, name: nil, characterSet: nil)
        var mw = try! SSHypothesisTesting.mannWhitneyUTest(set1: setA1, set2: setB1)
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
        let setM7 = SSExamine.init(withArray: M7, name: nil, characterSet: nil)
        let setM8 = SSExamine.init(withArray: M8, name: nil, characterSet: nil)
        mw = try! SSHypothesisTesting.mannWhitneyUTest(set1: setM7, set2: setM8)
        XCTAssertEqual(mw.p2Approx!, 0.125, accuracy: 1E-3)
        XCTAssertEqual(mw.zStat!, 1.5341, accuracy: 1E-3)
    }
    
    func testFrequencies() {
        let characters = ["A", "A", "A", "B", "B", "B","C","C","C"]
        let c:SSExamine<String> = try! SSExamine<String>.init(withObject: characters, levelOfMeasurement: .nominal, name: nil, characterSet: nil)
        XCTAssertEqual(1.0 / 3.0, c.rFrequency("A"))
        XCTAssertEqual(1.0 / 3.0, c.rFrequency("B"))
        XCTAssertEqual(1.0 / 3.0, c.rFrequency("C"))
        XCTAssertEqual(0, c.rFrequency("!"))
        XCTAssertEqual(1.0 / 3.0, c.eCDF("A"))
        XCTAssertEqual(2.0 / 3.0, c.eCDF("B"))
        XCTAssertEqual(3.0 / 3.0, c.eCDF("C"))
    }
    
    func testAutocorrelation() {
        let examine = SSExamine<Double>.init(withArray: lewData, name: nil, characterSet: nil)
        let boxljung = try! SSHypothesisTesting.autocorrelation(data: examine)
        if let a = boxljung.coefficients {
            XCTAssertEqual(a[1], -0.31, accuracy: 1E-2)
        }
        XCTAssertEqual(try! SSHypothesisTesting.autocorrelationCoefficient(data: examine, lag: 1), -0.31, accuracy: 1E-2)
        
        var runsTest: SSRunsTestResult
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
        let set1 = SSExamine.init(withArray: M1, name: nil, characterSet: nil)
        let set2 = SSExamine.init(withArray: M2, name: nil, characterSet: nil)
        let ww: SSWaldWolfowitzTwoSampleTestResult = try! SSHypothesisTesting.waldWolfowitzTwoSampleTest(set1: set1, set2: set2)
        XCTAssertEqual(ww.pValueAsymp!, 0.01512, accuracy: 1E-5)
        XCTAssertEqual(ww.zStat!, 2.4296, accuracy: 1E-4)
    }
    
    func testTTest()  {
        var examine1: SSExamine<Double>! = nil
        var examine2: SSExamine<Double>! = nil
        var examine3: SSExamine<Double>! = nil
        #if os(macOS) || os(iOS)
        examine1 = try! SSExamine<Double>.examine(fromFile: resPath + "/NormalData01.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        examine1.name = "Normal_01"
        examine2 = try! SSExamine<Double>.examine(fromFile: resPath + "/NormalData02.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        examine1.name = "Normal_02"
        examine3 = try! SSExamine<Double>.examine(fromFile: resPath + "/NormalData03.examine", separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        examine1.name = "Normal_03"
        #else
        if let p = linuxResourcePath(resource: "NormalData01", type: "examine") {
            examine1 = try! SSExamine<Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        }
        examine1.name = "Normal_01"
        if let p = linuxResourcePath(resource: "NormalData02", type: "examine") {
            examine2 = try! SSExamine<Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        }
        examine1.name = "Normal_02"
        if let p = linuxResourcePath(resource: "NormalData03", type: "examine") {
            examine3 = try! SSExamine<Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, scanDouble)!
        }
        examine1.name = "Normal_03"
        #endif
        var ttestResult = try! SSHypothesisTesting.twoSampleTTest(sample1: examine1, sample2: examine2, alpha: 0.05)
        XCTAssertEqual(ttestResult.p2Welch!, 0.366334, accuracy: 1E-6)
        
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
        var ds1: SSDataFrame<Double>! = nil
        #if os(macOS) || os(iOS)
        ds1 = try! SSDataFrame<Double>.dataFrame(fromFile: resPath + "/geardata.csv", scanDouble)
        #else
        if let p = linuxResourcePath(resource: "geardata", type: "csv") {
            ds1 = try! SSDataFrame<Double>.dataFrame(fromFile: p, scanDouble)
        }
        #endif
        var multipleMeansRes = try! SSHypothesisTesting.multipleMeansTest(dataFrame: ds1, alpha: 0.05)!
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
        
        var chiResult: SSChiSquareVarianceTestResult
        chiResult = try! SSHypothesisTesting.chiSquareVarianceTest(array: normal3, nominalVariance: 9.0 / 4.0, alpha: 0.05)!
        XCTAssertEqual(chiResult.p1Value!, 0.242166, accuracy: 1E-6)
        
        chiResult = try! SSHypothesisTesting.chiSquareVarianceTest(array: normal3, nominalVariance: 8.0 / 5.0, alpha: 0.05)!
        XCTAssertEqual(chiResult.p1Value!, 0.000269792, accuracy: 1E-9)
        
        var ftestRes: SSFTestResult
        ftestRes = try! SSHypothesisTesting.fTestVarianceEquality(data1: normal1, data2: normal2, alpha: 0.05)
        XCTAssertEqual(ftestRes.p1Value!, 0.000519142, accuracy: 1E-9)
        
        ftestRes = try! SSHypothesisTesting.fTestVarianceEquality(data1: normal1, data2: normal3, alpha: 0.05)
        XCTAssertEqual(ftestRes.p1Value!, 1.43217E-6, accuracy: 1E-9)
        
        ftestRes = try! SSHypothesisTesting.fTestVarianceEquality(data1: normal2, data2: normal3, alpha: 0.05)
        XCTAssertEqual(ftestRes.p1Value!, 0.0736106, accuracy: 1E-7)
    }
    
    func testKStest() {
        let normal = try! SSExamine<Double>.init(withObject: normal1, levelOfMeasurement: .interval, name: nil, characterSet: nil)
        normal.name = "Normal Distribution"
        
        let laplace = try! SSExamine<Double>.init(withObject: laplaceData, levelOfMeasurement: .interval, name: nil, characterSet: nil)
        laplace.name = "Laplace Distribution"
        
        var res: SSKSTestResult = try! SSHypothesisTesting.ksGoFTest(array: normal.elementsAsArray(sortOrder: .raw)!, targetDistribution: .gaussian)!
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
    
    func testDistributions() {
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
        /* noncentral PDF
         R code:
         > dt(x = -10, ncp = 3, df = 22)
         [1] 9.281464e-15
         > dt(x = 0, ncp = 3, df = 22)
         [1] 0.004381789
         > dt(x = 2.5, ncp = 3, df = 22)
         [1] 0.3346016
         > dt(x = 10, ncp = 3, df = 22)
         [1] 3.549312e-05
         > dt(x = -10, ncp = 10, df = 22)
         [1] 3.810285e-14
         > dt(x = 0, ncp = 10, df = 22)
         [1] 7.607685e-23
         > dt(x = 2.5, ncp = 10, df = 22)
         [1] 1.214813e-11
         > dt(x = 10, ncp = 10, df = 2)
         [1] 0.07213699
        */
        XCTAssertEqual(try! pdfStudentTNonCentral(x: -10, nonCentralityPara: 3, degreesOfFreedom: 22), 9.281464e-15, accuracy: 1E-20)
        XCTAssertEqual(try! pdfStudentTNonCentral(x: 0, nonCentralityPara: 3, degreesOfFreedom: 22), 0.004381789, accuracy: 1E-9)
        XCTAssertEqual(try! pdfStudentTNonCentral(x: 2.5, nonCentralityPara: 3, degreesOfFreedom: 22), 0.3346016, accuracy: 1E-7)
        XCTAssertEqual(try! pdfStudentTNonCentral(x: 10, nonCentralityPara: 3, degreesOfFreedom: 2), 0.01746092, accuracy: 1E-9)
        XCTAssertEqual(try! pdfStudentTNonCentral(x: -10, nonCentralityPara: 10, degreesOfFreedom: 22), 3.810285e-14, accuracy: 1E-14)
        XCTAssertEqual(try! pdfStudentTNonCentral(x: 0, nonCentralityPara: 10, degreesOfFreedom: 22), 7.607685e-23, accuracy: 1E-27)
        XCTAssertEqual(try! pdfStudentTNonCentral(x: 2.5, nonCentralityPara: 10, degreesOfFreedom: 22), 1.214813e-11, accuracy: 1E-16)
        XCTAssertEqual(try! pdfStudentTNonCentral(x: 10, nonCentralityPara: 10, degreesOfFreedom: 2), 0.07213699, accuracy: 1E-8)
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
        XCTAssertEqual(try! cdfStudentTNonCentral(t: -10, nonCentralityPara: 3, degreesOfFreedom: 22), 1.479927e-13, accuracy: 1E-19)
        XCTAssertEqual(try! cdfStudentTNonCentral(t: 0, nonCentralityPara: 3, degreesOfFreedom: 22), 0.001349898, accuracy: 1E-9)
        XCTAssertEqual(try! cdfStudentTNonCentral(t: 2.5, nonCentralityPara: 3, degreesOfFreedom: 22), 0.3101249, accuracy: 1E-7)
        XCTAssertEqual(try! cdfStudentTNonCentral(t: 10, nonCentralityPara: 3, degreesOfFreedom: 2), 0.9065271, accuracy: 1E-7)
        XCTAssertEqual(try! cdfStudentTNonCentral(t: -10, nonCentralityPara: 10, degreesOfFreedom: 22), 1.382228e-13, accuracy: 1E-14)
        XCTAssertEqual(try! cdfStudentTNonCentral(t: 0, nonCentralityPara: 10, degreesOfFreedom: 22), 7.619853e-24, accuracy: 1E-27)
        XCTAssertEqual(try! cdfStudentTNonCentral(t: 2.5, nonCentralityPara: 10, degreesOfFreedom: 22), 1.301945e-12, accuracy: 1E-16)
        XCTAssertEqual(try! cdfStudentTNonCentral(t: 10, nonCentralityPara: 10, degreesOfFreedom: 2), 0.3714677, accuracy: 1E-7)
        XCTAssertEqual(try! cdfStudentTNonCentral(t: 10, nonCentralityPara: 10, degreesOfFreedom: 223322), 0.4999955, accuracy: 1E-7)
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


    }
    
//
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//        }
//    }
    
}

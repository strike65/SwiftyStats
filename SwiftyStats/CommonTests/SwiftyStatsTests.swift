//
//  SwiftyStatsTests.swift
//  SwiftyStatsTests
//
//  Created by strike65 on 17.07.17.
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
        //        let df: SSDataFrame<Double, Double> = try! SSDataFrame.dataFrame(fromFile: resPath + "/TukeyKramerData_01.csv", Helpers.NumberScanner.scanDouble)
        let df1: SSDataFrame<Double, Double> = try! SSDataFrame.dataFrame(fromFile: resPath + "/TukeyKramerData_02.csv", Helpers.NumberScanner.scanDouble)
        #else
        let df: SSDataFrame<Double, Double>  = try! SSDataFrame.dataFrame(fromString: TukeyKramerData_01String, parser: Helpers.NumberScanner.scanDouble)
        let df1: SSDataFrame<Double, Double>  = try! SSDataFrame.dataFrame(fromString: TukeyKramerData_02String, parser: Helpers.NumberScanner.scanDouble)
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
        let test = try! SSHypothesisTesting.tukeyKramerTest(dataFrame: df1, alpha: 0.05)!
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
            examineInt = try SSExamine<Int, Double>.examine(fromFile: resPath + "/IntData.examine", separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanInt)!
            examineIntOutliers = try SSExamine<Int, Double>.examine(fromFile: resPath + "/IntDataWithOutliers.examine", separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanInt)!
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
                examineInt = try SSExamine<Int>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanInt)!
            }
            else {
                fatalError("No testfiles " + #file + "\(#line)")
            }
            if let p = linuxResourcePath(resource: "IntDataWithOutliers", type: "examine") {
                examineIntOutliers = try SSExamine<Int>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanInt)!
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
                if let testExamineInt = try SSExamine<Int, Double>.examine(fromFile: p, separator: ",", stringEncoding: .utf8, Helpers.NumberScanner.scanInt) {
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
        //        print(examineInt.elementsAsString(withDelimiter: ",", asRow: false)!)
        XCTAssert(examineInt.elementsAsArray(sortOrder: .raw)! == intData)
        XCTAssert(examineInt.elementsAsArray(sortOrder: .ascending)! != intData)
        XCTAssert(examineInt.elementsAsArray(sortOrder: .descending)! != intData)
        var examineDouble: SSExamine<Double, Double>! = nil
        var examineString: SSExamine<String, Double>! = nil
        do {
            #if os(macOS) || os(iOS)
            examineDouble = try SSExamine<Double, Double>.examine(fromFile: resPath + "/DoubleData.examine", separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanDouble)
            #else
            if let p = linuxResourcePath(resource: "DoubleData", type: "examine") {
                examineDouble = try SSExamine<Double, Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanDouble)
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
        examineDouble.alpha = 0.05
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
        XCTAssert(!examineDouble.isGaussian!)
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
            df2 = try SSDataFrame<Double, Double>.dataFrame(fromFile: resPath + "test.csv", separator: ",", firstRowContainsNames: true, stringEncoding: String.Encoding.utf16, Helpers.NumberScanner.scanDouble)
            #else
            df2 = try SSDataFrame<Double, Double>.dataFrame(fromFile: "test.csv", separator: ",", firstRowContainsNames: true, stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanDouble)
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
            print(url!.path)
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
        do {
            exa1 = try SSExamine<Double, Double>.examine(fromFile: resPath + "/NormalData01.examine", separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanDouble)!
        }
        catch {
            print(resPath + "/NormalData01.examine")
        }
        #else
        if let p = linuxResourcePath(resource: "NormalData01", type: "examine") {
            exa1 = try! SSExamine<Double, Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanDouble)!
        }
        #endif
        print("==============!!!!!!!!!!!!!!!!!!!================")
        exa1.name = "Normal_01"
        #if os(macOS) || os(iOS)
        exa2 = try! SSExamine<Double, Double>.examine(fromFile: resPath + "/NormalData02.examine", separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanDouble)!
        #else
        if let p = linuxResourcePath(resource: "NormalData02", type: "examine") {
            exa2 = try! SSExamine<Double, Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanDouble)!
        }
        #endif
        exa2.name = "Normal_02"
        #if os(macOS) || os(iOS)
        exa3 = try! SSExamine<Double, Double>.examine(fromFile: resPath + "/NormalData03.examine", separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanDouble)!
        #else
        if let p = linuxResourcePath(resource: "NormalData03", type: "examine") {
            exa3 = try! SSExamine<Double, Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanDouble)!
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
        df2 = try! SSDataFrame<Double, Double>.dataFrame(fromFile: resPath + "/normal.csv", separator: ",", firstRowContainsNames: true, stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanDouble)
        #else
        df2 = try! SSDataFrame<Double, Double>.dataFrame(fromFile: "normal.csv", separator: ",", firstRowContainsNames: true, stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanDouble)
        #endif
        XCTAssert(df.isEqual(df2))
        #if os(macOS) || os(iOS)
        let df3 = try! SSDataFrame<String, Double>.dataFrame(fromFile: resPath + "/normal.csv", separator: ",", firstRowContainsNames: true, stringEncoding: .utf8, Helpers.NumberScanner.scanString)
        #else
        let df3 = try! SSDataFrame<String>.dataFrame(fromFile: "normal.csv", separator: ",", firstRowContainsNames: true, stringEncoding: .utf8, Helpers.NumberScanner.scanString)
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
        //        var g5: SSExamine<Double, Double>! = nil
        //        var g6: SSExamine<Double, Double>! = nil
        //        #if os(macOS) || os(iOS)
        //        g5 = try! SSExamine<Double, Double>.examine(fromFile: resPath + "/largeNormal_01.examine", separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanDouble)!
        //        g6 = try! SSExamine<Double, Double>.examine(fromFile: resPath + "/largeNormal_02.examine", separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanDouble)!
        //        #else
        //        if let p = linuxResourcePath(resource: "largeNormal_01", type: "examine") {
        //            g5 = try! SSExamine<Double, Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanDouble)!
        //        }
        //        if let p = linuxResourcePath(resource: "largeNormal_02", type: "examine") {
        //            g6 = try! SSExamine<Double, Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanDouble)!
        //        }
        //        #endif
        //        res = try! SSHypothesisTesting.signTest(set1: g5, set2: g6)
        //        XCTAssertEqual(res.zStat!, -2.7511815643464903, accuracy: 1E-7)
        //        XCTAssertEqual(res.pValueExact!, 0.00295538, accuracy: 1E-6)
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
        XCTAssertEqual(htest.H_value!, 11.53, accuracy: 1E-2)
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
        examine1 = try! SSExamine<Double, Double>.examine(fromFile: resPath + "/NormalData01.examine", separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanDouble)!
        examine1.name = "Normal_01"
        examine2 = try! SSExamine<Double, Double>.examine(fromFile: resPath + "/NormalData02.examine", separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanDouble)!
        examine1.name = "Normal_02"
        examine3 = try! SSExamine<Double, Double>.examine(fromFile: resPath + "/NormalData03.examine", separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanDouble)!
        examine1.name = "Normal_03"
        #else
        if let p = linuxResourcePath(resource: "NormalData01", type: "examine") {
            examine1 = try! SSExamine<Double, Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanDouble)!
        }
        examine1.name = "Normal_01"
        if let p = linuxResourcePath(resource: "NormalData02", type: "examine") {
            examine2 = try! SSExamine<Double, Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanDouble)!
        }
        examine1.name = "Normal_02"
        if let p = linuxResourcePath(resource: "NormalData03", type: "examine") {
            examine3 = try! SSExamine<Double, Double>.examine(fromFile: p, separator: ",", stringEncoding: String.Encoding.utf8, Helpers.NumberScanner.scanDouble)!
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
        ds1 = try! SSDataFrame<Double, Double>.dataFrame(fromFile: resPath + "/geardata.csv", Helpers.NumberScanner.scanDouble)
        #else
        if let p = linuxResourcePath(resource: "geardata", type: "csv") {
            ds1 = try! SSDataFrame<Double, Double>.dataFrame(fromFile: p, Helpers.NumberScanner.scanDouble)
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
        
        // R:
        // normalData <- c(-1.39472,0.572422,-0.807981,1.12284,0.582314,-2.02361,-1.07106,-1.07723,0.105198,-0.806512,-1.47555,0.117081,-0.40699,-0.554643,-0.0838551,-2.38265,-0.748096,1.13259,0.134903,-1.11957,-0.268167,-0.249893,-0.636138,0.411145,1.40698,0.868583,0.221741,-0.751367,-0.843731,-1.92446,-0.770097,1.34406,0.113856,0.442025,0.206676,0.448239,0.701375,-1.50239,0.118701,0.992643,0.119639,-0.0365253,0.205961,-0.37079,-0.224489,-0.428072,0.911177,-0.279192,0.560748,-0.24796,-1.05229,2.03458,-2.02889,-1.08878,-0.826172,0.381449,-0.134957,-0.07598,-1.03606,1.65422,-0.290542,0.221982,0.0674381,-0.32888,1.59649,0.418209,-0.899435,0.329175,-0.177973,1.62596,0.599629,-1.5299,-2.18709,0.297174,0.997437,1.55026,0.857938,0.177222,1.62641,-0.982871,0.307966,-0.518949,2.34573,-0.17761,2.3379,0.598934,-0.727655,0.320675,1.5864,0.0940648,0.350143,-0.617015,0.839371,0.224846,0.0201539,-1.49075,0.847894,-0.790432,1.80993,1.32279,0.141171,-1.14471,0.601558,0.678619,-0.45809,0.312201,1.3017,0.0407581,0.993514,0.931535,1.13858)
        // ks.test(normalData, "pnorm",mean(doubleData), sd(doubleData), exact = "true")
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
            marcumRes = SSSpecialFunctions.marcum(mys[i-1], sqrt(2 * x1[i-1]), sqrt(2 * y1[i-1]))
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
                    marcumRes = SSSpecialFunctions.marcum(mu, sqrt(2 * x), sqrt(2 * y))
                    p0 = marcumRes.p
                    q0 = marcumRes.q
                    ierr1 = marcumRes.err
                    marcumRes = SSSpecialFunctions.marcum(mu - 1.0, sqrt(2 * x), sqrt(2 * y))
                    pm1 = marcumRes.p
                    qm1 = marcumRes.q
                    ierr2 = marcumRes.err
                    marcumRes = SSSpecialFunctions.marcum(mu + 1, sqrt(2 * x), sqrt(2 * y))
                    p1 = marcumRes.p
                    q1 = marcumRes.q
                    ierr1 = marcumRes.err
                    marcumRes = SSSpecialFunctions.marcum(mu + 2, sqrt(2 * x), sqrt(2 * y))
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
        XCTAssert(d0 < 1e-12)
        print("Maximum value of the recurrence check = \(d0)")
    }
    
    
    func testQuick() {
        //        let z: Complex<Double> = Complex<Double>(-3.0,4.0)
        //        let g: Complex<Double> = SSMath.tgamma1(z: z)
        //        var a: Array<Complex<Double>> = Array<Complex<Double>>.init()
        //        var b: Array<Complex<Double>> = Array<Complex<Double>>.init()
        //        a.append(Complex<Double>.init(re: 3, im: 0))
        //        a.append(Complex<Double>.init(re: 4, im: 0))
        //        b.append(Complex<Double>.init(re: 1, im: 0))
        //        z = Complex<Double>.init(re: 3, im: 0)
        //        var hg: Complex<Double> = try! hypergeometricPFQ(a: a, b: b, z: z)
        //        var i: Int = 0
        //        var maxError: Float80 = 0.0
        //        var error: Float80 = 0.0
        //        var test: Float80
        //        var test1: Float80
        //        var errX: Float80 = 0.0
        //        var errMinX: Float80 = 0.0
        //        var minErr: Float80 = 1.0
        //        var x: Float80 = 0
        //        while i < besselJ0_0_8.count {
        //            test = besselJ0l(x: x)
        //            test1 = besselJ0_0_8[i]
        //            error = abs(test - test1)
        //            if i == 0 {
        //                minErr = error
        //                errMinX = x
        //            }
        //            print(error)
        //            if error > maxError {
        //                maxError = error
        //                errX = x
        //            }
        //            else if error < minErr {
        //                minErr = error
        //                errMinX = x
        //            }
        //            x = x + 0.01
        //            i = i + 1
        //        }
        //        print("*****************************************************")
        //        print("MaxError: \(maxError) at \(errX)")
        //        print("MinError: \(minErr) at \(errMinX)")
        //        i = 0
        //        maxError = 0.0
        //        error = 0.0
        //        errX = 0.0
        //        x = -15.99
        //        while i < besselJ0_8_16.count {
        //            test = besselJ0l(x: x)
        //            test1 = besselJ0_8_16[i]
        //            error = abs(test - test1)
        //            if error > maxError {
        //                maxError = error
        //                errX = x
        //            }
        //            print(error)
        //            x = x + 0.01
        //            i = i + 1
        //        }
        //        print("*****************************************************")
        //        print("MaxError: \(maxError) at \(errX)")
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
        para = try! SSProbDist.StudentT.para(degreesOfFreedom: 21)
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
        XCTAssertEqual(try! SSProbDist.StudentT.pdf(t: -10, degreesOfFreedom: 22), 1.098245e-09, accuracy: 1E-10)
        XCTAssertEqual(try! SSProbDist.StudentT.pdf(t: 0, degreesOfFreedom: 22), 0.394436, accuracy: 1E-5)
        XCTAssertEqual(try! SSProbDist.StudentT.pdf(t: 2.5, degreesOfFreedom: 22), 0.02223951, accuracy: 1E-5)
        XCTAssertEqual(try! SSProbDist.StudentT.pdf(t: 10, degreesOfFreedom: 2), 0.0009707329, accuracy: 1E-10)
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
        XCTAssertEqual(try! SSProbDist.StudentT.cdf(t: -10, degreesOfFreedom: 22), 6.035806e-10, accuracy: 1E-15)
        XCTAssertEqual(try! SSProbDist.StudentT.cdf(t: 0, degreesOfFreedom: 22), 0.5)
        XCTAssertEqual(try! SSProbDist.StudentT.cdf(t: 2.5, degreesOfFreedom: 22), 0.9898164, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.StudentT.cdf(t: 10, degreesOfFreedom: 2), 0.9950738, accuracy: 1E-7)
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
        para = try! SSProbDist.NonCentralSudentT.para(degreesOfFreedom: 21, nonCentralityPara: 3)
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
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.pdf(x: -10,  degreesOfFreedom: 22, nonCentralityPara: 3), 1.61220211703878172128e-16, accuracy: 1E-18)
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.pdf(x: 0, degreesOfFreedom: 22, nonCentralityPara: 3), 0.00438178866867118877565, accuracy: 1E-12)
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.pdf(x: 2.5, degreesOfFreedom: 22, nonCentralityPara: 3), 0.334601573269501746166, accuracy: 1E-12)
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.pdf(x: 10, degreesOfFreedom: 22, nonCentralityPara: 3), 0.0000354931204704236583089, accuracy: 1E-12)
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.pdf(x: 1, degreesOfFreedom: 22, nonCentralityPara: 10), 2.86089002661815955619e-18, accuracy: 1E-18)
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.pdf(x: 0, degreesOfFreedom: 22, nonCentralityPara: 10), 7.60768463597592483354e-23, accuracy: 1E-27)
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.pdf(x: 2.5, degreesOfFreedom: 22, nonCentralityPara: 10), 1.21515039938564508949e-11, accuracy: 1E-12)
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.pdf(x: 10, degreesOfFreedom: 22, nonCentralityPara: 10), 0.218713193594618197003, accuracy: 1E-12)
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
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.cdf(t: -10, degreesOfFreedom: 22, nonCentralityPara: 3), 8.14079530286125822663e-17, accuracy: 1E-19)
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.cdf(t: 0, degreesOfFreedom: 22, nonCentralityPara: 3), 0.00134989803163009452665, accuracy: 1E-9)
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.cdf(t: 2.5, degreesOfFreedom: 22, nonCentralityPara: 3), 0.310124866777693411844, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.cdf(t: 10, degreesOfFreedom: 22, nonCentralityPara: 3), 0.999976994489342241050, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.cdf(t: -10, degreesOfFreedom: 22, nonCentralityPara: 10), 4.39172441491830770359e-44, accuracy: 1E-48)
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.cdf(t: 0, degreesOfFreedom: 22, nonCentralityPara: 10), 7.61985302416052606597e-24, accuracy: 1E-27)
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.cdf(t: 2, degreesOfFreedom: 22, nonCentralityPara: 10), 1.00316897649437185093e-14, accuracy: 1E-23)
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.cdf(t: 2.5, degreesOfFreedom: 22, nonCentralityPara: 10), 1.30289935752455767687e-12, accuracy: 1E-16)
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.cdf(t: 10, degreesOfFreedom: 22, nonCentralityPara: 10), 0.469124289769452233227, accuracy: 1E-14)
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
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.quantile(p: 0, degreesOfFreedom: 21, nonCentralityPara: 3), -Double.infinity)
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.quantile(p: 0.25, degreesOfFreedom: 21, nonCentralityPara: 3), 2.312281, accuracy: 1e-6)
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.quantile(p: 0.5, degreesOfFreedom: 21, nonCentralityPara: 3), 3.038146, accuracy: 1e-6)
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.quantile(p: 0.75, degreesOfFreedom: 21, nonCentralityPara: 3), 3.82973, accuracy: 1e-6)
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.quantile(p: 0.99, degreesOfFreedom: 21, nonCentralityPara: 3), 6.238628, accuracy: 1e-6)
        XCTAssertEqual(try! SSProbDist.NonCentralSudentT.quantile(p: 1, degreesOfFreedom: 21, nonCentralityPara: 3), Double.infinity)
        /*
         nd = NormalDistribution[3, 1/2];
         N[Kurtosis[nd], 21]
         N[Mean[nd], 21]
         N[Skewness[nd], 21]
         N[Variance[nd], 21]
         */
        para = SSProbDist.Gaussian.para(mean: 2, standardDeviation: 0.5)
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
        XCTAssertEqual(try! SSProbDist.Gaussian.cdf(x: 2, mean: 0, variance: 1), 0.977249868, accuracy: 1E-8)
        XCTAssertEqual(SSProbDist.StandardNormal.cdf(u: 2), 0.977249868, accuracy: 1E-8)
        XCTAssertEqual(SSProbDist.StandardNormal.cdf(u: -2), 0.0227501319, accuracy: 1E-8)
        XCTAssertEqual(try! SSProbDist.Gaussian.cdf(x: 3, mean: 22, standardDeviation: 3), 1.19960226E-10, accuracy: 1E-18)
        XCTAssertEqual(try! SSProbDist.Gaussian.cdf(x: -3, mean: 22, standardDeviation: 3), 3.92987343E-17, accuracy: 1E-25)
        XCTAssertEqual(try! SSProbDist.Gaussian.cdf(x: -3, mean: -3.5, standardDeviation: 0.5), 0.841344746, accuracy: 1E-9)
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
        XCTAssertEqual(try! SSProbDist.Gaussian.pdf(x: 2, mean: 0, variance: 1), 0.0539909665, accuracy: 1E-8)
        XCTAssertEqual(SSProbDist.StandardNormal.pdf(u: 2), 0.0539909665, accuracy: 1E-8)
        XCTAssertEqual(SSProbDist.StandardNormal.pdf(u: -2), 0.0539909665, accuracy: 1E-8)
        XCTAssertEqual(try! SSProbDist.Gaussian.pdf(x: 3, mean: 22, standardDeviation: 3), 2.59281602E-10, accuracy: 1E-18)
        XCTAssertEqual(try! SSProbDist.Gaussian.pdf(x: -3, mean: 22, standardDeviation: 3), 1.10692781E-16, accuracy: 1E-23)
        XCTAssertEqual(try! SSProbDist.Gaussian.pdf(x: -3, mean: -3.5, standardDeviation: 0.5), 0.483941449, accuracy: 1E-9)
        
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
        XCTAssertEqual(try! SSProbDist.StandardNormal.quantile(p: 1.0/3.0), -0.430727, accuracy: 1E-6)
        XCTAssertEqual(try! SSProbDist.StandardNormal.quantile(p: 5.0/100.0), -1.64485, accuracy: 1E-5)
        XCTAssertEqual(try! SSProbDist.StandardNormal.quantile(p: 5.0/10.0), 0, accuracy: 1E-6)
        XCTAssertEqual(try! SSProbDist.Gaussian.quantile(p: 1.0/3.0, mean: 2, standardDeviation: 0.5), 1.78464, accuracy: 1E-4)
        XCTAssertEqual(try! SSProbDist.Gaussian.quantile(p: 5/100.0, mean: 2, standardDeviation: 0.5), 1.17757, accuracy: 1E-4)
        XCTAssertEqual(try! SSProbDist.Gaussian.quantile(p: 5/10.0, mean: 2, standardDeviation: 0.5), 2, accuracy: 1E-6)
        /*
         df = 11;
         chd = ChiSquareDistribution[df];
         N[Mean[chd], 21]
         N[Variance[chd], 21]
         N[Skewness[chd], 21]
         N[Kurtosis[chd], 21]
         */
        para = try! SSProbDist.ChiSquare.para(degreesOfFreedom: 11)
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
        XCTAssertEqual(try! SSProbDist.ChiSquare.cdf(chi: 1, degreesOfFreedom: 16), 6.219691E-08, accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.ChiSquare.cdf(chi: -1, degreesOfFreedom: 16), 0, accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.ChiSquare.cdf(chi: 16, degreesOfFreedom: 16), 0.5470392, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.ChiSquare.cdf(chi: -16, degreesOfFreedom: 16), 0, accuracy: 1E-7)
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
        
        XCTAssertEqual(try! SSProbDist.ChiSquare.pdf(chi: 1, degreesOfFreedom: 16), 4.700913e-07, accuracy: 1E-13)
        XCTAssertEqual(try! SSProbDist.ChiSquare.pdf(chi: -1, degreesOfFreedom: 16), 0, accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.ChiSquare.pdf(chi: 16, degreesOfFreedom: 16), 0.06979327, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.ChiSquare.pdf(chi: -16, degreesOfFreedom: 16), 0, accuracy: 1E-7)
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
        XCTAssertEqual(try! SSProbDist.ChiSquare.quantile(p: 0, degreesOfFreedom: 16), 0, accuracy: 1E-13)
        XCTAssertEqual(try! SSProbDist.ChiSquare.quantile(p: 0.25, degreesOfFreedom: 16), 11.91222, accuracy: 1E-5)
        XCTAssertEqual(try! SSProbDist.ChiSquare.quantile(p: 0.5, degreesOfFreedom: 16), 15.3385, accuracy: 1E-4)
        XCTAssertEqual(try! SSProbDist.ChiSquare.quantile(p: 0.75, degreesOfFreedom: 16), 19.36886, accuracy: 1E-5)
        XCTAssertEqual(try! SSProbDist.ChiSquare.quantile(p: 0.99, degreesOfFreedom: 16), 31.99993, accuracy: 1E-5)
        XCTAssert(try! SSProbDist.ChiSquare.quantile(p: 1.0, degreesOfFreedom: 16).isInfinite)
        
        
        /*
         df1 = 4;
         df2 = 9;
         fd = FRatioDistribution[df1, df2];
         N[Mean[fd], 21]
         N[Variance[fd], 21]
         N[Skewness[fd], 21]
         N[Kurtosis[fd], 21]
         */
        para = try! SSProbDist.FRatio.para(numeratorDF: 4, denominatorDF: 9)
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
        XCTAssertEqual(try! SSProbDist.FRatio.cdf(f: 2, numeratorDF: 2, denominatorDF: 3), 0.7194341, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.FRatio.cdf(f: 2, numeratorDF: 22, denominatorDF: 3), 0.6861387, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.FRatio.cdf(f: 2, numeratorDF: 3, denominatorDF: 22), 0.8565898, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.FRatio.cdf(f: -2, numeratorDF: 3, denominatorDF: 22), 0, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.FRatio.cdf(f: 0, numeratorDF: 3, denominatorDF: 22), 0, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.FRatio.cdf(f: 33, numeratorDF: 3, denominatorDF: 22), 1, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.FRatio.cdf(f: 3, numeratorDF: 3, denominatorDF: 22), 0.9475565, accuracy: 1E-7)
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
        XCTAssertEqual(try! SSProbDist.FRatio.pdf(f: 2, numeratorDF: 2, denominatorDF: 3), 0.1202425, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.FRatio.pdf(f: 2, numeratorDF: 22, denominatorDF: 3), 0.1660825, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.FRatio.pdf(f: 2, numeratorDF: 3, denominatorDF: 22), 0.1486917, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.FRatio.pdf(f: -2, numeratorDF: 3, denominatorDF: 22), 0, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.FRatio.pdf(f: 0, numeratorDF: 3, denominatorDF: 22), 0, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.FRatio.pdf(f: 33, numeratorDF: 3, denominatorDF: 22), 6.849943e-09, accuracy: 1E-15)
        XCTAssertEqual(try! SSProbDist.FRatio.pdf(f: 3, numeratorDF: 3, denominatorDF: 22), 0.05102542, accuracy: 1E-7)
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
        XCTAssertEqual(try! SSProbDist.FRatio.quantile(p: 0, numeratorDF: 2, denominatorDF: 3), 0, accuracy: 0)
        XCTAssertEqual(try! SSProbDist.FRatio.quantile(p: 0.25, numeratorDF: 2, denominatorDF: 3), 0.3171206, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.FRatio.quantile(p: 0.5, numeratorDF: 2, denominatorDF: 3), 0.8811016, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.FRatio.quantile(p: 0.75, numeratorDF: 2, denominatorDF: 3), 2.279763, accuracy: 1E-6)
        XCTAssertEqual(try! SSProbDist.FRatio.quantile(p: 0.99, numeratorDF: 2, denominatorDF: 3), 30.81652, accuracy: 1E-5)
        XCTAssertEqual(try! SSProbDist.FRatio.quantile(p: 0.25, numeratorDF: 22, denominatorDF: 3), 0.6801509, accuracy: 1E-6)
        XCTAssertEqual(try! SSProbDist.FRatio.quantile(p: 0.5, numeratorDF: 22, denominatorDF: 3), 1.229022, accuracy: 1E-6)
        XCTAssertEqual(try! SSProbDist.FRatio.quantile(p: 0.75, numeratorDF: 22, denominatorDF: 3), 2.461528, accuracy: 1E-6)
        XCTAssertEqual(try! SSProbDist.FRatio.quantile(p: 0.99, numeratorDF: 22, denominatorDF: 3), 26.63955, accuracy: 1E-5)
        XCTAssert(try! SSProbDist.FRatio.quantile(p: 1.0, numeratorDF: 22, denominatorDF: 3).isInfinite)
        /*
         df1 = 4;
         df2 = 9;
         fd = FRatioDistribution[df1, df2];
         N[Mean[fd], 21]
         N[Variance[fd], 21]
         N[Skewness[fd], 21]
         N[Kurtosis[fd], 21]
         */
        para = try! SSProbDist.LogNormal.para(mean: 3, variance: 0.25)
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
        XCTAssertEqual(try! SSProbDist.LogNormal.cdf(x: 1, mean: 0, variance: 1), 0.5, accuracy: 1E-1)
        XCTAssertEqual(try! SSProbDist.LogNormal.cdf(x: 1, mean: 0, variance: 0.25), 0.5, accuracy: 1E-1)
        XCTAssertEqual(try! SSProbDist.LogNormal.cdf(x: 2, mean: 0, variance: 0.25), 0.9171715, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.LogNormal.cdf(x: 2, mean: 3, variance: 0.25), 1.977763E-06, accuracy: 1E-12)
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
        XCTAssertEqual(try! SSProbDist.LogNormal.pdf(x: 1, mean: 0, variance: 1), 0.3989423, accuracy: 1E-6)
        XCTAssertEqual(try! SSProbDist.LogNormal.pdf(x: 1, mean: 0, variance: 0.25), 0.7978846, accuracy: 1E-6)
        XCTAssertEqual(try! SSProbDist.LogNormal.pdf(x: 2, mean: 0, variance: 0.25), 0.1526138, accuracy: 1E-6)
        XCTAssertEqual(try! SSProbDist.LogNormal.pdf(x: 2, mean: 3, variance: 0.25), 9.520355e-06, accuracy: 1E-12)
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
        XCTAssertEqual(try! SSProbDist.LogNormal.quantile(p: 0, mean: 0, variance: 1), 0, accuracy: 0)
        XCTAssertEqual(try! SSProbDist.LogNormal.quantile(p: 0.25, mean: 0, variance: 1), 0.5094163, accuracy: 1E-6)
        XCTAssertEqual(try! SSProbDist.LogNormal.quantile(p: 0.5, mean: 0, variance: 1), 1, accuracy: 0)
        XCTAssertEqual(try! SSProbDist.LogNormal.quantile(p: 0.75, mean: 0, variance: 1), 1.963031, accuracy: 1E-6)
        XCTAssert(try! SSProbDist.LogNormal.quantile(p: 1.0, mean: 0, variance: 1).isInfinite)
        
        /*
         shapeA = 2;
         shapeB = 25/10;
         bd = BetaDistribution[shapeA, shapeB];
         N[Mean[bd], 21]
         N[Variance[bd], 21]
         N[Skewness[bd], 21]
         N[Kurtosis[bd], 21]
         */
        para = try! SSProbDist.Beta.para(shapeA: 2, shapeB: 2.5)
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
        XCTAssertEqual(try! SSProbDist.Beta.cdf(x: 0.2, shapeA: 1, shapeB: 2), 0.36, accuracy: 1e-2)
        XCTAssertEqual(try! SSProbDist.Beta.cdf(x: 0.6, shapeA: 1, shapeB: 2), 0.84, accuracy: 1e-2)
        XCTAssertEqual(try! SSProbDist.Beta.cdf(x: 0.9, shapeA: 1, shapeB: 2), 0.99, accuracy: 1e-2)
        XCTAssertEqual(try! SSProbDist.Beta.cdf(x: 0.2, shapeA: 3, shapeB: 2), 0.0272, accuracy: 1e-4)
        XCTAssertEqual(try! SSProbDist.Beta.cdf(x: 0.6, shapeA: 3, shapeB: 2.5), 0.587639, accuracy: 1e-6)
        XCTAssertEqual(try! SSProbDist.Beta.cdf(x: 0.6, shapeA: 0.5, shapeB: 2.5), 0.9591406, accuracy: 1e-6)
        XCTAssertEqual(try! SSProbDist.Beta.cdf(x: 0.6, shapeA: 0.5, shapeB: 0.5), 0.5640942, accuracy: 1e-6)
        XCTAssertThrowsError(try SSProbDist.Beta.cdf(x: 0.6, shapeA: 0.99, shapeB: 0))
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
        XCTAssertEqual(try! SSProbDist.Beta.pdf(x: 0.2, shapeA: 1, shapeB: 2), 1.6, accuracy: 1e-1)
        XCTAssertEqual(try! SSProbDist.Beta.pdf(x: 0, shapeA: 1, shapeB: 2), 2.0, accuracy: 1e-1)
        XCTAssertEqual(try! SSProbDist.Beta.pdf(x: 0.9, shapeA: 1, shapeB: 2), 0.2, accuracy: 1e-1)
        XCTAssertEqual(try! SSProbDist.Beta.pdf(x: 0.2, shapeA: 3, shapeB: 2), 0.384, accuracy: 1e-3)
        XCTAssertEqual(try! SSProbDist.Beta.pdf(x: 0.6, shapeA: 3, shapeB: 2.5), 1.793011, accuracy: 1e-6)
        XCTAssertEqual(try! SSProbDist.Beta.pdf(x: 0.6, shapeA: 0.5, shapeB: 2.5), 0.2772255, accuracy: 1e-7)
        XCTAssertEqual(try! SSProbDist.Beta.pdf(x: 0.6, shapeA: 0.5, shapeB: 0.5), 0.6497473, accuracy: 1e-7)
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
        XCTAssertEqual(try! SSProbDist.Beta.quantile(p: 0, shapeA: 1, shapeB: 2), 0, accuracy: 1e-1)
        XCTAssertEqual(try! SSProbDist.Beta.quantile(p: 0.25, shapeA: 1, shapeB: 2), 0.1339746, accuracy: 1e-7)
        XCTAssertEqual(try! SSProbDist.Beta.quantile(p: 0.5, shapeA: 1, shapeB: 2), 0.2928932, accuracy: 1e-7)
        XCTAssertEqual(try! SSProbDist.Beta.quantile(p: 0.75, shapeA: 1, shapeB: 2), 0.5, accuracy: 1e-1)
        XCTAssertEqual(try! SSProbDist.Beta.quantile(p: 0.99, shapeA: 1, shapeB: 2), 0.9, accuracy: 1e-1)
        XCTAssertEqual(try! SSProbDist.Beta.quantile(p: 1.0, shapeA: 1, shapeB: 2), 1.0, accuracy: 1e-1)
        /*
         loc = 99;
         scale = 25/100;
         cd = CauchyDistribution[loc, scale];
         N[Mean[cd], 21]
         N[Variance[cd], 21]
         N[Skewness[cd], 21]
         N[Kurtosis[cd], 21]
         */
        para = try! SSProbDist.Cauchy.para(location: 99, scale: 0.25)
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
        XCTAssertEqual(try! SSProbDist.Cauchy.cdf(x: 1, location: 1, scale: 0.5), 0.5, accuracy: 1E-1)
        XCTAssertEqual(try! SSProbDist.Cauchy.cdf(x: -10, location: -2, scale: 3), 0.1142003, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.Cauchy.cdf(x: 10, location: -2, scale: 3), 0.9220209, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.Cauchy.cdf(x: 0, location: 99, scale: 3), 0.009642803, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.Cauchy.cdf(x: 2, location: 3, scale: 0.25), 0.07797913, accuracy: 1E-7)
        
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
        XCTAssertEqual(try! SSProbDist.Cauchy.pdf(x: 1, location: 1, scale: 0.5), 0.6366198, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.Cauchy.pdf(x: -10, location: -2, scale: 3), 0.01308123, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.Cauchy.pdf(x: 10, location: -2, scale: 3), 0.00624137, accuracy: 1E-7)
        XCTAssertEqual(try! SSProbDist.Cauchy.pdf(x: 0, location: 99, scale: 3), 9.734247e-05, accuracy: 1E-11)
        XCTAssertEqual(try! SSProbDist.Cauchy.pdf(x: 2, location: 3, scale: 0.25), 0.07489644, accuracy: 1E-7)
        
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
        XCTAssertEqual(try! SSProbDist.Cauchy.quantile(p: 0, location: 1, scale: 0.5), -Double.infinity)
        XCTAssertEqual(try! SSProbDist.Cauchy.quantile(p: 0.25, location: -2, scale: 3), -5.0, accuracy: 1E-1)
        XCTAssertEqual(try! SSProbDist.Cauchy.quantile(p: 0.5, location: -2, scale: 3), -2.0, accuracy: 1E-1)
        XCTAssertEqual(try! SSProbDist.Cauchy.quantile(p: 0.75, location: 99, scale: 3), 102.0, accuracy: 1E-1)
        XCTAssertEqual(try! SSProbDist.Cauchy.quantile(p: 0.99, location: 3, scale: 0.25), 10.95513, accuracy: 1E-5)
        XCTAssertEqual(try! SSProbDist.Cauchy.quantile(p: 1, location: 3, scale: 0.25), Double.infinity)
        /*
         loc = 0;
         scale = 1;
         cd = LaplaceDistribution[loc, scale];
         N[Mean[cd], 21]
         N[Variance[cd], 21]
         N[Skewness[cd], 21]
         N[Kurtosis[cd], 21]
         */
        para = try! SSProbDist.Laplace.para(mean: 0, scale: 1)
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
        XCTAssertEqual(try! SSProbDist.Laplace.cdf(x: 1, mean: 0, scale: 1), 0.8160603, accuracy: 1e-7)
        XCTAssertEqual(try! SSProbDist.Laplace.cdf(x: -8, mean: 0, scale: 1), 0.0001677313, accuracy: 1e-9)
        XCTAssertEqual(try! SSProbDist.Laplace.cdf(x: 19, mean: 0, scale: 1), 1.0, accuracy: 1e-1)
        XCTAssertEqual(try! SSProbDist.Laplace.cdf(x: 0.5, mean: 0, scale: 1), 0.6967347, accuracy: 1e-7)
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
        XCTAssertEqual(try! SSProbDist.Laplace.pdf(x: 1, mean: 0, scale: 1), 0.1839397, accuracy: 1e-7)
        XCTAssertEqual(try! SSProbDist.Laplace.pdf(x: -8, mean: 0, scale: 1), 0.0001677313, accuracy: 1e-9)
        XCTAssertEqual(try! SSProbDist.Laplace.pdf(x: 19, mean: 0, scale: 1), 2.801398E-9, accuracy: 1e-15)
        XCTAssertEqual(try! SSProbDist.Laplace.pdf(x: 0.5, mean: 0, scale: 1), 0.3032653, accuracy: 1e-7)
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
        XCTAssertEqual(try! SSProbDist.Laplace.quantile(p: 1, mean: 0, scale: 1), Double.infinity)
        XCTAssertEqual(try! SSProbDist.Laplace.quantile(p: 0.5, mean: 0, scale: 1), 0)
        XCTAssertEqual(try! SSProbDist.Laplace.quantile(p: 0.75, mean: 0, scale: 1), 0.6931472, accuracy: 1e-7)
        XCTAssertEqual(try! SSProbDist.Laplace.quantile(p: 0.99, mean: 0, scale: 1), 3.912023, accuracy: 1e-7)
        XCTAssertEqual(try! SSProbDist.Laplace.quantile(p: 0, mean: 0, scale: 1), -Double.infinity)
        
        /*
         loc = 3;
         scale = 2;
         d = LogisticDistribution[loc, scale];
         N[Mean[d], 21]
         N[Variance[d], 21]
         N[Skewness[d], 21]
         N[Kurtosis[d], 21]
         */
        para = try! SSProbDist.Logistic.para(mean: 3, scale: 2)
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
        XCTAssertEqual(try! SSProbDist.Logistic.cdf(x: 1, mean: 3, scale: 2), 0.2689414, accuracy: 1e-7)
        XCTAssertEqual(try! SSProbDist.Logistic.cdf(x: 55, mean: 3, scale: 2), 1.0, accuracy: 1e-1)
        XCTAssertEqual(try! SSProbDist.Logistic.cdf(x: 3, mean: -2, scale: 22), 0.5565749, accuracy: 1e-7)
        XCTAssertThrowsError(try SSProbDist.Logistic.cdf(x: -3, mean: 3, scale: 0))
        
        /*
         R code
         > plogis(q = 1,location = 3,scale = 2)
         [1] 0.2689414
         > plogis(q = 55,location = 3,scale = 2)
         [1] 1
         > plogis(q = 3,location = -2,scale = 22)
         [1] 0.5592442
         */
        XCTAssertEqual(try! SSProbDist.Logistic.cdf(x: 1, mean: 3, scale: 2), 0.2689414, accuracy: 1e-7)
        XCTAssertEqual(try! SSProbDist.Logistic.cdf(x: 55, mean: 3, scale: 2), 1.0, accuracy: 1e-1)
        XCTAssertEqual(try! SSProbDist.Logistic.cdf(x: 3, mean: -2, scale: 22), 0.5565749, accuracy: 1e-7)
        XCTAssertThrowsError(try SSProbDist.Logistic.cdf(x: -3, mean: 3, scale: 0))
        /*
         > dlogis(x = 1,location = 3,scale = 2)
         [1] 0.09830597
         > dlogis(x = 55,location = 3,scale = 2)
         [1] 2.554545e-12
         > dlogis(x = 3,location = -2,scale = 22)
         [1] 0.01121815
         */
        XCTAssertEqual(try! SSProbDist.Logistic.pdf(x: 1, mean: 3, scale: 2), 0.09830597, accuracy: 1e-7)
        XCTAssertEqual(try! SSProbDist.Logistic.pdf(x: 55, mean: 3, scale: 2), 2.554545e-12, accuracy: 1e-18)
        XCTAssertEqual(try! SSProbDist.Logistic.pdf(x: 3, mean: -2, scale: 22), 0.01121815, accuracy: 1e-7)
        XCTAssertThrowsError(try SSProbDist.Logistic.pdf(x: -3, mean: 3, scale: 0))
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
        XCTAssertEqual(try! SSProbDist.Logistic.quantile(p: 0, mean: 3, scale: 22), -Double.infinity)
        XCTAssertEqual(try! SSProbDist.Logistic.quantile(p: 0.25, mean: 3, scale: 22), -21.16947, accuracy: 1E-5)
        XCTAssertEqual(try! SSProbDist.Logistic.quantile(p: 0.5, mean: 3, scale: 22), 3.0, accuracy: 1E-1)
        XCTAssertEqual(try! SSProbDist.Logistic.quantile(p: 0.75, mean: 3, scale: 22), 27.16947, accuracy: 1E-5)
        XCTAssertEqual(try! SSProbDist.Logistic.quantile(p: 0.99, mean: 3, scale: 22), 104.0926, accuracy: 1E-4)
        XCTAssertEqual(try! SSProbDist.Logistic.quantile(p: 1.0, mean: 3, scale: 22), Double.infinity)
        /*
         min = 1;
         shape = 22;
         d = ParetoDistribution[min, shape];
         N[Mean[d], 21]
         N[Variance[d], 21]
         N[Skewness[d], 21]
         N[Kurtosis[d], 21]
         */
        para = try! SSProbDist.Pareto.para(minimum: 1, shape: 22)
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
        XCTAssertThrowsError(try SSProbDist.Pareto.cdf(x: 0, minimum: 0, shape: 2))
        XCTAssertThrowsError(try SSProbDist.Pareto.cdf(x: 0, minimum: -2, shape: 1))
        XCTAssertEqual(try! SSProbDist.Pareto.cdf(x: 0, minimum: 1, shape: 22), 0)
        XCTAssertEqual(try! SSProbDist.Pareto.cdf(x: 1.0, minimum: 1, shape: 22), 0)
        XCTAssertEqual(try! SSProbDist.Pareto.cdf(x: 1.001, minimum: 1, shape: 22), 0.02174901, accuracy: 1e-7)
        XCTAssertEqual(try! SSProbDist.Pareto.cdf(x: 1.05, minimum: 1, shape: 22), 0.6581501, accuracy: 1e-7)
        XCTAssertEqual(try! SSProbDist.Pareto.cdf(x: 1.85, minimum: 1, shape: 22), 0.9999987, accuracy: 1e-7)
        XCTAssertEqual(try! SSProbDist.Pareto.cdf(x: 2, minimum: 1, shape: 22), 0.9999998, accuracy: 1e-7)
        XCTAssertEqual(try! SSProbDist.Pareto.cdf(x: 2.5, minimum: 1, shape: 22), 0.999999998240781395558, accuracy: 1e-12)
        
        
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
        XCTAssertThrowsError(try SSProbDist.Pareto.pdf(x: 0, minimum: 0, shape: 2))
        XCTAssertThrowsError(try SSProbDist.Pareto.pdf(x: 0, minimum: -2, shape: 1))
        XCTAssertEqual(try! SSProbDist.Pareto.pdf(x: 0, minimum: 1, shape: 22), 0)
        XCTAssertEqual(try! SSProbDist.Pareto.pdf(x: 1.0, minimum: 1, shape: 22), 22)
        XCTAssertEqual(try! SSProbDist.Pareto.pdf(x: 1.001, minimum: 1, shape: 22), 21.5000217271321940712, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Pareto.pdf(x: 1.05, minimum: 1, shape: 22), 7.16256872752922185937, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Pareto.pdf(x: 1.85, minimum: 1, shape: 22), 0.0000157569779601844505236, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Pareto.pdf(x: 2, minimum: 1, shape: 22),   2.622604e-6, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Pareto.pdf(x: 2.5, minimum: 1, shape: 22), 1.548112e-8, accuracy: 1e-14)
        
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
        XCTAssertThrowsError(try SSProbDist.Pareto.quantile(p: 0, minimum: 0, shape: 2))
        XCTAssertThrowsError(try SSProbDist.Pareto.quantile(p: 0, minimum: -2, shape: 2))
        XCTAssertThrowsError(try SSProbDist.Pareto.quantile(p: -1, minimum: 1, shape: 22))
        XCTAssertEqual(try! SSProbDist.Pareto.quantile(p: 0, minimum: 1, shape: 22), 1.0)
        XCTAssertEqual(try! SSProbDist.Pareto.quantile(p: 0.25, minimum: 1, shape: 22), 1.01316232860042649240, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.Pareto.quantile(p: 0.5, minimum: 1, shape: 22), 1.03200827973420963159, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.Pareto.quantile(p: 0.75, minimum: 1, shape: 22), 1.06504108943996267819, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.Pareto.quantile(p: 0.99, minimum: 1, shape: 22), 1.23284673944206613905, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.Pareto.quantile(p: 1.0, minimum: 1, shape: 22), Double.infinity)
        XCTAssertThrowsError(try SSProbDist.Pareto.quantile(p: 1.1, minimum: 1, shape: 22))
        
        /*
         lambda = 1/4;
         d = ExponentialDistribution[lambda];
         N[Mean[d], 21]
         N[Variance[d], 21]
         N[Skewness[d], 21]
         N[Kurtosis[d], 21]
         */
        para = try! SSProbDist.Exponential.para(lambda: 0.25)
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
        XCTAssertThrowsError(try SSProbDist.Exponential.cdf(x: 1, lambda: 0))
        XCTAssertThrowsError(try SSProbDist.Exponential.cdf(x: 1, lambda: -1))
        XCTAssertEqual(try! SSProbDist.Exponential.cdf(x: -2, lambda: 0.25), 0)
        XCTAssertEqual(try! SSProbDist.Exponential.cdf(x: 0, lambda: 0.25), 0)
        XCTAssertEqual(try! SSProbDist.Exponential.cdf(x: 0.5, lambda: 0.25), 0.117503097415404597135, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.Exponential.cdf(x: 3, lambda: 0.25), 0.527633447258985292862, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.Exponential.cdf(x: 5, lambda: 0.25), 0.713495203139809899675, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.Exponential.cdf(x: 22, lambda: 0.25), 0.995913228561535933007, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.Exponential.cdf(x: 50, lambda: 0.25), 0.999996273346827921329, accuracy: 1e-14)
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
        XCTAssertThrowsError(try SSProbDist.Exponential.pdf(x: 1, lambda: 0))
        XCTAssertThrowsError(try SSProbDist.Exponential.pdf(x: 1, lambda: -1))
        XCTAssertEqual(try! SSProbDist.Exponential.pdf(x: -2, lambda: 0.25), 0)
        XCTAssertEqual(try! SSProbDist.Exponential.pdf(x: 0, lambda: 0.25), 0.25)
        XCTAssertEqual(try! SSProbDist.Exponential.pdf(x: 0.5, lambda: 0.25), 0.220624225646148850716, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.Exponential.pdf(x: 3, lambda: 0.25), 0.118091638185253676785, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.Exponential.pdf(x: 5, lambda: 0.25), 0.0716261992150475250812, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.Exponential.pdf(x: 22, lambda: 0.25), 0.00102169285961601674837, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.Exponential.pdf(x: 50, lambda: 0.25), 9.31663293019667748231e-7, accuracy: 1e-14)
        /*
         N[InverseCDF[ed, 0], 21]
         N[InverseCDF[ed, 25/100], 21]
         N[InverseCDF[ed, 5/10], 21]
         N[InverseCDF[ed, 75/100], 21]
         N[InverseCDF[ed, 99/100], 21]
         N[InverseCDF[ed, 1], 21]
         */
        XCTAssertThrowsError(try SSProbDist.Exponential.quantile(p: 1, lambda: 0))
        XCTAssertThrowsError(try SSProbDist.Exponential.quantile(p: 1, lambda: -1))
        XCTAssertEqual(try! SSProbDist.Exponential.quantile(p: 0, lambda: 0.25), 0)
        XCTAssertEqual(try! SSProbDist.Exponential.quantile(p: 0.25, lambda: 0.25), 1.15072828980712370976, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.Exponential.quantile(p: 0.5, lambda: 0.25), 2.77258872223978123767, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.Exponential.quantile(p: 0.75, lambda: 0.25), 5.54517744447956247534, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.Exponential.quantile(p: 0.99, lambda: 0.25), 18.4206807439523654721, accuracy: 1e-14)
        XCTAssert(try! SSProbDist.Exponential.quantile(p: 1, lambda: 0.25).isInfinite)
        
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
        XCTAssertThrowsError(try SSProbDist.InverseNormal.cdf(x: 0, mean: 0, lambda: 2))
        XCTAssertThrowsError(try SSProbDist.InverseNormal.cdf(x: 0, mean: 2, lambda: 0))
        XCTAssertEqual(try! SSProbDist.InverseNormal.cdf(x: 0, mean: 6, lambda: 9), 0)
        XCTAssertEqual(try! SSProbDist.InverseNormal.cdf(x: 1, mean: 6, lambda: 9), 0.0108821452821513154870, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.InverseNormal.cdf(x: 2, mean: 6, lambda: 9), 0.125627012864498276906, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.InverseNormal.cdf(x: 3, mean: 6, lambda: 9), 0.287386744404773626164, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.InverseNormal.cdf(x: 10, mean: 6, lambda: 9), 0.851063810667129652088, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.InverseNormal.cdf(x: 33, mean: 6, lambda: 9), 0.997518962516710678217, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.InverseNormal.cdf(x: 145, mean: 6, lambda: 9), 0.999999999702767058076, accuracy: 1e-14)
        
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
        XCTAssertThrowsError(try SSProbDist.InverseNormal.pdf(x: 0, mean: 0, lambda: 2))
        XCTAssertThrowsError(try SSProbDist.InverseNormal.pdf(x: 0, mean: 2, lambda: 0))
        XCTAssertEqual(try! SSProbDist.InverseNormal.pdf(x: 0, mean: 6, lambda: 9), 0)
        XCTAssertEqual(try! SSProbDist.InverseNormal.pdf(x: 1, mean: 6, lambda: 9), 0.0525849014807056120865, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.InverseNormal.pdf(x: 2, mean: 6, lambda: 9), 0.155665311532723013753, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.InverseNormal.pdf(x: 3, mean: 6, lambda: 9), 0.158302949877769673488, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.InverseNormal.pdf(x: 10, mean: 6, lambda: 9), 0.0309864928480366992183, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.InverseNormal.pdf(x: 33, mean: 6, lambda: 9), 0.000399039071184676275858, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.InverseNormal.pdf(x: 145, mean: 6, lambda: 9), 4.00272220943724302952e-11, accuracy: 1e-23)
        
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
        XCTAssertThrowsError(try SSProbDist.InverseNormal.quantile(p: 0, mean: 0, lambda: 2))
        XCTAssertThrowsError(try SSProbDist.InverseNormal.quantile(p: 0, mean: 2, lambda: 0))
        XCTAssertEqual(try! SSProbDist.InverseNormal.quantile(p: 0, mean: 6, lambda: 9), 0)
        XCTAssertEqual(try! SSProbDist.InverseNormal.quantile(p: 0.25, mean: 6, lambda: 9), 2.76686873332207861117, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.InverseNormal.quantile(p: 0.5, mean: 6, lambda: 9), 4.53675199081610130561, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.InverseNormal.quantile(p: 0.75, mean: 6, lambda: 9), 7.57917596871024542035, accuracy: 1e-14)
        XCTAssertEqual(try! SSProbDist.InverseNormal.quantile(p: 0.99, mean: 6, lambda: 9), 24.5614684372629823155, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.InverseNormal.quantile(p: 0.999, mean: 6, lambda: 9), 38.7320805901883006582, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.InverseNormal.quantile(p: 1, mean: 6, lambda: 9), Double.infinity)
        /*
         mu = 6;
         lambda = 9;
         wd = InverseGaussianDistribution[mu, lambda];
         N[Mean[d], 21]
         N[Variance[d], 21]
         N[Skewness[d], 21]
         N[Kurtosis[d], 21]
         */
        para = try! SSProbDist.InverseNormal.para(mean: 6, lambda: 9)
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
        XCTAssertThrowsError(try SSProbDist.Gamma.cdf(x: 0, shape: -1, scale: 1))
        XCTAssertThrowsError(try SSProbDist.Gamma.cdf(x: 0, shape: 1, scale: 0))
        XCTAssertEqual(try! SSProbDist.Gamma.cdf(x: 0, shape: 2, scale: 3), 0, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Gamma.cdf(x: 1, shape: 2, scale: 3), 0.0446249192349476660992, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Gamma.cdf(x: 2, shape: 2, scale: 3), 0.144304801612346621880, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Gamma.cdf(x: 3, shape: 2, scale: 3), 0.264241117657115356809, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Gamma.cdf(x: 10, shape: 2, scale: 3), 0.845412695495239610381, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Gamma.cdf(x: 33, shape: 2, scale: 3), 0.999799579590517052088, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Gamma.cdf(x: 145, shape: 2, scale: 3), 0.999999999999999999950, accuracy: 1e-12)
        
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
        XCTAssertThrowsError(try SSProbDist.Gamma.pdf(x: 0, shape: -1, scale: 1))
        XCTAssertThrowsError(try SSProbDist.Gamma.pdf(x: 0, shape: 1, scale: 0))
        XCTAssertEqual(try! SSProbDist.Gamma.pdf(x: 0, shape: 2, scale: 3), 0, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Gamma.pdf(x: 1, shape: 2, scale: 3), 0.0796145900637543611584, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Gamma.pdf(x: 2, shape: 2, scale: 3), 0.114092693118353783749, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Gamma.pdf(x: 3, shape: 2, scale: 3), 0.122626480390480773865, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Gamma.pdf(x: 10, shape: 2, scale: 3), 0.0396377703858359973383, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Gamma.pdf(x: 33, shape: 2, scale: 3), 0.0000612395695642340841463, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Gamma.pdf(x: 145, shape: 2, scale: 3), 1.64522588620458773000e-20, accuracy: 1e-27)
        
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
        XCTAssertThrowsError(try SSProbDist.Gamma.quantile(p: 0, shape: -1, scale: 1))
        XCTAssertThrowsError(try SSProbDist.Gamma.quantile(p: 0, shape: 1, scale: 0))
        XCTAssertEqual(try! SSProbDist.Gamma.quantile(p: 0, shape: 2, scale: 3), 0, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Gamma.quantile(p: 0.25, shape: 2, scale: 3), 2.88383628934433128754, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Gamma.quantile(p: 0.5, shape: 2, scale: 3), 5.03504097004998196024, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Gamma.quantile(p: 0.75, shape: 2, scale: 3), 8.07790358666908731226, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Gamma.quantile(p: 0.99, shape: 2, scale: 3), 19.9150562039814368081, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Gamma.quantile(p: 0.999, shape: 2, scale: 3), 27.7002404293547571913, accuracy: 1e-12)
        XCTAssert(try! SSProbDist.Gamma.quantile(p: 1, shape: 2, scale: 3).isInfinite)
        /*
         shape = 2;
         scale = 3;
         d = InverseGaussianDistribution[shape, scale];
         N[Mean[d], 21]
         N[Variance[d], 21]
         N[Skewness[d], 21]
         N[Kurtosis[d], 21]
         */
        para = try! SSProbDist.Gamma.para(shape: 2, scale: 3)
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
        XCTAssertThrowsError(try SSProbDist.Erlang.cdf(x: 0, shape: 0, rate: 1))
        XCTAssertEqual(try! SSProbDist.Erlang.cdf(x: -1, shape: 8, rate: 1.9), 0, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Erlang.cdf(x: 1, shape: 8, rate: 1.9), 0.000793457613267557042372, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Erlang.cdf(x: 2, shape: 8, rate: 1.9), 0.0401073776861547292702, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Erlang.cdf(x: 2.2, shape: 8, rate: 1.9), 0.0625806276334696425021, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Erlang.cdf(x: 4.5, shape: 8, rate: 1.9), 0.620845136890394243952, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Erlang.cdf(x: 7, shape: 8, rate: 1.9), 0.953851071263071931215, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Erlang.cdf(x: 10, shape: 8, rate: 1.9), 0.998486657386375206401, accuracy: 1e-12)
        
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
        XCTAssertThrowsError(try SSProbDist.Erlang.pdf(x: 0, shape: 0, rate: 1))
        XCTAssertEqual(try! SSProbDist.Erlang.pdf(x: -1, shape: 8, rate: 1.9), 0, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Erlang.pdf(x: 1, shape: 8, rate: 1.9), 0.00504009538397410085449, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Erlang.pdf(x: 2, shape: 8, rate: 1.9), 0.0964915337384170109056, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Erlang.pdf(x: 2.2, shape: 8, rate: 1.9), 0.128589676154648556029, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Erlang.pdf(x: 4.5, shape: 8, rate: 1.9), 0.243707024534075753055, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Erlang.pdf(x: 7, shape: 8, rate: 1.9), 0.0464694938322868155464, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Erlang.pdf(x: 10, shape: 8, rate: 1.9), 0.00188800489092865877089, accuracy: 1e-12)
        
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
        XCTAssertThrowsError(try SSProbDist.Erlang.quantile(p: 0, shape: 0, rate: 1))
        XCTAssertEqual(try! SSProbDist.Erlang.quantile(p: 0, shape: 8, rate: 1.9), 0, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Erlang.quantile(p: 0.25, shape: 8, rate: 1.9), 3.13479465721473572797, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Erlang.quantile(p: 0.5, shape: 8, rate: 1.9), 4.03644707500042310756, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Erlang.quantile(p: 0.75, shape: 8, rate: 1.9), 5.09706847910118785655, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Erlang.quantile(p: 0.99, shape: 8, rate: 1.9), 8.42103339705662662358, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Erlang.quantile(p: 0.999, shape: 8, rate: 1.9), 10.3295670502022305302, accuracy: 1e-12)
        XCTAssert(try! SSProbDist.Erlang.quantile(p: 1, shape: 8, rate: 1.9).isInfinite)
        /*
         shape = 8;
         scale = 19/10;
         d = ErlangDistribution[shape, scale];
         N[Mean[d], 21]
         N[Variance[d], 21]
         N[Skewness[d], 21]
         N[Kurtosis[d], 21]
         */
        para = try! SSProbDist.Erlang.para(shape: 8, rate: 1.9)
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
        XCTAssertThrowsError(try SSProbDist.Weibull.cdf(x: 0, location: 2, scale: 0, shape: 3))
        XCTAssertThrowsError(try SSProbDist.Weibull.cdf(x: 0, location: 2, scale: 4, shape: 0))
        XCTAssertThrowsError(try SSProbDist.Weibull.cdf(x: 0, location: 2, scale: 4, shape: -1))
        XCTAssertThrowsError(try SSProbDist.Weibull.cdf(x: 0, location: 2, scale: -24, shape: -1))
        XCTAssertEqual(try! SSProbDist.Weibull.cdf(x: -1,  location: 2, scale: 4, shape: 3), 0, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Weibull.cdf(x: 2.9, location: 2, scale: 4, shape: 3), 0.0113259974465415820934, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Weibull.cdf(x: 3,   location: 2, scale: 4, shape: 3), 0.0155035629945915940130, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Weibull.cdf(x: 3.1, location: 2, scale: 4, shape: 3), 0.0205821113758218963048, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Weibull.cdf(x: 4.5, location: 2, scale: 4, shape: 3), 0.216622535939181796504, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Weibull.cdf(x: 7,   location: 2, scale: 4, shape: 3), 0.858169840912657470462, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Weibull.cdf(x: 22,  location: 2, scale: 4, shape: 3), 1.00000000000000000000, accuracy: 1e-12)
        
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
        XCTAssertThrowsError(try SSProbDist.Weibull.pdf(x: 0, location: 2, scale: 0, shape: 3))
        XCTAssertThrowsError(try SSProbDist.Weibull.pdf(x: 0, location: 2, scale: 4, shape: 0))
        XCTAssertThrowsError(try SSProbDist.Weibull.pdf(x: 0, location: 2, scale: 4, shape: -2))
        XCTAssertThrowsError(try SSProbDist.Weibull.pdf(x: 0, location: 2, scale: -4, shape: 3))
        XCTAssertEqual(try! SSProbDist.Weibull.pdf(x: -1,  location: 2, scale: 4, shape: 3), 0, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Weibull.pdf(x: 2.9, location: 2, scale: 4, shape: 3), 0.0375387160344516243049, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Weibull.pdf(x: 3,   location: 2, scale: 4, shape: 3), 0.0461482704846285190306, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Weibull.pdf(x: 3.1, location: 2, scale: 4, shape: 3), 0.0555513583704026018190, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Weibull.pdf(x: 4.5, location: 2, scale: 4, shape: 3), 0.229505116424067833055, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Weibull.pdf(x: 7,   location: 2, scale: 4, shape: 3), 0.166207217680479526802, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Weibull.pdf(x: 22,  location: 2, scale: 4, shape: 3), 9.68703868657098933797e-54, accuracy: 1e-60)
        
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
        XCTAssertThrowsError(try SSProbDist.Weibull.quantile(p: 0, location: 2, scale: 0, shape: 3))
        XCTAssertThrowsError(try SSProbDist.Weibull.quantile(p: 0, location: 2, scale: 4, shape: 0))
        XCTAssertThrowsError(try SSProbDist.Weibull.quantile(p: 0, location: 2, scale: 0, shape: 0))
        XCTAssertThrowsError(try SSProbDist.Weibull.quantile(p: 0, location: 2, scale: -4, shape: 3))
        XCTAssertThrowsError(try SSProbDist.Weibull.quantile(p: 0, location: 2, scale: 4, shape: -3))
        XCTAssertThrowsError(try SSProbDist.Weibull.quantile(p: 0, location: 2, scale: -4, shape: -3))
        XCTAssertEqual(try! SSProbDist.Weibull.quantile(p: 0, location: 2, scale: 4, shape: 3), 2, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Weibull.quantile(p: 0.25, location: 2, scale: 4, shape: 3), 4.64056942859838095934, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Weibull.quantile(p: 0.5, location: 2, scale: 4, shape: 3), 5.53998817800207087498, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Weibull.quantile(p: 0.75, location: 2, scale: 4, shape: 3), 6.46010562184380828507, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Weibull.quantile(p: 0.99, location: 2, scale: 4, shape: 3), 8.65490539680019769957, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Weibull.quantile(p: 0.999, location: 2, scale: 4, shape: 3), 9.61796499056221876841, accuracy: 1e-12)
        XCTAssert(try! SSProbDist.Weibull.quantile(p: 1, location: 2, scale: 4, shape: 3).isInfinite)
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
        para = try! SSProbDist.Weibull.para(location: 2, scale: 4, shape: 3)
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
        XCTAssertThrowsError(try SSProbDist.Uniform.cdf(x: 0, lowerBound: 10, upperBound: 1))
        XCTAssertThrowsError(try SSProbDist.Uniform.cdf(x: 0, lowerBound: 10, upperBound: 10))
        XCTAssertEqual(try! SSProbDist.Uniform.cdf(x: 0,   lowerBound: 1, upperBound: 10), 0, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Uniform.cdf(x: 2.9, lowerBound: 1, upperBound: 10), 0.211111111111111111111, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Uniform.cdf(x: 3,   lowerBound: 1, upperBound: 10), 0.222222222222222222222, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Uniform.cdf(x: 3.1, lowerBound: 1, upperBound: 10), 0.233333333333333333333, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Uniform.cdf(x: 4.5, lowerBound: 1, upperBound: 10), 0.388888888888888888889, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Uniform.cdf(x: 7,   lowerBound: 1, upperBound: 10), 0.666666666666666666667, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Uniform.cdf(x: 22,  lowerBound: 1, upperBound: 10), 1.0, accuracy: 1e-12)
        
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
        XCTAssertThrowsError(try SSProbDist.Uniform.pdf(x: 0, lowerBound: 10, upperBound: 1))
        XCTAssertThrowsError(try SSProbDist.Uniform.pdf(x: 0, lowerBound: 10, upperBound: 10))
        XCTAssertThrowsError(try SSProbDist.Uniform.pdf(x: 0, lowerBound: 10, upperBound: 10))
        XCTAssertEqual(try! SSProbDist.Uniform.pdf(x: 0,     lowerBound: 1, upperBound: 10), 0, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Uniform.pdf(x: 2.9,   lowerBound: 1, upperBound: 10), 0.111111111111111111111, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Uniform.pdf(x: 3,     lowerBound: 1, upperBound: 10), 0.111111111111111111111, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Uniform.pdf(x: 3.1,   lowerBound: 1, upperBound: 10), 0.111111111111111111111, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Uniform.pdf(x: 4.5,   lowerBound: 1, upperBound: 10), 0.111111111111111111111, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Uniform.pdf(x: 7,     lowerBound: 1, upperBound: 10), 0.111111111111111111111, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Uniform.pdf(x: 22,    lowerBound: 1, upperBound: 10), 0, accuracy: 1e-12)
        
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
        XCTAssertThrowsError(try SSProbDist.Uniform.quantile(p: 0, lowerBound: 10, upperBound: 1))
        XCTAssertThrowsError(try SSProbDist.Uniform.quantile(p: 0, lowerBound: 10, upperBound: 10))
        XCTAssertThrowsError(try SSProbDist.Uniform.quantile(p: 0, lowerBound: 10, upperBound: 10))
        XCTAssertThrowsError(try SSProbDist.Uniform.quantile(p: -1, lowerBound: 1, upperBound: 10))
        XCTAssertThrowsError(try SSProbDist.Uniform.quantile(p: 2, lowerBound: 1, upperBound: 10))
        XCTAssertEqual(try! SSProbDist.Uniform.quantile(p: 0, lowerBound: 1, upperBound: 10), 1, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Uniform.quantile(p: 0.25, lowerBound: 1, upperBound: 10), 3.25, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Uniform.quantile(p: 0.5, lowerBound: 1, upperBound: 10), 5.5, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Uniform.quantile(p: 0.75, lowerBound: 1, upperBound: 10), 7.75, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Uniform.quantile(p: 0.99, lowerBound: 1, upperBound: 10), 9.91, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Uniform.quantile(p: 0.999, lowerBound: 1, upperBound: 10), 9.991, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Uniform.quantile(p: 1, lowerBound: 1, upperBound: 10), 10.0, accuracy: 1e-12)
        /*
         min = 1;
         max = 10;
         d = UniformDistribution[{min, max}];
         N[Mean[d], 21]
         N[Variance[d], 21]
         N[Skewness[d], 21]
         N[Kurtosis[d], 21]
         */
        para = try! SSProbDist.Uniform.para(lowerBound: 1, upperBound: 10)
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
        XCTAssertThrowsError(try SSProbDist.Triangular.cdf(x: 0, lowerBound: 10, upperBound: 0, mode: 3))
        XCTAssertThrowsError(try SSProbDist.Triangular.cdf(x: 0, lowerBound: 0, upperBound: 0, mode: 3))
        XCTAssertThrowsError(try SSProbDist.Triangular.cdf(x: 0, lowerBound: 0, upperBound: 10, mode: 333))
        XCTAssertEqual(try! SSProbDist.Triangular.cdf(x: 0,   lowerBound: 1, upperBound: 10, mode: 3), 0, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.cdf(x: 2.9, lowerBound: 1, upperBound: 10, mode: 3), 0.200555555555555555556, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.cdf(x: 3,   lowerBound: 1, upperBound: 10, mode: 3), 0.222222222222222222222, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.cdf(x: 3.1, lowerBound: 1, upperBound: 10, mode: 3), 0.244285714285714285714, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.cdf(x: 4.5, lowerBound: 1, upperBound: 10, mode: 3), 0.519841269841269841270, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.cdf(x: 7,   lowerBound: 1, upperBound: 10, mode: 3), 0.857142857142857142857, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.cdf(x: 22,  lowerBound: 1, upperBound: 10, mode: 3), 1.0, accuracy: 1e-12)
        
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
        XCTAssertThrowsError(try SSProbDist.Triangular.pdf(x: 0, lowerBound: 10, upperBound: 0, mode: 3))
        XCTAssertThrowsError(try SSProbDist.Triangular.pdf(x: 0, lowerBound: 0, upperBound: 0, mode: 3))
        XCTAssertThrowsError(try SSProbDist.Triangular.pdf(x: 0, lowerBound: 0, upperBound: 10, mode: 333))
        XCTAssertEqual(try! SSProbDist.Triangular.pdf(x: 0,     lowerBound: 1, upperBound: 10, mode: 3), 0, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.pdf(x: 2.9,   lowerBound: 1, upperBound: 10, mode: 3), 0.211111111111111111111, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.pdf(x: 3,     lowerBound: 1, upperBound: 10, mode: 3), 0.222222222222222222222, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.pdf(x: 3.1,   lowerBound: 1, upperBound: 10, mode: 3), 0.219047619047619047619, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.pdf(x: 4.5,   lowerBound: 1, upperBound: 10, mode: 3), 0.174603174603174603175, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.pdf(x: 7,     lowerBound: 1, upperBound: 10, mode: 3), 0.0952380952380952380952, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.pdf(x: 22,    lowerBound: 1, upperBound: 10, mode: 3), 0, accuracy: 1e-12)
        
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
        XCTAssertThrowsError(try SSProbDist.Triangular.quantile(p: 0, lowerBound: 10, upperBound: 0, mode: 3))
        XCTAssertThrowsError(try SSProbDist.Triangular.quantile(p: 0, lowerBound: 0, upperBound: 0, mode: 3))
        XCTAssertThrowsError(try SSProbDist.Triangular.quantile(p: 0, lowerBound: 0, upperBound: 10, mode: 333))
        XCTAssertEqual(try! SSProbDist.Triangular.quantile(p: 0,    lowerBound: 1, upperBound: 10, mode: 3), 1, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.quantile(p: 0.25, lowerBound: 1, upperBound: 10, mode: 3), 3.12613645756623999012, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.quantile(p: 0.5,  lowerBound: 1, upperBound: 10, mode: 3), 4.38751391983908792162, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.quantile(p: 0.75, lowerBound: 1, upperBound: 10, mode: 3), 6.03137303340311411425, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.quantile(p: 0.99, lowerBound: 1, upperBound: 10, mode: 3), 9.20627460668062282285, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.quantile(p: 0.999,lowerBound: 1, upperBound: 10, mode: 3), 9.74900199203977733561, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.quantile(p: 1,    lowerBound: 1, upperBound: 10, mode: 3), 10.0, accuracy: 1e-12)
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
        para = try! SSProbDist.Triangular.para(lowerBound: 1, upperBound: 10, mode: 3)
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
        XCTAssertThrowsError(try SSProbDist.Triangular.cdf(x: 0, lowerBound: 10, upperBound: 0))
        XCTAssertThrowsError(try SSProbDist.Triangular.cdf(x: 0, lowerBound: 0, upperBound: 0))
        XCTAssertEqual(try! SSProbDist.Triangular.cdf(x: 0,   lowerBound: 1, upperBound: 10), 0, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.cdf(x: 2.9, lowerBound: 1, upperBound: 10), 0.0891358024691358024691, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.cdf(x: 3,   lowerBound: 1, upperBound: 10), 0.0987654320987654320988, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.cdf(x: 3.1, lowerBound: 1, upperBound: 10), 0.108888888888888888889, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.cdf(x: 4.5, lowerBound: 1, upperBound: 10), 0.302469135802469135802, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.cdf(x: 7,   lowerBound: 1, upperBound: 10), 0.777777777777777777778, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.cdf(x: 22,  lowerBound: 1, upperBound: 10), 1.0, accuracy: 1e-12)
        
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
        XCTAssertThrowsError(try SSProbDist.Triangular.pdf(x: 0, lowerBound: 10, upperBound: 0))
        XCTAssertThrowsError(try SSProbDist.Triangular.pdf(x: 0, lowerBound: 0, upperBound: 0))
        XCTAssertEqual(try! SSProbDist.Triangular.pdf(x: 0,     lowerBound: 1, upperBound: 10), 0, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.pdf(x: 2.9,   lowerBound: 1, upperBound: 10), 0.0938271604938271604938, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.pdf(x: 3,     lowerBound: 1, upperBound: 10), 0.0987654320987654320988, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.pdf(x: 3.1,   lowerBound: 1, upperBound: 10), 0.103703703703703703704, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.pdf(x: 4.5,   lowerBound: 1, upperBound: 10), 0.172839506172839506173, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.pdf(x: 7,     lowerBound: 1, upperBound: 10), 0.148148148148148148148, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.pdf(x: 22,    lowerBound: 1, upperBound: 10), 0, accuracy: 1e-12)
        
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
        XCTAssertThrowsError(try SSProbDist.Triangular.quantile(p: 0, lowerBound: 10, upperBound: 0))
        XCTAssertThrowsError(try SSProbDist.Triangular.quantile(p: 0, lowerBound: 0, upperBound: 0))
        XCTAssertEqual(try! SSProbDist.Triangular.quantile(p: 0,    lowerBound: 1, upperBound: 10), 1, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.quantile(p: 0.25, lowerBound: 1, upperBound: 10), 4.18198051533946385980, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.quantile(p: 0.5,  lowerBound: 1, upperBound: 10), 5.50000000000000000000, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.quantile(p: 0.75, lowerBound: 1, upperBound: 10), 6.81801948466053614020, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.quantile(p: 0.99, lowerBound: 1, upperBound: 10), 9.36360389693210722804, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.quantile(p: 0.999,lowerBound: 1, upperBound: 10), 9.79875388202501892732, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Triangular.quantile(p: 1,    lowerBound: 1, upperBound: 10), 10.0, accuracy: 1e-12)
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
        para = try! SSProbDist.Triangular.para(lowerBound: 1, upperBound: 10)
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
        XCTAssertThrowsError(try SSProbDist.Poisson.pdf(k: -1, rate: 1))
        XCTAssertThrowsError(try SSProbDist.Poisson.pdf(k: 1, rate: 0))
        XCTAssertEqual(try! SSProbDist.Poisson.pdf(k: 0, rate: 0.5), 0.606530659712633423604, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Poisson.pdf(k: 1, rate: 0.5), 0.303265329856316711802, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Poisson.pdf(k: 2, rate: 0.5), 0.0758163324640791779505, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Poisson.pdf(k: 3, rate: 0.5), 0.0126360554106798629917, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Poisson.pdf(k: 4, rate: 0.5), 0.00157950692633498287397, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Poisson.pdf(k: 5, rate: 0.5), 0.000157950692633498287397, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Poisson.pdf(k: 6, rate: 0.5), 0.0000131625577194581906164, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Poisson.pdf(k: 7, rate: 0.5), 9.40182694247013615457e-7, accuracy: 1e-15)
        
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
        XCTAssertThrowsError(try SSProbDist.Poisson.cdf(k: -1, rate: 1, tail: .lower))
        XCTAssertThrowsError(try SSProbDist.Poisson.cdf(k: 1, rate: 0, tail: .lower))
        XCTAssertEqual(try! SSProbDist.Poisson.cdf(k: 0, rate: 0.5, tail: .lower), 0.606530659712633423604, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Poisson.cdf(k: 1, rate: 0.5, tail: .lower), 0.909795989568950135406, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Poisson.cdf(k: 2, rate: 0.5, tail: .lower), 0.985612322033029313356, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Poisson.cdf(k: 3, rate: 0.5, tail: .lower), 0.998248377443709176348, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Poisson.cdf(k: 4, rate: 0.5, tail: .lower), 0.999827884370044159222, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Poisson.cdf(k: 5, rate: 0.5, tail: .lower), 0.999985835062677657509, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Poisson.cdf(k: 6, rate: 0.5, tail: .lower), 0.999998997620397115700, accuracy: 1e-12)
        XCTAssertEqual(try! SSProbDist.Poisson.cdf(k: 7, rate: 0.5, tail: .lower), 0.999999937803091362714, accuracy: 1e-12)
        
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
        XCTAssertThrowsError(try SSProbDist.VonMises.cdf(x: 2, mean: -3, concentration: 0))
        XCTAssertThrowsError(try SSProbDist.VonMises.cdf(x: 2, mean: -3, concentration: -1))
        XCTAssertEqual(try! SSProbDist.VonMises.cdf(x: -3 - Double.pi - 1.0, mean: -3, concentration: 4, useExpIntegration: true),0 ,accuracy: 1E-5)
        XCTAssertEqual(try! SSProbDist.VonMises.cdf(x: -Double.pi - 1.0, mean: -3, concentration: 4, useExpIntegration: true),0.0195387021367985546020 ,accuracy: 1E-12)
        XCTAssertEqual(try! SSProbDist.VonMises.cdf(x: -2.5, mean: -3, concentration: 4, useExpIntegration: true),0.829488464005985508796 ,accuracy: 1E-12)
        XCTAssertEqual(try! SSProbDist.VonMises.cdf(x: -0.2, mean: -3, concentration: 4, useExpIntegration: true),0.999904581125379364584 ,accuracy: 1E-12)
        XCTAssertEqual(try! SSProbDist.VonMises.cdf(x: -4.4, mean: -3, concentration: 4, useExpIntegration: true),0.00722697637072942637724 ,accuracy: 1E-12)
        XCTAssertEqual(try! SSProbDist.VonMises.cdf(x: -Double.pi / 2.0, mean: -3, concentration: 4, useExpIntegration: true),0.993539629762563788614 ,accuracy: 1E-12)
        XCTAssertEqual(try! SSProbDist.VonMises.cdf(x: 0, mean: -3, concentration: 4, useExpIntegration: true),0.999962986474166847826 ,accuracy: 1E-12)
        XCTAssertEqual(try! SSProbDist.VonMises.cdf(x: -3 + Double.pi + 1.0, mean: -3, concentration: 4, useExpIntegration: true),1.0 ,accuracy: 1E-7)
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
        XCTAssertThrowsError(try SSProbDist.VonMises.pdf(x: 2, mean: -3, concentration: 0))
        XCTAssertThrowsError(try SSProbDist.VonMises.pdf(x: 2, mean: -3, concentration: -1))
        XCTAssertEqual(try! SSProbDist.VonMises.pdf(x: -3 - Double.pi - 1.0, mean: -3, concentration: 4),0 ,accuracy: 1E-5)
        XCTAssertEqual(try! SSProbDist.VonMises.pdf(x: -Double.pi - 1.0, mean: -3, concentration: 4),0.0744027395631070328565 ,accuracy: 1E-12)
        XCTAssertEqual(try! SSProbDist.VonMises.pdf(x: -2.5, mean: -3, concentration: 4),0.471177869330735027666 ,accuracy: 1E-12)
        XCTAssertEqual(try! SSProbDist.VonMises.pdf(x: -0.2, mean: -3, concentration: 4),0.000324982499557601827956 ,accuracy: 1E-12)
        XCTAssertEqual(try! SSProbDist.VonMises.pdf(x: -4.4, mean: -3, concentration: 4),0.0277927164636370027697 ,accuracy: 1E-12)
        XCTAssertEqual(try! SSProbDist.VonMises.pdf(x: -Double.pi / 2.0, mean: -3, concentration: 4),0.0247638628979559132417 ,accuracy: 1E-12)
        XCTAssertEqual(try! SSProbDist.VonMises.pdf(x: 0, mean: -3, concentration: 4),0.000268456988587833058582 ,accuracy: 1E-12)
        XCTAssertEqual(try! SSProbDist.VonMises.pdf(x: -3 + Double.pi + 1.0, mean: -3, concentration: 4),0 ,accuracy: 1E-7)
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
        XCTAssertThrowsError(try SSProbDist.VonMises.quantile(p: -1, mean: -3, concentration: 4))
        XCTAssertThrowsError(try SSProbDist.VonMises.quantile(p: 2, mean: -3, concentration: 4))
        XCTAssertEqual(try! SSProbDist.VonMises.quantile(p: 0, mean: -3, concentration: 4),-6.14159265358979323846 ,accuracy: 1E-5)
        XCTAssertEqual(try! SSProbDist.VonMises.quantile(p: 0.25, mean: -3, concentration: 4),-3.35205527357190904480 ,accuracy: 1E-5)
        XCTAssertEqual(try! SSProbDist.VonMises.quantile(p: 0.5, mean: -3, concentration: 4),-3.00000000000000000000 ,accuracy: 1E-5)
        XCTAssertEqual(try! SSProbDist.VonMises.quantile(p: 0.75, mean: -3, concentration: 4),-2.64794472642809095508 ,accuracy: 1E-5)
        XCTAssertEqual(try! SSProbDist.VonMises.quantile(p: 0.99, mean: -3, concentration: 4),-1.68421199711729556367 ,accuracy: 1E-5)
        XCTAssertEqual(try! SSProbDist.VonMises.quantile(p: 0.999, mean: -3, concentration: 4),-1.04475697892580395363 ,accuracy: 1E-5)
        XCTAssertEqual(try! SSProbDist.VonMises.quantile(p: 1, mean: -3, concentration: 4),0.141592653589793238463 ,accuracy: 1E-5)
        /*
         a = -3;
         b = 4;
         d = VonMisesDistribution[a, b];
         [Mean[d], 21]
         V = 1 - BesselI[1, b]/BesselI[0, b]
         N[%,21]
         */
        XCTAssertThrowsError(try SSProbDist.VonMises.para(mean: -3, concentration: 0))
        XCTAssertThrowsError(try SSProbDist.VonMises.para(mean: -3, concentration: -1))
        para = try! SSProbDist.VonMises.para(mean: -3, concentration: 4)
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
        XCTAssertThrowsError(try SSProbDist.Rayleigh.pdf(x: 1, scale: 0))
        XCTAssertThrowsError(try SSProbDist.Rayleigh.pdf(x: 1, scale: -1))
        XCTAssertEqual(try! SSProbDist.Rayleigh.pdf(x: -1, scale: 1.5),0 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.Rayleigh.pdf(x: 0, scale: 1.5),0 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.Rayleigh.pdf(x: 0.01, scale: 1.5),0.00444434568010973124020 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.Rayleigh.pdf(x: 1, scale: 1.5),0.355883290185248018124 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.Rayleigh.pdf(x: 1.1, scale: 1.5),0.373622658528284221473 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.Rayleigh.pdf(x: 3, scale: 1.5),0.180447044315483589192 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.Rayleigh.pdf(x: 10, scale: 1.5),9.92725082756961935157e-10 ,accuracy: 1E-20)
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
        XCTAssertThrowsError(try SSProbDist.Rayleigh.cdf(x: 1, scale: 0))
        XCTAssertThrowsError(try SSProbDist.Rayleigh.cdf(x: 1, scale: -1))
        XCTAssertEqual(try! SSProbDist.Rayleigh.cdf(x: -1, scale: 1.5),0 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.Rayleigh.cdf(x: 0, scale: 1.5),0 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.Rayleigh.cdf(x: 0.01, scale: 1.5),0.0000222219753104709546309 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.Rayleigh.cdf(x: 1, scale: 1.5),0.199262597083191959222 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.Rayleigh.cdf(x: 1.1, scale: 1.5),0.235771834828509546987 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.Rayleigh.cdf(x: 3, scale: 1.5),0.864664716763387308106 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.Rayleigh.cdf(x: 10, scale: 1.5),0.999999999776636856380 ,accuracy: 1E-14)
        
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
        XCTAssertThrowsError(try SSProbDist.Rayleigh.quantile(p: -1, scale: 1.5))
        XCTAssertThrowsError(try SSProbDist.Rayleigh.quantile(p: 2, scale: 1.5))
        XCTAssertEqual(try! SSProbDist.Rayleigh.quantile(p: 0, scale: 1.5),0 ,accuracy: 1E-15)
        XCTAssertEqual(try! SSProbDist.Rayleigh.quantile(p: 0.25, scale: 1.5),1.13779142466139819887 ,accuracy: 1E-15)
        XCTAssertEqual(try! SSProbDist.Rayleigh.quantile(p: 0.5, scale: 1.5),1.76611503377321203652 ,accuracy: 1E-15)
        XCTAssertEqual(try! SSProbDist.Rayleigh.quantile(p: 0.75, scale: 1.5),2.49766383347309326906 ,accuracy: 1E-15)
        XCTAssertEqual(try! SSProbDist.Rayleigh.quantile(p: 0.99, scale: 1.5),4.55228138815543905259 ,accuracy: 1E-15)
        XCTAssertEqual(try! SSProbDist.Rayleigh.quantile(p: 0.999, scale: 1.5),5.57538328327475767043 ,accuracy: 1E-15)
        XCTAssert(try! SSProbDist.Rayleigh.quantile(p: 1, scale: 1.5).isInfinite)
        
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
        XCTAssertThrowsError(try SSProbDist.ExtremeValue.pdf(x: 1, location: -2, scale: -11))
        XCTAssertThrowsError(try SSProbDist.ExtremeValue.pdf(x: 1, location: -2, scale: 0))
        XCTAssertEqual(try! SSProbDist.ExtremeValue.pdf(x: -6, location: -2, scale: 1),  1.06048039970427672992e-22 ,accuracy: 1E-30)
        XCTAssertEqual(try! SSProbDist.ExtremeValue.pdf(x: -5, location: -2, scale: 1),3.80054250404435771071e-8 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.ExtremeValue.pdf(x: -0.04, location: -2, scale: 1),0.122351354198388769973 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.ExtremeValue.pdf(x: -2, location: -2, scale: 1),0.367879441171442321596 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.ExtremeValue.pdf(x: -0.11, location: -2, scale: 1),0.129889419617261299978 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.ExtremeValue.pdf(x: 0, location: -2, scale: 1),0.118204951593143145999 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.ExtremeValue.pdf(x: 2, location: -2, scale: 1),0.0179832296967136435659 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.ExtremeValue.pdf(x: 5, location: -2, scale: 1),0.000911050815848220300461 ,accuracy: 1E-14)
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
        XCTAssertThrowsError(try SSProbDist.ExtremeValue.cdf(x: 1, location: -2, scale: -11))
        XCTAssertThrowsError(try SSProbDist.ExtremeValue.cdf(x: 1, location: -2, scale: 0))
        XCTAssertEqual(try! SSProbDist.ExtremeValue.cdf(x: -6, location: -2, scale: 1),  1.94233760495640183858e-24 ,accuracy: 1E-30)
        XCTAssertEqual(try! SSProbDist.ExtremeValue.cdf(x: -5, location: -2, scale: 1),1.89217869483829263358e-9 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.ExtremeValue.cdf(x: -0.04, location: -2, scale: 1),0.868612280319186993522 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.ExtremeValue.cdf(x: -2, location: -2, scale: 1),0.367879441171442321596 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.ExtremeValue.cdf(x: -0.11, location: -2, scale: 1),0.859785956213361748121 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.ExtremeValue.cdf(x: 0, location: -2, scale: 1),0.873423018493116642989 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.ExtremeValue.cdf(x: 2, location: -2, scale: 1),0.981851073061666482920 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.ExtremeValue.cdf(x: 5, location: -2, scale: 1),0.999088533672457833191 ,accuracy: 1E-14)
        
        
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
        XCTAssertThrowsError(try SSProbDist.ExtremeValue.quantile(p: -1,location: -2, scale: 1))
        XCTAssertThrowsError(try SSProbDist.ExtremeValue.quantile(p: 2,location: -2, scale: 1))
        XCTAssert(try! SSProbDist.ExtremeValue.quantile(p: 0,location: -2, scale: 1) == -Double.infinity)
        XCTAssertEqual(try! SSProbDist.ExtremeValue.quantile(p: 0.25,location: -2, scale: 1),-2.32663425997828098240 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.ExtremeValue.quantile(p: 0.5,location: -2, scale: 1),-1.63348707941833567299 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.ExtremeValue.quantile(p: 0.75,location: -2, scale: 1),-0.754100676292761801619 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.ExtremeValue.quantile(p: 0.99,location: -2, scale: 1),2.60014922677657999772 ,accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.ExtremeValue.quantile(p: 0.999,location: -2, scale: 1),4.90725507052371649992 ,accuracy: 1E-14)
        XCTAssert(try! SSProbDist.ExtremeValue.quantile(p: 1,location: -2, scale: 1).isInfinite)
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
        XCTAssertThrowsError(try SSProbDist.NonCentralChiSquare.pdf(chi: 0, degreesOfFreedom: 10, lambda: -1))
        XCTAssertThrowsError(try SSProbDist.NonCentralChiSquare.pdf(chi: 0, degreesOfFreedom: -10, lambda: 0))
        XCTAssertEqual(try! SSProbDist.NonCentralChiSquare.pdf(chi: 0, degreesOfFreedom: 10, lambda: 2), 0, accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.NonCentralChiSquare.pdf(chi: 1, degreesOfFreedom: 10, lambda: 2), 0.000320827305783384301367, accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.NonCentralChiSquare.pdf(chi: 3.5, degreesOfFreedom: 10, lambda: 2), 0.0175567221203895712845, accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.NonCentralChiSquare.pdf(chi: 4, degreesOfFreedom: 10, lambda: 2), 0.0244526022914690298218, accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.NonCentralChiSquare.pdf(chi: 20, degreesOfFreedom: 10, lambda: 2), 0.0200906234018482020788, accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.NonCentralChiSquare.pdf(chi: 120, degreesOfFreedom: 10, lambda: 2), 1.86330190212638377398e-18, accuracy: 1E-25)
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
        XCTAssertThrowsError(try SSProbDist.NonCentralChiSquare.cdf(chi: 0, degreesOfFreedom: 10, lambda: -1))
        XCTAssertThrowsError(try SSProbDist.NonCentralChiSquare.cdf(chi: 0, degreesOfFreedom: -10, lambda: 0))
        XCTAssertEqual(try! SSProbDist.NonCentralChiSquare.cdf(chi: 0, degreesOfFreedom: 10, lambda: 2), 0, accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.NonCentralChiSquare.cdf(chi: 1, degreesOfFreedom: 10, lambda: 2), 0.0000687170350978367993954, accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.NonCentralChiSquare.cdf(chi: 3.5, degreesOfFreedom: 10, lambda: 2), 0.0158988857488017761417, accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.NonCentralChiSquare.cdf(chi: 4, degreesOfFreedom: 10, lambda: 2), 0.0263683505034293909215, accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.NonCentralChiSquare.cdf(chi: 20, degreesOfFreedom: 10, lambda: 2), 0.920255991428431897124, accuracy: 1E-14)
        XCTAssertEqual(try! SSProbDist.NonCentralChiSquare.cdf(chi: 120, degreesOfFreedom: 10, lambda: 2), 0.999999999999999995559, accuracy: 1E-14)
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
        XCTAssertThrowsError(try SSProbDist.NonCentralChiSquare.quantile(p: -1, degreesOfFreedom: 10, lambda: 2))
        XCTAssertThrowsError(try SSProbDist.NonCentralChiSquare.quantile(p: -1, degreesOfFreedom: 10, lambda: 2))
        XCTAssert(try! SSProbDist.NonCentralChiSquare.quantile(p: 0, degreesOfFreedom: 10, lambda: 2) == 0)
        XCTAssertEqual(try! SSProbDist.NonCentralChiSquare.quantile(p: 0.25, degreesOfFreedom: 10, lambda: 2),8.13756055748165583031 ,accuracy: 1E-11)
        XCTAssertEqual(try! SSProbDist.NonCentralChiSquare.quantile(p: 0.5, degreesOfFreedom: 10, lambda: 2),11.2430133568251407182 ,accuracy: 1E-11)
        XCTAssertEqual(try! SSProbDist.NonCentralChiSquare.quantile(p: 0.75, degreesOfFreedom: 10, lambda: 2),15.0420244933699346629 ,accuracy: 1E-11)
        XCTAssertEqual(try! SSProbDist.NonCentralChiSquare.quantile(p: 0.99, degreesOfFreedom: 10, lambda: 2),27.5151340899272570682 ,accuracy: 1E-11)
        XCTAssertEqual(try! SSProbDist.NonCentralChiSquare.quantile(p: 0.999, degreesOfFreedom: 10, lambda: 2),34.8900723430922940474 ,accuracy: 1E-11)
        XCTAssert(try! SSProbDist.NonCentralChiSquare.quantile(p: 1, degreesOfFreedom: 10, lambda: 2).isInfinite)
    }
    
    func testAiry() {
        // AiryAi for 100 <= x <= 100
        
        let ai: Array<Double> = [0.1488939424838102511513141000040911644741979022830182050873758921,
                                 0.09256111899142596927387658708951406853496428205293770121803101998,
                                 -0.01652321377768641629645385775413086316747901713381606578242898233,
                                 -0.1154621783486551409774241627317667358078486180953927375831755133,
                                 -0.1501143066534640768383208257028638234995497653155924061936287027,
                                 -0.1037635293296477816379765127256228674793850988053420151691903504,
                                 -0.003259833699567764521057718401808076036864990546497492878507752873,
                                 0.09805859694391026023114744205988292343693881535961875811903353714,
                                 0.1492901764629517522760046108231748065179000561067396135898329289,
                                 0.1269158349791164207128391870913618047131424726702238545134148365,
                                 0.04404174047121875650111792827380983784125457595626598034566033504,
                                 -0.05861532911721031777754694652155228701871925016301967206267101823,
                                 -0.1336080054425593494339148040360120039443273804453137428410705272,
                                 -0.1485580820614915092733873541271686091601526708814308242731087833,
                                 -0.0990796936112544961726033763954636513701084950299456515223605757,
                                 -0.008336054100305166618668556608717113145777062187874992373377684054,
                                 0.08488629557160754061004679570016156526851542442718305757768870225,
                                 0.143191856107462660679866111753121262573505150844201950188500938,
                                 0.1451789343628656488198424118858697938454002495495389458494189722,
                                 0.09223414735013414518870975662125906748584781396644603360816350421,
                                 0.005978426138492312086423311183697577307519740860183801803053154913,
                                 -0.08141054583839781871132405018359407270858109877546173753066642504,
                                 -0.1395142585223155214205055955446608937582547522398444561555457124,
                                 -0.1499249134808555335228381490449465019896298791527805699061449716,
                                 -0.1112203813759697324560583066934501122901296760406556093367883242,
                                 -0.03777307479690383640993426955948516455080911875496785724298576364,
                                 0.04631368518272456713100226557190814026491376259941483062880072491,
                                 0.1155074419433968453949310952038271281336853913889855393506273581,
                                 0.1505124489707944719440406274471245496704940963701190609965350669,
                                 0.1431257137680931187180104548439580571605621688654128108159795319,
                                 0.09732683611738342609205226008845698109150893590736560906315914464,
                                 0.02689753897479439842252557989478238352285619472175563452931155218,
                                 -0.04922253256466878563359383732229362603958969430230592462089804362,
                                 -0.1122516377089949296001158466778760472491019339218678221919815573,
                                 -0.1480877908847252401856718844944857350478502693816949191719875175,
                                 -0.1500559885141316037909676501902551419264474800943727766822267508,
                                 -0.1195307470230712191380669332569143154540534299433491945410696051,
                                 -0.06466292702592794633712834914865015725391895143304472014969077487,
                                 0.002165396129461792253174784489950863711044117100898055792146427805,
                                 0.06737497888165636243581468065171775122623604722398072530351521932,
                                 0.1189850736924109823310266754670838012635096675136819770904684053,
                                 0.1486473889900589930433438070160980581022638480434045881930475516,
                                 0.1526637571004858481877496390202089461776043246000875500050573328,
                                 0.1319909631085512372071445944763776084457894830857488550126972083,
                                 0.09143133323365127084391281115514966742749836933964617713305516856,
                                 0.03831598473799322446484959453167130912315452507065635159559541307,
                                 -0.01898969078162544131778835545571678270553155493631084559636235206,
                                 -0.0724731560325156457201413834935318036256701968738941017387846654,
                                 -0.1155541079602477051322576915459976571693836959296168752395198062,
                                 -0.143754052557950014442615688544689805294122252183710053354904979,
                                 -0.1549442690895142540579985615878484869420418669880067707285747654,
                                 -0.1492288868138279779908213969745350291183239585593911822324799001,
                                 -0.1285609769594158698410009925559761743294543860330711766617801965,
                                 -0.09620432078651783465927484307086456633703665311805946907577774579,
                                 -0.05614707228398803255130626233988903155182485814433001963538448358,
                                 -0.01255309184177442971281759439555754393814707270350675758978582911,
                                 0.03069043538186740068957788904916911891402776293801657015716530311,
                                 0.07029827690520320814618560272222223443828275445329349266632353347,
                                 0.1037786599251039613089175509341730259299726970383344122402295489,
                                 0.1295024938325110364861139778931080020484823125417807254993547465,
                                 0.1466732372011135777878095654816124958767723074733980320396486418,
                                 0.1552255721371727964446297555867378845169436911457315958282764109,
                                 0.1556812980556019729744489170413587740181412577801902840465234991,
                                 0.1489876413506265156362936032964689691303132814172362530451323731,
                                 0.1363579899848287039879567240783358118063031376306839099467658823,
                                 0.1191291649192952400965402081109616891403665070210225844834773837,
                                 0.09864366859415124422269129743727510823215618041378943718254850867,
                                 0.07616049823315505419966823949252772597365429868336474284792164528,
                                 0.0527943711238446579469680468637600775067398683213249654698265833,
                                 0.02948063891921313308651226069155477509952527120649215498920097802,
                                 0.006961668239212290099278568966519351954814368110398302071505309974,
                                 -0.01421015480862966248322737034640298248326174437166884393097308389,
                                 -0.03365760304216442188150383773920354440446580573759196325798630809,
                                 -0.05115630592424449889674246541430534130573914253501498154255693078,
                                 -0.06660858890545371263513515748815262398536524139476809853407775672,
                                 -0.08001626999874366447823667041644612413450434258199482084679591124,
                                 -0.09145443798526146333657368543249303630136047267578552048029553068,
                                 -0.1010475299715341247691666282320476235083541415745282505210124854,
                                 -0.1089484406601903594727140450399727579483556924267345944698469083,
                                 -0.1153209442066920669776427304968687829775584355053817061501561136,
                                 -0.1203253879316968590669884582513908053763250717993608772748046524,
                                 -0.1241074115525485114171069591565090498664397440163655453397867268,
                                 -0.1267893373561364215068079684780731663538962388058890240698207698,
                                 -0.1284638461532127232916502642798310460913950401804330601380198957,
                                 -0.1291895824599009639847936008960527576059403783329613895819456928,
                                 -0.1289884040862717150475235798782960672148740064253166328974794753,
                                 -0.12784409282455165203711610571269551702337249824962659235807136,
                                 -0.1257024632302958786335017791052743181508952520245300730082619786,
                                 -0.1224729361483726696883285884761909358174904711843173364836775959,
                                 -0.1180317736949542814556976111791293817737487222142332235034188497,
                                 -0.1122272931462813186639814475441674386629803380322355353056783174,
                                 -0.1048874768644593797945432527499399975918166152878623130125049005,
                                 -0.095830459123244461907427322792062043081679911301887865956718188,
                                 -0.08487837964150786562022661862270849821182663217045483666494633956,
                                 -0.07187502475436783336279785797842470847357712009617622735861734039,
                                 -0.05670750387804247081011152981626984726321950749343088645889210008,
                                 -0.03933190308015641884857345545541830014931579851780841178267321827,
                                 -0.01980239303222081387170690222587467595891049654036645240003623473,
                                 0.001697372900560595893118816806146641612067081101452714204383164274,
                                 0.024822555513655131240932603674222777887459881261597765586763801,
                                 0.04903808270241090054437270040695134233795919042521987367930532146,
                                 0.07359628823732931704751689731185435828556350739056630859258276487,
                                 0.09752631359717734305138517340959227768992909171114046256082022207,
                                 0.1196412014716709957361425252381520821428361626447884898905461238,
                                 0.1385690244050675292447231555304065851929779479995323203867844957,
                                 0.152814071134951686306015753555362846296328221793704147400370482,
                                 0.1608527220096297087963285830200898180709010529639145123658285635,
                                 0.1612658600111121223606115190500697323513139296842488630773556087,
                                 0.1529052462105134507873902052974291489929240100682117877419079417,
                                 0.1350851835051236934765549196400451454369736734593875314500089492,
                                 0.1077832515003665632122665978503640193293683117974836636156809921,
                                 0.0718256000180101256882634386896815014200376535789308485592345817,
                                 0.02902444961626245827284145319687758907762854582998954879947936507,
                                 -0.0177701655639391442382794881208739436659425032554754409744226471,
                                 -0.06474352712795679960901797643300628643230254203849983886068838578,
                                 -0.1073475972580094356922347205792346311081033042197572747332027855,
                                 -0.1407091733310777433563678524927522253209579132650913748956843728,
                                 -0.1602083405070240813393292487623334952466367227371498455379132684,
                                 -0.1621860940381013721947461865154185723498492806263653833525783655,
                                 -0.1446990946984981677008540370191235881033668407143213764422316697,
                                 -0.1081989183082357313684203666019775170128773934640890211792969649,
                                 -0.0559826901963391351185665767681277922275671451028744719302442155,
                                 0.005746243955706320306171168054588117710241361073259704019205083925,
                                 0.06834282100194567405882387379019248091307353800374324979588459599,
                                 0.1217759415738333288593577192843508062727869448308189005070650597,
                                 0.1562282321913432808751090831506172994639676705308748950288315892,
                                 0.1640471650300994587273046234227895993174029522398242339201348606,
                                 0.1417029878601303687269420954831956027736704145766138261591987461,
                                 0.09129142054913094863613180965495478466191660848572101064550437527,
                                 0.02108461381395233735628916531015786271915060896258829333933020951,
                                 -0.05527279698704292480099074368899617939978412960426377169429087765,
                                 -0.1210809363153535652157772576913043781486573543862463923472153192,
                                 -0.1601934218897831905615077854155433846070877606881302685117223491,
                                 -0.1612491924844888342813335629622971888134980330850253778790693546,
                                 -0.1214682211538830674104950742728733273930179108186477043648128662,
                                 -0.04877152616942016919436641990078768567400813009615143091816360738,
                                 0.03884081642813335016112106131343659028235861475426578317517530705,
                                 0.1171223803654052648749054913771946588595728185492989783214609181,
                                 0.1621337998673623533475007582890411805025924406556405862783582417,
                                 0.1579377549747154515989666188129137601000085087272886741682674892,
                                 0.1030126906395016690848421034148939559464301191796450124689151794,
                                 0.01278690148917344754414358080760506206163611737668689683787419743,
                                 -0.08350825574105978453312781894116585751995942004748191132377699959,
                                 -0.1516982348102737164734573968602161050699389622006485601298526294,
                                 -0.1649628695671462925180170007061072390522208142207752815443498628,
                                 -0.1152905032031441623063200863120927493773827208092708892437321938,
                                 -0.01911200194658857912786308812543753434538084282528772777254032468,
                                 0.08650088336123772782710932154401821237271188159680785385950814944,
                                 0.1572664560166889746733428072367219343993724828390469454326372768,
                                 0.1604947130174996430324447355967770148637934360476081019801476108,
                                 0.09143697925875690983471726982872256184920488719409958042362814381,
                                 -0.02120935718016615688013465394890190967408510612262936503733679949,
                                 -0.12541316667495732342868863768142315993697174670729049990720739,
                                 -0.1692253741665712306836371737110201859574880736596443158589590522,
                                 -0.1275624352010121558119974876314569065737948148500004274717215806,
                                 -0.01844806105842768681961549349862202578016328555810276213723589205,
                                 0.1021748319473305935242066613231467665772664416650809302171844431,
                                 0.1677966998303732167129941146842931272256467431146730122812381212,
                                 0.1385740531943612186470902646531514615362742237190723312141942911,
                                 0.02766695851221735179406345020198953413539428748489152869786542064,
                                 -0.1013972948475998844754906694037902927870054006232098972250247878,
                                 -0.1693711452993888291989546329863480457183474476126182123782777162,
                                 -0.1305361096068293337571584680721852366689574337875326875301091492,
                                 -0.006017592065304565746356162892772696828162282680500612492228336272,
                                 0.1240838493901736750742341315897426390069300033719960416825068518,
                                 0.1705468352418996519797895958101832124575981816365574769812791536,
                                 0.09744272110013414504963846497751591747171915486106024541939210339,
                                 -0.04688539406889921864982550462867080429954370396861963376159838672,
                                 -0.1582058168115706808835700799120336865031512572517901614198286224,
                                 -0.150884182755831778948829203920916507853598376348447213529151358,
                                 -0.02635167346141801843552279959721806854301573510802153666471092312,
                                 0.1205051410509592053921159520086548112486343196814277965116908081,
                                 0.1709357206860477991986813908568931739807539003669226083308981936,
                                 0.07962559078209480775497554915038572897701178106964720704434454068,
                                 -0.08044503981361626844628401455961933357777331172346752611227614845,
                                 -0.1721248319726306653593274622004836470016046477606081331060357134,
                                 -0.1115018613143554003280958466539952121962929901544107958216937034,
                                 0.05118933572638449497781913101930862071366602335745212437093588065,
                                 0.1678821460642943052020320347164604905293486747495495275176630359,
                                 0.1262267322668979091499206984125400994351378331520645699716719135,
                                 -0.03828947394166915001715976081189986077254988835649783482732929472,
                                 -0.1664077831888862526652252644076053353501640140538174796753880929,
                                 -0.1274078712604707762262082115401657490964253692259704596191715383,
                                 0.0434486282021437771245295107589259510738398783763391223687522928,
                                 0.1700546357963308759506231390794333689337069920231533244259927621,
                                 0.1150514955135189773347675819625107161889306967662347003707195955,
                                 -0.06649270911825885316431349117831186982061645287493466746626600848,
                                 -0.1752565020488512116119426480403233220605811904934026088283831628,
                                 -0.08527348984012539029156430513535382384337016124621918065497756942,
                                 0.1044394378403691942309942038792381710900965336634579934727968956,
                                 0.1720804761906460802067712758991781879081513053870402601719979392,
                                 0.03281455403057896625600365099858101897697998670420936177240318235,
                                 -0.1477981327234984160104828486564850694433161447014077872441749835,
                                 -0.1449329684904789043139323545888931685277396987026338916580721802,
                                 0.04248957367105712334577991891864967991047505205089397067663286446,
                                 0.1761713215273995173933997115838274188406640722210401342577311572,
                                 0.07836232394703392984241563869663433675162909053716853171230638332,
                                 -0.1253190012489068020260539894507013878777767974316352116597522399,
                                 -0.1591759564102121831914318864074344812444900646930323930702634935,
                                 0.02792764527798735180065770383730651997091817699609802075148017995,
                                 0.1767533932395528780908310879654717000698993679103734768463025339,
                                 0.07248740645912800981160922111834405150790920173559895114155325709,
                                 -0.138325508743721722106395854185487183116984748048055409342780553,
                                 -0.1449318345446017125379742826417656584070196899866755616377430919,
                                 0.06721181630313829063341609891071225909467901056806936519115465483,
                                 0.1774432896238832552474335747526361768454798544378438070614392008,
                                 0.01171579977436808318615282958076387428381390399896529069979696773,
                                 -0.1734435310065865818536824301786627564529368872637541372251054323,
                                 -0.08064261208520998242998699593095809623112269625174568906647218848,
                                 0.144320083561020083246773620843788314199495380261561939456441493,
                                 0.1310752843184386451041463075298067553832453343681925009560430552,
                                 -0.1028768362612530364102454325886805136279931548063823003542235624,
                                 -0.1621185516462894251775260011535062322766474672969930859920255881,
                                 0.0595031970870435641833618133965040216151164976648626138649944316,
                                 0.1773698406167526577533982934568018777367570474969266484171765036,
                                 -0.02092541750227817810768328429143620153432035347430722826725950798,
                                 -0.1821120931283049680772914670115512825133320257525634507135475207,
                                 -0.009408107072276676867524007186026274868744152565998972008557172023,
                                 0.1814528868705377639759809203194174236199613997768545670777812951,
                                 0.03026185724532274231882156956298843820959929218666451268459111295,
                                 -0.1793829336743059767932759522659298869487543530433479510628691955,
                                 -0.04150447908430345776406822125095272987609567307805409306920867679,
                                 0.1784450154298369038884148986653540177191981030588133444538833151,
                                 0.04326657633400653559668185900704376975551182470844188776203607662,
                                 -0.1796806587880092924218735902196230768866462436651585536514432101,
                                 -0.03546911506283659951729367935385714621016912897156868473822596999,
                                 0.1826179508736936365944661143496194965524753260403391151005758537,
                                 0.01774603373774157673644909038610727248327497139994407578599900382,
                                 -0.1851993279497213728442776065347728935033428538530506851163963053,
                                 0.01021758874406120097689001963267681340870462080014107107730370289,
                                 0.1836978487628852793863067923954816170180490377216472649472806047,
                                 -0.04790032957204315808386758876015793613855866134608147001722499798,
                                 -0.1728349603910207509185307653290193541461998643396484651200336293,
                                 0.09273418203975351498365558297745640161148284782154645070284633936,
                                 0.1464773028326657090167198086334450439777489979729816259475308547,
                                 -0.1386890167411069347580217066863586692200610971224642191855448423,
                                 -0.09937772590290209763265634150211144442639175075380685070666186006,
                                 0.1752660105125204016120620318087448082271479921379265986275574779,
                                 0.03026002545287426632501684438827214839996861740680827351801182081,
                                 -0.1880406948186284819395245333505741622578113021194712277604164716,
                                 0.05412589846683508665113037736804723939170072092240451619323108177,
                                 0.1622285951068773625097786092553444221893087504846568965605495742,
                                 -0.1356904300279945680540986252627940418202869682363597115294881337,
                                 -0.09019724480503226263740364892217804693474732687417038033588128022,
                                 0.1858121286670438645492234730309276316050710377293937966220534567,
                                 -0.01843084937154025746890847519510202554443505562847936905556406332,
                                 -0.1743024379785383452824990447652806463401544503977448718175468914,
                                 0.1296035442499540351447141929041509839352163893001638114093671986,
                                 0.0878248506182593239916178771280057899858823297616406443566833206,
                                 -0.190092120670588657353588109903403423297325438069562187997364061,
                                 0.04894441049040177687695100428168723143113912459602343858659497181,
                                 0.1531518913614205001138664758769374092926331004921312451283453767,
                                 -0.1670119212406701080109894471169765972484006704811595858362985427,
                                 -0.01936927187710758819725388046099213665263408976656193502212173444,
                                 0.1824519030652133646893158277193584699530745052917490378450566025,
                                 -0.1359910623701385970794062928510866390209136506921568544829364721,
                                 -0.06245216937063068831772084881636557840172524657494754853492127637,
                                 0.1918766147191546282800916853896022276852453681148728932879494359,
                                 -0.1161829593702744206765375696113482804676315055968274275051792394,
                                 -0.07998734575885182699861145834401995484781909898217660678937694461,
                                 0.1941107670150093598469225429272593518944069284424913368126637719,
                                 -0.1158838852553130872850603680669611582741039319530575990776408036,
                                 -0.07340679722007719661163863869591071237146467941835988557518461834,
                                 0.1928643594664327244734352261992150316877549009950392462540608799,
                                 -0.1359114805778110526385009108129754385025189494830982142897195534,
                                 -0.04103121303501574240382758957989191105430597711435324292053994809,
                                 0.1814722202247906519222829343847121808319286962723390808099394771,
                                 -0.1693193568301577066456204264437809865034307531143334419057715703,
                                 0.02002343620861761620881735904214309471626502276237110543813103831,
                                 0.1438305686538197571632621249944022558503012295507831877000249353,
                                 -0.1968137098679659832441064727581916471864595748506422088190104905,
                                 0.1042519056749465983091317984196880524977389981375772675785770629,
                                 0.06181292862602930270091469427849684545032294533459910645125792482,
                                 -0.1836833052300228835063939346244818047299408431522990862142532512,
                                 0.1820474444807181992487442691142907974225490636143794452337288448,
                                 -0.06347835875185610850606963124169662442194541928627862438221913903,
                                 -0.09310571230063893740800892769576412351553905817849528072309828086,
                                 0.1923579926119226147738322856326499272633570395118185632022290985,
                                 -0.1800210204890996015529597745922112957466171307866459737766734413,
                                 0.06853366737744542680824018648770777028956902738362269041183639775,
                                 0.07778782447711558376964819222671328839348023672025934916132956686,
                                 -0.1825930273147555474438133877687356387761433912763795099189451551,
                                 0.1970653779124357311060838811747389645552006294864539290371356203,
                                 -0.119610245744788215700987889796256080707884408443607358606674115,
                                 -0.009806743656199494547325668520692795508509259128470558622018131833,
                                 0.1329379141282757970793196432781405756704524505487545129969755424,
                                 -0.2002412118029033762365305277550578081042468475462522054967095823,
                                 0.1893874826598919828338425314847423502214948428954425687184656977,
                                 -0.1096384070070382121822817676064359932181998773209628937620729166,
                                 -0.006451342947968338071557412364916370848875245210246134613864118647,
                                 0.1180266425716333548404827611865722276881773070443696305728857513,
                                 -0.1907188582361353510669605912781702484402269696264119418470302788,
                                 0.2062449108000093498328001693612529063769582063259361524320024097,
                                 -0.1649696225648986770155723896526554724376749712538520613969819961,
                                 0.08240504992109474394697337019572785414156865187644930806570823427,
                                 0.01774992920121964431018979575116233502541986037958839800994103714,
                                 -0.1111391143903773374546777589211349672827923312584816439936766056,
                                 0.1786489157456298085005539749043853081477388532020830267177627261,
                                 -0.2095968760446417411731694208284028888761336581258923627189173509,
                                 0.2021823876750486862412102996392990823694632909117556435931668014,
                                 -0.1618814236123209239151994694024347817189794910948961395043286383,
                                 0.09875396351033582883991514140511890082088357231470232414688591704,
                                 -0.02457435243350448598063413436892248382303970569257153609185190657,
                                 -0.04956571503793671695649852545966820152648944110177765861947067127,
                                 0.1148527024308116998889391299547136826908732095433643417651227518,
                                 -0.1654959709680992628640642756579481693489042643502708591994956041,
                                 0.1987605559427885944696592437261847830744404004631629053374120087,
                                 -0.2145158176179256250164100529495677247729977296125909391204102596,
                                 0.2145369883430615402295576895719993372822206006566583395643269264,
                                 -0.2017556879549221569237153639159735698065344636684191782561442921,
                                 0.179592971149098953902611681562096956147203692311474838737840385,
                                 -0.1514456635859227154759807355386609378930897150060647077790991653,
                                 0.1203459607997602112870375849240456465794641455865264451211945158,
                                 -0.08878011069493384861926479941672726099469120991651287877916453405,
                                 0.05863379811425936863960333783065323946456514003682959439513745109,
                                 -0.03122613288910025431288914046917251099955814595559095371224572513,
                                 0.007396606677682654626296178787102225568515569590770649258312098447,
                                 0.01238389338755986001032147738065750470988003369998522167012673735,
                                 -0.02789891337355165605838533112848427856504965368066876778385629021,
                                 0.03908260279582710606107623362870227357897943631562201066090355456,
                                 -0.04593392343795724963226071787657242219698079047042425175601203436,
                                 0.04845270241167560947556941601079862992243657316664826894994191374,
                                 -0.04659924059396597889558932897527702245657941089887002107873639794,
                                 0.04027853541804042482985490481458675084930026442630567426616255682,
                                 -0.0293504859588477024600278448346553222084599616364059439329808694,
                                 0.01366815545524466084242388962040730996389438251381999966044458905,
                                 0.006853376908681702800848104584899879436120308275166435796399212307,
                                 -0.03213559750897688968942316509825120797623398433889287539782884562,
                                 0.06180304404027379103845482235186375634319991573887035000716014762,
                                 -0.09502346205242711805213497939308725335385951500877924401825550244,
                                 0.1303363899460221709190134887506033921427037746846454746553286451,
                                 -0.1654980002146330190267690006351112391248496229042529770857292374,
                                 0.1973864996422548460317439728780970258546061686201507255340813222,
                                 -0.2220297296187015220161571150969557728271944125980670984240910147,
                                 0.2348295188301973569148103600574174205473513022392991727480649587,
                                 -0.2310571886400257488101597999105867176259424386907396364685632013,
                                 0.2066697536442032286985622541457060155579763747605233747515843892,
                                 -0.1594343296620778376901131789734876978649513214737478515096558933,
                                 0.09024076062886658045467134672367313503732124783625210651685654793,
                                 -0.004333637288742865446947235714792996124253983523421213314787446803,
                                 -0.08796818845684216283262385832389778310726773685270024841152817249,
                                 0.1716145323960663530326948396618511339011774433714892841014343844,
                                 -0.2287601935393784087850394198333098842609714324789874890832745663,
                                 0.242562931313659446817768314547954007772069002403867454750969925,
                                 -0.2025301007661845138656475973125209414230851886307921312748870979,
                                 0.1102330052599805234007988475784966052064026392610905283097534559,
                                 0.0167234093988096804973029885229208798543847808438869843794907573,
                                 -0.1451251061056893673036400499754875554930232060908538652183647346,
                                 0.2331428349842738205188307591096568762372403560302488758033179111,
                                 -0.2440724618191213293240266282496505195842409172129426003182361767,
                                 0.1635265788304294694863710011141559014711074834063427658366339691,
                                 -0.01292604470324109259698038793892832203134887074694960965202585877,
                                 -0.1498365900818865332891997815711358346113598282389204103147588858,
                                 0.2490489269212110968628830028004551483526783738535215681979005994,
                                 -0.2269340533740828751164777471195225202497654087426780539265319588,
                                 0.08172350090403664572018375846238400833823027874765263424325797397,
                                 0.1161441537605141292761599777810701363349354034827245751113540114,
                                 -0.2503850429874952510167906218805105666233794816510760067368151561,
                                 0.2263584936789889662543187309113430024715816054909231999491647016,
                                 -0.04462568039701190981636756810425480423655912442164376371072482531,
                                 -0.1764061270779846895901922922194775049258835141363671153468274562,
                                 0.2678002721025839457554509636200150290464333914261268125785935913,
                                 -0.141661276880422656366952274702294834750052253487431168732282846,
                                 -0.1120885397755404761189093926742539715496454156048323841166731604,
                                 0.2712045408044142215843503642001864094438578371238679171713613352,
                                 -0.1726605906622262678196076382759416418371444682984193365100744181,
                                 -0.1052623002909523902321130354512978868434768254626982239710829127,
                                 0.2788684805605508383085624965938638916908446533420133075534379941,
                                 -0.1430579316690996977774693643023439138408753748646519627740407711,
                                 -0.1664479540904197673881618281095912990436709489019174643349412876,
                                 0.2782174908708289295276215087712218827421035333142632400228538107,
                                 -0.03059741893955142282119372095576273753854770846694323625611459083,
                                 -0.2659834827840777983847914327271312451681062767736608268466380922,
                                 0.1909812432962202926851340386849692199468731555861398438994783164,
                                 0.1715104393705370446315817461080986020027307437740874874735629128,
                                 -0.2762745613811602482251711382965334893477772434198970474645433942,
                                 -0.06655517505437312947418966235959652630787040600162045386296973792,
                                 0.305422970043592656399609772248877431047956821999205797596525942,
                                 -0.008759589255702381289966088468981292377435421367139565048687703091,
                                 -0.3119260350510506008546185721217066534523190199434388772732882292,
                                 0.04024123848644319068943031402993459010174071641215778383515461637,
                                 0.319103247719128201375747761947110890907201248061959364261039117,
                                 -0.02213372154734140367416924227414824097378513441307561201667245622,
                                 -0.3302902376302088790217001028989080696516822525210465780559001813,
                                 -0.05270505035638620262208267579388862081638303072854352688367921775,
                                 0.3217757163806478752673285436797523699195244820031479539944778685,
                                 0.1842808352505056372799415198167189622996194229592720517483053583,
                                 -0.2380203019971158035944441034961305441664467221750938325875077373,
                                 -0.3291451736298231052314485825290459078601906287194866645303912722,
                                 0.01778154127657497560302015149724460646017374822617648876162124933,
                                 0.350761009024114319788016327696742221484443250893087208211128178,
                                 0.2921527810559594668815688954853101495500003529749380920934696589,
                                 -0.07026553294928951509908431163180311641823742785379146759843349896,
                                 -0.3755338231404319119343969515801702395432685763782640639025625479,
                                 -0.3788142936776580743472439164996748505049914364214036828099926656,
                                 -0.112325067692966089187463100140195786015095565641771304861707597,
                                 0.227407428201685575991924436037873799460772225417096716495790034,
                                 0.4642565777488694064742733669192415853002428908919871896677878055,
                                 0.5355608832923521187995165656388747074669308976836170027706315172,
                                 0.4757280916105395887986437782813071504876098160591710878821805899,
                                 0.3550280538878172392600631860041831763979791741991772405833265103,
                                 0.2316936064808334897691252545099217396183864753577499817922638265,
                                 0.1352924163128814155241474235154663061749441429883307060091020548,
                                 0.07174949700810540967355541648967751360575177846439507536437735424,
                                 0.03492413042327437913532208079180760976106021389758320718866991321,
                                 0.01572592338047048999526604654076416845431582321747644909480096439,
                                 0.006591139357460719144257448407961351071732721347830668569901494979,
                                 0.002584098786989634963277144783300278450196310964647890734254683002,
                                 0.000951563851204801873621499968900128760027687802273779259618329551,
                                 0.0003302503235143089836587325900993362341337857764094534602671133769,
                                 0.0001083444281360744173498650250334598047957778347968893913351294252,
                                 0.00003368531190859981442528973405694337028275490527586196326324466348,
                                 9.947694360252889570238847668828779047342703413814845875507166423e-6,
                                 2.795882343204913585459995748810918799173873179064120576024820097e-6,
                                 7.492128863997167080771040272103909935141514805069222333736929196e-7,
                                 1.917256067513430751645002898931038676097379739122408999819866696e-7,
                                 4.692207616099231625649081703488224455252887658634213853311893662e-8,
                                 1.09970097551955065094906290807442618663368103651953552478876173e-8,
                                 2.471168430872489843289241134339096458065099206406723640789297353e-9,
                                 5.330263704617491626585486669522154654113433185163263510616992945e-10,
                                 1.104753255289868593355020565799224106876541668522205287525715188e-10,
                                 2.202274519283401643530304396355786042769642913920437692012054769e-11,
                                 4.226275864960359591298835450795907830254313164165150579579586945e-12,
                                 7.814290183962854346130297587929236294188819708844859892106679282e-13,
                                 1.393184688875360839049034503195532280649366967312148386901444304e-13,
                                 2.396827826078049936281668939411420051948030617019384218679812278e-14,
                                 3.981776078833335363022547078760319691402315022566165854472700691e-15,
                                 6.39167387674186665067872025336168514483704158881798262828122433e-16,
                                 9.92020549119237726631733288213253639980424173874371299985383685e-17,
                                 1.489537454965927195298039298952951890026013769961905054328675127e-17,
                                 2.164962520737992298989454038808459772579067488151036757787605216e-18,
                                 3.047538152456012684173786516247571115487467626480073432233140192e-19,
                                 4.156888828917024394747937619181497126750530577043424428506309598e-20,
                                 5.496911172967060763600712738317866239623317083472054915242874332e-21,
                                 7.05019729838861454244144716286984717900845307482477633235170699e-22,
                                 8.774220823294709737521657693714809080429055327748130326528866265e-23,
                                 1.060046682524795565634125585294033112995590362516522441314644319e-23,
                                 1.243733766971940457467866405744939385417582741822483467635685624e-24,
                                 1.417704377793352718937684362985429804546997135165745907424213419e-25,
                                 1.570590561517818377578549910856260840476655651940932538045648554e-26,
                                 1.691672868670540313553560212509351322370018092557614094610271382e-27,
                                 1.772136354314942104047501740834443133255363160454038373096249963e-28,
                                 1.806138442470383379480240357005506627391980746555984835020129389e-29,
                                 1.791508017269441364627314273605300797925212763812831898363508589e-30,
                                 1.729960240353698285290118861064631905717861896931359565695082634e-31,
                                 1.626800856851621560690369682322312670896070867481999419848086863e-32,
                                 1.490186095767206091032867927397374850950859669679377336817866101e-33,
                                 1.330078628939432760230020425565863893815337765861258578723741029e-34,
                                 1.157081085398542465860530587135242141712743207406287123908155657e-35,
                                 9.813303797462994780418646960981665337866146133285886703365092975e-37,
                                 8.116026824691386683758343296410234497191176592178879904195209414e-38,
                                 6.547220618442566694960128709935752459592501688877996580701975687e-39,
                                 5.153011145198340303609474433998916607584305598285064881194010433e-40,
                                 3.957838947992781643763624430183010264269356317731211945345214209e-41,
                                 2.967204922863166517969256954606180638160050810487039975956617182e-42,
                                 2.17183121355936136267608523325127913302469881320449609056688222e-43,
                                 1.552343448341592586671362486312389727546793677572651233391452831e-44,
                                 1.08373818565872701384810013543133783891938738523661567609032246e-45,
                                 7.391370577886336605077244315660809137433772438891533961356101921e-47,
                                 4.925797392817714742351921615737319900514741564265715380477672073e-48,
                                 3.208217591550495571075286933184752796566851921757606493445484049e-49,
                                 2.042534616669260159633022584499526812871949290826341964398567666e-50,
                                 1.271375950934322052293414993222636546883194528133370601918155892e-51,
                                 7.738489497569193001995209545676053675279177836469592525011447702e-53,
                                 4.606731112410231978165153072658465265085151017938967435531631463e-54,
                                 2.682619181084193829981404017079957710304684503510918115410040822e-55,
                                 1.528368213265633990489569064848240404675819636802774441936181172e-56,
                                 8.520624697779130605543508041468467274094835987720122425895341964e-58,
                                 4.648998546665167122122433490688220110357679814305707795364061676e-59,
                                 2.482906967949391519694215549557485603524228242086194791149225334e-60,
                                 1.298199973121842694438451674761602224714440931357337294089386546e-61,
                                 6.646124558420039097521323048494431263654469794759577697751655762e-63,
                                 3.332002595117602923461850363235447843230242494593368000490144656e-64,
                                 1.636119688941266542813503554648157572239085753008708465947154696e-65,
                                 7.869720746886599727549201271358164045464774884350167209524348776e-67,
                                 3.708501569400533695078482502704763072106423524303354738909695812e-68,
                                 1.712346650359580746925431127228345513678044963179548536306353203e-69,
                                 7.748131912810873542599857573744375599730630261078723637828173392e-71,
                                 3.436143676476105419450756388884040194436906939349196418444584476e-72,
                                 1.49372421492293495762652024911248649745208644212260217940197792e-73,
                                 6.365742658552914909567364686554155772681698877341682297888971584e-75,
                                 2.659873693220846222809027991892090441623081514369762229991597886e-76,
                                 1.089830530912485150147927664342566876890595102994182582995814099e-77,
                                 4.379199446522417934203121732142519512273130430396490657996250971e-79,
                                 1.725913900947648756536097089488276159219049443024891738290485136e-80,
                                 6.672400684314823546822254344403078104426076518442936299293350761e-82,
                                 2.530653969371560787347319170285091929987507707613836245860771091e-83,
                                 9.417145543781844749370415629668211180145616969575351212577252413e-85,
                                 3.438658557280137397811909347177447431279642087858856283313158976e-86,
                                 1.232221161038165945998605876299243109465562994811107102366260618e-87,
                                 4.333750512851099575397040561070288264436198854675827790932763122e-89,
                                 1.496097245129543510424210014670370942217770990417734650742656842e-90,
                                 5.070148892227303488996820085467597371851272124996497034679056121e-92,
                                 1.686903173518091236287213832518811072043171771879546205451931074e-93,
                                 5.51075404757218163285404410817771935008798552000258967654452236e-95,
                                 1.767769063797000876946132290984131782527711725377092557503586063e-96,
                                 5.568974017338446713956461041457188334871054574679627082026833548e-98,
                                 1.723061986369372995107266866865650517411061447768023848826065366e-99,
                                 5.236521782224858746106107843515860279108736194064596697135892786e-101,
                                 1.56329476268396608182806080984227244995364923292263389885266789e-102,
                                 4.584941724074828478347549647752186493373046357115664394277696211e-104,
                                 1.321174598222367496284487345553613325333142238417363948762160468e-105,
                                 3.740743654664774552370859817405783178180190834695107499257132767e-107,
                                 1.040792976800197551158090271842790652646654722970937649563073045e-108,
                                 2.845877633653958852536616295487051516157640747263213858169812794e-110,
                                 7.648034168118402384244031946570643478846826080105188073991409903e-112,
                                 2.020230347312425344719005399729920815873920865647924336133487226e-113,
                                 5.245714835356469902760425128805226658816035463381849163029904809e-115,
                                 1.339047339572099338866325205128950275389167922381941045440287634e-116,
                                 3.360538827468289022724091569711864711567497981323873911575380792e-118,
                                 8.292346395783181552739074202073636771415807250447564703251725372e-120,
                                 2.012031719069944719396503273336578937498394417158328551075756079e-121,
                                 4.800803920642208645029021602434189127564929641517014907441492763e-123,
                                 1.126541827350855693028146909292999567768671359598673874546556262e-124,
                                 2.59996140458506813974743621399102698365946429287001847720940785e-126,
                                 5.902069336192245982369847879663075105372665493252927158891341515e-128,
                                 1.317925095335732252312000247449522338957192966378526183194726066e-129,
                                 2.895055863746456686459079129787023916634408895743332321778951358e-131,
                                 6.256527549941553584921282686298297791383782865470497485195426506e-133,
                                 1.330301169371422147755902019077241715123728763314757009535659028e-134,
                                 2.783148709496935537097603938247637105692285857980137196619033786e-136,
                                 5.729568803249442700815679292315219405073428486813470510257089754e-138,
                                 1.160741336269287501532008653115808739953447825592429859748869051e-139,
                                 2.314224519543972756003358296726168886865985685517460942727402898e-141,
                                 4.541091517397308612091320747440659730888302869615111337631200855e-143,
                                 8.770565519900959982884889190554880238359100781269391139033645269e-145,
                                 1.667381739817839565243451024387235702251267091134956050635327381e-146,
                                 3.120396488436392203475314281961839158432789673519813705099699264e-148,
                                 5.748819722355149832447814861442483837742893766714250148307492271e-150,
                                 1.042721500944056602935879564724162966817437751615661365400144808e-151,
                                 1.862108356733616863133257705483085400522753841054710071438654079e-153,
                                 3.274270083584454093936988340551966627792891082781501892620984788e-155,
                                 5.669211171526504212568647125312465756222112541582919954685969483e-157,
                                 9.666176334222782544728740498075228495967911953885369720424308831e-159,
                                 1.623064630534994332836377664309154688772572903678405479779951087e-160,
                                 2.68405079997509456542492218358271458188343070674187800264242315e-162,
                                 4.371635931343786076685404308467942088487687089569881617037322622e-164,
                                 7.013258252609644497729288152022042134995645618640204251825017168e-166,
                                 1.108261511177581084657655623275107589629656342481489775500882253e-167,
                                 1.725182208880497768948836967543673071208545584552192280318239288e-169,
                                 2.645583425824027955175106515855170486043878827457395106702664865e-171,
                                 3.996915260582768856186662873166726287762117277758368464528680662e-173,
                                 5.949334422648301288484250751646500789358995369930156104779294833e-175,
                                 8.725182406412876283202429856143719388007156728530773683611171177e-177,
                                 1.260856992855033656184407315686051755331540994855276952382087553e-178,
                                 1.795413926032604398746483630641583231840940542489350929329402964e-180,
                                 2.519375009322647461093405953302765521030267668831831637229024869e-182,
                                 3.483953232348130035804407017431521659098907166024342542403873941e-184,
                                 4.748152593877340369359597380244405687182274655658841427080767679e-186,
                                 6.37780493266078654488723245648633267520449918660723685168668371e-188,
                                 8.443707036018079440356222390822642102208071225048691069766542409e-190,
                                 1.101872582415134320587889841482037378899654717601971510811858849e-191,
                                 1.417381045416278590678988371040333393379743392983301219789534346e-193,
                                 1.797295189444894736224508641866486394088945966169008415409308099e-195,
                                 2.246725803725829739821921903083210417106277320324868164797171901e-197,
                                 2.768845542310667313634814536727904427712779361289675400951695932e-199,
                                 3.364227153493629973587313534805870267291451959235073779272734655e-201,
                                 4.030227468914761792683546698966224096788496875599185895892623151e-203,
                                 4.760483029131417026195409567703388849232446625680594032318462162e-205,
                                 5.544585243848789097974337595148318380120580709012221931347355124e-207,
                                 6.367997325597162863213142605784980866251714246343699795887877477e-209,
                                 7.212261206010255510763482454680968074245332420373676555671692437e-211,
                                 8.055520658550761597260110697125395744141258714842073689868641901e-213,
                                 8.873358547517777183475790125093666345648192020281093936454798164e-215,
                                 9.639914285256551949820540288565348652277779624263261155918603414e-217,
                                 1.032921585808443200926128801221306780514893187285012297997281265e-218,
                                 1.09166332274264345510445352001556729607521201176782855010637454e-220,
                                 1.138034039313084673341457732870962094563929635862083649011195547e-222,
                                 1.170266499490285905484294432622567972389783893546275313570561026e-224,
                                 1.187120877918450979350514875780718062174861273357970498975862811e-226,
                                 1.187963966195738311573601763551614101440391593995123794820578344e-228,
                                 1.172808480695396406145684662000754690872367542029950692447792081e-230,
                                 1.142309088269039231412972203404115556210023855776707800704092178e-232,
                                 1.097715811072059272313999376614015871376229585576507668462986357e-234,
                                 1.040789403181221768850816607128315196114523989921186510592210145e-236,
                                 9.736866471238060295508477010840554346667498368548010388121921351e-239,
                                 8.988259227978483807784565765011295216576228752096115599620724181e-241,
                                 8.187446172481816594653316938357475375143875588499078114121825937e-243,
                                 7.359598989453857903114512264873556568135717513487682928346311291e-245,
                                 6.528431673507594139971928700777936697788787805188810205217573909e-247,
                                 5.715163408001596712440075595420650347877414692206519029187437346e-249,
                                 4.937753926954072565828100916307964837213935714237048782826210223e-251,
                                 4.210435593007885101392106168024390157123354317925067485632196613e-253,
                                 3.543537807902358532484561826972339729926341061949581130849860145e-255,
                                 2.943574995016014798757627437238859432320260864373659011424101097e-257,
                                 2.413551326150786032125059373087143094508060587275859446478356551e-259,
                                 1.953424613027975057986676532692833949550391515447795712069362176e-261,
                                 1.560668320577763905198034932775337731331522118513717964176242875e-263,
                                 1.230873595908090866166510017790963670230064806003094241512501879e-265,
                                 9.583410603610656708104400309712277361679075008176916563575527753e-268,
                                 7.366231046275380704225837686416341237652311395963918984614835876e-270,
                                 5.58989771278010428931970838571447637406344050473187156268663743e-272,
                                 4.188034372053992017121378931259237009050188339706558908372463683e-274,
                                 3.097982216231894452798115634568211407626000816258400404124262179e-276,
                                 2.262685805582112001436228987856304095515531182295020167066003568e-278,
                                 1.631775713394049903012814092653453516240250423243052446437482986e-280,
                                 1.161988099626561601767023591600406573871677465091983013404597181e-282,
                                 8.170749809285320456554156716647506557760552353385649728783010162e-285,
                                 5.673552384334714202944663515483492791116775217575425415809690052e-287,
                                 3.890406233258680805691048430914067085547100811865580637104923389e-289,
                                 2.634482152088184489550552569526498156135769967181276977696125861e-291,
                                 1.761852672801185065625287867289894626927871003626011579759361666e-293,
                                 1.163674274582250802382795828492336346520305097474391675235970757e-295,
                                 7.590916011966594356598354378362503750099853537169354543494568355e-298,
                                 4.890701348665263847666002357312956831766768372648184397355756879e-300,
                                 3.112257357030895994196531593616789671750130807424122221438442532e-302,
                                 1.956232022933922380729902664804330609834139156124708549067638543e-304,
                                 1.214559328776030765198992348881970692748756950313192271026500683e-306,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0]
        let dai: [Double] = [-0.2600066454334060227629078515692441970190117213062619527587326506,
                             -1.669232005410972452991134842178876154968284214370714714760874707,
                             -2.106198174089720426501871129289610234205916259591025812627813641,
                             -1.356007951514756734775753630348627132462888215696937724385717564,
                             0.1310530929446612166672916152083637837520821235818376197623207875,
                             1.531828638984654240212277249902988918738959331122065987438358045,
                             2.113192214898185353342779653466519648647798173420230005427921379,
                             1.60404976341331529585526362606718375645878786678323593725607961,
                             0.29679990720160864244664006157991753356029226367736319315191345,
                             -1.140718560920837111469694000496750345798034003980109991701878038,
                             -2.016554339162000866129928255712896072528230135385632145476857061,
                             -1.941981288037337363190177713115499947261031472235230426105099984,
                             -0.9852764361880688811527307645108725555617611924993360994833483472,
                             0.3965165320427100397117575229814057385120554034420837452366252005,
                             1.589671218588424559128121082378741890589574486483529388725891974,
                             2.09832035579354017408845878965755414949793339750565909967873469,
                             1.739978348677094759120250618877105487204899806574809234195202759,
                             0.6918414852003301389084178423238332907940169931394312231880849107,
                             -0.6109055310186485820512090985981201517930428648372011438669006003,
                             -1.665039190904666204404238282232195045738075360983989878968446301,
                             -2.093030162221620302362611496548293100438386489464200724607009278,
                             -1.768122471308461539633897178517073872316033558596380792559369438,
                             -0.8352283858665254070971181826279301512593583795543055199215492584,
                             0.3648219615760588239025875445009359533244915498404553017581001839,
                             1.427749259519639687700000253362058593325826262544814930114864122,
                             2.022599319602031448432589903670636617051418688343207579180262832,
                             1.987954084683612029223525782684953568711058869594489642277710033,
                             1.363504310481065068109839465021758291150586486235118440986460909,
                             0.3573079829236922958414669444898830155856163110824115808615560126,
                             -0.7314950401662068889809303082959417514398582878918939920406906417,
                             -1.605193254259707227004879706009813899236608103716621303164305331,
                             -2.046948263285790723221574993634585335683626496173183698389494512,
                             -1.967796442393392204660950808228991524680755603396165527027619792,
                             -1.414266047882576432793773754551875616354295956975343160026032719,
                             -0.5413375613044740863671400698270699991661959801480112334443369543,
                             0.4366167455504172003643904301154774433853036709592586104155978985,
                             1.301331875021010380882261623660486095053549388590155984750336955,
                             1.878588018846981517902574181253483289429257184841996168175693178,
                             2.069199200465246062769710337987191333768524061243064235601769832,
                             1.859432736834953013988463755845638632290328419282751926466545447,
                             1.312504634347700006193706406360674237411698177330725724479998732,
                             0.5464664732823899411486262646968883963790310818105508066875345264,
                             -0.2945443934477849922355812252492889696296919880788597843066530352,
                             -1.068920258238299390922411290388455362124164225528835241329124352,
                             -1.6608228237998451151348000160500974217237432366226100988092009,
                             -1.994996042897385473249363532375662156279962575003060353466084502,
                             -2.042331901022934612575009718822317787284023748040973338951155335,
                             -1.81719119838073394120020242630516825526653257805687371775235498,
                             -1.36865728726559388504675962844998567424765810990443604089711173,
                             -0.768389428769217906826180243333007297691076054362634468690459232,
                             -0.09764685698181448395834795633819695699065235399992544264541609414,
                             0.5644437199578360791764221643256345136077623596132286195328262886,
                             1.150005189237597768226378089103145972336037452925201401450069165,
                             1.608267151069722319341034514520107197025660037979157282504432041,
                             1.908146197739115656483269285751791229537444531730625698106343708,
                             2.0379896330327905350837547284495796001051324413335975219619348,
                             2.003189099520996801429193312026324220873657505223766497084107611,
                             1.82246250291716059765909731087055575538037325424842438870931607,
                             1.523559134534798614227866359870880410959122437694415679553806811,
                             1.139011286634921008806060611707938701468692854123698545916121432,
                             0.7023812772992844610151816934017805917308552448940293211324248108,
                             0.2452726193219659459594408799829170046102943730242394997479188337,
                             -0.2047861401306407661666088274866291441908153872497946777018908004,
                             -0.6256020655964951783913881184734548670462321757312745361895089691,
                             -1.000826235583234069639168551609371292362281336918691411783738147,
                             -1.319861620082531153195019761197845856136576652027189010217385717,
                             -1.577339112581541182104404439812437598723328445057353959230508126,
                             -1.772323982461287295590285216215954363816357618001371266666052136,
                             -1.907393513677700154028927057538699554346358548412086384915302822,
                             -1.987697321081285376405441471412709194301630966914429405840445631,
                             -2.0200805305884258284170583740934027231101946972451050315976928,
                             -2.012320685264536448598499077160631231295411762716255198571658509,
                             -1.972504300396855783360868199386288563087025819345114173597803771,
                             -1.908549520105459969125380325266559899915964714769301872111339337,
                             -1.827867435787594570353738907816770063817754257033586739919020235,
                             -1.737145787890225411439364024653139073668826017991604244942796409,
                             -1.642234117087153886026495300553690994176721434072818383684356975,
                             -1.548107965717485105773283485651516341196204465743454406181328763,
                             -1.458890492208740245485594383998021394815267113204223147580823525,
                             -1.377912009420337901190421280115181883516071017409664018973325952,
                             -1.307790818203421451068730931054316532059436214242897353355824136,
                             -1.250521782129505708557287240581867936268888702613502517988996826,
                             -1.207562044764598428017410387747423817057859853939538687859246996,
                             -1.179905934157850836316719206944121539848980217838339561643360342,
                             -1.168143350163814140379068956212242600936361489918232326998681999,
                             -1.172497793947336406668156243876743135622578142068077122768800002,
                             -1.192841741845879869320578845425205971401087489142094388568222199,
                             -1.228688395188487505860229660786505188123772401416525436648445565,
                             -1.279160086175564546310808207766661445040801497772371019510462966,
                             -1.342934931373812427001405791907116940208702850991346791544090191,
                             -1.41817484132810258299511436009515615893621416820343018717346226,
                             -1.502439844714220979337647232450199382459977210779283945704648685,
                             -1.592595963962908274802198829898882366612446076665888546031273115,
                             -1.684726628618431379431739153745700541852805096087711069635638482,
                             -1.77406079450289385972751337995377016487323678369500409798902122,
                             -1.85493439926929992829170631938220684298122414940622430534548377,
                             -1.920805226407799931996592069898574151741366537617088238825190498,
                             -1.964344182641037034467740472088121120174874268684114388426133373,
                             -1.97762771687342645103357983249959315276016900772022409308137819,
                             -1.952455700069595335035252544974373049379484118762764498269113716,
                             -1.880815428154091231258692211661395554669438832760186956795203456,
                             -1.755504274731158041050206529822418336790586090453588137397260198,
                             -1.570909719293384348299548887752389673831854563515717133618504589,
                             -1.323925108939638806457443664316971003259004360035098846311417656,
                             -1.014952307978600041244060517519375637823254726174638442147169938,
                             -0.6489091444458061340733271550598195932860357922104977804305597842,
                             -0.2361226158355426263367547006518295075984477959327853557424248044,
                             0.2070474919391692904239005584113286936603539181307188652943699467,
                             0.6580389506822539978256047509000663021919019785109720001625087076,
                             1.088568632768756771042366800115762847194308822523900580250923348,
                             1.465948561050917219715500402030417667870866923813528256778452774,
                             1.755368118968284652176297682155859243638171354582729420639858961,
                             1.923175588935098172955825884213134716553851554483339053853749155,
                             1.941042804443320194070622685614106122954071541292453956991862389,
                             1.790701202158896490263987650366100540063748587958961626052171677,
                             1.468713477913987030660617019431279451204848044916126650500840254,
                             0.9905256142917355521365924814744466680928357777123156050111338639,
                             0.3928787297105873108243816213734168928187984614261387651817147169,
                             -0.266388808618598136302083066124501674096518117619594901377151192,
                             -0.9119854686791534539320421715877704534605001856678297319914448183,
                             -1.45872417301604703937136741528187231849646792656400595253126701,
                             -1.822834646437019786658046020907801592444582171395355555184710431,
                             -1.936023947677654273688334027983689043671799777315088598549948492,
                             -1.760321168858174926093326622313869908134833237344177604569464031,
                             -1.300871257724313175555611927011430888743761188337385998123212557,
                             -0.6133247526548818035119013360584477904917159862115835479918146023,
                             0.1974027861584322691065798198789546738868324892311099242503468437,
                             0.9892148074369528484874734988636574929930162903646114308001408816,
                             1.60598803113593488537910357679836609505514618698597197723915921,
                             1.909235457780370537340143423629390982336439133319230501993438737,
                             1.812627839463788063115488612758944045251239009846190876513056579,
                             1.311156496265076018896001785132698306403509376202808234732613218,
                             0.4956892121261966421500058641423009446244010067015448455397101497,
                             -0.4548879456699996056773807042207930304961890440296379717030688536,
                             -1.307353545742271354808264728891821333008900077357748657206565444,
                             -1.830078214974598314599932997966583928890573164820392857259670839,
                             -1.859487137353435930112632250200232864716146282487643037279274154,
                             -1.358562832228504590785648387709495522566569386389440337911639354,
                             -0.4464316688546316622554325948089168459706754661673456882617240849,
                             0.6175771842117886323233682082393722929026417262445798567455150988,
                             1.500125193991563955475662925379174556908216904233531541413017268,
                             1.897689394078130614762021710827991702410901478504327335515547185,
                             1.647778500595816631894238369391145685271223835237109356714033517,
                             0.8066772426388197657470785076023555066324365181099098956171662653,
                             -0.3438818339490362051964707083539807462956551783117983164952070089,
                             -1.378452242198814874086904308686754713746422095445983744372464602,
                             -1.881734035081134964362269441751283199561811372557837875850126397,
                             -1.622659321018945364198010652537119816975604406444549825940990039,
                             -0.6754796409913257739357572106834422655045230086223004161124692032,
                             0.5775758235428548372114496974797700922899979925073190762255241986,
                             1.585655260126794215277894153062059795495050348036731761594444989,
                             1.869632129363474412559809570139602019238399281775988885723879227,
                             1.26237121124827742225907342990667986949996731524343359406723732,
                             0.02606832183513023402845253465448801965468559840985071257035807706,
                             -1.23668551993211813091148240198145025500517115840415116941036441,
                             -1.86587649461004795215004460630671774888066465625939367751903649,
                             -1.497189952619264994582706918357966366014410196655728563533695486,
                             -0.2958199291882723679432282712411296776342552944700585306012749099,
                             1.085585205347081546111326088894142056761879461717631467243844428,
                             1.844489355547270432295972217786502181457582574610137993324334099,
                             1.500835331536654311699580311932197002931993144287979491309608913,
                             0.2267820138455371831701000187612906393248048456784046711466120605,
                             -1.202201614256865145131559696700624748981879609676146427943242827,
                             -1.860323865524493689555817734683676694419983814368539630650558291,
                             -1.280716348130426393202496032569894661000874549022964889723906273,
                             0.181375061585954893254800195092824549240382525546536012612818661,
                             1.527337266186933688996358391095821465238976285758538769968499261,
                             1.783039410164993684051738663316099722091139182597278346309420766,
                             0.7241787566686604226195390118866994063279313030835492472494673086,
                             -0.8899492154075221688090219743606615012583282340532852920368365457,
                             -1.825882126463216642283467601465218830430878107514339761997306592,
                             -1.320098216887142001138107742641326077179225761912830434198358615,
                             0.2604726670957062597883408731095992988025213132690942924976576597,
                             1.634660574457987084116734787369437805403526726837838118253153583,
                             1.628444758807751842570119474650219832983370748561958602198379023,
                             0.2073506807626261186714914604315616323397447065322290101440871213,
                             -1.406028661256497049342521324630034988403598162159686165015396013,
                             -1.751735367861455488794970553609744377424437407336611094003227872,
                             -0.4741030290785880726785301145352930437448247202106748517500308211,
                             1.259421703172815157995964295334419794913515149185209896789326486,
                             1.782381319152492113849181927427711911821823550575152489378130677,
                             0.5461007332897308995873118363772178864593730675021783312985350511,
                             -1.246839969957813228024346592537482633799014960310827506646948801,
                             -1.763645262030973083850329008323701602946076170366315999892996333,
                             -0.4294510472900282328535199669999917339553953780386959801867478689,
                             1.370430394449825980535283986396321787606078983630172524425654531,
                             1.678995132518832404908269147735481780175018761118242938243416731,
                             0.1170193040408723257315214108222834729707903312947531673562845166,
                             -1.583367207248639946426183822876352792386944545729514052427931042,
                             -1.455331850621796648263886012446311159956217095637150766530355957,
                             0.3908938414341765009260400325696376419193394968093900752876810393,
                             1.772479654784310686429844425639539485511800973968701216036378063,
                             0.9867265295553364185619073143266148840133491506429143351146973725,
                             -1.031973972424998911676244692230816355741950128550398629236353132,
                             -1.744758024714813814865939046657035033781291534890036959653118311,
                             -0.2030825595900984852972214435012969086728824273091223370818383796,
                             1.609050624717143858448117956322024491873680145577505601346755965,
                             1.269668010188855746254152192745473949826626405791061321965505874,
                             -0.8003558605441652589455257975549770876811509037383626064778513505,
                             -1.764204271213421337440792866860731574379636752573507483736796021,
                             -0.242297031660583805399050264965739917001246177217385406523493826,
                             1.62877547382906404672633455825119739700197564230184715948572416,
                             1.127871677162850146302601557467956039301819667371848695910902475,
                             -1.04445570072209167053996443284240513821085734500936577711228092,
                             -1.64555012000638134145774891932094791120554560491379011125032331,
                             0.270937851798180791576501978954744699272292950359248233396809548,
                             1.766856480377757511004952269765795100636767768650979922567899822,
                             0.4727541017973056004478567834836636590313397490413001377861435091,
                             -1.57960146228665274688817456888620403918103052147087295001732527,
                             -1.058656307235214584302905793621572310210837735057942791541669314,
                             1.212917243328216307301808186316361959806754298538816068395179114,
                             1.44685314447507930900143453115272203847410573731267218200066381,
                             -0.7850205924669767290777242466441951561998208803099555130079417103,
                             -1.657206770881744918295633784517974653012294203056164638273821485,
                             0.3797962198611628541203959619224679580907972377467638811100503794,
                             1.738018179338423461073581609928080653689773605283379905111904001,
                             -0.04473998410692054379145166192386962561101199836447071252941020897,
                             -1.742643009839327534125759314562963044528320429559007706346988219,
                             -0.2002339360851307685443881598104684057656398363914268257752574428,
                             1.716257195588725360791234919340214255773682603705960919246549255,
                             0.3512271923827238862521496976774955802798549018102487108944659415,
                             -1.690435069971255198282634277694666240572254097931048444865711987,
                             -0.4105162385670738852189541047717020010711100447192331587494789661,
                             1.682029259506746908660698391822753450423516474814127230336121043,
                             0.3801712362600652172506251804584186015040714402672584477931587877,
                             -1.693452130669045538137233110621969742223643427154367446985312218,
                             -0.2594863939914600245745325481293838733781163185510137416059470761,
                             1.712713848990066565875601061572007352824311215834487830264064042,
                             0.0462343948232017337269700098884746522331287273161126177973120681,
                             -1.712969098396984115609403671531879433315016288299136939362869493,
                             0.258134860990562121059741382808414423075775904296271946521539545,
                             1.652779446517303439407872240824090837093860516376711382027274977,
                             -0.6393540911259303934334674643838814786173208728593742942918393655,
                             -1.47978793841525487060627626826452823269124194009700493238804028,
                             1.058328748833889804738587471844236757473510013964816194909981576,
                             1.141654580801682400011939251117628865988266992699114802274173073,
                             -1.439953116068969727488456810204938039366044305948305277121683033,
                             -0.6078088892158765266878202263725470044664391097385281736583742349,
                             1.670608457447203942307599481365472769353619087372553293497481771,
                             -0.09809609509515761166273568466101649927172645433758373134246535852,
                             -1.616210103427657037425353342745230699786800340229826375131751988,
                             0.8641353430527305809311399105530067639719952881150485719658757542,
                             1.172029809712192943074672390686934746097448689424613530002137872,
                             -1.4773089686854025775186572138850751525279286491146672418948357,
                             -0.343201584314977579959789645298504492881442571307149907520829285,
                             1.666039703208151172516754676034695510737435341364594382741474113,
                             -0.6742083275990256429228608437201663104907294278465213497444050868,
                             -1.223953038618300999697352660523188475061292208225830567708446175,
                             1.479734161291349022667143325071492648118480176847932743982321614,
                             0.1933382571447882650411105086788390641878276545929083828389808454,
                             -1.605133932660599543767279835678494211999775981726790650479782242,
                             1.000516495173623061707420370660257093926132766948771982959813733,
                             0.8204863091531767883464188630814442823553027339871338363352371277,
                             -1.64364884510910808355827820785489198028789062723679815563736987,
                             0.5387373907273851034286637317082925330899478660803774433701351308,
                             1.169799101571462192994765455474582096080141384708635867819408248,
                             -1.555893598705686126544250923355600001400856842652814923456045302,
                             0.2439069799700053418884530418656032916136058134593783591324364009,
                             1.312501804100416331234769515009300697575642717119088875122276818,
                             -1.490790099595923854946004067678322838797018772478933455697262419,
                             0.1608216287765184120661436170920450045524914483117373556678506284,
                             1.311193944429643860919858127926256071920829652353251582881260905,
                             -1.507671321699655789320220852211282935126100416212074885554505946,
                             0.2948307102692919745292798530364976535008789396882871298019060671,
                             1.16944021565011355146979743761735329048196152371261250621369477,
                             -1.581778805836475930192567381043025891091966659025858543702466076,
                             0.6323594902606258762084740472887279604086629458813319959240749125,
                             0.8295721448768319803170040128124143497321680455722923614405893058,
                             -1.59976827403739259974182571620870416041150279998661437348841395,
                             1.105598292753358930768267593789764058487990829021616554881622654,
                             0.219421535798070984104542692308827489746824496938065324728621511,
                             -1.361723647175247023147221240138723416800154781134543508188803061,
                             1.51745820852061956471864135138547372643008853850985360817689053,
                             -0.6284567729418462440947021104074085644565550280851896123686895277,
                             -0.6615503659578698955523416686944477987365008261718764061907432086,
                             1.504610871006041546240982019981325725420072133512397598261448174,
                             -1.403556710840774344847658829554384388400958983307102700591492551,
                             0.4705139137816114811755557599755272712764010949598156568870151988,
                             0.712856661385822057003764395725992059128485419514449254944337758,
                             -1.480159633155845084244837344537072353727017487725496560071082077,
                             1.450345595864224377713914779572550645357465131679322840701539264,
                             -0.6874833247468705540290491565987051180310003188550077038496001866,
                             -0.3912516748273272947272658274058984163832657277884968935703561709,
                             1.263477114192812069879158016908181842250059163914721016941594912,
                             -1.55522708693543562623159074868291054025160380674029439782008282,
                             1.182752431530427494788844756180316668788871139488549432408842387,
                             -0.3439265889439516256580571279956133452338995302308143551508711106,
                             -0.6042252603072372797386082394894411104373372432062484375975633612,
                             1.306744839291231264715049843441408372415040254005324724401566048,
                             -1.539200105202499028094134032914114337428772397526567684334146604,
                             1.263265357847369029974480031477559609498871758385257676718671177,
                             -0.6071151492582828378790910817111946664189807243664635814588110537,
                             -0.2042088875442765452411072687512616434851240112644872564948249553,
                             0.9331639482222184601160738373886651008255115742491525512703903148,
                             -1.398693583411369228335273060377736653417961010142581818911793561,
                             1.51330494530227891813637347005396239465437759986734598887753739,
                             -1.286251011286303569725170482922901026325582793811287832498502143,
                             0.8012778113817546299721095210304520740116536668458554541265842158,
                             -0.1818900751467787508980822225667199026612533373107585102771688231,
                             -0.443622238510680065216342750909449594424387635811317144152745566,
                             0.9689898372767490871365214911800869400147798715526509876040782934,
                             -1.324932915178882597193234036277571677906422338354187901244827287,
                             1.482635911528220890149978177121580146317666106048224588445911695,
                             -1.448572337843584788870462222511994448370130353910485911034277539,
                             1.254449067170418871474637461056560263048514409626032171301463859,
                             -0.9457653937555897593578809275673775938846027718245212460738496247,
                             0.5715391964255045882835743707877926279706931907788783388775587746,
                             -0.1766200494221438260796093642750401642697969837170936354484953009,
                             -0.2029856166762067147813996617790866242313353296080298946476584291,
                             0.5420500171328671580714542268335815487952578638564866980359090021,
                             -0.8259682480646549830542955914309485287955125935634321580525549671,
                             1.049267907390194237914146492838126813783495719578746980671315334,
                             -1.213471008583971769682385153470952695622354928496349087545096696,
                             1.324834096629640464327397875324487155617552512759361929230968769,
                             -1.392307799595397664717221030931453734856288665054692072959427081,
                             1.425891386217100587112126651401972069606697678569878539472898763,
                             -1.435431630744570524498359237873454308276283013679127265381654629,
                             1.429832615477134851604207558843526940671065826329296598062368556,
                             -1.41659868480135915657393486055026426835321153852867414254518194,
                             1.401617166177844783038485966317437968581658703511199670393139441,
                             -1.38909087526071838097581695014147879852884434874345146955671152,
                             1.381544679722782547086364015406184897680128512330897181634790361,
                             -1.379849835370964396905210278298715426040284972733751576013545979,
                             1.383231208925707062372083322366209235561979926869616848571089724,
                             -1.389244632204782772605972759134108555933055182167094105994683741,
                             1.393734561609567237306024238518359897277466964350313057911003211,
                             -1.390806513763224461936285862972689637508030479749137852489323201,
                             1.372874578790612104551720931077323140538176196969825045566711251,
                             -1.330870413947710849440772595220818156142613614062267466721293841,
                             1.254722663598746151417837583933504556673893265949858872876286035,
                             -1.134227229993008633220354549751364552140103532945525941851464581,
                             0.9604173134714894901039269579091711489944432867722069647417458806,
                             -0.7274916324192100170082121029920814681801939769062203647830859078,
                             0.4352519789349087264753569589011500993339830102570210332071404143,
                             -0.09182345301164598260954449541433447899401859704577332132101653431,
                             -0.2838175961920261903564948202385819963155277564605248508101612778,
                             0.6602736519705847054455198661764270854894003281728512883671801854,
                             -0.9941412417257047952182739191455739044508162075611233349046170877,
                             1.233543950681299817494556450971635692131174541590473045656011503,
                             -1.325690330366255509726477366921607771352841508570026232916718833,
                             1.228620602637485134704127610858150079455556553150309107574290034,
                             -0.9259315343790728078962088510694613986626124403943054456882105723,
                             0.4413531411462633371374944837368876884821871724107271577321853711,
                             0.151962603350154722917424012527203352001295591988052939027949245,
                             -0.7338033562948719834191379855568218647682874964121601328229858314,
                             1.156457597666485588201899616453401638654230000984477144013007967,
                             -1.282985269701006420643222159570753627088080387213154947170090304,
                             1.038092583909259558866275045763114832228453386781109632265430767,
                             -0.4558113120566969141869458593855556632280882258326222535157409169,
                             -0.2995506114761489625442193454037309569838309236396243666723505054,
                             0.9623788513876974100384205686412478865368940036144091833598769016,
                             -1.253717418758719087857808792659591276458540271657214451526003168,
                             1.00867440767719700957490147640893223779871936708029913347467535,
                             -0.2896720643205039931749451258070895704815301001325477620700848461,
                             -0.5873350900449397946058793869840017855240340437082270124899917863,
                             1.166936055002730355454278513853478514763050217250697540149335594,
                             -1.092412751270833672794243906391231916173996069752282726908341331,
                             0.3549025322392532795227839557241811154472090716375699569425925779,
                             0.6212944499089270724080801422854386289761452784243930382719304627,
                             -1.183933019705147497002823901988276372630939994337390580434911744,
                             0.8928628567364712383984099341143186250162270581023295547071949425,
                             0.08774108834375713570132023758929564495660084008636050765631645555,
                             -1.004961125005139593506444282179557670426526072438548567614468329,
                             1.064643962279708443597562571988690049596388200451191875155690152,
                             -0.1590389152049680157736995756187194114919804595699839360483179779,
                             -0.9024049204808416898591519658455409147625132223132345313276743702,
                             1.058684576644660077394894917170288827536404098054896240997139595,
                             -0.09462257996353213999977071365139116151572898104654732229784049345,
                             -0.9747644416212727179572594096247990326157245601070803150719322969,
                             0.9049379354302121995067425701018760762886610733050550128818327886,
                             0.2723742043086420208257838802339504179659985664274913301011240354,
                             -1.095321272880539215033628254668745760045456553721292756838415982,
                             0.4430248770028436411715168920641826913471757538069620630780968937,
                             0.8264327514252542379390867302024415584387415031856591843659473951,
                             -0.8715196778799533667224616334909309171997986829153308315185394091,
                             -0.4193313304195051644060210937262784795920848045763909029066215228,
                             1.023110453367970729895984322362782832437464842042569085696016458,
                             0.08772415432178444305360574444024583607437267168777168898991002794,
                             -1.02732787366457942146118731403121635938191244509540053994865524,
                             0.09095748739068167287889810875466296681493502285328838994990596776,
                             0.9962650441327900559045725412889096589048403914374213126400586914,
                             -0.1080953188118712389963452687619002013644870489832640667914796169,
                             -0.9756639809263315947126596842725970836797451571578180039788000435,
                             -0.03231334828463913587288273852932735444444081510758869470652049866,
                             0.9355609381983065510255224621326357323636987997800806725840767515,
                             0.3188095066985545962100629060793730039315521663790920096815911586,
                             -0.7710081684101265477312516545346593126862540013746050032197888832,
                             -0.6749524925132021729989387543663713519185597621985187592622803066,
                             0.345935487281342894929779434833759543052202451544966497230120951,
                             0.8641972177713983907721118946923175367448040861453134768688219668,
                             0.3271928185544431367948786774266291979275402418763007199119517062,
                             -0.5233625323157477007084954792738906514852650023070342375982004508,
                             -0.7906285753685813802964544458279401013974397253692758957316929043,
                             -0.3434434334540481462879373740986988570941942209587132942640172757,
                             0.3145837692165988136507872660658502917019396081972015056106707639,
                             0.6788527342647943633721400308225204240732031686087425615839721909,
                             0.6182590207416910414062642913324752829157779451241469421598977665,
                             0.3091869672024104204161689166456596156926529743643760260277895776,
                             -0.01016056711664520939504546984535756184189039546667066410539992972,
                             -0.2040816703395473861448172017949446083748692923967239852851209556,
                             -0.2588194037928067984051835601892039634790911383549345822100018139,
                             -0.2249105326646838931359969903285832148250296356108928371362859557,
                             -0.1591474412967932127875002524972296865738892015116109694151995215,
                             -0.09738201284230131921848421820244994177611243143723008896410869731,
                             -0.05309038443365363170399918587870349124856099004587799263040296618,
                             -0.02625088103590323036489549629723250944631783813577071643549932597,
                             -0.0119129767059513184737632325930222872603868754314831745013622147,
                             -0.00500441396795258283203024967883836790716278377542974739809987426,
                             -0.0019586409502041789001381409184090325808452833134173624498863274,
                             -0.0007178665675575088886935542984667746095438282769483866569555944121,
                             -0.0002474138908684624760002361720630506056558339653804771992485789874,
                             -0.00008046339130556514337967075505770215127503461108069781028070328039,
                             -0.00002476520039703495475418182538698540387637219367011254237988548082,
                             -7.231931466601792559814248837755005414552310191537174798252372897e-6,
                             -2.008150894738791991169305312066973894175135332515829943395955848e-6,
                             -5.312713959720544684789544280409978540039901911747999265188912641e-7,
                             -1.341439297906786574291153707932024241570012221325286972531616151e-7,
                             -3.237725440447602255894237298697754178873073086632850150407159571e-8,
                             -7.48064138965894641275954527341912225669103712124766399188941712e-9,
                             -1.65663945937406662625875893521510810982758371732870901727864822e-9,
                             -3.520633676738923636620644825279347270308147398059718113475900639e-10,
                             -7.187696781451567091337852978338361262544874634363282057857755113e-11,
                             -1.411144124662851733545119127150484422735220236806471930454313386e-11,
                             -2.666679967504531405901069622158442386311849491779574196466567671e-12,
                             -4.854736554985308462993653997695480545773308090182365216500739226e-13,
                             -8.521346564673856445296977249552649513085721853568722375341919959e-14,
                             -1.443208057397262604448112020464816196788287547580351361642358128e-14,
                             -2.3601425439243112854396504363753340148410122211120087806517036e-15,
                             -3.729310110017900679713424652831642254203944362255299554928835352e-16,
                             -5.697388206185780610665177680570480527832420253394376547127470177e-17,
                             -8.420567954017772766124392806839117289902046794063369650696448687e-18,
                             -1.204683204453443742272191285783224156119642081391781118321479107e-18,
                             -1.669188676838180955915934128152228848486231272596596130012318878e-19,
                             -2.241108542525297257484245606679269241067223974745045644700144559e-20,
                             -2.917148219293313793259713373314763801756804291901303481369780263e-21,
                             -3.68294962879009669191804468885406188621114936745285258954592498e-22,
                             -4.512001860681941889168941687419655995351199613095693728253283905e-23,
                             -5.366178823414727709383683897215425465819787503015442323124184819e-24,
                             -6.19814582713001505857178381391697069711637529550027214540258521e-25,
                             -6.955532236463624257855370790845731309526048435305425318745985172e-26,
                             -7.586391625748354960515371705912807505817048260256661046399108266e-27,
                             -8.045156793755489589419322092101402542789501467268680269254106833e-28,
                             -8.29813025830044574986147239670617865564588621474333084522993656e-29,
                             -8.327583751655689469681790273130819896787622743928744139358869438e-30,
                             -8.133774038447540275371838871712499218514110289868841191180129801e-31,
                             -7.734565180555525410121522783927180858671990961851654525721027888e-32,
                             -7.162788572866303810261025304351452054314661930914562823647730309e-33,
                             -6.461868523316313294311633395755524497877131127001375788153251112e-34,
                             -5.680506160122678296411564484037283329177523971539406021174551896e-35,
                             -4.867300156198381662215621316097316542110742260819473527538073619e-36,
                             -4.066089337243281005322614298216216010694862812270657837963294942e-37,
                             -3.312572393834598873189071172135896833299866872658921119856475778e-38,
                             -2.632462157874610049373415701568901842768409469840516436325572639e-39,
                             -2.04113918703811239880232581861767989712706846107522771079267874e-40,
                             -1.544540206238969500355727403725677059638425530538379829287447026e-41,
                             -1.140883819522246484852696456633011768760043026179631565372714832e-42,
                             -8.228031752356181205744313508361310544412203993564138618561634432e-44,
                             -5.795046510086222979055271995666955402745940552070123544570002949e-45,
                             -3.986721483253100799124307423347604063730199272141670984636144897e-46,
                             -2.679551062709984643564851811719545868474122627872801573337046078e-47,
                             -1.759876581432725982082104692404736826194377372631336989937221741e-48,
                             -1.129694662719963766022217213972364520190466284493631039278121521e-49,
                             -7.088937934666453203015320959551681493600558435015891707096254367e-51,
                             -4.349336586845958421237374948997410698116822749524785856291661499e-52,
                             -2.609547331124251989655404162710969376649625998767358859206239862e-53,
                             -1.531384880484603542052455520689450592126381061862202319744274771e-54,
                             -8.791347619990637851143771495743697977494686145813306217246820437e-56,
                             -4.938006425939041968206335257603481835304990211310559311444412012e-57,
                             -2.714216373760532210046989075129505664026826393779641464717435512e-58,
                             -1.46017133183062234696475566041398022046241748462889022616114485e-59,
                             -7.6894996836291994942933249625990942957411422902003407362126206e-61,
                             -3.964552358961317841635201938729319040786874948581911992625271481e-62,
                             -2.00150879848247169587504726212751610640850193016186662212436141e-63,
                             -9.895829461314069159457170682041831651149648604449389052187022242e-65,
                             -4.792266958198736414306780624035571530248151556961426650546649104e-66,
                             -2.273449787890976001132964512306245724943802181295837565638543571e-67,
                             -1.056684924101731513767092808907207745524560673754775745415765717e-68,
                             -4.812607593247162480811576700318835238991816212408679914181954781e-70,
                             -2.148068076509668724535087694567935673725033460776589399873594076e-71,
                             -9.397341411963939272731652528415636487688811870242830555749337241e-73,
                             -4.030017977600678042292694418417540525337674921068593387254504808e-74,
                             -1.694371191856590408179401139033063133191425230194950256175606303e-75,
                             -6.984949864435838530077343525880944823631891516443564098464686262e-77,
                             -2.823733839622903361467436052711811090905189896757964409093832278e-78,
                             -1.119545029641106227057012953607250979019584015801604265379774156e-79,
                             -4.353789194282252095831912535545393680355627498428551652127357988e-81,
                             -1.660928849467822865542613194763539243771251758565735663643913665e-82,
                             -6.216434486869191355267341894833290965381764400829505622398914394e-84,
                             -2.282897664072114610093439876166004494159075281902783884267133081e-85,
                             -8.22684848051104060976422501798645873776702323697141849000403748e-87,
                             -2.909570902178294779998447396580924013674116400097803936378631255e-88,
                             -1.009993130745611523339705413673657581905159200741529318183293595e-89,
                             -3.44149230702459414134673761022999571964867294259900956057420007e-91,
                             -1.151219757238147307200498973411662104544422239544882854134196292e-92,
                             -3.780908226493603425938270332437709777118563251302376684997014869e-94,
                             -1.219279384462860668416077187740233303467155496777536510389472022e-95,
                             -3.861193458144306473821223851720298462159178115636633148052054537e-97,
                             -1.200860358633304015954297882388226709637322622187749930157384005e-98,
                             -3.668232095243824427051762955413368850398504599073559009407219323e-100,
                             -1.100663490765235136180150489972217032002481808402436712706353986e-101,
                             -3.244331819828799296131337994946026031825692089440404812727063935e-103,
                             -9.395238679919615823472512400772227086817048258444913836277369718e-105,
                             -2.673255871999975630550737284664433523942838170011334659505101689e-106,
                             -7.4741386116441098937186842098830836232864368019451590358999012e-108,
                             -2.053557485346328000902988316457307744555257322724427488844132948e-109,
                             -5.545163185658199710379277824919182137911522624552702599915629735e-111,
                             -1.471701294230261806868501069731430546462651573404734677159884873e-112,
                             -3.839356985796398223862870100351788762394348002606079997100860206e-114,
                             -9.846137735999015454470208237431280887358101170581570462119807424e-116,
                             -2.48242720455383378242115952411060035949531287909147521131986255e-117,
                             -6.153532173454683934234827174112650848864657160136629526770495195e-119,
                             -1.499834826936644197526020747087987079214524704290421464658010755e-120,
                             -3.594732721419046653253867276345514676838051957651980122637531847e-122,
                             -8.472795974942314813859133216442372547125261175631373139888876809e-124,
                             -1.964066497812085480949932123427196297670519418925774722095354925e-125,
                             -4.478028115176851955187978063113477344346237536489883596183789768e-127,
                             -1.004269119750683454622693691345824175603475271645305832396400901e-128,
                             -2.21552743227880762324093627095343370888565742441883615405484367e-130,
                             -4.808377425557188549064922802289789745141856584884717555820215215e-132,
                             -1.026702535388092907852847012845591885362749994021503149366837406e-133,
                             -2.156975811209473787248144445419786648187663010525915272080351263e-135,
                             -4.458923105333032405721328305305484563085558565167520848005276686e-137,
                             -9.070430560921514751735312584997925337979297890017576496727513839e-139,
                             -1.815799191180234450606900070137511091978367921526431925530987182e-140,
                             -3.577487784683322274032809439405103260317275652248392215196270949e-142,
                             -6.937244654679492996001683001300470101020744279136408900049644183e-144,
                             -1.324104062143888324041327182412917678506827573102604593738640503e-145,
                             -2.487773821220972785450618557337445527136597528207626956875979005e-147,
                             -4.601298677332419086768468450446777439457562618491659013890744373e-149,
                             -8.378330353162272353336510597219509884170895663468987929762576976e-151,
                             -1.501995096516131198761936612168030950145988947779985675978351497e-152,
                             -2.651182817363878288491170356777796931924516919130173010084933964e-154,
                             -4.607833860467369938937459301853198297653817053704059417791548159e-156,
                             -7.886157978249678000131784987446149898028110719244706908671235345e-158,
                             -1.329140590068185338981468859188905454237439583774441356640055827e-159,
                             -2.206165728517071306361780191894332478021992271692003962239992198e-161,
                             -3.60654877280350328181147280304838572077616741889997103995281221e-163,
                             -5.807060800607957721024881257612692368930130226937412309120544802e-165,
                             -9.209922588129601333388066379161443117492841637545143679144616858e-167,
                             -1.43884668795872863876163524368465364761715418763769153578822169e-168,
                             -2.214397744728583962860874127856350572547867040395679361159298209e-170,
                             -3.357396898695992785311157264442363624737062042119887826828259646e-172,
                             -5.015090942645508076423588122892794822548056428179799595822756493e-174,
                             -7.380858792382569214031648232160166745352086638102558044795126615e-176,
                             -1.070309986494872971142233706759903301834712394920479431171918015e-177,
                             -1.529358354611174545630702875543790509845617877444046976431167931e-179,
                             -2.153416888702566389599206737911939893291317518294506489673719701e-181,
                             -2.988051542966189159023955170708913747779627279018013708589490433e-183,
                             -4.08611783736733271149905814931194466022321641232992774319527082e-185,
                             -5.507037294806109998763516258902573972073151920467116445089157346e-187,
                             -7.31527666222930814945698775759499458055512315591030360045848968e-189,
                             -9.577897081360969049712177059297522657830604996259269488941711124e-191,
                             -1.236109953231486241913708996213896800751490189795363647786147067e-192,
                             -1.572578072530381666506521329561072009180967093745491215747008163e-194,
                             -1.972222674764953558370690992715987552584467554733011660846301223e-196,
                             -2.438420178649008502339937771181883948664253186453500528576881772e-198,
                             -2.972282273730429858571357706495576747510066098297690056787444254e-200,
                             -3.572072996049861575566260663609478448931132519837805722221380099e-202,
                             -4.232715012230182168656139688913377579886453629936384489153226161e-204,
                             -4.94544797323997544859434271024849107227758403765448787606855236e-206,
                             -5.697698224832483572466764423663688853142324854515352599570210533e-208,
                             -6.473207912425247043950800221130772671985048365652456329294366898e-210,
                             -7.252452737298710442765824152554671845552204531545124153124923245e-212,
                             -8.013352572212708210442754943651040482781464833500974637980123154e-214,
                             -8.732250184636851461585869042254186161573799762154569752062324644e-216,
                             -9.385103675031917231399415759063523044651997253999061703279459265e-218,
                             -9.948811622772987016983177532125257367631846630779251343585796922e-220,
                             -1.040257000373223684788141062172468729770527000849526469370468401e-221,
                             -1.072914974834767963522638368299779517355977461778677383789030875e-223,
                             -1.09159852686163879395771149287815147132245726621702139441116438e-225,
                             -1.095597783037845380516399130081361383383123509576685083361165496e-227,
                             -1.084794209047692674594381604707061417681660406836322989495467515e-229,
                             -1.059665675707820380832789817232148173492340693176657400248910793e-231,
                             -1.021251732460306812504181363174075144165193763326552423079527923e-233,
                             -9.710825752820645893858246175435676981897398851989855926980918434e-236,
                             -9.110784430450053704399869618655548857899545893138781585702800704e-238,
                             -8.434286100241936177013587504788551193281453032473297891229613205e-240,
                             -7.704605128130197621534955480607315870141931707918569578537868899e-242,
                             -6.945097567569488242748028456058377077941463310357068817808505346e-244,
                             -6.178008442703920567275577834832743446306291945950780119243914255e-246,
                             -5.423466456130726114847906860925283991223243545971186827656530412e-248,
                             -4.698721814060521924093052302766823890354375951885596627686364127e-250,
                             -4.017655448916186204184516736151479554632450708932196516618778441e-252,
                             -3.390560987209271002115868896475645259971129717715716236133568866e-254,
                             -2.82417726940315086580580380425396528991766914787155948716880098e-256,
                             -2.321931189222398082141332570226312133736529980772459429266340849e-258,
                             -1.88433922441119965284663024258875372460572541819130619120014577e-260,
                             -1.509511447497807128483401090844286144979850119471154940343580308e-262,
                             -1.19370336345062336875791146686802463403060644596698303726106177e-264,
                             -9.318673440989053109396840123842320212366829899766316857096408669e-267,
                             -7.18165108596033710647312441749285633314932957166777432815601379e-269,
                             -5.464139656188156530349471708332435828670756378708735083284348172e-271,
                             -4.104508805121916873031047375908736088456020510388776276000415694e-273,
                             -3.0440867188788630030581812391420985060460066602914774597798006e-275,
                             -2.229069860456476687042462518923345928184969045589069424633061204e-277,
                             -1.611667548451825599250680074357517032082680438198464259816663907e-279,
                             -1.150605765729594370096256977166428669694530520305368430635266447e-281,
                             -8.111310114086867168073259635259708740762139645571388132435447603e-284,
                             -5.646545153760366396000005395077700029653030616863826196485501563e-286,
                             -3.881644904056990731934699753394688315136785720151072709759969213e-288,
                             -2.635140361604409933602875228699259810634773855010814582257534616e-290,
                             -1.766689812749958595034737058612005772865425846684970608405388959e-292,
                             -1.169766033396375367701304395282278343512586768547056462813647407e-294,
                             -7.649504516571761042476679176818284617604483969133565003815390676e-297,
                             -4.940564217395705101881982093647047716692284594345452028118060441e-299,
                             -3.151679052169143098386955527500621195238910999584622739883842425e-301,
                             -1.985833197807815015479314522401313757853353102980864593669875087e-303,
                             -1.235924520706669120328751023274978434019967970610626188988889235e-305,
                             -7.598056033156866870637021576115064706217827206042061345585305534e-308,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0,
                             0]
        var ans: (ai: Double, dai: Double, error: Int)
        let i: Int = 0
        ans = SSSpecialFunctions.airyAi(x: 0)
        var re, ae: Double
        var maxRe: Double = 0.0
        var maxAe: Double = 0.0
        var minRe: Double = 1.0
        var minAe: Double = 1.0
        var rep, aep: Double
        var maxRep: Double = 0.0
        var maxAep: Double = 0.0
        var minRep: Double = 1.0
        var minAep: Double = 1.0
        for x: Double in stride(from: -200, through: 200, by: 0.5) {
            ans = SSSpecialFunctions.airyAi(x: x)
            re = abs((ai[i] - ans.ai) / ans.ai)
            ae = abs(ai[i] - ans.ai)
            if re > maxRe {
                maxRe = re
            }
            else if re < minRe {
                minRe = re
            }
            if ae > maxAe {
                maxAe = ae
            }
            else if ae < minAe {
                minAe = ae
            }
            rep = abs((dai[i] - ans.dai) / ans.dai)
            aep = abs(dai[i] - ans.dai)
            if rep > maxRep {
                maxRep = rep
            }
            else if rep < minRep {
                minRep = rep
            }
            if aep > maxAep {
                maxAep = aep
            }
            else if aep < minAep {
                minAep = aep
            }
        }
        print("AiryAi===============================================")
        print("min. abs. Error: \(minAe), max. abs. Error: \(maxAe)")
        print("min. rel. Error: \(minRe), max. rel. Error: \(maxRe)")
        print("AiryAiPrime==========================================")
        print("min. abs. Error: \(minAep), max. abs. Error: \(maxAep)")
        print("min. rel. Error: \(minRep), max. rel. Error: \(maxRep)")
    }
    
    func testAiryBi() {
        let bi: [Double] = [0.01839840634261779333667280305178631576578063782072892004340632035,
                            0.1181885546888486281813550015847160346980767915141846345810358652,
                            0.149302955521557578121414366810793028544298525786997445346034784,
                            0.09623551964501104614209910908135067514061796296528327235524132283,
                            -0.009327007474130013842922606165034549008784039904369350588433424197,
                            -0.109009378323246743084979244537952424867201255718126186240133651,
                            -0.1505590030298616374352485472110948841398850663154164691673265785,
                            -0.114420218367267345310754674003564763693489069377162216309555504,
                            -0.02118639142333918634320983843876183165333542543806066258084946804,
                            0.08159563062698141885665382459205641922582941120354725520550722732,
                            0.1444124960691660700898900716954084991117419950426149565721033452,
                            0.1392413995048116214342317552454955283999736349134038779408530969,
                            0.07072636260993976914309463450258061307444298002972985111031713367,
                            -0.0285187821892493762072941584531276984174086411558512847982389125,
                            -0.1144362739052747571382328952849595381019621777929539068235714493,
                            -0.1512372103559612649914761586835762200306535446571102159129921013,
                            -0.1255641414825319639419480762282794882193876286188224212817587355,
                            -0.04998098835419279524386527683294745212483215061035119320491803407,
                            0.04421732156513306680279186868606936982651812081791401019343924172,
                            0.1206447786114599047901411521625014955346143245882225493455692599,
                            0.1518449345714445731813636977994001336031082080432700699115917375,
                            0.1284343952855045279628078985980272207768493778597413154145242287,
                            0.06074050050173223739652395164202388205042763329806191680594013158,
                            -0.02658654641867176982358353848092308090602131643153212644630559819,
                            -0.1041401010256163586360927766116954539743768580991428269776433143,
                            -0.1477134441906755034585054752507808752901947036336906344527856859,
                            -0.1453690689862503632425062040159720123676060267158126026438352147,
                            -0.09983153909306001494896834353487482010782655552943465835593422443,
                            -0.02618425832251483708953401400789131255396856106936205529012546647,
                            0.05372221671611759660157180191445148727113069939456450885714766771,
                            0.1180258220127757479454731332748038795121908432304242344273919039,
                            0.1507010931548663176465640502790953731467755587391349888428382957,
                            0.1450629444087212892041475346777871927549836358073081934199142987,
                            0.1043917325062993773689325524193732817075686216725055546670875695,
                            0.04000186812117307083116429274367629241299388684559030166027870073,
                            -0.03233503663371579243837135765039676718290382142581468071214420957,
                            -0.09647330442456156358251352230903065465647341011157159102723379938,
                            -0.1394484888621943828066936803352292836801358877101822207912847711,
                            -0.1538021389495722908277412095484436761813571444090310889654899213,
                            -0.1383948923439878240339246584052746686980515871773315205642204048,
                            -0.09781599928779678693595741440584203569411534922977432247855762957,
                            -0.04077244164035951265561364194354404707309746325087422658928931709,
                            0.0220312176278293019395093738194873725069359835916026185720226555,
                            0.08002050485609522162291377015665935609542454122842489292012009575,
                            0.1244935552695847155491164317443962552577761315118268211284389207,
                            0.1497457811252181882862622396922132976246997606839295214945975363,
                            0.153509045766903972610925699826966639805312718111193281182393083,
                            0.1367740551877935039862435039874430278536627250569487391314635102,
                            0.1031540493134711107906903311834788524493559154407925350611009442,
                            0.05798652087420217809701484509531462878381828103917704914846255328,
                            0.007364675947952075048594089525194173654570926523070956108568492345,
                            -0.04274520300952821052762476581389718818341829736895005494728469395,
                            -0.08719566895373251475913664962697321892811073720593844610071916862,
                            -0.1221084928611345700893175061576759529092893841906751950215926067,
                            -0.1450798333686469802342834246587736673236140050184877283395504082,
                            -0.1551712592099362263341206814114737568955179812392941935808261228,
                            -0.1527383308592545747629249991911235244272054379281718786606973154,
                            -0.1391560540070452677826972256913027603490896778396223041527866609,
                            -0.1164978727811737490761149721306355128008880651772364982717166738,
                            -0.08721544766347470711033800379461714243365257910266326938835081849,
                            -0.05385364001827880068950587481470862816220365347471654561486294837,
                            -0.01882169053601286946471690879120885695652781419299331370966346613,
                            0.01577049470980455561299950065048912803609424509785404467579435814,
                            0.04821160985734273644202075214982251655337580706258259819305807894,
                            0.07723107302209570033852946186417193073137971134515818377677493389,
                            0.1019951408581283805063569877341677067553055813591378945399826267,
                            0.1220695880527669106055237241351637208111529537653165316437053667,
                            0.1373611763888648774147148269481337329046437899232743200812539364,
                            0.1480486139200363007351636952052063660515879580743138333570270562,
                            0.1545115567751352535352127828202580999544942117013502506956652673,
                            0.1572638717074419393547802474678295254336274789182906673673441737,
                            0.1568951664494393587676786027390225250173803284056285121563692655,
                            0.1540226965833633665606030074137720447241547119483133469534530866,
                            0.1492542612403421609218424080512210753755051715659314955438184722,
                            0.1431616200428471460233886536352184286813921841816134590125272869,
                            0.1362632653655962082694653876129616347233903276072228981550274457,
                            0.1290150046064802623561890303183993932459421663355795091900730057,
                            0.1218066734288331330394878549270767115060297105685513187258556288,
                            0.1149633407199451732857256797332052092217875695452791952829342197,
                            0.1087495156276248234990011071828576242093255877125457524875806069,
                            0.1033750749038542864258217107797442528519315689016446401137832228,
                            0.09900185640979806959521567110543035699415587453025371248742533903,
                            0.09575008590243242156820854993885677746399751500787668589092589846,
                            0.09370400373335221522685465091282559190841625557880416893565900754,
                            0.09291622914509210163756613533072075983647099980240357383104800233,
                            0.09341054242955045975339626431683280133704339526343756435162871827,
                            0.09518288417637107918749732212827681471295775667702370697511010365,
                            0.09820047441971288664294939253558538953417412028927764596633431624,
                            0.1023990530647456628704447942683754448190285124952498519365378262,
                            0.1076783480096702992609259836915815710523145266598095051005158291,
                            0.1138960004418100480755449291897778698720732090570442188656689152,
                            0.1208603284384553006615165225082175440378791100161050052464414679,
                            0.1283224984295170259958928956238356812672922505448490957470622784,
                            0.135968903308532640368529920837124504421851177958951588293396377,
                            0.1434148136031925651632630274231923781640605193762583430851528449,
                            0.1502006625074602352829213213961299770138191141401394785709610709,
                            0.1557926227384282608114915738989645092276549057176184652231048587,
                            0.1595893935865458294349639374944935823506281017478425996678225676,
                            0.1609372825624142040968951498420797222440684973116750996254465405,
                            0.1591556609902918082135097953466192376869644502908580352203185116,
                            0.1535746027704218465626278138239851433604832508384630156168320001,
                            0.1435858753381906048135063484070249617698621542890283919044106122,
                            0.1287073380280360114895341610030632299027432080136150939683275822,
                            0.108659133624307618370961176842400012255046292870345035386590675,
                            0.08344780214760086869815800573470175301663573634626979082633877767,
                            0.05345165708047157731339832037666330379681489522238172856818432508,
                            0.01949762692086810811955442825887418265238178262862576987537820691,
                            -0.01708336864495603010949397896586017692395722511063195754826662813,
                            -0.05443801961211524055417017340835031086492225391876690052759374651,
                            -0.09022599641332631825596637247524923806148146160247650796782388397,
                            -0.1217249628527808555682598731557821257634049930295197076757493121,
                            -0.1460170314122067871613106605988240910911362932980359631495626901,
                            -0.1602604248873866625579467294349844317407587941747294519421023964,
                            -0.1620376984270260791865081267662438131288391326283629162426778954,
                            -0.1497554145113631879039214438729138296149996632211605200538826382,
                            -0.1230510459048365453452905849390384486416812588025216529802810472,
                            -0.08314384732202701882592591445815011781314503718238626316250990198,
                            -0.03305164293360781469699318288047303198603738720675802613096193818,
                            0.02240976619465994700907549830141819489521911300715351441309829154,
                            0.07691784437148701920996218956915311269953481101416662424483672885,
                            0.1232683576920589368847245566197647787374435195226950944359321926,
                            0.1543249844571972209395339583544640993857208011438515624371181909,
                            0.164212275048155534868665015771831266892330744909306875276907342,
                            0.1495882334623988965492144629192549576297503377310352680870069517,
                            0.1107562882400780105331186507089637443693212158849012089083202403,
                            0.0523287314748218988322579484011130825005005696680611778307348978,
                            -0.01683968146585188221628194840336664560850438268968420157006177435,
                            -0.08464675238995738333399132329053921706447985455472679481995706174,
                            -0.1376979389728642906168290275699564396357180394165134125915650282,
                            -0.1640140177769215625361835950806773301944381138712246290983136889,
                            -0.1560149648040889632174608592689066697090395843322956251301313925,
                            -0.1130753395083299548826706741927341726972998126823270257923186498,
                            -0.04284684142411270719513454346254864992559770331032486093636067164,
                            0.03934371604743434401435530507353148221282995855613590017443974449,
                            0.1133421236231513403831540890239748853962932356256078747673235463,
                            0.1589790307201910928130728415566037226527657533481943396287356624,
                            0.1618539728403896347485806612774548451596444361794278299186308869,
                            0.1184917181668362671445559941621201959718111412800550318534218293,
                            0.03903194705663964773559150545000713603328534716350189961636536705,
                            -0.05403474863832218179474939088259539288308942301190790049212095329,
                            -0.1315522991510997801286692811339888194016361779050565424850385938,
                            -0.1667571889686788966278390179255651247710966450605255215020930101,
                            -0.1450930458757220499846675970527105795342616217668449583439009021,
                            -0.07118804595829510566313970078168254519244685146691013253795338808,
                            0.03036666672312880222860435630444067245788571856974640499487771239,
                            0.1220577530840963468753797972218947677639166303243423927377360744,
                            0.1669735433495784170642641729657601765616452685140500811271104857,
                            0.1442871994052700878835955113770316438061224903537836355712275669,
                            0.06020430296181566816336351494353017472368548248524956320849638016,
                            -0.05152839834689550576759149096096545347377719254837931252665678444,
                            -0.1418089499399978320352706875484786694338761025373626668110485986,
                            -0.1675642413904986473133292143453918776405455972383210773750808886,
                            -0.1133869785515902638439785441437011416045922850248954554904119835,
                            -0.002376563424186570693203962904317730492954541130445111533229137023,
                            0.1114847908654418663030134980199550369602792990899286245168853408,
                            0.1685799999189124418685152832672501881973123931244009724731857882,
                            0.1355681535432716392825083858395249955507875153873262659287890462,
                            0.02686864930219786051198757518993453915867262332336112281240829209,
                            -0.09866352724992684309685715189657213238451638328287414859276597002,
                            -0.1680231319273045561127287156335117290981110796665828290870023079,
                            -0.1370261658471245592244843515455195935317295169258486631040701155,
                            -0.02077794745342647932374417827127253317540375541114889842709748329,
                            0.1101804919600490260634974157907397391868744284181341807940677743,
                            0.1708938279224305217889325947141659974732965116057264985166927027,
                            0.1179236859946232341445183632797370324010938982237971181164207566,
                            -0.01669893839339660647592237823443983740671959504910652146710422831,
                            -0.1411831173386560507539586402523684261291450497058096679972956892,
                            -0.1652047165869945946244745712134341371116597189128851352769353122,
                            -0.06726996022385760475751840539860154708972828508018414593668246578,
                            0.08277797231962386309459129463507124191400993340701799248277612029,
                            0.1702590267621006806529691356432862399962928708560546786868042205,
                            0.12339285345768803379163004871209596823120081579124125100082205,
                            -0.02436038911823733800688405326285185112697189066629542511412255139,
                            -0.1534203651477838867924353948164252613668567697872550795948918012,
                            -0.1532079227108283932834607998588392639216391790033200149258470468,
                            -0.0195852698977419398148730827651834864574975356478319219883593837,
                            0.1328336880261531371212762456270583230626821321596543280765702363,
                            0.1659049981662053544897648959277616974813788192578543931034433449,
                            0.04503575180836012595667155156058521897016584847881532118791487325,
                            -0.1197819817334596072718259012196648591342330459201190210132187626,
                            -0.1699516679787851154526907246925753595478477469393149284399299834,
                            -0.05222370567647848504202803483333091214305879433403678651361330265,
                            0.1193976056945364449213189049135236662079156081455563883397646007,
                            0.169324953676903352265526233541239979334445287507934506887522376,
                            0.04136181964108474316803000037784290177343075307708130155848768107,
                            -0.1321502216659307326248984608895757519474701150013887584727247933,
                            -0.1623295841460375390210247001940495428261190102283291483860641535,
                            -0.01137907092311892344260940274387561188246616480715114917527396701,
                            0.1537706639914428546616794056723219167750437005257674031576938119,
                            0.1417129681363874447199097031234414371607015023149463759292602737,
                            -0.03810734359516835251075909194146420113233261210768770925759688017,
                            -0.1733819243097244865804271602438078776728105246448998680250765405,
                            -0.09679132169331444475067358269325821500870116566347555503237254335,
                            0.1014030822513718515870098371866837159312470601678032897195254287,
                            0.1719262536179483121938627961758778597791393858484505682666794596,
                            0.02010150388627958562651664398725163018161160900879724658782368249,
                            -0.1593007115994507750275354182410891927881369757716188676680256051,
                            -0.1260557496164288942803466958708054952709408096301367573927609211,
                            0.07959916817396278245741181095449636532612841376235820440393215449,
                            0.1759879259099578888886297860242533316447060991678531690991650946,
                            0.02427388768016013160566747288634683500427504974728190557394945529,
                            -0.1632679901191149587795144683422905171607128602604330775034083702,
                            -0.1133904569957670052740103912854719350850824043771869408850927325,
                            0.1052007551440457804498457377992990137327604965732446806335943192,
                            0.1662429564213708815032359152223149707858103752182665476387145521,
                            -0.02739286038497017100332093889484586049453525883922220068807257031,
                            -0.179393998585918900384468028526752565169549047443811029513230117,
                            -0.04817083317928092659730646262434185540123769625847351920472791758,
                            0.1611959369732753934202991937343047706676855600451492845804136305,
                            0.1083697780414234268772042663591790645237778785912791281380358891,
                            -0.1244072712390208592509022923640068794246298677251982640967395131,
                            -0.1488641607006533270842801062928495880176070842210092851331232849,
                            0.08092420519433933094155999593595780750128796529312848148429101461,
                            0.1714006650912645675328811189474002663183026086930071354262444882,
                            -0.03933358387677834102157717217955957445235741458793514877668541049,
                            -0.1807163699720581181303377064297173584191025269550613089271208163,
                            0.004612871176901830339777575922179693934793257144251345204112040418,
                            0.1821760942291813961528682113107540144769274825072480376023863353,
                            0.02104247214999386977061595404162394849373283697434275048599964096,
                            -0.1804001256130143727407761595229552625174192567607420454807259307,
                            -0.03707511273835792103812547741156018235891372160825879375204681195,
                            0.1786722455964928728803579460855850829353240693959726177764431672,
                            0.04356775693024894009036192215536913119351347032134564195296344,
                            -0.1787846606798020977864033839121233128905704321953053157354188378,
                            -0.04058079541180923437098392851715805107451553772477221100624987145,
                            0.1810267718812837716403522625100237709182065281481635795826150259,
                            0.02787611549780896732597895905820920497694039222951842482971385581,
                            -0.184146574818169806496040229441684284088911865551063805908214506,
                            -0.005043635631757515632662207126304016836864461272486349323485950632,
                            0.1852567056969695981517346932120350055387740693556099850035249912,
                            -0.02794004732874361692347871707135996013549300762582461771141262975,
                            -0.1798140708645030645540318456464035404102182538392055421961828173,
                            0.06970310762878310414254170529046549060212930060021538335001558526,
                            0.1619711277852369634832574371498874166191852843530907637234497574,
                            -0.1161182126612215887969166710760386914152260007279083191338478934,
                            -0.1257382676861348807953602344051359619150639486202478482807524664,
                            0.1589827164473861490284161589457762324286559142916512798440501749,
                            0.06738637494596383880681705082051374583127586518237795592555231211,
                            -0.1856127301470700340445343777207303405635919657322329967647834625,
                            0.01086827260208205414725730235326957050782303826783876122060925804,
                            0.1807166384853889443558710050836094478852810050189793247346546108,
                            -0.09685936163816925995641662377458163491384280259425931716567163264,
                            -0.1319119252322917242308439987068507813018427457059166518852538132,
                            0.1667062614751747336169366228408914039973624729255778420213449852,
                            0.03892734720055683959461822170433463940727532774736259110781222122,
                            -0.189256083172093304085844637498324540306272947186594867427006456,
                            0.07676865129708911231781917610579658966480279625778296633774607038,
                            0.1399858517662097250756811335357470357742553033116288549966455538,
                            -0.169703950119484822582923307477368158114652320914751843011402119,
                            -0.02232316567028081086440447641915025840617499535252923522739335805,
                            0.185363671639268364537713876206216350335607098524930505314394115,
                            -0.1158571425291567384417961457843907630580686593902340533246336576,
                            -0.09544514944949861352660760623335652832523352542872186070406258829,
                            0.1917113345709366672667728243834536502569859461176609058025249242,
                            -0.06298128568949507261642372140776910914215706566886602473513148062,
                            -0.1374409541411786941820789672075271408638740368344989565086152422,
                            0.1833381866308088531264169797181974820166925966348802515180920022,
                            -0.02876569007957360869654123460474578546173059744090944693773845802,
                            -0.1558137892321530208808390465702790309599545272545551911572952865,
                            0.1775166566124422207587221442878920267247212716491466569885716565,
                            -0.01913899312858241407060671439070686680854194463997209872617673227,
                            -0.1573303022166761033872784586326565070334749704191979051674799866,
                            0.1814701933918293656667397662495897723054644050078359927457780575,
                            -0.035537685707277453724409138261769217710713190628508767891923702,
                            -0.1418759805816331979814059908397387035299846278791214086158817512,
                            0.1925093904607419429661712935206341566281924300556673468907782706,
                            -0.07717224249994166481455183358230356597157204298482263983852105268,
                            -0.101806666465485948176257387335016538349456587894767997256889136,
                            0.1969270910566741442377205411635603608544291754803025072709149374,
                            -0.1365402744152662695743272280674479671901364045468518718158525322,
                            -0.02730976739078578617608730216871249821629182384302217181778906637,
                            0.1696046370585901186998235110718817027854773641537301537962152478,
                            -0.1896519810390578167286402956538250236189719601732307989604881943,
                            0.07877497183695698955559739244560723365867042294356900994726715457,
                            0.08343847450023514526429806594120695774563316950513592618142447674,
                            -0.1903518896296662139002294402645165012340066564006480351344973617,
                            0.1782040847031657936909147374127455277271779177242915474941351065,
                            -0.0598979933499467981773089587854672089169063338558441298740734716,
                            -0.0913663439452652473049624816706308342305709437761812492761317633,
                            0.1903328045220035697581627279303988360019254118894379646158727261,
                            -0.1871968328829833155048566037730048771879924607192233200076494299,
                            0.08902632453548404360346647012883816189049084998802974590535269972,
                            0.05104530084232867621544003213079315138830644558723003666514920571,
                            -0.165258866839998865522878534578574109640471682952617172647562,
                            0.2042056071879265338028391492245353048449740311568619520398299583,
                            -0.1559004207001476304508735603050761988239165259649169385297419077,
                            0.04543782462685134300373181950487996056820155589411167760004297754,
                            0.08049634814217342486986467319997547523026503781478310871666783019,
                            -0.1746863750029426156371204998710444269701399519763501310737003708,
                            0.2066046045764977963115499093157599566958578039410631051684395556,
                            -0.1702661670221711329613702799263104621655873155392214227140764533,
                            0.08211946862563367525051102710760223917723231692944524061718815219,
                            0.027919218201373921779293712704740534690128842351794101075626366,
                            -0.1276848109700190098853673385755707528352781145200672528189571054,
                            0.1921785298535811734391335562234563181836909465079828694375058995,
                            -0.2088440339314571822033155033018767486664053949952375341787584147,
                            0.1782966272345916342746701871464169027831031184584906189356884794,
                            -0.111534368966870188675432210926655689148186732620172231468201186,
                            0.02532580638701210365107472096448495515869818512237578758302637394,
                            0.06256707319474912259049141381858614973383365124542994079945707683,
                            -0.1371501521288200733796208650905647361880230735051992847309850538,
                            0.1883884114801694118324212054163225336281429838708115499805941885,
                            -0.2118227600969850321679613855721086495509650089991827835637078271,
                            0.2079658944290236455945717661110623371750018917746974101317406291,
                            -0.1809775302428896027789910099059676582909468127478354695475368453,
                            0.1370994849758711964326066085039315264026303492939082289078976575,
                            -0.0832132223249346636508809927702308745409641993480017643366123529,
                            0.02573165258453275372365861290311664455644912921259684499484756551,
                            0.03010045812324174289642348262846530581842310273912714891532760056,
                            -0.08052304780980997440982305701725964108510667862914630751168047024,
                            0.1232765978683103783058253738960579568861790529090272013470066736,
                            -0.1574191719576239707074326555792324851835738846809652279300744543,
                            0.183040385133582922097543493866813458668298506815486701236133896,
                            -0.2009478059831110368936689923356570037269348944464742145049335338,
                            0.2123765168108329423805722192338733172087940136809378367100069786,
                            -0.2187494843618821115453753585961702956452350255636602741636859909,
                            0.2214982356447327151873855589699360692950615370217685646544539627,
                            -0.2219410017784468557502441948403509137872667232013060039790610512,
                            0.2212084770288473620353815285679997215839312041191797871201227903,
                            -0.2202044632581813408465933008491334350602108215985134909940111122,
                            0.2195886242840424235780506258213226994199901524810025297783543131,
                            -0.2197702367194763231245867698322372576660101383229523842190713785,
                            0.2209043932056564863016483053595544883211035825621086275236798618,
                            -0.2228851325784296787256979913105714673951526835945378366873093695,
                            0.2253332732710363838797312591006604332825780575463166263944799268,
                            -0.2275803468485782094429160166610943692782260505560675721659323252,
                            0.2286540897334389241392080662068346497364904809799617599422050501,
                            -0.2272755185477019063715923531286184007107651833612276327385307019,
                            0.2218825224967054962955917899733385861304899000529342664773470009,
                            -0.210699548223320312779993851744013751770930742412026631205007695,
                            0.1918760545743105988804090707791168807142896363254416415835614635,
                            -0.1637158502403539546406754276834763892433515015430596438783748012,
                            0.1250121909223280443718156043186063531120150928819323796103425815,
                            -0.07548604285166179143609808851083124832194065372798953963102937768,
                            0.01629401869992377225230306395134829356758281757618455255715950622,
                            0.04947291301087131008975067082137737785692648251389441220477320786,
                            -0.1164350222348791498098683449645418946558647588420656999834244921,
                            0.1769039514385433208614998870990795679695764925479847551963215826,
                            -0.2214191693450860330717180064530850827652270680371426646868188011,
                            0.2400369726830609525060922608053733777073383408496290673842076303,
                            -0.2244469422005663197375939231653847171729366634301425395344184513,
                            0.1707445343143055602494793250169635317643085249586891561865082164,
                            -0.08232288371808431852170689853334185525273395612053783917913979976,
                            -0.02806646720385413166216274090993860559266209319052838320546692198,
                            0.1383330921209639687104590726822852509183199662403282804417377727,
                            -0.2203350681125978814418972664189300729376306722050695534187758637,
                            0.2469384691240761020540917837615761819905844403379443032186135206,
                            -0.2019211800881988284447073375318061285004239354836882147855317056,
                            0.08983077591664324498567486816856184442452747859037918872792287966,
                            0.05884547444148723679103141835673670284870322649463766725693900428,
                            -0.1921468156903780237647036128161722205941016884751726516737096517,
                            0.2532598321256829153582823561069163162703073882345028592905814596,
                            -0.2062110460268968396797630539635436514964959899132760415682061168,
                            0.06030056022881531871969254190423035260570420687357005695251679898,
                            0.1219519689003285567193980190447081723613149161327544969269113271,
                            -0.2458169345563880093682757606844102710142306861408049256623067042,
                            0.2331811223044214160957826789264306203691205530383236797621214684,
                            -0.07716687687531381149376152670162671642693700868559661436476007455,
                            -0.1349873055782774759544943384949756022074547063025528577334719631,
                            0.261362137869230292114205436905180754611773697354851034792007884,
                            -0.2001393093226513492836047993358902621361974749176253246473226638,
                            -0.01909164225757662414329380469193552138505304539212553997948576843,
                            0.2301210900945883146676358262322161546122651832901178924473733701,
                            -0.2478706907204329252072023669722690213452939444357658846717494874,
                            0.03837248850838399807480063842072492226597432153956916804711639581,
                            0.2151202455786953349775998676589690258325081185674717683879123906,
                            -0.2571359210023431821447261248491722943329200855365255555481069457,
                            0.02433359843269569271524904183765504886901952611325839729799340458,
                            0.243123151428227216687588332540114512975911664289759879693495867,
                            -0.2305265307547122107351091693995234925669406506662303370596832748,
                            -0.06912659453101006118592810401063303506653540920286457860411573404,
                            0.2874922435175277552383898228014381737491808275714526948773550597,
                            -0.1196655527976245231326009740983905710954037219416045271207552243,
                            -0.2239501035800227914673690860743382512562098908630961718667445259,
                            0.2426132290926271993334156622778173579596717733008580751571150034,
                            0.1170333672573927766021015095318690896934956849140017639470832643,
                            -0.2957199120780730567294575143568261300122248364910734154061251166,
                            -0.02390927235594575754903595198556393300078908171908009072631393737,
                            0.3096547674267818863329629932166486007297557295561210430864906581,
                            -0.03035612326402101317808749158893857718821668474082452391930364205,
                            -0.3146798296438386331617542115023156955295157274732770984959919666,
                            0.03778543248946650226563065894492949470139664094631738953244886699,
                            0.3249473234552449179194280555744585945228546428129346400088035887,
                            0.007754436447658404431949082773798272907445218501376595498409739572,
                            -0.3312515807511378599698762392757070198124344449306921774254187892,
                            -0.1124634850764908063843208150544381602171049932731942226112388616,
                            0.2937620718544140201236471886909493636267666450987274563395782954,
                            0.2610126576364839518174202614884293104207771085558895006809933201,
                            -0.1466983766705570378752607399885456868409561851095615822994210269,
                            -0.3678134539157119910947077770812193410330732534894371841846706723,
                            -0.1383691349016005768500291756026237234395401787443868972478030658,
                            0.2538726576969326368005244553070234355003212776452856739123342406,
                            0.3922347057069992895544918276468434832416121723328910995953531733,
                            0.168939837481058611843442769540943269911562243926304070915823538,
                            -0.198289626374926543220644854572488356698807495832462809711096776,
                            -0.4324224718407052930284195036923072291236576121023132100526877461,
                            -0.4123025879563984880832340546114610420345348344724047288238769643,
                            -0.1917848611570412200129417232656064497557057333792379471289575734,
                            0.1039973894969446118886899909785991446370181113925239724352569732,
                            0.3803526597510538501697124937262645026709261850134749759835389297,
                            0.614926627446000735150922369093613553594728188648596505040878753,
                            0.8542770431031554933000487987952431808567874005047396269340087416,
                            1.207423594952871259436378817028286995385348944644442537538620972,
                            1.878941503747895000909335049476259057225954003326747003139783076,
                            3.298094999978214710280604425223452422003975963403620787682923545]
        let dbi: [Double] = [2.105701367289785444049358620236364588678722496881814961401753314,
                             1.307522741110230362475803962799957000969039762308867345999424721,
                             -0.2329010524141626214922911101871125362400985271009923229226946093,
                             -1.626625783551992859016624194079508074020900902979469230738743189,
                             -2.112307348148889884807896033232406608350962283957451328331688409,
                             -1.458375592348811343322016670931538237644237406084431627162554297,
                             -0.04594501194174952582339133793425757603749739009222867951493210326,
                             1.374424743800553654054078104033389333317983973135507211434081057,
                             2.090035490398383957893345651702194972086695109909094128483390901,
                             1.774658267619745495880819527073547736562379851939444761994976049,
                             0.6151945930475773255357563883448493609507638183679992015411839851,
                             -0.817289513627405664388661013269768547900541820039340972893160938,
                             -1.860853074360224177861062046468660736015033997190570000088717034,
                             -2.066543356725305816058684416262163560743182509357262341083444893,
                             -1.376607357398820170323778331114948791852844565810575388110113722,
                             -0.1158544712914226963594442021571849017451660196351515980303413739,
                             1.176055545382389395281891123005780866635304668933245665599839006,
                             1.981474175152189080012190728027463552718848320626306339800223796,
                             2.006470712512198339973394897241741871180892204233118288113783398,
                             1.273190081889146456961271097980841862768038351326557503609268793,
                             0.08260671517023388233160288514523747504895279157835855617970773471,
                             -1.120520011887097058178823001320285131051467785534202741116186296,
                             -1.917923650436091533725816971968933201087183801845156114469441118,
                             -2.058433938714298570057095057429080213936253154339871702273071822,
                             -1.525115558494347878660100427296980275727022790952796735123531491,
                             -0.5174260918060022256788333732901903817568862873550114873156866919,
                             0.6331357910784040286876860477775069926002886897447086391154082336,
                             1.577293629251387794277171161336845530262715151082266652910768548,
                             2.052680982675191367571676168959569552848725487315874125096768931,
                             1.949421552309606864616007664592922608478018346889127164716233695,
                             1.323947618157613515610713586259847732384010998864710188922788893,
                             0.3655555731095304429576234726573209034301725850625093243601939569,
                             -0.6674898373023114191764021217412227829858353261485814802855704098,
                             -1.520442879086968447505240754703871511683861022347102281111707937,
                             -2.003239907051990908567655249492789541169270552790716682238491377,
                             -2.027189122764512201779624380945757908064509879491438721780370756,
                             -1.612690498874707937495414478592738564560983050967073300694959816,
                             -0.8713435712299786350288984191882795018306932844397730698983733538,
                             0.02891999234642226265945496900286438427084874305569802904626241152,
                             0.9049931259456256714446928900560882795699402244456982793561296072,
                             1.596216465740776193155521310934932111314687278977243230685043663,
                             1.991485459682502177137682283547318693133820808723653127109235929,
                             2.042532690620471965770883814519429190608556833426855755560761577,
                             1.763562762074986581345232258467789963412646683884310133189051089,
                             1.220021017204435103747103035674458143623112481562315458804422768,
                             0.5106914394137853481340642293327527468398437938110648801952580338,
                             -0.2524245904567966019542551576050077407939914340824425476890512999,
                             -0.9626361089944919645740968923131590790861687151230351087959690754,
                             -1.532851994676713598582152833068228730208978187618240306224053649,
                             -1.904319576817445078722459084581565134875391280990310448966604179,
                             -2.049709554222398277108697097936845266856243170080973526372352378,
                             -1.971351734022851867227476748317200532487177908593998966009305555,
                             -1.695961088385192404534625099806903110600037874168079261252051546,
                             -1.267373515573774414345393144875373627739901086598758951191102111,
                             -0.7387091095863006752390185155348167352751739430458612869055948856,
                             -0.1650962643641242842696576897285369234451576485622856040296666896,
                             0.4022792956138638408412809361015033276398624699108501379087890076,
                             0.9204094118734551198734150796361861093218031460838484136237547777,
                             1.356911797240278882329533427426038567877551725890009706629331431,
                             1.690859383830677545060334533338368070695871984236728057990284149,
                             1.912305905786653252926817181854085282208988910186493014545431779,
                             2.020887644522543800508010661102605731492294626352547811605042113,
                             2.023880269367277313468769762510513421409190606985830737189377675,
                             1.934043662005345242610460592212478277071758273753643866667626627,
                             1.767516535905584142956324885076624201731804624607587738126018177,
                             1.541943271865269449508881883239599062346557265500205911910052218,
                             1.274939915392621795505055496980635620410915904739553846980297234,
                             0.9829423486901615241362372973458040600912966659533270547268169743,
                             0.6804308777439858696841419870958035399376127486072836056355838403,
                             0.3794924097952354908765081466874245792309624748745544965090686845,
                             0.08966252932240531678663548796487226094934261618798938824255308435,
                             -0.1820175328414158603800375842652504343289328938742404201757909126,
                             -0.4307928522486343742544627518163653773561925863232754542617032744,
                             -0.6538927492023497313507197944094646875592257173268327331697211939,
                             -0.8501819927945824676352818206535178732655465502796097038141992967,
                             -1.019801706716126548193690862106406248212308912178375590856077343,
                             -1.163825904435884862848489948693601240966470441008251188494530492,
                             -1.283950283669620942065443101051272667431644386217901849077907253,
                             -1.382222274521589544729634600232697171166951926222908282577977064,
                             -1.460815498353037563671289230669635041485813635474198240802509913,
                             -1.521847679372420321816091319951697974112619448914327345368907641,
                             -1.567238457710678412918329311552357513531727203872135362151533412,
                             -1.598602223905808036355775147320745549194249823198069985795110167,
                             -1.617170763178675555687322673528631571610247535568289701135160173,
                             -1.623740916190085227230478452148164765000851942331545426803196498,
                             -1.61864341785386807465268627345414892480082616397138958327770974,
                             -1.601730391328714012540307193149241916705746591610752034107500629,
                             -1.572380506976802639018683316966128786306952365210875791943623178,
                             -1.5295224441606843994494887877784319756589161823560602400592442,
                             -1.47167890349515499822293869070559066344808512215519988396259149,
                             -1.397034887270791601368310760266928090965503369997359302552793911,
                             -1.303535151954223351430333683075038314146045494415240466444894086,
                             -1.189016458251186365700553000910309420473343084136879987284949179,
                             -1.051380274844696082120190000658325599127982514571406715118609121,
                             -0.8888106576345111095171436276635743309147943855642336626255784239,
                             -0.700039814678480390830679739335751054351492458239671279611272313,
                             -0.4846600519987655328926571893408407171447781594909467708038201774,
                             -0.2434750826833696862832732730185993278472635671675925783968856881,
                             0.02112412072687150882627344909792271313004432372297090934636841773,
                             0.3047836344162644273501398231949983914762133289494270603145529425,
                             0.6008473883318573857691893329489480265396858904074904337146104779,
                             0.9001033859610009157524316909218232199247280558814219225091742635,
                             1.190676379000659357157075067266768960160429932779348547420852062,
                             1.45813757064492555507658076432770736910551543803292708530741752,
                             1.685905979358242597685114634374871780904723686561659101306320288,
                             1.856011131776074551068167695018860467393139472225781044812576975,
                             1.950268864544731025027771041474994517956358620891437619017618183,
                             1.95188750756229909834457068244360619791199768748310609818157475,
                             1.847467996566301797611254733188879903136400116016364888022684559,
                             1.629288208499856060617973798759819596160328185332948932605076018,
                             1.297672412910131457878183200361959496346072306642504405814048868,
                             0.8631496903731660640133949027331010366471730024383144855775745531,
                             0.3480151838035950240823823285196674011422067173276041425890594777,
                             -0.2131537598693792976669624601617737461750253820130461193049903441,
                             -0.774481830274531416530884897056546674096277942500126630802118577,
                             -1.281660326884299609913294689605388928541051680819882089350916357,
                             -1.676889787316003201464723430590889813553250476666455921866859513,
                             -1.905797149679610155184235563750134620526012097509606336190405623,
                             -1.925813536100066226202264774372018801819323669724474505324016025,
                             -1.715020611234311821450498762219954297997192776528933187000953638,
                             -1.280006817220222853908491674692594029482211217895534579496594849,
                             -0.660935685201791135246643295565403133190190193822658929581386629,
                             0.06804256675241836758922295139507238536377151344157042537240370728,
                             0.8045695422239837100006844612512650374415957809192730973055798742,
                             1.430744135075377192718719410442230673261490733703607723324807134,
                             1.83203365922174982508578420371916716707771200751857503321742538,
                             1.920092225224478950876718827028108018767380339752263175721130976,
                             1.655406628050332043422955956686018938271488465818681808469295972,
                             1.064378708281686753057364460356333602354822763019158840683477421,
                             0.2451317304968535990603625644147497650567642266494395772456043992,
                             -0.6425008239633845366130177491665317531368714708527123818380096523,
                             -1.40443595329632205073613791217349873680795431995453063097683595,
                             -1.854452983222794563056889464348578872953548363243506729026320982,
                             -1.863035091136021112585058046898947424975907398579339058389483006,
                             -1.400626907737227386391589380142245572925201034443900729777256748,
                             -0.5611025033321583215822470460064784558539840278690654815538847504,
                             0.4465535782345381916125711846931468813035633900776997323673284024,
                             1.343308097603378544570062068433508494483422553411392906562954623,
                             1.855780775919615775064051276798245977858302591206710301700944737,
                             1.804123772151632352546772381011285687079481593811013990001644593,
                             1.174272481854047763491510201421659751629001106505993388093362279,
                             0.1451905524741863897084139462927315619610032477704566432506041995,
                             -0.9487527179286750868966744770451941690901661729538646538795763888,
                             -1.719757055100810582727514346046759200090666700648396471611686668,
                             -1.866282648622379890980367633267248567508708275904739043716152873,
                             -1.301573838244609131270965102314133101630587948464345351264401675,
                             -0.2150526520602047062502279109110932707773969811500423917616095762,
                             0.9731798554421768575711718623608909735725063094685507911121696273,
                             1.765431181354701454958559479139075839217841843487935491087586611,
                             1.797868126916281470045894648971369040217858143741150902951790003,
                             1.022012970418925938255443325338045841206789364626006480809248919,
                             -0.2369895845970223570106816699109096271166569378010266439856226279,
                             -1.396770637199898507565575089747241212274913822370514292346106238,
                             -1.880615922588127169461450987001549420965985289195088097880197674,
                             -1.414509368243908683077183227365782171469842615860636866414805505,
                             -0.203838596469208271314980944854715323598449060149003979007389134,
                             1.128835806288516100067632657277186071359904199786473984244480089,
                             1.849628774365506329625711043324219447890270090642836649394245929,
                             1.524110869425774952414010527287761045607622585796572843798526547,
                             0.3033585297948979112042962052863601232968531528609428134715765878,
                             -1.111037284621321664514471098356682190588486134016492486446984557,
                             -1.85154219074562443884759313863105648680002827184364857092033733,
                             -1.42374950080541484361450810762113323811952361193073441299056404,
                             -0.06514559720944254512626315157162496624488095164258406301134723756,
                             1.348145584786516229679264022498190547468126784746762262760439471,
                             1.848648289234337990373220001153509774543465857349801817464691778,
                             1.05370261171695987179883303281519684879237097571391978141445906,
                             -0.5064128442463218240234100357430328276020555543825209010200358116,
                             -1.704073942798353125890357040042258199999701528848744333382888965,
                             -1.621387279943100957446718248635950256939087110905867154558498177,
                             -0.2822201163329221254721168781422969372055909804118582167968285855,
                             1.289730869589676870452536849346257833339968369869064415210073777,
                             1.825040836441961473879833695130502650900189302601317911329993969,
                             0.8479643704313097255793237765402977153127261569696355072465897462,
                             -0.8554815510933537550591248751713155316765743360232514516533432106,
                             -1.825703261616211163588106740727962975393895408404240610363741111,
                             -1.179728410701247374819850912459265570863435058561313527684931114,
                             0.5408984664121652927391895602228615637935594981438108851291923602,
                             1.768849796099751230935842530265014000641279887019190621568061379,
                             1.32661169098121032073230011983412616621821229671252518158670907,
                             -0.4019696912797636785776316428600560960617254900968511160329327212,
                             -1.74144788582288319655874444813066892464306695352983173464669113,
                             -1.329903540576225572705519373019545066570158705766037373703931059,
                             0.4529655987374768763308204975541025856284658185216535689349076418,
                             1.76735557965653657159247701815744041199332462258480216239605571,
                             1.192572118833474205178857181902755374393283235971876772830267403,
                             -0.6881852934793710139038280056160893901470958012567315062691233629,
                             -1.808653667727435558762453960407037915196334491595211804224640966,
                             -0.8775817610278861428894395063489018001838920490036514047378713878,
                             1.073066767939221805311866468117081427054152694273554883331657261,
                             1.763209673611515574984592513808903773575734319242946859593528331,
                             0.3350328280312988899820014466388211444569339094036185060337150911,
                             -1.507484006276953962610443860145346160033964599235016775616530997,
                             -1.474230099625261216193814934624945379820173870118200230942403287,
                             0.4316394338692541198545606764226261455159663121660478018674138004,
                             1.783647977426811818077762265691672534260412250111333885233635862,
                             0.7910303516356483512916160301620583606962467403541153268917872445,
                             -1.262864624025363770725508678290849589962819281619831838059521757,
                             -1.599501778931887429409321571547001906689875363985308488179961111,
                             0.2804115969499378396876082188627555970088847835534593969688312282,
                             1.767594893234060932435289318653170888692186830929581663511684703,
                             0.7226495025166389557304031505893307497537821555826021124193954336,
                             -1.376607995207215404017014016688646076591621667113113237567192194,
                             -1.438140615609054556853535070482242216053632892962868908966855253,
                             0.6657872343839450743161407682176813391733031865635081813279093448,
                             1.75204215440015656553519383805659815649033102972532429181654935,
                             0.114924910574806936496586827281190046015319039091854816427412461,
                             -1.703937445784984317031192316148943857600289240961667228567922148,
                             -0.789713363436768209078623765991400804207993647389272769527031701,
                             1.410638991630573664566982694934280235045392750712402278174891085,
                             1.277236685566519788116523143105365537287195046846096743086916097,
                             -1.000471154779981304673258649482818946011017659294300299740621347,
                             -1.571582746637760809525352228201182436939009598741882072558978388,
                             0.5758269326401179478586992020173573174219068402595780284872656411,
                             1.710387395393220755376946208457622588588916188456988305808805011,
                             -0.2017426829283418130357819581314642574879452817399981230382701254,
                             -1.746745649540871879280590066062411728166210732597487862804686233,
                             -0.08949611319350153424970482931959284012691573193584096310819518336,
                             1.731008387782421291815364642992673384667848819588413463354275431,
                             0.2873872692228440128914436558557148092728030564596565862172755767,
                             -1.701879282360919392111337725711623143049282761544964488813599726,
                             -0.3921518003852595221576967834027961825698539941700496911154995514,
                             1.683569662970523102839054867267089684861586579719662126027251433,
                             0.4065229389447600415271028822304275456853432364998859655307145749,
                             -1.685669660088527817125316672153634256239956997119714550892256266,
                             -0.3312660497019949668780738616991262758973032951409495727633988151,
                             1.703427357532494075033301086942988831298104290948825955342872954,
                             0.1645154794457942112835104678892165415808672941098215423320420191,
                             -1.717482996639168762456360193770485668317044553931913337404980914,
                             0.09501987977560088780558894382148004361932599317934947373803358891,
                             1.693528737792004875221340323835251999478345206408057478690935711,
                             -0.4408505296936183648724194917054676345663972018013444411058997144,
                             -1.583851545646889518549974550798982124460303171932217677526324239,
                             0.8478746799316681307455727763060408288019969422619541239019794416,
                             1.334122349893736800557504368140349060217781441468562067063499757,
                             -1.260086926883867041471172263676338305210270546942973222783409739,
                             -0.8994191346418940284776472941682684554122867801566605881821915931,
                             1.582462267889567532200382152143902257043884236838585752148974356,
                             0.2717674313604631238420996220705045486813876439685915635527459115,
                             -1.68710156802541549214975769710127529519846871528815641344726337,
                             0.4846816394613037995423976008970605999530614368852181394360131219,
                             1.446170993049405650774485230277702705442455025663848294104870277,
                             -1.206460746872453949880321075215140807857043113822796505739709494,
                             -0.7986189725219008738272273141011791314178236604281112054705148897,
                             1.641173593666854623050757226056851600055776928723739630191684877,
                             -0.1628648514731101558665957509634058549833517930872607733279457596,
                             -1.529248961013199732931206731653824949433137278054595268730892473,
                             1.134025912651839735722932028872626479253730475471814274217618483,
                             0.7650813341882986348039707753558589582268702887901636126795214873,
                             -1.651798944277472281207486273024425849495307096492351196038502409,
                             0.4244890630998230081683191537436765754527044323346701813619542235,
                             1.321517496131107843251084021651249536357741940760635736769174494,
                             -1.437013873036954689789427974300554371680696159436010549155668447,
                             -0.165404902273652766586116051013706700384845591927221561439768352,
                             1.558654680434497745925551824694339710326542063907871441402831492,
                             -1.158396579633652791793211062849090268333348026576779139112502405,
                             -0.5292878620506590891256304692720221997117110920393005892962573618,
                             1.622364111673338525385751403121782511987971351620352460077352634,
                             -0.9795240827888975995503805709750253586355649304485975143950951535,
                             -0.6709787839991318899312351881324214393740987011636436571219591883,
                             1.62397958126317928516957098919141825976993858693052749041462832,
                             -0.9666516305973033122409906978687687710960920396764411893127693094,
                             -0.6091054446850327919031924470555683390517036175594196044482462584,
                             1.596107678562374197246448851992514774380799878808158853527244574,
                             -1.121276938555506964305265287225262034358003289865147133793767718,
                             -0.3363929898126911296814714477137004383518845946705525338709697767,
                             1.485126957285338191762016443225029550037286029111598425046950517,
                             -1.38114103372028167549563254931537698226913725568243364295660619,
                             0.1634171866785960113697771220132981995065706179740234823168423273,
                             1.163530071976481389679786092420327265075834016349311395392044786,
                             -1.586868797352262898355055645011838980303043913609735914784717831,
                             0.8379246467004980363410714615016716267706301286715177262991211963,
                             0.4937628983497666408273567788240314864153725082542371897837359695,
                             -1.463405840056803361391785517056519792312562581804023783935408135,
                             1.445288801464397850669163767396508527039805248709086948167189831,
                             -0.5026022152710401954411124349382099393254471723651678891525600856,
                             -0.7323970303694952252109008252239891257917592172436508688749363894,
                             1.508266139428717399325892646662425993998169092532536962628704594,
                             -1.406384535473013395283738407351023246251366716197134387370391302,
                             0.5338537023486289856401554590426846054776647426020120422617347927,
                             0.6017623499162852036790214625044544005914045518031519981622955673,
                             -1.408081000590131510210021298175861487875327191479427243164638188,
                             1.51390533384168988825777912885316438139464247857743646506473939,
                             -0.9155494107726665800816423510007765576302714382509042716861679319,
                             -0.07380580204849907362435687438672326875755073562155615093052405484,
                             1.007374648550997151754782930160021838258339987608928646620852467,
                             -1.511589984027730964287895247695736285706232790368810008898908687,
                             1.423916488494064580870446037879403071439613358100830482792965917,
                             -0.8212392865980131257170003026609279442449764909601502707066000641,
                             -0.04713082016827290033306440361951471107446394571084105365530056656,
                             0.8745358973384489125020443087171869565083671041882836164602198616,
                             -1.407589764404663669865979684630716408176659745053314097758324032,
                             1.515715139254568281879718234233739432153589317490311087568361552,
                             -1.207246647925446942707718814673446356560405542668136301108365456,
                             0.6008249452620278405184205599563445216775924073980657520999710123,
                             0.1276161055495326573282987220481217010509507173246421724120470813,
                             -0.8005792522498612866200410997421338981133384127991266316305775584,
                             1.281507196215783724038756605222777830658895139964756553840665912,
                             -1.496698706950618073438683420832333022620520224786718912396169417,
                             1.437087297549665425017038073476523661855086749463211954437408682,
                             -1.145361700265477600264198635030550991006337931085069391524873912,
                             0.6957480645144921883322466066206479729878850597838450774410835757,
                             -0.1731014152451862447977595957248862387722827536228105452156860628,
                             -0.3441137545570198545294168429976163545105013228099172472961378705,
                             0.794781404876224952953703105548682765602436185289620171171515834,
                             -1.139882358998699579010313449905164653106078055969502071665199555,
                             1.36219315084907309265612376577677273375698674757550243485299679,
                             -1.462666781017726897072977216474352536976275650184886582549854892,
                             1.455226572073323977773180174020055618384249470640901408256470054,
                             -1.361361206333175203712920884326757161005709445269901510335210126,
                             1.205433203927577642206528837078795908364815553020582345177940396,
                             -1.011154742993590304954770820726920021225138889105802570646270559,
                             0.7993262489648496801992256275465228732175114048413320962003550342,
                             -0.5867010163281967613754379389674929663843444939157530710025958067,
                             0.3857230147890540518229764799871747772933625899084584138704370696,
                             -0.2048566409253803483520213039017222675838892684759038354126701794,
                             0.04925401621341454635270671200091594995897683171450204012106958771,
                             0.07844085045777133013950122482715787071771496591987644625021563145,
                             -0.1772917995617314743006875913762100664271119186646956153363683382,
                             0.2473614785240816276566981917424002781276040292313448702682211664,
                             -0.289139940282091935056123029500842839834771138650382175507441399,
                             0.3031303549963070489852833454511756214314406638042178153467347686,
                             -0.289596899310634187689376673805313731922233112682007557645164712,
                             0.2484751417073693759311463927254733437479045810361494759417325888,
                             -0.1794466313864296101501500001636212296050316552854874591263302998,
                             0.08218308911633292864301412356742401686205459428805972805142015495,
                             0.04323252432646093393405980856375149725644854768446212710370746063,
                             -0.1957052264685492061051029039560794889840750682230684019024568036,
                             0.3723603259063032674492184674924802924770148075792277958378868085,
                             -0.5676533632105859971144573196589510301990099564013260595975947627,
                             0.7724538046794021771333610434136559545817608723383699832562090912,
                             -0.9732706674059698475241338753527524013760756088847868777026748064,
                             1.151874944585784610490493901554945002111653268980801523286552413,
                             -1.285658623918784356248622025620542429269167907026658745756659098,
                             1.349122183197129712751703142631660897079467141541958001591662846,
                             -1.31685408589672370214961234041600993075298683124249973165045475,
                             1.168196625671366365727388830073063266897767531359550760947937022,
                             -0.8934234711959527455422211894301281300606460531550570735331940588,
                             0.50065634374572477751444066424050264062041081755224193857837196,
                             -0.02196597479789601924130089973174562572468627072046333586350177786,
                             -0.4836947258276814927724987693162813207070335533541248864955200071,
                             0.9335581043308996828387927288124851984145513049619089748964094603,
                             -1.232628887499418097614864694553080337020081526106706606019127477,
                             1.29469425134279143970567948578777410749361886457030098003116472,
                             -1.070461121969568304900917450084321212358472351779270691659804586,
                             0.576068142956347378403884558051281945053513750572574741634882952,
                             0.08918443240350289916771159787371740648768551107397260438096722218,
                             -0.7489883006243269800365237866194996309007053344727852974599033441,
                             1.189674142758294127737359161873330921745257640638901416382392652,
                             -1.231940244676479676809630773313222017533612692406967018121594637,
                             0.8157197157546058578776189286478294553285413154241182899313265406,
                             -0.06139721733392833772833182514896790082329772490197495454835795858,
                             -0.7362025618430732868715483219987059002085263240263316910591220587,
                             1.207965447358868276394287906178315987104706283317052473249652029,
                             -1.087025996675433682271322310382709660518948254006555609253567945,
                             0.3849228431443899153964039761595394643697474820946277820182221454,
                             0.5474219128919456987865732164697364533958054656411695883922789816,
                             -1.161903134087272258573675095755202191045207224826968251819262891,
                             1.035715597013658602702448398976817332364291524237242521363126562,
                             -0.1988680280216859810908253503544397305024742416389709128708271687,
                             -0.7914290338395364793562815314625225128929834146060873606023837582,
                             1.182354156057581149226861595555139475806700180228187660079519273,
                             -0.6144737539560740567619935164990952313725875451601786188060785021,
                             -0.4854720383649356585787704036973622296726275399828383893045637639,
                             1.151187094108641798715365191766938454376218058325176724171175312,
                             -0.7192395068395728138260863192856823168799976119011154086663180934,
                             -0.4378020657909875094650659795461981811772967807741631149062941226,
                             1.133177108022710437353500783401351919436952260603791470821862838,
                             -0.5684556059761353727226430431125035681134732082538803848628326402,
                             -0.6590509566800734119883009851118652962664155495654659398665112776,
                             1.07642975308437478674419608000314828278432992363386441555012148,
                             -0.1115622228670333134564775560474436621266704655323036981724190388,
                             -0.9974118189493335240541442572174135250107627973414235905864993657,
                             0.697608747334081857417677333064594274790322215998193219851015161,
                             0.6230972488192877335370886575704740377208308507536155587663243866,
                             -0.974516536167174072156062825781104931101375426194815480551930581,
                             -0.2367321978311233163262142861469880469663640641098057296496903857,
                             1.035326404693083440897668357640930865398170039975541587272260617,
                             -0.02202299531446446655902909489751456593211398392020351324290943375,
                             -1.011614081630377518647217460741704401645658887648830805355226833,
                             0.1194141133999092382775253366815218245364202395163026324357855886,
                             0.9847140700021197039206687085971495008409500998521014403060132285,
                             -0.05740051384366925439265490030687037980688138414093619663393962799,
                             -0.9629691651201747981359277936847603267725517336042594327090285872,
                             -0.159450497812981389349935733650156224613656024235585396239885927,
                             0.8778022815457609223675812589159419854814926322521851843836066028,
                             0.4982445900581134887461169261108195592749210771069729578613353034,
                             -0.5971706662916220169762741441342243453667878196798079737418756256,
                             -0.812898785105067000424680999446942129403022651857725107745089237,
                             0.02511158307363092598875579956097807978118128230517389821286161138,
                             0.7784117730018992460944232099040174558098367657630590548490421655,
                             0.6347447677736637097333254122672006179990121522179942843110676711,
                             -0.1166705674383408936795672429766645983332920738953310796038548884,
                             -0.6931162849072888017524436126705804626997026680149784953436968313,
                             -0.6756112226852585376680320451823026140880841533497405059709487494,
                             -0.220420154874629587683398427533689485941589142704040730461061231,
                             0.2787951669211695226850975694109832414030005934516310002397323516,
                             0.5579081030218973541316939627342981900078055029487430774000992274,
                             0.5923756264227923508167792291816009732767958833673629057820719939,
                             0.5059337136238471665702604378969036163730513656761924189028459319,
                             0.4482883573538263579148237103988283908662267992122620610828087784,
                             0.5445725641405923018271640182178233256545288982318871440949459393,
                             0.932435933392775632959451453674435344269565375238628395492869912,
                             1.886212254848165488692347024025147595704533100100938098818038983,
                             4.10068204993288988938203407917793529439024461377513711983770919]
        var ans: (bi: Double, dbi: Double, error: Int)
        var i: Int = 0
        ans = SSSpecialFunctions.airyBi(x: 0)
        var re, ae: Double
        var maxRe: Double = 0.0
        var maxAe: Double = 0.0
        var minRe: Double = 1.0
        var minAe: Double = 1.0
        var rep, aep: Double
        var maxRep: Double = 0.0
        var maxAep: Double = 0.0
        var minRep: Double = 1.0
        var minAep: Double = 1.0
        for x: Double in stride(from: -200, through: 2, by: 0.5) {
            ans = SSSpecialFunctions.airyBi(x: x)
            if ans.bi.isFinite && ans.dbi.isFinite && bi[i].isFinite && dbi[i].isFinite {
                re = abs((bi[i] - ans.bi) / ans.bi)
                ae = abs(bi[i] - ans.bi)
                if re > maxRe {
                    maxRe = re
                }
                else if re < minRe {
                    minRe = re
                }
                if ae > maxAe {
                    maxAe = ae
                }
                else if ae < minAe {
                    minAe = ae
                }
                rep = abs((dbi[i] - ans.dbi) / ans.dbi)
                aep = abs(dbi[i] - ans.dbi)
                if rep > maxRep {
                    maxRep = rep
                }
                else if rep < minRep {
                    minRep = rep
                }
                if aep > maxAep {
                    maxAep = aep
                }
                else if aep < minAep {
                    minAep = aep
                }
            }
            //            if abs(ans.ai - ai[i]) > 1e-16 {
            //                print("x : \(x), abs. Error: \(abs(ans.ai - ai[i])), rel. Error: \(re) ")
            //            }
            //            XCTAssertEqual(ans.ai, ai[i], accuracy: 1e-14)
            i = i + 1
        }
        print("AiryAi===============================================")
        print("min. abs. Error: \(minAe), max. abs. Error: \(maxAe)")
        print("min. rel. Error: \(minRe), max. rel. Error: \(maxRe)")
        print("AiryAiPrime==========================================")
        print("min. abs. Error: \(minAep), max. abs. Error: \(maxAep)")
        print("min. rel. Error: \(minRep), max. rel. Error: \(maxRep)")
        
    }
    
    
    
    //
    //
    //    func testPerformanceExample() {
    //        // This is an example of a performance test case.
    //        self.measure {
    //        }
    //    }
    
    func testBesselI0() {
        // BesselI0(x), 100 <= x <= 100, step 2
        
        let besselI0Data: [Float80] = [
            1.073751707131073823519720857603494661288403193325272795401540063e42,
            1.467956067407419253935815774834718367952993875125561963795542585e41,
            2.007304126311214310046362681359609158353334647885749594503448292e40,
            2.745415388947168612088253534423581168638303920667762206373930911e39,
            3.755794357405601907191452619533778214646739013457777677287809344e38,
            5.139238345508663835278491143551074437225477975963566786265569375e37,
            7.034019697322303775839744667527863794825432576041470228870590053e36,
            9.629888111716449119891609199747156897132776193136573093246999531e35,
            1.318733593825985352694048063551898085336352557787738371327431147e35,
            1.806411872857697017039735673179409600758257628613750697833410277e34,
            2.475178404334170488669557055604816741023037025797109181730474962e33,
            3.392601579325684183940206288406749310455895248442554580118730353e32,
            4.651606402086077743494549469956883405890265150856115920007394808e31,
            6.380056142918597534977429545519136072702305046180553281007861394e30,
            8.753985270944612432992459963519116073415315421938008883059037247e29,
            1.201588957912546360498375395967869129353733632850675094875133012e29,
            1.650002782141142080206219328914127394026116255252557541946408918e28,
            2.266745504580402482346612567083138715657662968786714445572829081e27,
            3.115457918187897557650694682306942275028270357926158832387382537e26,
            4.284053401489351373487689539590410365728846884537220296619345327e25,
            5.894077055609801168278817440333904737978983020316213949659565109e24,
            8.113723742037748511430594951641382362967922457155325146313559123e23,
            1.117597102908680557440252330312308169878006518727217928273409229e23,
            1.540387598056586022981882040602949012236539330144407280660208615e22,
            2.12459265487660652056871806315958339727216109963237958243900645e21,
            2.932553783849336326654675079456853858051295754348464637687510971e20,
            4.051049958561881502403150208528714832868499711626942014609943758e19,
            5.601064760357453441253288431922714610935756843087707673641028089e18,
            7.751559537842989740397780668696425957540590900893385159036597068e17,
            1.073895413680451019816822994457615112605655249605048907233546246e17,
            1.48947747934198999242245915707211844449466595566709917645085521e16,
            2.068504714851044845188315030265960321539502797950162891330469035e15,
            2.876667778112440429102939018743956743168597811585388259920143996e14,
            4.0068575042540716033612386491417848375483205750833823294989207e13,
            5.590908381350873086500103776088605327594330420659633252120139658e12,
            7.816722978239774897173898167052950054449442539779470033476887726e11,
            1.095346047317572734826748564401226073645732030800725365612567578e11,
            1.53889767056608104628354178833613609965823297928610316806121827e10,
            2.168619088241376503688993617666420248551029614224983674396580205e9,
            3.066929936403647456134989153557154852040468018913248584558728394e8,
            4.355828255955353327210666008921769191706709948274652699301682074e7,
            6.218412420781002949862477755522804357608567431075431079140885033e6,
            893446.2279201050170708640309761884542780698188588532984237189283,
            129418.5627006485636645883284779364697034506653868683440024006502,
            18948.92534929630886120810822975396610096395087020475178444194212,
            2815.71662846625447146981115342659009307845123839607778216714826,
            427.5641157218047851773967913180828851255641047912371158842972189,
            67.23440697647797532618802514487659014539309769967631228874757693,
            11.30192195213633049635627018321710249741261659443533770600649619,
            2.279585302336067267437204440811533353285841102785459054070839752,
            1,
            2.279585302336067267437204440811533353285841102785459054070839752,
            11.30192195213633049635627018321710249741261659443533770600649619,
            67.23440697647797532618802514487659014539309769967631228874757693,
            427.5641157218047851773967913180828851255641047912371158842972189,
            2815.71662846625447146981115342659009307845123839607778216714826,
            18948.92534929630886120810822975396610096395087020475178444194212,
            129418.5627006485636645883284779364697034506653868683440024006502,
            893446.2279201050170708640309761884542780698188588532984237189283,
            6.218412420781002949862477755522804357608567431075431079140885033e6,
            4.355828255955353327210666008921769191706709948274652699301682074e7,
            3.066929936403647456134989153557154852040468018913248584558728394e8,
            2.168619088241376503688993617666420248551029614224983674396580205e9,
            1.53889767056608104628354178833613609965823297928610316806121827e10,
            1.095346047317572734826748564401226073645732030800725365612567578e11,
            7.816722978239774897173898167052950054449442539779470033476887726e11,
            5.590908381350873086500103776088605327594330420659633252120139658e12,
            4.0068575042540716033612386491417848375483205750833823294989207e13,
            2.876667778112440429102939018743956743168597811585388259920143996e14,
            2.068504714851044845188315030265960321539502797950162891330469035e15,
            1.48947747934198999242245915707211844449466595566709917645085521e16,
            1.073895413680451019816822994457615112605655249605048907233546246e17,
            7.751559537842989740397780668696425957540590900893385159036597068e17,
            5.601064760357453441253288431922714610935756843087707673641028089e18,
            4.051049958561881502403150208528714832868499711626942014609943758e19,
            2.932553783849336326654675079456853858051295754348464637687510971e20,
            2.12459265487660652056871806315958339727216109963237958243900645e21,
            1.540387598056586022981882040602949012236539330144407280660208615e22,
            1.117597102908680557440252330312308169878006518727217928273409229e23,
            8.113723742037748511430594951641382362967922457155325146313559123e23,
            5.894077055609801168278817440333904737978983020316213949659565109e24,
            4.284053401489351373487689539590410365728846884537220296619345327e25,
            3.115457918187897557650694682306942275028270357926158832387382537e26,
            2.266745504580402482346612567083138715657662968786714445572829081e27,
            1.650002782141142080206219328914127394026116255252557541946408918e28,
            1.201588957912546360498375395967869129353733632850675094875133012e29,
            8.753985270944612432992459963519116073415315421938008883059037247e29,
            6.380056142918597534977429545519136072702305046180553281007861394e30,
            4.651606402086077743494549469956883405890265150856115920007394808e31,
            3.392601579325684183940206288406749310455895248442554580118730353e32,
            2.475178404334170488669557055604816741023037025797109181730474962e33,
            1.806411872857697017039735673179409600758257628613750697833410277e34,
            1.318733593825985352694048063551898085336352557787738371327431147e35,
            9.629888111716449119891609199747156897132776193136573093246999531e35,
            7.034019697322303775839744667527863794825432576041470228870590053e36,
            5.139238345508663835278491143551074437225477975963566786265569375e37,
            3.755794357405601907191452619533778214646739013457777677287809344e38,
            2.745415388947168612088253534423581168638303920667762206373930911e39,
            2.007304126311214310046362681359609158353334647885749594503448292e40,
            1.467956067407419253935815774834718367952993875125561963795542585e41,
            1.073751707131073823519720857603494661288403193325272795401540063e42
        ]
        
        var i: Int = 0
        var relErr: Float80
        var b: Float80
        var maxRelErr: Float80 = 0
        for x: Float80 in stride(from: -100.0, through: 100.0, by: 2.0) {
            b = SSSpecialFunctions.besselI0(x: x)
            relErr = abs((besselI0Data[i] -  b ) / b)
            if relErr > maxRelErr {
                maxRelErr = relErr
            }
            XCTAssertTrue(maxRelErr < 1e-18)
            i = i + 1
        }
        print("max. rel. Error BesselI0: \(maxRelErr)")
    }
    
    func testBesselI1() {
        // BesselI0(x), 100 <= x <= 100, step 2
        
        let besselI1Data: [Float80] = [
            -1.068369390338162481206145763224295265446122844056232269659180215e42,
            -1.460447191448613067942374442380142387923762438351657009868629094e41,
            -1.996821903194505409637630425063375312665899035040224188836726441e40,
            -2.730772856909081758614135728164123024802125777060559872177025525e39,
            -3.735326350978314123659483987653532380698268977291193355356296482e38,
            -5.110606815256598156879549044833046714518709875773519209178559984e37,
            -6.993938822790253503678762424987562681138663389509499132903003066e36,
            -9.573735707390484714263761307153496443186331656379024183638836117e35,
            -1.310860343758411947198800818853136386232934921350785210946161467e35,
            -1.795363167356007886158175421330796010698137531180056649075802182e34,
            -2.459659579567540863040021721128001496489656404187524085229261287e33,
            -3.370783517923905333324675281818561004566825067693054772790675049e32,
            -4.620901709133033862066717851782948073583362198871385138108115689e31,
            -6.336800007853939278412823368731598021844751646091385613828104247e30,
            -8.692979627521778644883434085049722465424274946378588699738622646e29,
            -1.192975078889231187497794932106843650596955006768039461233716851e29,
            -1.637825132931648220890864141930211850506633544954851368697677759e28,
            -2.24950713385321927236479329740975022105093325674325300215763782e27,
            -3.091021803908183541781936494588350937338990016753056982342104361e26,
            -4.249362968445755601728269094642459377954642193421035373776776381e25,
            -5.844751588390468281335172872520837044897779789983932052980512904e24,
            -8.043471013373183316556029239064131127535020599312351848285768655e23,
            -1.107573191725043112467404673827652605537771652414148643520350905e23,
            -1.526057458598636684372575035455269036830409306541562407918768458e22,
            -2.104063716183504289669484344981338990591735764342559826806955102e21,
            -2.903078590103556796751433255432087978298190812396606318205834258e20,
            -4.008627003263491800667481327309269150058951846366638231803988253e19,
            -5.539845296915024160705686153603051412805770103872286780546746217e18,
            -7.662961346952936477982135130606025728189327815695586076078403508e17,
            -1.061032963616063847880447922826667429116611943906924901322600654e17,
            -1.470739616325935273881695805348819289591818325922286739673506613e16,
            -2.041103569981368712451525210253853360426690572964022989197851406e15,
            -2.836428540113437418427033401392555958788882920957974694117344477e14,
            -3.947486494124859131212469530309781282105456960006110137316396272e13,
            -5.502845511211248186924860561446296048318749435826864931656109325e12,
            -7.68532038938956999494294710788180181907138788373799676725684905e11,
            -1.075605042080822441399403259897041769965255076503601510364165728e11,
            -1.509007264234164430530718992683130000506547675157343375925465528e10,
            -2.122947893287313751001778529233270010858919602758567662399602196e9,
            -2.996396068773789797263363050963381156794895241638514212224249948e8,
            -4.245497338512777018140990665855938402281209193282978792788737793e7,
            -6.043133242115628370407039023521274191615193335667040936711200851e6,
            -865059.4358548394714180762174952913872674474849548826886670014901,
            -124707.259149069860350493462759992619393159690036486607143147959,
            -18141.34878163883160142521479562888222329535960859472184743688481,
            -2670.988303701254654341031966772152549145745153787537713108489316,
            -399.8731367825600982190830861458227548896284439040676473065743717,
            -61.34193677764023786132931011458462953361232819281033973737921721,
            -9.759465153704449909475192567312680900055970333252967306927528051,
            -1.590636854637329063382254424999666247954478159495536647132287985,
            0,
            1.590636854637329063382254424999666247954478159495536647132287985,
            9.759465153704449909475192567312680900055970333252967306927528051,
            61.34193677764023786132931011458462953361232819281033973737921721,
            399.8731367825600982190830861458227548896284439040676473065743717,
            2670.988303701254654341031966772152549145745153787537713108489316,
            18141.34878163883160142521479562888222329535960859472184743688481,
            124707.259149069860350493462759992619393159690036486607143147959,
            865059.4358548394714180762174952913872674474849548826886670014901,
            6.043133242115628370407039023521274191615193335667040936711200851e6,
            4.245497338512777018140990665855938402281209193282978792788737793e7,
            2.996396068773789797263363050963381156794895241638514212224249948e8,
            2.122947893287313751001778529233270010858919602758567662399602196e9,
            1.509007264234164430530718992683130000506547675157343375925465528e10,
            1.075605042080822441399403259897041769965255076503601510364165728e11,
            7.68532038938956999494294710788180181907138788373799676725684905e11,
            5.502845511211248186924860561446296048318749435826864931656109325e12,
            3.947486494124859131212469530309781282105456960006110137316396272e13,
            2.836428540113437418427033401392555958788882920957974694117344477e14,
            2.041103569981368712451525210253853360426690572964022989197851406e15,
            1.470739616325935273881695805348819289591818325922286739673506613e16,
            1.061032963616063847880447922826667429116611943906924901322600654e17,
            7.662961346952936477982135130606025728189327815695586076078403508e17,
            5.539845296915024160705686153603051412805770103872286780546746217e18,
            4.008627003263491800667481327309269150058951846366638231803988253e19,
            2.903078590103556796751433255432087978298190812396606318205834258e20,
            2.104063716183504289669484344981338990591735764342559826806955102e21,
            1.526057458598636684372575035455269036830409306541562407918768458e22,
            1.107573191725043112467404673827652605537771652414148643520350905e23,
            8.043471013373183316556029239064131127535020599312351848285768655e23,
            5.844751588390468281335172872520837044897779789983932052980512904e24,
            4.249362968445755601728269094642459377954642193421035373776776381e25,
            3.091021803908183541781936494588350937338990016753056982342104361e26,
            2.24950713385321927236479329740975022105093325674325300215763782e27,
            1.637825132931648220890864141930211850506633544954851368697677759e28,
            1.192975078889231187497794932106843650596955006768039461233716851e29,
            8.692979627521778644883434085049722465424274946378588699738622646e29,
            6.336800007853939278412823368731598021844751646091385613828104247e30,
            4.620901709133033862066717851782948073583362198871385138108115689e31,
            3.370783517923905333324675281818561004566825067693054772790675049e32,
            2.459659579567540863040021721128001496489656404187524085229261287e33,
            1.795363167356007886158175421330796010698137531180056649075802182e34,
            1.310860343758411947198800818853136386232934921350785210946161467e35,
            9.573735707390484714263761307153496443186331656379024183638836117e35,
            6.993938822790253503678762424987562681138663389509499132903003066e36,
            5.110606815256598156879549044833046714518709875773519209178559984e37,
            3.735326350978314123659483987653532380698268977291193355356296482e38,
            2.730772856909081758614135728164123024802125777060559872177025525e39,
            1.996821903194505409637630425063375312665899035040224188836726441e40,
            1.460447191448613067942374442380142387923762438351657009868629094e41,
            1.068369390338162481206145763224295265446122844056232269659180215e42
        ]
        
        var i: Int = 0
        var relErr: Float80
        var b: Float80
        var maxRelErr: Float80 = 0
        for x: Float80 in stride(from: -100.0, through: 100.0, by: 2.0) {
            b = SSSpecialFunctions.besselI1(x: x)
            relErr = abs((besselI1Data[i] -  b ) / b)
            if relErr > maxRelErr {
                maxRelErr = relErr
            }
            XCTAssertTrue(maxRelErr < 1e-18)
            i = i + 1
        }
        print("max. rel. Error BesselI1: \(maxRelErr)")
    }
    
    func testBesselJ0() {
        // BesselI0(x), 100 <= x <= 100, step 2
        
        let besselJ0Data: [Float80] = [
            0.01998585030422312242422839095084899068063357885902792955864211445,
            -0.07935225749467102183213740036723436810512612717213070160973121313,
            0.04633460745193362295625058165603384471964821953554088657264193155,
            0.04204854102209948103399741286590846691712996189473712786840379584,
            -0.08270836557756638484827663676096906355535525018556192131223196168,
            0.02663001669996951132257906706609129818817744042263253937206117465,
            0.06215116143661287971069678009302653850579808113778392525864528271,
            -0.07957194751921752067419061776262703761258507714776270672613406229,
            0.003402263505860124821526380046304588894514670410448890295446474981,
            0.07862326054974704868875428078076123371680664881417994398384144918,
            -0.06974216551221002283974754961196436976991723263143010955392306212,
            -0.02182349179355920979252360120813242480851467666852776212460278676,
            0.08995643772497043618219705944569301130366731576957236165182711168,
            -0.05347677717910857574696039005740397574316465432077647140742947125,
            -0.04729446581174154126394032579227169755256542358974937525962693224,
            0.09490872648301354226674669208764927586130281993971102196742015283,
            -0.03148851718745771618962933029124648595202582222884081732768946311,
            -0.07113722783672528272404345049088150467108507777266350842128115244,
            0.09259001221604811433093570258749352164977447176286468115780520159,
            -0.004909609587473566646010944124489737247399086516263403585447275468,
            -0.09147180408906186953148083372479580829422103840314770687819524667,
            0.08252053218584683794062840957952052808773325807567061046513110357,
            0.02477365573419652598463316552316006435354268257190903431700478076,
            -0.1065227062157467635659813413939094248026341226592864271761487205,
            0.06465502794967447822296918132192567409993084647953983118271826806,
            0.05581232766925181500475047852943396817659267104557813619661325315,
            -0.1147148783241972523697519104676949787346169389722965060812413665,
            0.03936480102453884441406072968725092379570556015643769566977197543,
            0.0863066993322865791150794465038425663635772223861518070011987431,
            -0.1147394967135828207887863890042820518008480586063038065067269768,
            0.007366890584237289553531735691438071378291312015387388285023703265,
            0.1143327390611501165710470070375335239169589696756769322245314591,
            -0.1055673816686880622107446822788661941538957885403309659913981816,
            -0.0304211910217926520719389199488897568892245210538148561075072651,
            0.138079009746555923759306156222532881246843986259489356333380074,
            -0.08636798358104021133596232449606394801664860872851939896178117088,
            -0.07315701054899961390230402213486123468729257216414587308812099136,
            0.1559993155224211296028067442401865094597907030370039942551621993,
            -0.05623027416685926701477611803416836171344367056944195340707401162,
            -0.1206514757048671801557235354682913265544652955643264352905529677,
            0.1670246643405831547273205447013840388753333784085330842014622052,
            -0.01335580572198411088488540628382812405758638110001944261376497741,
            -0.1748990739836291848284025177258194074544967761190823855470137588,
            0.1710734761104586590630951931906235768655841438005865706126349622,
            0.04768931079683353662381168914142913846139850923313670060392775046,
            -0.2459357644513483351977608624853287538296000728265665696991583937,
            0.1716508071375539060908694078519720010684237099201356660300138595,
            0.150645257250996931662327948948689888849249532766532072151335629,
            -0.3971498098638473722865907684516980419756186852893888401403682212,
            0.223890779141235668051827454649948625825154482218607603128349706,
            1,
            0.223890779141235668051827454649948625825154482218607603128349706,
            -0.3971498098638473722865907684516980419756186852893888401403682212,
            0.150645257250996931662327948948689888849249532766532072151335629,
            0.1716508071375539060908694078519720010684237099201356660300138595,
            -0.2459357644513483351977608624853287538296000728265665696991583937,
            0.04768931079683353662381168914142913846139850923313670060392775046,
            0.1710734761104586590630951931906235768655841438005865706126349622,
            -0.1748990739836291848284025177258194074544967761190823855470137588,
            -0.01335580572198411088488540628382812405758638110001944261376497741,
            0.1670246643405831547273205447013840388753333784085330842014622052,
            -0.1206514757048671801557235354682913265544652955643264352905529677,
            -0.05623027416685926701477611803416836171344367056944195340707401162,
            0.1559993155224211296028067442401865094597907030370039942551621993,
            -0.07315701054899961390230402213486123468729257216414587308812099136,
            -0.08636798358104021133596232449606394801664860872851939896178117088,
            0.138079009746555923759306156222532881246843986259489356333380074,
            -0.0304211910217926520719389199488897568892245210538148561075072651,
            -0.1055673816686880622107446822788661941538957885403309659913981816,
            0.1143327390611501165710470070375335239169589696756769322245314591,
            0.007366890584237289553531735691438071378291312015387388285023703265,
            -0.1147394967135828207887863890042820518008480586063038065067269768,
            0.0863066993322865791150794465038425663635772223861518070011987431,
            0.03936480102453884441406072968725092379570556015643769566977197543,
            -0.1147148783241972523697519104676949787346169389722965060812413665,
            0.05581232766925181500475047852943396817659267104557813619661325315,
            0.06465502794967447822296918132192567409993084647953983118271826806,
            -0.1065227062157467635659813413939094248026341226592864271761487205,
            0.02477365573419652598463316552316006435354268257190903431700478076,
            0.08252053218584683794062840957952052808773325807567061046513110357,
            -0.09147180408906186953148083372479580829422103840314770687819524667,
            -0.004909609587473566646010944124489737247399086516263403585447275468,
            0.09259001221604811433093570258749352164977447176286468115780520159,
            -0.07113722783672528272404345049088150467108507777266350842128115244,
            -0.03148851718745771618962933029124648595202582222884081732768946311,
            0.09490872648301354226674669208764927586130281993971102196742015283,
            -0.04729446581174154126394032579227169755256542358974937525962693224,
            -0.05347677717910857574696039005740397574316465432077647140742947125,
            0.08995643772497043618219705944569301130366731576957236165182711168,
            -0.02182349179355920979252360120813242480851467666852776212460278676,
            -0.06974216551221002283974754961196436976991723263143010955392306212,
            0.07862326054974704868875428078076123371680664881417994398384144918,
            0.003402263505860124821526380046304588894514670410448890295446474981,
            -0.07957194751921752067419061776262703761258507714776270672613406229,
            0.06215116143661287971069678009302653850579808113778392525864528271,
            0.02663001669996951132257906706609129818817744042263253937206117465,
            -0.08270836557756638484827663676096906355535525018556192131223196168,
            0.04204854102209948103399741286590846691712996189473712786840379584,
            0.04633460745193362295625058165603384471964821953554088657264193155,
            -0.07935225749467102183213740036723436810512612717213070160973121313,
            0.01998585030422312242422839095084899068063357885902792955864211445
        ]
        
        var i: Int = 0
        var relErr: Float80
        var b: Float80
        var maxRelErr: Float80 = 0
        for x: Float80 in stride(from: -100.0, through: 100.0, by: 2.0) {
            b = SSSpecialFunctions.besselJ0(x: x)
            relErr = abs((besselJ0Data[i] -  b ) / b)
            if relErr > maxRelErr {
                maxRelErr = relErr
            }
            XCTAssertTrue(maxRelErr < 1e-15)
            i = i + 1
        }
        print("max. rel. Error BesselJ0: \(maxRelErr)")
    }
    
    
    func testGamma() {
        var ans: Complex<Double>
        var i: Int = 0
        var reR, reI, aeR, aeI: Double
        var maxReR: Double = 0.0
        var maxAeR: Double = 0.0
        var minReR: Double = 1.0
        var minAeR: Double = 1.0
        var maxReI: Double = 0.0
        var maxAeI: Double = 0.0
        var minReI: Double = 1.0
        var minAeI: Double = 1.0
        var y: Double = -2
        for x: Double in stride(from: 0, through: 150, by: 1.0) {
            ans = SSMath.ComplexMath.tgamma1(z: Complex<Double>.init(re: x, im: y))
            if ans.re.isFinite && ans.im.isFinite && g1R[i].isFinite && g1I[i].isFinite {
                reR = abs((ans.re - g1R[i]) / ans.re)
                aeR = abs(ans.re - g1R[i])
                if reR > maxReR {
                    maxReR = reR
                }
                else if reR < minReR {
                    minReR = reR
                }
                if aeR > maxAeR {
                    maxAeR = aeR
                }
                else if aeR < minAeR {
                    minAeR = aeR
                }
                reI = abs((ans.im - g1I[i]) / ans.im)
                aeI = abs(ans.im - g1I[i])
                if reI > maxReI {
                    maxReI = reI
                }
                else if reI < minReI {
                    minReI = reI
                }
                if aeI > maxAeI {
                    maxAeI = aeI
                }
                else if aeI < minAeI {
                    minAeI = aeI
                }
            }
            i = i + 1
        }
        print("Complex Gamma REAL ========================================")
        print("min. abs. Error: \(minAeR), max. abs. Error: \(maxAeR)")
        print("min. rel. Error: \(minReR), max. rel. Error: \(maxReR)")
        print("Complex Gamma IMAG ==========================================")
        print("min. abs. Error: \(minAeI), max. abs. Error: \(maxAeI)")
        print("min. rel. Error: \(minReI), max. rel. Error: \(maxReI)")
        maxReR = 0.0
        maxAeR = 0.0
        minReR = 1.0
        minAeR = 1.0
        maxReI = 0.0
        maxAeI = 0.0
        minReI = 1.0
        minAeI = 1.0
        y = -2
        i = 0
        for x: Double in stride(from: -150, through: 0, by: 1.0) {
            ans = SSMath.ComplexMath.tgamma1(z: Complex<Double>.init(re: x, im: y))
            if ans.re.isFinite && ans.im.isFinite && g1R[i].isFinite && g1I[i].isFinite {
                reR = abs((ans.re - g1Rn[i]) / ans.re)
                aeR = abs(ans.re - g1Rn[i])
                if reR > maxReR {
                    maxReR = reR
                }
                else if reR < minReR {
                    minReR = reR
                }
                if aeR > maxAeR {
                    maxAeR = aeR
                }
                else if aeR < minAeR {
                    minAeR = aeR
                }
                reI = abs((ans.im - g1In[i]) / ans.im)
                aeI = abs(ans.im - g1In[i])
                if reI > maxReI {
                    maxReI = reI
                }
                else if reI < minReI {
                    minReI = reI
                }
                if aeI > maxAeI {
                    maxAeI = aeI
                }
                else if aeI < minAeI {
                    minAeI = aeI
                }
            }
            i = i + 1
        }
        print("Complex Gamma REAL ========================================")
        print("min. abs. Error: \(minAeR), max. abs. Error: \(maxAeR)")
        print("min. rel. Error: \(minReR), max. rel. Error: \(maxReR)")
        print("Complex Gamma IMAG ==========================================")
        print("min. abs. Error: \(minAeI), max. abs. Error: \(maxAeI)")
        print("min. rel. Error: \(minReI), max. rel. Error: \(maxReI)")
    }
    
    // gamma 1-150
    let gamma150: [Float80] = [1,0.886226925452758,1,1.329340388179137,2,3.3233509704478426,6,
                               11.63172839656745,24,52.34277778455352,120,287.8852778150444,720,
                               1871.2543057977884,5040,14034.407293483413,40320,119292.46199460901,362880,
                               1.1332783889487856e6,3.6288e6,1899423083962249e7,3.99168e7,1.3684336546556586e8,
                               4.790016e8,1.7105420683195732e9,6.2270208e9,2.309231792231424e10,8.71782912e10,
                               3.3483860987355646e11,1.307674368e12,5.189998453040126e12,2.0922789888e13,
                               8.563497447516208e13,3.55687428096e14,1.4986120533153358e15,6.402373705728e15,
                               2.772432298633372e16,1.21645100408832e17,5.406242982335074e17,2.43290200817664e18,
                               1.1082798113786907e19,5.109094217170944e19,2.3828015944641846e20,
                               1.1240007277776077e21,5.361303587544414e21,2.585201673888498e22,
                               1.2599063430729376e23,6.204484017332394e23,3.0867705405286977e24,
                               1.5511210043330984e25,7.87126487834818e25,4.032914611266057e26,2.085885192762268e27,
                               1.0888869450418352e28,5.736184280096233e28,3.048883446117138e29,
                               1.6348125198274267e30,8.841761993739701e30,4.822696933490907e31,2.652528598121911e32,
                               1.4709225647147272e33,8.222838654177924e33,4.633406078851391e34,
                               2.6313083693369355e35,1.5058569756267023e36,8.68331761881189e36,5.044620868349451e37,
                               2.952327990396041e38,1.7403941995805607e39,1.0333147966386144e40,6.17839940851099e40,
                               3.719933267899013e41,2.2551157841065122e42,1.3763753091226346e43,
                               8.456684190399418e43,5.23022617466601e44,3.2558234133037764e45,2.0397882081197447e46,
                               1.2860502482549919e47,8.15915283247898e47,5.208503505432716e48,3.34525266131638e49,
                               2.1615289547545774e50,1.4050061177528801e51,9.186498057706951e51,
                               6.041526306337384e52,3.996126655102524e53,2.6582715747884495e54,1.778276361520623e55,
                               1.196222208654802e56,8.091157444918834e56,5.502622159812089e57,3.762388211887258e58,
                               2.5862324151116827e59,1.7871344006464473e60,1.2413915592536068e61,
                               8.667601843135271e61,6.082818640342679e62,4.290462912352009e63,3.041409320171302e64,
                               2.166683770737728e65,1.5511187532874088e66,1.1158421419299478e67,
                               8.065817517094494e67,5.858171245132188e68,4.274883284060123e69,3.134121616145727e70,
                               2.308436973392454e71,1.7080962807994084e72,1.2696403353658648e73,
                               9.479934358436689e73,7.109985878048745e74,5.3561629125167395e75,4.052691950487695e76,
                               3.0797936746971935e77,2.3505613312829024e78,1.8016792996978842e79,
                               1.3868311854568818e80,1.0719991833202212e81,8.320987112741681e81,
                               6.485595059087443e82,5.075802138772367e83,3.988640961338736e84,3.1469973260388374e85,
                               2.492900600836691e86,1.9826083154044198e87,1.582991881531248e88,
                               1.2688693218588428e89,1.021029763587701e90,8.247650592082321e90,6.687744951499225e91,
                               5.443449390774456e92,4.447350392747054e93,3.647111091818946e94,3.0019615151042864e95,
                               2.4800355424368993e96,2.0563436378463797e97,1.7112245242814685e98,
                               1.4291588283032485e99,1.1978571669969933e100,1.0075569739537903e101,
                               8.504785885678827e101,7.204032363769699e102,6.123445837688587e103,
                               5.222923463732892e104,4.470115461512898e105,3.838848745843728e106,
                               3.307885441519273e107,2.8599423156535397e108,2.480914081139533e109,
                               2.1592564483184432e110,1.8854947016660685e111,1.6518311829636027e112,
                               1.4518309202828782e113,1.2801691667968696e114,1.1324281178206039e115,
                               1.0049327959354582e116,8.946182130782364e116,7.989215727687162e117,
                               7.156945704626677e118,6.4313186607877084e119,5.797126020747554e120,
                               5.241524708541996e121,4.753643337013109e122,4.3242578845474255e123,
                               3.945523969720651e124,3.610755333596995e125,3.314240134565287e126,
                               3.0510882568895826e127,2.8171041143804693e128,2.6086804596405247e129,
                               2.4227095383671897e130,2.2565085975891645e131,2.107757298379541e132,
                               1.9744450228903197e133,1.8548264225739444e134,1.747383845257937e135,
                               1.6507955160907309e136,1.563908541505906e137,1.485715964481721e138,
                               1.4153372300629496e139,1.352001527678445e140,1.2950335655075787e141,
                               1.2438414054641828e142,1.1979060480944617e143,1.1567725070816412e144,
                               1.1200421549683488e145,1.0873661566567185e146,1.0584398364450596e147,
                               1.0329978488238504e148,1.0108100438050355e149,9.916779348709596e149,
                               9.75431692271828e150,9.619275968248377e151,9.510458999650913e152,
                               9.426890448883062e153,9.367802114655592e154,9.332621544394404e155,
                               9.320963104082245e156,9.332621544394225e157,9.367567919602772e158,
                               9.425947759837759e159,9.508081438397022e160,9.614466715035083e161,
                               9.745783474356481e162,9.90290071648575e163,1.0086885895959537e165,
                               1.0299016745144867e166,1.0540795761277733e167,1.0813967582402365e168,
                               1.112053952814804e169,1.1462805637346311e170,1.1843374597476843e171,
                               1.2265202031960951e172,1.2731627692288067e173,1.3246418194517785e174,
                               1.381381604613249e175,1.4438595832025125e176,1.512612857051622e177,
                               1.5882455415226952e178,1.6714372070419836e179,1.7629525510901396e180,
                               1.863652485851825e181,1.9745068572211572e182,2.0966090465832415e183,
                               2.2311927486598526e184,2.3796512678720198e185,2.543559733472036e186,
                               2.7247007017132962e187,2.925093693492995e188,3.1470293104792136e189,
                               3.3931086844520334e190,3.666289146707966e191,3.9699371608087175e192,
                               4.3078897473819436e193,4.684525849754326e194,5.104849350647641e195,
                               5.574585761207238e196,6.100294974023782e197,6.689502913449011e198,
                               7.350855443698236e199,8.09429852527322e200,8.931289364094251e201,
                               9.875044200832672e202,1.094082947101551e204,1.214630436702512e205,
                               1.3511924396703375e206,1.506141741511146e207,1.6822345873896565e208,
                               1.882677176888975e209,2.11120440717395e210,2.3721732428799207e211,
                               2.6706735750752748e212,3.012660018457494e213,3.405108808220738e214,
                               3.8562048236256426e215,4.375564818563824e216,4.97450422247703e217,
                               5.6663564400402e218,6.466855489220212e219,7.39459515425189e220,8.471580690878219e221,
                               9.723892627841765e222,1.118248651196143e224,1.2884157731890654e225,
                               1.487270706090812e226,1.72003505720741e227,1.9929427461617248e228,
                               2.3134471519439806e229,2.690472707318279e230,3.134720890883894e231,
                               3.6590428819524733e232,4.278894016056746e233,5.01288874827533e234,
                               5.883479272078018e235,6.917786472619215e236,8.148618791827496e237,
                               9.615723196940553e238,1.1367323214600767e240,1.3462012475718704e241,
                               1.597108911651231e242,1.8981437590762873e243,2.259909109986492e244,
                               2.6953641378880047e245,3.2203704817311862e246,3.8543707171800166e247,
                               4.621231641284257e248,5.550293832739239e249,6.677679721655397e250,
                               8.047926057472153e251,9.71602399500863e252,1.1749972043908966e254,
                               1.423397515268675e255,1.7272458904546453e256,2.09951133502152e257,
                               2.55632391787296e258,3.117774332506824e259,3.808922637630559e260]
    
    func tesGamma1() {
        var ans: Float80
        let i: Int = 0
        var reR, aeR: Float80
        var maxReR: Float80 = 0.0
        var maxAeR: Float80 = 0.0
        var minReR: Float80 = 1.0
        var minAeR: Float80 = 1.0
        let maxReI: Float80 = 0.0
        let maxAeI: Float80 = 0.0
        let minReI: Float80 = 1.0
        let minAeI: Float80 = 1.0
        for x: Float80 in stride(from: 1, through: 150, by: 0.5) {
            ans = SSMath.tgamma1(x)
            if ans.isFinite && gamma150[i].isFinite {
                reR = abs((ans - gamma150[i]) / ans)
                aeR = abs(ans - gamma150[i])
                if reR > maxReR {
                    maxReR = reR
                }
                else if reR < minReR {
                    minReR = reR
                }
                if aeR > maxAeR {
                    maxAeR = aeR
                }
                else if aeR < minAeR {
                    minAeR = aeR
                }
            }
        }
        print("Complex Gamma REAL ========================================")
        print("min. abs. Error: \(minAeR), max. abs. Error: \(maxAeR)")
        print("min. rel. Error: \(minReR), max. rel. Error: \(maxReR)")
        print("Complex Gamma IMAG ==========================================")
        print("min. abs. Error: \(minAeI), max. abs. Error: \(maxAeI)")
        print("min. rel. Error: \(minReI), max. rel. Error: \(maxReI)")
    }
    
    func pochhammer<T: SSComplexFloatElement>(a: Complex<T>, n: Int) -> Complex<T> {
        var y: Complex<T> = a;
        //        var c: Complex<T> = Complex<T>.zero
        //        var y: Complex<T>
        //        var t: Complex<T>
        if n == 0 {
            return Complex<T>.init(re: 1, im: 0)
        }
        var jf: Complex<T>
        for i in 1...n - 1 {
            jf = Complex<T>.init(re:  Helpers.makeFP(i), im: 0)
            y = y &** (a &++ jf)
        }
        return y
    }
    func lpochhammer<T: SSComplexFloatElement>(a: Complex<T>, n: Int) -> Complex<T> {
        var y: Complex<T> = SSMath.ComplexMath.log(a);
        //        var c: Complex<T> = Complex<T>.zero
        //        var y: Complex<T>
        //        var t: Complex<T>
        if n == 0 {
            return Complex<T>.init(re: 1, im: 0)
        }
        var jf: T
        for i in 1...n - 1 {
            jf =  Helpers.makeFP(i)
            y = y &++ SSMath.ComplexMath.log(a &++ jf)
        }
        return y
    }
    
}

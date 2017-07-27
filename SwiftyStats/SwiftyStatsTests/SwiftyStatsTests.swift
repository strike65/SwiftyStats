//
//  SwiftyStatsTests.swift
//  SwiftyStatsTests
//
//  Created by Volker Thieme on 17.07.17.
//  Copyright © 2017 VTSoftware. All rights reserved.
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
import XCTest
@testable import SwiftyStats

class SwiftyStatsTests: XCTestCase {
    let doubleData: Array<Double> = [18,15,18,16,17,15,14,14,14,15,15,14,15,14,22,18,21,21,10,10,11,9,28,25,19,16,17,19,18,14,14,14,14,12,13,13,18,22,19,18,23,26,25,20,21,13,14,15,14,17,11,13,12,13,15,13,13,14,22,28,13,14,13,14,15,12,13,13,14,13,12,13,18,16,18,18,23,11,12,13,12,18,21,19,21,15,16,15,11,20,21,19,15,26,25,16,16,18,16,13,14,14,14,28,19,18,15,15,16,15,16,14,17,16,15,18,21,20,13,23,20,23,18,19,25,26,18,16,16,15,22,22,24,23,29,25,20,18,19,18,27,13,17,13,13,13,30,26,18,17,16,15,18,21,19,19,16,16,16,16,25,26,31,34,36,20,19,20,19,21,20,25,21,19,21,21,19,18,19,18,18,18,30,31,23,24,22,20,22,20,21,17,18,17,18,17,16,19,19,36,27,23,24,34,35,28,29,27,34,32,28,26,24,19,28,24,27,27,26,24,30,39,35,34,30,22,27,20,18,28,27,34,31,29,27,24,23,38,36,25,38,26,22,36,27,27,32,28]
    // data with outliers
        let doubleData1: Array<Double> = [1,1,1,1,18,15,18,16,17,15,14,14,14,15,15,14,15,14,22,18,21,21,10,10,11,9,28,25,19,16,17,19,18,14,14,14,14,12,13,13,18,22,19,18,23,26,25,20,21,13,14,15,14,17,11,13,12,13,15,13,13,14,22,28,13,14,13,14,15,12,13,13,14,13,12,13,18,16,18,18,23,11,12,13,12,18,21,19,21,15,16,15,11,20,21,19,15,26,25,16,16,18,16,13,14,14,14,28,19,18,15,15,16,15,16,14,17,16,15,18,21,20,13,23,20,23,18,19,25,26,18,16,16,15,22,22,24,23,29,25,20,18,19,18,27,13,17,13,13,13,30,26,18,17,16,15,18,21,19,19,16,16,16,16,25,26,31,34,36,20,19,20,19,21,20,25,21,19,21,21,19,18,19,18,18,18,30,31,23,24,22,20,22,20,21,17,18,17,18,17,16,19,19,36,27,23,24,34,35,28,29,27,34,32,28,26,24,19,28,24,27,27,26,24,30,39,35,34,30,22,27,20,18,28,27,34,31,29,27,24,23,38,36,25,38,26,22,36,27,27,32,28,300,200,100,100,101,200,100,100,101,200,100,100,101]
    let rosnerData:Array<Double> = [-0.25,0.68,0.94,1.15,1.20,1.26,1.26,1.34,1.38,1.43,1.49,1.49,1.55,1.56,1.58,1.65,1.69,1.70,1.76,1.77,1.81,1.91,1.94,1.96,1.99,2.06,2.09,2.10,2.14,2.15,2.23,2.24,2.26,2.35,2.37,2.40,2.47,2.54,2.62,2.64,2.90,2.92,2.92,2.93,3.21,3.26,3.30,3.59,3.68,4.30,4.64,5.34,5.42,6.01]
    // data from nist sematech
    let zarrData: Array<Double> = [9.206343,9.299992,9.277895,9.305795,9.275351,9.288729,9.287239,9.260973,9.303111,9.275674,9.272561,9.288454,9.255672,9.252141,9.297670,9.266534,9.256689,9.277542,9.248205,9.252107,9.276345,9.278694,9.267144,9.246132,9.238479,9.269058,9.248239,9.257439,9.268481,9.288454,9.258452,9.286130,9.251479,9.257405,9.268343,9.291302,9.219460,9.270386,9.218808,9.241185,9.269989,9.226585,9.258556,9.286184,9.320067,9.327973,9.262963,9.248181,9.238644,9.225073,9.220878,9.271318,9.252072,9.281186,9.270624,9.294771,9.301821,9.278849,9.236680,9.233988,9.244687,9.221601,9.207325,9.258776,9.275708,9.268955,9.257269,9.264979,9.295500,9.292883,9.264188,9.280731,9.267336,9.300566,9.253089,9.261376,9.238409,9.225073,9.235526,9.239510,9.264487,9.244242,9.277542,9.310506,9.261594,9.259791,9.253089,9.245735,9.284058,9.251122,9.275385,9.254619,9.279526,9.275065,9.261952,9.275351,9.252433,9.230263,9.255150,9.268780,9.290389,9.274161,9.255707,9.261663,9.250455,9.261952,9.264041,9.264509,9.242114,9.239674,9.221553,9.241935,9.215265,9.285930,9.271559,9.266046,9.285299,9.268989,9.267987,9.246166,9.231304,9.240768,9.260506,9.274355,9.292376,9.271170,9.267018,9.308838,9.264153,9.278822,9.255244,9.229221,9.253158,9.256292,9.262602,9.219793,9.258452,9.267987,9.267987,9.248903,9.235153,9.242933,9.253453,9.262671,9.242536,9.260803,9.259825,9.253123,9.240803,9.238712,9.263676,9.243002,9.246826,9.252107,9.261663,9.247311,9.306055,9.237646,9.248937,9.256689,9.265777,9.299047,9.244814,9.287205,9.300566,9.256621,9.271318,9.275154,9.281834,9.253158,9.269024,9.282077,9.277507,9.284910,9.239840,9.268344,9.247778,9.225039,9.230750,9.270024,9.265095,9.284308,9.280697,9.263032,9.291851,9.252072,9.244031,9.283269,9.196848,9.231372,9.232963,9.234956,9.216746,9.274107,9.273776]
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testFrequencies() {
        let characters = ["A", "A", "A", "B", "B", "B","C","C","C"]
        let c:SSExamine<String> = try! SSExamine<String>.init(withObject: characters, levelOfMeasurement: .nominal, characterSet: nil)
        XCTAssertEqual(1.0 / 3.0, c.relativeFrequency(item: "A"))
        XCTAssertEqual(1.0 / 3.0, c.relativeFrequency(item: "B"))
        XCTAssertEqual(1.0 / 3.0, c.relativeFrequency(item: "C"))
        XCTAssertEqual(0, c.relativeFrequency(item: "!"))
        XCTAssertEqual(1.0 / 3.0, c.empiricalCDF(of: "A"))
        XCTAssertEqual(2.0 / 3.0, c.empiricalCDF(of: "B"))
        XCTAssertEqual(3.0 / 3.0, c.empiricalCDF(of: "C"))
    }
    
    func testTTest()  {
        // normally distributed data mean = 0, sd = 1.0
        let normal1 = [-1.39472,0.572422,-0.807981,1.12284,0.582314,-2.02361,-1.07106,-1.07723,0.105198,-0.806512,-1.47555,0.117081,-0.40699,-0.554643,-0.0838551,-2.38265,-0.748096,1.13259,0.134903,-1.11957,-0.268167,-0.249893,-0.636138,0.411145,1.40698,0.868583,0.221741,-0.751367,-0.843731,-1.92446,-0.770097,1.34406,0.113856,0.442025,0.206676,0.448239,0.701375,-1.50239,0.118701,0.992643,0.119639,-0.0365253,0.205961,-0.37079,-0.224489,-0.428072,0.911177,-0.279192,0.560748,-0.24796,-1.05229,2.03458,-2.02889,-1.08878,-0.826172,0.381449,-0.134957,-0.07598,-1.03606,1.65422,-0.290542,0.221982,0.0674381,-0.32888,1.59649,0.418209,-0.899435,0.329175,-0.177973,1.62596,0.599629,-1.5299,-2.18709,0.297174,0.997437,1.55026,0.857938,0.177222,1.62641,-0.982871,0.307966,-0.518949,2.34573,-0.17761,2.3379,0.598934,-0.727655,0.320675,1.5864,0.0940648,0.350143,-0.617015,0.839371,0.224846,0.0201539,-1.49075,0.847894,-0.790432,1.80993,1.32279,0.141171,-1.14471,0.601558,0.678619,-0.45809,0.312201,1.3017,0.0407581,0.993514,0.931535,1.13858]
        // normally distributed data mean = 0, sd = 6.0
        let normal2 = [-1.97868,-0.427976,-2.66975,0.176478,2.25474,2.40507,-0.761118,-1.23613,0.176328,0.246937,-0.748346,0.225074,2.12719,1.86908,-1.21862,0.167204,-0.212893,0.378512,-0.924507,-1.95599,0.939617,0.0456999,0.113515,1.16326,-3.19567,-0.0980512,0.112013,-1.2179,-2.11017,0.248698,-0.696075,2.17557,1.56604,-0.379878,0.0226318,1.05484,0.355952,-1.84079,1.86957,0.340198,1.63338,-0.0842764,-0.4389,-0.0731516,-1.52269,0.410057,-1.09899,1.79384,0.834195,-1.54511,-1.10209,0.667836,0.289231,0.811264,0.63324,-0.270103,-0.434363,-0.475097,1.61421,3.88214,-1.75994,0.669145,-1.62642,-0.5134,2.11818,-0.210695,-0.415295,1.31951,2.10836,-1.7428,-0.392325,-0.826717,-0.504155,-2.68384,-0.307938,0.243413,0.596948,-3.6242,1.17498,-0.52255,1.3824,-1.19024,2.56617,1.68061,-1.18291,-0.535121,-1.88233,-0.554142,-0.870762,0.73745,-0.737186,1.13752,-1.35994,-0.560269,0.619597,-0.588878,-0.660138,0.17239,2.23929,-0.642425,-2.40169,-1.02126,0.607818,-0.503528,1.04194,-2.77603,-2.34118,-0.0410913,0.524286,0.602759,-1.17653]
        // normally distributed data mean = 2, sd = 1.5
        let normal3 = [1.36006,-0.246289,1.43112,0.811084,1.2796,1.25608,3.68661,1.86247,1.51717,1.77718,6.45058,0.831263,2.51442,2.79311,3.34225,1.64312,-1.3939,1.1648,3.28153,0.830627,2.94934,3.8969,0.762779,2.72686,6.35514,3.23959,1.94143,1.7125,5.14749,0.0266368,2.35417,1.40718,2.29764,0.873589,3.03813,3.28821,2.35882,2.62306,3.68845,3.98375,2.68762,3.4678,1.61238,1.36748,1.41429,0.858909,3.5106,1.63765,4.11641,-0.675375,1.8475,-0.595252,1.98112,0.358589,2.01333,3.26077,2.31679,5.3696,3.04103,-1.3282,4.05513,1.58629,1.77726,1.7793,-0.0743819,4.99872,2.4563,-0.0183636,3.86533,2.69593,0.459153,2.56991,2.81289,3.39954,1.66538,2.40858,-0.559767,1.64667,0.706113,1.82405,-0.510256,0.773982,2.13633,1.05356,5.27519,-0.628657,0.604019,0.404042,0.410413,1.23801,1.25667,2.04208,4.0242,4.03866,0.306506,2.19311,2.88265,2.42201,4.6352,3.31063,3.10571,1.16181,1.83808,0.309436,1.77448,3.02173,1.81139,1.68856,4.96991,0.307478,1.40293]
        let examine1 = SSExamine<Double>.init(withArray: normal1, characterSet: nil)
        let examine2 = SSExamine<Double>.init(withArray: normal2, characterSet: nil)
        let examine3 = SSExamine<Double>.init(withArray: normal3, characterSet: nil)
        var ttestResult = try! SSHypothesisTesting.twoSampleTTest(sample1: examine1, sample2: examine2, alpha: 0.05)
        XCTAssertEqualWithAccuracy(ttestResult.p2Welch!, 0.366334, accuracy: 1E-6)
        ttestResult = try! SSHypothesisTesting.twoSampleTTest(sample1:examine1 , sample2: examine3, alpha: 0.05)
        XCTAssertTrue(ttestResult.p2Welch!.isZero)
        ttestResult = try! SSHypothesisTesting.twoSampleTTest(sample1:examine2 , sample2: examine3, alpha: 0.05)
        XCTAssertTrue(ttestResult.p2Welch!.isZero)
    }
    
    func testEqualityOfVariance() {
        // normally distributed data mean = 0, sd = 1.0
        let normal1 = [-1.39472,0.572422,-0.807981,1.12284,0.582314,-2.02361,-1.07106,-1.07723,0.105198,-0.806512,-1.47555,0.117081,-0.40699,-0.554643,-0.0838551,-2.38265,-0.748096,1.13259,0.134903,-1.11957,-0.268167,-0.249893,-0.636138,0.411145,1.40698,0.868583,0.221741,-0.751367,-0.843731,-1.92446,-0.770097,1.34406,0.113856,0.442025,0.206676,0.448239,0.701375,-1.50239,0.118701,0.992643,0.119639,-0.0365253,0.205961,-0.37079,-0.224489,-0.428072,0.911177,-0.279192,0.560748,-0.24796,-1.05229,2.03458,-2.02889,-1.08878,-0.826172,0.381449,-0.134957,-0.07598,-1.03606,1.65422,-0.290542,0.221982,0.0674381,-0.32888,1.59649,0.418209,-0.899435,0.329175,-0.177973,1.62596,0.599629,-1.5299,-2.18709,0.297174,0.997437,1.55026,0.857938,0.177222,1.62641,-0.982871,0.307966,-0.518949,2.34573,-0.17761,2.3379,0.598934,-0.727655,0.320675,1.5864,0.0940648,0.350143,-0.617015,0.839371,0.224846,0.0201539,-1.49075,0.847894,-0.790432,1.80993,1.32279,0.141171,-1.14471,0.601558,0.678619,-0.45809,0.312201,1.3017,0.0407581,0.993514,0.931535,1.13858]
        // normally distributed data mean = 0, sd = 6.0
        let normal2 = [-1.97868,-0.427976,-2.66975,0.176478,2.25474,2.40507,-0.761118,-1.23613,0.176328,0.246937,-0.748346,0.225074,2.12719,1.86908,-1.21862,0.167204,-0.212893,0.378512,-0.924507,-1.95599,0.939617,0.0456999,0.113515,1.16326,-3.19567,-0.0980512,0.112013,-1.2179,-2.11017,0.248698,-0.696075,2.17557,1.56604,-0.379878,0.0226318,1.05484,0.355952,-1.84079,1.86957,0.340198,1.63338,-0.0842764,-0.4389,-0.0731516,-1.52269,0.410057,-1.09899,1.79384,0.834195,-1.54511,-1.10209,0.667836,0.289231,0.811264,0.63324,-0.270103,-0.434363,-0.475097,1.61421,3.88214,-1.75994,0.669145,-1.62642,-0.5134,2.11818,-0.210695,-0.415295,1.31951,2.10836,-1.7428,-0.392325,-0.826717,-0.504155,-2.68384,-0.307938,0.243413,0.596948,-3.6242,1.17498,-0.52255,1.3824,-1.19024,2.56617,1.68061,-1.18291,-0.535121,-1.88233,-0.554142,-0.870762,0.73745,-0.737186,1.13752,-1.35994,-0.560269,0.619597,-0.588878,-0.660138,0.17239,2.23929,-0.642425,-2.40169,-1.02126,0.607818,-0.503528,1.04194,-2.77603,-2.34118,-0.0410913,0.524286,0.602759,-1.17653]
        // normally distributed data mean = 2, sd = 1.5
        let normal3 = [1.36006,-0.246289,1.43112,0.811084,1.2796,1.25608,3.68661,1.86247,1.51717,1.77718,6.45058,0.831263,2.51442,2.79311,3.34225,1.64312,-1.3939,1.1648,3.28153,0.830627,2.94934,3.8969,0.762779,2.72686,6.35514,3.23959,1.94143,1.7125,5.14749,0.0266368,2.35417,1.40718,2.29764,0.873589,3.03813,3.28821,2.35882,2.62306,3.68845,3.98375,2.68762,3.4678,1.61238,1.36748,1.41429,0.858909,3.5106,1.63765,4.11641,-0.675375,1.8475,-0.595252,1.98112,0.358589,2.01333,3.26077,2.31679,5.3696,3.04103,-1.3282,4.05513,1.58629,1.77726,1.7793,-0.0743819,4.99872,2.4563,-0.0183636,3.86533,2.69593,0.459153,2.56991,2.81289,3.39954,1.66538,2.40858,-0.559767,1.64667,0.706113,1.82405,-0.510256,0.773982,2.13633,1.05356,5.27519,-0.628657,0.604019,0.404042,0.410413,1.23801,1.25667,2.04208,4.0242,4.03866,0.306506,2.19311,2.88265,2.42201,4.6352,3.31063,3.10571,1.16181,1.83808,0.309436,1.77448,3.02173,1.81139,1.68856,4.96991,0.307478,1.40293]
        // with two arrays
        var varianceTestResult = try! SSHypothesisTesting.bartlettTest(data: [normal1, normal2], alpha: 0.05)!
        XCTAssertEqualWithAccuracy(varianceTestResult.pValue!, 0.00103845, accuracy: 1E-8)
        XCTAssertEqualWithAccuracy(varianceTestResult.testStatistic!, 10.7577, accuracy: 1E-4)
        // with three arrays
        varianceTestResult = try! SSHypothesisTesting.bartlettTest(data: [normal1, normal2, normal3], alpha: 0.05)!
        XCTAssertEqualWithAccuracy(varianceTestResult.pValue!, 0.0000156135, accuracy: 1E-10)
        XCTAssertEqualWithAccuracy(varianceTestResult.testStatistic!, 22.1347, accuracy: 1E-4)
        XCTAssertThrowsError(try SSHypothesisTesting.bartlettTest(data: [normal1], alpha: 0.05))
        varianceTestResult = try! SSHypothesisTesting.leveneTest(data: [normal1, normal2, normal3], testType: .median, alpha: 0.05)!
        XCTAssertEqualWithAccuracy(varianceTestResult.pValue!, 0.000490846, accuracy: 1E-9)
        varianceTestResult = try! SSHypothesisTesting.leveneTest(data: [normal1, normal2, normal3], testType: .mean, alpha: 0.05)!
        XCTAssertEqualWithAccuracy(varianceTestResult.pValue!, 0.000261212, accuracy: 1E-9)
        varianceTestResult = try! SSHypothesisTesting.leveneTest(data: [normal1, normal2, normal3], testType: .trimmedMean, alpha: 0.05)!
        XCTAssertEqualWithAccuracy(varianceTestResult.pValue!, 0.0003168469, accuracy: 1E-9)
    }
    
    func testKStest() {
        let normalData = [-0.547153,0.603349,0.0356913,0.371719,1.19563,-0.233729,-1.54745,-0.766288,-2.37127,-0.350955,-0.960762,-0.120141,-0.552313,-0.379464,0.233542,-0.0947998,2.26638,-0.117421,-0.428023,-0.0166867,1.02544,-0.886345,-0.555611,0.140396,0.264058,0.853666,-1.18988,-0.37095,-0.610685,-0.981675,0.714931,-0.029498,0.96298,-0.661278,0.737129,-0.342571,-0.190051,0.401794,0.386381,-0.422238,-1.09017,-1.101,0.765093,0.418662,-1.17782,0.532863,-1.35519,0.375049,0.105548,0.915736,0.119611,-1.00924,0.366805,-0.62722,0.51112,-0.647071,0.313495,-0.32859,-0.213161,-0.300696,-0.159295,0.571648,-1.85234,0.707033,-0.988096,0.545321,-0.283816,-0.502553,0.869898,-0.705467,1.86352,0.613512,-1.52042,2.807,1.54076,-0.7846,-0.489792,-1.31299,1.655,0.373027,0.379805,0.930562,-0.691871,-0.924249,-0.35578,-1.61662,1.83717,1.08207,1.78185,1.88403,-0.0805336,0.689903,-0.254391,0.0480327,1.97955,-1.21251,0.855274,-0.00948941,0.391186,-1.67967,-0.415094,0.916899,-1.61615,0.491064,0.764465,0.307897,0.764307,-0.135405,0.746823,0.179762,-0.673204,-0.964759,0.45124,0.48424,-1.34306,-1.24151,-0.322674,-0.0128122,-0.015076,-1.30808,1.25418,1.38792,0.682854,-1.28639,-0.956995,0.376591,-1.51564,-0.660866,1.35358,-0.0687147,2.90507,-0.255587,0.687841,1.20782,-0.280149,0.489096,1.33212,-1.35876,1.29549,-0.825661,-1.2907,-0.291063,-0.0685604,-1.08009,0.698847,-0.452389,-0.326694,-1.73331,0.291873,0.28719]
        let laplaceData = [-2.03679,0.518416,-1.72556,3.07248,1.58415,0.55357,1.13785,2.77352,0.692562,-0.246844,1.07308,0.676815,2.61719,0.839612,0.657608,1.60029,0.934251,1.64299,4.83994,-0.572193,0.590732,-2.30579,-3.46328,4.6823,2.65601,1.66736,0.0644071,0.561031,2.19092,1.10959,0.952764,4.28232,0.360738,3.43897,-0.122254,-3.22326,7.96229,-5.32675,1.4503,-2.94508,1.36242,1.0414,0.421444,3.61022,1.26506,-3.94449,-0.544188,2.88665,2.00745,-3.01688,1.0722,-0.327354,1.46366,1.52667,3.71474,1.24921,2.36462,2.111,-0.704057,6.7197,7.54793,2.76588,0.470362,0.467676,1.16809,2.11906,-3.79051,2.17474,4.64406,-1.69926,0.967686,-3.22085,1.72475,1.17087,1.03924,0.230923,1.4176,0.897564,-6.89486,-5.64721,1.07495,1.78927,8.24184,5.95395,0.793648,1.89169,1.25558,4.3064,-1.33544,5.67814,-6.36738,-0.372883,0.13142,0.786708,-0.0932199,-4.06743,4.07498,-0.482598,-1.49333,1.61442,-2.27068,1.55111,-2.59695,4.47164,-0.776884,0.884446,3.70967,0.858531,3.33213,-7.62385,0.0583429,-0.148588,-1.24765,8.67548,0.860613,1.36125,-9.48455,-0.831406,-1.86396,2.10917,4.551,1.064,1.97283,3.82057,2.29935,-1.74418,0.244115,-0.837016,2.53457,1.61,1.54181,-1.54528,-0.943004,-0.738644,-0.680302,0.358243,5.85945,0.920141,0.645741,0.675258,0.833122,0.0261111,0.593711,1.10065,0.956418,-0.194063,3.37702,-1.40828,0.853448,-1.26089]
        let normal = try! SSExamine<Double>.init(withObject: normalData, levelOfMeasurement: .interval, characterSet: nil)
        normal.name = "Normal Distribution"
        let laplace = try! SSExamine<Double>.init(withObject: laplaceData, levelOfMeasurement: .interval, characterSet: nil)
        laplace.name = "Laplace Distribution"
        var res: SSKSTestResult = try! SSHypothesisTesting.ksGoFTest(data: normal.elementsAsArray(sortOrder: .original)!, targetDistribution: .gaussian)!
        XCTAssertEqualWithAccuracy(res.pValue!, 0.955126, accuracy: 1E-5)
        res = try! SSHypothesisTesting.ksGoFTest(data: normal.elementsAsArray(sortOrder: .original)!, targetDistribution: .laplace)!
        XCTAssertEqualWithAccuracy(res.pValue!, 0.0118438, accuracy: 1E-5)
        res = try! SSHypothesisTesting.ksGoFTest(data: laplace.elementsAsArray(sortOrder: .original)!, targetDistribution: .gaussian)!
        XCTAssertEqualWithAccuracy(res.pValue!, 0.0948321, accuracy: 1E-5)
        res = try! SSHypothesisTesting.ksGoFTest(data: laplace.elementsAsArray(sortOrder: .original)!, targetDistribution: .laplace)!
        XCTAssertEqualWithAccuracy(res.pValue!, 0.0771619, accuracy: 1E-5)
        var adRes = try! SSHypothesisTesting.adNormalityTest(data: normalData, alpha: 0.05)!
        XCTAssertEqualWithAccuracy(adRes.pValue!, 0.93, accuracy: 1E-2)
        adRes = try! SSHypothesisTesting.adNormalityTest(data: laplaceData, alpha: 0.05)!
        XCTAssertEqualWithAccuracy(adRes.pValue!, 0.04, accuracy: 1E-2)
        XCTAssertEqualWithAccuracy(try! SSProbabilityDistributions.pdfChiSquareDist(chi: 22, degreesOfFreedom: 20), 0.0542627546491024962784, accuracy: 1E-12)
        XCTAssertEqualWithAccuracy(try! SSProbabilityDistributions.cdfChiSquareDist(chi: 22, degreesOfFreedom: 20), 0.659489357534338952719, accuracy: 1E-12)
        XCTAssertEqualWithAccuracy(try! SSProbabilityDistributions.quantileChiSquareDist(p: 0.5, degreesOfFreedom: 20), 19.3374292294282623035, accuracy: 1E-12)
    }
    
    func testDescriptive() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let double1 = SSExamine<Double>(withArray: doubleData, characterSet: nil)
        do {
            // tests correctness of archiving
            let tempDir = NSTemporaryDirectory()
            let filename = NSUUID().uuidString
            let url = NSURL.fileURL(withPathComponents: [tempDir, filename])
            let _ = try double1.archiveTo(filePath: url?.path , overwrite: true)
            var saved = try SSExamine<Double>.unarchiveFrom(filePath: url?.path)
            XCTAssert(double1.isEqual(saved))
            try FileManager.default.removeItem(at: url!)
            saved = double1.copy() as? SSExamine<Double>
            XCTAssert(double1.isEqual(saved))
            XCTAssert(double1.contains(item: 38))
            XCTAssert(!double1.contains(item: -1))
            XCTAssertEqual(double1.frequency(item: 27), 10)
            XCTAssertEqual(double1.relativeFrequency(item: 27), 10.0 / Double(double1.sampleSize))
            
            // elements as string
            XCTAssertEqual(double1.elementsAsString(withDelimiter: "*"), "18.0*15.0*18.0*16.0*17.0*15.0*14.0*14.0*14.0*15.0*15.0*14.0*15.0*14.0*22.0*18.0*21.0*21.0*10.0*10.0*11.0*9.0*28.0*25.0*19.0*16.0*17.0*19.0*18.0*14.0*14.0*14.0*14.0*12.0*13.0*13.0*18.0*22.0*19.0*18.0*23.0*26.0*25.0*20.0*21.0*13.0*14.0*15.0*14.0*17.0*11.0*13.0*12.0*13.0*15.0*13.0*13.0*14.0*22.0*28.0*13.0*14.0*13.0*14.0*15.0*12.0*13.0*13.0*14.0*13.0*12.0*13.0*18.0*16.0*18.0*18.0*23.0*11.0*12.0*13.0*12.0*18.0*21.0*19.0*21.0*15.0*16.0*15.0*11.0*20.0*21.0*19.0*15.0*26.0*25.0*16.0*16.0*18.0*16.0*13.0*14.0*14.0*14.0*28.0*19.0*18.0*15.0*15.0*16.0*15.0*16.0*14.0*17.0*16.0*15.0*18.0*21.0*20.0*13.0*23.0*20.0*23.0*18.0*19.0*25.0*26.0*18.0*16.0*16.0*15.0*22.0*22.0*24.0*23.0*29.0*25.0*20.0*18.0*19.0*18.0*27.0*13.0*17.0*13.0*13.0*13.0*30.0*26.0*18.0*17.0*16.0*15.0*18.0*21.0*19.0*19.0*16.0*16.0*16.0*16.0*25.0*26.0*31.0*34.0*36.0*20.0*19.0*20.0*19.0*21.0*20.0*25.0*21.0*19.0*21.0*21.0*19.0*18.0*19.0*18.0*18.0*18.0*30.0*31.0*23.0*24.0*22.0*20.0*22.0*20.0*21.0*17.0*18.0*17.0*18.0*17.0*16.0*19.0*19.0*36.0*27.0*23.0*24.0*34.0*35.0*28.0*29.0*27.0*34.0*32.0*28.0*26.0*24.0*19.0*28.0*24.0*27.0*27.0*26.0*24.0*30.0*39.0*35.0*34.0*30.0*22.0*27.0*20.0*18.0*28.0*27.0*34.0*31.0*29.0*27.0*24.0*23.0*38.0*36.0*25.0*38.0*26.0*22.0*36.0*27.0*27.0*32.0*28.0")
            // Descriptives
            XCTAssertEqual(double1.total, 4985)
            XCTAssertEqualWithAccuracy(double1.inverseTotal, 13.540959278542406, accuracy: 1.0E-14)
            XCTAssert(double1.squareTotal == 110289)
            
            XCTAssert(double1.quartile!.q25 == 15)
            XCTAssert(double1.quartile!.q50 == 19)
            XCTAssert(double1.quartile!.q75 == 24)
            XCTAssertEqual(double1.median, 19)
            XCTAssert(try double1.quantile(q: 0.1) == 13)
            XCTAssertThrowsError(try double1.quantile(q: 1.5))
            
            XCTAssert(double1.arithmeticMean == 20.100806451612904)
            XCTAssert(double1.harmonicMean == 18.314802880545665)
            XCTAssertEqual(double1.geometricMean, 19.168086630042282)
            XCTAssertEqualWithAccuracy(double1.contraHarmonicMean!, 22.124172517552658, accuracy: 1E-14)

            XCTAssertEqualWithAccuracy(double1.poweredTotal(power: 6), 59385072309, accuracy: 1E-14)
            XCTAssertEqualWithAccuracy(double1.poweredMean(order: 6)!, 24.919401155182530, accuracy: 1E-10)
            XCTAssertEqual(try double1.trimmedMean(alpha: 0.05), 19.736607142857143)
            XCTAssertEqual(try double1.trimmedMean(alpha: 0.4), 18.72)
            XCTAssertEqualWithAccuracy(try double1.winsorizedMean(alpha: 0.05)!, 20.052419354838708, accuracy: 1E-14)
            XCTAssertEqualWithAccuracy(try double1.winsorizedMean(alpha: 0.45)!, 18.508064516129032, accuracy: 1E-14)
            XCTAssertThrowsError(try double1.winsorizedMean(alpha: 0.6))
            XCTAssertThrowsError(try double1.winsorizedMean(alpha: 0.0))
            XCTAssertEqual(double1.poweredMean(order: 3), 22.095732180912705)
            XCTAssertEqual(double1.product, Double.infinity)
            XCTAssertEqual(double1.logProduct, 732.40519187630610)
            XCTAssertEqual(double1.maximum, 39)
            XCTAssertEqual(double1.minimum, 9)
            XCTAssertEqual(double1.range, 30)
            XCTAssertEqualWithAccuracy(double1.cv!, 0.317912682758119939795, accuracy: 1E-15)
            
            XCTAssertEqualWithAccuracy(double1.semiVariance(type: .lower)!, 24.742644316247567, accuracy: 1E-12)
            XCTAssertEqualWithAccuracy(double1.semiVariance(type: .upper)!, 65.467428319137056, accuracy: 1E-12)
            
            XCTAssertEqualWithAccuracy(double1.empiricalCDF(of: 23), 0.72983870967741935, accuracy: 1E-14)
            XCTAssertEqualWithAccuracy(double1.empiricalCDF(of: 9), 0.0040322580645161290, accuracy: 1E-14)
            XCTAssertEqualWithAccuracy(double1.empiricalCDF(of: 39), 1.0, accuracy: 1E-14)
            XCTAssertEqual(double1.empiricalCDF(of: -39), 0.0)
            XCTAssertEqual(double1.empiricalCDF(of: 2000), 1.0)
            XCTAssertEqual(double1.moment(r: 0, type: .central)!, 1.0)
            XCTAssertEqualWithAccuracy(double1.moment(r: 1, type: .central)!, 0, accuracy: 1E-14)
            XCTAssertEqualWithAccuracy(double1.moment(r: 2, type: .central)!, 40.671289672216441, accuracy: 1E-14)
            XCTAssertEqualWithAccuracy(double1.moment(r: 3, type: .central)!, 213.45322268575241, accuracy: 1E-12)
            XCTAssertEqualWithAccuracy(double1.moment(r: 4, type: .central)!, 5113.3413825102367, accuracy: 1E-12)
            XCTAssertEqualWithAccuracy(double1.moment(r: 5, type: .central)!, 59456.550944779016, accuracy: 1E-10)
            XCTAssertEqualWithAccuracy(double1.moment(r: 3, type: .origin)!, 10787.608870967742, accuracy: 1E-10)
            XCTAssertEqualWithAccuracy(double1.moment(r: 5, type: .origin)!, 8020422.4798387097, accuracy: 1E-10)
            XCTAssertEqualWithAccuracy(double1.standardDeviation(type: .unbiased)!, 6.3903013046339835, accuracy: 1E-14)
            
            XCTAssertEqualWithAccuracy(double1.kurtosisExcess!, 0.0912127828607771, accuracy: 1E-14)
            XCTAssertEqualWithAccuracy(double1.kurtosis!, 3.0912127828607771, accuracy: 1E-14)
            XCTAssertEqualWithAccuracy(double1.skewness!, 0.82294497966005010, accuracy: 1E-14)
            
            XCTAssertEqualWithAccuracy(try! SSProbabilityDistributions.pdfStudentTDist(t: 3, degreesOfFreedom: 23), 0.0075011050894842518, accuracy: 1E-14)
            XCTAssertEqualWithAccuracy(try! SSProbabilityDistributions.cdfStudentTDist(t: -5, degreesOfFreedom: 23), 0.000023321665771033846, accuracy: 1E-14)
            XCTAssertEqualWithAccuracy(try! SSProbabilityDistributions.cdfStudentTDist(t: 5, degreesOfFreedom: 23), 0.99997667833422897, accuracy: 1E-14)
            XCTAssertEqualWithAccuracy(try! SSProbabilityDistributions.cdfStudentTDist(t: 0, degreesOfFreedom: 23), 0.5, accuracy: 1E-14)
            XCTAssertEqual(try! SSProbabilityDistributions.quantileStudentTDist(p: 0, degreesOfFreedom: 23), -Double.infinity)
            XCTAssertEqual(try! SSProbabilityDistributions.quantileStudentTDist(p: 1, degreesOfFreedom: 23), Double.infinity)
            XCTAssertEqualWithAccuracy(try! SSProbabilityDistributions.quantileStudentTDist(p: 0.05, degreesOfFreedom: 23), -1.7138715277470481, accuracy: 1E-14)
            if let s = double1.standardDeviation(type: .unbiased) {
                let m = double1.arithmeticMean
                do {
                    try XCTAssertEqualWithAccuracy(SSProbabilityDistributions.pdfNormalDist(x: 2, mean: m, standardDeviation: s), 0.0011301879810605873, accuracy: 1E-14)
                    try XCTAssertEqualWithAccuracy(SSProbabilityDistributions.pdfNormalDist(x: 33, mean: m, standardDeviation: s), 0.0081396502508653989, accuracy: 1E-14)
                    try XCTAssertEqualWithAccuracy(SSProbabilityDistributions.cdfNormalDist(x: 33, mean: m, standardDeviation: s), 0.97823340773523892, accuracy: 1E-14)
                    try XCTAssertEqualWithAccuracy(SSProbabilityDistributions.cdfNormalDist(x: 5, mean: m, standardDeviation: s), 0.0090618277136769177, accuracy: 1E-14)
                    try XCTAssertEqualWithAccuracy(SSProbabilityDistributions.quantileNormalDist(p: 0.5, mean: m, standardDeviation: s), 20.100806451612903, accuracy: 1E-14)
                    try XCTAssertEqualWithAccuracy(SSProbabilityDistributions.quantileNormalDist(p: 0.975, mean: m, standardDeviation: s), 32.625566859054832, accuracy: 1E-14)
                }
                do {
                    let zarr = try SSExamine<Double>.init(withObject: zarrData, levelOfMeasurement: .interval, characterSet: nil)
                    if let ci = zarr.studentTCI(alpha: 0.95) {
                        // CI computed using R
                        XCTAssertEqualWithAccuracy(ci.lowerBound, 9.258242, accuracy: 1E-5)
                        XCTAssertEqualWithAccuracy(ci.upperBound, 9.264679, accuracy: 1E-5)
                    }
                    if let ci = zarr.normalCI(alpha: 0.95, populationSD: zarr.standardDeviation(type: .unbiased)!) {
                        // CI computed using R
                        XCTAssertEqualWithAccuracy(ci.lowerBound, 9.258262, accuracy: 1E-5)
                        XCTAssertEqualWithAccuracy(ci.upperBound, 9.264659, accuracy: 1E-5)
                    }
                    if let ci = double1.studentTCI(alpha: 0.95) {
                        // CI computed using R
                        XCTAssertEqualWithAccuracy(ci.lowerBound, 19.30157, accuracy: 1E-5)
                        XCTAssertEqualWithAccuracy(ci.upperBound, 20.90005, accuracy: 1E-5)
                    }
                    if let ci = double1.normalCI(alpha: 0.95, populationSD: double1.standardDeviation(type: .unbiased)!) {
                        // CI computed using R
                        XCTAssertEqualWithAccuracy(ci.lowerBound, 19.30548, accuracy: 1E-5)
                        XCTAssertEqualWithAccuracy(ci.upperBound, 20.89613, accuracy: 1E-5)
                    }
                }
            }
            XCTAssertEqual(double1.meanDifference!, 7.079110617735406)
            XCTAssertEqual(double1.semiVariance(type: .lower), 24.742644316247556)
            XCTAssertEqual(double1.semiVariance(type: .upper), 65.467428319137056)
            XCTAssert(!double1.hasOutliers(testType: .grubbs)!)
            let double2 = try SSExamine<Double>.init(withObject: rosnerData, levelOfMeasurement: .interval, characterSet: nil)
            XCTAssert(!double2.hasOutliers(testType: .grubbs)!)
            let esd: SSESDTestResult = SSHypothesisTesting.esdOutlierTest(data: double2.elementsAsArray(sortOrder: .original)!, alpha: 0.05, maxOutliers: 10, testType: .bothTails)!
            XCTAssert(esd.countOfOutliers == 3)
            let double3 = try SSExamine<Double>.init(withObject: doubleData1, levelOfMeasurement: .interval, characterSet: nil)
            XCTAssert(double3.hasOutliers(testType: .grubbs)!)
            XCTAssert(!double2.hasOutliers(testType: .grubbs)!)
            XCTAssert(double3.hasOutliers(testType: .esd)!)
            XCTAssert(double2.outliers(alpha: 0.05, max: 10, testType: .bothTails)!.elementsEqual([6.01,5.42,5.34]))
            var cv: Bool = false
            // values computed using Mathematica
            XCTAssert(gammaNormalizedQ(x: 3, a: 2, converged: &cv) == 0.19914827347145577)
            XCTAssert(gammaNormalizedQ(x: 3, a: 3, converged: &cv) == 0.42319008112684353)
            XCTAssertEqualWithAccuracy(gammaNormalizedQ(x: 3, a: 0.3, converged: &cv), 0.0064903726990984344, accuracy: 1E-12)
            XCTAssertEqualWithAccuracy(gammaNormalizedQ(x: 0.4, a: 0.3, converged: &cv), 0.22361941898336419, accuracy: 1E-12)
            XCTAssert(gammaNormalizedP(x: 3, a: 2, converged: &cv) == 0.80085172652854423)
            XCTAssert(gammaNormalizedP(x: 3, a: 3, converged: &cv) == 0.57680991887315648)
            XCTAssertEqualWithAccuracy(gammaNormalizedP(x: 3, a: 0.3, converged: &cv), 0.99350962730090157, accuracy: 1E-12)
            XCTAssertEqualWithAccuracy(gammaNormalizedP(x: 0.4, a: 0.3, converged: &cv), 0.77638058101663581, accuracy: 1E-12)
        }
        catch {
            
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

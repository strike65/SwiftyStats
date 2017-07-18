//
//  SwiftyStatsTests.swift
//  SwiftyStatsTests
//
//  Created by Volker Thieme on 17.07.17.
//  Copyright © 2017 VTSoftware. All rights reserved.
//

import XCTest
@testable import SwiftyStats

class SwiftyStatsTests: XCTestCase {
    let doubleData: Array<Double> = [18,15,18,16,17,15,14,14,14,15,15,14,15,14,22,18,21,21,10,10,11,9,28,25,19,16,
                                     17,19,18,14,14,14,14,12,13,13,18,22,19,18,23,26,25,20,21,13,14,15,14,17,11,13,
                                     12,13,15,13,13,14,22,28,13,14,13,14,15,12,13,13,14,13,12,13,18,16,18,18,23,11,
                                     12,13,12,18,21,19,21,15,16,15,11,20,21,19,15,26,25,16,16,18,16,13,14,14,14,28,
                                     19,18,15,15,16,15,16,14,17,16,15,18,21,20,13,23,20,23,18,19,25,26,18,16,16,15,
                                     22,22,24,23,29,25,20,18,19,18,27,13,17,13,13,13,30,26,18,17,16,15,18,21,19,19,
                                     16,16,16,16,25,26,31,34,36,20,19,20,19,21,20,25,21,19,21,21,19,18,19,18,18,18,
                                     30,31,23,24,22,20,22,20,21,17,18,17,18,17,16,19,19,36,27,23,24,34,35,28,29,27,
                                     34,32,28,26,24,19,28,24,27,27,26,24,30,39,35,34,30,22,27,20,18,28,27,34,31,29,
                                     27,24,23,38,36,25,38,26,22,36,27,27,32,28]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let double1 = SSExamine<Double>(withArray: doubleData, characterSet: nil)
        do {
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
            XCTAssertEqual(double1.elementsAsString(withDelimiter: "*"), "18.0*15.0*18.0*16.0*17.0*15.0*14.0*14.0*14.0*15.0*15.0*14.0*15.0*14.0*22.0*18.0*21.0*21.0*10.0*10.0*11.0*9.0*28.0*25.0*19.0*16.0*17.0*19.0*18.0*14.0*14.0*14.0*14.0*12.0*13.0*13.0*18.0*22.0*19.0*18.0*23.0*26.0*25.0*20.0*21.0*13.0*14.0*15.0*14.0*17.0*11.0*13.0*12.0*13.0*15.0*13.0*13.0*14.0*22.0*28.0*13.0*14.0*13.0*14.0*15.0*12.0*13.0*13.0*14.0*13.0*12.0*13.0*18.0*16.0*18.0*18.0*23.0*11.0*12.0*13.0*12.0*18.0*21.0*19.0*21.0*15.0*16.0*15.0*11.0*20.0*21.0*19.0*15.0*26.0*25.0*16.0*16.0*18.0*16.0*13.0*14.0*14.0*14.0*28.0*19.0*18.0*15.0*15.0*16.0*15.0*16.0*14.0*17.0*16.0*15.0*18.0*21.0*20.0*13.0*23.0*20.0*23.0*18.0*19.0*25.0*26.0*18.0*16.0*16.0*15.0*22.0*22.0*24.0*23.0*29.0*25.0*20.0*18.0*19.0*18.0*27.0*13.0*17.0*13.0*13.0*13.0*30.0*26.0*18.0*17.0*16.0*15.0*18.0*21.0*19.0*19.0*16.0*16.0*16.0*16.0*25.0*26.0*31.0*34.0*36.0*20.0*19.0*20.0*19.0*21.0*20.0*25.0*21.0*19.0*21.0*21.0*19.0*18.0*19.0*18.0*18.0*18.0*30.0*31.0*23.0*24.0*22.0*20.0*22.0*20.0*21.0*17.0*18.0*17.0*18.0*17.0*16.0*19.0*19.0*36.0*27.0*23.0*24.0*34.0*35.0*28.0*29.0*27.0*34.0*32.0*28.0*26.0*24.0*19.0*28.0*24.0*27.0*27.0*26.0*24.0*30.0*39.0*35.0*34.0*30.0*22.0*27.0*20.0*18.0*28.0*27.0*34.0*31.0*29.0*27.0*24.0*23.0*38.0*36.0*25.0*38.0*26.0*22.0*36.0*27.0*27.0*32.0*28.0")
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
            XCTAssertEqual(double1.geometricMean, 19.168086630042282)
            XCTAssert(double1.harmonicMean == 18.314802880545665)
            XCTAssertEqualWithAccuracy(double1.contraharmonicMean!, 22.124172517552658, accuracy: 1E-14)
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
            
            XCTAssertEqualWithAccuracy(double1.kurtosisExcess!, 0.0912127828607771, accuracy: 1E-14)
            XCTAssertEqualWithAccuracy(double1.kurtosis!, 3.0912127828607771, accuracy: 1E-14)
            XCTAssertEqualWithAccuracy(double1.skewness!, 0.82294497966005010, accuracy: 1E-14)
            
            
            
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

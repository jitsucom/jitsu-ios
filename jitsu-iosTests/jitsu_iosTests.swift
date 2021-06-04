//
//  jitsu_iosTests.swift
//  jitsu-iosTests
//
//  Created by Leonid Serebryanyy on 04.06.2021.
//

import XCTest
@testable import jitsu_ios

class jitsu_iosTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
		let test = EventName.showedScreen
		
		XCTAssertEqual(test, "sh")
	}

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

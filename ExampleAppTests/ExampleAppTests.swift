//
//  ExampleAppTests.swift
//  ExampleAppTests
//
//  Created by Leonid Serebryanyy on 18.07.2021.
//

import XCTest
@testable import ExampleApp
import Jitsu

class ExampleAppTests: XCTestCase {

    func testUsualSetup() throws {
		// we can check that MockServiceLocator gets used
		methodToTest()
	}
	
	func testExplicitSetup() throws {
		// we see that after setupMock is called, new events are not tracked
		Jitsu.setupMock(nil)
		methodToTest()
	}

}

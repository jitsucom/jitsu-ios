//
//  SerializerTools.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 04.07.2021.
//

import XCTest
@testable import Jitsu

class SerializerTests: XCTestCase {
	
	// MARK: - Basic
	
	func test_deepContainer() throws {
		// arrange
		let firstDict = ["fifty": [50, 51, 52, 53],
						 "sixty": [60, 61, 62, 63]]
		let secondDict = ["one": 1, "two": 2]
		
		let input = Array([
			NSDictionary(dictionary: firstDict),
			NSDictionary(dictionary: secondDict),
		])
		
		// build json
		guard let json = try? JSON(input) else {
			XCTFail("json couldn't be constructed from \(input)")
			return
		}
		
		// assert json
		let a = json.arrayValue?.first as? [String: Any]
		XCTAssertTrue(firstDict.anyEqual(to: a))
		let b = json.arrayValue?[1] as? [String: Any]
		XCTAssertTrue(secondDict.anyEqual(to: b))
		
		// encode
		let jsonString = json.toString()
		
		// decode
		let decoded = JSON.fromString(jsonString)
		
		// assert
		XCTAssertEqual(decoded, json)
	}
	
	// MARK: - Objc tests
	
	func test_nsarray_containsNSDict() throws {
		// arrange
		let firstDict = ["fifty": "50", "sixty": "60"]
		let secondDict = ["one": 1, "two": 2]
		
		let input = NSArray(array: [
			NSDictionary(dictionary: firstDict),
			NSDictionary(dictionary: secondDict),
		])
		
		// build json
		guard let json = try? JSON(input) else {
			XCTFail("json couldn't be constructed from \(input)")
			return
		}
		
		// assert json
		let a = json.arrayValue?.first as? [String: Any]
		XCTAssertTrue(firstDict.anyEqual(to: a))
		let b = json.arrayValue?[1] as? [String: Any]
		XCTAssertTrue(secondDict.anyEqual(to: b))
		
		// encode
		let jsonString = json.toString()
		
		// decode
		let decoded = JSON.fromString(jsonString)
		
		// assert
		XCTAssertEqual(decoded, json)
		
	}
	
	func test_array_containsNSDict() throws {
		// arrange
		let firstDict = ["fifty": "50", "sixty": "60"]
		let secondDict = ["one": 1, "two": 2]
		
		let input = Array([
			NSDictionary(dictionary: firstDict),
			NSDictionary(dictionary: secondDict),
		])
		
		// build json
		guard let json = try? JSON(input) else {
			XCTFail("json couldn't be constructed from \(input)")
			return
		}
		
		// assert json
		let a = json.arrayValue?.first as? [String: Any]
		XCTAssertTrue(firstDict.anyEqual(to: a))
		let b = json.arrayValue?[1] as? [String: Any]
		XCTAssertTrue(secondDict.anyEqual(to: b))
		
		// encode
		let jsonString = json.toString()
		
		// decode
		let decoded = JSON.fromString(jsonString)
		
		// assert
		XCTAssertEqual(decoded, json)
	}
	
	func test_array_of_nsnumbers() throws {
		// arrange
		let firstDict = ["fifty": NSNumber(50), "sixty": NSNumber(60)]
		let secondDict = ["one": 1, "two": 2]
		
		let input = Array([
			NSDictionary(dictionary: firstDict),
			NSDictionary(dictionary: secondDict),
		])
		
		// build json
		guard let json = try? JSON(input) else {
			XCTFail("json couldn't be constructed from \(input)")
			return
		}
		
		// assert json
		let a = json.arrayValue?.first as? [String: Any]
		XCTAssertTrue(firstDict.anyEqual(to: a))
		let b = json.arrayValue?[1] as? [String: Any]
		XCTAssertTrue(secondDict.anyEqual(to: b))
	}
	
	func test_arrayOfUUIDs_and_URLs() throws {
		let uuid = UUID()
		_ = try JSON(uuid)
		
		let nsuuid = NSUUID()
		_ = try JSON(nsuuid)
		
		let url = URL(string: "https://google.com")!
		_ = try JSON(url)
		
		let nsurl = NSURL(string: "https://google.com")!
		_ = try JSON(nsurl)
	}
	
	func test_deepContainer_objc() throws {
		// arrange
		let firstDict = ["fifty": NSArray(array: [50, 51, 52, 53]),
						 "sixty": NSArray(array: [60, 61, 62, 63])]
		let secondDict = ["one": 1, "two": 2]
		
		let input = Array([
			NSDictionary(dictionary: firstDict),
			NSDictionary(dictionary: secondDict),
		])
		
		// build json
		guard let json = try? JSON(input) else {
			XCTFail("json couldn't be constructed from \(input)")
			return
		}
		
		// assert json
		let a = json.arrayValue?.first as? [String: Any]
		XCTAssertTrue(firstDict.anyEqual(to: a))
		let b = json.arrayValue?[1] as? [String: Any]
		XCTAssertTrue(secondDict.anyEqual(to: b))
		
		// encode
		let jsonString = json.toString()
		
		// decode
		let decoded = JSON.fromString(jsonString)
		
		// assert
		XCTAssertEqual(decoded, json)
	}
	
	// MARK: - Codable
	
	func test_codable() throws {
		// arrange
		struct Some: Codable {
			var a: String
		}
		
		let input = Some(a: "5")
		
		// act
		guard let json = try? JSON(withCodable: input) else {
			XCTFail("json couldn't be constructed from \(input)")
			return
		}
		
		let jsonString = json.toString()
		let decoded = JSON.fromString(jsonString)
		
		//assert
		XCTAssertEqual(decoded, json)
	}
	
	func test_arrayOfCodable() throws {
		// arrange
		struct Some: Codable {
			var a: String
		}
		
		let input = [Some(a: "5"), Some(a: "10")]
		
		// act
		guard let json = try? JSON(withCodable: input) else {
			XCTFail("json couldn't be constructed from \(input)")
			return
		}
		
		let jsonString = json.toString()
		let decoded = JSON.fromString(jsonString)

		//assert
		XCTAssertEqual(decoded, json)
	}
	
	// MARK: - NSSecureCoding
	
//	func test_NSSecureCodingValues() throws {
//		@objc(JTSPost)
//		class Post: NSObject, NSSecureCoding {
//			var title: String?
//			init(title: String?) {
//				self.title = title
//			}
//
//			static var supportsSecureCoding: Bool = true
//			func encode(with coder: NSCoder) {
//				coder.encode(title, forKey: "title")
//			}
//			required init?(coder: NSCoder) {
//				title = (coder.decodeObject(forKey: "title") as! String)
//			}
//		}
//
//		// arrange
//		let input = Post(title: "hi")
//		// act
//		guard let json = try? JSON(with: input) else {
//			XCTFail("json couldn't be constructed from \(input)")
//			return
//		}
//
//
//		// act
//
//		//assert
//
//	}

	
}

//
//  GzipTests.swift
//  GzipTests
//
//  Created by 1024jp on 2015-05-11.

/*
The MIT License (MIT)

© 2015-2016 1024jp

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import Foundation
import XCTest
import Gzip

class NSData_GZIPTests: XCTestCase {
    
    func testGZip() {
        
        let testSentence = "foo"
        
        let data = testSentence.dataUsingEncoding(NSUTF8StringEncoding)!
        let gzipped = try! data.gzipped()
        let uncompressed = try! gzipped.gunzipped()
        let uncompressedSentence = String(data: uncompressed, encoding: NSUTF8StringEncoding)
        
        XCTAssertNotEqual(gzipped, data)
        XCTAssertEqual(uncompressedSentence, testSentence)
        
        XCTAssertTrue(gzipped.isGzipped)
        XCTAssertFalse(data.isGzipped)
        XCTAssertFalse(uncompressed.isGzipped)
    }
    
    
    func testZeroLength() {
        
        let zeroLengthData = NSData()
        
        XCTAssertEqual(try! zeroLengthData.gzipped(), zeroLengthData)
        XCTAssertEqual(try! zeroLengthData.gunzipped(), zeroLengthData)
        XCTAssertFalse(zeroLengthData.isGzipped)
    }
    
    
    func testWrongUngzip() {
        
        // data not compressed
        let data = "testString".dataUsingEncoding(NSUTF8StringEncoding)!
        
        var uncompressed: NSData?
        do {
            uncompressed = try data.gunzipped()
        } catch let error as GzipError {
            switch error {
            case .data(let message):
                XCTAssertEqual(message, "incorrect header check")
                XCTAssertEqual(message, error.localizedDescription)
            default:
                XCTFail("Caught incorrect error.")
            }
        } catch _ {
            XCTFail("Caught incorrect error.")
        }
        XCTAssertNil(uncompressed)
    }
    
    
    func testCompressionLevel() {
        
        let data = String.lorem(100_000).dataUsingEncoding(NSUTF8StringEncoding)!
        
        XCTAssertGreaterThan(try! data.gzipped(.bestSpeed).length,
                             try! data.gzipped(.bestCompression).length)
    }
    
    
    func testFileDecompression() {
        
        let bundle = NSBundle(forClass: NSData_GZIPTests.self)
        let url = bundle.URLForResource("test.txt", withExtension: "gz")!
        let data = try! NSData(contentsOfURL: url)!
        let uncompressed = try! data.gunzipped()
        
        
        XCTAssertEqual(String(data: uncompressed, encoding: NSUTF8StringEncoding), "test")
    }
    
}


private extension String {
    
    /// Generate random letters string for test.
    static func lorem(length : Int) -> String {
        
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var string = ""
        for _ in 0..<length {
            let rand = Int(arc4random_uniform(UInt32(letters.characters.count)))
            
            let index = letters[letters.startIndex.advancedBy(rand)]
            string.append(index)
        }
        
        return string
    }
    
}

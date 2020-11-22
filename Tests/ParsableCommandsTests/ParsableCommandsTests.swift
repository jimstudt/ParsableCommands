import XCTest
@testable import ParsableCommands

final class ParsableCommandsTests: XCTestCase {

    func testTokenizer() {
        XCTAssertEqual( tokenize("echo foo bar"), ["echo", "foo", "bar"])
        XCTAssertEqual( tokenize("   echo foo bar   "), ["echo", "foo", "bar"])
        XCTAssertEqual( tokenize("echo \"foo bar\" day"), ["echo", "foo bar", "day"])
        XCTAssertEqual( tokenize("echo \"foo\" 'bar' day"), ["echo", "foo", "bar", "day"])
        XCTAssertEqual( tokenize("echo \"foo barn't\" day"), ["echo", "foo barn't", "day"])
        XCTAssertEqual( tokenize("echo 'foo bar' day"), ["echo", "foo bar", "day"])
        XCTAssertEqual( tokenize("echo 'foo \"bar\"' day"), ["echo", "foo \"bar\"", "day"])
        XCTAssertEqual( tokenize("echo foo \"bar all day"), ["echo", "foo", "bar all day"])
        XCTAssertEqual( tokenize("echo foo 'bar \"all\" day"), ["echo", "foo", "bar \"all\" day"])
        XCTAssertEqual( tokenize("echo foo\\ bar"), ["echo", "foo bar"])
        XCTAssertEqual( tokenize("echo foo\\'t bar"), ["echo", "foo't", "bar"])
        XCTAssertEqual( tokenize("echo \\\"foo\\\" bar"), ["echo", "\"foo\"", "bar"])
        XCTAssertEqual( tokenize("echo \"foo \\\"bar\\\"\" day"), ["echo", "foo \"bar\"", "day"])
        XCTAssertEqual( tokenize("echo 'foo \\'bar\\'' day"), ["echo", "foo 'bar'", "day"])
        XCTAssertEqual( tokenize("echo '' bar"), ["echo", "", "bar"])

   }
    static var allTests = [
        ("testTokenizer", testTokenizer),
    ]
}

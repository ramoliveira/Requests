    import XCTest
    @testable import Requests

    final class RequestsTests: XCTestCase {
        public struct Kanye: Codable {
            let quote: String?
        }
        
        func testExample() {
            let url = URL(string: "https://api.kanye.rest/")!
            
            let expectation = XCTestExpectation(description: "Testing request to Kanye West API")
            
            Requests(.get, url: url).execute(Kanye.self) { result in
                switch result {
                case .success(let kanye):
                    XCTAssertNotNil(kanye.quote)
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("FAILED with:\n\(error)")
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 20.0)
        }
    }

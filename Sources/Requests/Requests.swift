import Foundation

public final class Requests {
    public enum `Type`: String {
        case get = "GET"
        case post = "POST"
    }
    
    public enum Error: Swift.Error {
        case failedDecode
        case failedEncode
    }
    
    public typealias Request = URLRequest
    public typealias Header = [String:Any]
    public typealias Body = Codable
    public typealias Task = URLSessionTask
    
    private(set) var request: Request
    private(set) var header: Header?
    private(set) var body: Body?
    
    public init(_ requestType: `Type`, url: URL) {
        self.request = URLRequest(url: url)
        self.request.httpMethod = requestType.rawValue
    }
    
    public init<T: Codable>(_ requestType: `Type`, url: URL, header: Header?=nil, body: T?=nil) throws {
        self.request = URLRequest(url: url)
        self.request.httpMethod = requestType.rawValue
        
        if let header = header, let body = body {
            self.set(header)
            try self.set(body)
            self.header = header
            self.body = body
        }
    }
    
    @discardableResult
    public func set(_ header: Header) -> Requests {
        for (key, value) in header {
            if !header.contains(where: { return $0.key == "Content-Type" }) {
                self.request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            if let value = value as? String {
                self.request.setValue(value, forHTTPHeaderField: key)
            } else {
                self.request.setValue("\(value)", forHTTPHeaderField: key)
            }
            self.header?[key] = value
        }
        
        return self
    }
    
    @discardableResult
    public func set<T: Encodable>(_ body: T) throws -> Requests {
        guard let body = try? JSONEncoder().encode(body) else { throw Error.failedEncode }
        self.request.httpBody = body
        self.body = body
        
        return self
    }
    
    public func execute<T: Codable>(_ responseData: T.Type, completion: @escaping (Result<T, Error>)->Void) {
        let task = URLSession.shared.dataTask(with: self.request) { (data, response, error) in
            if let error = error as? Error {
                completion(.failure(error))
            }
            
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedData))
                } catch let decodingError {
                    if let decodingError = decodingError as? Error {
                        completion(.failure(decodingError))
                    }
                }
            }
        }
        task.resume()
    }
}

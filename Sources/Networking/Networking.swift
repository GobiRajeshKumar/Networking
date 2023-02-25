import Foundation

public class Networking {

    private init() { }
    
    public static let shared = Networking()
    
    public func downloadData(fromURL url: URL, completionHandler: @escaping (_ data: Data?) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let data = data,
                error == nil,
                let response = response as? HTTPURLResponse,
                response.statusCode >= 200 && response.statusCode < 300 else {
                completionHandler(nil)
                return
            }
            
            completionHandler(data)
        }
        .resume()
    }
    
    private enum NetworkError: Error {
        case badURL
        case badResponse
        case errorDecodingData
        case invalidError
    }
    
    public enum HttpMethods: String {
        case POST, GET, PUT, DELETE
    }
    
    public enum MIMEType: String {
        case JSON = "application/json"
    }
    
    public enum HttpHeaders: String {
        case contentType = "Content-Type"
    }
    
    @available(iOS 15.0, *)
    public func fetchData<T: Codable>(from urlString: String) async throws -> [T]  {
        guard let url = URL(string: urlString) else {
            throw NetworkError.badURL
        }
        let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.badResponse
        }
        guard let object = try? JSONDecoder().decode([T].self, from: data) else {
            throw NetworkError.errorDecodingData
        }
        return object
    }
    
    @available(iOS 15.0, *)
    public func sendData<T: Codable>(from urlString: String, object: T, httpMethod: HttpMethods) async throws {
        guard let url = URL(string: urlString) else {
            throw NetworkError.badURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HttpHeaders.contentType.rawValue)
        request.httpBody = try? JSONEncoder().encode(object)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.badResponse
        }
    }
}

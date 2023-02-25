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
    
    @available(iOS 15.0, *)
    @available(macOS 12.0, *)
    public func fetch<T: Codable>(from urlString: String) async throws -> [T]  {
        guard let url = URL(string: urlString) else { throw NetworkError.badURL }
        let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { throw NetworkError.badResponse }
        guard let object = try? JSONDecoder().decode([T].self, from: data) else { throw NetworkError.errorDecodingData }
        return object
    }
}

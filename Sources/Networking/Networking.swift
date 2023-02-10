import Foundation

public class Networking {

    public init() { }
    
    public static let shared = Networking()
    
    public func downloadData(fromURL url: URL, completionHandler: @escaping (_ data: Data?) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let data = data,
                error == nil,
                let response = response as? HTTPURLResponse,
                response.statusCode >= 200 && response.statusCode < 300 else {
                print("Error downloading data.")
                completionHandler(nil)
                return
            }
            
            completionHandler(data)
        }
        .resume()
    }
    
    private enum NetworkError: Error {
        case urlError
        case responseError
        case error
    }
    
    @available(iOS 15.0, *)
    @available(macOS 12.0, *)
    public func downloadData<T: Codable>(from url: String) async throws -> T  {
        guard let url = URL(string: url) else { throw NetworkError.urlError }
        let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { throw NetworkError.responseError }
        return try JSONDecoder().decode(T.self, from: data)
    }
}

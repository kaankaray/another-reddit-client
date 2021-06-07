//
//  Global.swift
//  AnotherRedditClient
//
//  Created by Kaan Karay on 4.06.2021.
//

import Foundation
import UIKit

// MARK: - Extentions
extension UIImageView {
    ///Get image directly from URL
    public func imageFromUrl(urlString: String) {
        if let url = URL(string: urlString) {
            NSURLConnection.sendAsynchronousRequest(URLRequest(url: url), queue: OperationQueue.main) {
                (response: URLResponse?, data: Data?, error: Error?) -> Void in
                if let imageData = data as Data? {
                    self.image = UIImage(data: imageData)
                }
            }
        }
    }
}

// MARK: - Global methods:

///
/// Basically reformats Any object to JSON formatted Dictionary.
/// - Parameter obj: Object to be converted/.
///
func anyObjectToJSON(obj:Any) -> [String: Any] {
    do {
        let convertedToData = try JSONSerialization.data(withJSONObject: obj) // We convert this NSDictionary to Data first.
        return try JSONSerialization.jsonObject(with: convertedToData, options: []) as! [String : Any] // Then we return it.
    } catch let error as NSError {
        print(obj)
        print("Any to JSON method failed. + \(error.localizedDescription)")
    }
    return [:]
}

///
/// Gets posts from 'https://www.reddit.com/top.json' and returns the results as Array<String : Any>
/// - Parameter after: Default value = "";      reddit will return values after this post.
/// - Parameter limit: Default value = threadCount;     The subscriber to attach to this ``Publisher``, after which it can receive values
///
func getPosts(after:String = "", limit:Int = threadCount, completion: @escaping (Array<[String: Any]>) -> Void) {
    var urlString = "https://www.reddit.com/top.json?&limit=\(limit)" // URL and our limit
    if after != "" { urlString += "&after=\(after)" } // If there should be an 'after' input
    
    var urlRequest = URLRequest(url: URL(string: urlString)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20)
    urlRequest.allHTTPHeaderFields = ["Content-Type": "application/json", "User-Agent": "AnotherRedditClientApp"]
    urlRequest.httpMethod = "GET"
    URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
        if let error = error { print(error) } // If error,
        else if let data = data, let responseCode = response as? HTTPURLResponse {
            do {
//                    print(responseCode.statusCode)
                if (200...299).contains(responseCode.statusCode){ // If status code is OK
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            if let datas = json["data"] as? [String: Any] {
//                                    print(type(of: datas["children"]))
                                if let children = datas["children"] as? [Any] { // This gives us results in an array.
//                                        print(children.count)
//                                        print(type(of: children))
//                                        completion(children)
                                    var returningArray:Array<[String: Any]> = []
                                    for k in children {
                                        returningArray.append(anyObjectToJSON(obj: k))
                                    }
                                    completion(returningArray)
                                    
                                }
                            }
                        }
                } else { print("Response code is not OK: \(responseCode.statusCode)") }
            } catch let parseJSONError { print("error on parsing request to JSON : \(parseJSONError)") }
        }
    }.resume()
}


// MARK: Limits
let maxPostsInPage = 50
let threadCount = 5



// MARK: Global variables.
var passIDArr:Array<String> = []
var latestLoadedPostID:String = ""
var postCounter:Int = 0


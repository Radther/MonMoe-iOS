//
//  MONAPI.swift
//  MonMoeApp
//
//  Created by Tom Sinlgeton on 06/01/2017.
//  Copyright © 2017 Tom Sinlgeton. All rights reserved.
//

import Foundation
import SwiftyJSON

enum Result<T> {
    case success(T)
    case failure(Error)
}

enum MONError: Error {
    case failed
}

class MONAPI {
    
    static let endpoint = "www.monthly.moe"
    static var currentTask: URLSessionDataTask?
    
    static func getCalendar(forMonth month: Date = Date(), completion: @escaping (Result<[Date:[Episode]]>) -> ()) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = endpoint
        urlComponents.path = "/api/v1/calendar"
        
//        let dateQuery = URLQueryItem(name: "date", value: "")
//        urlComponents.queryItems = [dateQuery]
        print(urlComponents.url!)
        currentTask?.cancel()
        currentTask = URLSession.shared.dataTask(with: urlComponents.url!, completionHandler: { (data, response, error) in
            guard error == nil, let data = data else {
                completion(.failure(error!))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(MONError.failed))
                return
            }
            
            let json = JSON(data: data)
            let animes = json["animes"].arrayValue
            
            var animeDictionary = [Int: Anime]()
            animes.forEach({ (anime) in
                let id = anime["id"].intValue
                let title = anime["main_title"].stringValue
                let anime = Anime(id: id, title: title)
                
                animeDictionary[anime.id] = anime
            })
            
            let episodes = json["episodes"].arrayValue
            
            var episodesDictionary = [Date:[Episode]]()
            episodes.forEach({ (episode) in
                
            })
            
            completion(.success([:]))
        })
        
        currentTask?.resume()
    }
    
}

struct Anime {
    let id: Int
    let title: String
}

struct Episode {
    let id: Int
    let title: String
    let date: Date
    let first: Bool
    let last: Bool
    let special: Bool
}

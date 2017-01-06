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
    
    static func getCalendar(forMonth month: Date = Date(), completion: @escaping (Result<[Day]>) -> ()) {
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
            let calendar = Calendar(identifier: .gregorian)
            episodes.forEach({ (episodeJson) in
                let animeId = episodeJson["anime_id"].intValue
                guard let date = episodeJson["datetime"].date else {
                    return
                }
                let isFirst = episodeJson["is_first"].boolValue
                let islast = episodeJson["is_last"].boolValue
                let special = episodeJson["special"].boolValue
                let number = episodeJson["number"].intValue
                
                guard let title = animeDictionary[animeId]?.title else {
                    return
                }
                
                let episode = Episode(id: animeId, title: title, number: number, date: date, first: isFirst, last: islast, special: special)
                
                let dayDate = calendar.startOfDay(for: date)
                var episodeList = episodesDictionary[dayDate] ?? []
                episodeList.append(episode)
                episodesDictionary[dayDate] = episodeList
            })
            
            var days = [Day]()
            episodesDictionary.forEach({ (date, episodes) in
                days.append(Day(date: date, episodes: episodes))
            })
            
            completion(.success(days))
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
    let number: Int
    let date: Date
    let first: Bool
    let last: Bool
    let special: Bool
}

struct Day {
    let date: Date
    let episodes: [Episode]
}

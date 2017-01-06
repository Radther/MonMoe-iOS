//
//  MONAPI.swift
//  MonMoeApp
//
//  Created by Tom Sinlgeton on 06/01/2017.
//  Copyright © 2017 Tom Sinlgeton. All rights reserved.
//

import Foundation
import SwiftyJSON

class MONAPI {
    
    static let endpoint = "www.monthly.moe"
    
    static func getCalendar(forMonth month: Date = Date(), completion: ([Date:[Episode]]) -> ()) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = endpoint
        urlComponents.path = "/api/v1/calendar"
        
        let dateQuery = URLQueryItem(name: "date", value: "")
        urlComponents.queryItems = [dateQuery]
        
        _ = URLSession.shared.dataTask(with: urlComponents.url!, completionHandler: { (data, response, error) in
            guard error == nil else {
                print(error!)
                return
            }
            
            
        })
        
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

//
//  ViewController.swift
//  CondingProtocolSample
//
//  Created by Sudhanshu Srivastava on 29/11/18.
//  Copyright © 2018 Sudhanshu Srivastava. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var feedsArray: Feeds?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        JSONSerialization()
    }
    
    func JSONSerialization() {
        
        let responseJSON = """
            {
            "feeds": [
                {
                    "type": "create_card",
                    "description": "All natural"
                },
                {
                    "type": "feed_card",
                    "description": "Best drank with breakfast"
                },
                {
                    "type": "carousel",
                    "description": "An alcoholic beverage, best drunk on fridays after work",
                    "number_of_elements": "5"
                }
            ]
            }
            """
        //    print(responseJSON)
        let jsonDecoder = JSONDecoder()
        
        do{
            let results = try jsonDecoder.decode(Feeds.self, from: responseJSON.data(using: .utf8)!)
            feedsArray = results
            for result in results.feeds {
                print(result.description)
            }
        }catch {
            
        }
    }
}

// Models


struct Feeds: Decodable {
    var feeds: [Feed]
    enum CodingKeys: CodingKey {
        case feeds
    }
    
    enum FeedTypeKey: String, CodingKey {
        case type
    }
    
    enum FeedTypeValues: String, Decodable {
        case createCard = "create_card"
        case carousel = "carousel"
        case feedCard = "feed_card"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var feedsArrayForType = try container.nestedUnkeyedContainer(forKey: CodingKeys.feeds)
        var feeds = [Feed]()
        
        var feedsDecodedArray = feedsArrayForType
        
        while(!feedsArrayForType.isAtEnd) {
            let feed = try feedsArrayForType.nestedContainer(keyedBy: FeedTypeKey.self)
            
            let type = try feed.decode(FeedTypeValues.self, forKey: .type)
            switch type {
            case .createCard, .feedCard:
                feeds.append(try feedsDecodedArray.decode(Feed.self))
            case .carousel:
                feeds.append(try feedsDecodedArray.decode(Carousel.self))
            }
        }
        self.feeds = feeds
    }
}


class Feed: Decodable {
    var type: String
    var description: String
    
    private enum CodingKeys: String, CodingKey {
        case type
        case description
    }
}

class Carousel: Feed {
    var number_of_elements: String
    
    private enum CodingKeys: String, CodingKey {
        case number_of_elements
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.number_of_elements = try container.decode(String.self, forKey: .number_of_elements)
        try super.init(from: decoder)
    }
}



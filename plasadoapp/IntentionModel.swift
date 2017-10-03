//
//  IntentionModel.swift
//  plasadoapp
//
//  Created by a on 9/19/17.
//  Copyright © 2017 plasado. All rights reserved.
//

import Foundation
import ObjectMapper
class Intention : Mappable,Equatable{
    var name : String!
    var date : String!
    var location : String!
    var category : String!
    var minBudget : Int!
    var maxBudget : Int!
    var user : String!
    public static func ==(lhs: Intention, rhs: Intention) -> Bool{
        return lhs.toJSONString() == rhs.toJSONString()
    }
    
    init(value : [String : Any]) {
        name = value["name"] as! String
        date = value["date"] as! String
        location = value["location"] as! String
        category = value["category"] as! String
        minBudget = value["minBudget"] as! Int
        maxBudget = value["maxBudget"] as! Int
        user = value["user"] as! String
    }

    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        name        <- map["name"]
        date        <- map["date"]
        location    <- map["location"]
        category        <- map["category"]
        minBudget <- map["minBudget"]
        maxBudget   <- map["maxBudget"]
        user        <- map["user"]
        
    }
}

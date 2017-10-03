//
//  UserModel.swift
//  plasadoapp
//
//  Created by a on 9/1/17.
//  Copyright © 2017 plasado. All rights reserved.
//

import Foundation
import ObjectMapper
class Inviter : Mappable{
    var pendinglist : [String]! = []
    var userlist : [String]! = []
    init(value : [String : Any]){
        pendinglist = value["pendinglist"] as! [String]
        userlist = value["userlist"] as! [String]
    }
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        pendinglist    <- map["pendinglist"]
        userlist      <- map["userList"]
    }
}
class User : Mappable,Equatable{
    var email : String = ""
    var name : String = ""
    var birthday : String = Date().iso8601
    var gender : String = "Male"
    var type : String = "user"
    var comments : String = ""
    var picture : String = ""
    var events : [CelebrationEvent] = []
    var daysoffweek : [String] = ["Sat","Sun"]
    var inviterList : [Inviter] = []
    public static func ==(lhs: User, rhs: User) -> Bool{
        return lhs.toJSONString() == rhs.toJSONString()
    }
    init(value : [String : Any]) {
        let eventArray = ((value["events"] as? [String:Any])?["data"] as? [[String:Any]])
        if (eventArray == nil){
            self.events = []
        } else{
            for event in eventArray!{
                self.events.append(CelebrationEvent(value: event))
            }
        }
        if value["email"] == nil{
            self.email = ""
        } else {
            self.email = value["email"] as! String
        }
        
        if value["name"] == nil{
            self.name = ""
        } else {
            self.name = value["name"] as! String
        }
        
        if value["birthday"] == nil{
            self.birthday = Date().shortiso8601
        } else {
            self.birthday = value["birthday"] as! String
        }
        
        if value["gender"] == nil{
            self.gender = ""
        } else {
            self.gender = value["gender"] as! String
        }
        if value["picture"] as? String == nil{
            self.picture = ((value["picture"] as? [String : Any])?["data"] as! [String:Any])["url"] as! String
        } else{
            self.picture = value["picture"] as! String
        }
        
        self.type = value["type"] == nil ? "user" : value["type"] as! String
    }
    func setDaysoffweek(daysoffweekArray : [String]){
        self.daysoffweek = daysoffweekArray
    }
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        email           <- map["email"]
        name           <- map["name"]
        birthday           <- map["birthday"]
        gender           <- map["gender"]
        type           <- map["type"]
        comments           <- map["comments"]
        picture           <- map["picture"]
        events           <- map["events"]
        daysoffweek     <- map["daysoffweek"]
    }
}
enum RSVP{
    case attending
    case maybe
    case declined
}
class Friend : Mappable, Equatable{
    var id : String = ""
    var name : String = ""
    var picture : String = ""
    init(value : [String : Any]){
        self.id = value["id"] as! String
        self.name = value["name"] as! String
        self.picture = ((value["picture"] as! [String:Any])["data"] as! [String:Any])["url"] as! String
    }
    required init?(map: Map) {
        
    }
    func mapping(map : Map){
        id <- map["id"]
        name <- map["name"]
        picture <- map["picture"]
    }
    public static func ==(lhs: Friend, rhs: Friend) -> Bool{
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.picture == rhs.picture
    }
}
class CelebrationEvent:Mappable{
    var name : String = ""
    var description : String = ""
    var start_time : String = ""
    var end_time : String = ""
    //var place__name : String = ""
    init(value : [String : Any]) {
        self.name = (value["name"] as? String)!
        self.description = (value["description"] as? String)!
        if value["end_time"] != nil{
            self.end_time = (value["end_time"] as? String)!
        }
        else {
            self.end_time = (value["start_time"] as? String)!
        }
        if value["start_time"] != nil{
            self.start_time = (value["start_time"] as? String)!
        }
        else {
            self.start_time = (value["end_time"] as? String)!
        }
    }
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        name           <- map["name"]
        description           <- map["description"]
        start_time           <- map["start_time"]
        end_time           <- map["end_time"]
        //place__name           <- map["place__name"]
    }
    
    
}

extension Array  {
    var indexedDictionary: [Int: Element] {
        var result: [Int: Element] = [:]
        enumerated().forEach({ result[$0.offset] = $0.element })
        return result
    }
}


//
//  LocalStorage.swift
//  plasadoapp
//
//  Created by a on 8/19/17.
//  Copyright © 2017 plasado. All rights reserved.
//

import Foundation
import Alamofire
class LocalStorge {
    static public var token : String!
    
    
    static public var user : User!
    
    static public var offerArray : [Offer]! = []
    
    static public var categoryArray : [String]! = []
    
    static public var featuredOfferCount : Int! = 5
    
    
    static public var featuredOfferArray : [Offer]! = []
    
    static public var intentionArray : [[String : Any]]! = []
    
    static public var daysOffwork : [Date]!
    
    static public var appID : String!
    
    static public var ical_Events : [CelebrationEvent]! = []
}

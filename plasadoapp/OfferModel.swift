//
//  OfferModel.swift
//  plasadoapp
//
//  Created by Emperor on 9/11/17.
//  Copyright © 2017 plasado. All rights reserved.
//

import Foundation
import ObjectMapper
class Offer : Mappable{
    /*
     category:
     "Wedding Service"
     comment:
     "COment"
     creationDate:
     "9/2/2017"
     discount:
     "10"
     imageUrl:
     "https://firebasestorage.googleapis.com/v0/b/pla..."
     key:
     "-KtjKH2FSFIitmsdz0s3"
     price:
     "900"
     title: 
     "Service1"
     userEmail: 
     "aa@gmail.com"
*/
    var category : String = ""
    var comment : String = ""
    var creationDate : String = ""
    var discount : Int = 0
    var picture : String = ""
    var price : Int = 0
    var title : String = ""
    var userEmail : String = ""

    let transform = TransformOf<Int, String>(fromJSON: { (value: String?) -> Int? in
        // transform value from String? to Int?
        return Int(value!)
    }, toJSON: { (value: Int?) -> String? in
        // transform value from Int? to String?
        if let value = value {
            return String(value)
        }
        return nil
    })
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        category           <- map["category"]
        comment           <- map["comment"]
        creationDate           <- map["creationDate"]
        discount           <- (map["discount"],transform)
        picture           <- map["picture"]
        price           <- (map["price"], transform)
        title           <- map["title"]
        userEmail           <- map["userEmail"]
    }

}

//
//  Location.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 30/07/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import Foundation

struct LocationData : Codable {
    let id : Int?
    let name : String?
    let address : String?
    let zipCode : String?
    let city : String?
    let lat : CFloat?
    let lon : CFloat?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case name = "name"
        case address = "address"
        case zipCode = "zip_code"
        case city = "city"
        case lat = "lat"
        case lon = "lon"
    }
}

struct CoordinateData : Codable {
    let lat : CFloat
    let lon : CFloat
    var streetName = "";
    var zipCode = "";
    var country = "";
    var locality = "";
    var streetNumber = "";
    var city = "";
    var geoCodingCompleted = false;
    
    init(lat: CFloat, lon: CFloat) {
        self.lat = lat
        self.lon = lon
        streetName = "";
        zipCode = "";
        country = "";
        locality = "";
        streetNumber = "";
        city = "";
        geoCodingCompleted = false;
    }
}

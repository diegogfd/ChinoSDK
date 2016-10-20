//
//  MPPPeak.swift
//  MPPChinoSDK
//
//  Created by Diego Flores Domenech on 10/19/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class MPPPeak: NSObject {
    var index : Int = 0
    var value : Int64 = 0
    
    init(index : Int, value : Int64) {
        self.index = index
        self.value = value
    }
    
}

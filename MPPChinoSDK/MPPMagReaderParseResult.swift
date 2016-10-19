//
//  MPPMagReaderParseResult.swift
//  MPPChinoSDK
//
//  Created by Diego Flores Domenech on 10/18/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class MPPMagReaderParseResult: NSObject {

    var errorCode = 0
    var data = ""
    
    init(errorCode : Int, data : String) {
        self.errorCode = errorCode
        self.data = data
    }
    
}

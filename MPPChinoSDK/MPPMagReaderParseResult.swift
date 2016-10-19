//
//  MPPMagReaderParseResult.swift
//  MPPChinoSDK
//
//  Created by Diego Flores Domenech on 10/18/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class MPPMagReaderParseResult: NSObject {

    var code : MPPMagStripeResult = .nothing
    var data : String?
    
    init(code : MPPMagStripeResult, data : String?) {
        self.code = code
        self.data = data
    }
    
}

//
//  MPPMagReaderParser.swift
//  MPPChinoSDK
//
//  Created by Diego Flores Domenech on 10/18/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class MPPMagReaderParser: NSObject {
    
    static func parse(buffer : [Int]) -> MPPMagReaderParseResult?{
        return MPPMagReaderParseResult(errorCode: 1, data: "")
    }
    
}

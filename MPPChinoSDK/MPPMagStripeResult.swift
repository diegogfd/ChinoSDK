//
//  MPPMagStripeConstants.swift
//  MPPChinoSDK
//
//  Created by Diego Flores Domenech on 10/18/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

enum MPPMagStripeResult : Int{
    case nothing
    case success
    case successLuhn
    case shittyData
    case startSentinelNotFound
    case parityBitCheckFailed
    case parityForLRCCheckFailed
    case LRCCheckFailed
    case unableToPerformLRCCheck
    case unknownError
    case ignoreMicOut
    case tooFast
    case tooSlow
}

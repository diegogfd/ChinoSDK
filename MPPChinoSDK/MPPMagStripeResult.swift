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
    
    func description() -> String{
        var descr = ""
        switch self {
        case .nothing:
            descr = "nothing"
        case .success:
            descr = "success"
        case .successLuhn:
            descr = "successLuhn"
        case .shittyData:
            descr = "shittyData"
        case .startSentinelNotFound:
            descr = "startSentinelNotFound"
        case .parityBitCheckFailed:
            descr = "parityBitCheckFailed"
        case .parityForLRCCheckFailed:
            descr = "parityForLRCCheckFailed"
        case .LRCCheckFailed:
            descr = "LRCCheckFailed"
        case .unableToPerformLRCCheck:
            descr = "unableToPerformLRCCheck"
        case .unknownError:
            descr = "unknownError"
        case .ignoreMicOut:
            descr = "ignoreMicOut"
        case .tooFast:
            descr = "tooFast"
        case .tooSlow:
            descr = "tooSlow"
        }
        return descr
    }
}

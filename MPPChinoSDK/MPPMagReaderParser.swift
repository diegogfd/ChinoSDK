//
//  MPPMagReaderParser.swift
//  MPPChinoSDK
//
//  Created by Diego Flores Domenech on 10/18/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class MPPMagReaderParser: NSObject {
    
    static let maxQuantificationDataPeak = 32768;
    
    static func parse(buffer : [Int64],reversed : Bool,maxValue: Int64) -> MPPMagReaderParseResult?{
        let operationQueue = NSOperationQueue()
        var operations : [MPPParserOperation] = []

        let operation1 = MPPParserOperation()
        operation1.addExecutionBlock {
            operation1.parseResult = parseMethod(buffer, distanceBetweenPeaksHysteresis: 0.30, differenceInAmplitudeForPeaks: 0.15,reversed : reversed, maxValue: maxValue)
        }
        operations.append(operation1)
        let operation2 = MPPParserOperation()
        operation2.addExecutionBlock {
            operation2.parseResult = parseMethod(buffer, distanceBetweenPeaksHysteresis: 0.35, differenceInAmplitudeForPeaks: 0.2,reversed : reversed, maxValue: maxValue)
        }
        operations.append(operation2)
        let operation3 = MPPParserOperation()
        operation3.addExecutionBlock {
            operation3.parseResult = parseMethod(buffer, distanceBetweenPeaksHysteresis: 0.4, differenceInAmplitudeForPeaks: 0.25,reversed : reversed, maxValue: maxValue)
        }
        operations.append(operation3)
        let operation4 = MPPParserOperation()
        operation4.addExecutionBlock {
            operation4.parseResult = parseMethod(buffer, distanceBetweenPeaksHysteresis: 0.45, differenceInAmplitudeForPeaks: 0.3,reversed : reversed, maxValue: maxValue)
        }
        operations.append(operation4)

        operationQueue.addOperations(operations, waitUntilFinished: true)
        
        for operation in operations {
            if let parseResult = operation.parseResult {
                if parseResult.code == .success || parseResult.code == .successLuhn {
                    return parseResult
                }
            }
        }
        
        return operation1.parseResult
    }
    
    private static func parseMethod(data : [Int64], distanceBetweenPeaksHysteresis : Double, differenceInAmplitudeForPeaks: Double,reversed : Bool,maxValue: Int64) -> MPPMagReaderParseResult{
        
        
        
        
        
        return MPPMagReaderParseResult(code: .nothing, data: "")
    }
    
    private static func performLuhnValidation(ccNumber : String) -> Bool{
        if ccNumber.characters.count < 13 {
            return false
        }
        var sum : Int64 = 0
        var alternate = false
        for i in (ccNumber.characters.count - 1)...0 {
            let range = ccNumber.startIndex.advancedBy(i) ..< ccNumber.startIndex.advancedBy(i+1)
            var n =  Int64(ccNumber.substringWithRange(range))!
            if alternate {
                n *= 2
                if n > 9 {
                    n = n % 10 + 1
                }
            }
            sum += n
            alternate = !alternate
        }
        return sum % 10 == 0
    }
    
    private static func resolveErrorCause(ret : MPPMagStripeResult, result : String, distances : [Int], maxValue : Int64) -> MPPMagReaderParseResult{
        var ret = ret
        if distances.count < 116 && Double(maxValue) > Double(maxQuantificationDataPeak) * 0.85 {
            ret = .ignoreMicOut
            return MPPMagReaderParseResult(code: ret, data: nil)
        }
        var suma = 0
        for i in distances {
            suma += i
        }
        if distances.count == 0 {
            return MPPMagReaderParseResult(code: .tooSlow, data: nil)
        }else{
            if suma / distances.count > 40 {
                return MPPMagReaderParseResult(code: .tooSlow, data: nil)
            }else if suma / distances.count < 5{
                return MPPMagReaderParseResult(code: .tooFast, data: nil)
            }
        }
        return MPPMagReaderParseResult(code: ret, data: nil)
    }
    
}



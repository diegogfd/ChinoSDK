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
//        let operationQueue = NSOperationQueue()
//        var operations : [MPPParserOperation] = []
//
//        let operation1 = MPPParserOperation()
//        operation1.addExecutionBlock {
//            operation1.parseResult = parseMethod(buffer, distanceBetweenPeaksHysteresis: 0.30, differenceInAmplitudeForPeaks: 0.15,reversed : reversed, maxValue: maxValue)
//        }
//        operations.append(operation1)
//        let operation2 = MPPParserOperation()
//        operation2.addExecutionBlock {
//            operation2.parseResult = parseMethod(buffer, distanceBetweenPeaksHysteresis: 0.35, differenceInAmplitudeForPeaks: 0.2,reversed : reversed, maxValue: maxValue)
//        }
//        operations.append(operation2)
//        let operation3 = MPPParserOperation()
//        operation3.addExecutionBlock {
//            operation3.parseResult = parseMethod(buffer, distanceBetweenPeaksHysteresis: 0.4, differenceInAmplitudeForPeaks: 0.25,reversed : reversed, maxValue: maxValue)
//        }
//        operations.append(operation3)
//        let operation4 = MPPParserOperation()
//        operation4.addExecutionBlock {
//            operation4.parseResult = parseMethod(buffer, distanceBetweenPeaksHysteresis: 0.45, differenceInAmplitudeForPeaks: 0.3,reversed : reversed, maxValue: maxValue)
//        }
//        operations.append(operation4)
//
//        operationQueue.addOperations(operations, waitUntilFinished: true)
//        
//        for operation in operations {
//            if let parseResult = operation.parseResult {
//                if parseResult.code == .success || parseResult.code == .successLuhn {
//                    return parseResult
//                }
//            }
//        }
//        
//        return operation1.parseResult
        return parseMethod(buffer, distanceBetweenPeaksHysteresis: 0.30, differenceInAmplitudeForPeaks: 0.15,reversed : reversed, maxValue: maxValue)
    }
    
    private static func parseMethod(data : [Int64], distanceBetweenPeaksHysteresis : Double, differenceInAmplitudeForPeaks: Double,reversed : Bool,maxValue: Int64) -> MPPMagReaderParseResult{
        let maxValue = Double(maxValue)
        var result = ""
        var ret = MPPMagStripeResult.success
        var peakThreshold = maxValue * differenceInAmplitudeForPeaks
        var startIndex : Int = 0
        if !reversed {
            startIndex = 0
        }else{
            startIndex = data.count - 1
        }
        var currentPeak = MPPPeak(index: 0, value: 0)
        var distancesBetweenPeaks : [Int] = []
        if !reversed {
            for i in 0..<data.count {
                if Double(abs(data[i])) > peakThreshold {
                    startIndex = i + 1
                    currentPeak = MPPPeak(index: i, value: data[i])
                    break
                }
            }
        }else{
            for i in (data.count - 1).stride(to: 0, by: -1){
                if Double(abs(data[i])) > peakThreshold {
                    startIndex = i - 1
                    currentPeak = MPPPeak(index: i, value: data[i])
                    break
                }
            }
        }
        var valueForCurrentPeak = currentPeak.value
        while startIndex < data.count && startIndex >= 0{
            if Double(abs(data[startIndex])) > peakThreshold {
                if valueForCurrentPeak > 0 && data[startIndex] > 0 && data[startIndex] > valueForCurrentPeak {
                    currentPeak = MPPPeak(index: startIndex, value: data[startIndex])
                    peakThreshold = Double(abs(data[startIndex])) * distanceBetweenPeaksHysteresis
                    valueForCurrentPeak = currentPeak.value
                }
                if valueForCurrentPeak < 0 && data[startIndex] < 0 && data[startIndex] < valueForCurrentPeak {
                    currentPeak = MPPPeak(index: startIndex, value: data[startIndex])
                    peakThreshold = Double(abs(data[startIndex])) * distanceBetweenPeaksHysteresis
                    valueForCurrentPeak = currentPeak.value
                }
                if ((valueForCurrentPeak < 0 && data[startIndex] > 0) || (valueForCurrentPeak > 0 && data[startIndex] < 0)) {
                    distancesBetweenPeaks.append(abs(startIndex - currentPeak.index))
                    peakThreshold = abs(Double(data[startIndex]) * distanceBetweenPeaksHysteresis)
                    currentPeak = MPPPeak(index: startIndex, value: data[startIndex])
                    valueForCurrentPeak = data[startIndex]
                }
            }
            if !reversed {
                startIndex += 1
            }else{
                startIndex -= 1
            }
        }
        //Now that we have the distances, go through the first few (6) to establish the baseline frequency for a zero
        if distancesBetweenPeaks.count > 6 {
            var distanceBetweenZerosAverage = Int(0.04 * Double(distancesBetweenPeaks[0]) + 0.06 * Double(distancesBetweenPeaks[1]) + 0.1 * Double(distancesBetweenPeaks[2]) + 0.16 * Double(distancesBetweenPeaks[3]) + 0.24 * Double(distancesBetweenPeaks[4]) + 0.4 * Double(distancesBetweenPeaks[5]))
            //Decode ones or zeros in base of the average frequency
            var index = 0
            var bits : [Int8] = []
            while index < distancesBetweenPeaks.count {
                let proximityToZero = abs(Int64(distancesBetweenPeaks[index]) - distanceBetweenZerosAverage)
                let proximityToOne = abs(Int64(distancesBetweenPeaks[index]) - distanceBetweenZerosAverage / 2)
                if proximityToOne < proximityToZero {
                    //Got a one
                    bits.append(1)
                    if distancesBetweenPeaks.count > index + 1 {
                        distanceBetweenZerosAverage = distancesBetweenPeaks[index] + distancesBetweenPeaks[index + 1] //Recalculating... (A one has a peak in between)
                    }
                    index += 1
                }else{
                    //Got a zero
                    bits.append(0)
                    distanceBetweenZerosAverage = distancesBetweenPeaks[index] //Recalculating... (A zero does not have a peak in between)
                }
                index += 1
            }
            //Find the semicolon (Track2 start sentinel...)
            var found = false
            var start = 0
            while start < bits.count - 3{
                if bits[start] == 1 && bits[start + 1] == 1 && bits[start + 2] == 0 && bits[start + 3] == 1 {
                    found = true
                    break
                }
                start += 1
            }
            if !found {
                ret = .startSentinelNotFound
            }else{
                // Keep parsing Track2
                while start < bits.count && (start + 5) < bits.count {
                    //Get next character
                    let n = getLRCCharacter(bits, start: start)
                    result += String(UnicodeScalar(Int(n)))
                    
                    //Check the parity bit for the character
            
                    if !LRCParity(bits, start: start) {
                        ret = .parityBitCheckFailed
                        break
                    }
                    
                    //If we're at the track 2 end sentinel, get out
                    if String(UnicodeScalar(Int(n))) == "?" {
                        break
                    }
                    start += 5
                    }
                if ret == .success {
                    start += 5;
                    if bits.count < start + 5 {
                        ret = .unableToPerformLRCCheck
                    }else{
                        //Get the LRC character
                        let n = UInt8(getLRCCharacter(bits, start: start))
                        //Check the LRC character's parity bit
                        if !LRCParity(bits, start: start) {
                            ret = .parityForLRCCheckFailed
                        }else{
                            var chars = [UInt8](count:4, repeatedValue: 0)
                            for i in 0..<result.characters.count{
                                let char = [UInt8](result.utf8)[i]
                                chars[0] = (chars[0] + ((char >> 3) & 0x01)) % 2
                                chars[1] = (chars[1] + ((char >> 2) & 0x01)) % 2
                                chars[2] = (chars[2] + ((char >> 1) & 0x01)) % 2
                                chars[3] = (chars[3] + (char & 0x01)) % 2
                            }
                            //Check the LRC for the hole chunk
                            if chars[3] != (n & 0x01) || chars[2] != ((n >> 1) & 0x01) || chars[1] != ((n >> 2) & 0x01) || chars[0] != ((n >> 3) & 0x01){
                                ret = .LRCCheckFailed
                            }
                        }
                        
                    }
                }
                
            }
        }else{
            ret = .shittyData
        }
        if ret != .success {
            let puntoYComa = result.rangeOfString(";")?.startIndex
            let igual = result.rangeOfString("=")?.startIndex
            if let puntoYComa = puntoYComa, let igual = igual{
                if puntoYComa != result.endIndex {
                    let pan = result.substringWithRange(puntoYComa.advancedBy(1) ..< igual)
                    if performLuhnValidation(pan) {
                        return MPPMagReaderParseResult(code: .successLuhn, data: ";" + pan + "=")
                    }
                }
            }
            return resolveErrorCause(ret, result: result, distances: distancesBetweenPeaks, maxValue: Int64(maxValue))
        }
        return MPPMagReaderParseResult(code: ret, data: result)
    }
    
    private static func getLRCCharacter(bits : [Int8], start : Int) -> Int8{
        var n = CChar(strtoul("0x30", nil, 16))
        n += bits[start]
        n += bits[start + 1] * 2
        n += bits[start + 2] * 4
        n += bits[start + 3] * 8
        return n
    }
    
    private static func LRCParity(bits : [Int8], start : Int) -> Bool{
        var parityCheckSum = 0
        for i in start...start+4 {
            parityCheckSum += Int(bits[i])
        }
        return parityCheckSum % 2 == 1
    }
    
    private static func performLuhnValidation(ccNumber : String) -> Bool{
        if ccNumber.characters.count < 13 {
            return false
        }
        var sum : Int64 = 0
        var alternate = false
        for i in (ccNumber.characters.count - 1).stride(to: 0, by: -1) {
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



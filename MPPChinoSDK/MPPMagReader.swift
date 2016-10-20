//
//  MPPMagReader.swift
//  MPPChinoSDK
//
//  Created by Diego Flores Domenech on 10/18/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class MPPMagReader: NSObject {
    
    enum ActionPerformed {
        case nothing
        case calibration
        case readData
        case processData
    }
    
    private var noiseLevel : Int64 = 0
    private var samplesToWait = Int(44100 * 0.25)
    
    var actionPerformed = ActionPerformed.nothing
    let jackReader = MPPJackReader()
    let operationQueue = NSOperationQueue()
    
    var dataToProcess : [Int64] = []
    var dataRead : [Int64] = []
    var samplesUsedForCalibrate = 0
    var maxValue : Int64 = 0
    
    override init() {
        super.init()
        jackReader.delegate = self
    }
    
    func startReading(){
        actionPerformed = .calibration
        jackReader.startRecording()
    }
    
    func readData(buffer : [Int64]){
        dataRead.appendContentsOf(buffer)
        let bufferSize = dataRead.count
        if bufferSize > 0 && isABufferWithSignal(dataRead) {
            for k in 0..<bufferSize {
                let val = dataRead[k]
                dataToProcess.append(val)
                if abs(val) > maxValue {
                    maxValue = abs(val)
                }
            }
        }
        if !dataToProcess.isEmpty{
            actionPerformed = .processData
        }
        if dataRead.count > 10000 {
            dataRead = []
        }
    }
    
    func processData(){
        var parseResult : MPPMagReaderParseResult?
        parseResult = MPPMagReaderParser.parse(dataToProcess,reversed: false,maxValue: maxValue)
        if parseResult != nil{
            if parseResult!.code != MPPMagStripeResult.success && parseResult!.code != MPPMagStripeResult.successLuhn {
                //por si te pasan la tarjeta al reves
                dataToProcess = dataToProcess.reverse()
                parseResult = MPPMagReaderParser.parse(dataToProcess,reversed: true,maxValue: maxValue)
            }
        }
        print("PARSE RESULT: \(parseResult!.code.description())")
        dataToProcess = []
        dataRead = []
        maxValue = 0
        actionPerformed = .readData
    }
    
    func isABufferWithSignal(buffer : [Int64]) -> Bool{
        var minimumSamples = 300
        for i in 0..<buffer.count {
            if buffer[i] > noiseLevel {
                minimumSamples -= 1
            }
        }
        return minimumSamples < 0
    }
    
}

//MARK: - MPPJackReader delegate

extension MPPMagReader : MPPJackReaderDelegate{
    
    func jackReaderDelegateDidReadData(integerArrayData: [NSNumber]!) {
        var buffer : [Int64] = []
        for data in integerArrayData {
            buffer.append(data.longLongValue)
        }
        switch actionPerformed {
        case .calibration:
            samplesUsedForCalibrate += 1
            if samplesUsedForCalibrate < 300{
                calibrate(buffer, iteration: samplesUsedForCalibrate)
            }else{
                actionPerformed = .readData
            }
        case .readData:
            readData(buffer)
        case .processData:
            processData()
        default:
            print("")
        }
    }
}

//MARK: - Calibration

extension MPPMagReader{
    
    func calibrate(buffer : [Int64],iteration : Int){
        performMicroCalibration(buffer);
        if iteration == 1 {
            noiseLevel = 0;
        }
        if iteration == 299 {
            noiseLevel *= 3;
        }
    }
    
    func performMicroCalibration(buffer : [Int64]){
        let bufferSize = buffer.count
        let divs = 10
        let chunks = bufferSize / divs
        var maxs = [Int64](count: divs, repeatedValue: 0)
        if bufferSize > 0 {
            var from = 0
            for i in 0..<divs {
                from = chunks * i
                while from < (chunks * (i + 1)) - 1 && from < bufferSize{
                    let val = buffer[from]
                    if val > maxs[i] {
                        maxs[i] = val
                    }
                    from += 1
                }
            }
        }
        var prom : Int64 = 0
        for h in 0..<divs{
            prom += maxs[h]
        }
        prom = prom / Int64(divs)
        if noiseLevel == 0{
            noiseLevel = prom
        }else{
            noiseLevel = (prom + noiseLevel) / 2
        }
        print("NOISE: \(noiseLevel)")
    }
}

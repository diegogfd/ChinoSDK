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
    
    private var noiseLevel = 0
    private var samplesToWait = Int(44100 * 0.25)
    
    var actionPerformed = ActionPerformed.nothing
    let jackReader = MPPJackReader()
    
    var dataToProcess : [Int] = []
    
    override init() {
        super.init()
        jackReader.delegate = self
    }
    
    func startReading(){
        actionPerformed = .calibration
        jackReader.startRecording()
    }
    
    func performMicroCalibration(buffer : [Int]){
        let bufferSize = buffer.count
        let divs = 10
        let chunks = bufferSize / divs
        var maxs = [Int](count: divs, repeatedValue: 0)
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
        var prom = 0
        for h in 0..<divs{
            prom += maxs[h]
        }
        prom = prom / divs
        if noiseLevel == 0{
            noiseLevel = prom
        }else{
            noiseLevel = (prom + noiseLevel) / 2
        }
    }
    
    func readData(buffer : [Int]){
        while actionPerformed == .readData{
            let bufferSize = buffer.count
            if bufferSize > 0 {
                var silentSamples = 0
                for k in 0..<bufferSize {
                    let val = buffer[k]
                    dataToProcess.append(val)
                    if val >= noiseLevel || val <= -noiseLevel {
                        silentSamples = 0
                    }else{
                        silentSamples += 1
                    }
                }
                if silentSamples >= samplesToWait {
                    actionPerformed = .processData
                }
            }
        }
    }
    
    func processData(){
        var parseResult : MPPMagReaderParseResult?
        parseResult = MPPMagReaderParser.parse(dataToProcess)
        if parseResult != nil{
            if parseResult!.errorCode != MPPMagStripeResult.success.rawValue && parseResult!.errorCode != MPPMagStripeResult.successLuhn.rawValue {
                dataToProcess = dataToProcess.reverse()
                parseResult = MPPMagReaderParser.parse(dataToProcess)
            }
        }
        dataToProcess = []
    }
    
}

extension MPPMagReader : MPPJackReaderDelegate{
    
    func jackReaderDelegateDidReadData(integerArrayData: [NSNumber]!) {
        var buffer : [Int] = []
        for data in integerArrayData {
            buffer.append(data.integerValue)
        }
        switch actionPerformed {
        case .calibration:
            performMicroCalibration(buffer)
        case .readData:
            readData(buffer)
        case .processData:
            processData()
        default:
            print("")
        }
    }
    
}

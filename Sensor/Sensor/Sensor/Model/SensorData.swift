//
//  SensorData.swift
//  Sensor
//
//  Created by SH-DEV-5021 on 2017/5/25.
//  Copyright © 2017年 SH-DEV-5021. All rights reserved.
//


//保存每次传感器数据的数据结构，包含九个值在17行定义

import Foundation
import CoreMotion

let gravityUnit = -9.81

class SensorData {
    private var ax = 0.0, ay = 0.0, az = 0.0, wx = 0.0, wy = 0.0, wz = 0.0, gx = 0.0, gy = 0.0, gz = 0.0
    
    init(accelaration: CMAcceleration, rotation: CMRotationRate, gravity: CMAcceleration) {
        ax = (accelaration.x + gravity.x ) * gravityUnit
        ay = (accelaration.y + gravity.y ) * gravityUnit
        az = (accelaration.z + gravity.z ) * gravityUnit
        
        wx = rotation.x
        wy = rotation.y
        wz = rotation.z
        
        gx = gravity.x * gravityUnit
        gy = gravity.y * gravityUnit
        gz = gravity.z * gravityUnit
    }
    init() {}
    
    func writeToFile(atPath path: String) {
        let dataString = "\(ax)\r\n\(ay)\r\n\(az)\r\n\(wx)\r\n\(wy)\r\n\(wz)\r\n\(gx)\r\n\(gy)\r\n\(gz)\r\n"
        if FileManager.default.fileExists(atPath: path) {
            guard let fileHandle = FileHandle(forWritingAtPath: path) else {
                print("Fail to write")
                return
            }
            fileHandle.seekToEndOfFile()
            guard let data = dataString.data(using: .utf8, allowLossyConversion: true) else {
                print("Fail to generate data")
                return
            }
            fileHandle.write(data)
        } else {
            try? dataString.write(toFile: path, atomically: true, encoding: .utf8)
        }
    }
}

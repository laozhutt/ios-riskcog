//
//  File.swift
//  Sensor
//
//  Created by SH-DEV-5021 on 2017/5/25.
//  Copyright © 2017年 SH-DEV-5021. All rights reserved.
//
// 这个文件是用来采集传感器数据的Manager类
import Foundation
import CoreMotion

let maxVersionKey       = "max_version"
let resultKey           = "result"

class SensorManager {

//时间间隔0.02s采集一次数据，采集3秒数据
    private(set) var interval: TimeInterval = 0.02
    private(set) var duration: TimeInterval = 3.0
//时间间隔3s，再向服务器通过version询问结果
    private(set) var delay: TimeInterval = 1.5
    
    private lazy var motionManager: CMMotionManager = { CMMotionManager() }()
    
    init(interval: TimeInterval, duration: TimeInterval, delay: TimeInterval) {
        self.interval = interval
        self.duration = duration
        self.delay = delay
    }
    init() {}
    
//获得传感器数据的方法，设置一个时间队列采集3s，0.02s间隔采集
    func getSensorData(completion: @escaping (UserState) -> ()) {
        guard motionManager.isDeviceMotionAvailable else {
            print("Motion not available")
            return
        }
        motionManager.deviceMotionUpdateInterval = interval
        
        let filePath = NSTemporaryDirectory() + Date.timeStampString
        let writeQueue = OperationQueue()
        writeQueue.maxConcurrentOperationCount = 1
        
        Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            self.motionManager.stopDeviceMotionUpdates()
            if let string = try? String(contentsOfFile: filePath) {
                print(string);
            }
            
//申请一个http请求Manager，然后通过服务器获得测试结果并处理，延迟3s再向服务器查询
//post请求包含用户名以及version号
            let testManager = RequestManager(type: .test)
            testManager.filePath = filePath
            testManager.imei = IMEI.shared.value
            do {
                try testManager.request() { jsonData in
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.delay) {
                        try? FileManager.default.removeItem(atPath: filePath)
                        guard let json = jsonData else {
                            return
                        }
                        guard let object = try? JSONSerialization.jsonObject(with: json, options: .allowFragments), let dic = object as? [AnyHashable:Any] else {
                            
                            return
                        }
                        guard let maxVersion = dic[maxVersionKey] as? Int else {
                            print("Invalid version")
                            return
                        }
                        print("\(maxVersion)")
                        let queryManager = RequestManager(type: .query)
                        queryManager.imei = IMEI.shared.value
                        queryManager.version = "\(maxVersion)"
                        do {
                            try queryManager.request() { jsonData in
                                guard let json = jsonData else {
                                    return
                                }
                                guard let object = try? JSONSerialization.jsonObject(with: json, options: []), let dic = object as? [AnyHashable:Any] else {
                                    return
                                }
                                guard let resultString = dic[resultKey] as? String else {
                                    print("Invalid result")
                                    completion(.unknown)
                                    return
                                }
                                let parser = ResultParser(resultString: resultString)
                                completion(parser.userState)
                            }
                        } catch {
                            if let requestError = error as? RequestError {
                                switch requestError {
                                case .invalidIMEI:
                                    break
                                default:
                                    break
                                }
                            }
                        }
                    }
                }
            } catch {
                if let requestError = error as? RequestError {
                    switch requestError {
                    case .invalidIMEI:
                        break
                    default:
                        break
                    }
                }
            }
            
        }
        
        motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
            guard error == nil else {
                print("\(error!)")
                self.motionManager.stopDeviceMotionUpdates()
                return
            }
            guard let motion = motion else {
                print("No motion data")
                return
            }
            let sensorData = SensorData(accelaration: motion.userAcceleration, rotation: motion.rotationRate, gravity: motion.gravity)
            writeQueue.addOperation {
                sensorData.writeToFile(atPath: filePath)
            }
        }
    }
}

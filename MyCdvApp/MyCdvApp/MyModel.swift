import Foundation

class MyModel: NSObject {
    class func test(ax: [Double], ay: [Double], az: [Double], wx: [Double], wy: [Double], wz: [Double], gx: [Double], gy: [Double], gz: [Double]) -> Double {
        var file = Bundle.main.path(forResource: "SensorDemoDataSumTianSit.train.libsvm.model", ofType: nil, inDirectory: "OfflineModel")
        var name = strdup(file)

        var index: [Int32] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61]

        var res : [Float] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61]

        var probs : [Double] = [0, 1, 2]

        var label : Int32 = 5

        let data_len = 10
        let data_cross = 5

        var vax: [Float] = [0,0,0,0,0,0,0,0,0,0]
        var vay: [Float] = [0,0,0,0,0,0,0,0,0,0]
        var vaz: [Float] = [0,0,0,0,0,0,0,0,0,0]
        var vwx: [Float] = [0,0,0,0,0,0,0,0,0,0]
        var vwy: [Float] = [0,0,0,0,0,0,0,0,0,0]
        var vwz: [Float] = [0,0,0,0,0,0,0,0,0,0]
        var vgx: [Float] = [0,0,0,0,0,0,0,0,0,0]
        var vgy: [Float] = [0,0,0,0,0,0,0,0,0,0]
        var vgz: [Float] = [0,0,0,0,0,0,0,0,0,0]

        var sum = 0.0, cnt = ax.count
        for l in stride(from: 0, through: ax.count - data_len, by: data_cross) {
            for j in stride(from : 0 , to: data_len, by: 1) {
                let i = j + l
                vax[j] = Float(ax[i])
                vay[j] = Float(ay[i])
                vaz[j] = Float(az[i])
                vwx[j] = Float(wx[i])
                vwy[j] = Float(wy[i])
                vwz[j] = Float(wz[i])
                vgx[j] = Float(gx[i])
                vgy[j] = Float(gy[i])
                vgz[j] = Float(gz[i])
            }
            output(Int32(vax.count), &vax, &vay,&vaz, &vwx, &vwy, &vwz,&vgx, &vgy,&vgz, &res)
            doClassification(&res,&index, 1, name , &label, &probs , 62)
            sum += Double(label)
        }
        return sum / Double(cnt)
    }
}

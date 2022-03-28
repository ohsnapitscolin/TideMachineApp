//
//  WorldTides.swift
//  TideMachineApp
//
//  Created by Colin Dunn on 3/27/22.
//

import Foundation

let Location = (lon: "41.725040", lat: "-71.324036")

public func fetchTides(date: Date, completion: @escaping (PersistData?) -> Void) {
    let host = "https://www.worldtides.info/api/v3?heights"
    let date = "today"
    let days = "7"
    let lat = Location.lat
    let lon = Location.lon
    let key = "02b04d61-c363-4a63-98af-99f544a0521b"
    
    let url = URL(string: "\(host)&date=\(date)&days=\(days)&lat=\(lat)&lon=\(lon)&key=\(key)")!
    
    URLSession.shared.dataTask(with: url) {(data, response, error) in
        if (error != nil) {
            print(error!.localizedDescription)
            completion(nil)
        }
        
        if (data == nil) {
            print("No data in response!")
            completion(nil)
        }
        
        do{
            let json = try JSONSerialization.jsonObject(
                with: data!, options: .allowFragments) as! [String:Any]
            completion(parseTideData(json: json))
        } catch {
            print(error.localizedDescription)
            completion(nil)
        }
    }.resume()
}
    
func parseTideData(json: [String: Any]?) -> PersistData {
    let heights = json?["heights"] as? [[String: Any]] ?? []
    let station = json?["station"] as! String

    let heightData = heights.map({ (height: [String:Any]) -> HeightData in
        let dt = height["dt"] as! Int
        let height = height["height"] as! Double
        let date = Date(timeIntervalSince1970: Double(dt))
        return HeightData(date: date, height: height)
    })

    return PersistData(tideData: TideData(heights: heightData, station: station))
}

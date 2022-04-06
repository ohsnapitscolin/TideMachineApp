//
//  WorldTides.swift
//  TideMachineApp
//
//  Created by Colin Dunn on 3/27/22.
//

import Foundation

public func fetchTides(date: Date?, completion: @escaping (PersistData?, String?) -> Void) {
    let host = "https://www.worldtides.info/api/v3"
    let request = "heights&timezone"
    let days = "7"
    let lat = Location.lat
    let lon = Location.lon
    let key = "02b04d61-c363-4a63-98af-99f544a0521b"
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-dd"
    
    let requestDate = date != nil ? dateFormatter.string(from: date!) : "today"
    
    let url = URL(string: "\(host)?\(request)&date=\(requestDate)&days=\(days)&lat=\(lat)&lon=\(lon)&key=\(key)")!
    
    URLSession.shared.dataTask(with: url) {(data, response, error) in
        if (error != nil) {
            return completion(nil, error!.localizedDescription)
        }
        
        if (data == nil) {
            return completion(nil, "No data in response!")
        }
        
        do{
            let json = try JSONSerialization.jsonObject(
                with: data!, options: .allowFragments) as! [String:Any]
            
            let error = json["error"] as? String
            if error != nil {
                return completion(nil, error)
            } else {
                return completion(parseTideData(json: json), nil)
            }
        } catch {
            return completion(nil, error.localizedDescription)
        }
    }.resume()
}
    
func parseTideData(json: [String: Any]) -> PersistData? {
    guard let heights = json["heights"] as? [[String: Any]] else {
        debugOutput.append("No heights found in response")
        return nil
    }
    guard let timezone = json["timezone"] as? String else {
        debugOutput.append("No timezone found in response")
        return nil
    }
    
    let station = json["station"] as? String ?? ""
    
    if station == "" {
        debugOutput.append("No station found in response")
    }

    let heightData = heights.map({ (height: [String:Any]) -> HeightData in
        let dt = height["dt"] as! Int
        let height = height["height"] as! Double
        let date = Date(timeIntervalSince1970: Double(dt))
        return HeightData(date: date, height: height)
    })

    return PersistData(tideData: TideData(name: LocationName,
                                          heights: heightData,
                                          station: station,
                                          timezone: timezone))
}

//
//  Persister.swift
//  TideMachineApp
//
//  Created by Colin Dunn on 3/27/22.
//

import Foundation

let BundleIdentifier = "lian.land.TideMachine"
let FileName = "lian.land.TideMachine_v1"

public struct PersistData: Codable {
    var tideData: TideData
    
    func copy() throws -> PersistData {
        let data = try JSONEncoder().encode(self)
        let copy = try JSONDecoder().decode(PersistData.self, from: data)
        return copy
    }
}

class Persister {
    public var data: PersistData! = nil
    
    private var fileUrl: URL! = nil
    private var bundle: Bundle! = nil
    
    init() {
        fileUrl = getDocumentsDirectory().appendingPathComponent("\(FileName).txt")
        bundle = Bundle.init(identifier: BundleIdentifier) ?? Bundle.main

        if (!FileManager.default.fileExists(atPath: fileUrl.path)) {
            reset()
        }

        data = read()
        
        if (data == nil) {
            data = empty()
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func empty() -> PersistData {
        let tideData = TideData(name: "", heights: [], station: "", timezone: "")
        return PersistData(tideData: tideData)
    }

    private func read() -> PersistData? {
        do {
            let stringData = try String(contentsOf: fileUrl, encoding: .utf8)
            let data = stringData.data(using: .utf8)!
            return try JSONDecoder().decode(PersistData.self, from: data)
        } catch {
            print(error)
            return nil
        }
    }

    public func reset() {
        write(data: empty())
    }

    public func write(data: PersistData) {
        do {
            let data = try JSONEncoder().encode(data)
            let stringData = String(data: data, encoding: .utf8)!
            try stringData.write(to: fileUrl, atomically: true, encoding: .utf8)
        } catch {
            print(error)
        }
    }
}

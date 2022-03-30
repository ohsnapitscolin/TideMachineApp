//
//  CustomDate.swift
//  TideMachineApp
//
//  Created by Colin Dunn on 3/27/22.
//

import Foundation

enum Season {
    case Winter
    case Spring
    case Summer
    case Fall
}

enum TimeOfDay  {
    case Morning
    case Day
    case Evening
    case Night
}

let Seasons = [Season.Spring, Season.Summer, Season.Fall, Season.Winter]
let TimesOfDay = [TimeOfDay.Morning, TimeOfDay.Day, TimeOfDay.Evening, TimeOfDay.Night]

let SeasonRanges: [Season:(start: String, end: String)] = [
    Season.Spring: (start: "03-20", end: "06-21"),
    Season.Summer: (start: "06-21", end: "09-22"),
    Season.Fall: (start: "09-22", end: "12-21"),
    Season.Winter: (start: "12-21", end: "03-20")
]

let TimeRanges: [TimeOfDay:(start: String, end: String)] = [
    TimeOfDay.Morning: (start: "05:00", end: "08:30"),
    TimeOfDay.Day: (start: "09:00", end: "16:30"),
    TimeOfDay.Evening: (start: "17:00", end: "20:30"),
    TimeOfDay.Night: (start: "21:00", end: "04:30")
]

class CustomDate {
    private var custom: Bool = false
    
    public var date: Date!
    public var metadata: DateMetadata
    private var _timezone: TimeZone?
    
    init(date: Date?) {
        custom = date != nil
        let initialDate = date ?? Date()
        self.date = initialDate
        
        metadata = getDateData(date: initialDate,
                               timezone: TimeZone.current)
    }
    
    func tick() {
        if custom {
            date = Calendar.current.date(byAdding: .second, value: TestIntervalSeconds, to: date)
        } else {
            date = Date()
        }
        
        metadata = getDateData(date: date, timezone: timezone)
    }
    
    var formattedDate: String {
        get {
            let convertedDate = convert(date: date, timezone: timezone)
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "HH:mm:ss"
            return dateformatter.string(from: convertedDate)
        }
    }
    
    var timezone: TimeZone {
        get { return _timezone ?? TimeZone.current }
        set(timezone) {
            _timezone = timezone
            metadata = getDateData(date: date, timezone: timezone)
        }
    }
}

func convert(date: Date, timezone: TimeZone) -> Date {
    let calendar = Calendar.current
    var components = calendar.dateComponents(in: timezone, from: date)
    components.timeZone = TimeZone.current
    return calendar.date(from: components)!
}

func millisecondsPastMidnight(date: Date) -> Double {
    let startOfDay = Calendar.current.startOfDay(for: date)
    return (date.timeIntervalSince1970 - startOfDay.timeIntervalSince1970) * 1000
}

func daysPastNewYears(date: Date) -> Int {
    let year = Calendar.current.component(.year, from: date)
    let startOfYear = Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1))
    let days = Calendar.current.dateComponents([.day], from: startOfYear!, to: date).day!
    return days < 0 ? 365 + days : days
}

func getDateData(date: Date, timezone: TimeZone) -> DateMetadata {
    let dateFormatter = DateFormatter()
    
    let convertedDate = convert(date: date, timezone: timezone)

    let milliseconds = millisecondsPastMidnight(date: convertedDate)
    let year = Calendar.current.component(.year, from: convertedDate)

    dateFormatter.dateFormat = "HH-mm"
    
    var times: [Double] = TimesOfDay.map {
        millisecondsPastMidnight(date: dateFormatter.date(from: "\(TimeRanges[$0]!.start)")!)
    }
    
    times.append(milliseconds)
    times.sort()
    var timeIndex = times.lastIndex(of: milliseconds)! - 1
    let isMorning = timeIndex < 0;

    let days = daysPastNewYears(date: convertedDate) - (isMorning ? 1 : 0)
    dateFormatter.dateFormat = "YYYY-MM-dd"
    
    var seasons: [Int] = Seasons.map {
        daysPastNewYears(date: dateFormatter.date(from: "\(year)-\(SeasonRanges[$0]!.start)")!)
    }
 
    seasons.append(days)
    seasons.sort()
    var seasonIndex = seasons.lastIndex(of: days)! - 1
    
    seasonIndex = seasonIndex < 0 ? seasons.count - 2 : seasonIndex
    timeIndex = timeIndex < 0 ? times.count - 2 : timeIndex
    
    let lastDayOfSeason = seasons.firstIndex(where: { $0 - 1 == days }) != nil
    let timeOfDay = TimesOfDay[timeIndex]
    
    let nextSeasonIndex = lastDayOfSeason && timeOfDay == TimeOfDay.Night
        ? (seasonIndex + 1) % Seasons.count
        : seasonIndex
    let nextTimeIndex = (timeIndex + 1) % TimesOfDay.count

    return DateMetadata(
        msPastMidnight: milliseconds,
        season: Seasons[seasonIndex],
        nextSeason: Seasons[nextSeasonIndex],
        timeOfDay: timeOfDay,
        nextTimeOfDay: TimesOfDay[nextTimeIndex],
        lastDayOfSeason: lastDayOfSeason)
}

struct DateMetadata {
    let msPastMidnight: Double
    let season: Season
    let nextSeason: Season
    let timeOfDay: TimeOfDay
    let nextTimeOfDay: TimeOfDay
    let lastDayOfSeason: Bool
}

//
//  Serie.swift
//  Series
//
//  Created by Florian Pygmalion on 16/12/2016.
//
//

import Foundation

public class Serie {

    let id: String
    let name: String
    let finished: Bool
    let numberSeason: Int
    let image: String
    let date: String

    public init(id: String, name: String, finished: Bool, numberSeason: Int, image: String, date: String) {
        self.id = id
        self.name = name
        self.finished = finished
        self.numberSeason = numberSeason
        self.image = image
        self.date = date
    }

    public func toDictionary() -> [String: Any] {
        return ["id": id, "name": name, "finished": finished, "numberSeason": numberSeason, "image": image, "date": date]
    }
    
}

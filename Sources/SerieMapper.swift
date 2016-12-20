//
//  SerieMapper.swift
//  Series
//
//  Created by Florian Pygmalion on 19/12/2016.
//
//

import Foundation
import PostgreSQL

public class SerieMapper {

    var postgreConnection: PostgreSQL.Connection!

    public init(database: String, host: String, port: Int32, username: String, password: String) {
        do {
            let connectionString = URL(string: "postgres://\(username):\(password)@\(host):\(port)/\(database)")!
            postgreConnection = try PostgreSQL.Connection(info: .init(connectionString))

            try postgreConnection.open()

            guard postgreConnection.internalStatus == PostgreSQL.Connection.InternalStatus.OK else {
                print("Connection refused")
                return
            }
        } catch {
            print("(\(#function) at \(#line)) - Failed to connect to the server")
        }
    }

    convenience init() {
        self.init()
    }

    public func getAllSeries() throws -> [Serie] {
        var series: [Serie] = []
        let query = "SELECT * FROM serie"

        do {
            let result = try self.postgreConnection.execute(query)

            guard result.status == PostgreSQL.Result.Status.TuplesOK else {
                throw SerieError.Invalid("")
            }

            for i in 0 ..< result.count {
                let id = try String(describing: result[i].data("id"))
                let name = try String(describing: result[i].data("name"))
                let finished = try String(describing: result[i].data("finished")) == "true" ? true : false
                let numberSeason = try String(describing: result[i].data("number_season"))
                let image = try String(describing: result[i].data("image"))
                let date = try String(describing: result[i].data("date"))
                let serie = Serie(id: id, name: name, finished: finished, numberSeason: Int(numberSeason)!, image: image, date: date)
                series.append(serie)
            }
            return series
        } catch {
            throw SerieError.Invalid("")
        }
    }

    public func getSerieWith(_ id: Int) throws -> Serie {
        let query = "SELECT * FROM serie WHERE id = \(id)"

        do {
            let result = try self.postgreConnection.execute(query)

            guard result.status == PostgreSQL.Result.Status.TuplesOK else {
                throw SerieError.Invalid("")
            }
            let id = try String(describing: result[0].data("id"))
            let name = try String(describing: result[0].data("name"))
            let finished = try String(describing: result[0].data("finished")) == "true" ? true : false
            let numberSeason = try String(describing: result[0].data("number_season"))
            let image = try String(describing: result[0].data("image"))
            let date = try String(describing: result[0].data("date"))
            return Serie(id: id, name: name, finished: finished, numberSeason: Int(numberSeason)!, image: image, date: date)
        } catch {
            throw SerieError.IDNotFound("")
        }
    }

    public func addSerie(_ name: String, finished: Bool, numberSeason: Int, image: String, date: String) throws -> Serie {
        let query = "INSERT INTO serie (name, finished, number_season, image, date) VALUES ('\(name)', \(finished), \(numberSeason), \(image), \(date)) RETURNING id"

        do {
            let result = try self.postgreConnection.execute(query)

            guard result.status == PostgreSQL.Result.Status.TuplesOK else {
                throw SerieError.Invalid("")
            }
            let id = try (String(describing: result[0].data("id")))
            return Serie(id: id, name: name, finished: finished, numberSeason: numberSeason, image: image, date: date)
        } catch {
            throw SerieError.Unknown
        }
    }

}

//
//  Controller.swift
//  Series
//
//  Created by Florian Pygmalion on 08/12/2016.
//
//

import Kitura
import SwiftyJSON
import Foundation
import LoggerAPI
import PostgreSQL
import KituraRequest

public class Controller {

    let defaultPostgreHost = "localhost"
    let defaultPostgrePort = Int32(5432)
    let defaultDatabaseName = "series"
    let defaultPostgreUsername = "florianpygmalion"
    let defaultPostgrePassword = ""
    var postgreConnection: PostgreSQL.Connection!
    var serieMapper: SerieMapper!
    let router: Router!

    let port: Int = 8090

    init() {
        router = Router()
        // Mandatory for detect content body
        router.all(middleware: BodyParser())

        serieMapper = SerieMapper(database: defaultDatabaseName, host: defaultPostgreHost, port: defaultPostgrePort, username: defaultPostgreUsername, password: defaultPostgrePassword)

        router.get("/") { _, response, next in
            response.status(.OK).send(json: JSON(["hello" : "world"]))
            next()
        }

        router.get("/series", handler: getSeries)
        router.get("/series/:id", handler: getSerieById)
        router.post("/series", handler: postSerie)
    }

    public func getSeries(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        Log.info("Handling a get to /series")

        var objects: [[String: Any]] = []
        do {
            let series = try serieMapper.getAllSeries()
            for serie in series {
                objects.append(serie.toDictionary())
            }
            let json = JSON(objects)
            response.status(.OK).send(json: json)
            response.headers["Content-Type"] = "application/json"
        }
        catch {
            print("Connection refused")
        }

        next()
    }

    public func getSerieById(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        Log.info("Handling a post to /serie/:id")

        guard let parameterId = request.parameters["id"] else {
            Log.info("No id")
            response.status(.badRequest).send(json: JSON(["error": "No id received"]))
            next()
            return
        }
        guard let id = Int(parameterId) else {
            Log.info("Format id is not conform")
            response.status(.badRequest).send(json: JSON(["error": "Format id is not conform"]))
            next()
            return
        }
        do {
            let serie = try serieMapper.getSerieWith(id).toDictionary()
            let json = JSON(serie)
            response.status(.OK).send(json: json)
        } catch {
            print("Connection refused")
        }
        next()
    }

    public func postSerie(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        Log.info("Handling a post to /series")

        guard let body = request.body else {
            response.status(.badRequest)
            Log.error("No body found in request")
            return
        }

        guard case let .json(json) = body else {
            response.status(.badRequest)
            Log.error("Body contains invalid JSON")
            return
        }

        let name = json["name"].stringValue
        let finished = json["finished"].boolValue
        let numberSeason = json["numberSeason"].intValue
        let image = json["image"].stringValue
        let date = json["date"].stringValue

        do {
            let serie = try serieMapper.addSerie(name, finished: finished, numberSeason: numberSeason, image: image, date: date).toDictionary()
            let json = JSON(serie)
            response.status(.OK).send(json: json)
        } catch {
            print("Connection refused")
        }

        next()
    }

}

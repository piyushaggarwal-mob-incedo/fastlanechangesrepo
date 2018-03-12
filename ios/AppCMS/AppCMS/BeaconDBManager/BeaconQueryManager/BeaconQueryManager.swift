//
//  BeaconQueryManager.swift
//  AppCMS
//
//  Created by  Diksha Goyal on 23/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

let DBNAME = "beaconEvents.sql"
let TABLENAME = "beaconEventTable"
let TABLE_COLUMNS_QUERY = "beaconEventId INTEGER PRIMARY KEY AUTOINCREMENT, aid TEXT,cid TEXT , pfm TEXT , vid TEXT,uid TEXT , profid TEXT , pa TEXT , player TEXT , environment TEXT ,media_type TEXT,tstampoverride TEXT ,stream_id TEXT , dp1 TEXT,dp2 TEXT,dp3 TEXT,dp4 TEXT,dp5 TEXT,ref TEXT,apos TEXT,apod TEXT,vpos TEXT,url TEXT,embedurl TEXT,ttfirstframe TEXT,bitrate TEXT,connectionspeed TEXT,resolutionheight TEXT,resolutionwidth TEXT,bufferhealth TEXT"

class BeaconQueryManager {
    // MARK: - Properties
    private var dbManagerObj: BeaconDBManager?
    
    static let sharedInstance:BeaconQueryManager = {
        let instance = BeaconQueryManager()
        return instance
    }()
    
    init() {
        if dbManagerObj == nil {
            createDBForBeaconEvents()
        }
    }
    
    private func createDBForBeaconEvents() {
        dbManagerObj = BeaconDBManager()
        dbManagerObj?.intializeData(dbFilename: DBNAME, tableName: TABLENAME, tableColumnsQuery:TABLE_COLUMNS_QUERY )
        
    }
    func fetchTheUnsyncronisedBeaconEvents() -> Array<Dictionary<String,String>> {
        let queryToLoadAllData: String = "select * from \(TABLENAME)"
        return dbManagerObj!.loadData(fromDB: queryToLoadAllData) 
    }
    
    //MARK:- Generate Query to insert data in sqlite
    
    func addBeaconEventParameterString(beaconParameterDict: Dictionary<String,String>) {
      let beaconEvent : BeaconEvent = BeaconEvent.init(beaconParameterDict)
        let queryToAddBeaconEvent: String = "insert into \(TABLENAME)  (aid ,cid, pfm , vid,uid , profid , pa  , player , environment ,media_Type,tstampoverride ,stream_id , dp1 ,dp2 ,dp3 ,dp4 ,dp5 ,ref ,apos ,apod ,vpos ,url ,embedurl ,ttfirstframe ,bitrate ,connectionspeed ,resolutionheight ,resolutionwidth ,bufferhealth ) values('\(beaconEvent.aid ?? "")','\(beaconEvent.cid ?? "")','\(beaconEvent.pfm ?? "")','\(beaconEvent.vid ?? "")','\(beaconEvent.uid ?? "")','\(beaconEvent.profid ?? "")','\(beaconEvent.pa ?? "")','\(beaconEvent.player ?? "")','\(beaconEvent.environment ?? "")','\(beaconEvent.media_type ?? "")','\(beaconEvent.tstampoverride ?? "")','\(beaconEvent.stream_id ?? "")','\(beaconEvent.dp1 ?? "")','\(beaconEvent.dp2 ?? "")','\(beaconEvent.dp3 ?? "")','\(beaconEvent.dp4 ?? "")','\(beaconEvent.dp5 ?? "")','\(beaconEvent.ref ?? "")','\(beaconEvent.apos ?? "")','\(beaconEvent.apod ?? "")','\(beaconEvent.vpos ?? "")','\(beaconEvent.url ?? "")','\(beaconEvent.embedurl ?? "")','\(beaconEvent.ttfirstframe ?? "")','\(beaconEvent.bitrate ?? "")','\(beaconEvent.connectionspeed ?? "")','\(beaconEvent.resolutionheight ?? "")','\(beaconEvent.resolutionwidth ?? "")','\(beaconEvent.bufferhealth ?? "")')"
        dbManagerObj?.execute(queryToAddBeaconEvent)
        if dbManagerObj?.affectedRows == 0 {
            //  DebugLog("BEACON-> Failed to update DB after adding an event!")
        }
        else {
            // DebugLog("BEACON-> Added Beacon Event to DB successfully!")
        }
    }
    
    //MARK:- Generate Query to remove data from sqlite
    func removeBeaconEventFromTheBeaconDB() {
        let queryToRemoveBeaconEvent: String = "delete from \(TABLENAME)"
        dbManagerObj?.execute(queryToRemoveBeaconEvent)
        if dbManagerObj?.affectedRows == 0 {
            //DebugLog("BEACON-> Failed to update DB after deleting an event!")
        }
        else {
            //DebugLog("BEACON-> Removed Beacon Event from DB successfully!")
        }
    }

  }

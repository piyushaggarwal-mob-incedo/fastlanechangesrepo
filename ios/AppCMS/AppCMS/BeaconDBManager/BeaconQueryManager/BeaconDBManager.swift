//
//  BeaconDBManager.swift
//  AppCMS
//
//  Created by  Diksha Goyal on 23/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation


class BeaconDBManager {
    /*!
     * @brief Path the documents directory.
     */
    var documentsDirectory: String = ""
    /*!
     * @brief Name of the database file.
     */
    var databaseFilename: String = ""
    /*!
     * @brief Results fetched after running the query.
     */
    var arrResults = [Any]()
    var results:Array<Dictionary<String,String>>=[]
    var arrColumnNames = [Any]()
    var affectedRows : Int = 01
    var lastInsertedRowID : Double  = 01
    
    func intializeData( dbFilename: String, tableName: String,  tableColumnsQuery: String)  {
        // Set the documents directory path to the documentsDirectory property.
        let paths: [String] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        documentsDirectory = paths[0]
        // Keep the database filename.
        databaseFilename = dbFilename
        // Create database file in the documents directory if necessary.
        createDB(dbFileName: dbFilename,tableName: tableName,tableColumnsQuery: tableColumnsQuery)
    }
    
    func createDB(dbFileName: String, tableName: String, tableColumnsQuery: String) {
        //Build the path to keep the database
        let _database: String = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(dbFileName).absoluteString
        let fileMngr = FileManager.default
        //Check if file already exists. If yes, do not create new.
        if fileMngr.fileExists(atPath: _database) == false {
            // Create a sqlite object.
            var _DB: OpaquePointer?
            let dbpath = _database.utf8
            if sqlite3_open(_database, &_DB) == SQLITE_OK {
                var errorMassage:String = ""
                if let error = sqlite3_errmsg(_DB){
                    errorMassage = String(cString: error)
                }
                let sql_statement = "CREATE TABLE IF NOT EXISTS \(tableName) (\(tableColumnsQuery))"
                if sqlite3_exec(_DB, sql_statement, nil, nil, nil) != SQLITE_OK {
                    print("error creating table: \(errorMassage)")
                }
                sqlite3_close(_DB)
            }
            else {
                print("Error to open/create the table")
            }
        }
    }
    
   private func runQuery(_ query: String, isQueryExecutable queryExecutable: Bool) {
        // Create a sqlite object.
        var sqlite3Database: OpaquePointer?
        // Set the database file path.
        let databasePath: String = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(databaseFilename).absoluteString
        // Initialize the results array.
        if !results.isEmpty {
            results.removeAll()
            // arrResults = nil
        }
        arrResults = [Any]()
        // Initialize the column names array.
        if !arrColumnNames.isEmpty {
            arrColumnNames.removeAll()
            //arrColumnNames = nil
        }
        //var result:Array<Dictionary<String,AnyObject>>=[]
        arrColumnNames = [Any]()
        // Open the database.
        //  let openDatabaseResult: Bool = sqlite3_open(databasePath, &sqlite3Database)
        if sqlite3_open(databasePath, &sqlite3Database) == SQLITE_OK {
            // Declare a sqlite3_stmt object in which will be stored the query after having been compiled into a SQLite statement.
            var compiledStatement: OpaquePointer?
            // Load all data from database to memory.
            //  let prepareStatementResult: Bool = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, nil)
            if sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, nil) == SQLITE_OK {
                // Check if the query is non-executable.
                if !queryExecutable {
                    // In this case data must be loaded from the database.
                    // Declare an array to keep the data for each fetched row.
                    var arrDataRow = [String : AnyObject]()
                    var dict=Dictionary<String, String>()
                    // Loop through the results and add them to the results array row by row.
                    while sqlite3_step(compiledStatement) == SQLITE_ROW {
                        // Initialize the mutable array that will contain the data of a fetched row.
                        // arrDataRow = [String : AnyObject]
                        // Get the total number of columns.
                        let totalColumns: Int = Int(sqlite3_column_count(compiledStatement))
                        // Go through all columns and fetch each column data.
                        for i in 0..<totalColumns {
                            // Convert the column data to text (characters).
                            let strF=sqlite3_column_name(compiledStatement, Int32(i))
                            let strV = sqlite3_column_text(compiledStatement, Int32(i))
                            
                            let rFiled:String=String(cString: strF!)
                            let rValue:String=String(cString: strV!)
                            //let rValue=String(cString: UnsafePointer<Int8>(strV!))
                            dict[rFiled] = rValue as String?
                            // result.insert(mod, at: result.count)                            //let
                        }
                        results.insert(dict , at: results.count)
                        
                    }
                    // Store each fetched data row in the results array, but first check if there is actually data.
                }
                    
                else {
                    // This is the case of an executable query (insert, update, ...).
                    // Execute the query.
                    if SQLITE_DONE == sqlite3_step(compiledStatement) {
                        // Keep the affected rows.
                        affectedRows = Int(sqlite3_changes(sqlite3Database))
                        // Keep the last inserted row ID.
                        //lastInsertedRowID = Double(sqlite3_last_insert_rowid(sqlite3Database))
                    }
                    else {
                        // If could not execute the query show the error message on the debugger.
                        print("DB Error: \(sqlite3_errmsg(sqlite3Database))")
                    }
                }
                
            }
            sqlite3_finalize(compiledStatement)
        }
        
        sqlite3_close(sqlite3Database)
    }
    
    func loadData(fromDB query: String) -> Array<Dictionary<String,String>> {
        // Run the query and indicate that is not executable.
        // The query string is converted to a char* object.
        runQuery(query, isQueryExecutable: false)
        // Returned the loaded results.
        return (results)
    }
    
    func execute(_ query: String) {
        // Run the query and indicate that is executable.
        runQuery(query, isQueryExecutable: true)
    }
}

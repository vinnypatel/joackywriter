


//80491442
import Foundation
import SQLite3

class DBHelper
{
    public static let shared = DBHelper.init()
//    class func sharedAppDelegate() -> DBHelper{
//                return UIApplication.shared.delegate as! AppDelegate
//            }
    init()
    {
        db = openDatabase()
       // createTable(withName: "TABLE_CHOICE")
       // createTable(withName: "TABLE_CORE_CHOICE")
        // createTableCore()
    }
    
    let dbPath: String = "myDb.sqlite"
    var db:OpaquePointer?
    func openDatabase() -> OpaquePointer?
    {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK
        {
            print("error opening database")
            return nil
        }
        else
        {
            print("Successfully opened connection to database at \(dbPath)")
            return db
        }
    }
    
    
    func getCategoryIDForSuggestionWords(withText: String, strColumn: String) -> [Choices]{
        
        //let query = "SELECT * FROM TABLE_CHOICE WHERE sWord LIKE '%\(withText)%';"
        let query = "SELECT * FROM TABLE_CHOICE WHERE \(strColumn) LIKE '%\(withText)%';"
        var queryStatement: OpaquePointer? = nil
        var psns : [Choices] = []
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                let parentId = sqlite3_column_int(queryStatement, 1)
                let caption = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let intShowInMessageBox = sqlite3_column_int(queryStatement, 3)
                let imgPath = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let recordingPath = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                let wordType = String(describing: String(cString: sqlite3_column_text(queryStatement, 6)))
                let color = String(describing: String(cString: sqlite3_column_text(queryStatement, 7)))
                let moreWords = String(describing: String(cString: sqlite3_column_text(queryStatement, 8)))
                let isCategory = sqlite3_column_int(queryStatement, 9)
                var sWord = ""
                let isImageHasText = sqlite3_column_int(queryStatement, 11)
                if sqlite3_column_text(queryStatement, 10) != nil {
                    sWord = String(describing: String(cString: sqlite3_column_text(queryStatement, 10)))
                }
                
                var wt: WordType!
                
                switch wordType {
                case "Noun":
                    wt = .Noun
                    break
                    
                case "Verb":
                    wt = .Verb
                    break
                    
                case "Descriptive":
                    wt = .Descriptive
                    
                    break
                case "Phrase":
                    wt = .Phrase
                    break
                    
                case "Others":
                    wt = .Others
                    break
                    
                default:
                    wt = .Noun
                    break
                    
                }
                
                psns.append(Choices(id: Int(id), parentId: Int(parentId), caption: caption, showInMessageBox: intShowInMessageBox == 1 ? true : false, imgPath: imgPath, recordingPath: recordingPath, wordType: wt, color: color, moreWords:moreWords, isCategory: isCategory == 1 ? true : false, sWord: sWord, isImageHasText: isImageHasText == 1 ? true : false))
                //                psns.append(Choices(id : id, parentId : parentId, caption : caption, showInMessageBox : intShowInMessageBox == 1 ? true : false, imgPath: imgPath, recordingPath: recordingPath, wordType: wordType, color: color))
                print("Query Result:")
                // print("\(id) | \(name) | \(year)")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        
        debugPrint(psns.count)
        
        return psns
    }
    
    func createTable(withName name:String) {
        let createTableString = "CREATE TABLE IF NOT EXISTS \(name) (id INTEGER PRIMARY KEY,parentId INTEGER,caption TEXT, showInMessageBox INT, imgPath TEXT, recordingPath TEXT, wordType CHAR(10), color CHAR(10), moreWords TEXT, isCategory INT);" //, sWord TEXT
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("person table created.")
            } else {
                print("person table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
        
        if !tableHasColumn(db: db!, tableName: name, columnName: "sWord") {
            //ALTER TABLE equipment ADD COLUMN location text;
            
            addColumn(db: db!, tableName: name, columnNameToAdd: "sWord", withDataType: "TEXT") //suggestion
            
        }
        
        if !tableHasColumn(db: db!, tableName: name, columnName: "isImageHasText") {
            
            addColumn(db: db!, tableName: name, columnNameToAdd: "isImageHasText", withDataType: "INT") //suggestion
            
        }
        
        
    }
    
    
    

    private func addColumn(db: OpaquePointer, tableName: String, columnNameToAdd: String, withDataType: String) {
    
    var tableColumnsQueryStatement: OpaquePointer? = nil
    if sqlite3_prepare_v2(db, "ALTER TABLE \(tableName) ADD COLUMN \(columnNameToAdd) \(withDataType);",
                        -1,
                        &tableColumnsQueryStatement,
                        nil) == SQLITE_OK {

        while (sqlite3_step(tableColumnsQueryStatement) == SQLITE_ROW) {

            let queryResultCol1 = sqlite3_column_text(tableColumnsQueryStatement, 1)
            let currentColumnName = String(cString: queryResultCol1!)

        }
    }
    
}

private func tableHasColumn(db: OpaquePointer, tableName: String, columnName: String) -> Bool {

        var retVal = false

        var tableColumnsQueryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, "PRAGMA table_info(\(tableName));",
                            -1,
                            &tableColumnsQueryStatement,
                            nil) == SQLITE_OK {

            while (sqlite3_step(tableColumnsQueryStatement) == SQLITE_ROW) {

                let queryResultCol1 = sqlite3_column_text(tableColumnsQueryStatement, 1)
                let currentColumnName = String(cString: queryResultCol1!)

                if currentColumnName == columnName {
                    retVal = true
                    break
                }
            }
        }

        return retVal
}

    
    func insert(id : Int, parentId : Int, caption : String, showInMessageBox : Bool, imgPath: String, recordingPath: String, wordType: String, color: String, moreWords: String, isCategory: Bool, sWord: String, isImageHasText: Int, tableName: String) -> Bool
    {
        var isSuccess = false
        let choices = read()
        for p in choices
        {
            if p.id == id
            {
                return isSuccess
            }
        }
        
        let insertStatementString = "INSERT INTO \(tableName)(id, parentId, caption, showInMessageBox, imgPath, recordingPath, wordType, color, moreWords, isCategory, sWord, isImageHasText) VALUES(NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(insertStatement, 1, Int32(parentId))
            sqlite3_bind_text(insertStatement, 2, (caption as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 3, Int32(showInMessageBox ? 1 : 0))
            sqlite3_bind_text(insertStatement, 4, (imgPath as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, (recordingPath as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 6, (wordType as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 7, (color as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 8, (moreWords as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 9, Int32(isCategory ? 1 : 0))
            sqlite3_bind_text(insertStatement, 10, (sWord as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 11, Int32(isImageHasText))
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
                isSuccess = true
            } else {
                debugPrint("\(sqlite3_errmsg)")
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
        
        return isSuccess
    }
    
    //    func insertIntoCore(id : Int, parentId : Int, caption : String, showInMessageBox : Bool, imgPath: String, recordingPath: String, wordType: String, color: String, moreWords: String, isCategory: Bool) -> Bool
    //    {
    //        var isSuccess = false
    //        let choices = read()
    //        for p in choices
    //        {
    //            if p.id == id
    //            {
    //                return isSuccess
    //            }
    //        }
    //
    //        let insertStatementString = "INSERT INTO TABLE_CHOICE(id, parentId, caption, showInMessageBox, imgPath, recordingPath, wordType, color, moreWords, isCategory) VALUES(NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
    //        var insertStatement: OpaquePointer? = nil
    //        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
    //
    //            sqlite3_bind_int(insertStatement, 1, Int32(parentId))
    //            sqlite3_bind_text(insertStatement, 2, (caption as NSString).utf8String, -1, nil)
    //            sqlite3_bind_int(insertStatement, 3, Int32(showInMessageBox ? 1 : 0))
    //            sqlite3_bind_text(insertStatement, 4, (imgPath as NSString).utf8String, -1, nil)
    //            sqlite3_bind_text(insertStatement, 5, (recordingPath as NSString).utf8String, -1, nil)
    //            sqlite3_bind_text(insertStatement, 6, (wordType as NSString).utf8String, -1, nil)
    //            sqlite3_bind_text(insertStatement, 7, (color as NSString).utf8String, -1, nil)
    //            sqlite3_bind_text(insertStatement, 8, (moreWords as NSString).utf8String, -1, nil)
    //            sqlite3_bind_int(insertStatement, 9, Int32(isCategory ? 1 : 0))
    //
    //            if sqlite3_step(insertStatement) == SQLITE_DONE {
    //                print("Successfully inserted row.")
    //                isSuccess = true
    //            } else {
    //                print("Could not insert row.")
    //            }
    //        } else {
    //            print("INSERT statement could not be prepared.")
    //        }
    //        sqlite3_finalize(insertStatement)
    //
    //        return isSuccess
    //    }
    
    func read(parentID:Int, withTableName name: String) -> [Choices] {
        let queryStatementString = "SELECT * FROM \(name) WHERE parentId == \(parentID);"
        var queryStatement: OpaquePointer? = nil
        var psns : [Choices] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                let parentId = sqlite3_column_int(queryStatement, 1)
                let caption = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let intShowInMessageBox = sqlite3_column_int(queryStatement, 3)
                let imgPath = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let recordingPath = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                let wordType = String(describing: String(cString: sqlite3_column_text(queryStatement, 6)))
                let color = String(describing: String(cString: sqlite3_column_text(queryStatement, 7)))
                let moreWords = String(describing: String(cString: sqlite3_column_text(queryStatement, 8)))
                let isCategory = sqlite3_column_int(queryStatement, 9)
                var sWord = ""
                if sqlite3_column_text(queryStatement, 10) != nil {
                    sWord = String(describing: String(cString: sqlite3_column_text(queryStatement, 10)))
                }
                let isImageHasText = sqlite3_column_int(queryStatement, 11)
                var wt: WordType!
                
                switch wordType {
                case "Noun":
                    wt = .Noun
                    break
                    
                case "Verb":
                    wt = .Verb
                    break
                    
                case "Descriptive":
                    wt = .Descriptive
                    
                    break
                case "Phrase":
                    wt = .Phrase
                    break
                    
                case "Others":
                    wt = .Others
                    break
                    
                default:
                    wt = .Noun
                    break
                    
                }
                
                psns.append(Choices(id: Int(id), parentId: Int(parentId), caption: caption, showInMessageBox: intShowInMessageBox == 1 ? true : false, imgPath: imgPath, recordingPath: recordingPath, wordType: wt, color: color, moreWords:moreWords, isCategory: isCategory == 1 ? true : false, sWord: sWord, isImageHasText: isImageHasText == 1 ? true : false))
                //                psns.append(Choices(id : id, parentId : parentId, caption : caption, showInMessageBox : intShowInMessageBox == 1 ? true : false, imgPath: imgPath, recordingPath: recordingPath, wordType: wordType, color: color))
                print("Query Result:")
                // print("\(id) | \(name) | \(year)")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return psns
    }
    
    func read() -> [Choices] {
        let queryStatementString = "SELECT * FROM TABLE_CHOICE"
        var queryStatement: OpaquePointer? = nil
        var psns : [Choices] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                let parentId = sqlite3_column_int(queryStatement, 1)
                let caption = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let intShowInMessageBox = sqlite3_column_int(queryStatement, 3)
                let imgPath = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let recordingPath = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                let wordType = String(describing: String(cString: sqlite3_column_text(queryStatement, 6)))
                let color = String(describing: String(cString: sqlite3_column_text(queryStatement, 7)))
                let moreWords = String(describing: String(cString: sqlite3_column_text(queryStatement, 8)))
                let isCategory = sqlite3_column_int(queryStatement, 9)
                var sWord = ""
                if sqlite3_column_text(queryStatement, 10) != nil {
                        
                    sWord = String(describing: String(cString: sqlite3_column_text(queryStatement, 10)))
                }
                let isImageHasText = sqlite3_column_int(queryStatement, 11)
                var wt: WordType!
                
                switch wordType {
                case "Noun":
                    wt = .Noun
                    break
                    
                case "Verb":
                    wt = .Verb
                    break
                    
                case "Descriptive":
                    wt = .Descriptive
                    
                    break
                case "Phrase":
                    wt = .Phrase
                    break
                    
                case "Others":
                    wt = .Others
                    break
                    
                default:
                    wt = .Noun
                    break
                    
                }
                
                psns.append(Choices(id: Int(id), parentId: Int(parentId), caption: caption, showInMessageBox: intShowInMessageBox == 1 ? true : false, imgPath: imgPath, recordingPath: recordingPath, wordType: wt, color: color, moreWords:moreWords, isCategory: isCategory == 1 ? true : false, sWord: sWord, isImageHasText: isImageHasText == 1 ? true : false))
                //                psns.append(Choices(id : id, parentId : parentId, caption : caption, showInMessageBox : intShowInMessageBox == 1 ? true : false, imgPath: imgPath, recordingPath: recordingPath, wordType: wordType, color: color))
               // print("Query Result:")
                // print("\(id) | \(name) | \(year)")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return psns
    }
    
    func deleteByID(id:Int, fromTable tableName: String) {
        let deleteStatementStirng = "DELETE FROM \(tableName) WHERE Id = ?;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(id))
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                debugPrint("\(sqlite3_errmsg)")
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }
    
    func updateById(id : Int, parentId : Int, caption : String, showInMessageBox : Bool, imgPath: String, recordingPath: String, wordType: String, color: String, moreWords: String, isCategory: Bool, sWord: String, isImageHasText: Int, tableName: String) -> Bool {
        
        var isSuccess = false
       // let deleteStatementStirng = "DELETE FROM \(tableName) WHERE Id = ?;"
        let udpateStatementString = "UPDATE \(tableName) SET parentId = '\(parentId)', caption = '\(caption)', showInMessageBox = '\(showInMessageBox == true ? 1 : 0)', imgPath = '\(imgPath)' , recordingPath = '\(recordingPath)', wordType = '\(wordType)', color = '\(color)', moreWords = '\(moreWords)', isCategory = '\(isCategory ? 1 : 0)', sWord = '\(sWord)', isImageHasText = '\(isImageHasText)' WHERE id = \(id);" //"UPDATE \(tableName) SET parentId = '\(parentId)' WHERE id = \(id);"//"INSERT INTO \(tableName)(id, parentId, caption, showInMessageBox, imgPath, recordingPath, wordType, color, moreWords, isCatego∫ry) VALUES(NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        //"UPDATE \(tableName) SET parentId = '\(parentId)', caption = '\(caption)', showInMessageBox = '\(showInMessageBox == true ? 1 : 0)', imgPath = '\(imgPath)' , recordingPath = '\(recordingPath)', wordType = '\(wordType)', color = '\(color)', moreWords = '\(moreWords)', isCategory = '\(isCategory ? 1 : 0)', sWord = '\(sWord)' WHERE id = \(id);"
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, udpateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            
            //            sqlite3_bind_int(insertStatement, 1, Int32(parentId))
            //            sqlite3_bind_text(insertStatement, 2, (caption as NSString).utf8String, -1, nil)
            //            sqlite3_bind_int(insertStatement, 3, Int32(showInMessageBox ? 1 : 0))
            //            sqlite3_bind_text(insertStatement, 4, (imgPath as NSString).utf8String, -1, nil)
            //            sqlite3_bind_text(insertStatement, 5, (recordingPath as NSString).utf8String, -1, nil)
            //            sqlite3_bind_text(insertStatement, 6, (wordType as NSString).utf8String, -1, nil)
            //            sqlite3_bind_text(insertStatement, 7, (color as NSString).utf8String, -1, nil)
            //            sqlite3_bind_text(insertStatement, 8, (moreWords as NSString).utf8String, -1, nil)
            //            sqlite3_bind_int(insertStatement, 9, Int32(isCategory ? 1 : 0))
            var updateStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, udpateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
                //sqlite3_bind_int(deleteStatement, 1, Int32(id))
                if sqlite3_step(updateStatement) == SQLITE_DONE {
                    print("Successfully updated row.")
                    isSuccess = true
                } else {
                    debugPrint("\(sqlite3_errmsg)")
                    print("Could not INSERT row.")
                }
            } else {
                print("DELETE statement could not be prepared")
            }
            sqlite3_finalize(updateStatement)
        }
        
        return isSuccess
    }
    
}

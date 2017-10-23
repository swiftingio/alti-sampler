import CoreData

enum Field: String {
    case timestamp, json
}

class Exporter {
    let context: NSManagedObjectContext
    let filemgr = FileManager.default
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    let encoder = JSONEncoder()
    init(context: NSManagedObjectContext) {
        self.context = context
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    func allRecordings() throws -> [String] {
        let request: NSFetchRequest<Recording> = NSFetchRequest(entityName: String(describing: Recording.self))
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        let recordings: [Recording] = try context.fetch(request)
        let strings: [String] = recordings.map { $0.json ?? "" }.filter { $0 != "" }
        return strings
    }
    
    func saveAsPlistToDocuments() throws -> String? {
        let recordings = try allRecordings()
        let filePath = documentsPath.appendingPathComponent("\(Date()).plist")
        _ = filemgr.createFile(atPath: filePath, contents: nil, attributes: nil)
        let saved = (recordings as NSArray).write(toFile: filePath, atomically: true)
        return saved ? filePath : nil
    }
    
    func allJSONRecordings() throws -> String {
        let recordings = try allRecordings()
        let json = "[\(recordings.joined(separator: ","))]"
        return json
    }
    
    func save(_ samples: [Sample], outputFormatting: JSONEncoder.OutputFormatting = JSONEncoder.OutputFormatting(rawValue: 0)) {
        guard !samples.isEmpty else { return }
        do {
            encoder.outputFormatting = outputFormatting
            let data = try encoder.encode(samples)
            let json = String(bytes: data, encoding: .utf8)
            let entity = NSEntityDescription.insertNewObject(forEntityName: "Recording", into: context)
            entity.setValue(json, forKey: Field.json.rawValue)
            entity.setValue(Date(), forKey: Field.timestamp.rawValue)
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func json(from sample: Sample, outputFormatting: JSONEncoder.OutputFormatting = .prettyPrinted) -> String? {
        do {
            encoder.outputFormatting = outputFormatting
            let data = try encoder.encode(sample)
            let json = String(bytes: data, encoding: .utf8)
            return json
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

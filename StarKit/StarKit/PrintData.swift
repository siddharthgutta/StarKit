
import Foundation

public enum TemplateError: ErrorType {
    case FileNotFound
    case FileDataToStringConversion
    case StringToDataConversion
}

public struct PrintData {
    
    public let dictionary: [String: String]
    public let filePath: String
    
    public init(dictionary: [String: String], filePath: String) {
        self.dictionary = dictionary
        self.filePath = filePath
    }
    
    func rawData() throws -> NSData {
        guard let fileData = NSFileManager.defaultManager().contentsAtPath(filePath) else {
            throw TemplateError.FileNotFound
        }
        guard let fileDataString = NSMutableString(data: fileData, encoding: NSUTF8StringEncoding) else {
            throw TemplateError.FileDataToStringConversion
        }
        
        for (key, value) in dictionary {
            fileDataString.replaceOccurrencesOfString(key, withString: value, options: .CaseInsensitiveSearch, range: NSMakeRange(0, fileDataString.length))
        }
        
        guard let unparsedData = fileDataString.dataUsingEncoding(NSUTF8StringEncoding) else {
            throw TemplateError.StringToDataConversion
        }
        
        let parser = TemplateParser()
        let parsedData = parser.parse(unparsedData)
        
        return parsedData
    }
    
}

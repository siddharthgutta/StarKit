
import Foundation

enum TemplateElement: String {
    case Print = "print"
    
    case AlignLeft = "left"
    case AlignCenter = "center"
    case AlignRight = "right"

    case NewLine = "newline"
    case Tab = "tab"
    
    case Bold = "bold"
    case Underline = "underline"
    case Upperline = "upperline"
    case Large = "large"
    case InvertColor = "invertcolor"

    case OpenDrawer1 = "opendrawer1"
    case OpenDrawer2 = "opendrawer2"
}

class TemplateParser: NSObject, NSXMLParserDelegate {
    
    private var parsedData = NSMutableData()
    
    func parse(data: NSData) -> NSData {
        parsedData = NSMutableData()
        
        let parser = NSXMLParser(data: data)
        parser.delegate = self
        parser.parse()
        
        /*
        appendDataFromString("Test\n")
        parsedData.appendBytes(PrinterCommand.alignLeftCommand, length: 4)
        appendDataFromString("Left\n")
        parsedData.appendBytes(PrinterCommand.alignCenterCommand, length: 4)
        appendDataFromString("Center\n")
        parsedData.appendBytes(PrinterCommand.alignRightCommand, length: 4)
        appendDataFromString("Right")
        parsedData.appendBytes(PrinterCommand.partialCutCommand, length: 3)
        */

        return parsedData
    }
    
    private func appendBytes(bytes: [Byte]?) {
        if let bytes = bytes {
            parsedData.appendBytes(bytes, length: bytes.count)
        }
    }
    
    private func appendDataFromString(string: String) {
        if let data = string.dataUsingEncoding(NSASCIIStringEncoding) {
            parsedData.appendData(data)
        }
    }
    
    // MARK: - NSXMLParserDelegate
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        let element = TemplateElement(rawValue: elementName)
        
        switch element! {
        case .AlignCenter:
            appendBytes(PrinterCommand.alignCenterCommand)
        case .AlignLeft:
            appendBytes(PrinterCommand.alignLeftCommand)
        case .AlignRight:
            appendBytes(PrinterCommand.alignRightCommand)
        case .Bold:
            appendBytes(PrinterCommand.boldStartCommand)
        case .InvertColor:
            appendBytes(PrinterCommand.invertedColorStartCommand)
        case .Large:
            appendBytes(PrinterCommand.largeTextStartCommand)
        case .NewLine:
            appendBytes(PrinterCommand.newLineCommand)
        case .OpenDrawer1:
            appendBytes(PrinterCommand.openDrawer1Command)
        case .OpenDrawer2:
            appendBytes(PrinterCommand.openDrawer2Command)
        case .Print:
            appendBytes(PrinterCommand.alignLeftCommand)
        case .Tab:
            appendBytes(PrinterCommand.tabCommand)
        case .Underline:
            appendBytes(PrinterCommand.underlineStartCommand)
        case .Upperline:
            appendBytes(PrinterCommand.upperlineStartCommand)
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        let cleanedString = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if !cleanedString.isEmpty {
            let mutableString = NSMutableString(string: string)
            
            let newLineCommandString = String(data: NSData(bytes: PrinterCommand.newLineCommand, length: PrinterCommand.newLineCommand.count), encoding: NSASCIIStringEncoding)!
            mutableString.replaceOccurrencesOfString("\\n", withString: newLineCommandString, options: [], range: NSMakeRange(0, mutableString.length))
            
            let tabCommandString = String(data: NSData(bytes: PrinterCommand.tabCommand, length: PrinterCommand.tabCommand.count), encoding: NSASCIIStringEncoding)!
            mutableString.replaceOccurrencesOfString("\\t", withString: tabCommandString, options: [], range: NSMakeRange(0, mutableString.length))
            
            appendDataFromString(mutableString as String)
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let element = TemplateElement(rawValue: elementName)
        
        switch element! {
        case .Bold:
            appendBytes(PrinterCommand.boldEndCommand)
        case .InvertColor:
            appendBytes(PrinterCommand.invertedColorEndCommand)
        case .Large:
            appendBytes(PrinterCommand.largeTextEndCommand)
        case .Print:
            appendBytes(PrinterCommand.partialCutCommand)
        case .Underline:
            appendBytes(PrinterCommand.underlineEndCommand)
        case .Upperline:
            appendBytes(PrinterCommand.upperlineEndCommand)
        default:
            appendBytes(nil)
        }
    }
    
}
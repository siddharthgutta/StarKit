
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
    
    private let parsedData = NSMutableData()
    
    func parse(data: NSData) -> NSData {
        let parser = NSXMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return parsedData
    }
    
    private func appendDataFromString(string: String) {
        if let data = string.dataUsingEncoding(NSASCIIStringEncoding) {
            parsedData.appendData(data)
        }
    }
    
    // MARK: - NSXMLParserDelegate
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        let bytes: [Byte]
        
        let element = TemplateElement(rawValue: elementName)
        switch element! {
        case .AlignCenter:
            bytes = PrinterCommand.alignCenterCommand
        case .AlignLeft:
            bytes = PrinterCommand.alignLeftCommand
        case .AlignRight:
            bytes = PrinterCommand.alignRightCommand
        case .Bold:
            bytes = PrinterCommand.boldStartCommand
        case .InvertColor:
            bytes = PrinterCommand.invertedColorStartCommand
        case .Large:
            bytes = PrinterCommand.largeTextStartCommand
        case .NewLine:
            bytes = PrinterCommand.newLineCommand
        case .OpenDrawer1:
            bytes = PrinterCommand.openDrawer1Command
        case .OpenDrawer2:
            bytes = PrinterCommand.openDrawer2Command
        case .Print:
            bytes = []
        case .Tab:
            bytes = PrinterCommand.tabCommand
        case .Underline:
            bytes = PrinterCommand.underlineStartCommand
        case .Upperline:
            bytes = PrinterCommand.upperlineStartCommand
        }
        
        parsedData.appendBytes(bytes, length: bytes.count)
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
        let bytes: [Byte]
        
        let element = TemplateElement(rawValue: elementName)
        switch element! {
        case .Bold:
            bytes = PrinterCommand.boldEndCommand
        case .InvertColor:
            bytes = PrinterCommand.invertedColorEndCommand
        case .Large:
            bytes = PrinterCommand.largeTextEndCommand
        case .Print:
            bytes = PrinterCommand.fullCutCommand
        case .Underline:
            bytes = PrinterCommand.underlineEndCommand
        case .Upperline:
            bytes = PrinterCommand.upperlineEndCommand
        default:
            bytes = []
        }
        
        parsedData.appendBytes(bytes, length: bytes.count)
    }
    
}

typealias Byte = UInt8

class PrinterCommand {
    
    // Spacing
    static let tabCommand: [Byte] = [0x09]
    static let newLineCommand: [Byte] = [0x0a]
    
    // Alignment
    static let alignLeftCommand: [Byte] = [0x1b, 0x1d, 0x61, 0x30]
    static let alignCenterCommand: [Byte] = [0x1b, 0x1d, 0x61, 0x31]
    static let alignRightCommand: [Byte] = [0x1b, 0x1d, 0x61, 0x32]
    
    // Text Formatting
    static let boldStartCommand: [Byte] = [0x1b, 0x45]
    static let boldEndCommand: [Byte] = [0x1b, 0x46]
    
    static let underlineStartCommand: [Byte] = [0x1b, 0x2d, 0x01]
    static let underlineEndCommand: [Byte] = [0x1b, 0x2d, 0x00]
    
    static let upperlineStartCommand: [Byte] = [0x1b, 0x5f, 0x01]
    static let upperlineEndCommand: [Byte] = [0x1b, 0x5f, 0x00]
    
    static let largeTextStartCommand: [Byte] = [0x1b, 0x68, 0x01, 0x1b, 0x57, 0x01]
    static let largeTextEndCommand: [Byte] = [0x1b, 0x68, 0x00, 0x1b, 0x57, 0x00]
    
    static let invertedColorStartCommand: [Byte] = [0x1b, 0x34]
    static let invertedColorEndCommand: [Byte] = [0x1b, 0x35]
    
    // Open Drawer
    static let openDrawer1Command: [Byte] = [0x07]
    static let openDrawer2Command: [Byte] = [0x1a]
    
    // Cutting
    static let fullCutCommand: [Byte] = [0x1b, 0x64, 0x02]
    static let partialCutCommand: [Byte] = [0x1b, 0x64, 0x03]
    
}
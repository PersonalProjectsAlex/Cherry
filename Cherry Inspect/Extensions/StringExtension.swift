//
//  StringExtension.swift
//  CherryDrive
//
//  Created by Jefferson S. Batista on 5/1/16.
//  Copyright © 2016 Ring Seven. All rights reserved.
//

import UIKit

extension String {
    static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    
    var intValue: Int {
        return (self as NSString).integerValue
    }
    
    var boolValue: Bool {
        return (self as NSString).boolValue
    }
    
    var isValidEmail: Bool {
        return NSPredicate(format: "SELF MATCHES %@", String.emailRegex).evaluate(with: self)
    }
    
    func stringByAddingEncodedParams(_ parameters: AnyObject) -> String {
        if let params = parameters as? NSDictionary {
            let chars = NSMutableCharacterSet.alphanumeric()
            chars.addCharacters(in: "-._* ")
            
            var array = [String]()
            for (key, value) in params {
                if let encoded = (value as AnyObject).addingPercentEncoding(withAllowedCharacters: chars as CharacterSet) {
                    array.append("\(key)=\(encoded)")
                }
            }
            
            let paramsString = array.joined(separator: "&").replacingOccurrences(of: " ", with: "+")
            return self + "&\(paramsString)"
        }
        
        return self
    }
    
    func safeURL() -> String? {
        let chars = NSMutableCharacterSet.alphanumeric()
        // Plus for spaces is required by API specification, thus not esacping it
        chars.addCharacters(in: "@+-._*:/?&= ")
        
        return self.addingPercentEncoding(withAllowedCharacters: chars as CharacterSet)?.replacingOccurrences(of: " ", with: "+")
    }
}

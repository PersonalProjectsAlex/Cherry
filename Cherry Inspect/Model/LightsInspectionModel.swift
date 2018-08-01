//
//  LightsInspectionModel.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 9/7/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit

class LightsInspectionModel: NSObject {
    static let sharedInstance = LightsInspectionModel()
    
    //FRONT ITEMS
    var collectionItemsFront = ["Corner", "Daytime Running Lights", "Daytime Running Lights", "Corner", "Sideturn / Running Lights", "Headlight High Beams", "Headlight High Beams", "Low beams ", "Sideturn / Running Lights", "Turn Signal", "Fog Light", "Fog Light", "Turn Signal"]
    
    var itemsFront = [false,false,false,false,false,false,false,false,false,false,false,false]
    var itemsFrontIds = [127,128,133,132,129,130,135,134,131,137,654,136]
    
    //REAR ITEMS
    var collectionItemsRear = ["Brake Light", "Hight Mount", "Cargo Lights", "Brake Light", "Tail Light / Running Lights", "Reverse", "Reverse", "Tail Light / Running Lights", "Turn Signal", "Driver License", "Passenger License", "Turn Signal"]
    
    var itemsRear = [false,false,false,false,false,false,false,false,false,false,false,false]
    var itemsRearIds = [139,138,655,144,140,142,147,145,141,143,148,146]
    
    func resetLightsInspectionModel() {
        itemsFront = [false,false,false,false,false,false,false,false,false,false,false,false]
        itemsRear = itemsFront
    }
}

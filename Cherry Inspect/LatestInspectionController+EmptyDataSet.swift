//
//  IncompleteInspectionsController+EmptyDataSet.swift
//  Cherry Inspect
//
//  Created by Administrador on 22/03/18.
//  Copyright © 2018 Slate Development. All rights reserved.
//

import Foundation
import TBEmptyDataSet
import SwiftyBeaver

extension LatestInspectionController: TBEmptyDataSetDelegate, TBEmptyDataSetDataSource {
    
    // imageForEmptyDataSet
    func imageForEmptyDataSet(in scrollView: UIScrollView) -> UIImage? {
        return #imageLiteral(resourceName: "Logo2")
    }
    
    // titleForEmptyDataSet
    func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        var emptyTitle = String()
        var attributes: [NSAttributedStringKey: Any]?
        
        if isLoading{
            emptyTitle = "Loading..."
            attributes = [.font: UIFont(name: "Lato-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18), .foregroundColor: UIColor.lightGray]
            SwiftyBeaver.warning("Working")
            
        }else{
            
            attributes = [.font: UIFont(name: "Lato-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18), .foregroundColor: UIColor.red]
            emptyTitle = "¡Empty Data!"
            SwiftyBeaver.warning("Not at all")
        }
        
        return NSAttributedString(string: emptyTitle, attributes: attributes)
    }
    
    // descriptionForEmptyDataSet
    func descriptionForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        
        var description = String()
        if isLoading{
            description = ""
        }else{
            description = "You don't have inspections in latest yet"
        }
        let attributes: [NSAttributedStringKey: Any]? = [.font: UIFont(name: "Lato-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18), .foregroundColor: UIColor.red]
        
        return NSAttributedString(string: description, attributes: attributes)
    }
    
    // verticalOffsetForEmptyDataSet
    func verticalOffsetForEmptyDataSet(in scrollView: UIScrollView) -> CGFloat {
        
        if let navigationBar = navigationController?.navigationBar {
            return -navigationBar.frame.height * 0.10
        }
        return 0
    }
    
    // verticalSpacesForEmptyDataSet
    func verticalSpacesForEmptyDataSet(in scrollView: UIScrollView) -> [CGFloat] {
        return [25, 8]
    }
    
    
    
    
    
}

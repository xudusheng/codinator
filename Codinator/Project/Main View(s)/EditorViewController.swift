//
//  EditorViewController.swift
//  Codinator
//
//  Created by Lennart Kerkvliet on 26-03-16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController, UITextViewDelegate, WUTextSuggestionDisplayControllerDataSource {
    @IBOutlet var textView: UITextView!
    var text : String? = ""
    var documentTitle : String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.Interactive
        textView.layer.drawsAsynchronously = true
        textView.text = text
        
        self.navigationItem.title = documentTitle
        
        let suggestionDisplayController = WUTextSuggestionDisplayController()
        suggestionDisplayController.dataSource = self
        let suggestionController = WUTextSuggestionController(textView: textView, suggestionDisplayController: suggestionDisplayController)
        suggestionController.suggestionType = WUTextSuggestionType.At
    }
    
    func textSuggestionDisplayController(textSuggestionDisplayController: WUTextSuggestionDisplayController!, suggestionDisplayItemsForSuggestionType suggestionType: WUTextSuggestionType, query suggestionQuery: String!) -> [AnyObject]! {
        if suggestionType == WUTextSuggestionType.At {
            var suggestionDisplayItems : [WUTextSuggestionDisplayItem] = []
            for name in self.filteredNamesUsingQuery(suggestionQuery) {
                let item = WUTextSuggestionDisplayItem(title: name)
                suggestionDisplayItems.append(item)
            }
            return suggestionDisplayItems
        }
        
        return nil;
    }
    
    func filteredNamesUsingQuery(query : String) -> [String] {
        if let filteredNames = self.names().filteredArrayUsingPredicate(NSPredicate(block: { (evaluatedObject : AnyObject, bindings: [String : AnyObject]?) -> Bool in
            if let evaluatedObject = evaluatedObject as? String {
                if evaluatedObject.lowercaseString.hasPrefix(query.lowercaseString) {
                    return true
                }
            }
            
            return false
        })) as? [String] {
            return filteredNames
        }
        
        return []
    }

    func names() -> NSArray {
        return ["h1>","/h1>","h2>","/h2>","h3>","/h3>","h4>","h5>","h6>","head>","body>","/body>","!Doctype html>","center>","img src=","a href=","font ","meta","table border=","tr>","td>","div>","div class=","style>","title>","li>","em>","p>","li>","section class=","header>","footer>","ul>","del>","em>","sub>","sup>","var>","cite>","dfn>","big>","small>","strong>","code>","frameset","blackquote>","br>"]
    }

}
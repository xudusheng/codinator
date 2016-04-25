//
//  FilesTableViewController.swift
//  Codinator
//
//  Created by Lennart Kerkvliet on 26-03-16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

class FilesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewFilesDelegate, AssistantViewControllerDelegate{
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var toolBar: UIToolbar!

    var documentInteractionController: UIDocumentInteractionController?
    
    var items: [NSURL] = []
    
    
    var inspectorPath: String?
    var projectManager: Polaris! {
        
        get {
            return getSplitView.projectManager
        }
        
    }
    
    
    var indexPath: NSIndexPath?
    
    var getSplitView: ProjectSplitViewController! {
        
        get {
            
            guard let splitView = self.splitViewController as? ProjectSplitViewController else {
                assertionFailure("SplitView is nil")
                return ProjectSplitViewController()
            }
            
            return splitView
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = inspectorPath { } else {
            inspectorPath = projectManager.inspectorPath
        }
        
        
        reloadData()
        
    
        let insets = UIEdgeInsetsMake(0, 0, toolBar.frame.height, 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
        
        if traitCollection.forceTouchCapability == .Available {
            registerForPreviewingWithDelegate(self, sourceView: self.tableView)
        }
    }

    
    var hasntOpenIndexFileYet = true
    
    var count = 0
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if count > 0 {
            projectManager.inspectorPath = inspectorPath
        }
        
        
        // Keyboard show/hide notifications
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
        if hasntOpenIndexFileYet {
            // Find 'index.html' and save index of it in the array itself
            let items = self.items.enumerate().filter { $0.element.absoluteString.hasSuffix("index.html")}
            
            // if 'items' isn't empty sellect the corresponding cell
            if items.isEmpty != true {
                let indexPath = NSIndexPath(forRow: items.first!.index, inSection: 0)
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .Top)
                tableView(tableView, didSelectRowAtIndexPath: indexPath)
                
                // Load WebView
                guard let webView = getSplitView.webView else {
                    return
                }
                
                guard let path = (projectManager?.inspectorPath as NSString?)?.stringByAppendingPathComponent(items.first!.element.lastPathComponent!) else {
                    return
                }
                
                webView.loadFileURL( NSURL(fileURLWithPath: path, isDirectory: false), allowingReadAccessToURL: NSURL(fileURLWithPath: path, isDirectory: true))
              
                
                hasntOpenIndexFileYet = false
            }
        }

        
        getSplitView.assistantViewController?.renameDelegate = self
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // MARK: - Assistant View
    
    func renamedFileWithName(name: String) {
        reloadData()
        
        // Find 'name' and save index of it in the array itself
        let items = self.items.enumerate().filter { $0.element.absoluteString.hasSuffix(name)}
        
        // if 'items' isn't empty sellect the corresponding cell
        if items.isEmpty != true {
            let indexPath = NSIndexPath(forRow: items.first!.index, inSection: 0)
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .Top)
            tableView(tableView, didSelectRowAtIndexPath: indexPath)
        }
        
        
        
    }
    
    

    // MARK: - Action Buttons
    
    @IBAction func add(sender: UIBarButtonItem) {
        let newFile = UIAlertAction(title: "New File", style: .Default) { (action : UIAlertAction) in
            self.performSegueWithIdentifier("newFile", sender: self)
        }
        
        let newSubpage = UIAlertAction(title: "New Subpage", style: .Default) { (action : UIAlertAction) in
            self.performSegueWithIdentifier("newSubpage", sender: self)
        }
        
        let newDir = UIAlertAction(title: "New Directory", style: .Default) { (action : UIAlertAction) in
            self.performSegueWithIdentifier("newDir", sender: self)
        }
        
        let Import = UIAlertAction(title: "Import", style: .Default) { (action : UIAlertAction) in
            self.performSegueWithIdentifier("import", sender: self)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        
        let popup = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        popup.addAction(newFile)
        popup.addAction(newSubpage)
        popup.addAction(newDir)
        popup.addAction(Import)
        popup.addAction(cancel)
        
        popup.view.tintColor = UIColor.purpleColor()
        
        popup.popoverPresentationController?.barButtonItem = sender
        self.presentViewController(popup, animated: true, completion: {
            popup.view.tintColor = UIColor.purpleColor()
        })
    }
    
    @IBAction func product(sender: UIBarButtonItem) {
        let run = UIAlertAction(title: "Run", style: .Default) { (action : UIAlertAction) in
            self.performSegueWithIdentifier("run", sender: self)
        }
        
        let archive = UIAlertAction(title: "Archive", style: .Default) { (action : UIAlertAction) in
            self.performSegueWithIdentifier("archive", sender: self)
        }
        
        let history = UIAlertAction(title: "History", style: .Default) { (action : UIAlertAction) in
            self.performSegueWithIdentifier("history", sender: self)
        }
        
        let export = UIAlertAction(title: "Export", style: .Default) { (action : UIAlertAction) in
            Notifications.sharedInstance.alertWithMessage("Archive the Project first.\nAfterwards open up the History window and use the export manager.", title: "✈️")
        }
        
        let localServer = UIAlertAction(title: "Local Server", style: .Default) { (action : UIAlertAction) in
            self.performSegueWithIdentifier("Pulse", sender: self)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        
        let popup = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        popup.addAction(run)
        popup.addAction(archive)
        popup.addAction(history)
        popup.addAction(export)
        popup.addAction(localServer)
        popup.addAction(cancel)
        
        popup.view.tintColor = UIColor.purpleColor()
        
        popup.popoverPresentationController?.barButtonItem = sender
        self.presentViewController(popup, animated: true, completion: {
            popup.view.tintColor = UIColor.purpleColor()
        })
    }
    
    
    
    
    
    // MARK: - Keyboard show/hide
    
    let grabberViewHeight = CGFloat(10)
    var keyboardHeight: CGFloat = 0
    
    func keyboardWillShow(notification: NSNotification) {
//        let userInfo = notification.userInfo!
//        keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().height
        

    }
    
    func keyboardWillHide(notification: NSNotification) {
//        keyboardHeight = 0
//        
//        var insets = tableView.contentInset
//        insets.bottom = 0
//        
//        tableView.contentInset = insets
//        tableView.scrollIndicatorInsets = insets
        
    }

    

    
    
    // MARK: - File Database
    
    func reloadData() {
       
        if let items = projectManager!.contentsOfDirectoryAtPath(inspectorPath) {
            self.items = items.map { $0 as! NSURL}
        }

        tableView.reloadData()
    }
    
    

    // MARK: - Storyboards
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
               
            case "newFile":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! CreateFileViewController
                viewController.path = projectManager.inspectorPath
                viewController.items = self.items.map { $0.lastPathComponent! }
                viewController.delegate = self
 
            case "newSubpage":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! CreateSubpageViewController
                viewController.projectManager = projectManager
                viewController.delegate = self
                
            case "newDir":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! CreateDirViewController
                viewController.projectManager = projectManager
                viewController.delegate = self
                
            case "import":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! NewImportViewController
               
                viewController.items = self.items.map{ $0.lastPathComponent! }
                viewController.webUploaderURL = projectManager.webUploaderServerURL()
                viewController.inspectorPath = projectManager.inspectorPath
                viewController.delegate = self
            
            case "run":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! AspectRatioViewController
                
                if projectManager.deletePath?.characters.count >= 2 {
                    viewController.previewPath = projectManager.deletePath
                    projectManager.deletePath = ""
                }
                else {
                
                    if let tmpPath = projectManager.tmpFilePath {
                        if tmpPath.isEmpty {
                            
                            if (projectManager.inspectorPath as NSString).lastPathComponent != "index.html" {
                                viewController.previewPath = projectManager.inspectorPath + "/index.html"
                            }
                            else {
                                viewController.previewPath = projectManager.inspectorPath
                            }
                            
                        }
                        else {
                            viewController.previewPath = projectManager.tmpFilePath
                            projectManager.tmpFilePath = ""
                        }
                    }
                    else {
                        if (projectManager.inspectorPath as NSString).lastPathComponent != "index.html" {
                            viewController.previewPath = projectManager.inspectorPath + "/index.html"
                        }
                        else {
                            viewController.previewPath = projectManager.inspectorPath
                        }
                    
                    }
                }
                
                
                
            case "archive":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! ArchiveViewController
                viewController.projectManager = projectManager
                
            case "Pulse":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! ServersViewController
                viewController.projectManager = projectManager
                
            case "history":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! HistoryViewController
                viewController.projectManager = projectManager
               
            case "moveFile":
                let viewController = (segue.destinationViewController as! UINavigationController).viewControllers.first as! FileMoverViewController
                viewController.fileUrl = NSURL(fileURLWithPath: projectManager.deletePath)
                viewController.delegate = self
                
            default:
                break
            }
        
        }
        
    }
}

//
//  FolderTableViewController.swift


import UIKit
class FolderTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var placeHomeButton: UIButton!
    
    @IBAction func placeHomeButtonHit(sender: AnyObject) {
        if(fileMgr.editingMode){
            fileMgr.moveOver(fileMgr.editingPathToChange,toPath:fileMgr.getDocsDir())
            fileMgr.editingMode = false
            for(var i = 0; i < self.indexPathArray.count;i++){
                tableView.cellForRowAtIndexPath(self.indexPathArray[i])?.backgroundColor = UIColor.whiteColor()
            }
        }
        //else nothing
    }
    
    var temp_new_path_holder:String!
    var indexPathArray = [NSIndexPath]()
    
    //Method for extracting name of folder/file from path
    func stripPath(s: String)->String{
        var tempStringArray = s.componentsSeparatedByString("/")
        return tempStringArray[tempStringArray.count - 1]
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = stripPath(fileMgr.currentPath)
        if(fileMgr.editingMode){
            placeHomeButton.hidden = false
            placeHomeButton.enabled = true
        }
        else{
            placeHomeButton.hidden = true
            placeHomeButton.enabled = false
        }
    }
    
    //Get Number of cells to create
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileMgr.pathStringArray.count
    }
    
    //create cells and put them in the table view
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "folderCell")
        var tempString = fileMgr.pathStringArray[indexPath.row]
        cell.textLabel?.text = stripPath(fileMgr.pathStringArray[indexPath.row])
        indexPathArray.append(indexPath)
        
        var isDir = fileMgr.checkFolderOrFile(tempString)
        if(isDir){
            if(fileMgr.editingMode){cell.backgroundColor = UIColor.greenColor()}
        }
        else{cell.backgroundColor = UIColor.whiteColor()}
        
        return cell
    }
    
    //Selection of a cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        temp_new_path_holder = fileMgr.pathStringArray[indexPath.row]
        
        var isDir = fileMgr.checkFolderOrFile(temp_new_path_holder)
        if(isDir){
            self.performSegueWithIdentifier("selfSegue", sender: self)
            //fileMgr.editingMode = false
        }
        else{
            if(temp_new_path_holder.pathExtension == "jpg" || temp_new_path_holder.pathExtension == "JPG"
                || temp_new_path_holder.pathExtension == "png" || temp_new_path_holder.pathExtension == "PNG"){
                self.performSegueWithIdentifier("segueToImgView", sender: self)
            }
            else if(temp_new_path_holder.pathExtension == "pdf" || temp_new_path_holder.pathExtension == "txt"
                || temp_new_path_holder.pathExtension == "TXT" || temp_new_path_holder.pathExtension == "PDF"){
                self.performSegueWithIdentifier("segueToWebView", sender: self)
            }
            else{
                println("not a valid file name")
            }
        }

    }
    //Cell Editing: Piece #1
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        if(fileMgr.editingMode){
            
            var dropAction = UITableViewRowAction(style: .Normal, title: "Drop") { (action, indexPath) -> Void in
                tableView.editing = false //slide menu goes away
                var t_path = fileMgr.pathStringArray[indexPath.row]
                var isDir = fileMgr.checkFolderOrFile(t_path)
                if(isDir){
                    fileMgr.moveOver(fileMgr.editingPathToChange,toPath:t_path)
                    for(var i = 0; i < self.indexPathArray.count;i++){
                        tableView.cellForRowAtIndexPath(self.indexPathArray[i])?.backgroundColor = UIColor.whiteColor()
                    }
                    fileMgr.editingMode = false
                }
                else{
                    fileMgr.editingMode = false
                }
                
                //self.performSegueWithIdentifier("selfSegue", sender: self)
            }
            dropAction.backgroundColor = UIColor.blueColor()
            
            
            
            var cancelAction = UITableViewRowAction(style: .Normal, title: "Cancel") { (action, indexPath) -> Void in
                tableView.editing = false //slide menu goes away
                for(var i = 0; i < self.indexPathArray.count;i++){
                    tableView.cellForRowAtIndexPath(self.indexPathArray[i])?.backgroundColor = UIColor.whiteColor()
                }
                fileMgr.editingMode = false
            }
            cancelAction.backgroundColor = UIColor.redColor()
            
            
            return [dropAction,cancelAction]
        }
            
        else{
            var shareAction = UITableViewRowAction(style: .Normal, title: "Share") { (action, indexPath) -> Void in
                tableView.editing = false //slide menu goes away
                
                var tempPath = fileMgr.pathStringArray[indexPath.row]
                
                var isDir = fileMgr.checkFolderOrFile(tempPath)
                if(isDir){
                    //do something if dir
                }
                else{
                    var tObj = fileMgr.giveFileNameAndData(tempPath)
                    var name = tObj.0
                    var data = tObj.1
                    dropboxMgr.saveFile(name, data: data)
                }
            }
            shareAction.backgroundColor = UIColor.grayColor()
            
            
            
            var moveAction = UITableViewRowAction(style: .Default, title: "Move") { (action, indexPath) -> Void in
                tableView.editing = false //slide menu goes away
                
                fileMgr.editingPathToChange = fileMgr.pathStringArray[indexPath.row]
                
                
                for(var i = 0; i < self.indexPathArray.count;i++){
                    var tempPath = fileMgr.pathStringArray[i]
                    var isDir = fileMgr.checkFolderOrFile(tempPath)
                    if(isDir){
                        tableView.cellForRowAtIndexPath(self.indexPathArray[i])?.backgroundColor = UIColor.greenColor()
                    }
                }
                self.placeHomeButton.enabled = true
                self.placeHomeButton.hidden = false
                fileMgr.editingMode = true
            }
            moveAction.backgroundColor = UIColor.greenColor()
            
            
            var deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { (action, indexPath) -> Void in
                tableView.editing = false //slide menu goes away
                var deleteError:NSError?
                var tempFileString = fileMgr.pathStringArray[indexPath.row]
                fileMgr.pathStringArray.removeAtIndex(indexPath.row)
                self.indexPathArray.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                fileMgr.nsFM.removeItemAtPath(tempFileString, error: &deleteError)
            }
            deleteAction.backgroundColor = UIColor.redColor()
            
            return [deleteAction, moveAction, shareAction]
        }
        
        
        
    }
    //Cell Editing: Piece #2
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    //Segue Controllers
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if(segue.identifier == "selfSegue") {
            ///update all to new dir
            fileMgr.setCurrentPathForward(temp_new_path_holder)
        }
        if(segue.identifier == "backButtonSegue"){
            fileMgr.setCurrentPathBack()
        }
        if(segue.identifier == "homeButtonSegue"){
            fileMgr.setCurrentPathHome()
        }
        if(segue.identifier == "segueToImgView"){
            if let destination = segue.destinationViewController as? ImgViewVC {
                destination.path = temp_new_path_holder
            }
        }
        if(segue.identifier == "segueToWebView"){
            if let destination = segue.destinationViewController as? WebViewVC {
                destination.path = temp_new_path_holder
            }
        }
    }
    
    
}
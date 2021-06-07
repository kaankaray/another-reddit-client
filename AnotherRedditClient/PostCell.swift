//
//  PostCell.swift
//  AnotherRedditClient
//
//  Created by Kaan Karay on 4.06.2021.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var subredditLabel: UILabel!
    @IBOutlet weak var mainTextView: UITextView!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var previewImageView: UIImageView!
    
    var superTableController : UITableViewController?
    var cellNumber:Int = 0
    var sourceImageStr:String = ""
    var urlOfPost:URL = URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!
    
    ///Finds image in source.
    ///Not in use!
    func findImageURL(contentsOfPreview:[String : Any], completion: @escaping (String) -> Void) {
        // Full resolution url of an image is so well hidden...
        let insideOfPreviewAsAnyArray = contentsOfPreview["images"] as? [Any] ?? []
        let insideOfImages = anyObjectToJSON(obj: insideOfPreviewAsAnyArray[0] )
        let insideOfSource = anyObjectToJSON(obj: insideOfImages["source"]! )
        completion( insideOfSource["url"] as? String ?? "" )

    }
    
    /// Clicked on image. Will create an alertcontroller to ask if user wants to save or copy image to clipboard
    @IBAction func imageButtonAct(_ sender: Any) {
        
        let alert = UIAlertController(title: "Save photo", message: "Would you like to save this photo to your gallery?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
            switch action.style{
                case .default:
                    UIImageWriteToSavedPhotosAlbum(self.previewImageView.image!, self, nil, nil)
                    print("saved image \(self.cellNumber)")
            case .cancel:
                print("cancel")
            case .destructive:
                print("dest")
            @unknown default:
                fatalError() ///Should never happen
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Copy to clipboard", style: .default, handler: { action in
            switch action.style{
                case .default:
                    UIPasteboard.general.image = self.previewImageView.image!
                    print("copied to clipboard \(self.cellNumber)")
                case .cancel:
                    print("cancel")
                case .destructive:
                    print("dest")
            @unknown default:
                fatalError() ///Should never happen
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        superTableController!.present(alert, animated: true, completion: nil)
        
        print(cellNumber)
    }
    
    /// Open link in UIApplication
    @IBAction func titleButtonAct(_ sender: Any) {
        let alert = UIAlertController(title: "Open link", message: "Would you like to open this post in your browser?", preferredStyle: .actionSheet) //actionSheets are way better imo
        alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { action in
            switch action.style{
                case .default:
                    UIApplication.shared.open(self.urlOfPost)
                    print("link opened of cell \(self.cellNumber)")
            case .cancel:
                print("cancel")
            case .destructive:
                print("dest")
            @unknown default:
                fatalError() ///Should never happen
            }
        }))
        alert.addAction(UIAlertAction(title: "Copy to clipboard", style: .default, handler: { action in
            switch action.style{
                case .default:
                    UIPasteboard.general.url = self.urlOfPost
                    print("copied to clipboard \(self.cellNumber)")
                case .cancel:
                    print("cancel")
                case .destructive:
                    print("dest")
            @unknown default:
                fatalError() ///Should never happen
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        superTableController!.present(alert, animated: true, completion: nil)
    }
    
    /// Reads userDefaultsData to fill labels and views.
    func useUserDefaultsData() {
        let decoded  = UserDefaults.standard.object(forKey: "postNo\(cellNumber)") as? Data ?? nil
        if (decoded != nil) {
            let postData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded!) as? Dictionary<String, Any>
            DispatchQueue.main.async {
                self.titleButton.setTitle(postData?["title"] as? String, for: .normal)
                self.commentsCountLabel.text = postData?["num_comments"] as? String
                self.creationDateLabel.text = {
                    var difference = Date(timeIntervalSince1970: (postData?["created_utc"] as? Double)!).distance(to: Date())
                    var returnStr = ""
                    //Put it in a while loop to get a precise date?
                    if difference > 86400{
                        returnStr += "\(Int(difference/86400)) days "
                        difference = difference.truncatingRemainder(dividingBy: 86400)
                    } else if difference > 3600{
                        returnStr += "\(Int(difference/3600)) hours "
                        difference = difference.truncatingRemainder(dividingBy: 3600)
                    } else if difference > 60 {
                        returnStr += "\(Int(difference/60)) minutes "
                        difference = difference.truncatingRemainder(dividingBy: 60)
                    }
                    return "\(returnStr)ago"
                }()
                self.authorLabel.text = "u/" + (postData?["author"] as! String)
                self.subredditLabel.text = postData?["subreddit_name_prefixed"] as? String
                
                if postData?["selftext"] as? String != "" { // If a body text exists,
                    self.previewImageView.isHidden = true
                    self.imageButton.isHidden = true
                    self.mainTextView.text = postData?["selftext"] as? String
                    
                } else if postData!.keys.contains("thumbnail") {
                    self.previewImageView.isHidden = false
                    self.imageButton.isHidden = false
                    self.mainTextView.isHidden = true
                    self.previewImageView.imageFromUrl(urlString: postData!["thumbnail"] as! String)
                }
                /*
                /// Code snippet to get the full res image.
                if postData!.keys.contains("preview") { // Unfortunately Reddit doesn't let us get full resolution images, it returns 403 Forbidden.
                    self.previewImageView.isHidden = false
                    self.mainTextView.isHidden = true
                    print("test")
                    self.findImageURL(contentsOfPreview: postData?["preview"] as! [String:Any]) { URLResult in
                        print(URLResult)
                        self.previewImageView.imageFromUrl(urlString: URLResult)
                        
//                        DispatchQueue.global().async {
//                            let data = try? Data(contentsOf: qURLResult)
//                            DispatchQueue.main.async {
//                                if data != nil{
//                                    self.previewImageView.image = UIImage(data: data!)
//                                }
//                            }
//                        }
                    }
                }
                */
                self.commentsCountLabel.text = "Comments: \(postData?["num_comments"] as? Int ?? -1)"
//                self.subredditLabel.text = postData?["subreddit_name_prefixed"] as? String
                self.urlOfPost = URL(string: postData?["url"] as? String ?? "")!
                
            }
        }
    }
    
    /// Checks which value is available for usage.
    /// Checks for passIDArr array
    func updateView() {
        print("Loading cell: \(cellNumber)")
        
        if passIDArr[cellNumber] == "+" || passIDArr[cellNumber] == "" {
            /// Means the data downloaded is the latest. Or the download id is yet unknown. Use UserDefaults.
            useUserDefaultsData()
        } else {
            /// We have an id, and we need to download it. We somehow failed to foresee this info.
            print("Downloading cell: \(cellNumber)")
            getPosts(after: passIDArr[cellNumber]) { results in
                let post = anyObjectToJSON(obj: results[threadCount-1]["data"]!)
                do {
                    let encodedData = try NSKeyedArchiver.archivedData(withRootObject: post, requiringSecureCoding: false)
                    UserDefaults.standard.setValue(encodedData, forKey: "postNo\(self.cellNumber)") /// Saves as Dictionary<String, Any>
                    passIDArr[self.cellNumber] = "+"
                } catch let err { print("Error saving the data to userdefaults : \(err.localizedDescription)") }
                if self.cellNumber + threadCount < maxPostsInPage{ ///We don't want to pass the max post limit
                    passIDArr[self.cellNumber+threadCount] = post["name"] as! String
                    self.updateView()
                }
            }
        }
        
        /// Try and download cellNumber+5.
        if cellNumber + threadCount < maxPostsInPage && passIDArr[cellNumber + threadCount] != "" && passIDArr[cellNumber + threadCount] != "+" {
            print("PRE-Downloading cell: \(cellNumber + threadCount)")
            getPosts(after: passIDArr[cellNumber + threadCount]) { results in
                let post = anyObjectToJSON(obj: results[threadCount - 1]["data"]!)
                do {
                    let encodedData = try NSKeyedArchiver.archivedData(withRootObject: post, requiringSecureCoding: false)
                    UserDefaults.standard.setValue(encodedData, forKey: "postNo\(self.cellNumber + threadCount)") /// Saves as Dictionary<String, Any>
                    if self.cellNumber + threadCount + threadCount < maxPostsInPage{ ///We don't want to pass the max post limit
                        passIDArr[self.cellNumber + threadCount] = "+"
                    }
                    
                } catch let err { print("Error saving the data to userdefaults : \(err.localizedDescription)") }
                if self.cellNumber + threadCount + threadCount < maxPostsInPage{ ///We don't want to pass the max post limit
                    passIDArr[self.cellNumber + threadCount + threadCount] = post["name"] as! String
                }
            }
            
        }
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code DO NOTHING HERE
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

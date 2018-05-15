//
//  HomeControllerViewCells.swift
//  urcal
//
//  Created by Kilian Hiestermann on 12.05.17.
//  Copyright © 2017 Kilian Hiestermann. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

protocol HomeControllerViewCellDelegate {
    func didTapComment(postID: String)
}

class HomeControllerViewCell: UICollectionViewCell, CLLocationManagerDelegate{
        
    var likes = 0
    
    var userLatitude: Double?
    var userLongitude: Double?
    var delegate: HomeControllerViewCellDelegate?
    
    var indexPath: NSIndexPath?{
        didSet{}
    }
    
    var bookmarked: Bool?{
        didSet{
            if bookmarked == false {
                bookmarkButton.removeTarget(self, action: #selector(handleDeBookmark), for: .touchUpInside)
                bookmarkButton.addTarget(self, action: #selector(handleBookmark), for: .touchUpInside)
                bookmarkButton.setImage(#imageLiteral(resourceName: "pin_32"), for: .normal)
            } else if bookmarked == true {
                bookmarkButton.removeTarget(self, action: #selector(handleBookmark), for: .touchUpInside)
                bookmarkButton.addTarget(self, action: #selector(handleDeBookmark), for: .touchUpInside)
                bookmarkButton.setImage(#imageLiteral(resourceName: "bookmark").withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
    }
    
    var post :UserPost?{
        didSet{
            

            guard let imageUrl = post?.post.imageUrl else { return }
            guard let geoImageUrl = post?.post.geoImageUrl else { return }
            
            imageView.loadImageUsingCacheWithUrlString(urlString: imageUrl)
            postUsername.text = post?.user.username
            geoImageView.loadImageUsingCacheWithUrlString(urlString: geoImageUrl)
            
            //setupAttributeCaption()
            setupDistance()
        }
    }
     
    var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .red
        return iv
    }()
    
    var postUsername: UILabel = {
        let label = UILabel()
        return label
    }()
    
    var postUserImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 80/2
        image.clipsToBounds = true
        image.backgroundColor = .green
        image.image = UIImage(named: "profil_dummy")
        return image
    }()
    
    let bottomCellBackground: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = UIColor(white: 0, alpha: 0)
        return view
    }()
    
    let geoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .blue
        return iv
    }()
    
    var captionLabel: UITextView = {
        let label = UITextView()
        //label.numberOfLines = 0
        return label
    }()
    
    let distancIcon: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "distance").withRenderingMode(.alwaysOriginal), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.1)
        return button
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.1)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    lazy var bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor(white: 0, alpha: 0.1)
        return button
    }()
    
    let distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "100"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    let commentLabel: UILabel = {
        let label = UILabel()
        label.text = "1000"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    let likesLabel: UILabel = {
        let label = UILabel()
        label.text = "1.1k"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    let bookmarkLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    lazy var mapButton: UIButton = {
        let button = UIButton(type: .system)
        button.isUserInteractionEnabled = true
        button.isEnabled = true
        button.addTarget(self, action: #selector(handleShowMap), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
         layoutIfNeeded()
        settingUpViews()
    }

    override func prepareForReuse() {
        self.imageView.image = nil
        self.geoImageView.image = nil
    }
    
    fileprivate func settingUpViews(){
    
    addSubview(geoImageView)
    geoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: -2, width: frame.width / 2 - 2 , height: frame.width / 2 - 2)
    
    addSubview(imageView)
    imageView.anchor(top: topAnchor, left: nil, bottom: nil , right: rightAnchor , paddingTop: 0, paddingLeft: 2, paddingBottom: 0, paddingRight: 0, width: frame.width/2 - 2  , height: frame.width/2 - 2 )

    addSubview(mapButton)
    mapButton.anchor(top: nil, left: imageView.rightAnchor, bottom: imageView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: frame.width * (1/2) , height: frame.width * (1/2))
    addSubview(postUserImage)
    postUserImage.centerYAnchor.constraint(equalTo: geoImageView.bottomAnchor, constant: 10).isActive = true
    postUserImage.leftAnchor.constraint(equalTo: geoImageView.leftAnchor, constant: 10).isActive = true
    postUserImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
    postUserImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
    
    setupButtons()
    
    }
    
    fileprivate func setupButtons() {
        
        addSubview(bottomCellBackground)
        bottomCellBackground.anchor(top: imageView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let stackView = UIStackView(arrangedSubviews: [distancIcon, commentButton, likeButton, bookmarkButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: imageView.bottomAnchor, left: imageView.leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: -4, width: 0, height: 37)
        
        let stackViewLabels = UIStackView(arrangedSubviews: [distanceLabel,commentLabel, likesLabel, bookmarkLabel])
        stackViewLabels.axis = .horizontal
        stackViewLabels.distribution = .fillEqually
        addSubview(stackViewLabels)
        stackViewLabels.anchor(top: stackView.bottomAnchor, left: imageView.leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 2, paddingLeft: 4, paddingBottom: -3, paddingRight: -4, width: 0, height: 0)
        
        
       
       
        let stackViewFrame = UIBezierPath(rect: stackView.frame)
        let stackViewLabelsFrame = UIBezierPath(rect: stackViewLabels.frame)
        print(stackViewLabels.frame.height)
        captionLabel.textContainer.exclusionPaths = [stackViewFrame, stackViewLabelsFrame]
        captionLabel.backgroundColor = UIColor.init(white: 0, alpha: 0)
        captionLabel.text = "asdfj aoisdf oiasdiofhj aopsdhfiu ahsdof aosidijf poauhdf oahsdüif aoidjfpoawjdfüi ashdopifj aspdjf asdfop asodfh oashdf oasdf asodhf asjdfo asoidfjoai sdjfüo iasdüoif aüoisdjf oaisdjfüi asjdüoifij asüoidjf üoaisdjf oiasjd füoiasd falisdhf asd foashdf "
        addSubview(captionLabel)
        captionLabel.anchor(top: imageView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc fileprivate func handleComment() {
        guard let postID = post?.post.postId else { return }
        delegate?.didTapComment(postID: postID)
    }
    
    func handleBookmark(){
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let postId = post?.post.postId else { return }

        let refUser = Database.database().reference().child("users").child(uid).child("bookmarks")
        let refPost = Database.database().reference().child("posts").child(postId).child("bookmarks")
        let valuePost = [postId: 1]
        let valueUser = [uid:1]
        refUser.updateChildValues(valuePost) { (err, ref) in
            if let err = err{
                print(err)
            }
            refPost.updateChildValues(valueUser, withCompletionBlock: { (err, ref) in
                if let err = err {
                    print(err)
                }
            })
        }
        self.bookmarked = true
    }
    
    func handleDeBookmark() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let postId = post?.post.postId else { return }
        
        let refUser = Database.database().reference().child("users").child(uid).child("bookmarks").child(postId)
        let refPost = Database.database().reference().child("posts").child(postId).child("bookmarks").child(uid)
        refUser.removeValue { (err, ref) in
            if let err = err{
                print(err)
            }
            refPost.removeValue(completionBlock: { (err, ref) in
                if let err = err{
                    print(err)
                }
                self.bookmarked = false

                if self.indexPath != nil{
                    self.delateBookmark()
                }
            })

        }
    }
    
    fileprivate func delateBookmark(){
        let myDict = self.indexPath
        NotificationCenter.default.post(name: .delateCell, object: myDict)
        NotificationCenter.default.post(name: .refreshHomeController, object: nil)
    }
    
    fileprivate func setupAttributeCaption() {
        guard let post = self.post else { return }
                
        let attributedText = NSMutableAttributedString(string: "\(post.user.username): ", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: post.post.captionText, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
        
        let timeAgoDisplay = post.post.creationDate.timeAgoDisplay()
        attributedText.append(NSAttributedString(string: "\n \(timeAgoDisplay)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14),NSForegroundColorAttributeName: UIColor.lightGray ]))
        
        captionLabel.attributedText = attributedText
    }
    

    func handleShowMap() {
        
        guard let longitude = post?.post.longitude else { return }
        guard let latitude = post?.post.latitude else { return }
        let myDict = [ "longitude": longitude, "latitude": latitude] as [String : Any]
        
        NotificationCenter.default.post(name: .setUpMap, object: myDict)

    }
    
    fileprivate func setupDistance(){
        
        guard let currentUserLatitude = userLatitude else { return distanceLabel.text = "Error"}
        guard let currentUserLongitude = userLongitude else { return }
        guard let postLatitude = post?.post.latitude else { return }
        guard let postLongitude = post?.post.longitude else { return }
        
        
        let coordinate1 = CLLocation(latitude: currentUserLatitude, longitude: currentUserLongitude)
        let coordinate2 = CLLocation(latitude: postLatitude, longitude: postLongitude)
        
        var distance = round(coordinate1.distance(from: coordinate2))
        
        if distance > 1000{
            distance = round(distance / 100)
            distance = distance / 10
            distanceLabel.text = "\(distance) km"
        } else {
            distanceLabel.text = "\(distance) m"
        }
        distanceLabel.text = "350 m"
    }
    
    func handleLike() {
        likes += 1
        likesLabel.text = String(likes)
        likeButton.imageView?.image = UIImage(named: "like")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

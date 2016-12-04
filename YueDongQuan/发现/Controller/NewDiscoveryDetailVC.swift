//
//  NewDiscoveryDetailVC.swift
//  YueDongQuan
//
//  Created by HKF on 2016/12/2.
//  Copyright © 2016年 黄方果. All rights reserved.
//

import UIKit

class NewDiscoveryDetailVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    private var DetailTable : UITableView!
    
    var newDiscoveryArray : DiscoveryArray?
    var newDiscoveryOfZeroCommentArr = [DiscoveryCommentModel]()
    var newDiscoveryOfNoZeroCommentArr = [DiscoveryCommentModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DetailTable = UITableView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight-44-20), style: UITableViewStyle.Grouped)
        DetailTable.delegate = self
        DetailTable.dataSource = self
        
        
        self.view.addSubview(DetailTable)
        
        
        

        let newDisZeroArray = NSMutableArray()
        let newDisNoZeroArray = NSMutableArray()
        
        for model in (self.newDiscoveryArray!.comment)!{
            if model.commentId == 0 {
                newDisZeroArray.addObject(model)
                
            }else{
                newDisNoZeroArray.addObject(model)
            }
        }
        
        self.newDiscoveryOfZeroCommentArr = newDisZeroArray.copy() as! [DiscoveryCommentModel]
        self.newDiscoveryOfNoZeroCommentArr = newDisNoZeroArray.copy() as! [DiscoveryCommentModel]
        
        self.newDiscoveryOfZeroCommentArr.sortInPlace({ (num1:DiscoveryCommentModel, num2:DiscoveryCommentModel) -> Bool in
            return num1.time > num2.time
        })
        
        print(self.newDiscoveryArray!.comment.count)
        print(self.newDiscoveryOfNoZeroCommentArr.count)
        print(self.newDiscoveryOfZeroCommentArr.count)
        
        DetailTable.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.tabBarController?.hidesBottomBarWhenPushed = true
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.tabBarController?.hidesBottomBarWhenPushed = false
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return newDiscoveryOfZeroCommentArr.count + 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            
            let h = NewDiscoveryHeaderCell.hyb_heightForTableView(tableView, config: { (sourceCell : UITableViewCell!) in
                let cell = sourceCell as! NewDiscoveryHeaderCell
                cell.configCellWithModelAndIndexPath((self.newDiscoveryArray)!, indexPath: indexPath)
                }, cache: { () -> [NSObject : AnyObject]! in
                return [kHYBCacheUniqueKey : ("\(self.newDiscoveryArray?.id)"),
                                    kHYBCacheStateKey:"",kHYBRecalculateForStateKey:1]
            })
            return h
            
        }else{
            let h = NewDiscoveryCommentDeatilCell.hyb_heightForTableView(tableView,
                                                          config: { (sourceCell:UITableViewCell!) in
                                                            let cell = sourceCell as! NewDiscoveryCommentDeatilCell
                                                            cell.newConfigPingLunCell(self.newDiscoveryOfZeroCommentArr,subModel:self.newDiscoveryOfNoZeroCommentArr,
                                                                indexpath: indexPath)
                }, cache: { () -> [NSObject : AnyObject]! in
                    
                    return [kHYBCacheUniqueKey : (self.newDiscoveryArray?.id.description)!,
                        kHYBCacheStateKey:"",
                        kHYBRecalculateForStateKey:1]
            })
            return h
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var detailHeaderCell = tableView.dequeueReusableCellWithIdentifier("cell") as? NewDiscoveryHeaderCell
            detailHeaderCell = NewDiscoveryHeaderCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
            detailHeaderCell?.configCellWithModelAndIndexPath(self.newDiscoveryArray!, indexPath: indexPath)
            return detailHeaderCell!
            
        }else{
            var detailscommentCell = tableView.dequeueReusableCellWithIdentifier("cell") as? NewDiscoveryCommentDeatilCell
            if detailscommentCell == nil{
                detailscommentCell = NewDiscoveryCommentDeatilCell(style: .Default, reuseIdentifier: "cell")
                detailscommentCell!.commentModelTemp = self.newDiscoveryOfZeroCommentArr[indexPath.row]
                
            }
            
            detailscommentCell!.newConfigPingLunCell(self.newDiscoveryOfZeroCommentArr,subModel:self.newDiscoveryOfNoZeroCommentArr, indexpath: indexPath)
            
//            detailscommentCell?.commentBtnBlock({ (btn, indexpath,pingluntype) in
//                
//                self.keyboard.keyboardUpforComment()
//            })
            
            return detailscommentCell!
        }
        
    }
    

}



class NewDiscoveryHeaderCell: UITableViewCell {
    
    private var titleLabel : UILabel?//name
    private var superLinkLabel : UILabel?
    private var descLabel : UILabel?//说说内容
    private var headImageView : UIImageView?//头像
    private var headTypeView : UIImageView?//是否认证
    
    private var timeStatus : UILabel?//时间
    private var distanceLabel : UILabel?//距离
    private var typeStatusView : UIImageView?//类型
    private var displayView = PYPhotosView()//照片或者视频显示
    
    private var videoImage = UIImageView()//视频展示
    private var playVideoBtn = UIButton()//播放按钮
    
    
    private var tableView : UITableView?//评论cell
    private var locationView = UIView()//有定位时显示定位，没有时隐藏
    private var locationLabel = UILabel()//显示定位信息
    private var operateView : UIView!//操作的view
    private var liulanCount = UILabel()//浏览次数
    private let dianzanBtn = UIButton()//点赞按钮
    private let pinglunBtn = UIButton()//评论按钮
    private let jubaoBtn = UIButton()//举报按钮
    
    private var testModel : DiscoveryArray?//模型
    private var indexPath : NSIndexPath?
    
    
    var imageArry = [String]()
    
    private var popView = SimplePopupView()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
        setUI()
    }
    
    
    @objc private func setUI(){
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        self.selectionStyle = .None
        //头像
        self.headImageView = UIImageView()
        self.headImageView?.contentMode = .ScaleAspectFill
        self.contentView.addSubview(self.headImageView!)
        self.headImageView?.snp_makeConstraints(closure: { (make) in
            make.top.equalTo(20)
            make.left.equalTo(15)
            make.width.height.equalTo(40)
        })
        self.headImageView?.backgroundColor = UIColor.whiteColor()
        self.headImageView?.layer.masksToBounds = true
        self.headImageView?.layer.cornerRadius = 20
        self.headImageView?.userInteractionEnabled = true
        let headerTap = UITapGestureRecognizer(target: self, action: #selector(clickHeader))
        self.headImageView?.addGestureRecognizer(headerTap)
        weak var weakSelf = self
        
        self.headTypeView = UIImageView()
        self.contentView.addSubview(headTypeView!)
        self.headTypeView?.snp_makeConstraints(closure: { (make) in
            make.right.equalTo((weakSelf?.headImageView?.snp_right)!)
            make.bottom.equalTo((weakSelf?.headImageView?.snp_bottom)!)
            make.height.width.equalTo(15)
        })
        self.headTypeView?.layer.masksToBounds = true
        self.headTypeView?.layer.cornerRadius = 7
        self.headTypeView?.layer.borderWidth = 1
        self.headTypeView?.layer.borderColor = UIColor.whiteColor().CGColor
        self.headTypeView?.backgroundColor = UIColor.whiteColor()
        
        //昵称
        self.titleLabel = UILabel()
        self.contentView.addSubview(self.titleLabel!)
        self.titleLabel?.preferredMaxLayoutWidth = screenWidth - 110
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.font = UIFont.systemFontOfSize(17)
        
        self.titleLabel?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo((weakSelf?.headImageView?.snp_right)!).offset(5)
            make.top.equalTo(20)
            make.width.equalTo(screenWidth/2)
            make.height.equalTo(26)
        })
        self.titleLabel?.backgroundColor = UIColor.whiteColor()
        
        //时间
        self.timeStatus = UILabel()
        self.contentView.addSubview(self.timeStatus!)
        self.timeStatus?.font = UIFont.systemFontOfSize(10)
        self.timeStatus?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo((weakSelf?.headImageView?.snp_right)!).offset(5)
            make.top.equalTo((weakSelf?.titleLabel?.snp_bottom)!)
            make.height.equalTo(14)
            make.width.equalTo(screenWidth/6)
        })
        //        self.timeStatus?.text = "六分钟前"
        self.timeStatus?.backgroundColor = UIColor.whiteColor()
        self.timeStatus?.textAlignment = .Left
        //距离
        self.distanceLabel = UILabel()
        self.contentView.addSubview(self.distanceLabel!)
        self.distanceLabel?.font = UIFont.boldSystemFontOfSize(10)
        self.distanceLabel?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo((weakSelf?.timeStatus?.snp_right)!)
            make.top.equalTo((weakSelf?.titleLabel?.snp_bottom)!)
            make.height.equalTo(14)
            make.width.equalTo(screenWidth/3)
        })
        //        self.distanceLabel?.text = "离我1000km"
        self.distanceLabel?.backgroundColor = UIColor.whiteColor()
        self.distanceLabel?.textAlignment = .Left
        
        ///说说类型
        self.typeStatusView = UIImageView()
        self.contentView.addSubview(self.typeStatusView!)
        self.typeStatusView?.snp_makeConstraints(closure: { (make) in
            make.top.equalTo(25)
            make.right.equalTo(-20)
            make.height.equalTo(20)
            make.width.equalTo(40)
        })
        
        self.typeStatusView?.backgroundColor = UIColor.whiteColor()
        self.typeStatusView?.layer.masksToBounds = true
        self.typeStatusView?.layer.cornerRadius = 10
        
        self.superLinkLabel = UILabel()
        self.contentView.addSubview(self.superLinkLabel!)
        self.superLinkLabel!.snp_makeConstraints(closure: { (make) in
            make.top.equalTo((weakSelf?.headImageView?.snp_bottom)!).offset(5)
            make.right.equalTo(-20)
            make.height.equalTo(20)
            make.left.equalTo(20)
        })
        self.superLinkLabel?.textAlignment = .Left
        //添加手势
        let tapSuperLink = UITapGestureRecognizer(target: self, action: #selector(clickSuperLinkLabel))
        self.superLinkLabel?.userInteractionEnabled = true
        self.superLinkLabel?.addGestureRecognizer(tapSuperLink)
        
        //说说内容
        self.descLabel = UILabel()
        self.contentView.addSubview(self.descLabel!)
        self.descLabel?.numberOfLines = 0
        self.descLabel?.font = UIFont.systemFontOfSize(14)
        self.descLabel?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo((weakSelf?.superLinkLabel?.snp_bottom)!).offset(5)
        })
        
        //照片或视频展示
        self.contentView.addSubview(self.displayView)
        displayView.photoWidth = (ScreenWidth - 30)/3
        displayView.photoHeight = (ScreenWidth - 30)/3
        displayView.scrollEnabled = false
        self.displayView.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo((weakSelf?.descLabel?.snp_bottom)!).offset(5)
        })
        
        self.contentView.addSubview(self.videoImage)
        self.videoImage.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(10)
            //            make.width.equalTo(ScreenWidth - 20)
            make.right.equalTo(-10)
            make.top.equalTo((weakSelf?.displayView.snp_bottom)!).offset(2)
        })
        
        self.videoImage.addSubview(self.playVideoBtn)
        self.playVideoBtn.snp_makeConstraints { (make) in
            make.center.equalTo(self.videoImage.snp_center)
            make.height.width.equalTo(40)
        }
        self.playVideoBtn.setImage(UIImage(named: "audionews_index_play@2x.png"), forState: UIControlState.Normal)
        
        self.videoImage.backgroundColor = UIColor.brownColor()
        self.videoImage.userInteractionEnabled = true
        
        
        //定位信息
        self.contentView.addSubview(self.locationView)
        self.locationView.snp_makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo((weakSelf?.videoImage.snp_bottom)!).offset(5)
            make.height.equalTo(14)
        }
        self.locationView.backgroundColor = UIColor.whiteColor()
        let locationImg = UIImageView(frame: CGRect(x: 1, y: 1, width: 12, height: 12))
        locationImg.image = UIImage(named: "location")
        self.locationView.addSubview(locationImg)
        
        self.locationLabel.frame = CGRect(x: 16, y: 1, width: screenWidth - 36, height: 12)
        self.locationLabel.font = UIFont.systemFontOfSize(10)
        //        self.locationLabel.text = "重庆市渝北区大龙上"
        self.locationView.addSubview(self.locationLabel)
        
        //点赞数，浏览次数，评论数，以及举报按钮
        self.operateView = UIView()
        self.contentView.addSubview(self.operateView)
        self.operateView.snp_makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo((weakSelf?.locationView.snp_bottom)!).offset(5)
            make.height.equalTo(24)
        }
        self.operateView.backgroundColor = UIColor.whiteColor()
        let liulanImg = UIImageView(frame: CGRect(x: 2, y: 6, width: 20, height: 12))
        liulanImg.image = UIImage(named: "ic_liulan")
        self.operateView.addSubview(liulanImg)
        self.liulanCount.frame = CGRect(x: 23, y: 0, width: screenWidth/6, height: 24)
        self.liulanCount.text = "0"
        self.liulanCount.font = UIFont.boldSystemFontOfSize(10)
        self.liulanCount.textColor = UIColor(red: 166/255, green: 166/255, blue: 166/255, alpha: 1.0)
        self.operateView.addSubview(self.liulanCount)
        
        self.dianzanBtn.frame = CGRect(x: screenWidth/5, y: 0, width: screenWidth/6, height: 24)
        //        self.dianzanBtn.setImage(UIImage(named: "ic_zan_a6a6a6"), forState: UIControlState.Normal)
        //        self.dianzanBtn.setTitle("0", forState: UIControlState.Normal)
        self.dianzanBtn.titleLabel?.font = UIFont.systemFontOfSize(10)
        self.dianzanBtn.setImage(UIImage(named: "ic_zan_a6a6a6"), forState: UIControlState.Normal)
        self.dianzanBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0,  screenWidth/10)
        self.dianzanBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -screenWidth/30, 0, 0)
        self.dianzanBtn.setTitleColor(UIColor(red: 166/255, green: 166/255, blue: 166/255, alpha: 1.0), forState: UIControlState.Normal)
        self.operateView.addSubview(self.dianzanBtn)
        self.dianzanBtn.addTarget(self, action: #selector(clickDianZanBtn(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.pinglunBtn.frame = CGRect(x: screenWidth/5*2, y: 0, width: screenWidth/6, height: 24)
        //        self.pinglunBtn.setImage(UIImage(named: "ic_pinglun"), forState: UIControlState.Normal)
        self.pinglunBtn.setTitle("0", forState: UIControlState.Normal)
        self.pinglunBtn.titleLabel?.font = UIFont.systemFontOfSize(10)
        self.pinglunBtn.setImage(UIImage(named: "ic_pinglun"), forState: UIControlState.Normal)
        self.pinglunBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, screenWidth/10)
        self.pinglunBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -screenWidth/30, 0, 0)
        self.pinglunBtn.setTitleColor(UIColor(red: 166/255, green: 166/255, blue: 166/255, alpha: 1.0), forState: UIControlState.Normal)
        self.pinglunBtn.addTarget(self, action: #selector(clickPingLun), forControlEvents: UIControlEvents.TouchUpInside)
        self.operateView.addSubview(self.pinglunBtn)
        
        self.operateView.addSubview(self.jubaoBtn)
        self.jubaoBtn.snp_makeConstraints { (make) in
            make.top.bottom.equalTo(0)
            make.right.equalTo(-5)
            make.width.equalTo(screenWidth/12)
        }
        
        self.jubaoBtn.setImage(UIImage(named: "jubao"), forState: UIControlState.Normal)
        self.jubaoBtn.backgroundColor = UIColor.whiteColor()
        self.jubaoBtn.addTarget(self, action: #selector(clickJuBao), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        self.hyb_lastViewInCell = self.operateView
        self.hyb_bottomOffsetToCell = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    @objc private func clickHeader(){
        
    }
    
    @objc private func clickDianZanBtn(sender:UIButton){
        
    }
    @objc private func clickPingLun(){
        
    }
    @objc private func clickJuBao(){
        
    }
    
    
    func configCellWithModelAndIndexPath(model : DiscoveryArray,indexPath : NSIndexPath){
        
        self.indexPath = indexPath
        let subModel = model
        
        self.distanceLabel?.text = String(format: "%0.2fkm",(model.distance))
        
        
        if subModel.csum != nil{
            self.pinglunBtn.setTitle("\(subModel.csum)", forState: UIControlState.Normal)
            self.liulanCount.text = "\(subModel.csum + subModel.isPraise)"
        }else{
            self.pinglunBtn.setTitle("0", forState: UIControlState.Normal)
            self.liulanCount.text = "\(subModel.isPraise)"
        }
        
        if subModel.isPraise != 0{
            self.dianzanBtn.setImage(UIImage(named: "ic_zan_f13434"), forState: UIControlState.Normal)
            self.dianzanBtn.setTitle("\(subModel.isPraise)", forState: UIControlState.Normal)
        }
        
        switch subModel.typeId {
        case 11:
            //            print("图片")
            self.titleLabel?.text =  subModel.name
            self.typeStatusView?.image = UIImage(named: "explain_pic")
        case 12:
            //            print("视频")
            self.titleLabel?.text =  subModel.name
            self.typeStatusView?.image = UIImage(named: "explain_vedio")
        case 13:
            //            print("活动")
            self.titleLabel?.text = subModel.name
            self.typeStatusView?.image = UIImage(named: "explain_JOIN")
        case 14:
            //            print("约战")
            self.titleLabel?.text =  subModel.name
            self.typeStatusView?.image = UIImage(named: "约战")
        case 15:
            //            print("求加入")
            self.titleLabel?.text =  subModel.name
            self.typeStatusView?.image = UIImage(named: "explain_enlist")
        case 16:
            //            print("招募")
            self.titleLabel?.text =  subModel.rname
            
            self.typeStatusView?.image = UIImage(named: "招募")
        default:
            break
        }
        
        if model.typeId == 13 {
            self.superLinkLabel!.snp_updateConstraints(closure: { (make) in
                make.height.equalTo(35)
            })
            let temp = model.aname
            let attribStr = NSMutableAttributedString(string: temp)
            attribStr.addAttributes([NSForegroundColorAttributeName : UIColor.blueColor()], range: NSMakeRange(0, model.aname.characters.count))
            attribStr.addAttributes([NSUnderlineStyleAttributeName : NSNumber(integer: 1)], range: NSMakeRange(0, model.aname.characters.count))
            attribStr.addAttributes([NSUnderlineColorAttributeName : UIColor.blueColor()], range: NSMakeRange(0, model.aname.characters.count))
            let attch = NSTextAttachment()
            attch.image = UIImage(named: "link")
            attch.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)
            let string = NSAttributedString(attachment: attch)
            attribStr.insertAttributedString(string, atIndex: 0)
            
            self.superLinkLabel?.attributedText = attribStr
            
        }else{
            self.superLinkLabel!.snp_updateConstraints(closure: { (make) in
                make.height.equalTo(0)
            })
        }
        
        if subModel.address == ""{
            self.locationView.snp_updateConstraints(closure: { (make) in
                make.height.equalTo(0)
            })
            self.locationView.hidden = true
        }else{
            self.locationView.hidden = false
            self.locationView.snp_updateConstraints(closure: { (make) in
                make.height.equalTo(14)
            })
            //            self.distanceLabel?.text = subModel.address
        }
        let tempStr = "<body> " + subModel.content + " </body>"
        let resultStr1 = tempStr.stringByReplacingOccurrencesOfString("\\n", withString: "<br/>", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let data = resultStr1.dataUsingEncoding(NSUnicodeStringEncoding)
        let options = [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType]
        let html =  try! NSAttributedString(data: data!, options: options, documentAttributes: nil)
        self.descLabel?.attributedText = html
        self.locationLabel.text = subModel.address
        if subModel.thumbnailSrc != nil {
            self.headImageView?.sd_setImageWithURL(NSURL(string: subModel.thumbnailSrc), placeholderImage: UIImage(named: "热动篮球LOGO"))
        }else{
            self.headImageView?.sd_setImageWithURL(NSURL(string: ""), placeholderImage: UIImage(named: "热动篮球LOGO"))
        }
        
        self.testModel = subModel
        
        self.timeStatus?.text = getTimeString(subModel.time)
        
        
        if subModel.images.count != 0 {
            let h1 = cellHeightByData1(subModel.images.count)
            
            self.displayView.snp_updateConstraints(closure: { (make) in
                make.height.equalTo(h1)
            })
            self.displayView.hidden = false
        }else{
            self.displayView.snp_updateConstraints(closure: { (make) in
                make.height.equalTo(0)
            })
            self.displayView.hidden = true
        }
        
        //        NSLog("videoURL = \(model.compressUrl)")
        if subModel.compressUrl != "" {
            self.videoImage.snp_updateConstraints(closure: { (make) in
                make.height.equalTo(ScreenHeight/4)
            })
            self.videoImage.hidden = false
            
            
            //            self.videoImage.sd_setImageWithURL(NSURL(string: model.compressUrl), placeholderImage: nil)
            self.videoImage.sd_setImageWithURL(NSURL(string: subModel.vPreviewThu), placeholderImage: UIImage(named: ""))
            
            
        }else{
            self.videoImage.snp_updateConstraints(closure: { (make) in
                make.height.equalTo(0)
            })
            self.videoImage.hidden = true
        }
        
        
        
        var thumbnailImageUrls = [String]()
        var originalImageUrls = [String]()
        if subModel.images.count != 0 {
            for item in subModel.images {
                thumbnailImageUrls.append(item.thumbnailSrc)
                originalImageUrls.append(item.originalSrc)
            }
            displayView.thumbnailUrls = thumbnailImageUrls
            displayView.originalUrls = originalImageUrls
        }
        
        
        
    }
    
    
    @objc private func clickSuperLinkLabel(){
        
    }
    
    @objc private func getTimeString(time:Int) -> String{
        
        let timeTemp = NSDate.init(timeIntervalSince1970: Double(time/1000))
        
        let timeInterval = timeTemp.timeIntervalSince1970
        
        let timer = NSDate().timeIntervalSince1970 - timeInterval//currentTime - createTime
        
        let second = timer
        if second < 60 {
            let result = String(format: "刚刚")
            return result
        }
        
        let minute = timer/60
        if minute < 60 {
            let result = String(format: "%ld分钟前", Int(minute))
            return result
        }
        
        let hours = timer/3600
        
        if hours < 24 {
            let result = String(format: "%ld小时前", Int(hours))
            return result
        }
        let days = timer/3600/24
        
        if days < 30 {
            let result = String(format: "%ld天前", Int(days))
            return result
        }
        
        let months = timer/3600/24/30
        if months < 12 {
            let result = String(format: "%ld月前", Int(months))
            return result
        }
        
        let years = timer/3600/24/30
        
        let result = String(format: "%ld年前", Int(years))
        
        
        
        return result
        
        //        let temp = timer - time
    }
    @objc private func cellHeightByData1(imageNum:Int)->CGFloat{
        let totalWidth = self.bounds.size.width
        //        let lines:CGFloat = (CGFloat(imageNum))/3
        var picHeight:CGFloat = 0
        switch imageNum{
        case 1...3:
            picHeight = totalWidth/3
            break
        case 4...6:
            picHeight = totalWidth*(2/3)
            break
        case 7...9:
            picHeight = totalWidth
            break
        default:
            picHeight = 0
        }
        return picHeight
        
    }
    
    
    
    
}

class NewDiscoveryCommentDeatilCell: UITableViewCell,UITableViewDataSource,UITableViewDelegate {
    
    private var headImage : UIImageView?
    private var userName : UILabel?
    private var timeAgo : UILabel?
    private var replyBtn : UIButton?
    private var contentlabel : UILabel?
    private var tableView : UITableView?
    
    var commentModelTemp : DiscoveryCommentModel?
    private var NoZeroCommentAry = [DiscoveryCommentModel]()
    private var smallModel : DiscoveryCommentModel?
    //子评论行数
    private var subCommentCount = 0
    private var indexpath : NSIndexPath?
    
    private let ary = NSMutableArray()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        self.selectionStyle = .None
        
        headImage = UIImageView()
        userName = UILabel()
        timeAgo = UILabel()
        replyBtn = UIButton()
        contentlabel = UILabel()
        self.contentView .addSubview(headImage!)
        self.contentView .addSubview(userName!)
        self.contentView .addSubview(timeAgo!)
        self.contentView .addSubview(replyBtn!)
        self.contentView .addSubview(contentlabel!)
        
        //头像
        self.headImage = UIImageView()
        self.headImage?.backgroundColor = UIColor.blueColor()
        
        self.contentView .addSubview(self.headImage!)
        
        self.headImage?.snp_makeConstraints(closure: { (make) in
            make.left.top.equalTo(10)
            make.width.height.equalTo(40)
        })
        
        weak var WeakSelf = self
        //昵称
        self.userName = UILabel()
        self.contentView .addSubview(self.userName!)
        
        self.userName?.textColor = UIColor(red: 54/255, green: 71/255, blue: 121/255, alpha: 0.9)
        self.userName?.preferredMaxLayoutWidth = ScreenWidth - 10 - 40 - 30
        self.userName?.numberOfLines = 0
        self.userName?.font = kAutoFontWithTop
        self.userName?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo((WeakSelf!.headImage!.snp_right)).offset(5)
            make.top.equalTo((WeakSelf!.headImage!.snp_top))
            make.right.equalTo(-10)
            make.height.equalTo(15)
        })
        //MARK:回复按钮
        replyBtn = UIButton(type: .Custom)
        self.contentView .addSubview(replyBtn!)
        replyBtn?.snp_makeConstraints(closure: { (make) in
            make.right.equalTo(-10)
            make.top.equalTo(10)
            make.width.equalTo(40)
            make.height.equalTo(20)
        })
        replyBtn?.layer.cornerRadius = 10
        replyBtn?.layer.masksToBounds = true
        replyBtn?.backgroundColor = kBlueColor
        replyBtn?.addTarget(self, action: #selector(newDiscoveryReplySomeOne), forControlEvents: UIControlEvents.TouchUpInside)
        
        // MARK:分钟数
        self.timeAgo = UILabel()
        self.timeAgo?.font = kAutoFontWithSmall
        self.contentView .addSubview(self.timeAgo!)
        self.timeAgo!.preferredMaxLayoutWidth = ScreenWidth-20 ;
        self.timeAgo!.numberOfLines = 0;
        //    self.descLabel!.font = UIFont.systemFontOfSize(kMidScaleOfFont)
        self.timeAgo?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo((WeakSelf!.headImage!.snp_right)).offset(5)
            make.right.equalTo(-10)
            make.top.equalTo((WeakSelf?.userName?.snp_bottom)!).offset(10)
        })
        // MARK:内容
        self.contentlabel = UILabel()
        self.contentView .addSubview(self.contentlabel!)
        self.contentlabel?.preferredMaxLayoutWidth = ScreenWidth - 20
        self.contentlabel?.numberOfLines = 0
        self.contentlabel!.font = kAutoFontWithTop
        self.contentlabel?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo((headImage?.snp_right)!)
            make.right.equalTo(-10)
            make.top.equalTo((headImage?.snp_bottom)!).offset(5)
        })
        //MARK:子评论表格
        self.tableView = UITableView()
        self.tableView?.scrollEnabled = false
        self.contentView .addSubview(self.tableView!)
        self.tableView?.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(self.userName!)
            make.top.equalTo((self.contentlabel?.snp_bottom)!).offset(5)
            make.trailing.equalTo(-10)
        })
        
//        self.tableView?.registerClass(NewDetailsCommentCell.self, forCellReuseIdentifier: "identtifier")
        
        self.tableView?.separatorStyle = .None
        self.hyb_lastViewInCell = self.tableView
        self.hyb_bottomOffsetToCell = 0
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func newDiscoveryReplySomeOne(){
        
    }
    
    
    func newConfigPingLunCell(model:[DiscoveryCommentModel],subModel:[DiscoveryCommentModel],indexpath:NSIndexPath)  {
        self.NoZeroCommentAry = subModel
        self.commentModelTemp = model[indexpath.section - 1]
        self.indexpath = indexpath
        self.userName?.text = model[indexpath.section - 1].netName
        let time = TimeStampToDate().getTimeString(model[indexpath.section - 1].time)
        self.timeAgo?.text = time
        self.replyBtn?.setTitle("回复", forState: UIControlState.Normal)
        self.replyBtn?.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.contentlabel?.text = model[indexpath.section - 1].content
        self.headImage?.image = UIImage(named: "默认头像")
        //孙子级评论
        var tableViewHeight = CGFloat()
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.registerClass(NewDetailsCommentCell.self,
                                      forCellReuseIdentifier: "identtifier")
        if subModel.count != 0 {
            if subModel.count == 1 {
                let cellheight = NewDetailsCommentCell.hyb_heightForTableView(self.tableView, config: { (sourceCell:UITableViewCell!) in
                    
                    let cell = sourceCell as! NewDetailsCommentCell
                    cell.configSubCommentCellWithModel(subModel.first!)
                    }, cache: { () -> [NSObject : AnyObject]! in
                        return [kHYBCacheUniqueKey : "",
                            kHYBCacheStateKey :"",
                            kHYBRecalculateForStateKey:1]
                })
                tableViewHeight += cellheight;
                self.tableView?.snp_updateConstraints(closure: { (make) in
                    make.height.equalTo(tableViewHeight)
                })
                
                self.tableView?.reloadData()
                
            }else{
                for id in 1...subModel.count {
                    
                    let cellheight = NewDetailsCommentCell.hyb_heightForTableView(self.tableView, config: { (sourceCell:UITableViewCell!) in
                        
                        let cell = sourceCell as! NewDetailsCommentCell
                        cell.configSubCommentCellWithModel(subModel[id - 1])
                        }, cache: { () -> [NSObject : AnyObject]! in
                            return [kHYBCacheUniqueKey : "",
                                kHYBCacheStateKey :"",
                                kHYBRecalculateForStateKey:1]
                    })
                    tableViewHeight += cellheight;
                }
                self.tableView?.snp_updateConstraints(closure: { (make) in
                    make.height.equalTo(tableViewHeight)
                })
                self.tableView?.reloadData()
            }
            
        }
        
        for id in self.NoZeroCommentAry{
            if id.commentId == self.commentModelTemp!.id {
                
                ary.addObject(id)
            }
        }
        
        //self.tableView?.reloadData()
        
    }
    
    
    //数据源
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("identtifier",forIndexPath: indexPath) as! NewDetailsCommentCell
        cell = NewDetailsCommentCell(style: .Default, reuseIdentifier: "identtifier")
        //        if indexPath.row <= self.ary.count {
        cell.configSubCommentCellWithModel(ary[indexPath.row] as! DiscoveryCommentModel)
        //        }
        
        return cell
    }
    //确定行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ary.count
        
    }
    //计算高度
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if self.ary.count != 0 {
            let cell_height = NewDetailsCommentCell.hyb_heightForTableView(self.tableView, config: { (cell:UITableViewCell!) in
                let cell = cell as! NewDetailsCommentCell
                cell.configSubCommentCellWithModel(self.ary[indexPath.row] as! DiscoveryCommentModel)
            }) { () -> [NSObject : AnyObject]! in
                let cache = [kHYBCacheUniqueKey:userInfo.uid,
                             kHYBCacheStateKey:"",
                             kHYBRecalculateForStateKey:0]
                return cache as [NSObject : AnyObject]
            }
            return cell_height
        }else{
            return 0
        }
        
    }
    //取消选中样式
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath,
                                         animated: true)
    }
    
    
}


class NewDetailsCommentCell: UITableViewCell {
    
    private var contentLabel : UILabel?
    var subIndex : NSIndexPath?
    
    var allCommentAry : [DiscoveryCommentModel]?
    
    typealias allcommentClourse = (md:[DiscoveryCommentModel])->Void
    var allcommentBlock : allcommentClourse?
    func allComment(block:allcommentClourse?) {
        allcommentBlock = block
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected( selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentLabel = UILabel()
        self.contentView .addSubview(self.contentLabel!)
        self.contentLabel?.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.contentLabel?.preferredMaxLayoutWidth = ScreenWidth - 10 - 40 - 20
        self.contentLabel?.numberOfLines = 0
        self.contentLabel?.font = kAutoFontWithMid
        self.contentLabel?.snp_makeConstraints(closure: { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(0).offset(3)
        })
        self.hyb_lastViewInCell = self.contentLabel
        self.hyb_bottomOffsetToCell = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func getAllCommentData(model:[DiscoveryCommentModel])  {
        self.allCommentAry = model
    }
    func configSubCommentCellWithModel(model:DiscoveryCommentModel)  {
        
        //           self.allComment { (md) in
        //        if self.allCommentAry != nil {
        
        
        
        
        let attributeString = NSMutableAttributedString(string: String(format: "%@回复:  %@", model.netName,model.content))
        //从文本0开始6个字符字体HelveticaNeue-Bold,16号
        
        //设置字体颜色
        attributeString.addAttribute(NSForegroundColorAttributeName,
                                     value: kBlueColor,
                                     range: NSMakeRange(0,
                                        NSString(string:model.netName).length))
        
        
        self.contentLabel?.attributedText = attributeString
        
        
        
        
        
        
        //        }
        
        
        //        }
        
        
    }
}






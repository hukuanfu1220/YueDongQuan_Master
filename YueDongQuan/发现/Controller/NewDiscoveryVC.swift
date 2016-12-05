//
//  NewDiscoveryVC.swift
//  YueDongQuan
//
//  Created by HKF on 2016/11/30.
//  Copyright © 2016年 黄方果. All rights reserved.
//

import UIKit
import MJRefresh
import SRGMediaPlayer
import Alamofire
import SwiftyJSON

class NewDiscoveryVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,AMapLocationManagerDelegate,HKFTableViewCellDelegate,ChatKeyBoardDelegate,ChatKeyBoardDataSource {
    
    private let MENU_BUTTON_WIDTH : CGFloat = 80
    let cellID  = "HKFTableViewCell"
    private var TopMenuView: UIScrollView!//顶部按钮
    private var ContentView: UIScrollView!//容器
    private var ordertemp = 0 {
        didSet{
            pullDownRef()
        }
    }//附近筛选参数
    
    private var menuBgView = UIView()
    private var menuArray = [String]()
    private var tableViewArray = [UITableView]()
    private var refreshTableView = UITableView()
    private var menuTitle = String()
    private var requestCanShu = ["14","15","11","12","13"]
    
    private let http = DiscorveryDataAPI.shareInstance
    private var AllModelData = [DiscoveryArray]()
    private var typeID = String()
    /******尝试加载视频播放*******/
    private var moviePlayers : RTSMediaPlayerViewController!
    /******定位使用*******/
    private var manger = AMapLocationManager()
    private var userLatitude : Double = 0
    private var userLongitude : Double = 0
    
    /*********评论所需 ************/
    private var commentSayIndex : NSIndexPath?
    private var typeStatus : PingLunType?
    private var commentSayId:Int?
    private var commentMainID = Int()
    private var commentModel : DiscoveryCommentModel?
    private var commentToCommentIndex : NSIndexPath?
    
    //弹出键盘
    lazy var keyboard:ChatKeyBoard = {
        var keyboard = ChatKeyBoard(navgationBarTranslucent: false)
        keyboard.delegate = self
        keyboard.dataSource = self
        keyboard.keyBoardStyle = KeyBoardStyle.Comment
        keyboard.allowVoice = false
        keyboard.allowMore = false
        keyboard.allowSwitchBar = false
        keyboard.placeHolder = "评论"
        return keyboard
        
        
    }()
    
//MARK:键盘的代理方法
    internal func chatKeyBoardToolbarItems() -> [ChatToolBarItem]! {
        let item1 = ChatToolBarItem(kind: BarItemKind.Face, normal: "face", high: "face_HL", select: "keyboard")
        return [item1]
    }
    internal func chatKeyBoardFacePanelSubjectItems() -> [FaceThemeModel]! {
        let model = FaceSourceManager.loadFaceSource() as! [FaceThemeModel]
        return model
    }
    internal func chatKeyBoardMorePanelItems() -> [MoreItem]! {
        let item1 = MoreItem(picName: "pinc", highLightPicName: "More_HL", itemName: "more")
        return [item1]
    }
    
    func chatKeyBoardSendText(text: String!) {
        
//        text.stringByReplacingEmojiCheatCodesWithUnicode
//        print(text.stringByReplacingEmojiUnicodeWithCheatCodes)
        
        let test = text.stringByReplacingEmojiUnicodeWithCheatCodes()
        sendMessage(test)
        
        self.keyboard.keyboardDownForComment()
    }
    
    /***********************************/
    
    
    
    @objc private func setNav(){
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_lanqiu"), style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 24.0 / 255, green: 90.0 / 255, blue: 172.0 / 255, alpha: 1.0)
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 65, height: 32))
        let searchBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        
        searchBtn.setImage(UIImage(named: "ic_search"), forState: UIControlState.Normal)
        searchBtn.addTarget(self, action: #selector(clickSearchBtn), forControlEvents: UIControlEvents.TouchUpInside)
        rightView.addSubview(searchBtn)
        let addBtn = UIButton(frame: CGRect(x: 33, y: 0, width: 32, height: 32))
        addBtn.setImage(UIImage(named: "ic_add"), forState: UIControlState.Normal)
        rightView.addSubview(addBtn)
        addBtn.addTarget(self, action: #selector(clickAddBtn), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightView)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
    }
    
    @objc private func clickSearchBtn(){
        let searchVC = SearchController()
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc private func clickAddBtn(sender:UIBarButtonItem,event:UIEvent){
        
        let righttable = CustomTable(frame: CGRect(x: 0,
            y: 0,
            width: 130,
            height: 132))
        righttable.titleLext =  ["扫一扫","上传场地","新建圈子"]
        righttable.rowNumber = 3
        righttable.rowHeight = 44
        righttable.titleImage = ["ic_erweima","ic_shangchuan","ic_xinjianquanzi"]
        let popview = WJPopoverViewController(showView: righttable)
        popview.borderWidth = 0
        popview.showPopoverWithBarButtonItemTouch(event,
                                                  animation: true)
        
        righttable.sendVlaueBack({ (index) in
            popview.dissPopoverViewWithAnimation(true)
            switch index {
            case 0:
                
                let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
                if device != nil{
                    let VC = SGScanningQRCodeVC()
                    self.navigationController?.pushViewController(VC, animated: true)
                }else{
                    let alert = SGAlertView(title: "⚠️ 警告", delegate: nil, contentTitle: "未检测到您的摄像头", alertViewBottomViewType: (SGAlertViewBottomViewTypeOne))
                    alert.show()
                }
                
                break
            case 1:
                let post = HKFPostField_OneVC()
                let nav = CustomNavigationBar(rootViewController: post)
                self.navigationController?.presentViewController(nav, animated: true, completion: nil)
                
                break
            case 2:
                let newCircle = NewQuanZiViewController()
                let nav = CustomNavigationBar(rootViewController: newCircle)
                nav.navigationBar.tintColor = UIColor.whiteColor()
                self.navigationController?.presentViewController(nav, animated: true, completion: nil)
                break
            default:
                break
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNav()
        manger.delegate = self
        manger.startUpdatingLocation()
        self.edgesForExtendedLayout = .None
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(notifyChangeModel), name: "LastestOrderDataChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(noDataNotifyProcess), name: "SenderNoDataNotify", object: nil)
        createMenu()
        
        createFlowBtn()
        self.view.addSubview(self.keyboard)
        self.view.bringSubviewToFront(self.keyboard)
        
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //创建一个悬浮的按钮
    @objc private func  createFlowBtn(){
        let flowView = UIImageView(frame: CGRect(x: ScreenWidth - 120, y: 40, width: 100, height: 40))
        flowView.image = UIImage(named: "ic_float")
        flowView.contentMode = .ScaleAspectFit
        flowView.layer.masksToBounds = true
        flowView.layer.cornerRadius = 10
        self.view.addSubview(flowView)
        self.view.bringSubviewToFront(flowView)
        
        let tapBtn = UIButton(frame: CGRect(x: ScreenWidth - 130, y: 40, width: 80, height: 40))
        tapBtn.addTarget(self, action: #selector(clickFlowViewBtn), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(tapBtn)
        self.view.bringSubviewToFront(tapBtn)
        
        
    }
    
    @objc private func clickFlowViewBtn(sender:UIButton){
        FTPopOverMenu.showForSender(sender, withMenu: ["按时间排序","按距离排序"], doneBlock: { (index:Int) in
            
            switch index {
                case 0 :
                    NSLog("xxxx")
                    self.ordertemp = 0
                    break
                case 1 :
                    NSLog("ooooo")
                    self.ordertemp = 1
                    break
                default:
                    break
            }
            
            
            }) { 
                
        }
    }
    
    
//MARK:判断视频是什么状态
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        
    }
    override func shouldAutorotate() -> Bool {
        return true
    }
    
//MARK:支持横竖屏显示
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All
    }
    
//MARK:创建顶部按钮
    func createMenu(){
        self.menuArray = ["最新","关注","图片|视频","活动|约战", "求加入|招募"]
        
        TopMenuView = UIScrollView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 40))
        self.view.addSubview(TopMenuView)
        TopMenuView.scrollEnabled = true
        TopMenuView.showsVerticalScrollIndicator = false
        TopMenuView.showsHorizontalScrollIndicator = false
        
        ContentView = UIScrollView(frame: CGRect(x: 0, y: 40, width: ScreenWidth, height: ScreenHeight - 104 - 49))
        ContentView.showsVerticalScrollIndicator = false
        ContentView.showsHorizontalScrollIndicator = false
        ContentView.pagingEnabled = true
        ContentView.scrollEnabled = true
        ContentView.delegate = self
        self.view.addSubview(ContentView)
        
        for i in 0..<self.menuArray.count {
            let menu = UIButton(type: UIButtonType.Custom)
            menu.frame = CGRect(x: MENU_BUTTON_WIDTH*CGFloat(i), y: 0, width: MENU_BUTTON_WIDTH, height: TopMenuView.frame.size.height)
            menu.setTitle(self.menuArray[i] , forState: UIControlState.Normal)
            menu.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            menu.titleLabel?.font = UIFont.systemFontOfSize(14)
            menu.tag = i
            menu.addTarget(self, action: #selector(NewDiscoveryVC.selectMenu(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            TopMenuView.addSubview(menu)
        }
        TopMenuView.contentSize = CGSize(width: MENU_BUTTON_WIDTH*CGFloat(self.menuArray.count), height: TopMenuView.frame.size.height)
        menuBgView = UIView(frame: CGRect(x: 0, y: TopMenuView.frame.size.height - 2, width: MENU_BUTTON_WIDTH, height: 2))
        menuBgView.backgroundColor = UIColor.redColor()
        TopMenuView.addSubview(menuBgView)
        ContentView.contentSize = CGSize(width: ScreenWidth*CGFloat(self.menuArray.count), height: ContentView.frame.size.height)
        addTableViewToScrollView(withScrollView: ContentView, withCount: menuArray.count, WithFrame: CGRectZero)
        
    }
//MARK:选择顶部按钮
    @objc private func selectMenu(sender:UIButton){
        sender.setTitleColor(UIColor.blueColor(), forState: UIControlState.Selected)
        ContentView.contentOffset = CGPoint(x: ScreenWidth*CGFloat(sender.tag), y: 0)
        let xx = ScreenWidth*CGFloat(sender.tag - 1)*(MENU_BUTTON_WIDTH/ScreenWidth) - MENU_BUTTON_WIDTH
        TopMenuView.scrollRectToVisible(CGRect(x: xx, y: 0, width: ScreenWidth, height: TopMenuView.frame.size.height), animated: true)
        refreshTableView(sender.tag)
        
    }
//MARK:添加tableview
    @objc private func addTableViewToScrollView(withScrollView scrollView:UIScrollView,withCount pageCount:Int,WithFrame frame:CGRect){
        
        for i in 0..<pageCount {
            let tableView = UITableView(frame: CGRect(x: ScreenWidth*CGFloat(i), y: 0, width: ScreenWidth, height: ScreenHeight - TopMenuView.frame.size.height - 64 - 49),style: UITableViewStyle.Plain)
            
            tableView.tag = i
            tableView.delegate = self
            tableView.dataSource = self
//            tableView.registerClass(HKFTableViewCell.self, forCellReuseIdentifier: cellID)
            
            tableViewArray.append(tableView)
            scrollView.addSubview(tableView)
        }
        
        refreshTableView(0)
        
    }
//MARK:刷新tableview
    @objc private func refreshTableView(index:Int){
        
        
        refreshTableView = tableViewArray[index]
        refreshTableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(NewDiscoveryVC.pullDownRef))
        refreshTableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(NewDiscoveryVC.pullUpRef))
        refreshTableView.estimatedRowHeight = 200
        var frame = refreshTableView.frame
        frame.origin.x = ScreenWidth * CGFloat(index)
        refreshTableView.frame = frame
        menuTitle = menuArray[index]
        let typeIDTemp = self.requestCanShu[index]
        self.typeID = typeIDTemp
        pullDownRef()
    }
//MARK:下拉刷新
    @objc private func pullDownRef(){
        http.removeAllModelData()
        http.requestLastestDataList(self.typeID, pageNo: 1,longitude: self.userLongitude,latitude: self.userLatitude ,order:self.ordertemp)
    }
//MARK:上拉加载更多
    @objc private func pullUpRef(){
       http.requestLastestMoreDataList(self.typeID,longitude: self.userLongitude,latitude: self.userLatitude ,order:self.ordertemp)
    }
    
    @objc private func notifyChangeModel(){
        
        let tempModel = http.getLastestDataList()
        self.AllModelData = tempModel
        
        self.refreshTableView.reloadData()
        
        refreshTableView.mj_header.endRefreshing()
        refreshTableView.mj_footer.endRefreshing()
    }
    
    @objc private func noDataNotifyProcess(){
        refreshTableView.mj_footer.endRefreshingWithNoMoreData()
    }
    
    
//MARK:计算顶部的线的滑动
    @objc private func changeView(x:CGFloat){
        let xx = x*(MENU_BUTTON_WIDTH/ScreenWidth)
        menuBgView.frame = CGRect(x: xx, y: menuBgView.frame.origin.y, width: menuBgView.frame.size.width, height: menuBgView.frame.size.height)
        
    }
//MARK:UITableViewDataSource和UITableViewDelegate
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AllModelData.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let model = self.AllModelData[indexPath.row]
        let h : CGFloat = HKFTableViewCell.hyb_heightForTableView(tableView, config: { (sourceCell:UITableViewCell!) in
            let cell = sourceCell as! HKFTableViewCell
            cell.configCellWithModelAndIndexPath(model, indexPath: indexPath)
        }) { () -> [NSObject : AnyObject]! in
            let cache = [kHYBCacheStateKey:"\(model.id)",kHYBCacheUniqueKey:"",kHYBRecalculateForStateKey:1]
            model.shouldUpdateCache = false
            return cache as [NSObject:AnyObject]
        }
        return h + 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellID) as? HKFTableViewCell
        cell?.indexPath = indexPath
        cell = HKFTableViewCell(style: .Default, reuseIdentifier: cellID)
        cell!.indexPath = indexPath

        cell!.delegate = self
        cell!.headTypeView?.hidden = true
        let model = self.AllModelData[indexPath.row]
        cell!.configCellWithModelAndIndexPath(model , indexPath: indexPath)
        cell?.playVideoBtn.tag = indexPath.row

        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let newDiscoveryDetailVC = NewDiscoveryDetailVC()
        newDiscoveryDetailVC.newDiscoveryArray  = self.AllModelData[indexPath.row]
        self.navigationController?.pushViewController(newDiscoveryDetailVC, animated: true)
        
    }
    
    
    func clickVideoBtn(indexPath: NSIndexPath) {
        
        let url = self.AllModelData[indexPath.row].compressUrl
//        "http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"
        moviePlayers = RTSMediaPlayerViewController(contentURL: NSURL(string: url)!)
        
        self.presentViewController(moviePlayers, animated: true, completion: nil)
    }
    
    @objc private func createVideoPlayerVC(){
        
    }
    
    
//MARK:点击cell中的所有代理方法
    //点击头像
    func clickCellHeaderImageForToHeInfo(index: NSIndexPath, uid: String) {
        let he_Uid = uid
        let heInfoVC = HeInfoVC()
        heInfoVC.userid = he_Uid
        self.navigationController?.pushViewController(heInfoVC, animated: true)
    }
    //点赞
    func clickDianZanBtnAtIndexPath(indexPath: NSIndexPath) {
        requestDianZan(self.AllModelData[indexPath.row].id)
    }
    //点击举报
    func clickJuBaoBtnAtIndexPath(foundId: Int, typeId: Int) {
        requestJuBaoSay(foundId, typeId: typeId)
    }
    //创建评论
    func createPingLunView(indexPath: NSIndexPath, sayId: Int, type: PingLunType) {
        self.keyboard.keyboardUpforComment()
        self.commentSayIndex = indexPath
        self.commentSayId = sayId
        self.typeStatus = type
        self.commentMainID = 0
    }
    //评论
    func selectCellPinglun(indexPath: NSIndexPath, commentIndexPath: NSIndexPath, sayId: Int, model: DiscoveryCommentModel, type: PingLunType) {
        
        self.keyboard.keyboardUpforComment()
        self.commentSayIndex = indexPath
        self.commentToCommentIndex = commentIndexPath
        self.commentSayId = sayId
        self.typeStatus = type
        self.commentModel = model
//        self.commentMainID = model.id
    }
    
    
    //点击超链接文本
    func clickSuperLinkLabelURL(indexPath: NSIndexPath) {
        let webVC = ActivityDetailWebVC()
        webVC.urlStr = "http://www.ctyundong.com"
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    //刷新单个cell
    func reloadCellHeightForModelAndAtIndexPath(model: DiscoveryArray, indexPath: NSIndexPath) {
        refreshTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.keyboard.keyboardDownForComment()
        
    }

    
    
//MARK:UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.isKindOfClass(UITableView.self){
            
        }else{
            changeView(scrollView.contentOffset.x)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.isKindOfClass(UITableView.self) {
            
        }else{
            let xx = scrollView.contentOffset.x * (MENU_BUTTON_WIDTH/ScreenWidth) - MENU_BUTTON_WIDTH
            
            TopMenuView.scrollRectToVisible(CGRect(x: xx, y: 0, width: ScreenWidth, height: TopMenuView.frame.size.height), animated: true)
            let i = (scrollView.contentOffset.x/ScreenWidth)
            refreshTableView(Int(i))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
//MARK:地图定位代理
extension NewDiscoveryVC {
    func amapLocationManager(manager: AMapLocationManager!, didFailWithError error: NSError!) {
        print(error)
    }
    func amapLocationManager(manager: AMapLocationManager!, didUpdateLocation location: CLLocation!) {
        
        
        self.userLatitude = location.coordinate.latitude
        self.userLongitude = location.coordinate.longitude
        
        manger.stopUpdatingLocation()
        pullDownRef()
    }
}


//MAKR:cell中的请求方法
extension NewDiscoveryVC {
    
    //请求点赞
    @objc private func requestDianZan(foundId:Int){
        let v = NSObject.getEncodeString("20160901")
        
        let para = ["v":v,"uid":userInfo.uid.description,"foundId":foundId]
        
        Alamofire.request(.POST, NSURL(string: testUrl + "/praise")!, parameters: para as? [String : AnyObject]).responseString { response -> Void in
            switch response.result {
            case .Success:
                let json = JSON(data: response.data!)
                _ = json.object
                
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    //发送评论内容
    private func sendMessage(text:String){
        switch typeStatus! {
        case .pinglun:
            let model = DiscoveryCommentModel()
            model.netName = userInfo.name
            model.commentId = 0
            model.content = text
            model.foundId = self.commentSayId
            model.id = (self.commentSayIndex?.row)! + 1
            model.time = Int(NSDate().timeIntervalSince1970)
            model.uid = userInfo.uid
            model.beUserName = nil
            model.beUid = 0
            
            self.AllModelData[(self.commentSayIndex?.row)!].comment.append(model)
            let modelss  =  self.AllModelData[(self.commentSayIndex?.row)!]
            reloadCellHeightForModelAndAtIndexPath(modelss, indexPath: self.commentSayIndex!)
        
            NewRequestCommentSay(withCommentId: 0, content: text, foundId: self.commentSayId!,mainId: 0)
        case .selectCell:
            let model = DiscoveryCommentModel()
            model.netName = userInfo.name
            model.commentId = (self.commentModel?.id)
            model.content = text
            model.foundId = self.commentSayId
            model.id = (self.commentModel?.id)! + 1
            model.time = Int(NSDate().timeIntervalSince1970)
            model.uid = userInfo.uid
            model.beUserName = self.commentModel?.netName
            model.beUid = nil
            
            self.AllModelData[(self.commentSayIndex?.row)!].comment.append(model)
            let modelss  =  self.AllModelData[(self.commentSayIndex?.row)!]
            reloadCellHeightForModelAndAtIndexPath(modelss, indexPath: self.commentSayIndex!)
            
            NewRequestCommentSay(withCommentId: (self.commentModel?.id)!, content: text, foundId: self.commentSayId!,mainId: (self.commentModel?.id)!)
        }
        
        
        
        
    }
    
    //评论说说
    private func NewRequestCommentSay(withCommentId commentId: Int,content:String,foundId:Int,mainId:Int){
        let v = NSObject.getEncodeString("20160901")
        
        let para = ["v":v,"uid":userInfo.uid.description,"commentId":commentId,"content":content,"foundId":foundId,"mainId":mainId]
        Alamofire.request(.POST, NSURL(string: testUrl + "/commentfound")!, parameters: para as? [String : AnyObject]).responseString { response -> Void in
            switch response.result {
            case .Success:
                let json = JSON(data: response.data!)
                _ = json.object
                
                
                
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    
    //举报请求
    @objc private func requestJuBaoSay(foundId:Int,typeId:Int){
        let v = NSObject.getEncodeString("20160901")
        
        let para = ["v":v,"uid":userInfo.uid.description,"foundId":foundId,"typeId":typeId]
        
        Alamofire.request(.POST, NSURL(string: testUrl + "/report")!, parameters: para as? [String : AnyObject]).responseString { response -> Void in
            switch response.result {
            case .Success:
                let json = JSON(data: response.data!)
                let dict = (json.object) as! NSDictionary
                
                if ((dict["code"] as! String) == "200" && (dict["flag"] as! String) == "1") {
//                    SVProgressHUD.showSuccessWithStatus("举报成功")
//                    SVProgressHUD.dismissWithDelay(2)
                }
                
            //               NSLog("举报=\(json)")
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    @objc private func distanceBetweenOrderBy(withOldLat oldLat:Double,withOldLng oldLng:Double,withNewLat newLat:Double,withNewLng newLng: Double) -> String {
        let curLocation = CLLocation(latitude: CLLocationDegrees(oldLat), longitude: CLLocationDegrees(oldLng))
        
        let newLocation = CLLocation(latitude: CLLocationDegrees(newLat), longitude: CLLocationDegrees(newLng))
        
        let distance = curLocation.distanceFromLocation(newLocation)
        
        return String(format: "%ld",distance)
    }
    
}



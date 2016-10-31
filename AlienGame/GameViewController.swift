//
//  GameViewController.swift
//  AlienGame
//
//  Created by Wood, Ben on 12/14/15.
// Test
//  Copyright (c) 2015 Wood, Benjamin. All rights reserved.
//

import UIKit
import SpriteKit
import iAd
import Social
import GameKit

protocol GameViewControllerDelegate : NSObjectProtocol {
    func setShareButtonHidden(_ hidden : Bool)
    func ShareFunction(_ sender: AnyObject)
}

class GameViewController: UIViewController, ADBannerViewDelegate, ADInterstitialAdDelegate, GKGameCenterControllerDelegate, GameViewControllerDelegate {

    @IBOutlet var adBannerView: ADBannerView?
    
    var interAd = ADInterstitialAd()
    var interAdView: UIView = UIView()
    
   
    
    var scene = GameScene(fileNamed:"GameScene")
    var Highscore = Int()
    var tweetImage = UIImage()
    var facebookImage = UIImage()
    var scoresScreen = false
    var gameCenterAchievements = [String: GKAchievement]()
    var soundOn = true
    @IBOutlet var facebookButton: UIButton!
 
    @IBOutlet var tweetButton: UIButton!
    
    @IBOutlet var closeButton: UIButton!
    
    @IBAction func ShareFunction(_ sender: AnyObject) {
        GameCenter((scene?.shareBTN)!)
        
    }
    
    @IBOutlet var muteButton: UIButton!
    @IBAction func muteButton(_ sender: AnyObject) {
        
        if soundOn {
            scene?.soundOn = false
            soundOn = false
            muteButton.setTitle("Sound On", for: UIControlState())
            
        } else {
            scene?.soundOn = true
            soundOn = true
            muteButton.setTitle("Sound Off", for: UIControlState())

        }
        
    }
    func loadAchievementPercentages(){
        
        GKAchievement.loadAchievements(completionHandler: { (allAchievements, error) -> Void in
            
            if error != nil {
                
                let alert = UIAlertController(title: "Accounts", message: "Game Center was unable to load.", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:  nil))
                
                alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: {
                    (UIAlertAction) in
                    
                    let settingsURL = URL (string: UIApplicationOpenSettingsURLString)
                    
                    if let url = settingsURL{
                        UIApplication.shared.openURL(settingsURL!)
                        
                        
                    }
                }))
                
                self.present(alert, animated: true, completion: nil)
                
                
            } else {
                
                if (allAchievements != nil) {
                    
                    for theAchievement in allAchievements! {
                        
                        if let singleAchievement: GKAchievement = theAchievement {
                            
                            self.gameCenterAchievements[singleAchievement.identifier!] = singleAchievement
                        }
                    }
                    
                
            }
            }
        })
        
        
        
        
    }

    @IBAction func GameCenter(_ sender: AnyObject) {
        scene?.highScoreLabel.isHidden = true
        saveHighscore((scene?.Highscore)!)
        showLeader()
    }
  
    @IBAction func close(_ sender: AnyObject) {
        
        close()
    }
    @IBAction func tweetAction(_ sender: AnyObject) {
        
        if scene!.playing == false {
            
            Highscore = scene!.Highscore
            
            if SLComposeViewController.isAvailable (forServiceType: SLServiceTypeTwitter){
                
                let twitterController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                twitterController?.setInitialText("@BingBangApp My highscore = \(Highscore). What's yours?")
                twitterController?.add(scene?.captureScreen())
                
                self.present(twitterController!, animated: true, completion: nil)
                
                loadAd()
            }
                
            
            else {
                
                let alert = UIAlertController(title: "Accounts", message: "No Twitter Account Detected", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:  nil))
                
                alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: {
                    (UIAlertAction) in
                    
                    let settingsURL = URL (string: UIApplicationOpenSettingsURLString)
                    
                    if let url = settingsURL{
                        UIApplication.shared.openURL(settingsURL!)
                        
                        
                    }
                }))
                
                self.present(alert, animated: true, completion: nil)
                
                
            }
            
        }
    }
    
    
    @IBAction func facebookAction(_ sender: AnyObject) {
    
        if scene!.playing == false {
        
            
            Highscore = scene!.Highscore

            if SLComposeViewController.isAvailable (forServiceType: SLServiceTypeFacebook){
                
                let facebookController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                
                facebookController?.setInitialText("@BingBangApp My highscore = \(Highscore). What's yours?")
            
                facebookController?.add(scene?.captureScreen())
                
                self.present(facebookController!, animated: true, completion: nil)
                
                loadAd()
            }
                
                
            else {
                
                let alert = UIAlertController(title: "Accounts", message: "No Facebook Account Dectected", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:  nil))
                
                alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: {
                    (UIAlertAction) in
                    
                    let settingsURL = URL (string: UIApplicationOpenSettingsURLString)
                    
                    if let url = settingsURL{
                        UIApplication.shared.openURL(settingsURL!)
                        
                        
                        
                    }
                }))
                
                self.present(alert, animated: true, completion: nil)
                
                
            }
        }
    }

    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        authenticateLocalPlayer()
        loadAd()
        
        closeButton.layer.cornerRadius = 10
        closeButton.clipsToBounds = true
        
        closeButton.removeFromSuperview()
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.pauseGameScene), name: NSNotification.Name(rawValue: "PauseGameScene"), object: nil)

        NotificationCenter.default.addObserver(self, selector: Selector("resumeGameScene"), name: NSNotification.Name(rawValue: "ResumeGameScene"), object: nil)

        if (scene != nil) {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene!.scaleMode = .aspectFill
            
            scene!.gameVCDelegate = self
            
            skView.presentScene(scene)
        }
        
        
        self.canDisplayBannerAds = true
        self.adBannerView?.delegate = self
        self.adBannerView?.isHidden = true
        Highscore = scene!.Highscore


        
       
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func bannerViewWillLoadAd(_ banner: ADBannerView!) {
        
        
    }
    func bannerViewDidLoadAd(_ banner: ADBannerView!) {
        
        self.adBannerView?.isHidden = false
    }
    func bannerViewActionDidFinish(_ banner: ADBannerView!) {
        
        
    }
    func bannerViewActionShouldBegin(_ banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    func bannerView(_ banner: ADBannerView!, didFailToReceiveAdWithError error: Error!) {
        
        self.adBannerView?.isHidden = true
    }
    
    func pauseGameScene() {
        if scene?.playing == true {
            loadAd()
            scene?.pauseGameScene()
        }
        
    
    }
    func close (){
        closeButton.removeFromSuperview()
        interAdView.removeFromSuperview()
        
    }
    
    func loadAd(){
        interAd = ADInterstitialAd()
        interAd.delegate = self
    }
    
    func interstitialAdDidLoad(_ interstitialAd: ADInterstitialAd!) {
        interAdView = UIView()
        interAdView.frame = self.view.bounds
        view.addSubview(interAdView)
        
        interAd.present(in: interAdView)
        UIViewController.prepareInterstitialAds()
        
        interAdView.addSubview(closeButton)
        
        if scene?.playing == true {
            scene?.pauseGameScene()
        }
        
        
    }
    
    func interstitialAdDidUnload(_ interstitialAd: ADInterstitialAd!) {
        
    }
    
    func interstitialAd(_ interstitialAd: ADInterstitialAd!, didFailWithError error: Error!) {
        
        closeButton.removeFromSuperview()
        interAdView.removeFromSuperview()
    }
    
    //send high score to leaderboard
    func saveHighscore(_ score:Int) {
        
        //check if user is signed in
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
            var scoreReporter = GKScore(leaderboardIdentifier: "BingBangAppLeaderboard") //leaderboard id here
            
            scoreReporter.value = Int64((scene?.Highscore)!) //score variable here (same as above)
            
            var scoreArray: [GKScore] = [scoreReporter]
            
            self.gameCenterAchievements.removeAll()
            
            reportAchievement("BingBangAppAchievement10Points", amount: 10.0)
            reportAchievement("BingBangAppAchievement20Points", amount: 20.0)
            reportAchievement("BingBangAppAchievement25Points", amount: 25.0)
            reportAchievement("BingBangAppAchievement35Points", amount: 35.0)
            reportAchievement("BingBangAppAchievement45Points", amount: 45.0)
            reportAchievement("BingBangAppAchievement50Points", amount: 50.0)
            
            
            GKScore.report(scoreArray, withCompletionHandler: {(error : Error?) -> Void in
                if error != nil {
                    
                }
            })
            
        }
        
    }
    
    
    func reportAchievement (_ identifier:String, amount: Double){
        
        let achievement = GKAchievement(identifier: identifier)
        
        var percentage = Double ((Double((scene?.Highscore)!)/amount) * 100)
        
        if percentage > 100 {
            percentage = 100
        }
        achievement.percentComplete = percentage
        let achievementArray: [GKAchievement] = [achievement]
        
        GKAchievement.report(achievementArray, withCompletionHandler: {
            
            error -> Void in
            
            if (error != nil) {
                
                let alert = UIAlertController(title: "Accounts", message: "No GameCenter Account Detected.", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:  nil))
                
                alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: {
                    (UIAlertAction) in
                    
                    let settingsURL = URL (string: UIApplicationOpenSettingsURLString)
                    
                    if let url = settingsURL{
                        UIApplication.shared.openURL(settingsURL!)
                        
                        
                    }
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            } else {
                self.gameCenterAchievements.removeAll()
                self.loadAchievementPercentages()
            }
            
        })
    }
    
    //shows leaderboard screen
    func showLeader() {
        let vc = self.view?.window?.rootViewController
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        vc?.present(gc, animated: true, completion: nil)
    }
    
    //hides leaderboard screen
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController!)
    {
        gameCenterViewController.dismiss(animated: true, completion: nil)
        gameCenterAchievements.removeAll()
        loadAchievementPercentages()
    }
    
    //initiate gamecenter
    func authenticateLocalPlayer(){
        
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            if (viewController != nil) {
                self.present(viewController!, animated: true, completion: nil)
            }
                
            else {

                self.gameCenterAchievements.removeAll()
                self.loadAchievementPercentages()
            }
        }
        
    }
    
    func setShareButtonHidden(_ hidden : Bool) {
        self.tweetButton.isHidden = hidden
        self.facebookButton.isHidden = hidden
        
    }
    



    
    
}

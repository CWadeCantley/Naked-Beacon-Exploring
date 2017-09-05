//
// Please report any problems with this app template to contact@estimote.com
//

import UIKit

//CWC : For audio, add audio framework
import AVFoundation

// Functional Requirements
//1) When BOB is in range, show his picture, play his song
//2) Only play BOB once
//3) When JAN is in range while BOB is play, disregard JAN.  Let BOB finish.


class ViewController: UIViewController, ProximityContentManagerDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var proximityContentManager: ProximityContentManager!
    
    //Some custom variables
    var waskristina = false
    var wasjamie = false
    var wasnohuman = false
    
    var humanName = ""
    var introSongPlayer : AVAudioPlayer?
	
		
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // cwc - spin the circle thingy
        self.activityIndicator.startAnimating()

        // Specify the beacons we are allowed to look for and send it to the framework.
        self.proximityContentManager = ProximityContentManager(
            beaconIDs: [
                BeaconID(UUIDString: "4C6C27FD-8156-91F7-EC19-C6D28314E278", major: 3, minor: 47301), //mint -
                BeaconID(UUIDString: "428AF900-15C0-1085-0445-D8C6EA4ACFB0", major: 1, minor: 13719), ///blueberry -
                BeaconID(UUIDString: "8427B559-F7C5-C8A9-536F-97BD3E190554", major: 2, minor: 24564) //ice Blue - Kristina HardIn
            ],
            beaconContentFactory: CachingContentFactory(beaconContentFactory: BeaconDetailsCloudFactory()))
        
        // Report any resulting delegates to this page, and begin looking for our beacons.
        self.proximityContentManager.delegate = self
        self.proximityContentManager.startContentUpdates()
    }

    //CWC - When the Beacon Framework tells us that a new beacon is the closest, do something with it.
    func proximityContentManager(proximityContentManager: ProximityContentManager, didUpdateContent content: AnyObject?) {
        self.activityIndicator?.stopAnimating()
        self.activityIndicator?.removeFromSuperview()
        self.introSongPlayer?.volume = 1.0
        self.image.hidden = false
        
        if let beaconDetails = content as? BeaconDetails {
            self.view.backgroundColor = beaconDetails.backgroundColor
            
            
            //CWC : This will switch between images, play sound, and change background color.
            switch beaconDetails.beaconName {
            case "ice" :
                if waskristina == false {
                    self.waskristina = true
                    self.image.contentMode = UIViewContentMode.ScaleAspectFill
                    self.image.image = UIImage(named: "KristinaHardin")
                    self.humanName = "Kristina"
                    self.label.text = "Warm round of applause for Kristina!"
                    self.label.textColor = beaconDetails.backgroundColor
                    if let introSong = self.setupAudioPlayerWithFile("KristinaHardinIntro", type:"mp3") {
                        self.introSongPlayer = introSong
                        self.introSongPlayer?.play()
                    }
                }
            case "mint" :
                if wasjamie == false {
                    self.wasjamie = true
                    self.image.contentMode = UIViewContentMode.ScaleAspectFill
                    self.image.image = UIImage(named: "JamieTrinker")
                    self.label.text = "Give it up for Jamie!"
                    self.label.textColor = beaconDetails.backgroundColor
                    if let introSong = self.setupAudioPlayerWithFile("ChrisIntroSong", type:"mp3") {
                        self.introSongPlayer = introSong
                        self.introSongPlayer?.play()
                    }
                }
            default :
                
                if wasnohuman == false {
                    self.wasnohuman = true
                    self.image.contentMode = UIViewContentMode.Center
                    self.image.image = UIImage(named: "Beacon")
                    self.label.text = "Searching for Humans... Stand By."
                    
                }
                
            }
            
            
        } else {
            self.view.backgroundColor = BeaconDetails.neutralColor
            self.label.text = "No Special Humans in range."
            
        }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// Handle the music here
extension ViewController: AVAudioPlayerDelegate {
    
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer?  {
        // CWC - Get the path for the audio files
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        
        // CWC - setup the player
        var audioPlayer:AVAudioPlayer?
        
        // 3
        do {
            // CWC - Try and play whatever URL is put into the Player
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        
        return audioPlayer
    }
    

}



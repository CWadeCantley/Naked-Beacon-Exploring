//
// Please report any problems with this app template to contact@estimote.com
//

class BeaconDetailsCloudFactory: BeaconContentFactory {
    
    func contentForBeaconID(beaconID: BeaconID, completion: (content: AnyObject) -> ()) {
        let beaconDetailsRequest = ESTRequestBeaconDetails(
            proximityUUID: beaconID.proximityUUID, major: beaconID.major, minor: beaconID.minor)
        
        beaconDetailsRequest.sendRequestWithCompletion { (beaconDetails, error) in
            if let beaconDetails = beaconDetails {
                completion(content: BeaconDetails(
                    beaconName: beaconDetails.name ?? "\(beaconID.major):\(beaconID.minor)",
                    beaconColor: beaconDetails.color))
            } else {
                
                //Should there be an issue where the system can't get online to fetch the beacon name and color, use this static method.
                
                //get beacon data from NSUserDefaults
                let systemPreferences = NSUserDefaults.standardUserDefaults()
                let beaconIceSettings = systemPreferences.dictionaryForKey("beaconIceSettings")!
                let beaconBlueberrySettings = systemPreferences.dictionaryForKey("beaconBlueberrySettings")!
                let beaconMintSettings = systemPreferences.dictionaryForKey("beaconMintSettings")!
                
                
                
                switch beaconID.proximityUUID.UUIDString {
                case beaconIceSettings["UUID"]! as! String:
                    completion(content: BeaconDetails(
                        beaconName: "ice",
                        beaconColor: .IcyMarshmallow))
                case beaconBlueberrySettings["UUID"]! as! String:
                    completion(content: BeaconDetails(
                        beaconName: "blueberry",
                        beaconColor: .BlueberryPie))
                case beaconMintSettings["UUID"]! as! String:
                    completion(content: BeaconDetails(
                        beaconName: "mint",
                        beaconColor: .MintCocktail))
                default :
                    NSLog("Couldn't fetch data from Estimote Cloud for beacon \(beaconID), will use default values instead. Double-check if the app ID and app token provided in the AppDelegate are correct, and if the beacon with such ID is assigned to your Estimote Account. The error was: \(error)")
                    completion(content: BeaconDetails(
                        beaconName: "beacon",
                        beaconColor: .Unknown))
                }
                
            }
        }
    }
    
}

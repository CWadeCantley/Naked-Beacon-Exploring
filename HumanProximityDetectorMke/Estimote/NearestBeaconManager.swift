//
// Please report any problems with this app template to contact@estimote.com
//

protocol NearestBeaconManagerDelegate: class {

    func nearestBeaconManager(nearestBeaconManager: NearestBeaconManager, didUpdateNearestBeaconID nearestBeaconID: BeaconID?)

}

class NearestBeaconManager: NSObject, ESTBeaconManagerDelegate {

    weak var delegate: NearestBeaconManagerDelegate?

    private let beaconRegions: [CLBeaconRegion]

    private let beaconManager = ESTBeaconManager()

    private var nearestBeaconID: BeaconID?
    private var firstEventSent = false
    
    private var lastBeacon: CLBeacon?

    init(beaconRegions: [CLBeaconRegion]) {
        self.beaconRegions = beaconRegions

        super.init()

        self.beaconManager.delegate = self
        self.beaconManager.requestWhenInUseAuthorization()
        self.beaconManager.returnAllRangedBeaconsAtOnce = true
    }

    func startNearestBeaconUpdates() {
        for beaconRegion in self.beaconRegions {
            self.beaconManager.startRangingBeaconsInRegion(beaconRegion)
        }
    }

    func stopNearestBeaconUpdates() {
        for beaconRegion in self.beaconRegions {
            self.beaconManager.stopRangingBeaconsInRegion(beaconRegion)
        }
    }
    
    func beaconManager(manager: AnyObject, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) { print("NearestBeaconManager : beaconManager")
        let nearestBeacon = beacons.first
        
        //pass the beacon data higher up for debugging.
        //self.delegate?.beaconsDetected(manager, didRangeBeacons: beacons, inRegion: region)
        
        //If there was a last beacon, do a check.
        if self.lastBeacon != nil {
            
            //
            for beacon in beacons {
                if lastBeacon?.proximityUUID == beacon.proximityUUID && beacon.rssi == 0 {
                    
                    //if the last nearest beacon came back with 0 power suddenly, return to escape out of this function.
                    //Something strange happened and we don't want to push any data quite yet.
                    return
                }
            }
        }
        
        
        //set the last beacon value
        self.lastBeacon = nearestBeacon
        
        if nearestBeacon?.beaconID != self.nearestBeaconID{
            
            //if it didn't return by now, the beacon must be good so push it through the delegate.
            self.nearestBeaconID = nearestBeacon?.beaconID
            self.delegate?.nearestBeaconManager(self, didUpdateNearestBeaconID: self.nearestBeaconID)
            
            print("NEW LOCATION")
            
        }
        
    }

    /*
    func beaconManager(manager: AnyObject, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        let nearestBeacon = beacons.first

        if nearestBeacon?.beaconID != self.nearestBeaconID || !firstEventSent {
            self.nearestBeaconID = nearestBeacon?.beaconID
            self.delegate?.nearestBeaconManager(self, didUpdateNearestBeaconID: self.nearestBeaconID)
            self.firstEventSent = true
        }
    }
     */
    
    func beaconManager(manager: AnyObject, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .Denied || status == .Restricted {
            NSLog("Location Services are disabled for this app, which means it won't be able to detect beacons.")
        }
    }

    func beaconManager(manager: AnyObject, rangingBeaconsDidFailForRegion region: CLBeaconRegion?, withError error: NSError) {
        NSLog("Ranging failed for region: %@. Make sure that Bluetooth and Location Services are on, and that Location Services are allowed for this app. Beacons require a Bluetooth Low Energy compatible device: <http://www.bluetooth.com/Pages/Bluetooth-Smart-Devices-List.aspx>. Note that the iOS simulator doesn't support Bluetooth at all. The error was: %@", region?.identifier ?? "(unknown)", error);
    }

}

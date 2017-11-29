//
//  ViewController.swift
//  CycleMap
//
//  Created by Joni Lassila on 29/11/2017.
//  Copyright © 2017 Joni Lassila. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import StoreKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationButton: MKUserTrackingBarButtonItem!
    @IBOutlet weak var speedLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCycleMap()
        setupLocationManager()
        begForReviews()
    }
    
    func addCycleMap() {
        let overlay = MKTileOverlay(urlTemplate: "https://tile.thunderforest.com/cycle/{z}/{x}/{y}@2x.png?apikey=7760545f91504c6591737b342641aae3")
        overlay.canReplaceMapContent = true
        overlay.tileSize = CGSize(width: 512, height: 512)
        mapView.add(overlay)
    }
    
    func setupLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.locationButton.mapView = mapView
    }
    
    func begForReviews() {
        let appLaunchCount = UserDefaults.standard.integer(forKey: "AppLaunchCount")
        let askedForReview = UserDefaults.standard.bool(forKey: "AskedForReview")
        
        if appLaunchCount >= 5 && !askedForReview {
            SKStoreReviewController.requestReview()
            UserDefaults.standard.set(true, forKey: "AskedForReview")
        }
        
        UserDefaults.standard.set(appLaunchCount+1, forKey: "AppLaunchCount")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        var speedKmh = location.speed * 3.6
        
        if speedKmh < 0 {
            speedKmh = 0
        }
        
        self.speedLabel.text = "\(Int(speedKmh)) km/h"
        
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKTileOverlay {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        
        return MKOverlayRenderer()
    }


}


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

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationButton: MKUserTrackingBarButtonItem!
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCycleMap()
        setupLocationManager()
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKTileOverlay {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        
        return MKOverlayRenderer()
    }


}


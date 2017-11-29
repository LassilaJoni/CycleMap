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

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate , UISearchBarDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationButton: MKUserTrackingBarButtonItem!
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBAction func searchButton(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
        self.view.addSubview(activityIndicator)
//        hide searchbar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch =  MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (response, error) in
            if response == nil
            {
                print("error")
            }
            else
            {
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                self.mapView.addAnnotation(annotation)
                
//                Zooming in on a annotation
                let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
                let span  = MKCoordinateSpanMake(0.1, 0.1)
                let region=MKCoordinateRegionMake(coordinate, span)
                self.mapView.setRegion(region, animated: true)
                
            }
        }
    }
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Cycling Maps", comment: "View Controller's title")
        
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
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
                UserDefaults.standard.set(true, forKey: "AskedForReview")
            }
        }
        
        UserDefaults.standard.set(appLaunchCount+1, forKey: "AppLaunchCount")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        var speedKmh = location.speed * 3.6
        var speedMph = location.speed / 0.44704
        
        if speedKmh < 0 || speedMph < 0 {
            speedKmh = 0
            speedMph = 0
        }
        
        if Locale.current.usesMetricSystem {
            self.speedLabel.text = "\(Int(speedKmh)) km/h"
            
        } else {
            self.speedLabel.text = "\(Int(speedMph)) mph"
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKTileOverlay {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        
        return MKOverlayRenderer()
    }
    
}


//
//  MapViewController.swift
//  CycleMap
//
//  Created by Joni Lassila on 29/11/2017.
//  Copyright © 2017 Joni Lassila. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import StoreKit

class MapViewController: UIViewController {
	
	// MARK Outlets
	
	@IBOutlet private var mapView: MKMapView!
	@IBOutlet private var locationButton: MKUserTrackingBarButtonItem!
    
    @IBOutlet private var speedContainerView: UIVisualEffectView!
    @IBOutlet private var speedLabel: UILabel!
	
	// MARK: Stored Properties
	
	private lazy var locationManager = CLLocationManager()
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = NSLocalizedString("Cycling Maps", comment: "View Controller's title")
		
		// Speed Label
		
		speedContainerView.layer.cornerRadius = 10
		speedContainerView.clipsToBounds = true
		
		speedContainerView.alpha = 0
		
		// Setup
		
		addOverlay()
		setupLocationManager()
		checkRateStatus()
		
		// Search
		
		let searchController = UISearchController(searchResultsController: nil)
			navigationItem.searchController = searchController
			searchController.searchBar.delegate = self
	}
	
	// MARK: Private Methods
	
	private func addOverlay() {
		let apiKey = ""
		
		let overlay = MKTileOverlay(urlTemplate: String(format: "https://tile.thunderforest.com/cycle/{z}/{x}/{y}@2x.png?apikey=%@", apiKey))
		
		overlay.canReplaceMapContent = true
		overlay.tileSize = CGSize(width: 512, height: 512)
		
		mapView.addOverlay(overlay)
	}
	
	private  func setupLocationManager() {
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
		
		locationButton.mapView = mapView
	}
	
	private func checkRateStatus() {
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
}

// MARK: MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		return MKTileOverlayRenderer(overlay: overlay)
	}
}

// MARK: CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.first else {
			return
		}
		
		speedContainerView.alpha = (location.speed > 0) ? 1 : 0
		
		if Locale.current.usesMetricSystem {
			let speed = location.speed * 3.6
			speedLabel.text = String(format: "%i km/h", (speed > 0) ? Int(speed) : 0)
		} else {
			let speed = location.speed / 0.44704
			speedLabel.text = String(format: "%i mph", (speed > 0) ? Int(speed) : 0)
		}
	}
}

// MARK: UISearchBarDelegate

extension MapViewController: UISearchBarDelegate {
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		navigationItem.searchController?.resignFirstResponder()
		navigationItem.searchController?.dismiss(animated: true, completion: nil)
		
		let searchRequest = MKLocalSearch.Request()
		searchRequest.naturalLanguageQuery = searchBar.text
		
		MKLocalSearch(request: searchRequest).start { response, error in
			guard let response = response, error == nil else {
				print(error?.localizedDescription ?? "")
				return
			}
			
			let latitude = response.boundingRegion.center.latitude
			let longitude = response.boundingRegion.center.longitude
			
			let annotation = MKPointAnnotation()
			annotation.title = searchBar.text
			annotation.subtitle = response.mapItems.first?.name
			annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
			
			self.mapView.addAnnotation(annotation)
			
			let span = MKCoordinateSpan.init(latitudeDelta: 0.06, longitudeDelta: 0.06)
			let region = MKCoordinateRegion.init(center: annotation.coordinate, span: span)
			
			self.mapView.setRegion(region, animated: true)
			
		}
	}
}

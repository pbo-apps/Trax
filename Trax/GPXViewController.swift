//
//  GPXViewController.swift
//  Trax
//
//  Created by Pete Bounford on 03/03/2017.
//  Copyright © 2017 PBO Apps. All rights reserved.
//

import UIKit
import MapKit

class GPXViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Model
    var gpxUrl: URL? {
        didSet {
            clearWaypoints()
            if let url = gpxUrl {
                GPX.parse(url, completionHandler: { gpx in
                    if gpx != nil {
                        self.addWaypoints(gpx!.waypoints)
                    }
                })
            }
        }
    }
    
    private func clearWaypoints() {
        mapView?.removeAnnotations(mapView.annotations)
    }
    
    private func addWaypoints(_ waypoints: [GPX.Waypoint]) {
        mapView?.addAnnotations(waypoints)
        mapView?.showAnnotations(waypoints, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gpxUrl = URL(string: "https://cs193p.stanford.edu/Vacation.gpx")
    }
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .satellite
            mapView.delegate = self
        }
    }

}


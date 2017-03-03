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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var view: MKAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.AnnotationViewReuseIdentifier)
        
        // Need to check for null because this could be the first ever pin (there are no prototypes like in TableView)
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            view.canShowCallout = true
        } else {
            view.annotation = annotation
        }
        view.leftCalloutAccessoryView = nil
        if let waypoint = annotation as? GPX.Waypoint {
            if waypoint.thumbnailUrl != nil {
                view.leftCalloutAccessoryView = UIButton(frame: Constants.LeftCalloutFram)
            }
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let thumbnailImageButton = view.leftCalloutAccessoryView as? UIButton,
            let url = (view.annotation as? GPX.Waypoint)?.thumbnailUrl,
            let imageData = NSData(contentsOf: url), // blocks main queue!!!
            let image = UIImage(data: imageData as Data) {
            thumbnailImageButton.setImage(image, for: .normal)
        }
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
    
    // MARK: Constants
    
    private struct Constants {
        static let LeftCalloutFram = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewReuseIdentifier = "Waypoint"
        static let ShowImageSegueIdentifier = "Show Image"
        static let EditUserWaypoint = "Edit Waypoint"
    }

}


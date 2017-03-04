//
//  GPXViewController.swift
//  Trax
//
//  Created by Pete Bounford on 03/03/2017.
//  Copyright © 2017 PBO Apps. All rights reserved.
//

import UIKit
import MapKit

class GPXViewController: UIViewController, MKMapViewDelegate, UIPopoverPresentationControllerDelegate {

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
        
        view.isDraggable = annotation is EditableWaypoint
        view.leftCalloutAccessoryView = nil
        view.rightCalloutAccessoryView = nil
        
        if let waypoint = annotation as? GPX.Waypoint {
            if waypoint.thumbnailUrl != nil {
                view.leftCalloutAccessoryView = UIButton(frame: Constants.LeftCalloutFram)
            }
            if waypoint is EditableWaypoint {
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let thumbnailImageButton = view.leftCalloutAccessoryView as? UIButton,
            let url = (view.annotation as? GPX.Waypoint)?.thumbnailUrl {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                if let imageData = NSData(contentsOf: url),
                    let image = UIImage(data: imageData as Data) {
                    DispatchQueue.main.async {
                        thumbnailImageButton.setImage(image, for: .normal)
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.leftCalloutAccessoryView {
            performSegue(withIdentifier: Constants.ShowImageSegueIdentifier, sender: view)
        } else if control == view.rightCalloutAccessoryView {
            mapView.deselectAnnotation(view.annotation, animated: true)
            performSegue(withIdentifier: Constants.EditUserWaypointSegueIdentifier, sender: view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gpxUrl = URL(string: "https://cs193p.stanford.edu/Vacation.gpx")
    }
    
    private func select(annotation waypoint: GPX.Waypoint?) {
        if waypoint != nil {
            mapView.selectAnnotation(waypoint!, animated: true)
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func updatedUserWaypoint(with segue: UIStoryboardSegue) {
        select(annotation: (segue.source.contentVC as? EditWaypointViewController)?.waypointToEdit)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination.contentVC
        let annotationView = sender as? MKAnnotationView
        let waypoint = annotationView?.annotation as? GPX.Waypoint
        
        if segue.identifier == Constants.ShowImageSegueIdentifier {
            if let ivc = destination as? ImageViewController {
                ivc.imageURL = waypoint?.imageUrl
                ivc.title = waypoint?.name
            }
        } else if segue.identifier == Constants.EditUserWaypointSegueIdentifier {
            if let editableWaypoint = waypoint as? EditableWaypoint,
                let ewvc = destination as? EditWaypointViewController {
                if let ppc = ewvc.popoverPresentationController {
                    ppc.sourceRect = annotationView!.frame
                    ppc.delegate = self
                }
                ewvc.waypointToEdit = editableWaypoint
            }
        }
    }
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .satellite
            mapView.delegate = self
        }
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        select(annotation: (popoverPresentationController.presentedViewController as? EditWaypointViewController)?.waypointToEdit)
    }
    
    @IBAction func addWaypoint(_ sender: UILongPressGestureRecognizer) {
        // Drop the pin as soon as we recognise the gesture
        if sender.state == .began {
            let coordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            let waypoint = EditableWaypoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            waypoint.name = "Dropped"
            mapView.addAnnotation(waypoint)
        }
    }
    
    // MARK: Constants
    
    private struct Constants {
        static let LeftCalloutFram = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewReuseIdentifier = "Waypoint"
        static let ShowImageSegueIdentifier = "Show Image"
        static let EditUserWaypointSegueIdentifier = "Edit Waypoint"
    }

}

extension UIViewController {
    var contentVC: UIViewController {
        if let navCon = self as? UINavigationController {
            return navCon.visibleViewController ?? navCon
        } else {
            return self
        }
    }
}


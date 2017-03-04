//
//  MKGPX.swift
//  Trax
//
//  Created by Pete Bounford on 03/03/2017.
//  Copyright © 2017 PBO Apps. All rights reserved.
//

import MapKit

// Add subclass which allows dragging of the waypoint (because we now have a setter for the coordinate)
class EditableWaypoint: GPX.Waypoint {

    override var coordinate: CLLocationCoordinate2D {
        get {
            return super.coordinate
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
}

extension GPX.Waypoint: MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String? { return name }
    
    var subtitle: String? { return info }
    
    var thumbnailUrl: URL? {
        return getImageUrl(of: "thumbnail")
    }
    
    var imageUrl: URL? {
        return getImageUrl(of: "large")
    }
    
    private func getImageUrl(of type: String?) -> URL? {
        for link in links {
            if link.type == type {
                return link.url
            }
        }
        return nil
    }
}

//
//  MapViewController.swift
//  Yelp
//
//  Created by Gelei Chen on 25/1/2016.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var qTree = QTree()
    let locationManager = CLLocationManager()
    var businessArray:[Business]!
    var cacheArray : [Business] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let zoomRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: 37.785771, longitude: -122.406165), 1000, 1000)
        self.mapView.setRegion(zoomRegion, animated: true)
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.mapType = MKMapType.Standard
        
        for bussiness in businessArray {
            let annotation = scholarAnnotation(coordinate: CLLocationCoordinate2DMake(Double(bussiness.latitude!), Double(bussiness.longitude!)), title: bussiness.name!, subtitle: bussiness.name!, profilePictureUrl: bussiness.imageURL!.absoluteString)
            self.qTree.insertObject(annotation)
        }
        self.reloadAnnotations()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(QCluster.classForCoder()) {
            
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(ClusterAnnotationView.reuseId()) as? ClusterAnnotationView
            if annotationView == nil {
                annotationView = ClusterAnnotationView(cluster: annotation)
            }
            //annotationView!.canShowCallout = true
            //
            annotationView!.cluster = annotation
            return annotationView
        } else if annotation.isKindOfClass(scholarAnnotation.classForCoder()) {
            let customAnnotation = annotation as! scholarAnnotation
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("ScholarAnnotation")
            
//            if pinView == nil {
//                pinView = MKAnnotationView(annotation: customAnnotation, reuseIdentifier: "ScholarAnnotation")
//                pinView?.canShowCallout = true
//                pinView?.leftCalloutAccessoryView = UIImageView(image: UIImage(named: "Movie"))
//                pinView!.rightCalloutAccessoryView = UIButton(type:UIButtonType.DetailDisclosure)
//                
//            } else {
//                pinView!.annotation = customAnnotation
//                
//                
//            }
            
            return pinView
        }
        return nil
    }
    
    
    func reloadAnnotations(){
        if self.isViewLoaded() == false {
            return
        }
        let mapRegion = self.mapView.region
        let minNonClusteredSpan = min(mapRegion.span.latitudeDelta, mapRegion.span.longitudeDelta) / 5
        let objects = self.qTree.getObjectsInRegion(mapRegion, minNonClusteredSpan: minNonClusteredSpan) as NSArray
        
        let annotationsToRemove = (self.mapView.annotations as NSArray).mutableCopy() as! NSMutableArray
        annotationsToRemove.removeObject(self.mapView.userLocation)
        annotationsToRemove.removeObjectsInArray(objects as [AnyObject])
        self.mapView.removeAnnotations(annotationsToRemove as [AnyObject] as! [MKAnnotation])
        let annotationsToAdd = objects.mutableCopy() as! NSMutableArray
        annotationsToAdd.removeObjectsInArray(self.mapView.annotations)
        
        self.mapView.addAnnotations(annotationsToAdd as [AnyObject] as! [MKAnnotation])

        
        
    }
    
    
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.reloadAnnotations()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

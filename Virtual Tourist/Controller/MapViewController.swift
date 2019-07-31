//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by A.M.W on 7/8/19.
//  Copyright © 2019 AW. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var tapPinToDelete: UILabel!
    
    @IBOutlet weak var edit: UIBarButtonItem!
    
    @IBOutlet var longPress: UILongPressGestureRecognizer!
    
    var fetchedResultController: NSFetchedResultsController<Pin>!
    var deleteFlag:Bool!
    
    
    override func viewDidLoad() {
         super.viewDidLoad()
        deleteFlag = false
        mapView.delegate = self
        mapView.addGestureRecognizer(longPress)
        setupFetchedResultsController()
        tapPinToDelete.isHidden = true
        print()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        if let pins = fetchedResultController.fetchedObjects {
            showPinsOnTheMap(pins: pins)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PhotoAlbumVC" {
            let controller = segue.destination as! PhotoAlbumViewController
            let selectedPin = sender as! Pin
            controller.selectedPin = selectedPin
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultController = nil
    }
    
    
    func showPinsOnTheMap(pins: [Pin]) {
        if mapView.annotations.count != 0 {
            mapView.removeAnnotations(mapView.annotations)
        }
        
        for pin in pins {
            let pinAnnotation = PinPoint(pin: pin)
            mapView.addAnnotation(pinAnnotation)
        }
    }
    
    
    func getDataFromDB(_ mapView: MKMapView,didSelect view: MKAnnotationView,annotation: PinPoint){
        
        guard let photoAlbumViewController = self.storyboard?.instantiateViewController(withIdentifier: "photoView") as? PhotoAlbumViewController else {return}
        
        if let pin = annotation.pinObject {
            photoAlbumViewController.pin = pin
        }
        
        mapView.deselectAnnotation(view.annotation!, animated: true)
        self.navigationController?.pushViewController(photoAlbumViewController, animated: true)
        mapView.deselectAnnotation(view.annotation!, animated: true)
        
        
    }
    
    func getDataFromFlicker(_ mapView: MKMapView,didSelect view: MKAnnotationView,annotation: PinPoint,coordinate: CLLocationCoordinate2D){
        FlickrClient.searchPhotos(latitude: Double(coordinate.latitude), longitude: Double(coordinate.longitude) , done: { (arrImges) in
            
            guard let photoAlbumViewController = self.storyboard?.instantiateViewController(withIdentifier: "photoView") as? PhotoAlbumViewController else {return}
            
            if let pin = annotation.pinObject {
                
                photoAlbumViewController.pin = pin
    
            }
            
            photoAlbumViewController.arrFlickerImages = arrImges
            mapView.deselectAnnotation(view.annotation!, animated: true)
            self.navigationController?.pushViewController(photoAlbumViewController, animated: true)
        }) { (Error) in
            self.showFailureFromViewController(viewController: self, message: Error.localizedDescription )
            mapView.deselectAnnotation(view.annotation!, animated: true)
        }
        
    }
    
    func pushAlbumVC(pin: Pin) {
        guard let albumVC = storyboard?.instantiateViewController(withIdentifier: "photoView") as? PhotoAlbumViewController else {
            return
        }
        albumVC.pin = pin
        navigationController?.pushViewController(albumVC, animated: true)
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if !deleteFlag {
            
            let annotation = (view.annotation) as! PinPoint
            if let pin = annotation.pinObject {
                pushAlbumVC(pin: pin)
            }
            mapView.deselectAnnotation(annotation, animated: true)
            
        } else {
            let lat = Double(view.annotation!.coordinate.latitude)
            let long = Double(view.annotation!.coordinate.longitude)
            deletePinFromDB(latitude: lat, longitude: long)
            mapView.removeAnnotation(view.annotation!)
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    @IBAction func addNewPin(_ sender: Any) {
        guard let gesture = sender as? UILongPressGestureRecognizer else {
            return
        }
        guard gesture.state == .began else {
            return
        }
        let pressedPoint = gesture.location(in: mapView)
        let pointCordination = mapView.convert(pressedPoint, toCoordinateFrom: mapView)
        let pin = PinCoreData.getNewPin(latitude: pointCordination.latitude, longitude: pointCordination.longitude)
        let annotation = PinPoint(pin: pin)
        mapView.addAnnotation(annotation)
    }
    
    

    @IBAction func deletePinBt(_ sender: Any) {
        deletePinsMap()
    }
    
    
    func deletePinsMap(){
        if !deleteFlag {
            changeBarButtonTitle("Done")
            tapPinToDelete.isHidden = false
            self.deleteFlag = true
        } else {
            changeBarButtonTitle("Edit")
            tapPinToDelete.isHidden = true
            self.deleteFlag = false
            
        }
    }
    
    
    func changeBarButtonTitle(_ text: String) {
        self.navigationItem.rightBarButtonItem! = UIBarButtonItem(title: text, style: UIBarButtonItem.Style.done, target: self, action: #selector(MapViewController.deletePinBt(_:)))
       
    }
    

    
    
    func deletePinFromDB(latitude: Double,longitude: Double){
        if let pins = fetchedResultController.fetchedObjects {
            for pin in pins {
                
                if pin.latitude == latitude && pin.longitude == longitude {
                    PinCoreData.deletePin(pin: pin)
                }
            }
        }
    }
    
    
}



extension MapViewController: NSFetchedResultsControllerDelegate {

    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: "pin")
        
        fetchedResultController.delegate = self

        do {
            try fetchedResultController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
}


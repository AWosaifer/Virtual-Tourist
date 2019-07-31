//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by A.M.W on 7/8/19.
//  Copyright © 2019 AW. All rights reserved.
//

import MapKit
import UIKit
import CoreData
import Kingfisher
import Alamofire

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, MKMapViewDelegate {
    
    @IBOutlet weak var vTMapView: MKMapView!
    
    @IBOutlet weak var vTCollectionView: UICollectionView!
    
    @IBOutlet weak var newCollectionBt: UIButton!
    
    @IBOutlet weak var collectionViewFlow: UICollectionViewFlowLayout!
    
    @IBOutlet weak var tempLabel: UILabel!
    
    var fetchedResultsController:NSFetchedResultsController<Images>!
    var arrDBImage = [UIImage]()
    var pin:Pin?
    var selectedPin : Pin!    
    
    private let dataManager = DataManager(baseURL: API.AuthenticatedBaseURL)

    var deleteflag:Bool = false
    var coordinates:CLLocationCoordinate2D?
    var arrFlickerImages = [FlickrImage]()
    var selectedImageToDelete:[Images]?
    var selectedIndexPath = IndexPath()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        ensurePhotosAppearance()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        selectedImageToDelete = [Images]()
        deleteflag = false
        vTCollectionView.delegate = self
        vTCollectionView.dataSource = self
        setUpMap()
        let space:CGFloat = 2.0
        let dimension = (vTCollectionView.frame.size.width - (2 * space)) / 3.0
        collectionViewFlow.minimumInteritemSpacing = space
        collectionViewFlow.minimumLineSpacing = space
        collectionViewFlow.itemSize = CGSize(width: dimension, height: dimension)


            dataManager.weatherDataForLocation(latitude: pin!.latitude, longitude: pin!.longitude) { (response, error) in
                print("Hey this is weather response:")
                if let response = response?["currently"] as? [String:Any]{
                    // assign your labels here
                    
                    
                    print(response["temperature"]) //example of string out put : 108.41
                    print(response["summary"]) //example of string out put : Clear
                    
                    
                    if let temperature = response["temperature"], let summary = response["summary"] as? String{
                        let alertVC = UIAlertController(title: "", message: "Weather temerature is : \((temperature)) \n and it feels like \(summary)", preferredStyle: .alert)
                        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertVC, animated: true, completion: nil)
                    }
               
                }
               // print(response)
            }
        
       // dataModel.requestData()
    }
    
    
    func setUpMap(){
        vTMapView.delegate = self
        coordinates = CLLocationCoordinate2DMake(pin!.latitude, pin!.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates!
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: coordinates!, span: span)
        vTMapView.setRegion(region, animated: true)
        vTMapView.addAnnotation(annotation)
    }
    
    fileprivate func ensurePhotosAppearance() {
        if fetchedResultsController.fetchedObjects?.count == 0 {
            loadPhotos()
        }
    }
    
    func loadPhotos() {
        FlickrClient.searchPhotos(latitude: self.pin!.latitude, longitude: self.pin!.longitude, done: { images in

            if images.count == 0 {
                self.showFailureFromViewController(viewController: self, message: "There is no photos here please choose another location")
            }
            else {
                PhotoCoreData.savePhotos(pin: self.pin!, images: images)
            }

        }) { (error) in
            self.showFailureFromViewController(viewController: self, message: error.localizedDescription)
        }

    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let image = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        cell.image = image
        cell.layer.borderWidth = 0
        cell.layer.borderColor = UIColor.clear.cgColor
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        var cell = collectionView.cellForItem(at: indexPath)
        if cell!.layer.borderWidth != 0.0 {
            newCollectionBt.setTitle("Remove Selected Pictures", for: .normal)
            deleteflag = true
            let photoToBeDeselect = fetchedResultsController.object(at: indexPath)
            if let index = selectedImageToDelete!.firstIndex(of:photoToBeDeselect){
                selectedImageToDelete!.remove(at: index)
            }
            cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.borderWidth = 0
            cell?.layer.borderColor = UIColor.gray.cgColor
            
            if selectedImageToDelete!.isEmpty {
                newCollectionBt.setTitle("New Collection", for: .normal)
                deleteflag = false
            }
        }
        else {// select
            let photoToBeDeleted = fetchedResultsController.object(at: indexPath)
            newCollectionBt.setTitle("Remove Selected Pictures", for: .normal)
            deleteflag = true
            selectedImageToDelete!.append(photoToBeDeleted)
            cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.borderWidth = 10.0
            cell?.layer.borderColor = UIColor.gray.cgColor
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
    

    
    
    
    @IBAction func clickNewCollection(_ sender: Any){
    if deleteflag {
    newCollectionBt.setTitle("New Collection", for: .normal)
        PhotoCoreData.deletePhotos(photos: selectedImageToDelete!)
    selectedImageToDelete = [Images]()
        deleteflag = false
         
    }else {
    newCollectionBt.setTitle("New Collection", for: .normal)
    guard fetchedResultsController.fetchedObjects!.count > 0 else {
    return
    }
    PhotoCoreData.deletePhotos(photos: fetchedResultsController.fetchedObjects!)
    loadPhotos()
    }
}
}


    
          
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Images> = Images.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "pin == %@", pin!)
        fetchRequest.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert,.delete :
            vTCollectionView.reloadData()
        default:
            break
        }
   
    }

}


//
//  ViewController.swift
//  chpanPW7
//
//  Created by ZhengWu Pan on 25.01.2022.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(mapView)
        let leftMargin:CGFloat = 0
        let topMargin:CGFloat = 0
        let mapWidth:CGFloat = view.frame.size.width
        let mapHeight:CGFloat = view.frame.size.height
        
        
        mapView.frame = CGRect(x: leftMargin, y: topMargin, width: mapWidth, height: mapHeight)
        
    
        configureUI()
        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .darkContent
    }
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.layer.masksToBounds = true
        mapView.layer.cornerRadius = 5
        mapView.clipsToBounds = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        mapView.showsUserLocation = true
        return mapView
    }()
    
    private func configureUI(){
    }
    
    
}


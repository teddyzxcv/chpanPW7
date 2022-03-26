//
//  ViewController.swift
//  chpanPW7
//
//  Created by ZhengWu Pan on 25.01.2022.
//

import UIKit
import CoreLocation
import MapKit
import MapboxMaps
import MapboxSearch
import MapboxSearchUI

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var navController = AdvancedViewController()
    
    let searchController = MapboxSearchController()
    
    var panelController : MapboxPanelController? = nil
    
    var annotationManager: CircleAnnotationManager?
    
    var searchFromOrTo: MapButton?
    
    var fromAnnotation: CircleAnnotation? = nil
    
    var toAnnotation: CircleAnnotation? = nil
    
    internal var mapView: MapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchFromOrTo = startLocation
        
        let myResourceOptions = ResourceOptions(accessToken: Bundle.main.object(forInfoDictionaryKey: "MBXAccessToken") as! String)
        let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions)
        mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.location.delegate = self
        self.view.addSubview(mapView)
        
        configureUI()
        searchController.delegate = self
        mapView.location.options.puckType = .puck2D()
        panelController = MapboxPanelController(rootViewController: searchController)
        addChild(panelController!)
        annotationManager = mapView.annotations.makeCircleAnnotationManager()
        mapView.ornaments.options.compass.visibility = .visible
        mapView.ornaments.options.compass.position = .bottomRight
        mapView.ornaments.options.compass.margins.y = view.center.y - 50
        mapView.ornaments.options.compass.margins.x = 20
    }
    
    func requestPermissionsButtonTapped() {
        mapView.location.requestTemporaryFullAccuracyPermissions(withPurposeKey: "CustomKey")
    }
    
    func showResults(_ results: SearchResult) {
        buttonClear.isEnabled = true
        buttonClear.setTitleColor(.white, for: .normal)
        annotationManager?.annotations.removeAll()
        if(fromAnnotation != nil){
            annotationManager?.annotations.append(fromAnnotation!)
        }
        if(toAnnotation != nil){
            annotationManager?.annotations.append(toAnnotation!)
        }
        let newCamera = CameraOptions(center: results.coordinate,
                                      padding: .zero,
                                      anchor: .zero,
                                      zoom: 14.5,
                                      bearing: 0.0,
                                      pitch: 15.0)
        self.mapView.camera.fly(to: newCamera, duration: 2.0)
        
    }
    

    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .darkContent
    }
    
    private let buttonStack: UIStackView = UIStackView()
    
    private let zoomButtonStack: UIStackView = UIStackView()
    
    let userLocationButton: MapButton = MapButton(backColor: UIColor.cyan.cgColor, text: "X", frame: CGRect(x: 20, y: 0, width: 30, height: 30))
    
    let zoomInButton: MapButton = MapButton(backColor: UIColor.black.cgColor, text: "+", frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
    let zoomOutButton: MapButton = MapButton(backColor: UIColor.black.cgColor, text: "-", frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
    private let buttonGo: MapButton = MapButton(backColor: UIColor.blue.cgColor, text: "Go", frame: CGRect(x: 0, y: 0, width: 120, height: 40))
    
    private let buttonClear: MapButton = MapButton(backColor: UIColor.lightGray.cgColor, text: "Clear", frame: CGRect(x: 0, y: 0, width: 120, height: 40))
    
    let startLocation: MapButton = {
        let control = MapButton(backColor: UIColor.lightGray.cgColor, text: "From", frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        control.addTarget(self, action: #selector(fromPressed), for: .touchUpInside)
        return control
    }()
    
    let endLocation:  MapButton = {
        let control = MapButton(backColor: UIColor.lightGray.cgColor, text: "To", frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        control.addTarget(self, action: #selector(toPressed), for: .touchUpInside)
        
        return control
    }()
    
    let textStack = UIStackView()
    
    @objc func fromPressed(){
        panelController?.setState(.opened)
        panelController?.becomeFirstResponder()
        searchFromOrTo = startLocation
    }
    
    @objc func toPressed(){
        panelController?.setState(.opened)
        panelController?.becomeFirstResponder()
        searchFromOrTo = endLocation
    }
    
    @objc func userLocationPressed() {
        let newCamera = CameraOptions(center: mapView.location.latestLocation?.coordinate,
                                      padding: .zero,
                                      anchor: .zero,
                                      zoom: 14.5,
                                      bearing: 0.0,
                                      pitch: 15.0)
        self.mapView.camera.fly(to: newCamera, duration: 1.5)
        
    }
    
    private func configureUI(){
        userLocationButton.center = view.center
        userLocationButton.addTarget(self, action: #selector(userLocationPressed), for: .touchUpInside)
        userLocationButton.center.x = 40
        buttonClear.addTarget(self, action: #selector(clearButtonWasPressed), for: .touchUpInside)
        buttonStack.addArrangedSubview(buttonGo)
        buttonStack.addArrangedSubview(buttonClear)
        buttonStack.frame = CGRect(x: 0, y: view.frame.size.height - 50, width: view.frame.size.width-30, height: 40)
        buttonStack.center = view.center
        buttonStack.center.y = 180
        buttonStack.spacing = 30
        buttonStack.alignment = .fill
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        textStack.axis = .vertical
        view.addSubview(textStack)
        view.addSubview(userLocationButton)
        textStack.spacing = 10
        textStack.pin(to: view, [.top: 50, .left: 10, .right:10])
        [startLocation, endLocation].forEach{ textField in
            textField.setHeight(to: 40)
            textStack.addArrangedSubview(textField)
        }
        view.addSubview(buttonStack)
        buttonClear.setTitleColor(UIColor.gray, for: .normal)
        buttonGo.addTarget(self, action: #selector(goButtonWasPressed), for: .touchUpInside)
        zoomButtonStack.frame = CGRect(x: 0, y: 0, width: 50, height: 200)
        zoomButtonStack.addArrangedSubview(zoomInButton)
        zoomButtonStack.addArrangedSubview(zoomOutButton)
        zoomButtonStack.center = view.center
        zoomButtonStack.center.x = view.frame.size.width - 40
        zoomButtonStack.spacing = 100
        zoomButtonStack.axis = .vertical
        zoomButtonStack.distribution = .fillEqually
        zoomInButton.addTarget(self, action: #selector(zoomInPressed), for: .touchUpInside)
        zoomOutButton.addTarget(self, action: #selector(zoomOutPressed), for: .touchUpInside)
        view.addSubview(zoomButtonStack)
    }
    
    @objc func zoomInPressed(){
        let newCamera = CameraOptions(center: mapView.cameraState.center,
                                      padding: .zero,
                                      anchor: .zero,
                                      zoom: mapView.cameraState.zoom + 1,
                                      bearing: mapView.cameraState.bearing,
                                      pitch: mapView.cameraState.pitch)
        mapView.camera.fly(to: newCamera, duration: 0.2)
    }
    
    @objc func zoomOutPressed(){
        let newCamera = CameraOptions(center: mapView.cameraState.center,
                                      padding: .zero,
                                      anchor: .zero,
                                      zoom: mapView.cameraState.zoom - 1,
                                      bearing: mapView.cameraState.bearing,
                                      pitch: mapView.cameraState.pitch)
        mapView.camera.fly(to: newCamera, duration: 0.2)
        
    }
    
    @objc func clearButtonWasPressed(){
        startLocation.setTitle( "From", for: .normal)
        endLocation.setTitle( "To", for: .normal)
        startLocation.setTitleColor(.white, for: .disabled)
        endLocation.setTitleColor(.white, for: .disabled)
        startLocation.backgroundColor = .lightGray
        endLocation.backgroundColor = .lightGray
        
        buttonClear.setTitleColor(.gray, for: .disabled)
        buttonClear.backgroundColor = .lightGray
        buttonClear.isEnabled = false
        annotationManager?.annotations.removeAll()
        fromAnnotation = nil
        toAnnotation = nil
    }
    
    @objc func goButtonWasPressed(){
        navController = AdvancedViewController()
        if(fromAnnotation == nil){
            fromAnnotation = CircleAnnotation(centerCoordinate: mapView.location.latestLocation!.coordinate )
        }
        if(toAnnotation == nil){
            return
        }
        navController.coordinates = [fromAnnotation!.point.coordinates, toAnnotation!.point.coordinates]
        panelController?.setState(.hidden)
        addChild(navController)
        view.addSubview(navController.view)
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .blue
        return render
    }
    
}

extension MapViewController: SearchControllerDelegate {
    func showCategoryResults() {
        let newCamera = CameraOptions(center: mapView.location.latestLocation?.coordinate,
                                      padding: .zero,
                                      anchor: .zero,
                                      zoom: 12,
                                      bearing: 0.0,
                                      pitch: 15.0)
        self.mapView.camera.fly(to: newCamera, duration: 2.0)
        
    }
    
    func categorySearchResultsReceived(category: SearchCategory, results: [SearchResult]) {
        annotationManager?.annotations.removeAll()
        results.forEach{ result in
            var annotation = CircleAnnotation(centerCoordinate: result.coordinate)
            annotation.circleColor = StyleColor(.orange)
            annotation.circleRadius = 10
            annotationManager?.annotations.append(annotation)
        }
        showCategoryResults()
    }
    
    func searchResultSelected(_ searchResult: SearchResult) {
        print(searchResult.name)
        searchFromOrTo!.backgroundColor = UIColor.blue
        searchFromOrTo!.setTitleColor(UIColor.white, for: .normal)
        searchFromOrTo!.setTitle(searchResult.name, for: .normal)
        var annotation = CircleAnnotation(centerCoordinate: searchResult.coordinate)
        annotation.circleColor = StyleColor(.red)
        annotation.circleRadius = 10
        if (searchFromOrTo == startLocation) {
            fromAnnotation = annotation
        } else {
            toAnnotation = annotation
        }
        showResults(searchResult)
    }
    func userFavoriteSelected(_ userFavorite: FavoriteRecord) { }
    func shouldCollapseForSelection(_ searchResult: SearchResult) -> Bool {
        return true
    }
}

extension MapViewController: LocationPermissionsDelegate {
    func locationManager(_ locationManager: LocationManager, didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization) {
        if accuracyAuthorization == .reducedAccuracy {
            // Perform an action in response to the new change in accuracy
        }
    }
}





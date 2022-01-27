//
//  ViewController.swift
//  chpanPW7
//
//  Created by ZhengWu Pan on 25.01.2022.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(mapView)
        let leftMargin:CGFloat = 0
        let topMargin:CGFloat = 0
        let mapWidth:CGFloat = view.frame.size.width
        let mapHeight:CGFloat = view.frame.size.height
        
        
        mapView.frame = CGRect(x: leftMargin, y: topMargin, width: mapWidth, height: mapHeight)
        
        
        configureUI()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        mapView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .darkContent
    }
    
    var coordinates: [CLLocationCoordinate2D] = []
    
    private func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> ()){
        DispatchQueue.global(qos: .background).async {
            CLGeocoder().geocodeAddressString(address){
                completion($0?.first?.location?.coordinate, $1)
            }
        }
    }
    
    private let buttonStack: UIStackView = UIStackView()
    
    private let buttonGo: MapButton = MapButton(backColor: UIColor.blue.cgColor, text: "Go", frame: CGRect(x: 0, y: 0, width: 120, height: 40))
    
    private let buttonClear: MapButton = MapButton(backColor: UIColor.lightGray.cgColor, text: "Clear", frame: CGRect(x: 0, y: 0, width: 120, height: 40))
    
    let startLocation: UITextField = {
        let control = UITextField()
        control.backgroundColor = UIColor.lightGray
        control.textColor = UIColor.black
        control.placeholder = "From"
        control.layer.cornerRadius = 2
        control.clipsToBounds = false
        control.font = UIFont.systemFont(ofSize: 15)
        control.borderStyle = UITextField.BorderStyle.roundedRect
        control.autocorrectionType = UITextAutocorrectionType.yes
        control.keyboardType = UIKeyboardType.default
        control.returnKeyType = UIReturnKeyType.done
        control.clearButtonMode = UITextField.ViewMode.whileEditing
        control.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return control
    }()
    
    let endLocation: UITextField = {
        let control = UITextField()
        control.backgroundColor = UIColor.lightGray
        control.textColor = UIColor.black
        control.placeholder = "To"
        control.layer.cornerRadius = 2
        control.clipsToBounds = false
        control.font = UIFont.systemFont(ofSize: 15)
        control.borderStyle = UITextField.BorderStyle.roundedRect
        control.autocorrectionType = UITextAutocorrectionType.yes
        control.keyboardType = UIKeyboardType.default
        control.returnKeyType = UIReturnKeyType.done
        control.clearButtonMode = UITextField.ViewMode.whileEditing
        control.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return control
    }()
    
    let textStack = UIStackView()
    
    
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
        buttonClear.addTarget(self, action: #selector(clearButtonWasPressed), for: .touchUpInside)
        buttonStack.addArrangedSubview(buttonGo)
        buttonStack.addArrangedSubview(buttonClear)
        buttonStack.frame = CGRect(x: 0, y: view.frame.size.height - 50, width: view.frame.size.width-30, height: 40)
        buttonStack.center = view.center
        buttonStack.center.y = view.frame.size.height - 50
        buttonStack.spacing = 30
        buttonStack.alignment = .fill
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        textStack.axis = .vertical
        view.addSubview(textStack)
        textStack.spacing = 10
        textStack.pin(to: view, [.top: 50, .left: 10, .right:10])
        [startLocation, endLocation].forEach{ textField in
            textField.setHeight(to: 40)
            textField.delegate = self
            textStack.addArrangedSubview(textField)
            
        }
        view.addSubview(buttonStack)
        buttonClear.setTitleColor(UIColor.gray, for: .normal)
        buttonGo.addTarget(self, action: #selector(goButtonWasPressed), for: .touchUpInside)
    }
    
    @objc func clearButtonWasPressed(){
        startLocation.text = ""
        endLocation.text = ""
        buttonClear.setTitleColor(.gray, for: .disabled)
        buttonClear.backgroundColor = .lightGray
        buttonClear.isEnabled = false
    }
    
    @objc func goButtonWasPressed(){
        print("Go button pressed")
        guard
            let first = startLocation.text,
            let second = endLocation.text,
            first != second
        else {
            return
        }
        let group = DispatchGroup()
        group.enter()
        getCoordinateFrom(address: first, completion: { [weak self] coords,_ in
            if let coords = coords{
                self?.coordinates.append(coords)
            }
            group.leave()
        })
        
        group.enter()
        getCoordinateFrom(address: second, completion: { [weak self] coords,_ in
            if let coords = coords{
                self?.coordinates.append(coords)
            }
            group.leave()
        })
        group.notify(queue: .main){
            DispatchQueue.main.async {
                [weak self] in self?.buildPath()
            }
        }
        coordinates = []
        
    }
    
    private func buildPath(){
        print("Build Path")
        mapView.removeOverlays(mapView.overlays)
        if (coordinates.count != 2) {
            print("Coordinate not found")
            return
        }
        let sourceCoordinate = coordinates[0]
        let destinationCoordinate = coordinates[1]
        print(coordinates[0])
        print(coordinates[1])
        let sPlaceMark = MKPlacemark(coordinate: sourceCoordinate)
        let dPlaceMark = MKPlacemark(coordinate: destinationCoordinate)
        
        let sourceItem = MKMapItem(placemark: sPlaceMark)
        let destinationItem = MKMapItem(placemark: dPlaceMark)
        
        
        let directionRequest = MKDirections.Request();
        directionRequest.source = sourceItem
        directionRequest.destination = destinationItem
        
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("No no no")
                }
                return
            }
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .blue
        return render
    }
    
}

extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if(startLocation.hasText && endLocation.hasText){
            goButtonWasPressed()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if (textField.hasText) {
            buttonClear.setTitleColor(.black, for: .normal )
            buttonClear.backgroundColor = .white
            buttonClear.isEnabled = true
        }
    }
    
}


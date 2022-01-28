import UIKit
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import MapboxMaps

class AdvancedViewController: UIViewController, NavigationMapViewDelegate, NavigationViewControllerDelegate {
    
    public var coordinates: [LocationCoordinate2D] = []
    
    let movementMethodStack = UIStackView()
    
    var navigationMapView: NavigationMapView!
    var navigationRouteOptions: NavigationRouteOptions!
    var currentRouteIndex = 0 {
        didSet {
            showCurrentRoute()
        }
    }
    var currentRoute: Route? {
        return routes?[currentRouteIndex]
    }
    
    var routes: [Route]? {
        return routeResponse?.routes
    }
    
    var routeResponse: RouteResponse? {
        didSet {
            guard currentRoute != nil else {
                navigationMapView.removeRoutes()
                return
            }
            currentRouteIndex = 0
        }
    }
    
    func showCurrentRoute() {
        guard let currentRoute = currentRoute else { return }
        
        var routes = [currentRoute]
        routes.append(contentsOf: self.routes!.filter {
            $0 != currentRoute
        })
        navigationMapView.show(routes)
        navigationMapView.showWaypoints(on: currentRoute)
        distanceLabel.text = String(format: "%.01fkm", routes[self.currentRouteIndex].distance / 1000)
    }
    
    var startButton: UIButton!
    
    var walkingButton: MapButton = {
        let control = MapButton(backColor: UIColor.lightGray.cgColor, text: "Walk", frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        control.addTarget(self, action: #selector(walkingPressed), for: .touchUpInside)
        return control
    }()
    
    var automobileButton: MapButton = {
        let control = MapButton(backColor: UIColor.systemGreen.cgColor, text: "Automobile", frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        control.addTarget(self, action: #selector(automobilePressed), for: .touchUpInside)
        return control
    }()
    
    var cyclingButton: MapButton = {
        let control = MapButton(backColor: UIColor.lightGray.cgColor, text: "Cycling", frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        control.addTarget(self, action: #selector(cyclingPressed), for: .touchUpInside)
        return control
    }()
    
    @objc func walkingPressed(){
        automobileButton.backgroundColor = .lightGray
        cyclingButton.backgroundColor = .lightGray
        walkingButton.backgroundColor = .systemGreen
        requestRoute(coordinates: coordinates, profile: .walking)
    }
    
    @objc func automobilePressed(){
        cyclingButton.backgroundColor = .lightGray
        walkingButton.backgroundColor = .lightGray
        automobileButton.backgroundColor = .systemGreen
        requestRoute(coordinates: coordinates, profile: .automobileAvoidingTraffic)
    }
    
    @objc func cyclingPressed(){
        automobileButton.backgroundColor = .lightGray
        walkingButton.backgroundColor = .lightGray
        cyclingButton.backgroundColor = .systemGreen
        requestRoute(coordinates: coordinates, profile: .cycling)
    }
    
    // MARK: - UIViewController lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationMapView = NavigationMapView(frame: view.bounds)
        navigationMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navigationMapView.delegate = self
        navigationMapView.userLocationStyle = .puck2D()
        
        let navigationViewportDataSource = NavigationViewportDataSource(navigationMapView.mapView, viewportDataSourceType: .raw)
        navigationViewportDataSource.options.followingCameraOptions.zoomUpdatesAllowed = false
        navigationViewportDataSource.followingMobileCamera.zoom = 13.0
        navigationMapView.navigationCamera.viewportDataSource = navigationViewportDataSource
        
        view.addSubview(navigationMapView)
        startButton = UIButton()
        startButton.setTitle("End navigation", for: .normal)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.backgroundColor = .blue
        startButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        startButton.addTarget(self, action: #selector(tappedButton(sender:)), for: .touchUpInside)
        view.addSubview(startButton)
        
        startButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        startButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        view.setNeedsLayout()
        
        requestRoute(coordinates: coordinates, profile: .automobileAvoidingTraffic)
        
        movementMethodStack.addArrangedSubview(walkingButton)
        movementMethodStack.addArrangedSubview(automobileButton)
        movementMethodStack.addArrangedSubview(cyclingButton)
        movementMethodStack.frame = CGRect(x: 0, y: view.frame.size.height - 50, width: view.frame.size.width-30, height: 40)
        movementMethodStack.center = view.center
        movementMethodStack.center.y = 80
        movementMethodStack.spacing = 30
        movementMethodStack.alignment = .fill
        movementMethodStack.axis = .horizontal
        movementMethodStack.distribution = .fillEqually
        view.addSubview(distanceLabel)
        distanceLabel.frame = CGRect(x: 20, y: view.center.y, width: 60, height: 40)
        distanceLabel.backgroundColor = .systemBlue
        distanceLabel.layer.masksToBounds = true
        distanceLabel.layer.cornerRadius = 10
        distanceLabel.textAlignment = .center
        view.addSubview(movementMethodStack)
    }
    
    @objc func tappedButton(sender: UIButton) {
        view.removeFromSuperview()
    }
    
    
    // Override layout lifecycle callback to be able to style the start button.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    let distanceLabel = UILabel()
    
    
    public func requestRoute(coordinates: [LocationCoordinate2D], profile: ProfileIdentifier) {
        currentRouteIndex = 0
        let userWaypoint = Waypoint(coordinate: coordinates[0])
        
        let destinationWaypoint = Waypoint(coordinate: coordinates[1])
        
        let navigationRouteOptions = NavigationRouteOptions(waypoints: [userWaypoint, destinationWaypoint])
        navigationRouteOptions.profileIdentifier = profile
        Directions.shared.calculate(navigationRouteOptions) { [weak self] (_, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let self = self else { return }
                
                self.navigationRouteOptions = navigationRouteOptions
                self.routeResponse = response
                if let routes = self.routes,
                   let currentRoute = self.currentRoute {
                    self.navigationMapView.show(routes)
                    self.navigationMapView.showWaypoints(on: currentRoute)
                }
            }
        }
        guard let routeResponse = self.routeResponse, let navigationRouteOptions = self.navigationRouteOptions else { return }
        // For demonstration purposes, simulate locations if the Simulate Navigation option is on.
        let navigationService = MapboxNavigationService(routeResponse: routeResponse,
                                                        routeIndex: currentRouteIndex,
                                                        routeOptions: navigationRouteOptions,
                                                        simulating: .onPoorGPS )
        let navigationOptions = NavigationOptions(navigationService: navigationService)
        let navigationViewController = NavigationViewController(for: routeResponse, routeIndex: currentRouteIndex,
                                                                   routeOptions: navigationRouteOptions,
                                                                   navigationOptions: navigationOptions)

        navigationViewController.delegate = self

        //present(navigationViewController, animated: true, completion: nil)

    }
    
    // Delegate method called when the user selects a route
    func navigationMapView(_ mapView: NavigationMapView, didSelect route: Route) {
        self.currentRouteIndex = self.routes?.firstIndex(of: route) ?? 0
        distanceLabel.text = String(format: "%.01fkm", routes![self.currentRouteIndex].distance / 1000)
    }
    
    func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
        dismiss(animated: true, completion: nil)
    }
}

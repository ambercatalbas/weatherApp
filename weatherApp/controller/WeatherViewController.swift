//
//  ViewController.swift
//  weatherApp
//
//  Created by Yasemin YEL on 20.02.2021.
//  Copyright © 2021 Sifa. All rights reserved.
//

import UIKit
import SkeletonView
import CoreLocation
import Loaf

protocol WeatherViewControllerDelegate: class {
    func didUpdateWeatherFromSearch(model: WeatherModel)
}

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var temparatureLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    
    private let weatherManager = WeatherManager()
    
    private lazy var locationManager : CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // fetchWeather(byCity: "Andırın")
      locationWeather()
    }
    private func fetchWeather(byLocation location: CLLocation) {
        showAnimation()
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        weatherManager.fetchWeather(lat: lat, lon: lon) { [weak self] (result) in
            guard let this = self else {return}
            this.handleResult(result)
        }
    }
    private func fetchWeather(byCity city: String){
        showAnimation()
        weatherManager.fetchWeather(byCity: city) { [weak self](result) in
            guard let this = self else {return}
            this.handleResult(result)
        }
    }
    private func handleResult(_ result: Result<WeatherModel, Error>) {
        switch result {
        case .success(let model):
            updateView(with: model)
        case .failure(let error):
          handleError(error)
            
        }
    }
    private func handleError(_ error: Error) {
        hideAnimation()
        conditionImageView.image = UIImage(named: "imSad")
        navigationItem.title = ""
        temparatureLabel.text = "Ooops"
        conditionLabel.text = "Something went wrong. Please try again."
        Loaf(error.localizedDescription, state: .error, location: .bottom, sender: self).show()
    }
    private func updateView(with model: WeatherModel) {
        hideAnimation()
        temparatureLabel.text = model.temp.toString().appending("°C")
        conditionLabel.text = model.conditionDescription
        navigationItem.title = model.countryName
        conditionImageView.image = UIImage(named: model.conditionImage)
    }
    private func hideAnimation() {
        conditionImageView.hideSkeleton()
        temparatureLabel.hideSkeleton()
        conditionLabel.hideSkeleton()
    }
    private func showAnimation(){
           
        conditionImageView.showAnimatedGradientSkeleton()
        temparatureLabel.showAnimatedGradientSkeleton()
        conditionLabel.showAnimatedGradientSkeleton()
        
       }
    @IBAction func addCityButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showAddCity", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddCity" {
            if let destination = segue.destination as? AddCityViewController {
                destination.delegate = self
            }
        }
    }
   @IBAction func locationButtonTapped(_ sender: Any) {
   locationWeather()
   }
    private func locationWeather() {
        switch CLLocationManager.authorizationStatus() {
           case .authorizedAlways, .authorizedWhenInUse:
               locationManager.requestLocation()
           case .notDetermined:
               locationManager.requestWhenInUseAuthorization()
              locationManager.requestLocation()
           default:
               promtForLocationPermission()
           }
    }
    private func promtForLocationPermission() {
        let alertController = UIAlertController(title: "Requires Location Permission ", message: "Whould you like to enable location permission in settings?", preferredStyle: UIAlertController.Style.alert)
        let enableAction = UIAlertAction(title: "Go to Settings", style: UIAlertAction.Style.default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {return}
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(enableAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension WeatherViewController: WeatherViewControllerDelegate {
    func didUpdateWeatherFromSearch(model: WeatherModel) {
        presentedViewController?.dismiss(animated: true, completion: {
            [weak self] in guard let this = self else {return}
            this.updateView(with: model)
        })
       
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {          
                if let location = locations.last {
                    manager.stopUpdatingLocation()
                    fetchWeather(byLocation: location)

                }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
       handleError(error)
    }
}

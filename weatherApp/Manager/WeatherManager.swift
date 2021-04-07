//
//  WeatherManager.swift
//  weatherApp
//
//  Created by Yasemin YEL on 20.02.2021.
//  Copyright © 2021 Sifa. All rights reserved.
//

import Foundation
import Alamofire

enum WeatherError: Error, LocalizedError {
    
    case unknown
    case ivalidCity
    case custom(description: String)
    var errorDescription: String? {
        switch self  {
        case .ivalidCity:
            return "This is an invalid City. Please try again!"
        case .unknown:
            return "Hey, this is unknown error!"
      
        case .custom(let description):
            return description
        }
        
    }
}

struct WeatherManager {
    
    private let API_KEY = "d6076d39bd4fb90b86944134e9a65a1c"
   
    func fetchWeather(lat: Double, lon: Double, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
           
            let path = "http://api.openweathermap.org/data/2.5/weather?appid=%@&units=metric&lat=%f&lon=%f"
            let urlString = String(format: path, API_KEY, lat, lon)
            handleRequest(urlString: urlString, completion: completion)
        }
        func fetchWeather(byCity city: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
       
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city

        let path = "http://api.openweathermap.org/data/2.5/weather?q=%@&appid=%@&units=metric"
        let urlString = String(format: path, query, API_KEY)
        handleRequest(urlString: urlString, completion: completion)
    }
    private func handleRequest(urlString: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
          AF.request(urlString)
                    .validate()
                    .responseDecodable(of: WeatherData.self, queue: .main,  decoder: JSONDecoder()) { (response) in
                    switch response.result {
                        
                    case .success(let weatherData):
                        let model = weatherData.model
                        completion(.success(model))
                    case .failure(let error):
                        
                        if let err = self.getWeatherError(error: error, data:response.data) {
                            completion(.failure(err))
                        } else {
                            completion(.failure(error))
                        }
                }
                        }
    }
    private func getWeatherError(error: AFError, data: Data?) -> Error? {
        //status == 404 & payload is parsable
        //=> message
        //else, return error
        
        if error.responseCode == 404,
        let data = data,
        let failure = try? JSONDecoder().decode(WeatherDataFailure.self, from: data) {
            let message = failure.message
            return WeatherError.custom(description: message)
        } else {
            return nil
        }
    }
}



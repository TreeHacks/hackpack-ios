//
//  BriefingViewController.swift
//  Statusboard
//
//  Created by Olivia Brown on 12/19/18.
//

import UIKit
import CoreLocation

class BriefingViewController: UIViewController {

    @IBOutlet weak var weatherTextView: UITextView!

    @IBOutlet weak var newsButton: UIButton!
    var articleUrlString: String?

    // Access the current location
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocation? {
        get {
            return (CLLocationManager.authorizationStatus() == .authorizedWhenInUse) ? locationManager.location : nil
        }
    }

    // Open the url every time the button is tapped
    @IBAction func buttonTapped(_ sender: UIButton) {
        if let urlString = articleUrlString, let url = URL(string: urlString) {
            UIApplication.shared.openURL(url)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Request access to the user's location
        locationManager.requestWhenInUseAuthorization()

        // Load all the components displayed on the screen
        setupNews()
        setupWeather()
    }

    // Display a button that links to and displays the title of the top NYTimes article by calling the NYTimes API
    func setupNews() {
        guard let url = URL(string: "https://api.nytimes.com/svc/topstories/v2/home.json?api-key=8085826bc22e436aa53e58765b1c38f6") else { return }
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: {(data, reponse, error) in
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    guard let topArticle = (jsonResult["results"] as? NSArray)?[0] as? NSDictionary,
                        let articleTitle = topArticle["title"] as? String,
                        let url = topArticle["url"] as? String else { return }

                    self.articleUrlString = url
                    DispatchQueue.main.async {
                        self.newsButton.setTitle(articleTitle, for: .normal)
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }

    // Display the weather in the user's current location using the CoreLocation framework and the Open Weather Map API
    func setupWeather() {
        // Only display if we have the current location
        guard let coordinates = currentLocation?.coordinate else { return }
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&units=imperial&APPID=2f6eb7ed8c5576e5d51fe15b51cdea10")
        let task = URLSession.shared.dataTask(with: url!, completionHandler: {(data, reponse, error) in
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    if let items = jsonResult["main"] as? NSDictionary {
                        if let tempMin = items["temp_min"] as? Double,
                            let tempMax = items["temp_max"] as? Double,
                            let humidity = items["humidity"] as? Double {

                            DispatchQueue.main.async {
                                self.weatherTextView.text = "🌎 Today's Weather Forecast 🌎\n\nHigh: \(tempMax)°F\nLow: \(tempMin)°F\nHumidity: \(humidity)%"
                            }
                        }
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
}

//
//  BriefingViewController.swift
//  Rise & Shine
//
//  TreeHacks 2019
//  https://treehacks.com
//

import UIKit
import CoreLocation

class BriefingViewController: UIViewController {

    @IBOutlet private weak var weatherTextView: UITextView!
    @IBOutlet private weak var newsButton: UIButton!
    @IBOutlet private weak var animatingButton: UIButton!

    // Access the current location
    private var locationManager = CLLocationManager()

    private var articleUrlString: String?

    // Open the url every time the button is tapped
    @IBAction private func buttonTapped(_ sender: UIButton) {
        if let urlString = articleUrlString, let url = URL(string: urlString) {
            UIApplication.shared.openURL(url)
        }
    }

    @IBAction private func animateButtonAway(_ sender: Any) {
        animatingButton.animateOut()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        // Load all the components displayed on the screen. Note: don't need to call setupWeather since call is in delegate
        setupNews()
        animatingButton.animateIn()
    }

    // Display a button that links to and displays the title of the top NYTimes article by calling the NYTimes API
    private func setupNews() {
        guard let url = URL(string: "https://api.nytimes.com/svc/topstories/v2/home.json?api-key=8085826bc22e436aa53e58765b1c38f6") else { return }
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: {(data, reponse, error) in
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                    guard let topArticle = (jsonResult["results"] as? [[String: Any]])?[0],
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
    private func setupWeather() {
        // Only display if we have the current location
        guard let coordinates = locationManager.location?.coordinate,
            let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&units=imperial&APPID=2f6eb7ed8c5576e5d51fe15b51cdea10") else { return }
        let task = URLSession.shared.dataTask(with: url, completionHandler: {(data, reponse, error) in
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                    guard let items = jsonResult["main"] as? [String: Any],
                        let tempMin = items["temp_min"] as? Double,
                        let tempMax = items["temp_max"] as? Double,
                        let humidity = items["humidity"] as? Double else { return }
                    DispatchQueue.main.async {
                        self.weatherTextView.text = "Today's Forecast:\n\nHigh: \(tempMax)°F\nLow: \(tempMin)°F\nHumidity: \(humidity)%"
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
}

extension BriefingViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            setupWeather()
        }
    }
}

extension UIButton {
    func animateIn() {
        self.alpha = 0.0
        UIView.animate(withDuration: 0.5, delay: 1.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: UIView.AnimationOptions.curveEaseIn, animations: {
            [weak self] in
            self?.alpha = 1.0
        })
    }

    func animateOut() {
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: UIView.AnimationOptions.curveEaseIn, animations: {
            [weak self] in
            self?.alpha = 0.0
        })
    }
}

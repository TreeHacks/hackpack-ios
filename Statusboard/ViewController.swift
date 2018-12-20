//
//  TreeHacks 2019
//
//  ViewController.swift
//  Statusboard
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var quoteTextView: UITextView!
    @IBOutlet weak var weatherTextView: UITextView!
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the navigation controller (the bar at the top) to have a specific color, title, and tint.
        if let navController = self.navigationController {
            navController.navigationBar.barTintColor = UIColor.orange
            navController.navigationBar.tintColor = UIColor.white
            self.title = "Rise & Shine"
        }

        // Request access to the user's location
        locationManager.requestWhenInUseAuthorization()

        // Set up all the components
        setupGIF(of: "sunshine")
        setupQuote()
        setupWeather()
    }

    // Load a GIF of the passed search term by querying the giphy.com API and filling our image view with the content
    func setupGIF(of searchTerm: String) {
        // Construct the URL by inserting our search term (which we edit to have the correct characters for a URL)
        guard let encodedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else { return }
        let searchURL = URL(string:"http://api.giphy.com/v1/gifs/translate?s=\(encodedSearchTerm)&api_key=dc6zaTOxFJmzC")
        let searchData = try? Data(contentsOf: searchURL!)
        
        // Parse the JSON by accessing multiple levels of dictionaries to get the gif's link
        do {
            if let jsonResult = try JSONSerialization.jsonObject(with: searchData!, options: []) as? NSDictionary {
                if let images = (jsonResult["data"] as? NSDictionary)?["images"] as? NSDictionary {
                    if let link = (images["downsized"] as? NSDictionary)?["url"] as? String,
                        let url = URL(string: link) {
                        if let gifData = try? Data(contentsOf: url), let gif = UIImage.gifWithData(gifData) {
                            self.imageView.image = gif // display the gif we found
                        }
                    }
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    // Load a quote using the NSURLSession framework to get data returned from Quotes REST API
    func setupQuote() {
        let url = URL(string: "http://quotes.rest/qod.json")
        let session = URLSession.shared
        let task = session.dataTask(with: url!, completionHandler: {(data, reponse, error) in
            do {
                // Parse the JSON by accessing multiple levels of dictionaries to get the quote and author
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    if let quotes = (jsonResult["contents"] as? NSDictionary)?["quotes"] as? NSArray {
                        if let firstQuote = quotes[0] as? NSDictionary,
                            let quoteText = firstQuote["quote"] as? String,
                            let quoteAuthor = firstQuote["author"] as? String {
                            // Change the text view to display quote on the main thread
                            DispatchQueue.main.async(execute: {
                                self.quoteTextView.text = "💭 Quote of the Day 💭\n\n\(quoteText)\n\n- \(quoteAuthor)"
                            });
                        }
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }

    // Display the weather in the user's current location using the Maps framework and the Open Weather Map API
    func setupWeather() {
        let location = "Stanford"
        //        var currentLocation: CLLocation? = nil
        //
        //        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
        //            CLLocationManager.authorizationStatus() ==  .authorizedAlways) {
        //            currentLocation = locationManager.location
        //        }
        //        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(currentLocation!.coordinate.latitude)&lon=\(currentLocation!.coordinate.longitude),us%20&units=imperial&APPID=2f6eb7ed8c5576e5d51fe15b51cdea10")
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=\(location),us%20&units=imperial&APPID=2f6eb7ed8c5576e5d51fe15b51cdea10")
        let session = URLSession.shared
        let task = session.dataTask(with: url!, completionHandler: {(data, reponse, error) in
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    if let items = jsonResult["main"] as? NSDictionary {
                        let tempMin = items["temp_min"] as! NSNumber
                        let tempMax = items["temp_max"] as! NSNumber
                        let humidity = items["humidity"] as! NSNumber
                        
                        DispatchQueue.main.async(execute: {
                            self.weatherTextView.text = "🌎 Today's Weather Forecast for \(location) 🌎\n\nHigh: \(tempMax)°F\nLow: \(tempMin)°F\nHumidity: \(humidity)%"
                        });
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
}


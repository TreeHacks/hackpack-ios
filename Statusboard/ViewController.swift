//
//  ViewController.swift
//  Statusboard
//
//  Created by Veeral Patel on 1/7/16.
//
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var quoteTextView: UITextView!
    @IBOutlet weak var weatherTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This sets up the navigation controller (the bar at the top) to be a certain style, color, and tint.
        
        let name = "ENTER NAME HERE"
        self.title = "Good morning, \(name)"
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 42/255, green: 62/255, blue: 80/255, alpha: 1)
        self.navigationController!.navigationBar.barStyle = .BlackTranslucent
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        // Calling the setupGIF function
        setupGIF()
        
        setupQuote()
        setupWeather()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupGIF() {
        /* gifString is the query we're going to be searching with using the Giphy.com API.
        Before we do that, we escape the string properly. Then, we put everything together
        in a completed searchURL and get the contents from the link */
        
        let gifString = "dj khaled"
        let encodedString = gifString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let searchURL = NSURL(string:"http://api.giphy.com/v1/gifs/translate?s=\(encodedString)&api_key=dc6zaTOxFJmzC")
        let searchData = NSData(contentsOfURL:searchURL!)
        
        /* The next thing we have to do is parse the JSON that is returned from the URL.
        This involves accessing multiple dictionaries until we reach the gif link we're after. */
        
        do {
            if let jsonResult = try NSJSONSerialization.JSONObjectWithData(searchData!, options: []) as? NSDictionary {
                if let items = jsonResult["data"] as? NSDictionary {
                    if let images = items["images"] as? NSDictionary {
                        if let gType = images["downsized"] as? NSDictionary {
                            if let link = gType["url"] as? String {
                                
                                /* After we have the link, the only that's left to do is display it with the help of
                                the UIImage+Gif.swift framework we added */
                                
                                let imageData = NSData(contentsOfURL: NSURL(string: link)!)
                                let gif = UIImage.gifWithData(imageData!)
                                self.imageView.image = gif;
                            }
                        }
                    }
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func setupQuote() {
        /* This is a slightly different way to make HTTP requests but the fundamentals are the same.
        We're using Apple's NSURLSession framework to get the data returned from http://quotes.rest/qod.json */
        
        let url = NSURL(string: "http://quotes.rest/qod.json")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {(data, reponse, error) in
            do {
                
                /* Again, this is where we start parsing the JSON until we reach the data we're after */
                
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    if let items = jsonResult["contents"] as? NSDictionary {
                        if let quoteData = items["quotes"] as? NSArray {
                            if let firstQuote = quoteData[0] as? NSDictionary {
                                
                                /* Once we reach the quote, all we have to do is display the text */
                                
                                let quoteText = firstQuote["quote"] as! String
                                let quoteAuthor = firstQuote["author"] as! String
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.quoteTextView.text = "💭 Quote of the Day 💭\n\n\(quoteText)\n\n- \(quoteAuthor)"
                                });
                            }
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        })
        
        task.resume()
    }
    
    func setupWeather() {
        /* This is location to query the weather for. Feel free to change it to anything you'd like. */
        
        let location = "Stanford"
        let url = NSURL(string: "http://api.openweathermap.org/data/2.5/weather?q=\(location),us%20&units=imperial&APPID=2f6eb7ed8c5576e5d51fe15b51cdea10")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {(data, reponse, error) in
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    if let items = jsonResult["main"] as? NSDictionary {
                        let tempMin = items["temp_min"] as! NSNumber
                        let tempMax = items["temp_max"] as! NSNumber
                        let humidity = items["humidity"] as! NSNumber
                        
                        dispatch_async(dispatch_get_main_queue(), {
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


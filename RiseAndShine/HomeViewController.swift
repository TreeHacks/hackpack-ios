//
//  HomeViewController.swift
//  Rise & Shine
//
//  TreeHacks 2019
//  https://treehacks.com
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var quoteTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the navigation controller (the bar at the top) to have a specific color, title, and tint.
        if let navController = self.navigationController {
            navController.navigationBar.barTintColor = UIColor.orange
            navController.navigationBar.tintColor = UIColor.white
            self.title = "Rise & Shine"
        }

        // Set up all the components on the screen
        setupGIF(of: "sunshine")
        setupQuote()
    }

    // Load a GIF of the passed search term by querying the giphy.com API and filling our image view
    private func setupGIF(of searchTerm: String) {
        // Construct the URL by inserting our search term (which we edit to have the correct characters for a URL)
        guard let encodedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
            let searchURL = URL(string:"http://api.giphy.com/v1/gifs/translate?s=\(encodedSearchTerm)&api_key=dc6zaTOxFJmzC") else { return }
        let searchData = try? Data(contentsOf: searchURL)
        
        // Parse the JSON by accessing multiple levels of dictionaries to get the gif's link
        do {
            if let jsonResult = try JSONSerialization.jsonObject(with: searchData!, options: []) as? [String: Any] {
                guard let images = (jsonResult["data"] as? [String: Any])?["images"] as? [String: Any],
                    let link = (images["downsized"] as? [String: String])?["url"],
                    let url = URL(string: link),
                    let gifData = try? Data(contentsOf: url),
                    let gif = UIImage.gifWithData(gifData) else { return }
                self.imageView.image = gif // display the gif we found
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    // Load a quote using the URLSession framework to get data returned from Quotes REST API
    private func setupQuote() {
        guard let url = URL(string: "http://quotes.rest/qod.json") else { return }
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: {(data, reponse, error) in
            do {
                // Parse the JSON by accessing multiple levels of dictionaries to get the quote and author
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                    guard let quotes = (jsonResult["contents"] as? [String: Any])?["quotes"] as? [Any],
                        let firstQuote = quotes[0] as? [String: Any],
                        let quoteText = firstQuote["quote"] as? String,
                        let quoteAuthor = firstQuote["author"] as? String else { return }

                    // Change the text view to display quote on the main thread
                    DispatchQueue.main.async {
                        self.quoteTextView.text = "\(quoteText)\n\n- \(quoteAuthor)"
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
}

//
//  TreeHacks 2019
//
//  AdditionalViewController.swift
//  Statusboard
//

import UIKit

class AdditionalViewController: UIViewController {

    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var newsButton: UIButton!
    var articleUrlString: String?
    
    @IBOutlet weak var xkcdImageView: UIImageView!
    @IBOutlet weak var xkcdTitleLable: UILabel!

    // Open the url every time the button is tapped
    @IBAction func buttonTapped(_ sender: UIButton) {
        if let urlString = articleUrlString, let url = URL(string: urlString) {
            UIApplication.shared.openURL(url)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load all the components displayed on the screen
        setupCountdown(until: "2019-02-18");
        setupNews();
        setupXKCD();
    }

    // Display a countdown of the number of days until the passed in date
    func setupCountdown(until targetDateString: String) {
        // Set up the format the date should be in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.init(identifier: .gregorian)
        
        // Find the difference between target date and today and display in label
        let targetDate: Date! = dateFormatter.date(from: targetDateString)
        let todayDate: Date! = Date()
        let dateString = DateFormatter.localizedString(from: targetDate, dateStyle: .short, timeStyle: .none)
        if let numDays = calendar.dateComponents([.day], from: todayDate, to: targetDate).day {
            self.countdownLabel.text = "📅 Days until \(dateString): \(numDays)"
        }
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

    // Displays the most current xkcd comic in an image view
    func setupXKCD() {
        guard let url = URL(string: "http://xkcd.com/info.0.json") else { return }
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: {(data, reponse, error) in
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    let imageLink = jsonResult["img"] as! String
                    let title = jsonResult["title"] as! String
                    guard let url = URL(string: imageLink), let imageData = try? Data(contentsOf: url) else { return }
                    
                    DispatchQueue.main.async(execute: {
                        self.xkcdTitleLable.text = title;
                        self.xkcdImageView.image = UIImage(data: imageData)
                    })
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
}

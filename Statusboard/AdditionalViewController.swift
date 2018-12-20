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
    var articleUrl = String()
    
    @IBOutlet weak var xkcdImageView: UIImageView!
    @IBOutlet weak var xkcdTitleLable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupCountdown();
        setupNews();
        setupXKCD();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupCountdown() {
        /* This sets up the format the date should be in */
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        /* This initializes the two dates we want to find the time difference between */
        
        let targetDate: Date? = dateFormatter.date(from: "2017-06-20")
        let todayDate: Date? = Date()
        
        /* After we have the difference between the two dates, we can display it with our label */
        
        let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian);
        let components = (calendar as NSCalendar?)?.components(.day, from:todayDate!, to:targetDate!, options: [])
        let dateString = DateFormatter.localizedString(from: targetDate!, dateStyle: .short, timeStyle: .short); //format date correctly
        let days = (components?.day!)!
        self.countdownLabel.text = "📅 Days until \(dateString):\n\(days)"
    }
    
    func setupNews() {
        /* This is the URL for getting the top NYTimes stories */
        
        let url = URL(string: "https://api.nytimes.com/svc/topstories/v2/home.json?api-key=8085826bc22e436aa53e58765b1c38f6")
        let session = URLSession.shared
        let task = session.dataTask(with: url!, completionHandler: {(data, reponse, error) in
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    if let items = jsonResult["results"] as? NSArray {
                        
                        /* Because we just want 1 story, we get the first item in the dictionary */
                        
                        if let topArticle = items[0] as? NSDictionary {
                            let articleTitle = topArticle["title"] as! String
                            self.articleUrl = topArticle["url"] as! String
                            
                            /* We set the title of the button to be the article title */
                            
                            DispatchQueue.main.async(execute: {
                                self.newsButton.setTitle(articleTitle, for: UIControl.State())
                            });
                        }
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        })
        
        task.resume()
    }
    
    /* This function will get "triggered" everytime the button is tapped.
    In our case, we want it to open the article URL (in mobile Safari). */
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if let url = URL(string: self.articleUrl) {
            UIApplication.shared.openURL(url)
        }
    }
    
    func setupXKCD() {
        /* This gets the most current xkcd comic */
        
        let url = URL(string: "http://xkcd.com/info.0.json")
        let session = URLSession.shared
        let task = session.dataTask(with: url!, completionHandler: {(data, reponse, error) in
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    let imageLink = jsonResult["img"] as! String
                    let title = jsonResult["title"] as! String
                    
                    let url = URL(string: imageLink)
                    let data = try? Data(contentsOf: url!)
                    
                    /* Once we have the imageLink and title, we can display it. */
                    
                    DispatchQueue.main.async(execute: {
                        self.xkcdTitleLable.text = title;
                        self.xkcdImageView.image = UIImage(data: data!)
                    });
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        })
        
        task.resume()
    }
}

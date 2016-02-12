# iOS Hackpack Tutorial
*Come join us on [#hackpack-ios](https://treehacks-2016.slack.com/messages/hackpack-ios) on Slack to get help, hang out, and show off your project!*
### Overview

For the iOS Hackpack, we’re going to be making a “Morning Briefing” app that displays a bunch of things you may want to see everyday. For example, a daily DJ Khaled GIF, an interesting quote, a countdown to a special day, etc. Throughout the process, you’ll learn about the basic process behind making iPhone apps, making HTTP requests, and Swift (Apple’s new programming language). 

If you’ve taken CS106A/B/X, then read these tutorials over to learn a little bit about Swift:
http://www.raywenderlich.com/115253/swift-2-tutorial-a-quick-start
https://learnxinyminutes.com/docs/swift/
https://www.objc.io/issues/16-swift/swift-functions/

### Getting Started

* If you don’t have [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12) installed on your computer, install it from the Mac App Store.
*  ![](https://quip.com/blob/KWDAAAiFNtr/cYDpy1W8yWSlhzDQV6NHUA?a=glRLEkOMvi8b4JyhWPj0O8vtgnpCCL0soRYNZYW6mL0a)
* Click “Create a new Xcode project” and under iOS → Application, select “ Single View Application” and fill in the following fields. After clicking “next,” pick somewhere to save the project and then press “Create.”
* ![](https://quip.com/blob/KWDAAAiFNtr/MhH4UAKvGoKkHuaSnDcYzg?a=wqjapDGgVXIsUoxyam11a5PktsMU9TKdn56avMNTHD0a)
### CHECKPOINT #1 - GIF

The first thing we’re going to do is add the necessary elements to display a GIF. Apple doesn’t natively support displaying GIFs in image views, so we’re going to add an open source framework to help. Clone or download [SwiftGif](https://github.com/bahlo/SwiftGif) (click Download Zip) and add `UIImage+Gif.swift` to your project directory by dragging the file to the left panel as so:
![](https://quip.com/blob/KWDAAAiFNtr/ROCAUJg5SuOMkSmGZwrzkw?a=DHWs4izNozAoAq9LpeNxcqasLK6qiMaCpVHsrhkCaNEa)Make sure the following options are selected and then press finish.
![](https://quip.com/blob/KWDAAAiFNtr/IUx6lD0rWwn2elTftBK_sA?a=Talznxqd7wZA9a0xmqSBokraC1RI9a4IkWZ5VhW1tvca)Next, open Main.storyboard. Think of Main.storyboard as a rough mockup of what your app will look like. You can position different UI elements, preview colors/fonts, and connect screens together.

Click on ViewController to select it, and choose “iPhone 4.7-inch” as your size.
![](https://quip.com/blob/KWDAAAiFNtr/cWSTIVt9ernEE0P1eGI2EA?a=2x94vtqTfIwZArKS3THFOJIByPaNqCDDOZ480iGcWloa)Next, go to the top and click Editor → Embed In → Navigation Controller. This will put the main view controller into a navigation controller, which will then give us the ability to title our screen.

After that, click on the circle icon on the bottom right hand side, scroll until you find “Image View” and then drag an image view onto View Controller.
![](https://quip.com/blob/KWDAAAiFNtr/nqO07RUzWofCsnCaRRJXvQ?a=BsQMCZy8OGDdhIRDPEIXyYsdaz2l4vf4r78Phugemuga)Position it however you want somewhere at the top. Click on it again to change the width/height. Next, click on the attributes panel on the right hand side and change the Mode to be “Scale to Fill.”

After that, click on the venn diagram-ish icons on the top right 
![](https://quip.com/blob/KWDAAAiFNtr/LK8tKTUUSzxE07zYd_LSnw?a=uYsuam6kERicfXxWU2T9dC15VkYFXxA0GCS7Ruf5XgYa)This will bring up a panel to view two different files side by side. We want to have `ViewController.swift` on one side and `Main.storyboard` on the other. The different files can be accessed from the top of each pane.

Once you have that setup:

1. Hold the control key on your keyboard
2. Click on image view, and drag the resulting line to underneath `class ViewController: UIViewController {`
3. When the small dialog pop ups to connect, name the image view “imageView” and press “connect” to finish.
4. Congratulations! You just connected the image view you dragged and a variable called “imageView” that you can now use to change certain properties of it in code.

Before getting to the actual code, switch back to the original view from the top right. 

In `viewDidLoad()`, add the following code after super.viewDidLoad() and change the placeholder text:

```
// This sets up the navigation controller (the bar at the top) to be a certain style, color, and tint.

let name = "ENTER NAME HERE"
self.title = "Good morning, \(name)"
self.navigationController!.navigationBar.barTintColor = UIColor(red: 42/255, green: 62/255, blue: 80/255, alpha: 1)
self.navigationController!.navigationBar.barStyle = .BlackTranslucent
self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()

// Calling the setupGIF function
setupGIF()
```

Underneath that add the following code: 

```
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
```

Now, we're ready to test that everything works. 

Make sure in your project page (accessible from the left hand panel) the following options are selected:

![](https://quip.com/blob/KWDAAAiFNtr/nQwM9CXLd4t_aCUL5wcUTQ?a=7j2nwe57xP9G73qBZFFyuEC35VK78vbMXaqX6U8GBtMa)

After that, choose to run the application on an iPhone 6 (since that's how we setup the storyboard) and then press the run button (looks like a play button):
![](https://quip.com/blob/KWDAAAiFNtr/yBze2-IplmAu4H5--smwxw?a=UaSBEA3Ogj9gJ3bHurkRKEwlKSwfbo1VZ4p5UGDWKpQa)
If everything worked, you should see a random DJ Khaled related GIF show up in the simulator as so:

![](https://quip.com/blob/KWDAAAiFNtr/n1nIZWJt92fdYTm6D2ZhCw?a=EJaBaEuXOoBqkzNaQiCaOMvUGjBu9BamAyauhu6rdTUa)
Congratulations! You just completed your first checkpoint. Next, we'll add a random quote and weather.


### CHECKPOINT #2 - QUOTE + WEather

The process for adding a quote of the day and weather condition is pretty much the same. To do this, we're not going to be adding any files, but rather just using the [quotes.rest](http://quotes.rest/) and [openweathermap.org](http://openweathermap.org/) API.

To start off, go to `Main.storyboard `and drag in **two ** `UITextView` from the bottom right hand side. Double click to add some placeholder text. It should look like this:

![](https://quip.com/blob/KWDAAAiFNtr/L7ttQn68A-RYMIxXcP3mmg?a=hqP23FXKYSgVLIJkaEvWOw0xJaZGP7ApQF637zCeYW4a)

 Place one in middle and the other towards the bottom. Again, we're going to have to connect these text views in code. Click 
![](https://quip.com/blob/KWDAAAiFNtr/LK8tKTUUSzxE07zYd_LSnw?a=uYsuam6kERicfXxWU2T9dC15VkYFXxA0GCS7Ruf5XgYa) again and bring up `Main.storyboard` and `ViewController.swift` side-by-side. Hold control, click, and drag the connector over to underneath the image view we added before. When the prompt comes up, name one text view `quoteTextView`, the other `weatherTextView` and click connect.

Next, add `setupQuote()`  and `setupWeather()` in `viewDidLoad()` and add the following code block underneath `setupGIF()`:

```
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
```

Again, the code is pretty self-explanatory now that you've completed checkpoint #1. We're parsing the JSON returned from http://quotes.rest/qod.json and [openweathermap.org](http://openweathermap.org/) and setting the `self.quoteTextView.text` and `self.weatherTextView.text`  (respectively )to be the text we get.

Once that's completed press run (play) button on the top left and a random quote and some weather details for Stanford will show up!

Feel free to mess around with the `location`  variable in the `setupWeather()` method

### CHECKPOINT #3 - Button/NEW SCREEN

Next, we're going to be creating a button that brings us to another screen.

In `Main.storyboard`, drag in a Button from the bottom right and place it somewhere near the bottom of the screen. Double click to change the title to “🔑🔑🔑 More Briefings →”. At this point, your view controller should be similar to this: 

![](https://quip.com/blob/KWDAAAiFNtr/A3ftucZtd4hiv5Qsoomv0g?a=FZmdryWaQCfkRlzrF2FMQRquZrzjhPGjpuvs7G1rM0Ya)
Next, drag in a ViewController and place it next our original one like so:
![](https://quip.com/blob/KWDAAAiFNtr/NL9aAw23Y17aeqm0G3QD8w?a=GiiicuM0KuIGxgS9ovoMHJokJUapFrzpDksmWxCeB0oa)Again, you're going to want to change the size to be iPhone 6 if it's not already:
![](https://quip.com/blob/KWDAAAiFNtr/cWSTIVt9ernEE0P1eGI2EA?a=2x94vtqTfIwZArKS3THFOJIByPaNqCDDOZ480iGcWloa)
Next, hold control, click on your button, and drag the connector to your new view controller. When a gray prompt comes up, select “push.” You should see a connection between your two screens now. 
![](https://quip.com/blob/KWDAAAiFNtr/YRBplfPPVK8BiaPZF3mAkA?a=3KnxIdFJ32SaubZ2ByNCg7lalBgZBKaPSkA5Er9MWdsa)
This connects the button and the next screen together. When the button is tapped, it with “push” the next view controller onto your screen.

Press the run button to check it out! You may notice the blank screen, but that's because we haven't added anything there yet. Onto to the next checkpoint...

### CHECKPOINT #3 - COUNTDOWN, NYTIMES, XKCD

Finally, we're going to be adding a countdown (to a special date), NYTimes top story button, and XKCD comic to our app.

Setup `Main.storyboard` so that it looks like this:
![](https://quip.com/blob/KWDAAAiFNtr/0b5Gj5d7I6pIegTY2X130A?a=CG3yQZacf7JQFLSptd5pOL2c38fheGm0YPOtGi4yiGEa)“Countdown label, Top NYTimes Story, and XKCD” are UI elements of type **Label**. “Loading button link...” should be a **Button**. And the image view is a **Image View** (duh).

However, you may have noticed that we don't have another `ViewController.swift`. So, we're going to add another file:
![](https://quip.com/blob/KWDAAAiFNtr/vM_iKFFcjhr8JNCVbaDiUA?a=rcBb8zM1OJQaThwMq4uEu8PTub7BnZ4l8CRs7z9aaQ4a)


Make sure it's a Cocoa Touch Class and then fill in these fields:
![](https://quip.com/blob/KWDAAAiFNtr/xuQAEB10vNyqKh4Kgp5M_A?a=6iewbVJqc8YmhbWaynsjBiP0PejtWxigLo7oaSr1P40a) Finally, we have `AdditionalViewController.swift` to connect our UI elements to. Before we do that though, go back to `Main.storyboard`, click on the new view controller we added and fill this out in the right hand panel:
![](https://quip.com/blob/KWDAAAiFNtr/YY715eBZNPp6P8pirOxYEg?a=XBFToGDhFba77MsU8x06j8Aa11nNA4am9KT1H5ABI8Aa)This makes sure that the storyboard view controller and the file is matched. After that, click on
![](https://quip.com/blob/KWDAAAiFNtr/LK8tKTUUSzxE07zYd_LSnw?a=uYsuam6kERicfXxWU2T9dC15VkYFXxA0GCS7Ruf5XgYa)again and connect the respective UI elements with variable names (bolded) as so:

```
    @IBOutlet weak var **countdownLabel**: UILabel!
    @IBOutlet weak var **newsButton**: UIButton!
    @IBOutlet weak var **xkcdImageView**: UIImageView!
    @IBOutlet weak var **xkcdTitleLable**: UILabel!
```

Underneath that, declare a string:

```
    var articleUrl = String()
```

Add helper methods in `viewDidLoad()`

```
        setupCountdown();
        setupNews();
        setupXKCD();
```

And finally add the following code blocks to make everything work:  

```
    func setupCountdown() {
        /* This sets up the format the date should be in */
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        /* This initializes the two dates we want to find the time difference between */
        
        let targetDate: NSDate? = dateFormatter.dateFromString("2016-06-20")
        let todayDate: NSDate? = NSDate()
      
        /* After we have the difference between the two dates, we can display it with our label */
        
        let calendar = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian);
        let components = calendar?.components(.Day, fromDate:todayDate!, toDate:targetDate!, options: []) 
        let dateString = NSDateFormatter.localizedStringFromDate(targetDate!, dateStyle: .ShortStyle, timeStyle: .ShortStyle); //format date correctly
        self.countdownLabel.text = "📅 Days until \(dateString):\n\(components!.day)"
    }
    
    func setupNews() {
        /* This is the URL for getting the top NYTimes stories */
    
        let url = NSURL(string: "http://api.nytimes.com/svc/topstories/v1/home.json?api-key=cf9ece3591fde74684d354879f3df115:8:73978099")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {(data, reponse, error) in
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    if let items = jsonResult["results"] as? NSArray {
                    
                        /* Because we just want 1 story, we get the first item in the dictionary */
                        
                        if let topArticle = items[0] as? NSDictionary {
                            let articleTitle = topArticle["title"] as! String
                            self.articleUrl = topArticle["url"] as! String
                            
                            /* We set the title of the button to be the article title */
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                self.newsButton.setTitle(articleTitle, forState: .Normal)
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
    
    @IBAction func buttonTapped(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: self.articleUrl)!)
    }
    
    func setupXKCD() {
        /* This gets the most current xkcd comic */
    
        let url = NSURL(string: "http://xkcd.com/info.0.json")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {(data, reponse, error) in
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    let imageLink = jsonResult["img"] as! String
                    let title = jsonResult["title"] as! String
                                  
                    let url = NSURL(string: imageLink)
                    let data = NSData(contentsOfURL: url!)
                    
                    /* Once we have the imageLink and title, we can display it. */
                    
                    dispatch_async(dispatch_get_main_queue(), {
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
```

Last but not least, switch over to `Main.storyboard`, control, click, and drag from the Button to the top middle button of the view controller:
![](https://quip.com/blob/KWDAAAiFNtr/Bm1hYi6entBO9dRzXWUNXw?a=MfbYNAr9acD86XVszpluo8c4hc5OaoI8LNofRaDEZdUa) ![](https://quip.com/blob/KWDAAAiFNtr/rHMePceb7AVTeeYI3Ttu2Q?a=NqUvGMGG16wNwrXaRxbanC3ftrtRCaGDj8TcsaexyOga) Choose “buttonTapped:” to finish and then press play to test. The countdown, NYTimes button, and XKCD comic should show up. 

# Congratulations!

You’ve finished the iOS Hackpack tutorial. Hopefully, you learned a little about making iPhone apps, HTTP requests, and Swift. If not, let me (organizer-veeral) know in the Slack channel and I'd be down to help!

If you want to work on the app a little more, here are some ideas on how to extend it:

* integrate the ESPN API
* get info about popular stocks using Yahoo or Google Finance API
* show an interesting fact of the day
* random joke?
* etc. etc.




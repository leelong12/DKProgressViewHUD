//
//  ViewController.swift
//  DKHUDDEMO
//
//  Created by lee on 2017/6/13.
//  Copyright © 2017年 lee. All rights reserved.
//

import UIKit
import DKProgressViewHUD

struct DKExample {
    var title: String?
    var selector :Selector?
    
    static func example(title:String,selector:Selector)->DKExample{
        var example = DKExample()
        example.title = title
        example.selector = selector
        return example
    }
}

class ViewController: UIViewController {
    
    var examples = [[DKExample.example(title: "Indeterminate mode", selector: #selector(indeterminateExample)),
                     DKExample.example(title: "With label", selector: #selector(labelExample)),
                     DKExample.example(title: "With details label", selector: #selector(detailsLabelExample))],
                    [DKExample.example(title: "Determinate mode", selector: #selector(determinateExample)),
                     DKExample.example(title: "Annular determinate mode", selector: #selector(annularDeterminateExample)),
                     DKExample.example(title: "Bar determinate mode", selector: #selector(barDeterminateExample))],
                    [DKExample.example(title: "Text only", selector: #selector(textExample)),
                     DKExample.example(title: "Custom view", selector: #selector(customViewExample)),
                     DKExample.example(title: "With action button", selector: #selector(cancelationExample)),
                     DKExample.example(title: "Mode switching", selector: #selector(modeSwitchingExample))],
                    [DKExample.example(title: "On window", selector: #selector(indeterminateExample)),
                     DKExample.example(title: "URLSession", selector: #selector(networkingExample)),
                     DKExample.example(title: "Determinate with NSProgress", selector: #selector(determinateNSProgressExample)),
                     DKExample.example(title: "Dim background", selector: #selector(dimBackgroundExample)),
                     DKExample.example(title: "Colored", selector: #selector(colorExample))]]
    var isCanceled:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK - Examples
    
    func indeterminateExample() -> Void {
        // Show the HUD on the root view (self.view is a scrollable table view and thus not suitable,
        // as the HUD would move with the content as we scroll).
        let hud = DKProgressViewHUD.showHUD(view: (self.navigationController?.view)!, animated: true)
        
        // Fire off an asynchronous task, giving UIKit the opportunity to redraw wit the HUD added to the
        // view hierarchy.
        DispatchQueue.global(qos: .userInitiated).async {
            // Do something useful in the background
            self.doSomeWork()
            // IMPORTANT - Dispatch back to the main thread. Always access UI
            // classes (including MBProgressHUD) on the main thread.
            DispatchQueue.main.async {
                hud.hide(true)
            }
        }
    }
            
    func labelExample()->Void{
        let hud = DKProgressViewHUD.showHUD(view: (self.navigationController?.view)!, animated: true)
        // Set the label text.
        hud.label?.text = NSLocalizedString("Loading...", tableName: "HUD loading title", comment: "HUD loading title");
        // You can also adjust other label properties if needed.
        // hud.label.font = [UIFont italicSystemFontOfSize:16.f];
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Do something useful in the background
            self.doSomeWork()
            // IMPORTANT - Dispatch back to the main thread. Always access UI
            // classes (including MBProgressHUD) on the main thread.
            DispatchQueue.main.async {
                hud.hide(true)
            }
        }
    }
    
    func detailsLabelExample() -> Void {
        let hud = DKProgressViewHUD.showHUD(view: (self.navigationController?.view)!, animated: true)
        // Set the label text.
        hud.label?.text = NSLocalizedString("Loading...", comment:"HUD loading title");
        // Set the details label text. Let's make it multiline this time.
        hud.detailsLabel?.text = NSLocalizedString("Parsing data\n(1/1)", comment:"HUD title");
        DispatchQueue.global(qos: .userInitiated).async {
            // Do something useful in the background
            self.doSomeWork()
            // IMPORTANT - Dispatch back to the main thread. Always access UI
            // classes (including MBProgressHUD) on the main thread.
            DispatchQueue.main.async {
                hud.hide(true)
            }
        }
    }
    
    func windowExample() -> Void {
        let hud = DKProgressViewHUD.showHUD(view: self.view.window!, animated: true)
        DispatchQueue.global(qos: .userInitiated).async {
            // Do something useful in the background
            self.doSomeWork()
            // IMPORTANT - Dispatch back to the main thread. Always access UI
            // classes (including MBProgressHUD) on the main thread.
            DispatchQueue.main.async {
                hud.hide(true)
            }
        }
    }
    
    func determinateExample() -> Void {
        let hud = DKProgressViewHUD.showHUD(view: (self.navigationController?.view)!, animated: true)
        // Set the determinate mode to show task progress.
        hud.mode = .determinate;
        hud.label?.text = NSLocalizedString("Loading...", comment:"HUD loading title");
        DispatchQueue.global(qos: .userInitiated).async {
            // Do something useful in the background
            self.doSomeWorkWithProgress()
            // IMPORTANT - Dispatch back to the main thread. Always access UI
            // classes (including MBProgressHUD) on the main thread.
            DispatchQueue.main.async {
                hud.hide(true)
            }
        }
    }
    
    func determinateNSProgressExample() -> Void {
        let hud = DKProgressViewHUD.showHUD(view: (self.navigationController?.view)!, animated: true)
        // Set the determinate mode to show task progress.
        hud.mode = .determinate;
        hud.label?.text = NSLocalizedString("Loading...", comment:"HUD loading title");
        
        // Set up NSProgress
        let progressObject = Progress.discreteProgress(totalUnitCount: 100)
        hud.progressObject = progressObject;
        
        // Configure a cancel button.
        hud.button?.setTitle(NSLocalizedString("Cancel",comment:"HUD cancel button title"), for: .normal)
        hud.button?.addTarget(progressObject, action: #selector(progressObject.cancel), for: .touchUpInside)
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Do something useful in the background
            self.doSomeWorkWithProgressObject(progressObject)
            // IMPORTANT - Dispatch back to the main thread. Always access UI
            // classes (including MBProgressHUD) on the main thread.
            DispatchQueue.main.async {
                hud.hide(true)
            }
        }
    }
    
    func annularDeterminateExample() -> Void {
        let hud = DKProgressViewHUD.showHUD(view: (self.navigationController?.view)!, animated: true)
        // Set the annular determinate mode to show task progress.
        hud.mode = .annularDeterminate;
        hud.label?.text = NSLocalizedString("Loading...", comment:"HUD loading title");
        DispatchQueue.global(qos: .userInitiated).async {
            // Do something useful in the background
            self.doSomeWorkWithProgress()
            // IMPORTANT - Dispatch back to the main thread. Always access UI
            // classes (including MBProgressHUD) on the main thread.
            DispatchQueue.main.async {
                hud.hide(true)
            }
        }
    }
    
    func barDeterminateExample() -> Void {
        let hud = DKProgressViewHUD.showHUD(view: (self.navigationController?.view)!, animated: true)
        // Set the bar determinate mode to show task progress.
        hud.mode = .determinateHorizontalBar;
        hud.label?.text = NSLocalizedString("Loading...", comment:"HUD loading title");
        DispatchQueue.global(qos: .userInitiated).async {
            // Do something useful in the background
            self.doSomeWorkWithProgress()
            // IMPORTANT - Dispatch back to the main thread. Always access UI
            // classes (including MBProgressHUD) on the main thread.
            DispatchQueue.main.async {
                hud.hide(true)
            }
        }
    }
    
    func customViewExample() -> Void {
        let hud = DKProgressViewHUD.showHUD(view: (self.navigationController?.view)!, animated: true)
        // Set the custom view mode to show any view.
        hud.mode = .customView;
        // Set an image view with a checkmark.
        let image = UIImage(named:"Checkmark")?.withRenderingMode(.alwaysTemplate)
        hud.customView = UIImageView.init(image: image)
        // Looks a bit nicer if we make it square.
        hud.minSize = CGSize.init(width: 50, height: 50)
        hud.isSquare = true;
        // Optional label text.
        hud.label?.text = NSLocalizedString("Done", comment:"HUD done title");
        
        hud.hide(true, afterDelay: 3.0)
    }
    
    func textExample() -> Void {
        let hud = DKProgressViewHUD.showHUD(view: (self.navigationController?.view)!, animated: true)
        // Set the text mode to show only text.
        hud.mode = .text;
        hud.label?.text = NSLocalizedString("Message here!", comment:"HUD message title");
        hud.detailsLabel?.text = NSLocalizedString("Message here! jdfjkbgjdgfbgjwbjbefvbehfvbhdvvdydffytwdytwefdywectywecgvhcvchvdhcveycveyucvyevywveyucvewyucvyvcuyev", comment:"HUD message title");
        // Move to bottm center.
        hud.offset = CGPoint.init(x: 0, y: DKProgressMaxOffset)
        hud.hide(true, afterDelay: 3.0)
    }
    
    func cancelationExample() -> Void {
        let hud = DKProgressViewHUD.showHUD(view: (self.navigationController?.view)!, animated: true)
        // Set the determinate mode to show task progress.
        hud.mode = .determinate;
        hud.label?.text = NSLocalizedString("Loading...", comment:"HUD loading title");
        
        // Configure the button.
        hud.button?.setTitle(NSLocalizedString("Cancel", comment:"HUD cancel button title"), for: .normal)
        hud.button?.addTarget(self, action: #selector(cancelWork), for: .touchUpInside)
        DispatchQueue.global(qos: .userInitiated).async {
            // Do something useful in the background
            self.doSomeWorkWithProgress()
            // IMPORTANT - Dispatch back to the main thread. Always access UI
            // classes (including MBProgressHUD) on the main thread.
            DispatchQueue.main.async {
                hud.hide(true)
            }
        }
    }
    
    func modeSwitchingExample() -> Void {
        let hud = DKProgressViewHUD.showHUD(view: (self.navigationController?.view)!, animated: true)
        // Set some text to show the initial status.
        hud.label?.text = NSLocalizedString("Preparing...", comment:"HUD preparing title");
        // Will look best, if we set a minimum size.
        hud.minSize = CGSize.init(width: 150, height: 100)
//        hud.offset = CGPoint.init(x: 0, y: 1000)
        DispatchQueue.global(qos: .userInitiated).async {
            // Do something useful in the background
            self.doSomeWorkWithMixedProgress()
            // IMPORTANT - Dispatch back to the main thread. Always access UI
            // classes (including MBProgressHUD) on the main thread.
            DispatchQueue.main.async {
                hud.hide(true)
            }
        }
    }
    
    func networkingExample() -> Void {
        let hud = DKProgressViewHUD.showHUD(view: (self.navigationController?.view)!, animated: true)
        // Set some text to show the initial status.
        hud.label?.text = NSLocalizedString("Preparing...", comment:"HUD preparing title");
        // Will look best, if we set a minimum size.
        hud.minSize = CGSize.init(width: 150, height: 100)
        
        self.doSomeNetworkWorkWithProgress()
    }
    
    func dimBackgroundExample() -> Void {
        let hud = DKProgressViewHUD.showHUD(view: (self.navigationController?.view)!, animated: true)
        // Change the background view style and color.
        hud.backgroundView?.style = .solidColor;
        hud.backgroundView?.color = UIColor.init(white: 0.0, alpha: 0.1)
        DispatchQueue.global(qos: .userInitiated).async {
            // Do something useful in the background
            self.doSomeWork()
            // IMPORTANT - Dispatch back to the main thread. Always access UI
            // classes (including MBProgressHUD) on the main thread.
            DispatchQueue.main.async {
                hud.hide(true)
            }
        }
    }
    
    func colorExample() -> Void {
        let hud = DKProgressViewHUD.showHUD(view: (self.navigationController?.view)!, animated: true)
        hud.contentColor = UIColor.init(red: 0, green: 0.6, blue: 0.7, alpha: 1)
        
        // Set the label text.
        hud.label?.text = NSLocalizedString("Loading...", comment:"HUD loading title");
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Do something useful in the background
            self.doSomeWork()
            // IMPORTANT - Dispatch back to the main thread. Always access UI
            // classes (including MBProgressHUD) on the main thread.
            DispatchQueue.main.async {
                hud.hide(true)
            }
        }
    }
    
    //MARK - Tasks
    
    func doSomeWork() -> Void {
        sleep(UInt32(3.0))
    }
    
    func doSomeWorkWithProgressObject(_ progressObject:Progress) -> Void {
        while (progressObject.fractionCompleted < 1.0) {
            if (progressObject.isCancelled) {break;}
            progressObject.becomeCurrent(withPendingUnitCount: 1)
            progressObject.resignCurrent()
            usleep(50000);
        }
    }
    
    func doSomeWorkWithProgress() -> Void {
        self.isCanceled = false;
        // This just increases the progress indicator in a loop.
        var progress:Float = 0.0;
        while (progress < 1.0) {
            if (self.isCanceled) {break;}
            progress += 0.01;
            DispatchQueue.main.async {
                DKProgressViewHUD.HUD(view: (self.navigationController?.view)!)?.progress = progress
            }
            usleep(50000);
        }
    }
    
    func doSomeWorkWithMixedProgress() -> Void {
        let hud = DKProgressViewHUD.HUD(view: (self.navigationController?.view)!)
        // Indeterminate mode
        sleep(2);
        // Switch to determinate mode
        DispatchQueue.main.async {
            hud?.mode = .determinate;
            hud?.label?.text = NSLocalizedString("Loading...", comment:"HUD loading title");
        }
        var progress:Float = 0.0;
        while (progress < 1.0) {
            progress += 0.01;
            DispatchQueue.main.async {
                hud?.progress = progress;
            }
            usleep(50000);
        }
        // Back to indeterminate mode
        DispatchQueue.main.async {
            hud?.mode = .indeterminate;
            hud?.label?.text = NSLocalizedString("Cleaning up...", comment:"HUD cleanining up title");
        }
        sleep(2);
        DispatchQueue.main.async {
            let image = UIImage(named:"Checkmark")?.withRenderingMode(.alwaysTemplate)
            hud?.customView = UIImageView.init(image: image)
            hud?.mode = .customView;
            hud?.label?.text = NSLocalizedString("Completed", comment:"HUD completed title");
        }
        sleep(2);
    }
    
    func doSomeNetworkWorkWithProgress() -> Void {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let url = URL.init(string: "https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/HT1425/sample_iPod.m4v.zip")
        let task = session.downloadTask(with: url!)
        task.resume()
    }
    
    func cancelWork(_ sender:Any) -> Void {
        self.isCanceled = true
    }

}

extension ViewController :UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.examples.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.examples[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let example = self.examples[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DKExampleCell", for: indexPath)
        cell.textLabel?.text = example.title;
        cell.textLabel?.textColor = self.view.tintColor;
        cell.textLabel?.textAlignment = .center;
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = cell.textLabel?.textColor.withAlphaComponent(0.1)
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let example = self.examples[indexPath.section][indexPath.row]
        self.perform(example.selector)
        let delay = DispatchTime.now() + .milliseconds(100)
        DispatchQueue.main.asyncAfter(deadline: delay) { 
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension ViewController :URLSessionDownloadDelegate{
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        DispatchQueue.main.async {
            let hud = DKProgressViewHUD.HUD(view: (self.navigationController?.view)!)
            let image = UIImage(named:"Checkmark")?.withRenderingMode(.alwaysTemplate)
            hud?.customView = UIImageView.init(image: image)
            hud?.mode = .customView;
            hud?.label?.text = NSLocalizedString("Completed", comment:"HUD completed title");
            hud?.hide(true, afterDelay: 3.0)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        // Update the UI on the main thread
        DispatchQueue.main.async {
            let hud = DKProgressViewHUD.HUD(view: (self.navigationController?.view)!)
            hud?.mode = .determinate
            hud?.progress = progress
        }
    }
}

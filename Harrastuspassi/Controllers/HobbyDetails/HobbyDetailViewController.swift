//
//  HobbyDetailViewController.swift
//  Harrastuspassi
//
//  Created by Tiia Trogen on 25/07/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit
import GoogleMaps
import Hero

class HobbyDetailViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    var panGR: UIPanGestureRecognizer!
    var hobbyEvent: HobbyEventData?
    var camera: GMSCameraPosition?
    var heroID: String?
    var imageHeroID: String?
    var titleHeroID: String?
    var locationHeroID: String?
    var dayOfWeekLabelHeroID: String?
    var dismissStarted = false;
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var organizerLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var closeButton: UIButton!
    
    var startingOffset: CGFloat = 0;
    
    var image: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.hero.isEnabled = true;
        view.hero.id = heroID;
        imageView.hero.id = imageHeroID;
        titleLabel.hero.id = titleHeroID;
        locationLabel.hero.id = locationHeroID;
        dayOfWeekLabel.hero.id = dayOfWeekLabelHeroID;
        closeButton.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude);
        closeButton.hero.isEnabled = true;
        closeButton.hero.modifiers = [.duration(0.7), .translate(x:100), .useGlobalCoordinateSpace];
        dayOfWeekLabel.adjustsFontSizeToFitWidth = true;
        
        panGR = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognizer:)));
        panGR.delegate = self
        scrollView.addGestureRecognizer(panGR);
        scrollView.bounces = false;
        startingOffset = scrollView.contentOffset.y;
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        if let d = hobbyEvent?.startDayOfWeek {
            dayOfWeekLabel.text = Weekdays().list.first{$0.id == d}?.name
        }
        
        closeButton.layer.cornerRadius = 15;
        closeButton.clipsToBounds = true;
        
        if let event = hobbyEvent {
            titleLabel.text = event.hobby?.name
            if let img = image {
                imageView.image = img
                
            } else if let imageUrl = event.hobby?.image {
                let url = URL (string: imageUrl)
                imageView.loadurl(url: url!, completition: nil);
            } else {
                imageView.image = UIImage(named: "ic_panorama")
            }
        }
        reloadData();
        setUpMapView();
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func reloadData() {
        let getDateFormatter  = DateFormatter()
        getDateFormatter.dateFormat = "yyyy-MM-dd"
        let getTimeFormatter = DateFormatter()
        getTimeFormatter.dateFormat = "HH:mm:ss"
        guard let event = hobbyEvent, let d = hobbyEvent?.startDate, let t = hobbyEvent?.startTime else {
            return
        }
        
        let date = getDateFormatter.date(from: d)
        let time = getTimeFormatter.date(from: t)
        let dateOutputDateFormatter = DateFormatter()
        dateOutputDateFormatter.dateFormat = "dd.MM.yyyy"
        let timeOutputFormatter = DateFormatter()
        timeOutputFormatter.dateFormat = "HH:mm"
        
        organizerLabel.text = event.hobby?.organizer?.name
        if let t = time { timeLabel.text = timeOutputFormatter.string(from: t) }
        locationLabel.text = event.hobby?.location?.name
        descriptionLabel.text = event.hobby?.description
        dateLabel.adjustsFontSizeToFitWidth = true;
        if let d = date { dateLabel.text = dateOutputDateFormatter.string(from: d) }
        guard let location = event.hobby?.location else {
            return
        }
        if let zipCode = location.zipCode, let address = location.address, let city = location.city {
            addressLabel.text = address + ", " + zipCode + ", " + city
        }
        
    }
    
    func setUpMapView() {
        guard let lat = hobbyEvent?.hobby?.location?.lat, let lon = hobbyEvent?.hobby?.location?.lon, let title = hobbyEvent?.hobby?.name, let snippet = hobbyEvent?.hobby?.location?.name else {
            return
        }
        camera = GMSCameraPosition.camera(withLatitude: Double(lat), longitude: Double(lon), zoom: 12.0)
        guard let cam = camera else {
            return
        }
        self.view.layoutIfNeeded()
        mapView.camera = cam;
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: Double(lat), longitude: Double(lon))
        marker.title = title
        marker.snippet = snippet
        marker.map = mapView
    }
    
    @objc func handlePan(gestureRecognizer:UIPanGestureRecognizer) {
        let translation = panGR.translation(in: nil)
        let progress = translation.y / 2 / view.bounds.height
        switch panGR.state {
        case .began:
            // begin the transition as normal
            if scrollView.contentOffset.y == self.startingOffset {
                print("OFFSET 0")
                
            }
            
        case .changed:
            // calculate the progress based on how far the user moved
            let translation = panGR.translation(in: nil)
            let progress = translation.y / 2 / view.bounds.height
            if scrollView.isAtTop && panGR.direction == .down && !dismissStarted {
                dismissStarted = true;
                dismiss(animated: true, completion: nil)
            }
            if dismissStarted {
                Hero.shared.update(CGFloat(progress))
            }
        default:
            if progress + panGR.velocity(in: nil).y / view.bounds.height > 0.3 && dismissStarted {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
                dismissStarted = false;
            }
        }
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true;
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil);
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
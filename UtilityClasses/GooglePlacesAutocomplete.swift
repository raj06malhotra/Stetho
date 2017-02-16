//
//  GooglePlacesAutocomplete.swift
//  GooglePlacesAutocomplete
//
//  Created by Howard Wilson on 10/02/2015.
//  Copyright (c) 2015 Howard Wilson. All rights reserved.
//
/*
import UIKit

public let ErrorDomain: String! = "GooglePlacesAutocompleteErrorDomain"

public struct LocationBias {
  public let latitude: Double
  public let longitude: Double
  public let radius: Int
  
  public init(latitude: Double = 0, longitude: Double = 0, radius: Int = 20000000) {
    self.latitude = latitude
    self.longitude = longitude
    self.radius = radius
  }
  
  public var location: String {
    return "\(latitude),\(longitude)"
  }
}

public enum PlaceType: CustomStringConvertible {
  case all
  case geocode
  case address
  case establishment
  case regions
  case cities

  public var description : String {
    switch self {
      case .all: return ""
      case .geocode: return "geocode"
      case .address: return "address"
      case .establishment: return "establishment"
      case .regions: return "(regions)"
      case .cities: return "(cities)"
    }
  }
}

open class Place: NSObject {
  open let id: String
  open let desc: String
  open var apiKey: String?

  override open var description: String {
    get { return desc }
  }

  public init(id: String, description: String) {
    self.id = id
    self.desc = description
  }

  public convenience init(prediction: [String: AnyObject], apiKey: String?) {
    self.init(
      id: prediction["place_id"] as! String,
      description: prediction["description"] as! String
    )

    self.apiKey = apiKey
  }

  /**
    Call Google Place Details API to get detailed information for this place
  
    Requires that Place#apiKey be set
  
    - parameter result: Callback on successful completion with detailed place information
  */
  open func getDetails(_ result: @escaping (PlaceDetails) -> ()) {
    GooglePlaceDetailsRequest(place: self).request(result)
  }
}

open class PlaceDetails: CustomStringConvertible {
  open let name: String
  open let latitude: Double
  open let longitude: Double
  open let raw: [String: AnyObject]

  public init(json: [String: AnyObject]) {
    let result = json["result"] as! [String: AnyObject]
    let geometry = result["geometry"] as! [String: AnyObject]
    let location = geometry["location"] as! [String: AnyObject]

    self.name = result["name"] as! String
    self.latitude = location["lat"] as! Double
    self.longitude = location["lng"] as! Double
    self.raw = json
  }

  open var description: String {
    return "PlaceDetails: \(name) (\(latitude), \(longitude))"
  }
}

@objc public protocol GooglePlacesAutocompleteDelegate {
  @objc optional func placesFound(_ places: [Place])
  @objc optional func placeSelected(_ place: Place)
  @objc optional func placeViewClosed()
}

// MARK: - GooglePlacesAutocomplete
open class GooglePlacesAutocomplete: UINavigationController {
  open var gpaViewController: GooglePlacesAutocompleteContainer!
  open var closeButton: UIBarButtonItem!

  // Proxy access to container navigationItem
  open override var navigationItem: UINavigationItem {
    get { return gpaViewController.navigationItem }
  }

  open var placeDelegate: GooglePlacesAutocompleteDelegate? {
    get { return gpaViewController.delegate }
    set { gpaViewController.delegate = newValue }
  }
  
  open var locationBias: LocationBias? {
    get { return gpaViewController.locationBias }
    set { gpaViewController.locationBias = newValue }
  }

  public convenience init(apiKey: String, placeType: PlaceType = .all) {
    let gpaViewController = GooglePlacesAutocompleteContainer(
      apiKey: apiKey,
      placeType: placeType
    )

    self.init(rootViewController: gpaViewController)
    self.gpaViewController = gpaViewController

    closeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(GooglePlacesAutocomplete.close))
    closeButton.style = UIBarButtonItemStyle.done

    gpaViewController.navigationItem.leftBarButtonItem = closeButton
    gpaViewController.navigationItem.title = "Enter Address"
  }

  func close() {
    placeDelegate?.placeViewClosed?()
  }

  open func reset() {
    gpaViewController.searchBar.text = ""
    gpaViewController.searchBar(gpaViewController.searchBar, textDidChange: "")
  }
}

// MARK: - GooglePlacesAutocompleteContainer
open class GooglePlacesAutocompleteContainer: UIViewController {
  @IBOutlet open weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var topConstraint: NSLayoutConstraint!

  var delegate: GooglePlacesAutocompleteDelegate?
  var apiKey: String?
  var places = [Place]()
  var placeType: PlaceType = .all
  var locationBias: LocationBias?

  convenience init(apiKey: String, placeType: PlaceType = .all) {
    let bundle = Bundle(for: GooglePlacesAutocompleteContainer.self)

    self.init(nibName: "GooglePlacesAutocomplete", bundle: bundle)
    self.apiKey = apiKey
    self.placeType = placeType
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override open func viewWillLayoutSubviews() {
    topConstraint.constant = topLayoutGuide.length
  }

  override open func viewDidLoad() {
    super.viewDidLoad()

    NotificationCenter.default.addObserver(self, selector: #selector(GooglePlacesAutocompleteContainer.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(GooglePlacesAutocompleteContainer.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    searchBar.becomeFirstResponder()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
  }

  func keyboardWasShown(_ notification: Notification) {
    if isViewLoaded && view.window != nil {
      let info: Dictionary = (notification as NSNotification).userInfo!
      let keyboardSize: CGSize = ((info[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue.size)
      let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)

      tableView.contentInset = contentInsets;
      tableView.scrollIndicatorInsets = contentInsets;
    }
  }

  func keyboardWillBeHidden(_ notification: Notification) {
    if isViewLoaded && view.window != nil {
      self.tableView.contentInset = UIEdgeInsets.zero
      self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
  }
}

// MARK: - GooglePlacesAutocompleteContainer (UITableViewDataSource / UITableViewDelegate)
extension GooglePlacesAutocompleteContainer: UITableViewDataSource, UITableViewDelegate {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return places.count
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 

    // Get the corresponding candy from our candies array
    let place = self.places[(indexPath as NSIndexPath).row]

    // Configure the cell
    cell.textLabel!.text = place.description
    cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
    
    return cell
  }

  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    delegate?.placeSelected?(self.places[(indexPath as NSIndexPath).row])
  }
}

// MARK: - GooglePlacesAutocompleteContainer (UISearchBarDelegate)
extension GooglePlacesAutocompleteContainer: UISearchBarDelegate {
  public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if (searchText == "") {
      self.places = []
      tableView.isHidden = true
    } else {
      getPlaces(searchText)
    }
  }

  /**
    Call the Google Places API and update the view with results.

    - parameter searchString: The search query
  */
  
  fileprivate func getPlaces(_ searchString: String) {
    var params = [
      "input": searchString,
      "types": placeType.description,
      "components": "country:IN",
      "key": apiKey ?? ""
    ]
    
    if let bias = locationBias {
      params["location"] = bias.location
      params["radius"] = bias.radius.description
    }
    
    if (searchString == ""){
      return
    }
    
    GooglePlacesRequestHelpers.doRequest(
      "https://maps.googleapis.com/maps/api/place/autocomplete/json",
      params: params
      ) { json, error in
        if let json = json{
          if let predictions = json["predictions"] as? Array<[String: AnyObject]> {
            self.places = predictions.map { (prediction: [String: AnyObject]) -> Place in
              return Place(prediction: prediction, apiKey: self.apiKey)
            }
          self.tableView.reloadData()
          self.tableView.isHidden = false
          self.delegate?.placesFound?(self.places)
        }
      }
    }
  }
}

// MARK: - GooglePlaceDetailsRequest
class GooglePlaceDetailsRequest {
  let place: Place

  init(place: Place) {
    self.place = place
  }

  func request(_ result: @escaping (PlaceDetails) -> ()) {
    GooglePlacesRequestHelpers.doRequest(
      "https://maps.googleapis.com/maps/api/place/details/json",
      params: [
        "placeid": place.id,
        "key": place.apiKey ?? ""
      ]
    ) { json, error in
      if let json = json as? [String: AnyObject] {
        result(PlaceDetails(json: json))
      }
      if let error = error {
        // TODO: We should probably pass back details of the error
        print("Error fetching google place details: \(error)")
      }
    }
  }
}

// MARK: - GooglePlacesRequestHelpers
class GooglePlacesRequestHelpers {
  /**
  Build a query string from a dictionary

  - parameter parameters: Dictionary of query string parameters
  - returns: The properly escaped query string
  */
  fileprivate class func query(_ parameters: [String: AnyObject]) -> String {
    var components: [(String, String)] = []
    for key in Array(parameters.keys).sorted(by: <) {
      let value: AnyObject! = parameters[key]
      components += [(escape(key), escape("\(value)"))]
    }

    return (components.map{"\($0)=\($1)"} as [String]).joined(separator: "&")
  }

  fileprivate class func escape(_ string: String) -> String {
    let legalURLCharactersToBeEscaped: CFString = ":/?&=;+!@#$()',*" as CFString
    return CFURLCreateStringByAddingPercentEscapes(nil, string as CFString!, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
  }

  fileprivate class func doRequest(_ url: String, params: [String: String], completion: @escaping (NSDictionary?,NSError?) -> ()) {
    let request = NSMutableURLRequest(
      url: URL(string: "\(url)?\(query(params as [String : AnyObject]))")!
    )

    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: { data, response, error in
      self.handleResponse(data, response: response as? , error: error, completion: completion)
    }) 

    task.resume()
  }

  fileprivate class func handleResponse(_ data: Data!, response: HTTPURLResponse!, error: NSError!, completion: @escaping (NSDictionary?, NSError?) -> ()) {
    
    // Always return on the main thread...
    let done: ((NSDictionary?, NSError?) -> Void) = {(json, error) in
        DispatchQueue.main.async(execute: {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            completion(json,error)
        })
    }
    
    if let error = error {
      print("GooglePlaces Error: \(error.localizedDescription)")
      done(nil,error)
      return
    }

    if response == nil {
      print("GooglePlaces Error: No response from API")
      let error = NSError(domain: ErrorDomain, code: 1001, userInfo: [NSLocalizedDescriptionKey:"No response from API"])
      done(nil,error)
      return
    }

    if response.statusCode != 200 {
      print("GooglePlaces Error: Invalid status code \(response.statusCode) from API")
      let error = NSError(domain: ErrorDomain, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:"Invalid status code"])
      done(nil,error)
      return
    }
    
    let json: NSDictionary?
    do {
      json = try JSONSerialization.jsonObject(
        with: data,
        options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
    } catch {
      print("Serialisation error")
      let serialisationError = NSError(domain: ErrorDomain, code: 1002, userInfo: [NSLocalizedDescriptionKey:"Serialization error"])
      done(nil,serialisationError)
      return
    }

    if let status = json?["status"] as? String {
      if status != "OK" {
        print("GooglePlaces API Error: \(status)")
        let error = NSError(domain: ErrorDomain, code: 1002, userInfo: [NSLocalizedDescriptionKey:status])
        done(nil,error)
        return
      }
    }
    
    done(json,nil)

  }
}
 
 
 
 
 */

//
//  GooglePlacesAutocomplete.swift
//  GooglePlacesAutocomplete
//
//  Created by Howard Wilson on 10/02/2015.
//  Copyright (c) 2015 Howard Wilson. All rights reserved.
//
/*
import UIKit

public let ErrorDomain: String! = "GooglePlacesAutocompleteErrorDomain"

public struct LocationBias {
    public let latitude: Double
    public let longitude: Double
    public let radius: Int
    
    public init(latitude: Double = 0, longitude: Double = 0, radius: Int = 20000000) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
    
    public var location: String {
        return "\(latitude),\(longitude)"
    }
}

public enum PlaceType: CustomStringConvertible {
    case All
    case Geocode
    case Address
    case Establishment
    case Regions
    case Cities
    
    public var description : String {
        switch self {
        case .All: return ""
        case .Geocode: return "geocode"
        case .Address: return "address"
        case .Establishment: return "establishment"
        case .Regions: return "(regions)"
        case .Cities: return "(cities)"
        }
    }
}

public class Place: NSObject {
    public let id: String
    public let desc: String
    public var apiKey: String?
    
    override public var description: String {
        get { return desc }
    }
    
    public init(id: String, description: String) {
        self.id = id
        self.desc = description
    }
    
    public convenience init(prediction: [String: AnyObject], apiKey: String?) {
        self.init(
            id: prediction["place_id"] as! String,
            description: prediction["description"] as! String
        )
        
        self.apiKey = apiKey
    }
    
    /**
     Call Google Place Details API to get detailed information for this place
     
     Requires that Place#apiKey be set
     
     - parameter result: Callback on successful completion with detailed place information
     */
    public func getDetails(result: @escaping (PlaceDetails) -> ()) {
        GooglePlaceDetailsRequest(place: self).request(result: result)
    }
}

public class PlaceDetails: CustomStringConvertible {
    public let name: String
    public let latitude: Double
    public let longitude: Double
    public let raw: [String: AnyObject]
    
    public init(json: [String: AnyObject]) {
        let result = json["result"] as! [String: AnyObject]
        let geometry = result["geometry"] as! [String: AnyObject]
        let location = geometry["location"] as! [String: AnyObject]
        
        self.name = result["name"] as! String
        self.latitude = location["lat"] as! Double
        self.longitude = location["lng"] as! Double
        self.raw = json
    }
    
    public var description: String {
        return "PlaceDetails: \(name) (\(latitude), \(longitude))"
    }
}

@objc public protocol GooglePlacesAutocompleteDelegate {
    @objc optional func placesFound(places: [Place])
    @objc optional func placeSelected(place: Place)
    @objc optional func placeViewClosed()
}

// MARK: - GooglePlacesAutocomplete
public class GooglePlacesAutocomplete: UINavigationController {
    public var gpaViewController: GooglePlacesAutocompleteContainer!
    public var closeButton: UIBarButtonItem!
    
    // Proxy access to container navigationItem
    public override var navigationItem: UINavigationItem {
        get { return gpaViewController.navigationItem }
    }
    
    public var placeDelegate: GooglePlacesAutocompleteDelegate? {
        get { return gpaViewController.delegate }
        set { gpaViewController.delegate = newValue }
    }
    
    public var locationBias: LocationBias? {
        get { return gpaViewController.locationBias }
        set { gpaViewController.locationBias = newValue }
    }
    
    public convenience init(apiKey: String, placeType: PlaceType = .All) {
        let gpaViewController = GooglePlacesAutocompleteContainer(
            apiKey: apiKey,
            placeType: placeType
        )
        
        self.init(rootViewController: gpaViewController)
        self.gpaViewController = gpaViewController
        
        closeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(GooglePlacesAutocomplete.close))
        closeButton.style = UIBarButtonItemStyle.done
        
        gpaViewController.navigationItem.leftBarButtonItem = closeButton
        gpaViewController.navigationItem.title = "Enter Address"
    }
    
    func close() {
        placeDelegate?.placeViewClosed?()
    }
    
    public func reset() {
        gpaViewController.searchBar.text = ""
        gpaViewController.searchBar(gpaViewController.searchBar, textDidChange: "")
//        gpaViewController.searchBar(searchBar: gpaViewController.searchBar, textDidChange: "")
//        gpaViewController.searchBar(gpaViewController.searchBar, textDidChange: "")
    }
}

// MARK: - GooglePlacesAutocompleteContainer
public class GooglePlacesAutocompleteContainer: UIViewController {
    @IBOutlet public weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var delegate: GooglePlacesAutocompleteDelegate?
    var apiKey: String?
    var places = [Place]()
    var placeType: PlaceType = .All
    var locationBias: LocationBias?
    
    convenience init(apiKey: String, placeType: PlaceType = .All) {
        let bundle = Bundle(for: GooglePlacesAutocompleteContainer.self)
//        let bundle = NSBundle(forClass: GooglePlacesAutocompleteContainer.self)
        
        self.init(nibName: "GooglePlacesAutocomplete", bundle: bundle)
        self.apiKey = apiKey
        self.placeType = placeType
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
//        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override public func viewWillLayoutSubviews() {
        topConstraint.constant = topLayoutGuide.length
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWasShown(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillBeHidden(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        
        
        
//        NotificationCenter.default.addObserver(self, selector: #selector(GooglePlacesAutocomplete.keyboardWasShown(_:)), name: .UIKeyboardWillShow, object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(GooglePlacesAutocomplete.keyboardWillBeHidden(_:)), name: .UIKeyboardWillHide, object: nil)


//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown:), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: "keyboardWillBeHidden:", name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        searchBar.becomeFirstResponder()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
//        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func keyboardWasShown( notification: NSNotification) {
        if isViewLoaded && view.window != nil {
            let info: Dictionary = notification.userInfo!
            let keyboardSize: CGSize = ((info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size)!
//            let keyboardSize: CGSize = (info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size)!
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
            
            tableView.contentInset = contentInsets;
            tableView.scrollIndicatorInsets = contentInsets;
        }
    }
    
    func keyboardWillBeHidden( notification: NSNotification) {
        if isViewLoaded && view.window != nil {
            self.tableView.contentInset = UIEdgeInsets.zero
            self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
        }
    }
}

// MARK: - GooglePlacesAutocompleteContainer (UITableViewDataSource / UITableViewDelegate)
extension GooglePlacesAutocompleteContainer: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        // Get the corresponding candy from our candies array
        let place = self.places[indexPath.row]
        
        // Configure the cell
        cell.textLabel!.text = place.description
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        delegate?.placeSelected(place: self.places[indexPath.row])
        delegate?.placeSelected?(place: self.places[indexPath.row])
    }
}

// MARK: - GooglePlacesAutocompleteContainer (UISearchBarDelegate)
extension GooglePlacesAutocompleteContainer: UISearchBarDelegate {
   
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "") {
            self.places = []
            tableView.isHidden = true
        } else {
            getPlaces(searchString: searchText)
        }
    }
    
    /**
     Call the Google Places API and update the view with results.
     
     - parameter searchString: The search query
     */
    
    private func getPlaces(searchString: String) {
        var params = [
            "input": searchString,
            "types": placeType.description,
            "key": apiKey ?? ""
        ]
        
        if let bias = locationBias {
            params["location"] = bias.location
            params["radius"] = bias.radius.description
        }
        
        if (searchString == ""){
            return
        }
        
    
        GooglePlacesRequestHelpers.doRequest(
            "https://maps.googleapis.com/maps/api/place/autocomplete/json",
            params: params
        ) { json, error in
            if let json = json{
                if let predictions = json["predictions"] as? Array<[String: AnyObject]> {
                    self.places = predictions.map { (prediction: [String: AnyObject]) -> Place in
                        return Place(prediction: prediction, apiKey: self.apiKey)
                    }
                    self.tableView.reloadData()
                    self.tableView.hidden = false
                    self.delegate?.placesFound?(self.places)
                }
            }
        }
    }
}

// MARK: - GooglePlaceDetailsRequest
class GooglePlaceDetailsRequest {
    let place: Place
    
    init(place: Place) {
        self.place = place
    }
    
    func request(result: @escaping (PlaceDetails) -> ()) {
        GooglePlacesRequestHelpers.doRequest(
            "https://maps.googleapis.com/maps/api/place/details/json",
            params: [
                "placeid": place.id,
                "key": place.apiKey ?? ""
            ]
        ) { json, error in
            if let json = json as? [String: AnyObject] {
                result(PlaceDetails(json: json))
            }
            if let error = error {
                // TODO: We should probably pass back details of the error
                print("Error fetching google place details: \(error)")
            }
        }
    }
}

// MARK: - GooglePlacesRequestHelpers
class GooglePlacesRequestHelpers {
    /**
     Build a query string from a dictionary
     
     - parameter parameters: Dictionary of query string parameters
     - returns: The properly escaped query string
     */
    private class func query(parameters: [String: AnyObject]) -> String {
        var components: [(String, String)] = []
        for key in Array(parameters.keys).sort(<) {
            let value: AnyObject! = parameters[key]
            components += [(escape(key), escape("\(value)"))]
        }
        
        return (components.map{"\($0)=\($1)"} as [String]).joinWithSeparator("&")
    }
    
    private class func escape(string: String) -> String {
        let legalURLCharactersToBeEscaped: CFStringRef = ":/?&=;+!@#$()',*"
        return CFURLCreateStringByAddingPercentEscapes(nil, string, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
    }
    
    private class func doRequest(url: String, params: [String: String], completion: (NSDictionary?,NSError?) -> ()) {
        let request = NSMutableURLRequest(
            URL: NSURL(string: "\(url)?\(query(params))")!
        )
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            self.handleResponse(data, response: response as? NSHTTPURLResponse, error: error, completion: completion)
        }
        
        task.resume()
    }
    
    private class func handleResponse(data: NSData!, response: NSHTTPURLResponse!, error: NSError!, completion: (NSDictionary?, NSError?) -> ()) {
        
        // Always return on the main thread...
        let done: ((NSDictionary?, NSError?) -> Void) = {(json, error) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion(json,error)
            })
        }
        
        if let error = error {
            print("GooglePlaces Error: \(error.localizedDescription)")
            done(nil,error)
            return
        }
        
        if response == nil {
            print("GooglePlaces Error: No response from API")
            let error = NSError(domain: ErrorDomain, code: 1001, userInfo: [NSLocalizedDescriptionKey:"No response from API"])
            done(nil,error)
            return
        }
        
        if response.statusCode != 200 {
            print("GooglePlaces Error: Invalid status code \(response.statusCode) from API")
            let error = NSError(domain: ErrorDomain, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:"Invalid status code"])
            done(nil,error)
            return
        }
        
        let json: NSDictionary?
        do {
            json = try NSJSONSerialization.JSONObjectWithData(
                data,
                options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
        } catch {
            print("Serialisation error")
            let serialisationError = NSError(domain: ErrorDomain, code: 1002, userInfo: [NSLocalizedDescriptionKey:"Serialization error"])
            done(nil,serialisationError)
            return
        }
        
        if let status = json?["status"] as? String {
            if status != "OK" {
                print("GooglePlaces API Error: \(status)")
                let error = NSError(domain: ErrorDomain, code: 1002, userInfo: [NSLocalizedDescriptionKey:status])
                done(nil,error)
                return
            }
        }
        
        done(json,nil)
        
    }
}*/







//
//  GooglePlacesAutocomplete.swift
//  GooglePlacesAutocomplete
//
//  Created by Howard Wilson on 10/02/2015.
//  Copyright (c) 2015 Howard Wilson. All rights reserved.
//

import UIKit
import CoreLocation

public let ErrorDomain: String! = "GooglePlacesAutocompleteErrorDomain"

public struct LocationBias {
    public let latitude: CLLocationDegrees
    public let longitude: CLLocationDegrees
    public let radius: CLLocationDistance
    
    public init(latitude: Double = 0, longitude: Double = 0, radius: Int = 20000000) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = Double(radius)
    }
    
    public init(latitude: Double = 0, longitude: Double = 0, radius: CLLocationDistance = 20000000) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
    
    public init(location:CLLocation, radius: CLLocationDistance = 20000000){
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.radius = radius
    }
    
    public init(region:CLCircularRegion){
        self.latitude = region.center.latitude
        self.longitude = region.center.longitude
        self.radius = region.radius
    }
    
    public var location: String {
        return "\(latitude),\(longitude)"
    }
}

public enum PlaceType: CustomStringConvertible {
    case all
    case geocode
    case address
    case establishment
    case regions
    case cities
    
    public var description : String {
        switch self {
        case .all: return ""
        case .geocode: return "geocode"
        case .address: return "address"
        case .establishment: return "establishment"
        case .regions: return "(regions)"
        case .cities: return "(cities)"
        }
    }
}

open class Place: NSObject {
    open let id: String
    open let desc: String
    open var apiKey: String?
    
    override open var description: String {
        get { return desc }
    }
    
    public init(id: String, description: String) {
        self.id = id
        self.desc = description
    }
    
    public convenience init(prediction: [String: Any], apiKey: String?) {
        
        self.init(
            id: prediction["place_id"] as! String,
            description: prediction["description"] as! String
        )
        
        self.apiKey = apiKey
    }
    
    /**
     Call Google Place Details API to get detailed information for this place
     
     Requires that Place#apiKey be set
     
     - parameter result: Callback on successful completion with detailed place information
     */
    open func getDetails(_ result: @escaping (PlaceDetails) -> ()) {
        GooglePlaceDetailsRequest(place: self).request(result)
    }
}

open class PlaceDetails: CustomStringConvertible {
    open let name: String
    open let latitude: Double
    open let longitude: Double
    
    open let location: CLLocation
    
    open var region: CLCircularRegion
    
    open var radius: CLLocationDistance {
        get {
            return region.radius
        }
    }
    
    open let raw: [String: AnyObject]
    
    public init(json: [String: AnyObject]) {
        let result = json["result"] as! [String: AnyObject]
        let geometry = result["geometry"] as! [String: AnyObject]
        let location = geometry["location"] as! [String: AnyObject]
        
        self.name = result["name"] as! String
        self.latitude = location["lat"] as! Double
        self.longitude = location["lng"] as! Double
        self.location = CLLocation(latitude: self.latitude, longitude: self.longitude)
        
        var radius: CLLocationDistance = 10 // default to 10m radius
        
        if let viewport = geometry["viewport"] as? [String: AnyObject] {
            // We are assuming that the place is circular and using the north-east to centre distance to derive the radius
            let northEastDict = viewport["northeast"] as! [String: AnyObject]
            let northEast = CLLocation(latitude: northEastDict["lat"] as! Double, longitude: northEastDict["lng"] as! Double)
            
            radius = self.location.distance(from: northEast)
        }
        
        
        self.region = CLCircularRegion(center: self.location.coordinate, radius: radius, identifier: self.name)
        
        
        self.raw = json
        
    }
    
    open var description: String {
        return "PlaceDetails: \(name) (\(latitude), \(longitude))"
    }
}

@objc public protocol GooglePlacesAutocompleteDelegate {
    @objc optional func placesFound(_ places: [Place])
    @objc optional func placeSelected(_ place: Place)
    @objc optional func placeViewClosed()
}

// MARK: - GooglePlacesAutocompleteService

open class GooglePlacesAutocompleteService {
    var delegate: GooglePlacesAutocompleteDelegate?
    var apiKey: String?
    var places = [Place]()
    open var placeType: PlaceType = .all
    open var locationBias: LocationBias?
    open var country: String?
    
    public init(apiKey: String, placeType: PlaceType = .all) {
        self.apiKey = apiKey
        self.placeType = placeType
    }
    
    open func getPlaces(_ searchString: String, completion:@escaping (([Place]?, Error?) -> Void)) {
        var params = [
            "input": searchString,
            "types": placeType.description,
            "key": apiKey ?? ""
        ]
        
        if let bias = locationBias {
            params["location"] = bias.location
            params["radius"] = bias.radius.description
        }
        
        if let country = country {
            params["components"] = "country:\(country)"
        }
        
        if (searchString == ""){
            let error = NSError(domain: ErrorDomain, code: 1000, userInfo: [NSLocalizedDescriptionKey:"No search string given"])
            completion(nil,error)
            return
        }
        
        GooglePlacesRequestHelpers.doRequest(
            "https://maps.googleapis.com/maps/api/place/autocomplete/json",
            params: params
        ) { json, error in
            if let json = json{
                if let predictions = json["predictions"] as? Array<[String: Any]> {
                    self.places = predictions.map { (prediction: [String: Any]) -> Place in
                        return Place(prediction: prediction, apiKey: self.apiKey)
                    }
                    
                    completion(self.places, error)
                    self.delegate?.placesFound?(self.places)
                } else {
                    completion(nil, error)
                }
            } else {
                completion(nil,error)
            }
        }
    }
}

// MARK: - GooglePlacesAutocomplete (UINavigationController)

open class GooglePlacesAutocomplete: UINavigationController {
    open var gpaViewController: GooglePlacesAutocompleteContainer!
    open var closeButton: UIBarButtonItem!
    
    open var gpaService: GooglePlacesAutocompleteService!
    
    // Proxy access to container navigationItem
    open override var navigationItem: UINavigationItem {
        get { return gpaViewController.navigationItem }
    }
    
    open var placeDelegate: GooglePlacesAutocompleteDelegate? {
        get { return gpaService.delegate }
        set { gpaService.delegate = newValue }
    }
    
    open var locationBias: LocationBias? {
        get { return gpaService.locationBias }
        set { gpaService.locationBias = newValue }
    }
    
    public convenience init(apiKey: String, placeType: PlaceType = .all) {
        let service = GooglePlacesAutocompleteService(apiKey: apiKey, placeType: placeType)
        self.init(service:service)
    }
    
    public convenience init(service: GooglePlacesAutocompleteService) {
        
        let gpaViewController = GooglePlacesAutocompleteContainer(service: service)
        self.init(rootViewController: gpaViewController)
        self.gpaService = service
        self.gpaViewController = gpaViewController
        
        closeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(GooglePlacesAutocomplete.close))
        closeButton.style = UIBarButtonItemStyle.done
        
        gpaViewController.navigationItem.leftBarButtonItem = closeButton
        gpaViewController.navigationItem.title = "Enter Address"
    }
    
    func close() {
        placeDelegate?.placeViewClosed?()
    }
    
    open func reset() {
        gpaViewController.searchBar.text = ""
        gpaViewController.searchBar(gpaViewController.searchBar, textDidChange: "")
    }
}

// MARK: - GooglePlacesAutocompleteContainer
open class GooglePlacesAutocompleteContainer: UIViewController {
    @IBOutlet open weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    open var gpaService: GooglePlacesAutocompleteService!
    
    convenience init(service: GooglePlacesAutocompleteService) {
        let bundle = Bundle(for: GooglePlacesAutocompleteContainer.self)
        
        self.init(nibName: "GooglePlacesAutocomplete", bundle: bundle)
        self.gpaService = service
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override open func viewWillLayoutSubviews() {
        topConstraint.constant = topLayoutGuide.length
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(GooglePlacesAutocompleteContainer.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GooglePlacesAutocompleteContainer.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        searchBar.becomeFirstResponder()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func keyboardWasShown(_ notification: Notification) {
        if isViewLoaded && view.window != nil {
            if let info: Dictionary = (notification as NSNotification).userInfo,
                let keyboardSize: CGSize = ((info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size){
                let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
                tableView.contentInset = contentInsets;
                tableView.scrollIndicatorInsets = contentInsets;
            }
        }
    }
    
    func keyboardWillBeHidden(_ notification: Notification) {
        if isViewLoaded && view.window != nil {
            self.tableView.contentInset = UIEdgeInsets.zero
            self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
        }
    }
}

// MARK: - GooglePlacesAutocompleteContainer (UITableViewDataSource / UITableViewDelegate)
extension GooglePlacesAutocompleteContainer: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gpaService.places.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Get the corresponding candy from our candies array
        let place = gpaService.places[(indexPath as NSIndexPath).row]
        
        // Configure the cell
        cell.textLabel!.text = place.description
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        gpaService.delegate?.placeSelected?(gpaService.places[(indexPath as NSIndexPath).row])
    }
}

// MARK: - GooglePlacesAutocompleteContainer (UISearchBarDelegate)
extension GooglePlacesAutocompleteContainer: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "") {
            gpaService.places = []
            tableView.isHidden = true
        } else {
            getPlaces(searchText)
        }
    }
    
    /**
     Call the Google Places API and update the view with results.
     
     - parameter searchString: The search query
     */
    
    fileprivate func getPlaces(_ searchText: String){
        gpaService.getPlaces(searchText, completion: {(places: [Place]?,error: Error?) in
            self.tableView.reloadData()
            self.tableView.isHidden = false
            
        }
        )
    }
}

// MARK: - GooglePlaceDetailsRequest
class GooglePlaceDetailsRequest {
    let place: Place
    
    init(place: Place) {
        self.place = place
    }
    
    func request(_ result: @escaping (PlaceDetails) -> ()) {
        GooglePlacesRequestHelpers.doRequest(
            "https://maps.googleapis.com/maps/api/place/details/json",
            params: [
                "placeid": place.id,
                "key": place.apiKey ?? ""
            ]
        ) { json, error in
            if let json = json as? [String: AnyObject] {
                result(PlaceDetails(json: json))
            }
            if let error = error {
                // TODO: We should probably pass back details of the error
                print("Error fetching google place details: \(error)")
            }
        }
    }
}

// MARK: - GooglePlacesRequestHelpers
class GooglePlacesRequestHelpers {
    /**
     Build a query string from a dictionary
     
     - parameter parameters: Dictionary of query string parameters
     - returns: The properly escaped query string
     */
    
    typealias JSON = [String: Any]
    
    fileprivate class func query(_ parameters: [String: String]) -> String {
        var components: [(String, String)] = []
        for key in Array(parameters.keys).sorted(by: <) {
            let value = parameters[key]!
            components += [(escape(key), escape("\(value)"))]
        }
        
        return (components.map{"\($0)=\($1)"} as [String]).joined(separator: "&")
    }
    
    fileprivate class func escape(_ string: String) -> String {
        let legalURLCharactersToBeEscaped: CFString = ":/?&=;+!@#$()',*" as CFString
        return CFURLCreateStringByAddingPercentEscapes(nil, string as CFString!, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as! String
    }
    
    fileprivate class func doRequest(_ url: String, params: [String: String], completion: @escaping (JSON?,Error?) -> ()) {
        let request = URLRequest(
            url: URL(string: "\(url)?\(query(params))")!
        )
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request){ data, response, error in
            self.handleResponse(data, response: response , error: error, completion: completion)
        }
        
        task.resume()
    }
    
    fileprivate class func handleResponse(_ data: Data?, response: URLResponse?, error: Error?, completion: @escaping (JSON?, Error?) -> ()) {
        
        // Always return on the main thread...
        let done: ((JSON?, Error?) -> Void) = {(json, error) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completion(json,error)
            })
        }
        
        if let error = error {
            print("GooglePlaces Error: \(error.localizedDescription)")
            done(nil,error)
            return
        }
        
        if response == nil {
            print("GooglePlaces Error: No response from API")
            let error = NSError(domain: ErrorDomain, code: 1001, userInfo: [NSLocalizedDescriptionKey:"No response from API"])
            done(nil,error)
            return
        }
        
        let httpResponse = response as! HTTPURLResponse
        
        
        if httpResponse.statusCode != 200 {
            print("GooglePlaces Error: Invalid status code \(httpResponse.statusCode) from API")
            let error = NSError(domain: ErrorDomain, code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey:"Invalid status code"])
            done(nil,error)
            return
        }
        
        let json: NSDictionary?
        do {
            json = try JSONSerialization.jsonObject(
                with: data!,
                options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
        } catch {
            print("Serialisation error")
            let serialisationError = NSError(domain: ErrorDomain, code: 1002, userInfo: [NSLocalizedDescriptionKey:"Serialization error"])
            done(nil,serialisationError)
            return
        }
        
        if let status = json?["status"] as? String {
            if status != "OK" {
                print("GooglePlaces API Error: \(status)")
                let error = NSError(domain: ErrorDomain, code: 1002, userInfo: [NSLocalizedDescriptionKey:status])
                done(nil,error)
                return
            }
        }
        
        
        
        done(json as? [String:Any],nil)
        
    }
}


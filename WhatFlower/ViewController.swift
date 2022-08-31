//
//  ViewController.swift
//  WhatFlower
//
//  Created by Huang Yan on 8/27/22.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    let picker = UIImagePickerController()
    let wikipediaURL = "https://en.wikipedia.org/w/api.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = true
    }
//    func updateUI(_ result: WikiDescriptionData) {
//        DispatchQueue.main.async {
//            self.descriptionLabel.text = result.query.pages[result.query.pageids[0]].extract
//        }
//    }
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        present(picker, animated: true)
        
    }
    //format=json&action=query&prop=extracts&exintro=&explaintext=&titles=barberton%20daisy&indexpageids&redirects=1
    func requestDescription(flowerName: String) {
        let parameters: [String:String] = [
            "format":"json",
            "action":"query",
            "prop":"extracts|pageimages",
            "exintro":"",
            "explaintext":"",
            "titles":flowerName,
            "indexpageids":"",
            "redirects":"1",
            "pithumbsize":"500"
        ]
        
        
        Alamofire.request(wikipediaURL, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                let flowerJSON: JSON = JSON(response.result.value)
                let pageID = flowerJSON["query"]["pageids"][0].stringValue
                let info = flowerJSON["query"]["pages"][pageID]["extract"].stringValue
                let flowerImageURL = flowerJSON["query"]["pages"][pageID]["thumbnail"]["source"].stringValue
                self.image.sd_setImage(with: URL(string: flowerImageURL))
                
                self.descriptionLabel.text = "description: \(info)"
            }
        }
    }
    func decodeJson(_ data: Data) -> WikiDescriptionData?{
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(WikiDescriptionData.self, from: data)
        }catch {
            print(error)
        }
        return nil
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            
            
            let ciImage = CIImage(image: selectedImage)
            detect(flowerImage: ciImage!)
        }
        self.picker.dismiss(animated: true)
    }
    func detect(flowerImage image:CIImage) {
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {fatalError()}
        
        let request = VNCoreMLRequest(model: model) { request, error in
            // completion trigger when handler finish recognizing image
            guard let result = request.results?.first as? VNClassificationObservation else {fatalError()}
            
            self.navigationItem.title = result.identifier.capitalized
            self.requestDescription(flowerName: result.identifier)
            
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
}


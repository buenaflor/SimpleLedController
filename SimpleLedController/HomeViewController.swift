//
//  HomeViewController.swift
//  SimpleLedController
//
//  Created by Giancarlo Buenaflor on 10.09.18.
//  Copyright © 2018 Giancarlo Buenaflor. All rights reserved.
//

import UIKit
import Endpoints

class HomeViewController: UIViewController {
    
    private let colorWheelSize: CGFloat = 260
    private lazy var colorWheelX: CGFloat = (view.frame.size.width / 2) - (colorWheelSize / 2)
    private lazy var colorWheelY: CGFloat = (view.frame.size.height * 0.07)
    
    private lazy var colorWheel: ColorWheel = {
        let cv = ColorWheel(frame: CGRect(x: colorWheelX, y: colorWheelY, width: colorWheelSize, height: colorWheelSize), color: .red)
        cv.delegate = self
        return cv
    }()
    
    private lazy var ipAddressTextField: UITextField = {
        let tf = UITextField()
        tf.text = "http://192.168.0.241:3000/api/"
        tf.backgroundColor = .lightGray
        return tf
    }()
    
    private lazy var toggleButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Toggle", for: .normal)
        btn.backgroundColor = .lightGray
        btn.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    var ledOn: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(colorWheel)
        
        view.add(subview: ipAddressTextField) { (v, p) in [
            v.topAnchor.constraint(equalTo: p.safeAreaLayoutGuide.topAnchor),
            v.leadingAnchor.constraint(equalTo: p.leadingAnchor),
            v.trailingAnchor.constraint(equalTo: p.trailingAnchor),
            v.heightAnchor.constraint(equalToConstant: 40)
            ]}
        
        view.add(subview: toggleButton) { (v, p) in [
            v.centerXAnchor.constraint(equalTo: p.centerXAnchor),
            v.centerYAnchor.constraint(equalTo: p.centerYAnchor),
            v.widthAnchor.constraint(equalToConstant: 100),
            v.heightAnchor.constraint(equalToConstant: 40)
            ]}
        
        view.add(subview: slider) { (v, p) in [
            v.centerXAnchor.constraint(equalTo: p.centerXAnchor),
            v.topAnchor.constraint(equalTo: toggleButton.bottomAnchor, constant: 20),
            v.widthAnchor.constraint(equalToConstant: 300)
            ]}
    
        SessionManager.shared.start(call: SimpleLedControllerClient.GetLEDPower(tag: "ledpower")) { (result) in
            result.onSuccess(block: { (response) in
                self.ledOn = response.ledOn
                
                if response.ledOn {
                    self.toggleButton.backgroundColor = .green
                    self.toggleButton.setTitle("LED is on", for: .normal)
                }
                else {
                    self.toggleButton.backgroundColor = .red
                    self.toggleButton.setTitle("LED is off", for: .normal)
                }
            }).onError(block: { (err) in
                self.alert(error: err)
            })
        }
    }
    
    @objc private func toggleButtonTapped() {
        guard let ledOn = ledOn else { return }
        let ledPower = PostLEDPowerResponse(ledOn: !ledOn)
        
        do {
            let data = try JSONEncoder().encode(ledPower)
            let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
            let jsonBody = try JSONEncodedBody(jsonObject: jsonData)
            
            SessionManager.shared.start(call: SimpleLedControllerClient.PostLEDPower(tag: "ledpower", body: jsonBody)) { (result) in
                result.onError(block: { (err) in
                    self.alert(error: err)
                }).onSuccess(block: { (response) in
                    print("Led is: \(response.ledOn)")
                    
                    if response.ledOn {
                        self.toggleButton.backgroundColor = .green
                        self.toggleButton.setTitle("LED is on", for: .normal)
                    }
                    else {
                        self.toggleButton.backgroundColor = .red
                        self.toggleButton.setTitle("LED is off", for: .normal)
                    }
                    
                    SessionManager.shared.start(call: SimpleLedControllerClient.GetLEDPower(tag: "ledpower")) { (result) in
                        result.onSuccess(block: { (response) in
                            self.ledOn = response.ledOn
                        }).onError(block: { (err) in
                            self.alert(error: err)
                        })
                    }
                })
            }
        }
        catch {
            
        }
    }
    
    func sendSingleColorRequest(hexColor: String) {
        
        let singleColor = SingleColor(hexColor: hexColor)
        
        do {
            let data = try JSONEncoder().encode(singleColor)
            let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
            let jsonBody = try JSONEncodedBody(jsonObject: jsonData)
            
            SessionManager.shared.start(call: SimpleLedControllerClient.PostSingleColor(tag: "single_color", body: jsonBody)) { (result) in
                result.onSuccess(block: { (response) in
                    print(response)
                }).onError(block: { (err) in
                    print(err)
                })
            }
        } catch let err {
            print(err)
        }
    }
    
    func getIpAddress() -> URL {
        guard let ipAddressText = ipAddressTextField.text, let ipAddressURL = URL(string: ipAddressText) else { return URL(string: "https://www.google.com")! }
        
        return ipAddressURL
    }

    @objc private func sliderChanged(_ sender: UISlider) {
        print(sender.value)
    }
}

extension HomeViewController: ColorWheelDelegate {
    func hueAndSaturationSelected(_ hue: CGFloat, saturation: CGFloat) {
        guard let color = colorWheel.color else { return }

//        let convertedHue: Double = Double(hue)
//        let convertedSaturation: Double = Double(saturation)
        let hexColor = color.rgbToHex().replacingOccurrences(of: "#", with: "")
        
//        self.sendSingleColorRequest(hexColor: hexColor)
    }
}

extension UIColor {
    var redValue: CGFloat{ return CIColor(color: self).red }
    var greenValue: CGFloat{ return CIColor(color: self).green }
    var blueValue: CGFloat{ return CIColor(color: self).blue }
    var alphaValue: CGFloat{ return CIColor(color: self).alpha }
}

extension UIColor {
    
    func rgbToHex() -> String {
        
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "#%06x", rgb)
    }
}

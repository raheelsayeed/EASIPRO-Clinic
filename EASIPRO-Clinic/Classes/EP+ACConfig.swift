//
//  EP+ACConfig.swift
//  EASIPRO-Clinic
//
//  Created by Raheel Sayeed on 03/05/18.
//  Copyright © 2018 Boston Children's Hospital. All rights reserved.
//

import Foundation
import AssessmentCenter

extension ACForm {
	
	public class func SampleForms() -> [ACForm] {
		
		return [
			ACForm(_oid: "EFB1133D-429E-4C9D-B322-32C614CB3C9D", _title: "PROMIS Sleep", _loinc: nil),
			ACForm(_oid: "FFCDF6E3-8B17-4673-AB38-C677FFF6DBAF", _title: "PROMIS Bank v1.0 - Anxiety", _loinc: "61922-1"),
			ACForm(_oid: "C4ADCFAB-6B75-498E-9E94-AFD3BA211DC4", _title: "PROMIS Bank v1.0 - Pain Behavior", _loinc: "62212-6")
		]
	}
	
}

extension ACClient {
	
	/**
	AssessmentCenter's Credentials taken from Config.xcconfig via App's Info.plist
	*/
	public class func NewClient() -> ACClient {
		
		let infoDict = Bundle.main.infoDictionary!
		let accessID = infoDict["ASSESSMENTCENTER_ACCESSID"] as! String
		let accessToken = infoDict["ASSESSMENTCENTER_ACCESSTOKEN"] as! String
		let baseURI = infoDict["ASSESSMENTCENTER_BASE_URI"] as! String
		return ACClient(baseURL: URL(string: "https://\(baseURI)")!, accessIdentifier: accessID, token: accessToken)
		
	}
	
}

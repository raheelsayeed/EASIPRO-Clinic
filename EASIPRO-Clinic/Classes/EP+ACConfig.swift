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
	
	public class func NewClient() -> ACClient {
		
		let baseURLString = "https://www.assessmentcenter.net/ac_api/2014-01/"
		let accessID = "9E9A29C1-DD01-49F6-8D15-74338F673394"
		let accessToken = "517A4833-D8CD-4B00-94EE-252E8E237A43"
		let client = ACClient(baseURL: URL(string: baseURLString)!, accessIdentifier: accessID, token: accessToken)
		return client
	}
	
}

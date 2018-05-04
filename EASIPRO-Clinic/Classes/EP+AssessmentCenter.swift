//
//  EP+AssessmentCenter.swift
//  EASIPRO-Clinic
//
//  Created by Raheel Sayeed on 5/3/18.
//  Copyright © 2018 Boston Children's Hospital. All rights reserved.
//

import Foundation
import EASIPRO
import AssessmentCenter
import ResearchKit
import SMART

extension AssessmentCenter.ACForm {
	
	func proMeasure() -> PROMeasure2 {
		let title = self.title ?? OID
		let prom = PROMeasure2(title: title, identifier: OID)
		prom.measure = self
		return prom
	}
	
}

class ACMeasureViewController : MeasuresViewController {
	
	open override func loadQuestionnaires() {
		if nil != measures { return }
		markBusy()
		let acclient = ACClient.NewClient()
		acclient.listForms { [unowned self] (acforms) in
			if let acforms = acforms {
				self._measures = acforms.map { $0.proMeasure() }
				DispatchQueue.main.async {
					self.markStandby()
				}
			}
		}
	}
}

extension EASIPRO.SessionController2 {
	
	open func prepareSessionContainer(callback: @escaping ((UIViewController?, Error?) -> Void)) {
		guard let measures = measures else { return }
		
		
		let context = SMARTManager.shared.usageMode
		if context == .Practitioner {
			
			let acclient = ACClient.NewClient()
			let acForms = measures.map({ (prom) -> ACForm in
				return prom.measure as! ACForm
			})
			
			acclient.forms(acforms: acForms, completion: { [weak self] (completedForms) in
				if let completedForms = completedForms {
					let taskViewControllers = completedForms.map({ (form) -> ACTaskViewController in
						let acTVC = ACTaskViewController(acform: form, client: acclient, sessionIdentifier: (self?.patient.humanName!)!)
						acTVC.taskDelegate = self
						return acTVC
					})
					let navigationController = self?.sessionContainerController(for: taskViewControllers)
					callback(navigationController, nil)
				}
				else {
					callback(nil, nil)
				}
			})
		}
	}
}


extension EASIPRO.SessionController2 : ACTaskViewControllerDelegate {
	
	public func assessmentViewController(_ taskViewController: ACTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?, tscore: Double?, stderror: Double?, session: SessionItem) {
		
		let acform = (taskViewController.task as! ACTask).form
		
		if reason == .completed { handleCompletion(for: acform, session: session) }
		
		
	}
	
	public func didDismissACTaskViewController() {
		
	}
	
	func handleCompletion(for form: ACForm, session: SessionItem) {
		var qr = form.as_FHIRQuestionnaireResponse(with: session.score)!
		qr["subject"] = ["reference": "Patient/\(patient.id!.string)"]
		qr["authored"] = "2018-01-17" // todo: change to today
		do {
			let qResponse = try QuestionnaireResponse(json: qr)
			let srv = SMARTManager.shared.client.server
			qResponse.createAndReturn(srv, callback: { [weak self] (ferror) in
				let qResponseId = qResponse.id!.string
				var observation = form.as_FHIRObservation(with: session.score!, related: qResponseId, subject: self?.patient.id!.string)
				do {
					let observationFHIR = try Observation(json: observation!)
					observationFHIR.createAndReturn(SMARTManager.shared.client.server, callback: { (error) in
						print("Observation:", observationFHIR.id?.string)
						if let onMeasureCompletion = self?.onMeasureCompletion {
							DispatchQueue.main.async {
								onMeasureCompletion(form, nil)
							}
						}
					})
				}
				catch {
					print(error)
				}
			})

			
		}
		catch { //do
			print(error.localizedDescription)
		}
		


		
	}
		
}

//
//  PreviewEndEnforcer.swift
//  AppCMS_tvOS
//
//  Created by Anirudh Vyas on 03/12/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

let kPreviewEndEnforcerTimeUp = Notification.Name("PreviewEndEnforcerTimeUp")

import Foundation

class PreviewEndEnforcer: NSObject {
    
    /// Timer for tracking the app watch duration.
    private weak var trackingTimer: Timer?
    
    /// Gets the total allowed application preview time.
    private var totalAppAllowedTime: Double {
        get {
            let videoPreviewAvailable = AppConfiguration.sharedAppConfiguration.isVideoPreviewAvailable ?? false
            if videoPreviewAvailable {
                if let applicationPreviewDuration = AppConfiguration.sharedAppConfiguration.videoPreviewDuration {
                    if applicationPreviewDuration.isEmpty == false {
                        return Double(applicationPreviewDuration)! * 60
                    } else {
                        return 0
                    }
                } else {
                    return 0
                }
            } else {
                return 0
            }
        }
    }
    
    private var isPaused = true
    
    /// Holds the app usage time.
    private var appUsageTime: Double = 0.0
    
    override init() {
        super.init()
        self.appUsageTime = getTheTotalAppUsageTime()
    }
    
    /// The master preview allow metric.
    var isPreviewAllowed: Bool {
        get {
            if appUsageTime >= totalAppAllowedTime {
                return false
            } else {
                return true
            }
        }
    }
    
    /// Gets the total app usage time.
    ///
    /// - Returns: total app usage time.
    private func getTheTotalAppUsageTime() -> Double {
        var totalAppUsageTime = 0.0
        if let totalTime = Constants.kSTANDARDUSERDEFAULTS.value(forKey: "AppRunTime") as? Double {
            totalAppUsageTime += totalTime
        } else {
            saveUsageTime(usageTime: 0.0)
        }
        return totalAppUsageTime
    }
    
    /// Call this to start the time tracking.
    func startAppOnTimeTracking() {
        let isSubscribed = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool ?? false)
        if isSubscribed == false {
            if appUsageTime < totalAppAllowedTime {
                if isPaused == true {
                    trackingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector (self.incrementTimer), userInfo: nil, repeats: true)
                    RunLoop.current.add(trackingTimer!, forMode: RunLoopMode.commonModes)
                    isPaused = false
                }
            }
        }
    }
    
    func pauseAppOnTimeTracking() {
        if let timer = trackingTimer {
            timer.invalidate()
        }
        isPaused = true
    }
    
    @objc private func incrementTimer() {
        let isSubscribed = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool ?? false)
        if isSubscribed == false {
            appUsageTime += 1.0
            print("UsageTime >>>> \(appUsageTime)")
            if appUsageTime >= totalAppAllowedTime {
                pauseAppOnTimeTracking()
                Constants.kNOTIFICATIONCENTER.post(name: kPreviewEndEnforcerTimeUp, object: nil)
            }
            saveUsageTime(usageTime: appUsageTime)
        }
    }
    
    /// Call this save the app usage time.
    func saveUsageTime() {
        saveUsageTime(usageTime: appUsageTime)
    }
    
    /// Call this save the app usage time. Overloaded method, as the appUsageTime is only available to this class.
    private func saveUsageTime(usageTime: Double) {
        Constants.kSTANDARDUSERDEFAULTS.set(usageTime, forKey: "AppRunTime")
        Constants.kSTANDARDUSERDEFAULTS.synchronize()
    }
    
}

//
//  GetICloudUser.swift
//  Wasatch Transportation
//
//  Created by Parker Rushton on 10/18/16.
//  Copyright © 2016 PJR. All rights reserved.
//

import Foundation
import CloudKit

struct GetICloudUser: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        let container = CKContainer.default()
        container.fetchUserRecordID { recordID, error in
            if let error = error {
                core.fire(event: ErrorEvent(error: error, message: nil))
                core.fire(event: ICloudUserIdentified(icloudId: nil))
            } else {
                core.fire(event: ICloudUserIdentified(icloudId: recordID?.recordName))
            }
        }
    }
    
}

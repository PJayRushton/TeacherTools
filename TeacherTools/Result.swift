//
//  Result.swift
//  NetworkStack
//
//  Created by Jason Larsen on 2/23/16.
//  Copyright © 2016 OC Tanner. All rights reserved.
//

import Foundation

typealias ResultCompletion = (Result<JSONObject>) -> Void

public enum Result<T> {
    case success(T)
    case failure(Error)
    
    public func map<U>(_ f: (T) throws -> U) -> Result<U> {
        switch self {
        case let .success(x):
            do {
                return try .success(f(x))
            }
            catch {
                return .failure(error)
            }
        case let .failure(error):
            return .failure(error)
        }
    }
    
    public func flatMap<U>(_ f: (T) -> Result<U>) -> Result<U> {
        switch self {
        case let .success(x):
            return f(x)
        case let .failure(error):
            return .failure(error)
        }
    }
    
    /// Returns `true` if the result is a success, `false` otherwise.
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    /// Returns `true` if the result is a failure, `false` otherwise.
    public var isFailure: Bool {
        return !isSuccess
    }
    
}

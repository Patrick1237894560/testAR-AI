//
//  APIKey.swift
//  GeminiAPI
//
//  Created by 陳昱安 on 2025/3/13.
//

import Foundation
enum APIKey {
  // Fetch the API key from `GenerativeAI-Info.plist`
  static var `default`: String {
 
    guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist")
    else {
      fatalError("Couldn't find file 'GeminiAPI-Info.plist'.")
    }
 
    let plist = NSDictionary(contentsOfFile: filePath)
 
    guard let value = plist?.object(forKey: "API_KEY") as? String else {
      fatalError("Couldn't find key 'API_KEY' in 'GenerativeAI-Info.plist'.")
    }
 
    if value.starts(with: "_") {
      fatalError(
        "Follow the instructions at https://ai.google.dev/tutorials/setup to get an API key."
      )
    }
 
    return value
  }
}

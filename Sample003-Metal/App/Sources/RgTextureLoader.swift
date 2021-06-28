//
//  RgTextureLoader.swift
//  App
//
//  Created by ragingo on 2021/06/27.
//

import Foundation
import Metal

struct RgTextureLoader {
    static func load(request: URLRequest, device: MTLDevice, completion: @escaping (RgTexture?) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(nil)
                return
            }
            guard
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 else {
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            let texture = RgTexture(device: device, data: data)
            completion(texture)
        }
        task.resume()
    }
}

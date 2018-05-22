import Flutter
import UIKit

import AGSCore

enum HttpMethod: String {
    case GET, POST, PUT
}

public class SwiftAerogearCoreSdkPlugin: NSObject, FlutterPlugin {
    var currentConfig: MobileService?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "aerogear_core_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftAerogearCoreSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "getPlatformVersion":
            result("iOS => " + UIDevice.current.systemVersion)
        case "getConfiguration":
            handleGetConfigurationCall(call: call, result: result)
        case "cloud":
            handleCloudCall(call: call, result: result)
        case "publishMetric":
            result(FlutterMethodNotImplemented) //AgsMetrics.publish("test", [Metrics], )
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleGetConfigurationCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let serviceType = call.arguments as? String else {
            result(FlutterError(code: "CLOUD_ERROR", message: "serviceType should be a String", details: nil))
            return
        }
        
        AgsCore.logger.info("Loading configuration")
        if let configuration = AgsCore.instance.getConfiguration(serviceType) {
            let _configuration = ["id": configuration.id, "name": configuration.name, "type": configuration.type, "url": configuration.url] as [String: AnyObject]
            //_configuration["id"] = configuration.id
            //result(["id": configuration.id, "name": configuration.name, "type": configuration.type, "url": configuration.url])
            result(_configuration)
            return
        }
        result(nil)
    }
    
    private func cloudMethod(_ path: String, method: HttpMethod, data: [String: AnyObject]?, headers: [String: String]?, _ handler: @escaping (AgsHttpResponse) -> Void) {
        
        //var function: (String, [String: AnyObject]?, [String: String]?, @escaping (AgsHttpResponse) -> Void) -> Void
        switch (method) {
        case HttpMethod.GET:
            AgsCore.instance.getHttp().get(path, params: data, headers: headers, handler)
        case HttpMethod.POST:
            AgsCore.instance.getHttp().post(path, body: data, headers: headers, handler)
        case HttpMethod.PUT:
            AgsCore.instance.getHttp().put(path, body: data, headers: headers, handler)
        }
    }
    
    private func handleCloudCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        assert(call != nil && result != nil)
        
        guard let arguments = call.arguments as? [String: AnyObject] else {
            result(FlutterError(code: "CLOUD_ERROR", message: "Arguments should be a Map<String, dynamic>", details: nil))
            return
        }
        
        guard let path = arguments["path"] as? String else {
            result(FlutterError(code: "CLOUD_ERROR", message: "Arguments Map<String, dynamic> should contain path at least", details: nil))
            return
        }
        
        var method = HttpMethod.GET
        if let _method = HttpMethod(rawValue: (arguments["method"] as? String)!) {
            method = _method
        } else {
            result(FlutterError(code: "CLOUD_ERROR", message: "method allowed values are: GET, POST, PUT", details: nil))
            return
        }
        
        var contentType = "application/json"
        if let _contentType = arguments["contentType"] as? String {
            contentType = _contentType
        }
        
        var timeout = 25000
        if let _timeout = arguments["timeout"] as? Int {
            timeout = _timeout
        }

        let data = arguments["data"] as? [String: AnyObject]
        
        let headers = arguments["headers"] as? [String: String]
        
        cloudMethod(path, method: method, data: data, headers: headers, { (response) -> Void in
            if let error = response.error {
                let errorMessage = "Error: \(error)";
                AgsCore.logger.error(errorMessage)
                result(FlutterError(code: "CLOUD_ERROR", message: errorMessage, details: ["statusCode": response.statusCode, "response": response.response]))
                return
            }
            
            if let _response = response.response as? [String: Any] {
                //result(_response.description)
                //result(_response)
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: _response, options: .prettyPrinted)
                    //result("[{\"abc\" : \"123\"}]")
                    let kk = String(data: jsonData, encoding: .utf8)
                    result(kk)
                } catch {
                    let errorMessage = "Error: \(error)";
                    AgsCore.logger.error(errorMessage)
                    result(FlutterError(code: "CLOUD_ERROR", message: errorMessage, details: ["statusCode": response.statusCode, "response": response.response]))
                }
                
            } else if let _response = response.response as? [AnyObject] {
                //result(_response.description)
                //result(_response)
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: _response, options: .prettyPrinted)
                    //result("[{\"abc\" : \"123\"}]")
                    let kk = String(data: jsonData, encoding: .utf8)
                    result(kk)
                } catch {
                    let errorMessage = "Error: \(error)";
                    AgsCore.logger.error(errorMessage)
                    result(FlutterError(code: "CLOUD_ERROR", message: errorMessage, details: ["statusCode": response.statusCode, "response": response.response]))
                }
                
            }
        })
    }
}

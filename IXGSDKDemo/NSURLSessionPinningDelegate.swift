
import Foundation

// https://forums.developer.apple.com/forums/thread/707602
class NSURLSessionPinningDelegate: NSObject, URLSessionDelegate {


    func urlSession(_ session: URLSession,
                      didReceive challenge: URLAuthenticationChallenge,
                      completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        print("challenge received: \(challenge)")
        let authMethod = challenge.protectionSpace.authenticationMethod

        switch authMethod {
        case NSURLAuthenticationMethodHTTPBasic:
            assertionFailure("Server challenge is expected name/password credentials")
            completionHandler(.performDefaultHandling, nil)
            return
        case NSURLAuthenticationMethodServerTrust:
            if let serverTrust = challenge.protectionSpace.serverTrust {
                Task {
                    let result = await shouldAllowHTTPSConnection(trust: serverTrust)
                    if result == true {
                        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
                    } else {
                        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
                    }
                }
            }
        default:
            assertionFailure("Unhandled server challenge: \(authMethod)")
        }
    }

    func shouldAllowHTTPSConnection(certificates: [SecCertificate]) async throws -> Bool {
        let secCertificate = Bundle.main.certificateNamed("serverCert")!
        let secPolicy = SecPolicyCreateBasicX509()
        let secTrust = try secCall { SecTrustCreateWithCertificates(certificates as NSArray, secPolicy, $0) }
        let osStatus = SecTrustSetAnchorCertificates(secTrust, [secCertificate] as NSArray)
        guard osStatus == errSecSuccess else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(osStatus))}
        return SecTrustEvaluateWithError(secTrust, nil)
    }

    func shouldAllowHTTPSConnection(trust: SecTrust) async -> Bool {
        guard let secCertificates = SecTrustCopyCertificateChain(trust) as? [SecCertificate] else { return false }
        do {
            return try await shouldAllowHTTPSConnection(certificates: secCertificates)
        } catch {
            return false
        }
    }

    // https://developer.apple.com/documentation/xcode/signing-a-daemon-with-a-restricted-entitlement
    func secCall<Result>(_ body: (_ resultPtr: UnsafeMutablePointer<Result?>) -> OSStatus) throws -> Result {
        var result: Result? = nil
        let err = body(&result)
        guard err == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(err), userInfo: nil)
        }
        return result!
    }
}

extension Bundle {
    func certificateNamed(_ name: String) -> SecCertificate? {
        guard let certURL = self.url(forResource: name, withExtension: "pem"),
              let certData = try? Data(contentsOf: certURL),
              let cert = SecCertificateCreateWithData(nil, certData as NSData)
        else {
            return nil
        }
        return cert
    }
}

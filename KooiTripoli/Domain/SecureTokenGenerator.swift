import Foundation
import SwiftUI

// MARK: - Secure Token Generator

/// Generates secure opaque tokens, deep links, QR payloads, and 21×21 QR visual matrices
/// Ported from Kotlin `SecureTokenGenerator`
public final class SecureTokenGenerator {

    private static let random = SystemRandomNumberGenerator()
    private static let alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789"

    /// Generates an opaque token with prefix (e.g., "grp_xxx", "req_xxx")
    public static func generateOpaqueToken(prefix: String, length: Int = 22) -> String {
        var sb = prefix + "_"
        for _ in 0..<length {
            let idx = Int.random(in: 0..<alphabet.count, using: &random)
            let char = alphabet[alphabet.index(alphabet.startIndex, offsetBy: idx)]
            sb.append(char)
        }
        return sb
    }

    /// Creates a group invitation with token, deep link, QR payload, and expiry
    public static func createGroupInvitation(
        groupId: String,
        nowEpochMs: Int64,
        ttlMinutes: Int
    ) -> GroupInvitation {
        let token = generateOpaqueToken(prefix: "grp")
        let deepLink = "https://kooi.ly/group/\(token)"
        return GroupInvitation(
            groupId: groupId,
            token: token,
            deepLink: deepLink,
            qrPayload: "KOOI:GROUP:\(token)",
            expiresAtEpochMs: nowEpochMs + Int64(ttlMinutes) * 60_000,
            isRevoked: false
        )
    }

    /// Creates a money request token with shareable link and QR payload
    public static func createMoneyRequestToken(
        requestId: String,
        nowEpochMs: Int64,
        ttlMinutes: Int = 120
    ) -> PaymentRequestToken {
        let token = generateOpaqueToken(prefix: "req")
        let shareableLink = "https://kooi.ly/wallet/request/\(token)"
        return PaymentRequestToken(
            token: token,
            requestId: requestId,
            shareableLink: shareableLink,
            qrPayload: "KOOI:WALLET_REQ:\(token)",
            expiresAtEpochMs: nowEpochMs + Int64(ttlMinutes) * 60_000,
            isRevoked: false
        )
    }

    // MARK: - QR Matrix Generation (21×21)

    /// Generates a deterministic 21×21 QR-like visual module matrix with standard 7×7 finder
    /// patterns at top-left, top-right, and bottom-left plus payload-derived data cells.
    /// Returns `[[Bool]]` where `true` = dark module, `false` = light module.
    public static func buildQrMatrix(payload: String, gridSize: Int = 21) -> [[Bool]] {
        var matrix = Array(repeating: Array(repeating: false, count: gridSize), count: gridSize)

        // Stamp 7×7 finder patterns (outer + inner 3×3)
        func stampFinder(startR: Int, startC: Int) {
            for r in 0..<7 {
                for c in 0..<7 {
                    let isOuter = r == 0 || r == 6 || c == 0 || c == 6
                    let isInner = (2...4).contains(r) && (2...4).contains(c)
                    matrix[startR + r][startC + c] = isOuter || isInner
                }
            }
        }

        // Three finder positions
        stampFinder(startR: 0, startC: 0)
        stampFinder(startR: 0, startC: gridSize - 7)
        stampFinder(startR: gridSize - 7, startC: 0)

        // Payload hash for deterministic data cells
        var hash: Int64 = 1_125_899_906_842_597 // Large prime seed
        for ch in payload.unicodeScalars {
            hash = 31 &* hash &+ Int64(ch.value)
        }

        var bitIdx = 0
        for r in 0..<gridSize {
            for c in 0..<gridSize {
                // Skip finder pattern areas (8×8 at each corner)
                let inTopLeft = r < 8 && c < 8
                let inTopRight = r < 8 && c >= gridSize - 8
                let inBottomLeft = r >= gridSize - 8 && c < 8
                if !inTopLeft && !inTopRight && !inBottomLeft {
                    let mixed = hash ^ (Int64(r) * 37 &+ Int64(c) * 91 &+ Int64(bitIdx) * 17) << (bitIdx % 13)
                    matrix[r][c] = (mixed & 1) == 1
                    bitIdx += 1
                }
            }
        }
        return matrix
    }
}

/// Swift-compatible random number generator
private struct SystemRandomNumberGenerator: RandomNumberGenerator {
    mutating func next() -> UInt64 {
        var value: UInt64 = 0
        _ = SecRandomCopyBytes(kSecRandomDefault, MemoryLayout<UInt64>.size, &value)
        return value
    }
}

import Security
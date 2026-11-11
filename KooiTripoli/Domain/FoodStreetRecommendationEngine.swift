import Foundation

// MARK: - Food Street Recommendation Engine

/// Recommends food streets based on user's micro-zone, order volume, and restaurant availability
/// Ported from Kotlin `FoodStreetRecommendationEngine`
public struct FoodStreetRecommendationEngine {

    public static let defaultMaxRecommendedStreets = 3

    public static func recommendForMicroZone(
        allStreets: [FoodStreet],
        allRestaurants: [Restaurant],
        userMicroZoneId: String,
        maxRecommended: Int = defaultMaxRecommendedStreets
    ) -> StreetRecommendationResult {

        // Filter streets that have at least one available restaurant
        let eligibleStreets = allStreets.filter { street in
            street.restaurantIds.contains { id in
                allRestaurants.first { $0.id == id }?.isAvailableForOrdering == true
            }
        }

        // Zone-matched streets with verified order volume
        let zoneMatchedWithVolume = eligibleStreets.filter {
            $0.microZoneId == userMicroZoneId && ($0.recentAreaOrderVolume ?? 0) > 0
        }

        let usedFallback = zoneMatchedWithVolume.isEmpty

        let sortedPool: [FoodStreet]
        if !usedFallback {
            // Rank zone-local streets first by verified order volume, then nearby eligible streets
            let localRanked = zoneMatchedWithVolume.sorted { ($0.recentAreaOrderVolume ?? 0) > ($1.recentAreaOrderVolume ?? 0) }

            let localSet = Set(localRanked.map { $0.id })
            let neighborRanked = eligibleStreets
                .filter { !localSet.contains($0.id) }
                .sorted { lhs, rhs in
                    let lhsCount = streetAvailableRestaurantCount(lhs, allRestaurants)
                    let rhsCount = streetAvailableRestaurantCount(rhs, allRestaurants)
                    if lhsCount != rhsCount { return lhsCount > rhsCount }
                    return (lhs.recentAreaOrderVolume ?? 0) > (rhs.recentAreaOrderVolume ?? 0)
                }

            sortedPool = localRanked + neighborRanked
        } else {
            // Explicit fallback: rank by active available kitchens & fastest ETA without inventing volume
            sortedPool = eligibleStreets.sorted { lhs, rhs in
                let lhsCount = streetAvailableRestaurantCount(lhs, allRestaurants)
                let rhsCount = streetAvailableRestaurantCount(rhs, allRestaurants)
                if lhsCount != rhsCount { return lhsCount > rhsCount }
                return lhs.avgEtaMinutes < rhs.avgEtaMinutes
            }
        }

        let recommended = Array(sortedPool.prefix(maxRecommended.coerceAtLeast(1)))
        let recommendedIds = Set(recommended.map { $0.id })
        let remaining = allStreets.filter { !recommendedIds.contains($0.id) }

        let reasonAr = usedFallback
            ? "توصيات احتياطية حسب المطاعم المتاحة حالياً لعدم توفر بيانات طلبات محلية كافية لمنطقتك"
            : "مرتّبة حسب حجم الطلبات الفعلي وتوفر المطاعم في نطاق منطقتك"

        let reasonEn = usedFallback
            ? "Fallback recommendations by active kitchen availability (local micro-zone volume unavailable)"
            : "Selected by micro-zone order volume and active restaurant availability"

        return StreetRecommendationResult(
            recommendedStreets: recommended,
            otherStreets: remaining,
            usedFallbackRecommendations: usedFallback,
            reasonAr: reasonAr,
            reasonEn: reasonEn
        )
    }

    private static func streetAvailableRestaurantCount(
        _ street: FoodStreet,
        _ allRestaurants: [Restaurant]
    ) -> Int {
        street.restaurantIds.filter { id in
            allRestaurants.first { $0.id == id }?.isAvailableForOrdering == true
        }.count
    }
}

// Extension for Int.coerceAtLeast (Kotlin compatibility)
extension Int {
    func coerceAtLeast(_ minimum: Int) -> Int {
        self < minimum ? minimum : self
    }
}
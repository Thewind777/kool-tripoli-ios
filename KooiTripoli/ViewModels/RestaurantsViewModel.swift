import Foundation
import Combine
import SwiftUI

/// ViewModel for restaurant discovery with progressive pagination
/// Mirrors the Kotlin `KooiViewModel` restaurant loading logic
@MainActor
public final class RestaurantsViewModel: ObservableObject {
    // MARK: - Published State

    @Published public var restaurants: [Restaurant] = []
    @Published public var liveCuisines: [ApiCuisine] = []
    @Published public var isLoadingRestaurants: Bool = false
    @Published public var isLoadingMoreRestaurants: Bool = false
    @Published public var restaurantErrorAr: String?
    @Published public var restaurantErrorEn: String?
    @Published public var currentRestaurantPage: Int = 0
    @Published public var hasMoreRestaurantPages: Bool = true
    @Published public var totalStoreCount: Int = 0

    // Search & Filter
    @Published public var searchQuery: String = ""
    @Published public var activeCollectionFilter: RestaurantCollectionFilter = .all
    @Published public var activeCategoryFilter: FoodCategory = .all
    @Published public var navigatedFromHomeSeeAll: Bool = false

    // Dependencies
    private let apiClient = APIClient.shared
    private let cartStore = LocalCartStore.shared
    private var backgroundLoadTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    // Constants
    private let tripoliLat = "32.8872"
    private let tripoliLon = "13.1913"

    public init() {
        // Load cached data first
        restaurants = cartStore.getCachedRestaurants()
        liveCuisines = [] // Will be loaded from API

        // Start fresh load
        refreshRestaurants()
    }

    deinit {
        backgroundLoadTask?.cancel()
    }

    // MARK: - Public Methods

    /// Pulls the FIRST PAGE of the Tripoli store list from the backend
    public func refreshRestaurants() {
        isLoadingRestaurants = true
        restaurantErrorAr = nil
        restaurantErrorEn = nil
        currentRestaurantPage = 0
        hasMoreRestaurantPages = true
        totalStoreCount = 0

        Task {
            do {
                let json = try await apiClient.loadAvailableRestaurants(
                    latitude: tripoliLat,
                    longitude: tripoliLon,
                    userId: apiClient.userId.isEmpty ? nil : apiClient.userId,
                    cuisineId: nil,
                    categoryId: nil,
                    address: nil,
                    lang: "ar",
                    userType: "Passenger",
                    page: 0
                )

                let (restaurantsData, cuisinesData, totalStores, nextPage) = apiClient.parseRestaurantFeed(from: json)

                // Convert to models
                let newRestaurants = restaurantsData.compactMap { Restaurant.from(json: $0) }
                let newCuisines = cuisinesData.compactMap { ApiCuisine.from(json: $0) }

                await MainActor.run {
                    self.restaurants = newRestaurants
                    self.liveCuisines = newCuisines
                    self.isLoadingRestaurants = false
                    self.currentRestaurantPage = 0
                    self.hasMoreRestaurantPages = nextPage != nil
                    self.totalStoreCount = totalStores
                    self.restaurantErrorAr = nil
                    self.restaurantErrorEn = nil
                }

                // Cache for offline
                cartStore.cacheRestaurants(newRestaurants)

                // Trigger background loading of remaining pages
                if nextPage != nil {
                    loadRemainingPagesInBackground(startPage: nextPage!, initialRestaurants: newRestaurants, initialCuisines: newCuisines, totalStores: totalStores)
                }
            } catch let error as KooiAPIError {
                await MainActor.run {
                    self.isLoadingRestaurants = false
                    self.restaurantErrorAr = "تعذّر تحميل المطاعم من الخادم"
                    self.restaurantErrorEn = error.messageEn
                    self.hasMoreRestaurantPages = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingRestaurants = false
                    self.restaurantErrorAr = "تعذّر تحميل المطاعم من الخادم"
                    self.restaurantErrorEn = error.localizedDescription
                    self.hasMoreRestaurantPages = false
                }
            }
        }
    }

    /// Loads the next page of restaurants for infinite scroll
    public func loadMoreRestaurants() {
        guard !isLoadingMoreRestaurants, hasMoreRestaurantPages else { return }

        isLoadingMoreRestaurants = true
        let nextPage = currentRestaurantPage + 1

        Task {
            do {
                let json = try await apiClient.loadAvailableRestaurants(
                    latitude: tripoliLat,
                    longitude: tripoliLon,
                    userId: apiClient.userId.isEmpty ? nil : apiClient.userId,
                    cuisineId: nil,
                    categoryId: nil,
                    address: nil,
                    lang: "ar",
                    userType: "Passenger",
                    page: nextPage
                )

                let (restaurantsData, _, totalStores, nextPage) = apiClient.parseRestaurantFeed(from: json)
                let newRestaurants = restaurantsData.compactMap { Restaurant.from(json: $0) }

                await MainActor.run {
                    self.restaurants.append(contentsOf: newRestaurants)
                    self.isLoadingMoreRestaurants = false
                    self.currentRestaurantPage = nextPage ?? self.currentRestaurantPage
                    self.hasMoreRestaurantPages = nextPage != nil
                    self.totalStoreCount = totalStores
                }
            } catch let error as KooiAPIError {
                await MainActor.run {
                    self.isLoadingMoreRestaurants = false
                    self.restaurantErrorAr = "تعذّر تحميل المزيد من المطاعم"
                    self.restaurantErrorEn = error.messageEn
                }
            } catch {
                await MainActor.run {
                    self.isLoadingMoreRestaurants = false
                    self.restaurantErrorAr = "تعذّر تحميل المزيد من المطاعم"
                    self.restaurantErrorEn = error.localizedDescription
                }
            }
        }
    }

    /// Pull-to-refresh handler
    public func onPullToRefresh() {
        refreshRestaurants()
    }

    /// Loads remaining pages in background for full dataset availability (search/filter)
    private func loadRemainingPagesInBackground(
        startPage: Int,
        initialRestaurants: [Restaurant],
        initialCuisines: [ApiCuisine],
        totalStores: Int
    ) {
        backgroundLoadTask?.cancel()
        backgroundLoadTask = Task {
            var allStores = initialRestaurants
            var currentPage = startPage
            var hasMore = true

            while hasMore && !Task.isCancelled {
                do {
                    let json = try await apiClient.loadAvailableRestaurants(
                        latitude: tripoliLat,
                        longitude: tripoliLon,
                        userId: apiClient.userId.isEmpty ? nil : apiClient.userId,
                        cuisineId: nil,
                        categoryId: nil,
                        address: nil,
                        lang: "ar",
                        userType: "Passenger",
                        page: currentPage
                    )

                    let (restaurantsData, _, _, nextPage) = apiClient.parseRestaurantFeed(from: json)
                    let newRestaurants = restaurantsData.compactMap { Restaurant.from(json: $0) }

                    allStores.append(contentsOf: newRestaurants)
                    currentPage = nextPage ?? -1
                    hasMore = nextPage != nil

                    // Small delay to avoid hammering the server
                    try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                } catch {
                    print("Background load stopped at page \(currentPage): \(error)")
                    hasMore = false
                }
            }

            // Update with complete dataset for search/filter
            if allStores.count > initialRestaurants.count && !Task.isCancelled {
                await MainActor.run {
                    self.restaurants = allStores
                    self.currentRestaurantPage = currentPage
                    self.hasMoreRestaurantPages = hasMore
                    self.totalStoreCount = totalStores
                }
                cartStore.cacheRestaurants(allStores)
            }
        }
    }

    // MARK: - Filtering

    public func filteredRestaurants() -> [Restaurant] {
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return restaurants.filter { restaurant in
            // Collection filter
            let matchesCollection: Bool
            switch activeCollectionFilter {
            case .all: matchesCollection = true
            case .offers: matchesCollection = restaurant.hasOffer
            case .recommended: matchesCollection = restaurant.isRecommended
            case .popular: matchesCollection = restaurant.isPopular
            case .new: matchesCollection = restaurant.isNew
            case .nearby: matchesCollection = restaurant.isNearby
            }

            // Category filter
            let matchesCategory = activeCategoryFilter == .all || restaurant.category == activeCategoryFilter

            // Search query
            let matchesQuery = q.isEmpty ||
                restaurant.nameAr.lowercased().contains(q) ||
                restaurant.nameEn.lowercased().contains(q) ||
                restaurant.cuisineAr.lowercased().contains(q) ||
                restaurant.cuisineEn.lowercased().contains(q) ||
                restaurant.districtAr.lowercased().contains(q) ||
                restaurant.districtEn.lowercased().contains(q) ||
                restaurant.menu.contains { item in
                    item.nameAr.lowercased().contains(q) || item.nameEn.lowercased().contains(q)
                }

            return matchesCollection && matchesCategory && matchesQuery
        }
    }

    // MARK: - Navigation

    public func selectCollectionFilter(_ filter: RestaurantCollectionFilter) {
        activeCollectionFilter = filter
    }

    public func selectCategoryFilter(_ category: FoodCategory) {
        activeCategoryFilter = category
    }

    public func clearAllFilters() {
        activeCollectionFilter = .all
        activeCategoryFilter = .all
        searchQuery = ""
    }

    public func updateSearchQuery(_ query: String) {
        searchQuery = query
    }
}
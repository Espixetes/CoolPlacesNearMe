import Foundation

struct Place: Codable {
    struct Geometry: Codable {
        struct Location: Codable {
            let lat: Double
            let lng: Double
        }
        let location: Location
    }
    let geometry: Geometry
    let name: String
}

struct PlacesData: Codable {
    let candidates: [Place]
}

class CoolPlacesNearMe {
    let referenceLat: Double = 48.471207
    let referenceLng: Double = 35.038810
    let earthRadius: Double = 6371.0
    
    func haversineDistance(lat1: Double, lng1: Double, lat2: Double, lng2: Double) -> Double {
        let lat1Rad = lat1 * .pi / 180.0
        let lng1Rad = lng1 * .pi / 180.0
        let lat2Rad = lat2 * .pi / 180.0
        let lng2Rad = lng2 * .pi / 180.0
        
        let deltaLat = lat2Rad - lat1Rad
        let deltaLng = lng2Rad - lng1Rad
        
        let a = sin(deltaLat / 2) * sin(deltaLat / 2) +
                cos(lat1Rad) * cos(lat2Rad) * sin(deltaLng / 2) * sin(deltaLng / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        return earthRadius * c
    }
    
    func findPlaces(radius: Double) throws {
        guard let url = Bundle.main.url(forResource: "data", withExtension: "json") else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not find data.json in bundle"])
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let placesData = try decoder.decode(PlacesData.self, from: data)
        
        var results: [(name: String, distance: Double)] = []
        for place in placesData.candidates {
            let distance = haversineDistance(
                lat1: referenceLat,
                lng1: referenceLng,
                lat2: place.geometry.location.lat,
                lng2: place.geometry.location.lng
            )
            if distance <= radius {
                results.append((name: place.name, distance: distance))
            }
        }
        
        results.sort { $0.distance < $1.distance }
        
        if results.isEmpty {
            print("No places found within \(radius) km.")
        } else {
            print("Places within \(radius) km from Apriorit office:")
            for result in results {
                print("\(result.name): \(String(format: "%.2f", result.distance)) km")
            }
        }
    }
}

do {
    let coolPlaces = CoolPlacesNearMe()
    try coolPlaces.findPlaces(radius: 5.0)
} catch {
    print("Error: \(error)")
}

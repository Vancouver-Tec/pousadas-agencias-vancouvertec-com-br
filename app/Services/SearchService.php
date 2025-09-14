<?php

namespace App\Services;

use App\Models\Property;
use Illuminate\Database\Eloquent\Builder;
use Carbon\Carbon;

class SearchService
{
    public function search(array $filters)
    {
        $query = Property::with(['photos', 'reviews', 'city', 'state'])
                          ->where('active', true);

        // Filtro por destino (cidade ou estado)
        if (!empty($filters['destination'])) {
            $destination = $filters['destination'];
            $query->where(function($q) use ($destination) {
                $q->whereHas('city', function($cityQuery) use ($destination) {
                    $cityQuery->where('name', 'LIKE', "%{$destination}%");
                })->orWhereHas('state', function($stateQuery) use ($destination) {
                    $stateQuery->where('name', 'LIKE', "%{$destination}%");
                })->orWhere('name', 'LIKE', "%{$destination}%")
                  ->orWhere('address', 'LIKE', "%{$destination}%");
            });
        }

        // Filtro por tipo de propriedade
        if (!empty($filters['property_type'])) {
            $query->where('property_type', $filters['property_type']);
        }

        // Filtro por preço
        if (!empty($filters['min_price'])) {
            $query->where('price_per_night', '>=', $filters['min_price']);
        }
        if (!empty($filters['max_price'])) {
            $query->where('price_per_night', '<=', $filters['max_price']);
        }

        // Filtro por avaliação
        if (!empty($filters['min_rating'])) {
            $query->where('average_rating', '>=', $filters['min_rating']);
        }

        // Filtro por comodidades
        if (!empty($filters['amenities'])) {
            $amenities = is_array($filters['amenities']) ? $filters['amenities'] : explode(',', $filters['amenities']);
            foreach ($amenities as $amenity) {
                $query->where('amenities', 'LIKE', "%{$amenity}%");
            }
        }

        // Filtro por capacidade (hóspedes)
        if (!empty($filters['guests'])) {
            $query->where('max_guests', '>=', $filters['guests']);
        }

        // Verificar disponibilidade (datas)
        if (!empty($filters['check_in']) && !empty($filters['check_out'])) {
            $checkIn = Carbon::parse($filters['check_in']);
            $checkOut = Carbon::parse($filters['check_out']);
            
            $query->whereDoesntHave('bookings', function($bookingQuery) use ($checkIn, $checkOut) {
                $bookingQuery->where('status', '!=', 'cancelled')
                            ->where(function($dateQuery) use ($checkIn, $checkOut) {
                                $dateQuery->whereBetween('check_in_date', [$checkIn, $checkOut])
                                         ->orWhereBetween('check_out_date', [$checkIn, $checkOut])
                                         ->orWhere(function($overlapQuery) use ($checkIn, $checkOut) {
                                             $overlapQuery->where('check_in_date', '<=', $checkIn)
                                                         ->where('check_out_date', '>=', $checkOut);
                                         });
                            });
            });
        }

        // Ordenação
        $sortBy = $filters['sort'] ?? 'relevance';
        switch ($sortBy) {
            case 'price_low':
                $query->orderBy('price_per_night', 'asc');
                break;
            case 'price_high':
                $query->orderBy('price_per_night', 'desc');
                break;
            case 'rating':
                $query->orderBy('average_rating', 'desc');
                break;
            case 'newest':
                $query->orderBy('created_at', 'desc');
                break;
            default:
                $query->orderBy('featured', 'desc')
                      ->orderBy('average_rating', 'desc');
        }

        return $query;
    }

    public function getPopularDestinations($limit = 8)
    {
        return Property::selectRaw('cities.name as city_name, states.name as state_name, COUNT(*) as properties_count')
                      ->join('cities', 'properties.city_id', '=', 'cities.id')
                      ->join('states', 'cities.state_id', '=', 'states.id')
                      ->where('properties.active', true)
                      ->groupBy('cities.id', 'cities.name', 'states.name')
                      ->orderBy('properties_count', 'desc')
                      ->limit($limit)
                      ->get();
    }

    public function getFiltersData()
    {
        return [
            'property_types' => Property::select('property_type')
                                      ->distinct()
                                      ->pluck('property_type')
                                      ->filter()
                                      ->values(),
            'price_range' => [
                'min' => Property::where('active', true)->min('price_per_night') ?? 0,
                'max' => Property::where('active', true)->max('price_per_night') ?? 1000
            ],
            'amenities' => $this->getAvailableAmenities()
        ];
    }

    private function getAvailableAmenities()
    {
        $allAmenities = Property::where('active', true)
                               ->whereNotNull('amenities')
                               ->pluck('amenities')
                               ->flatMap(function($amenities) {
                                   return json_decode($amenities, true) ?? [];
                               })
                               ->unique()
                               ->values();

        return $allAmenities;
    }
}

<?php

namespace App\Http\Controllers\Client;

use App\Http\Controllers\Controller;
use App\Models\Favorite;
use App\Models\Property;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class FavoriteController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
        $this->middleware('client');
    }

    public function index()
    {
        $favorites = Auth::user()->favorites()
            ->with('property.images')
            ->latest()
            ->paginate(12);

        return view('client.favorites.index', compact('favorites'));
    }

    public function toggle(Request $request)
    {
        $request->validate([
            'property_id' => 'required|exists:properties,id'
        ]);

        $property = Property::findOrFail($request->property_id);
        $user = Auth::user();

        $favorite = $user->favorites()
            ->where('property_id', $property->id)
            ->first();

        if ($favorite) {
            $favorite->delete();
            $favorited = false;
            $message = __('messages.favorite_removed');
        } else {
            $user->favorites()->create([
                'property_id' => $property->id
            ]);
            $favorited = true;
            $message = __('messages.favorite_added');
        }

        if ($request->ajax()) {
            return response()->json([
                'favorited' => $favorited,
                'message' => $message
            ]);
        }

        return redirect()->back()->with('success', $message);
    }

    public function destroy($id)
    {
        $favorite = Auth::user()->favorites()->findOrFail($id);
        $favorite->delete();

        return redirect()->back()->with('success', __('messages.favorite_removed'));
    }
}


    public function show($id)
    {
        $booking = Auth::user()->bookings()
            ->with(['property.images', 'property.user', 'payments'])
            ->findOrFail($id);

        return view('client.bookings.show', compact('booking'));
    }

    public function cancel(Request $request, $id)
    {
        $booking = Auth::user()->bookings()->findOrFail($id);

        if ($booking->status !== 'confirmed') {
            return redirect()->back()->with('error', __('messages.booking_cannot_cancel'));
        }

        $booking->update(['status' => 'cancelled']);

        return redirect()->route('client.bookings.index')
            ->with('success', __('messages.booking_cancelled'));
    }
}

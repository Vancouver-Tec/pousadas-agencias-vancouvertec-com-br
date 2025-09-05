@extends('layouts.client')

@section('title', __('messages.change_password'))

@section('content')
<div class="container-fluid px-4">
    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="h3 mb-0 text-gray-800">{{ __('messages.change_password') }}</h1>
            <p class="mb-0 text-muted">{{ __('messages.update_account_password') }}</p>
        </div>
        <a href="{{ route('client.profile.show') }}" class="btn btn-outline-secondary">
            <i class="fas fa-arrow-left"></i> {{ __('messages.back_to_profile') }}
        </a>
    </div>

    <div class="row justify-content-center">
        <div class="col-lg-6">
            <div class="card shadow">
                <div class="card-header d-flex align-items-center">
                    <i class="fas fa-key text-primary me-2"></i>
                    <h6 class="m-0 font-weight-bold text-primary">{{ __('messages.password_security') }}</h6>
                </div>
                <div class="card-body">
                    <!-- Security Tips -->
                    <div class="alert alert-info mb-4">
                        <i class="fas fa-info-circle me-2"></i>
                        <strong>{{ __('messages.security_tips') }}:</strong>
                        <ul class="mb-0 mt-2">
                            <li>{{ __('messages.password_tip_1') }}</li>
                            <li>{{ __('messages.password_tip_2') }}</li>
                            <li>{{ __('messages.password_tip_3') }}</li>
                        </ul>
                    </div>

                    <form action="{{ route('client.profile.password.update') }}" method="POST">
                        @csrf
                        @method('PUT')

                        <div class="mb-3">
                            <label for="current_password" class="form-label">{{ __('messages.current_password') }} <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <input type="password" class="form-control @error('current_password') is-invalid @enderror" 
                                       id="current_password" name="current_password" required>
                                <button type="button" class="btn btn-outline-secondary" onclick="togglePassword('current_password')">
                                    <i class="fas fa-eye" id="current_password_icon"></i>
                                </button>
                            </div>
                            @error('current_password')
                                <div class="invalid-feedback d-block">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="mb-3">
                            <label for="password" class="form-label">{{ __('messages.new_password') }} <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <input type="password" class="form-control @error('password') is-invalid @enderror" 
                                       id="password" name="password" required>
                                <button type="button" class="btn btn-outline-secondary" onclick="togglePassword('password')">
                                    <i class="fas fa-eye" id="password_icon"></i>
                                </button>
                            </div>
                            @error('password')
                                <div class="invalid-feedback d-block">{{ $message }}</div>
                            @enderror
                            <div class="form-text">{{ __('messages.password_requirements') }}</div>
                        </div>

                        <div class="mb-4">
                            <label for="password_confirmation" class="form-label">{{ __('messages.confirm_new_password') }} <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <input type="password" class="form-control @error('password_confirmation') is-invalid @enderror" 
                                       id="password_confirmation" name="password_confirmation" required>
                                <button type="button" class="btn btn-outline-secondary" onclick="togglePassword('password_confirmation')">
                                    <i class="fas fa-eye" id="password_confirmation_icon"></i>
                                </button>
                            </div>
                            @error('password_confirmation')
                                <div class="invalid-feedback d-block">{{ $message }}</div>
                            @enderror
                        </div>

                        <!-- Actions -->
                        <div class="d-flex justify-content-end gap-2">
                            <a href="{{ route('client.profile.show') }}" class="btn btn-secondary">
                                {{ __('messages.cancel') }}
                            </a>
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save"></i> {{ __('messages.update_password') }}
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

@push('scripts')
<script>
function togglePassword(fieldId) {
    const field = document.getElementById(fieldId);
    const icon = document.getElementById(fieldId + '_icon');
    
    if (field.type === 'password') {
        field.type = 'text';
        icon.classList.remove('fa-eye');
        icon.classList.add('fa-eye-slash');
    } else {
        field.type = 'password';
        icon.classList.remove('fa-eye-slash');
        icon.classList.add('fa-eye');
    }
}

// Password strength indicator
document.getElementById('password').addEventListener('input', function() {
    const password = this.value;
    const strengthBar = document.getElementById('strength-bar');
    
    let strength = 0;
    if (password.length >= 8) strength++;
    if (password.match(/[a-z]/)) strength++;
    if (password.match(/[A-Z]/)) strength++;
    if (password.match(/[0-9]/)) strength++;
    if (password.match(/[^a-zA-Z0-9]/)) strength++;
    
    const colors = ['#dc3545', '#fd7e14', '#ffc107', '#20c997', '#28a745'];
    const labels = ['{{ __("messages.very_weak") }}', '{{ __("messages.weak") }}', '{{ __("messages.fair") }}', '{{ __("messages.good") }}', '{{ __("messages.strong") }}'];
    
    if (strengthBar) {
        strengthBar.style.width = (strength * 20) + '%';
        strengthBar.style.backgroundColor = colors[strength - 1] || '#dc3545';
        strengthBar.textContent = labels[strength - 1] || '';
    }
});
</script>
@endpush
@endsection

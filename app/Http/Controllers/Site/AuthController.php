<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Auth\Events\Registered;
use Illuminate\Validation\Rules;

class AuthController extends Controller
{
    public function showLogin()
    {
        return view('site.auth.login');
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ], [
            'email.required' => 'O email é obrigatório',
            'email.email' => 'Digite um email válido',
            'password.required' => 'A senha é obrigatória'
        ]);

        $credentials = $request->only('email', 'password');
        $remember = $request->boolean('remember');

        if (Auth::attempt($credentials, $remember)) {
            $request->session()->regenerate();

            $user = Auth::user();
            
            // Redirecionar baseado no tipo de usuário
            if ($user->role === 'admin') {
                return redirect()->intended(route('admin.dashboard'))->with('success', 'Login realizado com sucesso!');
            } else {
                return redirect()->intended(route('client.dashboard'))->with('success', 'Bem-vindo de volta!');
            }
        }

        return back()->withErrors([
            'email' => 'As credenciais não correspondem aos nossos registros.',
        ])->onlyInput('email');
    }

    public function showRegister()
    {
        return view('site.auth.register');
    }

    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
            'phone' => 'nullable|string|max:20',
            'terms' => 'required|accepted'
        ], [
            'name.required' => 'O nome é obrigatório',
            'email.required' => 'O email é obrigatório',
            'email.email' => 'Digite um email válido',
            'email.unique' => 'Este email já está cadastrado',
            'password.required' => 'A senha é obrigatória',
            'password.confirmed' => 'As senhas não coincidem',
            'terms.accepted' => 'Você deve aceitar os termos de uso'
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'phone' => $request->phone,
            'role' => 'client',
            'active' => true
        ]);

        event(new Registered($user));

        Auth::login($user);

        return redirect(route('client.dashboard'))->with('success', 'Conta criada com sucesso!');
    }

    public function showForgotPassword()
    {
        return view('site.auth.forgot-password');
    }

    public function forgotPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email'
        ], [
            'email.required' => 'O email é obrigatório',
            'email.email' => 'Digite um email válido'
        ]);

        $status = Password::sendResetLink(
            $request->only('email')
        );

        if ($status === Password::RESET_LINK_SENT) {
            return back()->with('status', 'Link de recuperação enviado para seu email!');
        }

        return back()->withErrors(['email' => 'Não encontramos um usuário com este email.']);
    }

    public function showResetPassword(Request $request)
    {
        return view('site.auth.reset-password', [
            'token' => $request->token,
            'email' => $request->email
        ]);
    }

    public function resetPassword(Request $request)
    {
        $request->validate([
            'token' => 'required',
            'email' => 'required|email',
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
        ], [
            'email.required' => 'O email é obrigatório',
            'password.required' => 'A senha é obrigatória',
            'password.confirmed' => 'As senhas não coincidem'
        ]);

        $status = Password::reset(
            $request->only('email', 'password', 'password_confirmation', 'token'),
            function (User $user, string $password) {
                $user->forceFill([
                    'password' => Hash::make($password)
                ]);

                $user->save();
            }
        );

        if ($status === Password::PASSWORD_RESET) {
            return redirect()->route('login')->with('status', 'Senha alterada com sucesso!');
        }

        return back()->withErrors(['email' => 'Token inválido ou expirado.']);
    }

    public function logout(Request $request)
    {
        Auth::logout();

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('site.home')->with('success', 'Logout realizado com sucesso!');
    }
}

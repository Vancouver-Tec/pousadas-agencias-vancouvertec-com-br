<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $title }} - Vancouver-Tec Pousadas</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #003580 0%, #0057b8 100%);
            color: white;
            min-height: 100vh;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            text-align: center;
            padding: 60px 0;
        }
        .header h1 {
            font-size: 3em;
            margin-bottom: 10px;
        }
        .header p {
            font-size: 1.2em;
            opacity: 0.9;
        }
        .search-box {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin: 40px 0;
            color: #333;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }
        .search-form {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr auto;
            gap: 15px;
            align-items: end;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .form-group input, .form-group select {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
        }
        .btn-search {
            background: #0071c2;
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
            height: fit-content;
        }
        .btn-search:hover {
            background: #005999;
        }
        .status {
            text-align: center;
            padding: 40px;
            background: rgba(255,255,255,0.1);
            border-radius: 8px;
            margin-top: 40px;
        }
        @media (max-width: 768px) {
            .search-form {
                grid-template-columns: 1fr;
            }
            .header h1 {
                font-size: 2em;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>{{ $title }}</h1>
            <p>{{ $subtitle }}</p>
        </div>

        <div class="search-box">
            <form class="search-form" action="{{ route('properties.search') }}" method="GET">
                <div class="form-group">
                    <label>Para onde você vai?</label>
                    <input type="text" name="destination" placeholder="Cidade, região, propriedade">
                </div>
                <div class="form-group">
                    <label>Data de check-in</label>
                    <input type="date" name="checkin" value="{{ date('Y-m-d') }}">
                </div>
                <div class="form-group">
                    <label>Data de check-out</label>
                    <input type="date" name="checkout" value="{{ date('Y-m-d', strtotime('+1 day')) }}">
                </div>
                <div class="form-group">
                    <button type="submit" class="btn-search">Pesquisar</button>
                </div>
            </form>
        </div>

        <div class="status">
            <h3>🎉 Sistema Vancouver-Tec está funcionando!</h3>
            <p>Idioma atual: <strong>{{ strtoupper(app()->getLocale()) }}</strong></p>
            <p>Middleware de idiomas: <strong>✅ Ativo</strong></p>
            <p>Banco de dados: <strong>{{ config('database.default') }}</strong></p>
        </div>
    </div>
</body>
</html>

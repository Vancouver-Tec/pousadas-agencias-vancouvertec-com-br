@extends('layouts.admin')

@section('title', 'Propriedades')
@section('page-title', 'Gestão de Propriedades')

@section('content')
<div class="mb-6">
    <a href="{{ route('admin.properties.create') }}" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg">
        <i class="fas fa-plus mr-2"></i>Nova Propriedade
    </a>
</div>

<div class="bg-white rounded-lg shadow overflow-hidden">
    @if(isset($properties) && $properties->count() > 0)
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Nome</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Localização</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Preço</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Ações</th>
                </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
                @foreach($properties as $property)
                    <tr>
                        <td class="px-6 py-4">
                            <div class="flex items-center">
                                <img class="h-10 w-10 rounded-full object-cover" 
                                     src="{{ $property->photos->first() ? asset('uploads/properties/'.$property->photos->first()->filename) : 'https://via.placeholder.com/40' }}" 
                                     alt="">
                                <div class="ml-4">
                                    <div class="text-sm font-medium text-gray-900">{{ $property->name }}</div>
                                    <div class="text-sm text-gray-500">{{ $property->type }}</div>
                                </div>
                            </div>
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-900">
                            {{ $property->city }}, {{ $property->state }}
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-900">
                            R$ {{ number_format($property->price_per_night, 2, ',', '.') }}
                        </td>
                        <td class="px-6 py-4">
                            @if($property->active)
                                <span class="px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">Ativa</span>
                            @else
                                <span class="px-2 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-800">Inativa</span>
                            @endif
                        </td>
                        <td class="px-6 py-4 text-sm space-x-2">
                            <a href="{{ route('admin.properties.edit', $property->id) }}" 
                               class="text-blue-600 hover:text-blue-900">Editar</a>
                            <form method="POST" action="{{ route('admin.properties.destroy', $property->id) }}" 
                                  class="inline" onsubmit="return confirm('Tem certeza?')">
                                @csrf @method('DELETE')
                                <button type="submit" class="text-red-600 hover:text-red-900">Excluir</button>
                            </form>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
        
        <div class="px-6 py-4">
            {{ $properties->links() }}
        </div>
    @else
        <div class="text-center py-12">
            <i class="fas fa-building text-4xl text-gray-300 mb-4"></i>
            <h3 class="text-lg font-medium text-gray-900 mb-2">Nenhuma propriedade cadastrada</h3>
            <p class="text-gray-500 mb-4">Comece adicionando sua primeira propriedade</p>
            <a href="{{ route('admin.properties.create') }}" 
               class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg">
                <i class="fas fa-plus mr-2"></i>Nova Propriedade
            </a>
        </div>
    @endif
</div>
@endsection

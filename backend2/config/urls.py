from django.contrib import admin
from django.urls import path, include
from django.http import JsonResponse

def home_view(request):
    return JsonResponse({
        'status': 'ok',
        'message': 'Backend 2 (django-oidc-provider OpenID Server) is active',
        'discovery': '/.well-known/openid-configuration',
        'jwks': '/jwks/',
        'authorize': '/authorize/',
        'token': '/token/',
        'userinfo': '/userinfo/',
        'admin': '/admin/',
    })

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/status/', home_view, name='home_status'),
    path('', include('oidc_provider.urls', namespace='oidc_provider')),
]

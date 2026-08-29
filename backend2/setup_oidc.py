import os
import json
import uuid
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.core.management import call_command
from django.contrib.auth.models import User
from oidc_provider.models import Client, ResponseType, RSAKey

def setup():
    # 1. Run migrations
    print("Running migrations...")
    call_command('migrate', interactive=False)

    # 2. Generate RSA Key if not exists
    if not RSAKey.objects.exists():
        print("Generating RS256 RSA Signing Key...")
        call_command('creatersakey')
    else:
        print("RSA Signing Key already exists.")

    # 3. Create Superuser
    if not User.objects.filter(username='admin').exists():
        User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
        print("Created superuser 'admin' (password: 'admin123')")
    else:
        print("Superuser 'admin' already exists.")

    # 4. Create test user student01
    student, created = User.objects.get_or_create(
        username='student01',
        defaults={
            'email': 'student01@university.ac.th',
            'first_name': 'Student',
            'last_name': 'One'
        }
    )
    if created:
        student.set_password('test1234')
        student.save()
        print("Created test user 'student01' (password: 'test1234')")
    else:
        print("Test user 'student01' already exists.")

    # 5. Create or get ResponseType 'code'
    code_resp_type, _ = ResponseType.objects.get_or_create(value='code')

    # 6. Create OIDC Client for Flutter Web
    client = Client.objects.filter(name='flutter-web-app').first()
    if not client:
        client = Client.objects.create(
            name='flutter-web-app',
            client_id='flutter-web-client-12345',
            client_type='public',
            _redirect_uris='http://localhost:50000\nhttp://localhost:50000/\nhttp://localhost:50000/index.html',
            _scope='openid profile email',
            jwt_alg='RS256',
            reuse_consent=True,
            require_consent=False,
        )
        client.response_types.add(code_resp_type)
        client.save()
        print(f"Created OIDC Client 'flutter-web-app' with Client ID: {client.client_id}")
    else:
        if not client.client_id:
            client.client_id = 'flutter-web-client-12345'
        client._redirect_uris = 'http://localhost:50000\nhttp://localhost:50000/\nhttp://localhost:50000/index.html'
        client.reuse_consent = True
        client.require_consent = False
        client.save()
        client.response_types.add(code_resp_type)
        print(f"OIDC Client 'flutter-web-app' updated with Client ID: {client.client_id}")

    # Write client info to JSON for Flutter app configuration
    config = {
        'issuer': 'http://localhost:8000',
        'client_id': client.client_id,
        'client_type': client.client_type,
        'redirect_uri': 'http://localhost:50000',
        'scopes': ['openid', 'profile', 'email'],
    }
    with open('client_config.json', 'w') as f:
        json.dump(config, f, indent=2)
    print("Saved OIDC configuration to client_config.json")
    print(json.dumps(config, indent=2))

if __name__ == '__main__':
    setup()

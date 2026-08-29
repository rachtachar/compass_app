import os
import django
from datetime import date, timedelta

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth.models import User
from app.models import Booking

def setup():
    # 1. Create superuser
    if not User.objects.filter(username='admin').exists():
        User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
        print("Created superuser 'admin' (password: 'admin123')")
    else:
        print("Superuser 'admin' already exists")

    # 2. Create student test user
    student, created = User.objects.get_or_create(
        username='student01',
        defaults={'email': 'student01@university.ac.th', 'first_name': 'Student', 'last_name': 'One'}
    )
    if created:
        student.set_password('test1234')
        student.save()
        print("Created test user 'student01' (password: 'test1234')")
    else:
        print("Test user 'student01' already exists")

    # 3. Create sample bookings
    sample_bookings = [
        {'destination_name': 'Tokyo, Japan 🌸', 'price': 35000.00, 'days': 7},
        {'destination_name': 'Chiang Mai, Thailand ⛰️', 'price': 8500.00, 'days': 3},
        {'destination_name': 'Seoul, South Korea 🇰🇷', 'price': 28000.00, 'days': 5},
        {'destination_name': 'Paris, France 🗼', 'price': 62000.00, 'days': 10},
    ]

    for item in sample_bookings:
        start = date.today() + timedelta(days=14)
        end = start + timedelta(days=item['days'])
        Booking.objects.get_or_create(
            destination_name=item['destination_name'],
            defaults={
                'user': student,
                'price': item['price'],
                'start_date': start,
                'end_date': end,
            }
        )
    print(f"Total bookings in database: {Booking.objects.count()}")

if __name__ == '__main__':
    setup()

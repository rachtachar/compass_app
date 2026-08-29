from django.urls import path
from .views import BookingListView, UserProfileView, HealthCheckView

urlpatterns = [
    path('', HealthCheckView.as_view(), name='health_check'),
    path('bookings/', BookingListView.as_view(), name='bookings_list'),
    path('profile/', UserProfileView.as_view(), name='user_profile'),
]

from django.contrib import admin
from .models import Booking

@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ('id', 'destination_name', 'price', 'start_date', 'end_date', 'user', 'created_at')
    list_filter = ('start_date', 'end_date')
    search_fields = ('destination_name', 'user__username')

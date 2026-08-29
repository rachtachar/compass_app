from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework import status
from .models import Booking
from .serializers import BookingSerializer, UserSerializer

class HealthCheckView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        return Response({
            'status': 'ok',
            'message': 'Backend 1 (DRF + SimpleJWT) is running',
            'endpoints': {
                'token': '/api/token/',
                'token_refresh': '/api/token/refresh/',
                'bookings': '/api/bookings/',
                'profile': '/api/profile/',
            }
        })

class BookingListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        bookings = Booking.objects.all()
        serializer = BookingSerializer(bookings, many=True)
        return Response({
            'user': request.user.username,
            'count': bookings.count(),
            'bookings': serializer.data
        })

    def post(self, request):
        serializer = BookingSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response({
            'authenticated': True,
            'user': serializer.data,
        })

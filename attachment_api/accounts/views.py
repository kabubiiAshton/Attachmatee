"""Auth and profile views."""
from django.contrib.auth import get_user_model
from rest_framework import generics, status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.views import TokenObtainPairView

from .models import StudentProfile, CompanyProfile
from .permissions import IsAdminRole
from .serializers import (
    RegisterSerializer, UserSerializer, StudentProfileSerializer,
    CompanyProfileSerializer, MyTokenObtainPairSerializer,
)

User = get_user_model()


class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [AllowAny]


class MyTokenObtainPairView(TokenObtainPairView):
    serializer_class = MyTokenObtainPairSerializer


class MeView(generics.RetrieveUpdateAPIView):
    """The logged-in user's own account record."""
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user


class StudentProfileViewSet(viewsets.ModelViewSet):
    """Students manage their own profile; admins can see all.

    /api/students/me/ is the convenient self endpoint.
    """
    serializer_class = StudentProfileSerializer

    def get_queryset(self):
        user = self.request.user
        if user.is_admin_role or user.is_company:
            return StudentProfile.objects.select_related("user").all()
        return StudentProfile.objects.filter(user=user)

    @action(detail=False, methods=["get", "put", "patch"])
    def me(self, request):
        profile, _ = StudentProfile.objects.get_or_create(user=request.user)
        if request.method == "GET":
            return Response(self.get_serializer(profile).data)
        partial = request.method == "PATCH"
        serializer = self.get_serializer(profile, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)


class CompanyProfileViewSet(viewsets.ModelViewSet):
    serializer_class = CompanyProfileSerializer

    def get_queryset(self):
        user = self.request.user
        if user.is_admin_role or user.is_student:
            return CompanyProfile.objects.select_related("user").all()
        return CompanyProfile.objects.filter(user=user)

    @action(detail=False, methods=["get", "put", "patch"])
    def me(self, request):
        profile, _ = CompanyProfile.objects.get_or_create(user=request.user)
        if request.method == "GET":
            return Response(self.get_serializer(profile).data)
        partial = request.method == "PATCH"
        serializer = self.get_serializer(profile, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)

    @action(detail=True, methods=["post"], permission_classes=[IsAdminRole])
    def verify(self, request, pk=None):
        """Admin-only: mark a company as verified."""
        company = self.get_object()
        company.is_verified = True
        company.save(update_fields=["is_verified"])
        return Response(
            {"detail": "Company verified.", "is_verified": True},
            status=status.HTTP_200_OK,
        )

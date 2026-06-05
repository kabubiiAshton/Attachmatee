"""Serializers for registration, users, and profiles."""
from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

from .models import StudentProfile, CompanyProfile

User = get_user_model()


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, validators=[validate_password])
    # Optional display name used to seed the role profile.
    name = serializers.CharField(write_only=True, required=False, allow_blank=True)
    # Username is auto-filled from email when omitted (see create()).
    username = serializers.CharField(required=False, allow_blank=True)

    class Meta:
        model = User
        fields = ["id", "email", "username", "password", "role", "phone", "name"]

    def validate_role(self, value):
        # Public registration cannot create admin accounts.
        if value == User.Role.ADMIN:
            raise serializers.ValidationError("Admin accounts cannot be self-registered.")
        return value

    def create(self, validated_data):
        name = validated_data.pop("name", "")
        password = validated_data.pop("password")
        if not validated_data.get("username"):
            validated_data["username"] = validated_data["email"]
        user = User(**validated_data)
        user.set_password(password)
        user.save()
        # Seed the matching profile so the user has somewhere to land.
        if user.is_student:
            StudentProfile.objects.create(user=user, full_name=name)
        elif user.is_company:
            CompanyProfile.objects.create(user=user, company_name=name)
        return user


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "email", "username", "role", "phone", "is_active"]
        read_only_fields = ["id", "role", "is_active"]


class StudentProfileSerializer(serializers.ModelSerializer):
    email = serializers.EmailField(source="user.email", read_only=True)

    class Meta:
        model = StudentProfile
        fields = [
            "id", "email", "full_name", "registration_number", "course",
            "institution", "year_of_study", "skills", "bio", "cv",
            "created_at", "updated_at",
        ]
        read_only_fields = ["id", "email", "created_at", "updated_at"]


class CompanyProfileSerializer(serializers.ModelSerializer):
    email = serializers.EmailField(source="user.email", read_only=True)

    class Meta:
        model = CompanyProfile
        fields = [
            "id", "email", "company_name", "industry", "location", "website",
            "description", "is_verified", "created_at", "updated_at",
        ]
        # Only an admin endpoint flips is_verified; never the company itself.
        read_only_fields = ["id", "email", "is_verified", "created_at", "updated_at"]


class MyTokenObtainPairSerializer(TokenObtainPairSerializer):
    """Embed role and email in the JWT and the login response."""

    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token["role"] = user.role
        token["email"] = user.email
        return token

    def validate(self, attrs):
        data = super().validate(attrs)
        data["role"] = self.user.role
        data["email"] = self.user.email
        data["user_id"] = self.user.id
        return data

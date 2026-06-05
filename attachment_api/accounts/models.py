"""User and profile models.

A single custom User carries a role (student, company, or admin). Each role
has a one-to-one profile holding the details specific to that role.
"""
from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    class Role(models.TextChoices):
        STUDENT = "student", "Student"
        COMPANY = "company", "Company"
        ADMIN = "admin", "Administrator"

    # email is the login identifier; username is kept but not required to be unique-facing
    email = models.EmailField(unique=True)
    role = models.CharField(max_length=10, choices=Role.choices, default=Role.STUDENT)
    phone = models.CharField(max_length=20, blank=True)

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["username"]

    @property
    def is_student(self):
        return self.role == self.Role.STUDENT

    @property
    def is_company(self):
        return self.role == self.Role.COMPANY

    @property
    def is_admin_role(self):
        return self.role == self.Role.ADMIN or self.is_staff

    def __str__(self):
        return f"{self.email} ({self.role})"


class StudentProfile(models.Model):
    user = models.OneToOneField(
        User, on_delete=models.CASCADE, related_name="student_profile"
    )
    full_name = models.CharField(max_length=150)
    registration_number = models.CharField(max_length=50, blank=True)
    course = models.CharField(max_length=150, blank=True)
    institution = models.CharField(max_length=150, blank=True)
    year_of_study = models.PositiveSmallIntegerField(null=True, blank=True)
    skills = models.TextField(blank=True, help_text="Comma-separated skills")
    bio = models.TextField(blank=True)
    cv = models.FileField(upload_to="cvs/", null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.full_name or self.user.email


class CompanyProfile(models.Model):
    user = models.OneToOneField(
        User, on_delete=models.CASCADE, related_name="company_profile"
    )
    company_name = models.CharField(max_length=200)
    industry = models.CharField(max_length=150, blank=True)
    location = models.CharField(max_length=150, blank=True)
    website = models.URLField(blank=True)
    description = models.TextField(blank=True)
    # Administrators verify companies before their postings go live.
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.company_name or self.user.email

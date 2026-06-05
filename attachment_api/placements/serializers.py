"""Serializers for postings, applications, and notifications."""
from rest_framework import serializers

from .models import JobPosting, Application, Notification


class JobPostingSerializer(serializers.ModelSerializer):
    company_name = serializers.CharField(source="company.company_name", read_only=True)
    application_count = serializers.IntegerField(source="applications.count", read_only=True)

    class Meta:
        model = JobPosting
        fields = [
            "id", "company", "company_name", "title", "description",
            "requirements", "location", "slots", "deadline", "status",
            "application_count", "created_at", "updated_at",
        ]
        # company is taken from the logged-in user; status is admin-controlled.
        read_only_fields = ["id", "company", "status", "created_at", "updated_at"]


class ApplicationSerializer(serializers.ModelSerializer):
    student_name = serializers.CharField(source="student.full_name", read_only=True)
    posting_title = serializers.CharField(source="posting.title", read_only=True)

    class Meta:
        model = Application
        fields = [
            "id", "posting", "posting_title", "student", "student_name",
            "cover_letter", "status", "created_at", "updated_at",
        ]
        # student is taken from the logged-in user; status changes via a dedicated action.
        read_only_fields = ["id", "student", "status", "created_at", "updated_at"]


class ApplicationStatusSerializer(serializers.Serializer):
    """Used by companies/admins to update an application's status."""
    status = serializers.ChoiceField(choices=Application.Status.choices)


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ["id", "message", "is_read", "created_at"]
        read_only_fields = ["id", "message", "created_at"]

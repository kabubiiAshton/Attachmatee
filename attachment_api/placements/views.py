"""Placement views: postings, applications, notifications."""
from rest_framework import viewsets, status, mixins
from rest_framework.decorators import action
from rest_framework.exceptions import PermissionDenied, ValidationError
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from accounts.models import StudentProfile, CompanyProfile
from accounts.permissions import IsAdminRole
from .models import JobPosting, Application, Notification
from .notifications import notify
from .serializers import (
    JobPostingSerializer, ApplicationSerializer,
    ApplicationStatusSerializer, NotificationSerializer,
)


class JobPostingViewSet(viewsets.ModelViewSet):
    serializer_class = JobPostingSerializer
    search_fields = ["title", "description", "location", "requirements"]
    ordering_fields = ["created_at", "deadline", "title"]

    def get_queryset(self):
        user = self.request.user
        base = JobPosting.objects.select_related("company")
        if user.is_admin_role:
            return base.all()
        if user.is_company:
            # A company sees only its own postings (any status).
            return base.filter(company__user=user)
        # Students and everyone else see only approved postings.
        return base.filter(status=JobPosting.Status.APPROVED)

    def perform_create(self, serializer):
        user = self.request.user
        if not user.is_company:
            raise PermissionDenied("Only companies can create postings.")
        company = CompanyProfile.objects.filter(user=user).first()
        if company is None:
            raise ValidationError("Complete your company profile first.")
        posting = serializer.save(company=company, status=JobPosting.Status.PENDING)
        # Tell admins there is something to review.
        from accounts.models import User
        for admin in User.objects.filter(role=User.Role.ADMIN):
            notify(admin, f"New posting '{posting.title}' awaits approval.")

    def _require_admin(self):
        if not self.request.user.is_admin_role:
            raise PermissionDenied("Admin only.")

    @action(detail=True, methods=["post"], permission_classes=[IsAdminRole])
    def approve(self, request, pk=None):
        posting = self.get_object()
        posting.status = JobPosting.Status.APPROVED
        posting.save(update_fields=["status"])
        notify(posting.company.user, f"Your posting '{posting.title}' was approved.")
        return Response({"detail": "Approved.", "status": posting.status})

    @action(detail=True, methods=["post"], permission_classes=[IsAdminRole])
    def reject(self, request, pk=None):
        posting = self.get_object()
        posting.status = JobPosting.Status.REJECTED
        posting.save(update_fields=["status"])
        notify(posting.company.user, f"Your posting '{posting.title}' was rejected.")
        return Response({"detail": "Rejected.", "status": posting.status})

    @action(detail=True, methods=["get"])
    def applications(self, request, pk=None):
        """List applications for a posting (company owner or admin only)."""
        posting = self.get_object()
        user = request.user
        if not (user.is_admin_role or posting.company.user == user):
            raise PermissionDenied("Not your posting.")
        qs = posting.applications.select_related("student").all()
        page = self.paginate_queryset(qs)
        serializer = ApplicationSerializer(page or qs, many=True)
        if page is not None:
            return self.get_paginated_response(serializer.data)
        return Response(serializer.data)


class ApplicationViewSet(viewsets.ModelViewSet):
    serializer_class = ApplicationSerializer

    def get_queryset(self):
        user = self.request.user
        base = Application.objects.select_related("posting", "student")
        if user.is_admin_role:
            return base.all()
        if user.is_company:
            return base.filter(posting__company__user=user)
        # Student: only their own applications.
        return base.filter(student__user=user)

    def perform_create(self, serializer):
        user = self.request.user
        if not user.is_student:
            raise PermissionDenied("Only students can apply.")
        student = StudentProfile.objects.filter(user=user).first()
        if student is None:
            raise ValidationError("Complete your student profile first.")
        posting = serializer.validated_data["posting"]
        if posting.status != JobPosting.Status.APPROVED:
            raise ValidationError("This posting is not open for applications.")
        if Application.objects.filter(posting=posting, student=student).exists():
            raise ValidationError("You have already applied to this posting.")
        application = serializer.save(student=student)
        notify(
            posting.company.user,
            f"{student.full_name or 'A student'} applied to '{posting.title}'.",
        )

    @action(detail=True, methods=["post"])
    def status(self, request, pk=None):
        """Company (owner) or admin updates an application's status."""
        application = self.get_object()
        user = request.user
        if not (user.is_admin_role or application.posting.company.user == user):
            raise PermissionDenied("Not your posting.")
        serializer = ApplicationStatusSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        new_status = serializer.validated_data["status"]
        application.status = new_status
        application.save(update_fields=["status"])
        notify(
            application.student.user,
            f"Your application to '{application.posting.title}' is now: {new_status}.",
        )
        return Response({"detail": "Status updated.", "status": new_status})

    @action(detail=True, methods=["post"])
    def withdraw(self, request, pk=None):
        """A student withdraws their own application."""
        application = self.get_object()
        if application.student.user != request.user:
            raise PermissionDenied("Not your application.")
        application.status = Application.Status.WITHDRAWN
        application.save(update_fields=["status"])
        return Response({"detail": "Withdrawn.", "status": application.status})


class NotificationViewSet(
    mixins.ListModelMixin, mixins.RetrieveModelMixin, viewsets.GenericViewSet
):
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Notification.objects.filter(recipient=self.request.user)

    @action(detail=True, methods=["post"])
    def read(self, request, pk=None):
        n = self.get_object()
        n.is_read = True
        n.save(update_fields=["is_read"])
        return Response({"detail": "Marked read."})

    @action(detail=False, methods=["post"])
    def read_all(self, request):
        self.get_queryset().update(is_read=True)
        return Response({"detail": "All marked read."})

    @action(detail=False, methods=["get"])
    def unread_count(self, request):
        count = self.get_queryset().filter(is_read=False).count()
        return Response({"unread": count})

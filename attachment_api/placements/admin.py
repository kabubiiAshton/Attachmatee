from django.contrib import admin

from .models import JobPosting, Application, Notification


@admin.register(JobPosting)
class JobPostingAdmin(admin.ModelAdmin):
    list_display = ("title", "company", "status", "slots", "deadline", "created_at")
    list_filter = ("status",)
    search_fields = ("title", "company__company_name")
    actions = ["approve", "reject"]

    @admin.action(description="Approve selected postings")
    def approve(self, request, queryset):
        queryset.update(status=JobPosting.Status.APPROVED)

    @admin.action(description="Reject selected postings")
    def reject(self, request, queryset):
        queryset.update(status=JobPosting.Status.REJECTED)


@admin.register(Application)
class ApplicationAdmin(admin.ModelAdmin):
    list_display = ("student", "posting", "status", "created_at")
    list_filter = ("status",)
    search_fields = ("student__full_name", "posting__title")


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ("recipient", "message", "is_read", "created_at")
    list_filter = ("is_read",)

from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin

from .models import User, StudentProfile, CompanyProfile


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ("email", "username", "role", "is_active", "is_staff")
    list_filter = ("role", "is_active", "is_staff")
    search_fields = ("email", "username")
    ordering = ("email",)
    fieldsets = BaseUserAdmin.fieldsets + (("Role", {"fields": ("role", "phone")}),)


@admin.register(StudentProfile)
class StudentProfileAdmin(admin.ModelAdmin):
    list_display = ("full_name", "registration_number", "institution", "course")
    search_fields = ("full_name", "registration_number")


@admin.register(CompanyProfile)
class CompanyProfileAdmin(admin.ModelAdmin):
    list_display = ("company_name", "industry", "location", "is_verified")
    list_filter = ("is_verified", "industry")
    search_fields = ("company_name",)
    actions = ["mark_verified"]

    @admin.action(description="Mark selected companies as verified")
    def mark_verified(self, request, queryset):
        queryset.update(is_verified=True)

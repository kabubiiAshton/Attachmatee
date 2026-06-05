"""Role-based permission classes used across the API."""
from rest_framework.permissions import BasePermission, SAFE_METHODS


class IsStudent(BasePermission):
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.is_student)


class IsCompany(BasePermission):
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.is_company)


class IsAdminRole(BasePermission):
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.is_admin_role)


class IsOwnerOrAdmin(BasePermission):
    """Object-level: only the owning user (via .user) or an admin may write.

    Read access is allowed to any authenticated user; the view's queryset is
    expected to already scope what each role can see.
    """

    def has_object_permission(self, request, view, obj):
        if request.method in SAFE_METHODS:
            return True
        if request.user.is_admin_role:
            return True
        owner = getattr(obj, "user", None)
        return owner == request.user

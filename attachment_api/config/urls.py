"""Root URL configuration."""
from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView

from accounts.views import (
    RegisterView, MeView, MyTokenObtainPairView,
    StudentProfileViewSet, CompanyProfileViewSet,
)
from placements.views import (
    JobPostingViewSet, ApplicationViewSet, NotificationViewSet,
)

router = DefaultRouter()
router.register(r"students", StudentProfileViewSet, basename="student")
router.register(r"companies", CompanyProfileViewSet, basename="company")
router.register(r"postings", JobPostingViewSet, basename="posting")
router.register(r"applications", ApplicationViewSet, basename="application")
router.register(r"notifications", NotificationViewSet, basename="notification")

api_patterns = [
    path("auth/register/", RegisterView.as_view(), name="register"),
    path("auth/login/", MyTokenObtainPairView.as_view(), name="login"),
    path("auth/refresh/", TokenRefreshView.as_view(), name="refresh"),
    path("auth/me/", MeView.as_view(), name="me"),
    path("", include(router.urls)),
]

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/", include(api_patterns)),
    path("api-auth/", include("rest_framework.urls")),  # browsable API login
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

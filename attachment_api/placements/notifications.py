"""Helper to create an in-app notification and send a matching email.

Centralising this keeps the views tidy and makes it a single place to swap in
a real email/SMS provider later.
"""
from django.conf import settings
from django.core.mail import send_mail

from .models import Notification


def notify(user, message):
    Notification.objects.create(recipient=user, message=message)
    if user.email:
        try:
            send_mail(
                subject="Attachment Placement System",
                message=message,
                from_email=settings.DEFAULT_FROM_EMAIL,
                recipient_list=[user.email],
                fail_silently=True,
            )
        except Exception:
            # Never let a mail failure break the request.
            pass

"""Seed the database with demo users and data for quick testing.

Run: python manage.py seed_demo
"""
from datetime import date, timedelta

from django.core.management.base import BaseCommand

from accounts.models import User, StudentProfile, CompanyProfile
from placements.models import JobPosting, Application


class Command(BaseCommand):
    help = "Create demo admin, company, and student accounts with sample data."

    def handle(self, *args, **options):
        # Admin
        admin, created = User.objects.get_or_create(
            email="admin@demo.local",
            defaults={"username": "admin", "role": User.Role.ADMIN,
                      "is_staff": True, "is_superuser": True},
        )
        if created:
            admin.set_password("admin1234")
            admin.save()
            self.stdout.write("Created admin@demo.local / admin1234")

        # Company
        comp_user, created = User.objects.get_or_create(
            email="company@demo.local",
            defaults={"username": "company", "role": User.Role.COMPANY},
        )
        if created:
            comp_user.set_password("company1234")
            comp_user.save()
        company, _ = CompanyProfile.objects.get_or_create(
            user=comp_user,
            defaults={"company_name": "Acme Tech Ltd", "industry": "Software",
                      "location": "Nairobi", "is_verified": True},
        )

        # Student
        stu_user, created = User.objects.get_or_create(
            email="student@demo.local",
            defaults={"username": "student", "role": User.Role.STUDENT},
        )
        if created:
            stu_user.set_password("student1234")
            stu_user.save()
        student, _ = StudentProfile.objects.get_or_create(
            user=stu_user,
            defaults={"full_name": "Jane Mwangi", "registration_number": "HDB212-0001/2023",
                      "course": "BBIT", "institution": "JKUAT", "year_of_study": 4,
                      "skills": "Python, Django, React"},
        )

        # A posting + application
        posting, _ = JobPosting.objects.get_or_create(
            company=company, title="Software Development Intern",
            defaults={"description": "Assist the engineering team for 3 months.",
                      "requirements": "Python, Git", "location": "Nairobi",
                      "slots": 2, "deadline": date.today() + timedelta(days=30),
                      "status": JobPosting.Status.APPROVED},
        )
        Application.objects.get_or_create(
            posting=posting, student=student,
            defaults={"cover_letter": "I am keen to learn and contribute."},
        )

        self.stdout.write(self.style.SUCCESS("Demo data ready."))
        self.stdout.write("Logins: admin@demo.local/admin1234, "
                          "company@demo.local/company1234, "
                          "student@demo.local/student1234")

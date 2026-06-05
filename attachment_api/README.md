# Student Industrial Attachment & Placement System — Backend API

Django REST Framework backend for the system described in the Group 9A project
report. It provides JWT-authenticated REST endpoints for the three roles in the
report — students, companies, and administrators — covering registration,
profiles, job postings, applications, and notifications.

This is the **backend foundation**. The React web app and Flutter mobile app
both talk to these same endpoints.

## Tech stack

- Python 3.12, Django 5.1
- Django REST Framework (REST API)
- SimpleJWT (token auth)
- django-cors-headers (lets the web/mobile clients call the API)
- SQLite in development, PostgreSQL in production (switch via env vars)

## Quick start

```bash
# 1. Create and activate a virtual environment
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate

# 2. Install dependencies
pip install -r requirements.txt

# 3. Apply migrations
python manage.py migrate

# 4. (Optional) seed demo accounts + sample data
python manage.py seed_demo

# 5. Run the server
python manage.py runserver
```

The API is then at `http://127.0.0.1:8000/api/`. The browsable DRF interface
works in a browser; log in via `http://127.0.0.1:8000/api-auth/login/`.

### Demo logins (after `seed_demo`)

| Role    | Email                | Password     |
|---------|----------------------|--------------|
| Admin   | admin@demo.local     | admin1234    |
| Company | company@demo.local   | company1234  |
| Student | student@demo.local   | student1234  |

The Django admin site is at `/admin/` (use the admin login above).

## Authentication

Obtain a token pair, then send the access token as a Bearer header.

```bash
# Login
curl -X POST http://127.0.0.1:8000/api/auth/login/ \
  -H 'Content-Type: application/json' \
  -d '{"email":"student@demo.local","password":"student1234"}'
# -> {"access":"...","refresh":"...","role":"student","user_id":3,...}

# Authenticated request
curl http://127.0.0.1:8000/api/postings/ \
  -H 'Authorization: Bearer <access-token>'

# Refresh an expired access token
curl -X POST http://127.0.0.1:8000/api/auth/refresh/ \
  -H 'Content-Type: application/json' -d '{"refresh":"<refresh-token>"}'
```

Access tokens last 60 minutes; refresh tokens last 7 days.

## Endpoints

### Auth
| Method | Path                  | Who        | Purpose                          |
|--------|-----------------------|------------|----------------------------------|
| POST   | /api/auth/register/   | Public     | Register (role: student/company) |
| POST   | /api/auth/login/      | Public     | Get JWT access + refresh tokens  |
| POST   | /api/auth/refresh/    | Public     | Refresh an access token          |
| GET/PUT| /api/auth/me/         | Any        | View/update own account          |

### Profiles
| Method        | Path                       | Who           | Purpose                       |
|---------------|----------------------------|---------------|-------------------------------|
| GET/PUT/PATCH | /api/students/me/          | Student       | Own student profile + CV      |
| GET           | /api/students/             | Company/Admin | Browse student profiles       |
| GET/PUT/PATCH | /api/companies/me/         | Company       | Own company profile           |
| GET           | /api/companies/            | Student/Admin | Browse companies              |
| POST          | /api/companies/{id}/verify/| Admin         | Verify a company              |

### Postings
| Method | Path                          | Who      | Purpose                              |
|--------|-------------------------------|----------|--------------------------------------|
| GET    | /api/postings/                | Any      | List (students see approved only)    |
| POST   | /api/postings/                | Company  | Create a posting (starts *pending*)  |
| GET    | /api/postings/{id}/           | Any      | Retrieve one                         |
| PUT    | /api/postings/{id}/           | Owner    | Update own posting                   |
| POST   | /api/postings/{id}/approve/   | Admin    | Approve (makes it visible)           |
| POST   | /api/postings/{id}/reject/    | Admin    | Reject                               |
| GET    | /api/postings/{id}/applications/ | Owner/Admin | Applications for that posting    |

Search and ordering: `/api/postings/?search=analyst&ordering=-created_at`

### Applications
| Method | Path                            | Who         | Purpose                       |
|--------|---------------------------------|-------------|-------------------------------|
| GET    | /api/applications/              | Role-scoped | List (own / received / all)   |
| POST   | /api/applications/              | Student     | Apply to a posting            |
| POST   | /api/applications/{id}/status/  | Company/Admin | Set shortlisted/accepted/etc |
| POST   | /api/applications/{id}/withdraw/| Student     | Withdraw own application       |

A student can apply to a posting only once (enforced by a DB constraint).

### Notifications
| Method | Path                              | Purpose                  |
|--------|-----------------------------------|--------------------------|
| GET    | /api/notifications/               | List own notifications   |
| GET    | /api/notifications/unread_count/  | Count unread             |
| POST   | /api/notifications/{id}/read/     | Mark one read            |
| POST   | /api/notifications/read_all/      | Mark all read            |

In development, notification emails print to the server console.

## How the roles are enforced

Every queryset is scoped to the caller's role, so the API never leaks data:
a student sees only approved postings and their own applications; a company
sees only its own postings and the applications to them; an admin sees
everything. Write actions (approve, reject, verify, status) are guarded by
role-based permission classes in `accounts/permissions.py`.

## Moving to PostgreSQL

Set these environment variables (see `.env.example`) and rerun migrations:

```
DB_ENGINE=postgres
DB_NAME=attachment
DB_USER=postgres
DB_PASSWORD=yourpassword
DB_HOST=localhost
DB_PORT=5432
```

## Project layout

```
attachment_api/
├── config/          # project settings, root urls, wsgi/asgi
├── accounts/        # User model (roles), profiles, auth, permissions
├── placements/      # job postings, applications, notifications
├── requirements.txt
├── .env.example
└── manage.py
```

## What to build next

1. **React web app** — login, admin dashboard (verify companies, approve
   postings), company portal.
2. **Flutter mobile app** — student browse/apply/track, company applicant
   management.
3. CV file-upload handling in the clients (the `cv` field already accepts
   multipart uploads on `/api/students/me/`).

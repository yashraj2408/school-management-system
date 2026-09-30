# Supabase Backend Integration Guide for School Management System

Yes! Your School Management System connects smoothly with **Supabase**. Using Supabase gives you a production-grade PostgreSQL database, instant REST/GraphQL APIs, built-in Authentication, and Row Level Security (RLS) for parent data privacy.

---

## 🏗️ Architecture: How Supabase Integrates with SMS

```
[ Admission Webform ] ---> [ Python REST API Webhook ] ---> [ Supabase Postgres Database ]
                                                                      │
                                                             Row Level Security (RLS)
                                                                      │
                                                             [ Parent Portal Dashboard ]
```

---

## ⚡ Step-by-Step Supabase Setup Instructions

### 1. Create a Supabase Project
1. Go to [https://supabase.com](https://supabase.com) and create a free project.
2. Note down your **Project URL** and **Service Role API Key** from **Settings -> API**.

### 2. Run Database Schema
1. Open the **SQL Editor** in your Supabase Dashboard.
2. Copy and paste the contents of `sms/supabase_integration/schema.sql`.
3. Click **Run**. This will automatically create:
   - Tables: `students`, `attendance`, `exam_results`, `fee_payments`, `classes`, `sections`, `subjects`, `teachers`, `academic_years`.
   - RLS Policies for parent privacy: Parents can **only view records matching their authenticated email**.

### 3. Connect Environment Variables
In your local environment or server, set:
```bash
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"
```

### 4. Enable Supabase Authentication for Parents
- In Supabase -> **Authentication -> Email**, enable Magic Link / Password login.
- When a parent logs into the portal using their email (e.g. `parent@example.com`), Supabase RLS policies automatically filter and isolate data so they **only see their own child's grades, attendance %, and fee statements**.

---

## 📂 File Directory

- `sms/supabase_integration/schema.sql` - Complete Postgres SQL schema with RLS security policies.
- `sms/supabase_integration/supabase_client.py` - Python client for inserting leads & querying student data.

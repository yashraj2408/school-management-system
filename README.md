# School Management System (SMS)
## Comprehensive Multi-Role Portal & Integration Credentials

Welcome to the **School Management System (SMS)** built for **Zoho CRM**, **Zoho Creator**, and **Supabase PostgreSQL Cloud Database**.

> 📖 **Full System Architecture & Technical Plan**: Read [`SYSTEM_ARCHITECTURE_PLAN.md`](./SYSTEM_ARCHITECTURE_PLAN.md) for full code architecture diagrams, role access matrices, data schemas, and security implementation details.

---

## 🔑 Complete Master Login Credentials Directory

Use these credentials to log in to the live portal at [`http://localhost:8080/index.html`](http://localhost:8080/index.html):

### 1. 👑 Administrator Account
| Role | Email / Username | Password | Access Scope |
| :--- | :--- | :--- | :--- |
| **System Admin** | `admin@school.edu` | `Admin@2026` | Full access to all 200 students (Classes 1-10), Admission Leads, Master 6-day timetables, & Teacher Workload Monitors |

---

### 2. 👨‍🏫 Staff & Teacher Accounts (Max 3 Classes / Day Policy)
| Teacher Name | Email / Username | Password | Subject Specialization |
| :--- | :--- | :--- | :--- |
| **Dr. Ramesh Kumar** | `ramesh.kumar@school.edu` | `Staff@2026` | Mathematics Specialist |
| **Prof. Vikram Malhotra** | `vikram.malhotra@school.edu` | `Staff@2026` | Physics Specialist |
| **Dr. Sneha Paul** | `sneha.paul@school.edu` | `Staff@2026` | Chemistry Specialist |
| **Ms. Neha Sharma** | `neha.sharma@school.edu` | `Staff@2026` | Computer Science Specialist |
| **Ms. Priya Das** | `priya.das@school.edu` | `Staff@2026` | English Literature Specialist |
| **Mr. Rajesh Khanna** | `rajesh.khanna@school.edu` | `Staff@2026` | Social Studies Specialist |

---

### 3. 🎒 Student Accounts (200 Total Students | Classes 1 to 10)
| Class | Student ID | Student Name | Email / Username | Password |
| :--- | :--- | :--- | :--- | :--- |
| **Class 10** | `STD-2026-1001` | Aarav Sharma | `aarav.sharma@student.edu` | `Student@2026` |
| **Class 9** | `STD-2026-901` | Rahul Gupta | `rahul.gupta@student.edu` | `Student@2026` |
| **Class 8** | `STD-2026-801` | Rohan Verma | `rohan.verma@student.edu` | `Student@2026` |
| **Class 7** | `STD-2026-701` | Ananya Patel | `ananya.patel@student.edu` | `Student@2026` |
| **Class 6** | `STD-2026-601` | Kavya Nair | `kavya.nair@student.edu` | `Student@2026` |
| **Class 5** | `STD-2026-501` | Aditya Kumar | `aditya.kumar@student.edu` | `Student@2026` |
| **Class 4** | `STD-2026-401` | Sneha Rao | `sneha.rao@student.edu` | `Student@2026` |
| **Class 3** | `STD-2026-301` | Vikram Das | `vikram.das@student.edu` | `Student@2026` |
| **Class 2** | `STD-2026-201` | Neha Malhotra | `neha.malhotra@student.edu` | `Student@2026` |
| **Class 1** | `STD-2026-101` | Priya Singh | `priya.singh@student.edu` | `Student@2026` |

---

### 4. 👨‍👩‍👧 Parent Accounts (Security Isolated via Supabase RLS)
| Parent Name | Email / Username | Password | Child Name & Class |
| :--- | :--- | :--- | :--- |
| **Vikram Sharma** | `vikram.sharma@example.com` | `Parent@2026` | Aarav Sharma (Class 10) |
| **Sanjay Verma** | `sanjay.verma@example.com` | `Parent@2026` | Rohan Verma (Class 8) |
| **Kiran Patel** | `kiran.patel@example.com` | `Parent@2026` | Ananya Patel (Class 7) |
| **Rajesh Singh** | `rajesh.singh@example.com` | `Parent@2026` | Priya Singh (Class 1) |

---

## 🌐 Quick Access Testing Links

- **Main Multi-Role Portal:** [`http://localhost:8080/index.html`](http://localhost:8080/index.html)
- **Admission Enquiry Webform:** [`http://localhost:8080/Webform_Config.html`](http://localhost:8080/Webform_Config.html)
- **Form Confirmation Page:** [`http://localhost:8080/thank-you.html`](http://localhost:8080/thank-you.html)
- **REST Webhook API Engine:** [`http://localhost:5050/health`](http://localhost:5050/health)
- **Live Supabase Dashboard:** [`https://supabase.com/dashboard/project/awvtyjzhkqcgbjicntep`](https://supabase.com/dashboard/project/awvtyjzhkqcgbjicntep)

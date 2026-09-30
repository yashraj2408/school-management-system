# School Management System (Zoho CRM & Zoho Creator Integration)
## Architecture, Data Modeling, Deluge Automation & Parent Portal Implementation Guide

---

## 1. System Overview & Integration Architecture

The **School Management System (SMS)** is built around a two-tier hybrid architecture leveraging **Zoho CRM** as the central administrative hub and **Zoho Creator** as the parent-facing portal application.

```mermaid
flowchart TD
    A["Public Admission Webform"] -->|Submits Lead| B["Zoho CRM: Leads Module"]
    B -->|Admission Confirmed| C["Zoho CRM: Students Module"]
    
    subgraph CRM ["Zoho CRM Core Modules"]
        C --> D["Academic Structure (Years, Classes, Sections, Subjects, Teachers)"]
        C --> E["Attendance Management Module"]
        C --> F["Examination & Results Module"]
        C --> G["Fee & Payment Management Module"]
    }
    
    subgraph Deluge ["Deluge Scripting & Automation Engine"]
        H["Auto Student ID Generation (STD-YYYY-XXXX)"]
        I["Attendance Duplicate Check & % Calculation"]
        J["Exam Marks, Grade & Class Performance Engine"]
        K["Fee Installment & Outstanding Ledger Engine"]
        L["Automated Low-Attendance & Overdue Fee Parent Alerts"]
    }

    CRM --> Deluge
    Deluge -->|Real-Time Bi-Directional API Sync| M["Zoho Creator: Parent Portal App"]
    
    subgraph Creator ["Zoho Creator Parent Application"]
        M --> N["Parent Security Isolation (Filter by Parent Email)"]
        N --> O["Student Profile & Class Details"]
        N --> P["Live Attendance Dashboard"]
        N --> Q["Exam Progress Report Card"]
        N --> R["Fee Breakdown & Payment History"]
    }
```

---

## 2. Part 1 – Zoho CRM Module Architecture & Field Specifications

### 2.1 Admission Management (Leads Module)
- **Entry point**: Public HTML Webform (`sms/zoho_integration/crm_schema/Webform_Config.html`) mapped to CRM `Leads` API.
- **Workflow State Machine**: `New Enquiry` → `Contacted` → `Campus Visit Scheduled` → `Entrance Test Pending` → `Admission Offered` → `Confirmed` / `Rejected`.
- **Conversion Rule**: When `Lead_Status` changes to `Confirmed`, Deluge auto-converts the lead into a record in the `Students` module.

### 2.2 Student Management (Students Module)
- **Primary Identifier**: Unique `Student_ID` auto-generated via Deluge script `01_auto_generate_student_id.ds` (format: `STD-YYYY-0001`).
- **Fields**: First Name, Last Name, DOB, Gender, Admission Date, Academic Year (Lookup), Current Class (Lookup), Current Section (Lookup), Parent Name, Parent Email, Parent Mobile, Attendance %, Total Fees, Fees Collected, Outstanding Fees, Fee Status.

### 2.3 Academic Structure Modules
- **Academic Years**: Name (`2026-2027`), Start Date, End Date, Status (`Active`, `Completed`).
- **Classes**: Class Name (`Class 10`), Class Code, Grade Level.
- **Sections**: Section Name (`Section A`), Class (Lookup), Class Teacher (Lookup), Capacity.
- **Subjects**: Subject Name, Subject Code, Class (Lookup), Assigned Teacher (Lookup).
- **Teachers**: Teacher Name, Teacher ID, Email, Phone, Specialization.

### 2.4 Attendance Management Module (`Student_Attendance`)
- **Key Validation**: `Attendance_Key` (`Student_ID + "_" + Date`) enforces database uniqueness, preventing duplicate entries for the same student on the same day.
- **Deluge Automation**: `02_attendance_validation_and_calc.ds` automatically recalculates overall attendance percentage on the parent Student record.

### 2.5 Examination & Results Module (`Exam_Results`)
- **Key Validation**: `Result_Key` (`Student_ID + "_" + Exam_ID + "_" + Subject_ID`).
- **Deluge Automation**: `03_exam_marks_and_grade_calc.ds` calculates Percentage, Grade (`A+`, `A`, `B`, `C`, `D`, `F`), and Result Status (`Pass`/`Fail`).

### 2.6 Fee & Payment Management Module (`Fee_Payments`)
- **Installment Ledger**: Maintains multiple payment receipts per student.
- **Deluge Automation**: `04_fee_installment_and_status_calc.ds` calculates `Fees_Collected`, `Outstanding_Fees = Total_Fees - Fees_Collected`, and sets status (`Paid`, `Partial`, `Pending`, `Overdue`).

---

## 3. Part 2 – Zoho Creator Parent Application & Integration

- **Form**: `Student_Parent_Portal_Record`
- **Security & Data Isolation**: Handled via `06_parent_portal_security_filter.ds`. Uses `zoho.loginuserid` matching against `Parent_Email` to ensure parents can only view records for their own children.
- **CRM Sync Engine**: Handled via `05_crm_to_creator_sync.ds`. On any record creation or update in CRM, Deluge uses `zoho.creator.updateRecord` / `postRecord` to keep Creator synchronized.

---

## 4. Reports & Dashboards

1. **Admission Conversion Funnel**: Tracks Lead enquiries from `New Enquiry` through to `Confirmed`.
2. **Class-wise Attendance & Shortage Report**: Filters students with attendance < 75%.
3. **Examination Result Performance Matrix**: Class-level and subject-level pass percentage and grade distribution.
4. **Fee Defaulter & Outstanding Balance Ledger**: List of students with `Outstanding_Fees > 0` sorted by due date.

---

## 5. Additional Feature Implementation

### Automated AI-Driven Parent Notification & Attendance/Fee Alerting System with PDF Report Card Generator
- **Problem Identified**: Manual follow-ups for low attendance (<75%) and pending fees waste hundreds of administrative hours and delay tuition collection.
- **Solution**: Script `07_additional_feature_automated_alerts_reportcard.ds` automatically:
  1. Detects low attendance (<75%) and sends an urgent email alert to the parent.
  2. Detects fee overdue balance and sends an automated fee reminder.
  3. Dynamically compiles student exam results into an HTML/PDF Academic Progress Report Card and emails it directly to the parent.

---

## 6. Directory Map of Solution Files

- `sms/zoho_integration/crm_schema/CRM_Modules_Data_Model.json` - Complete JSON schema definition of CRM modules & fields.
- `sms/zoho_integration/crm_schema/Webform_Config.html` - Production HTML Admission Enquiry Webform.
- `sms/zoho_integration/deluge_scripts/` - All 7 Deluge automation scripts.
- `sms/zoho_integration/creator_app/` - Creator Parent App definition & schema.
- `sms/zoho_integration/api/zoho_crm_creator_webhook.py` - REST Webhook Python integration backend.

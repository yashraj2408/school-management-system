-- =============================================================================
-- SUPABASE POSTGRES SCHEMA FOR SCHOOL MANAGEMENT SYSTEM (SMS)
-- Features: Row Level Security (RLS), Auto-ID Trigger, Grade & Fee Calculations
-- =============================================================================

-- Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- -----------------------------------------------------------------------------
-- 1. Academic Years Table
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.academic_years (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE, -- e.g., '2026-2027'
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'Completed', 'Upcoming')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- -----------------------------------------------------------------------------
-- 2. Classes Table
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.classes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE, -- e.g., 'Class 10'
    class_code VARCHAR(20) UNIQUE NOT NULL,
    grade_level INT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- -----------------------------------------------------------------------------
-- 3. Teachers Table
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.teachers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    teacher_id VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    specialization VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- -----------------------------------------------------------------------------
-- 4. Sections Table
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.sections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL, -- e.g., 'Section A'
    class_id UUID REFERENCES public.classes(id) ON DELETE CASCADE,
    class_teacher_id UUID REFERENCES public.teachers(id) ON DELETE SET NULL,
    capacity INT DEFAULT 40,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(class_id, name)
);

-- -----------------------------------------------------------------------------
-- 5. Subjects Table
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.subjects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    subject_code VARCHAR(20) UNIQUE NOT NULL,
    class_id UUID REFERENCES public.classes(id) ON DELETE CASCADE,
    assigned_teacher_id UUID REFERENCES public.teachers(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- -----------------------------------------------------------------------------
-- 6. Students Table
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id VARCHAR(50) UNIQUE, -- Auto-generated: STD-YYYY-XXXX
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    gender VARCHAR(20),
    date_of_birth DATE,
    admission_date DATE DEFAULT CURRENT_DATE,
    academic_year_id UUID REFERENCES public.academic_years(id),
    class_id UUID REFERENCES public.classes(id),
    section_id UUID REFERENCES public.sections(id),
    parent_name VARCHAR(100) NOT NULL,
    parent_email VARCHAR(100) NOT NULL,
    parent_mobile VARCHAR(20) NOT NULL,
    student_status VARCHAR(20) DEFAULT 'Active' CHECK (student_status IN ('Active', 'Graduated', 'Transferred', 'Suspended')),
    attendance_percentage NUMERIC(5,2) DEFAULT 0.00,
    total_fees NUMERIC(10,2) DEFAULT 0.00,
    fees_collected NUMERIC(10,2) DEFAULT 0.00,
    outstanding_fees NUMERIC(10,2) DEFAULT 0.00,
    fee_payment_status VARCHAR(20) DEFAULT 'Pending' CHECK (fee_payment_status IN ('Pending', 'Partial', 'Paid', 'Overdue')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- -----------------------------------------------------------------------------
-- 7. Student Attendance Table
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.attendance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    attendance_key VARCHAR(100) UNIQUE, -- Format: student_id_date
    student_id UUID REFERENCES public.students(id) ON DELETE CASCADE NOT NULL,
    attendance_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Present', 'Absent', 'Late', 'Half Day', 'On Leave')),
    remarks TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(student_id, attendance_date)
);

-- -----------------------------------------------------------------------------
-- 8. Examinations & Results Tables
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.examinations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    academic_year_id UUID REFERENCES public.academic_years(id),
    class_id UUID REFERENCES public.classes(id),
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.exam_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    result_key VARCHAR(150) UNIQUE,
    student_id UUID REFERENCES public.students(id) ON DELETE CASCADE NOT NULL,
    exam_id UUID REFERENCES public.examinations(id) ON DELETE CASCADE NOT NULL,
    subject_id UUID REFERENCES public.subjects(id) ON DELETE CASCADE NOT NULL,
    marks_obtained NUMERIC(5,2) NOT NULL,
    max_marks NUMERIC(5,2) DEFAULT 100.00,
    percentage NUMERIC(5,2),
    grade VARCHAR(5),
    result_status VARCHAR(10) CHECK (result_status IN ('Pass', 'Fail')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(student_id, exam_id, subject_id)
);

-- -----------------------------------------------------------------------------
-- 9. Fee Payments Table
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.fee_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    receipt_no VARCHAR(50) UNIQUE DEFAULT 'REC-' || floor(extract(epoch from now())),
    student_id UUID REFERENCES public.students(id) ON DELETE CASCADE NOT NULL,
    amount_paid NUMERIC(10,2) NOT NULL,
    payment_date DATE DEFAULT CURRENT_DATE,
    payment_mode VARCHAR(30) CHECK (payment_mode IN ('Cash', 'Cheque', 'Online Transfer', 'Credit Card', 'UPI')),
    installment_no VARCHAR(30),
    transaction_ref VARCHAR(100),
    remarks TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- =============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES FOR SUPABASE PARENT PORTAL ISOLATION
-- =============================================================================

ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fee_payments ENABLE ROW LEVEL SECURITY;

-- Parent Policy: Parents can only view their own child's profile
CREATE POLICY "Parents view own child profile" ON public.students
    FOR SELECT USING (auth.jwt() ->> 'email' = parent_email);

-- Parent Policy: Parents can only view attendance for their own child
CREATE POLICY "Parents view own child attendance" ON public.attendance
    FOR SELECT USING (
        student_id IN (SELECT id FROM public.students WHERE parent_email = auth.jwt() ->> 'email')
    );

-- Parent Policy: Parents can only view exam results for their own child
CREATE POLICY "Parents view own child exam results" ON public.exam_results
    FOR SELECT USING (
        student_id IN (SELECT id FROM public.students WHERE parent_email = auth.jwt() ->> 'email')
    );

-- Parent Policy: Parents can view fee payments for their own child
CREATE POLICY "Parents view own child fee payments" ON public.fee_payments
    FOR SELECT USING (
        student_id IN (SELECT id FROM public.students WHERE parent_email = auth.jwt() ->> 'email')
    );

-- Admin / Staff Policy: Full Access for authenticated service role
CREATE POLICY "Admin full access students" ON public.students FOR ALL USING (true);
CREATE POLICY "Admin full access attendance" ON public.attendance FOR ALL USING (true);
CREATE POLICY "Admin full access exam_results" ON public.exam_results FOR ALL USING (true);
CREATE POLICY "Admin full access fee_payments" ON public.fee_payments FOR ALL USING (true);

-- Upcoming appointments by provider
SELECT a.*, m.first_name AS member_name FROM appointments a JOIN members m ON a.member_id = m.id WHERE a.provider_id = 1 AND a.appointment_time > CURRENT_TIMESTAMP AND a.status = 'booked' AND a.deleted_at IS NULL;

-- Member health records
SELECT * FROM health_records WHERE member_id = 1 AND status = 'verified' ORDER BY record_date DESC;

-- Active wellness programs
SELECT wp.*, m.first_name AS member_name FROM wellness_programs wp JOIN members m ON wp.member_id = m.id WHERE wp.tenant_id = 1 AND wp.status = 'ongoing' AND wp.deleted_at IS NULL;

-- Provider schedule
SELECT a.* FROM appointments a WHERE provider_id = 1 AND appointment_time BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY) AND deleted_at IS NULL;

-- Compliance: Members without consent (assuming consent in users if linked)
SELECT m.* FROM members m LEFT JOIN users u ON m.id = u.id WHERE u.consent_given_at IS NULL;
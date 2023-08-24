ALTER TABLE reservations ADD KEY event_id_and_sheet_id_reserved_at_idx (event_id, sheet_id, reserved_at)
ALTER TABLE reservations ADD KEY user_id_sheet_id_idx (user_id, sheet_id)

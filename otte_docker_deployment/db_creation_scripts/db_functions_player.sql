---------------------------------- Session Management ----------------------------------
-- Function to update the lastCheckIn timestamp and reset the validDuration for a specific session
CREATE OR REPLACE FUNCTION update_last_checkin_for_player(session_token VARCHAR)
RETURNS VOID AS $$
BEGIN
    -- Update the lastCheckIn timestamp to the current time
    -- and reset the validDuration to 1 hour for the session with the provided token
    UPDATE Session
    SET "lastCheckIn" = NOW()
    WHERE token = session_token;
END;
$$ LANGUAGE plpgsql;

-- Function to check and expire sessions that have been inactive beyond their valid duration
CREATE OR REPLACE FUNCTION check_and_expire_sessions()
RETURNS VOID AS $$
BEGIN
    DELETE FROM Session
    WHERE "lastCheckIn" + validDuration < NOW();
END;
$$ LANGUAGE plpgsql;
---------------------------------- Session Management ----------------------------------


package com.nplekhanov.finance;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.PreparedStatementSetter;
import org.springframework.jdbc.core.ResultSetExtractor;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;

import javax.xml.bind.DatatypeConverter;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.Calendar;
import java.util.Collection;
import java.util.TimeZone;
import java.util.UUID;

/**
 * @author nplekhanov
 */
@Service
public class Users {

    @Autowired
    private JdbcTemplate jdbc;

    private SecureRandom saltGenerator = new SecureRandom();

    public User authenticate(String name, String password) {
        String hash = jdbc.query("select pwd_hash from user where name = ?", new OptionalStringResultSetExtractor(), name);
        if (hash == null) {
            return null;
        }
        if (!checkPasswordHash(password, hash)) {
            return null;
        }

        return jdbc.queryForObject("select id, name from user where name = ?", new UserRowMapper(), name);
    }

    private boolean checkPasswordHash(String passwordToCheck, String saltedHash) {
        String[] parts = saltedHash.split(";", 2);
        String knownHash = parts[0];
        String knownSalt = parts[1];
        String hashToCheck = calculateSaltedHash(passwordToCheck, knownSalt);
        return hashToCheck.equals(knownHash);
    }

    public void registerUser(final String invitationCode, String name, String password) {
        String description = jdbc.query("select description from invitation where code = ? and registered_at is null",
                new OptionalStringResultSetExtractor(), invitationCode);
        if (description == null) {
            return;
        }
        String salt = generateSalt();

        String passwordHash = calculateSaltedHash(password, salt);

        Object saltedHash = passwordHash + ";" + salt;
        jdbc.update("insert into user (name, description, pwd_hash) values (?, ?, ?)", name, description, saltedHash);
        jdbc.update("update invitation set registered_at = ? where code = ?", new PreparedStatementSetter() {
            @Override
            public void setValues(PreparedStatement ps) throws SQLException {
                ps.setTimestamp(1, Timestamp.from(Instant.now()), getCalendarForTz());
                ps.setString(2, invitationCode);
            }
        });

    }

    public void invite(final String description) {
        final String code = toSha256(UUID.randomUUID().toString());
        jdbc.update("insert into invitation (description, code, invited_at) values (?, ?, ?)", new PreparedStatementSetter() {
            @Override
            public void setValues(PreparedStatement ps) throws SQLException {
                ps.setString(1, description);
                ps.setString(2, code);
                ps.setTimestamp(3, Timestamp.from(Instant.now()), getCalendarForTz());
            }
        });

    }

    private Calendar getCalendarForTz() {
        return Calendar.getInstance(TimeZone.getTimeZone("Europe/Moscow"));
    }

    public Collection<Invitation> getInvitations() {
        return jdbc.query("select * from invitation", new RowMapper<Invitation>() {
            @Override
            public Invitation mapRow(ResultSet rs, int rowNum) throws SQLException {
                Invitation i = new Invitation();
                i.setCode(rs.getString("code"));
                i.setDescription(rs.getString("description"));
                i.setInvitedAt(rs.getTimestamp("invited_at", getCalendarForTz()).toInstant());
                Timestamp registeredAt = rs.getTimestamp("registered_at", getCalendarForTz());
                if (registeredAt != null) {
                    i.setRegisteredAt(registeredAt.toInstant());
                }
                return i;
            }
        });
    }

    private String generateSalt() {
        byte[] saltBytes = new byte[32];
        saltGenerator.nextBytes(saltBytes);
        return DatatypeConverter.printHexBinary(saltBytes);
    }

    private String calculateSaltedHash(String text, String salt) {
        return toSha256(toSha256(text) + salt);
    }

    private String toSha256(String text) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");

            byte[] hash = md.digest(text.getBytes("utf8"));
            return DatatypeConverter.printHexBinary(hash);

        } catch (NoSuchAlgorithmException | UnsupportedEncodingException e) {
            throw new IllegalStateException(e);
        }
    }

    public User getUser(long userId) {
        return jdbc.queryForObject("select id, name from user where id = ?", new UserRowMapper(), userId);
    }

    private static class UserRowMapper implements RowMapper<User> {
        @Override
        public User mapRow(ResultSet rs, int rowNum) throws SQLException {
            User user = new User();
            user.setId(rs.getLong("id"));
            user.setName(rs.getString("name"));
            return user;
        }
    }

    private static class OptionalStringResultSetExtractor implements ResultSetExtractor<String> {
        @Override
        public String extractData(ResultSet rs) throws SQLException, DataAccessException {
            return rs.next() ? rs.getString(1) : null;
        }
    }
}

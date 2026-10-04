package com.ecomate.backend.dto;

import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class UpdateProfileRequestTest {
    private static ValidatorFactory validatorFactory;
    private static Validator validator;

    @BeforeAll
    static void setUpValidator() {
        validatorFactory = Validation.buildDefaultValidatorFactory();
        validator = validatorFactory.getValidator();
    }

    @AfterAll
    static void closeValidator() {
        validatorFactory.close();
    }

    @Test
    void acceptsOptionalContactFieldsAndPhoto() {
        var request = new UpdateProfileRequest("Resident Name", "", "", "data:image/jpeg;base64,ZmFrZQ==");
        assertTrue(validator.validate(request).isEmpty());
    }

    @Test
    void rejectsBlankNamesAndMalformedPhoneNumbers() {
        var blankName = new UpdateProfileRequest("  ", "0771234567", "", "");
        var invalidPhone = new UpdateProfileRequest("Resident Name", "call me", "", "");

        assertFalse(validator.validate(blankName).isEmpty());
        assertFalse(validator.validate(invalidPhone).isEmpty());
    }
}
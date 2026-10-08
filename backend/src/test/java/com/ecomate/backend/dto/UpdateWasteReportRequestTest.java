package com.ecomate.backend.dto;

import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertFalse;

class UpdateWasteReportRequestTest {
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
    void acceptsSupportedPriorities() {
        for (String priority : new String[]{"LOW", "MEDIUM", "HIGH"}) {
            var request = new UpdateWasteReportRequest("IN_REVIEW", priority, "Waste Team A");
            assertTrue(validator.validate(request).isEmpty(), priority);
        }
    }

    @Test
    void rejectsUnsupportedPriority() {
        var request = new UpdateWasteReportRequest("IN_REVIEW", "URGENT", "Waste Team A");
        assertFalse(validator.validate(request).isEmpty());
    }
}
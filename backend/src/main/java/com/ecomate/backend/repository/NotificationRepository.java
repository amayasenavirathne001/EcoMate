package com.ecomate.backend.repository;

import com.ecomate.backend.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findByEmployeeIdOrderByDateTimeDesc(String employeeId);
}

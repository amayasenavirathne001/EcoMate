package com.ecomate.backend.service;

import com.ecomate.backend.dto.NotificationDto;
import com.ecomate.backend.entity.Notification;
import com.ecomate.backend.repository.NotificationRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class NotificationService {

    private final NotificationRepository repository;

    public NotificationService(NotificationRepository repository) {
        this.repository = repository;
    }

    public List<NotificationDto> getNotificationsForEmployee(String employeeId) {
        return repository.findByEmployeeIdOrderByDateTimeDesc(employeeId).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public NotificationDto createNotification(String employeeId, String title, String message) {
        Notification notification = new Notification(employeeId, title, message, LocalDateTime.now());
        return toDto(repository.save(notification));
    }

    public void markAsRead(Long id) {
        Notification entity = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Notification not found with id " + id));
        entity.setRead(true);
        repository.save(entity);
    }

    public NotificationDto toDto(Notification entity) {
        return new NotificationDto(
            entity.getId(),
            entity.getEmployeeId(),
            entity.getTitle(),
            entity.getMessage(),
            entity.getDateTime(),
            entity.isRead()
        );
    }
}

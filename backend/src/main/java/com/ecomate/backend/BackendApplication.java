package com.ecomate.backend;

import com.ecomate.backend.entity.*;
import com.ecomate.backend.repository.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDate;
import java.time.LocalDateTime;

@SpringBootApplication
public class BackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(BackendApplication.class, args);
	}

	@Bean
	public CommandLineRunner seedDatabase(
			UserRepository userRepository,
			CollectorDriverRepository employeeRepository,
			VehicleRepository vehicleRepository,
			CollectionJobRepository jobRepository,
			PasswordEncoder passwordEncoder) {
		return args -> {
			// Seed Municipal Admin
			if (!userRepository.existsByEmail("admin@ecomate.com")) {
				User admin = new User(
					"Municipal Admin",
					"admin@ecomate.com",
					passwordEncoder.encode("admin123"),
					Role.COUNCIL_ADMIN
				);
				userRepository.save(admin);
			}

			// Seed a test Collector User (matching John Doe EMP-001)
			if (!userRepository.existsByEmail("collector@ecomate.com")) {
				User collector = new User(
					"John Doe",
					"collector@ecomate.com",
					passwordEncoder.encode("collector123"),
					Role.COLLECTOR
				);
				userRepository.save(collector);
			}

			// Seed Drivers & Collectors
			if (employeeRepository.count() == 0) {
				employeeRepository.save(new CollectorDriver("EMP-001", "John Doe", "0771234567", EmployeeRole.DRIVER, "Zone A", "Morning", EmployeeStatus.AVAILABLE));
				employeeRepository.save(new CollectorDriver("EMP-002", "Jane Smith", "0777654321", EmployeeRole.COLLECTOR, "Zone A", "Morning", EmployeeStatus.AVAILABLE));
				employeeRepository.save(new CollectorDriver("EMP-003", "Bob Johnson", "0771112223", EmployeeRole.COLLECTOR, "Zone B", "Evening", EmployeeStatus.AVAILABLE));
				employeeRepository.save(new CollectorDriver("EMP-004", "Alice Williams", "0773334445", EmployeeRole.DRIVER, "Zone B", "Evening", EmployeeStatus.AVAILABLE));
				employeeRepository.save(new CollectorDriver("EMP-005", "Charlie Brown", "0775556667", EmployeeRole.COLLECTOR, "Zone A", "Morning", EmployeeStatus.AVAILABLE));
			}

			// Seed Vehicles
			if (vehicleRepository.count() == 0) {
				vehicleRepository.save(new Vehicle("WP-CAD-1024", "Compactor", 5.0, VehicleStatus.AVAILABLE, LocalDate.now().minusMonths(2)));
				vehicleRepository.save(new Vehicle("WP-GB-8899", "Dumper", 3.5, VehicleStatus.AVAILABLE, LocalDate.now().minusMonths(1)));
				vehicleRepository.save(new Vehicle("WP-LH-4455", "Flatbed", 2.0, VehicleStatus.AVAILABLE, LocalDate.now().minusWeeks(2)));
			}

			// Seed Collection Jobs
			if (jobRepository.count() == 0) {
				LocalDateTime today = LocalDateTime.now().withHour(0).withMinute(0).withSecond(0).withNano(0);
				jobRepository.save(new CollectionJob("R-101", "Greenfield Residential", "Weekly organic waste collection in Greenfield", "Zone A", today.plusHours(8), today.plusHours(11), "SCHEDULED"));
				jobRepository.save(new CollectionJob("R-102", "Greenfield Commercial", "Plastic and cardboard collection for retail sector", "Zone A", today.plusHours(11).plusMinutes(30), today.plusHours(14).plusMinutes(30), "SCHEDULED"));
				jobRepository.save(new CollectionJob("R-201", "Lakeview Mixed Collection", "Mixed municipal solid waste collection", "Zone B", today.plusHours(9), today.plusHours(12), "SCHEDULED"));
				jobRepository.save(new CollectionJob("R-301", "Riverside Dumpsters", "Emptying street bins and public dumpster units", "Zone C", today.plusHours(14), today.plusHours(17), "SCHEDULED"));
			}
		};
	}
}


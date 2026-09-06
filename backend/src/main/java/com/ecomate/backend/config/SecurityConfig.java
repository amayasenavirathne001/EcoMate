package com.ecomate.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;
@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http)
            throws Exception {

        http
            .csrf(csrf -> csrf.disable())
            .cors(cors ->
                cors.configurationSource(corsConfigurationSource()))
            // JWT authentication is stateless
            .sessionManagement(session ->
                session.sessionCreationPolicy(
                    SessionCreationPolicy.STATELESS
                )
            )

            .authorizeHttpRequests(auth -> auth

            .requestMatchers(
                            "/api/auth/login",
                            "/api/auth/register",
                            "/api/recycling/public/**"
            ).permitAll()

                .requestMatchers("/api/auth/me")
                .authenticated()
                // Role-based endpoints
                .requestMatchers("/api/resident/**")
                    .hasRole("RESIDENT")

                .requestMatchers("/api/collector/**")
                    .hasRole("COLLECTOR")

                .requestMatchers("/api/recycling/my-centre/**")
                    .hasRole("RECYCLING_OFFICER")

                .requestMatchers("/api/recycling/**")
                    .authenticated()

                .requestMatchers("/api/council/**")
                    .hasRole("COUNCIL_ADMIN")

                .requestMatchers("/api/municipal/**")
                    .hasRole("COUNCIL_ADMIN")

                // Everything else requires login
                .anyRequest().authenticated()
            )

            // Validate Bearer JWT tokens
            .oauth2ResourceServer(oauth2 ->
                oauth2.jwt(jwt ->
                    jwt.jwtAuthenticationConverter(
                        jwtAuthenticationConverter()
                    )
                )
            );

        return http.build();
    }

    @Bean
    public JwtAuthenticationConverter jwtAuthenticationConverter() {

        JwtGrantedAuthoritiesConverter authoritiesConverter =
                new JwtGrantedAuthoritiesConverter();

        // Our JWT contains:
        // "role": "RESIDENT"
        authoritiesConverter.setAuthoritiesClaimName("role");

        // hasRole("RESIDENT") expects ROLE_RESIDENT
        authoritiesConverter.setAuthorityPrefix("ROLE_");

        JwtAuthenticationConverter converter =
                new JwtAuthenticationConverter();

        converter.setJwtGrantedAuthoritiesConverter(
                authoritiesConverter
        );

        return converter;
    }
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {

    CorsConfiguration configuration = new CorsConfiguration();

    configuration.setAllowedOriginPatterns(
        List.of("http://localhost:*")
    );

    configuration.setAllowedMethods(
        List.of("GET", "POST", "PUT", "DELETE", "OPTIONS")
    );

    configuration.setAllowedHeaders(
        List.of("*")
    );

    configuration.setAllowCredentials(true);

    UrlBasedCorsConfigurationSource source =
        new UrlBasedCorsConfigurationSource();

    source.registerCorsConfiguration(
        "/**",
        configuration
    );

    return source;
   }
}
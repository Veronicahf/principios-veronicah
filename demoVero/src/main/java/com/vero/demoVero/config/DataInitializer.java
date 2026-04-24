package com.vero.demoVero.config;

import java.util.HashSet;
import java.util.Set;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.vero.demoVero.models.ERole;
import com.vero.demoVero.models.Role;
import com.vero.demoVero.models.User;
import com.vero.demoVero.repository.RoleRepository;
import com.vero.demoVero.repository.UserRepository;

@Configuration
public class DataInitializer {

  @Bean
  CommandLineRunner seedAuthData(RoleRepository roleRepository, UserRepository userRepository,
      PasswordEncoder passwordEncoder) {
    return args -> {
      Role userRole = ensureRole(roleRepository, ERole.ROLE_USER);
      Role moderatorRole = ensureRole(roleRepository, ERole.ROLE_MODERATOR);
      ensureRole(roleRepository, ERole.ROLE_ADMIN);

      userRepository.findByUsername("mod").orElseGet(() -> {
        User demoUser = new User("mod", "mod@bezkoder.com", passwordEncoder.encode("12345678"));
        Set<Role> roles = new HashSet<>();
        roles.add(userRole);
        roles.add(moderatorRole);
        demoUser.setRoles(roles);
        return userRepository.save(demoUser);
      });
    };
  }

  private Role ensureRole(RoleRepository roleRepository, ERole roleName) {
    return roleRepository.findByName(roleName).orElseGet(() -> roleRepository.save(new Role(roleName)));
  }
}
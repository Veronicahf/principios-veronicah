package com.vero.superheroes.controllers;

import com.vero.superheroes.models.Superheroe;
import com.vero.superheroes.models.User;
import com.vero.superheroes.repository.SuperheroeRepository;
import com.vero.superheroes.repository.UserRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/superheroes")
public class SuperheroeController {

    @Autowired
    private SuperheroeRepository superheroeRepository;

    @Autowired
    private UserRepository userRepository;

    @GetMapping("/all")
    public Page<Superheroe> getAll(Pageable pageable) {
        return superheroeRepository.findAll(pageable);
    }

    @PostMapping("")
    public Superheroe create(@Valid @RequestBody Superheroe superheroe) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();

        Optional<User> userOptional = userRepository.findByUsername(username);
        if (userOptional.isEmpty()) {
            throw new RuntimeException("User not found");
        }
        User user = userOptional.get();

        superheroe.setPostedBy(user);
        return superheroeRepository.save(superheroe);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();

        boolean canDeleteAny = authentication.getAuthorities().stream()
            .map(GrantedAuthority::getAuthority)
            .anyMatch(role -> role.equals("ROLE_ADMIN") || role.equals("ROLE_MODERATOR"));

        Superheroe superheroe = superheroeRepository.findById(id)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Superheroe not found"));

        boolean isOwner = superheroe.getPostedBy() != null
            && username.equals(superheroe.getPostedBy().getUsername());

        if (!canDeleteAny && !isOwner) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                "You can only delete your own superheroe");
        }

        superheroeRepository.deleteById(id);
    }
}

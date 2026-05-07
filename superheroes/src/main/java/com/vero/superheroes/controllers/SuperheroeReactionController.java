package com.vero.superheroes.controllers;
import java.util.Map;
import java.util.HashMap;
import java.util.stream.Collectors;
import org.springframework.http.ResponseEntity;
import java.util.Optional;
import java.util.List;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.ResponseEntity; 
import jakarta.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.GetMapping;

import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.vero.superheroes.models.Superheroe;
import com.vero.superheroes.models.SuperheroeReaction;
import com.vero.superheroes.models.User;
import com.vero.superheroes.payload.request.SuperheroeReactionRequest;
import com.vero.superheroes.models.Reaction;

import com.vero.superheroes.repository.UserRepository;
import com.vero.superheroes.repository.ReactionRepository;
import com.vero.superheroes.repository.SuperheroeReactionRepository;
import com.vero.superheroes.repository.SuperheroeRepository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/reactions")

public class SuperheroeReactionController {

    @Autowired
    private SuperheroeReactionRepository superheroeReactionRepository;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private SuperheroeRepository superheroeRepository;
    @Autowired
    private ReactionRepository reactionRepository;


  @GetMapping("/all")
    public Page<SuperheroeReaction> getSuperheroeReactions(Pageable pageable) {
        return superheroeReactionRepository.findAll(pageable);
    }

    // Endpoint para obtener todas las reacciones de un superhéroe específico.
    // Esto nos dirá qué usuarios han reaccionado a un superhéroe.
    @GetMapping("/superheroe/{superheroeId}")
public ResponseEntity<List<Map<String, Object>>> getReactionsBySuperheroe(@PathVariable Long superheroeId) {
    List<SuperheroeReaction> reactions = superheroeReactionRepository.findBySuperheroeId(superheroeId);
    
    // Transformamos las entidades a mapas simples para evitar el bucle de Jackson
    List<Map<String, Object>> response = reactions.stream().map(r -> {
        Map<String, Object> map = new HashMap<>();
        map.put("id", r.getId());
        
        // Enviamos solo los IDs para evitar traer entidades completas
        map.put("reactionId", r.getReaction().getId());
        map.put("userId", r.getUser().getId());
        map.put("superheroeId", r.getSuperheroe().getId());
        
        // Incluimos los datos de la reacción para que Flutter pueda mostrar el emoji
        Map<String, Object> reactionData = new HashMap<>();
        reactionData.put("id", r.getReaction().getId());
        reactionData.put("description", r.getReaction().getDescription());
        map.put("reaction", reactionData);
        
        return map;
    }).collect(Collectors.toList());
    
    return ResponseEntity.ok(response);
}

    // Endpoint para contar el número total de reacciones de un superhéroe.
    @GetMapping("/superheroe/{superheroeId}/count")
    public long countReactionsBySuperheroe(@PathVariable Long superheroeId) {
        return superheroeReactionRepository.countBySuperheroeId(superheroeId);
    }

    // Endpoint para contar las reacciones de un tipo específico para un superhéroe.
    // Por ejemplo, cuántos "likes" (reactionId=1) tiene un superhéroe.
    @GetMapping("/superheroe/{superheroeId}/count/{reactionId}")
    public long countReactionsBySuperheroeAndReaction(@PathVariable Long superheroeId, @PathVariable Long reactionId) {
        return superheroeReactionRepository.countBySuperheroeIdAndReactionId(superheroeId, reactionId);
    }

        // El usuario autenticado puede quitar su reacción a un superhéroe.
        // El usuario autenticado puede quitar su reacción a un superhéroe.
    @Transactional // <--- ESTO ES LA MAGIA QUE FALTA
    @DeleteMapping("/superheroe/{superheroeId}")
    public ResponseEntity<?> deleteMyReaction(@PathVariable Long superheroeId) {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            String userId = authentication.getName();

            User user = getValidUser(userId);
            superheroeReactionRepository.deleteByUserIdAndSuperheroeId(user.getId(), superheroeId);
            
            // Es buena práctica devolver un 200 OK explícito en lugar de "void"
            return ResponseEntity.ok().build(); 
    }
  
  @PostMapping("/create")
  public SuperheroeReaction createReaction(@Valid @RequestBody SuperheroeReactionRequest superheroeReactionRequest) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userId = authentication.getName();

        User user = getValidUser(userId);
        Superheroe superheroe = getValidSuperheroe(superheroeReactionRequest.getSuperheroeId());
        Reaction reaction = getValidReaction(superheroeReactionRequest.getReactionId());

        SuperheroeReaction newSuperheroeReaction = superheroeReactionRepository
            .findByUserIdAndSuperheroeId(user.getId(), superheroe.getId())
            .orElseGet(SuperheroeReaction::new);

        newSuperheroeReaction.setUser(user);
        newSuperheroeReaction.setSuperheroe(superheroe);
        newSuperheroeReaction.setReaction(reaction);

        newSuperheroeReaction = superheroeReactionRepository.save(newSuperheroeReaction);

        return newSuperheroeReaction;
  }

    private User getValidUser(String userId) {
        Optional<User> userOpt = userRepository.findByUsername(userId);
        if (userOpt.isEmpty()) {
            throw new RuntimeException("User not found");
        }
        return userOpt.get();
    }

    private Superheroe getValidSuperheroe(Long superheroeId) {
        Optional<Superheroe> superheroeOpt = superheroeRepository.findById(superheroeId);
        if (superheroeOpt.isEmpty()) {
            throw new RuntimeException("Superheroe not found");
        }
        return superheroeOpt.get();
    }

    private Reaction getValidReaction(Long reactionId) {
        Optional<Reaction> reactionOpt = reactionRepository.findById(reactionId);
        if (reactionOpt.isEmpty()) {
            throw new RuntimeException("Reaction not found");
        }
        return reactionOpt.get();
    }
}

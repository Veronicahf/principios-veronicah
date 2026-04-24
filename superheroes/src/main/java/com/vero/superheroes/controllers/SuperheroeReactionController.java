package com.vero.superheroes.controllers;
import java.util.Optional;

import jakarta.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.GetMapping;

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
  
  @PostMapping("/create")
  public SuperheroeReaction createReaction(@Valid @RequestBody SuperheroeReactionRequest superheroeReactionRequest) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userId = authentication.getName();

        User user = getValidUser(userId);
        Superheroe superheroe = getValidSuperheroe(superheroeReactionRequest.getSuperheroeId());
        Reaction reaction = getValidReaction(superheroeReactionRequest.getReactionId());

        SuperheroeReaction newSuperheroeReaction = new SuperheroeReaction();
        newSuperheroeReaction.setUser(user);
        newSuperheroeReaction.setSuperheroe(superheroe);
        newSuperheroeReaction.setReaction(reaction);

        superheroeReactionRepository.save(newSuperheroeReaction);

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

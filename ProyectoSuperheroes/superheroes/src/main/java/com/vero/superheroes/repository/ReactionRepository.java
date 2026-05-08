package com.vero.superheroes.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.vero.superheroes.models.Reaction;

@Repository
public interface ReactionRepository extends JpaRepository<Reaction, Long> {

}

